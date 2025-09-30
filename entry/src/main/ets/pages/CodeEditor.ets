import { RealFileService } from '../services/RealFileService';
import { FileItem, EditorTab } from '../models/FileModel';
import { HighlightedText } from '../components/HighlightedText';
import { MarkdownPreview } from '../components/MarkdownPreview';
import { MarkdownService } from '../services/MarkdownService';
import { ThemeService, Theme } from '../services/ThemeService';
import { SearchDialog } from '../components/SearchDialog';
import { SearchResult } from '../services/SearchService';
import { common } from '@kit.AbilityKit';
import { FileTreeItem } from '../components/FileTreeItem';

@Entry
@Component
struct CodeEditor {
  private fileService: RealFileService = new RealFileService();
  private context: common.UIAbilityContext | null = null;
  private markdownService: MarkdownService = new MarkdownService();
  private themeService: ThemeService = new ThemeService();

  @State currentFile: string = '';
  @State isFileTreeVisible: boolean = true;
  @State fileTree: FileItem[] = [];
  @State currentFolder: string = '';
  @State tabs: EditorTab[] = [];
  @State activeTab: EditorTab | null = null;
  @State editorContent: string = '';
  @State isLoading: boolean = false;
  @State expandedFolders: Set<string> = new Set();
  @State isPreviewMode: boolean = false;
  @State isMarkdownFile: boolean = false;
  @State showSearchDialog: boolean = false;
  @State currentTheme: Theme = this.themeService.getCurrentTheme();

  private autoSaveInterval: number | null = null;

  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.fileService.setContext(this.context);
    this.setupThemeListener();
    this.loadSavedTheme();
    this.setupAutoSave();
  }

  aboutToDisappear() {
    this.cleanupAutoSave();
  }

  private setupThemeListener() {
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  private async loadSavedTheme() {
    try {
      const savedThemeId = await this.themeService.loadThemePreference();
      if (savedThemeId) {
        this.themeService.switchTheme(savedThemeId);
      }
    } catch (error) {
      console.error('加载主题设置失败:', error);
    }
  }

  build() {
    Navigation() {
        Column() {
        // 顶部工具栏
        this.buildToolbar()

        // 标签栏
          if (this.tabs.length > 0) {
          this.buildTabBar()
          }

        // 主工作区
          Row() {
          // 侧边栏
            if (this.isFileTreeVisible) {
            this.buildSidebar()
            }

          // 编辑器区域
          this.buildEditor()
          }
          .layoutWeight(1)
        .backgroundColor($r('app.color.background_primary'))
        }
        .width('100%')
      .height('100%')

      // 搜索对话框
        if (this.showSearchDialog) {
          SearchDialog({
            visible: this.showSearchDialog,
          onClose: () => { this.showSearchDialog = false; },
            onResultSelect: (result: SearchResult) => {
              this.handleSearchResult(result);
            }
          })
        }
      }
    .hideTitleBar(true)
  }

  @Builder
  buildToolbar(): void {
      Row() {
      // 左侧操作按钮
        Row() {
        this.buildToolButton('📁', '打开文件夹', (): void => { 
          console.log('[按钮点击] 打开文件夹');
          this.openFolderDialog(); 
        })
        this.buildToolButton('📄', '打开文件', (): void => { 
          console.log('[按钮点击] 打开文件');
          this.openFileDialog(); 
        })
        this.buildToolButton('💾', '保存', (): void => { 
          console.log('[按钮点击] 保存文件');
          this.saveCurrentFile(); 
        }, !!this.activeTab)
        
        // Markdown 预览切换
        if (this.isMarkdownFile) {
          Divider()
            .vertical(true)
            .height(20)
            .color($r('app.color.border_light'))
            .margin({ left: 12, right: 12 })
          
          this.buildToggleButton(this.isPreviewMode ? '📝 编辑' : '👁 预览', (): void => { this.togglePreviewMode(); })
          }
        }
        .alignItems(VerticalAlign.Center)

      Blank()

      // 右侧功能按钮
        Row() {
          this.buildIconButton('🔍', (): void => { this.showSearchDialog = true; })
        this.buildIconButton('🎨', (): void => { this.cycleTheme(); })
        this.buildIconButton(this.isFileTreeVisible ? '◧' : '◨', (): void => {
          this.isFileTreeVisible = !this.isFileTreeVisible;
        })
        }
        .alignItems(VerticalAlign.Center)
      }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.surface_elevated'))
    .border({ width: { bottom: 1 }, color: $r('app.color.border_light') })
  }

  @Builder
  buildToolButton(icon: string, label: string, action: () => void, enabled: boolean = true): void {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      Row() {
        Text(icon).fontSize(16).margin({ right: 6 })
        Text(label).fontSize(14).fontWeight(FontWeight.Medium)
      }
    }
    .height(36)
    .padding({ left: 14, right: 14 })
    .backgroundColor(Color.Transparent)
    .borderRadius(8)
    .fontColor(enabled ? $r('app.color.text_primary') : $r('app.color.text_tertiary'))
    .enabled(enabled)
    .onClick(action)
    .margin({ right: 8 })
    .stateStyles({
      normal: {
        .backgroundColor(Color.Transparent)
      },
      pressed: {
        .backgroundColor($r('app.color.hover_bg'))
      }
    })
  }

  @Builder
  buildToggleButton(label: string, action: () => void): void {
    Button({ type: ButtonType.Normal }) {
      Text(label).fontSize(14).fontWeight(FontWeight.Medium)
    }
    .height(36)
    .padding({ left: 14, right: 14 })
    .backgroundColor($r('app.color.primary_brand'))
    .fontColor(Color.White)
    .borderRadius(8)
    .onClick(action)
  }

  @Builder
  buildIconButton(icon: string, action: () => void): void {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Text(icon).fontSize(18)
    }
        .width(36)
        .height(36)
    .backgroundColor(Color.Transparent)
    .fontColor($r('app.color.text_secondary'))
    .onClick(action)
    .margin({ left: 8 })
    .stateStyles({
      normal: {
        .backgroundColor(Color.Transparent)
      },
      pressed: {
        .backgroundColor($r('app.color.hover_bg'))
      }
    })
  }

  @Builder
  buildTabBar(): void {
    Scroll() {
      Row() {
        ForEach(this.tabs, (tab: EditorTab) => {
          this.buildTab(tab)
        })
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 0 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .height(44)
    .backgroundColor($r('app.color.background_secondary'))
  }

  @Builder
  buildTab(tab: EditorTab): void {
    Row() {
      Text(this.getFileIcon(tab.fileName))
        .fontSize(14)
        .margin({ right: 8 })

      Text(tab.fileName)
        .fontSize(13)
        .fontColor(tab.isActive ? $r('app.color.primary_brand') : $r('app.color.text_primary'))
        .fontWeight(tab.isActive ? FontWeight.Medium : FontWeight.Normal)
        .maxLines(1)
        .layoutWeight(1)

      if (tab.isModified) {
        Circle()
          .width(6)
          .height(6)
          .fill($r('app.color.warning_color'))
          .margin({ left: 6, right: 6 })
      }

      Button({ type: ButtonType.Circle }) {
        Text('×').fontSize(16).fontColor($r('app.color.text_tertiary'))
      }
      .width(18)
      .height(18)
      .backgroundColor(Color.Transparent)
      .onClick((): void => { this.closeTab(tab.id); })
    }
    .height(36)
    .padding({ left: 12, right: 8 })
    .backgroundColor(tab.isActive ? $r('app.color.background_primary') : Color.Transparent)
    .borderRadius({ topLeft: 8, topRight: 8 })
          .margin({ right: 4 })
    .onClick((): void => { this.switchToTab(tab.id); })
  }

  @Builder
  buildSidebar(): void {
    Column() {
      // 文件浏览器头部
      Row() {
        Text('文件浏览器')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)

        Button({ type: ButtonType.Circle }) {
          Text('⟳').fontSize(16)
        }
        .width(28)
        .height(28)
        .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_secondary'))
        .onClick((): void => { this.refreshFileTree(); })
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.surface_elevated'))

      Divider().color($r('app.color.border_light'))

      // 文件树
      if (this.fileTree.length === 0) {
        this.buildEmptySidebar()
      } else {
        Scroll() {
          Column() {
                ForEach(this.fileTree, (item: FileItem) => {
                  FileTreeItem({
                    fileItem: item,
                    level: 0,
                    isExpanded: this.expandedFolders.has(item.path),
                    isSelected: this.activeTab?.filePath === item.path,
                onFileClick: (file: FileItem): void => { this.onFileClick(file); },
                onFolderToggle: (file: FileItem): void => { this.toggleFolder(file); }
                  })
                }, (item: FileItem) => item.path)
              }
          .padding(8)
        }
        .layoutWeight(1)
      }
    }
    .width(280)
    .height('100%')
    .backgroundColor($r('app.color.surface_elevated'))
    .border({ width: { right: 1 }, color: $r('app.color.border_light') })
  }

  @Builder
  buildEmptySidebar(): void {
    Column() {
      Text('📂').fontSize(48).margin({ bottom: 16 })
      Text('未打开文件夹').fontSize(16).fontColor($r('app.color.text_secondary')).margin({ bottom: 8 })
      Text('点击上方按钮打开').fontSize(13).fontColor($r('app.color.text_tertiary'))
    }
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  buildEditor(): void {
      Column() {
      if (!this.activeTab) {
        this.buildWelcome()
      } else if (this.isMarkdownFile && this.isPreviewMode) {
        this.buildMarkdownPreview()
      } else {
        this.buildTextEditor()
      }
    }
      .layoutWeight(1)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.editor_background'))
  }

  @Builder
  buildWelcome(): void {
    Column() {
      Text('</>').fontSize(56).fontColor($r('app.color.primary_brand')).margin({ bottom: 24 })
      Text('选择一个文件开始编辑').fontSize(18).fontColor($r('app.color.text_secondary')).margin({ bottom: 32 })
      
      Button('打开文件')
            .fontSize(16)
        .backgroundColor($r('app.color.primary_brand'))
        .fontColor(Color.White)
          .borderRadius(8)
        .padding({ left: 24, right: 24, top: 12, bottom: 12 })
        .onClick((): void => { this.openFileDialog(); })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  @Builder
  buildTextEditor(): void {
      Column() {
      HighlightedText({
        code: this.editorContent,
        language: this.activeTab?.language || 'javascript',
        fontSize: 15,
        editable: true,
        onChange: (value: string): void => {
          this.editorContent = value;
          if (this.activeTab) {
            this.activeTab.content = value;
            this.activeTab.isModified = true;
          }
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildMarkdownPreview(): void {
    Scroll() {
      MarkdownPreview({
        markdown: this.editorContent,
        fontSize: 15
      })
      .width('100%')
      .padding(24)
    }
      .width('100%')
    .height('100%')
  }

  // === 文件操作方法 ===
  async openFolderDialog(): Promise<void> {
    try {
      this.isLoading = true;
      console.log('开始打开文件夹选择器...');
      const folderPath = await this.fileService.openFolderPicker();
      console.log('选择的文件夹:', folderPath);
      
      if (folderPath) {
        this.currentFolder = folderPath;
        await this.loadFileTree();
      }
    } catch (error) {
      console.error('打开文件夹失败:', error);
      console.error('错误详情:', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  async loadFileTree() {
    try {
      if (!this.currentFolder) return;
      this.isLoading = true;
      this.fileTree = await this.fileService.readDirectoryTree(this.currentFolder, 5);
    } catch (error) {
      console.error('加载文件树失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  async refreshFileTree() {
    await this.loadFileTree();
  }

  async openFileDialog(): Promise<void> {
    console.log('=== 开始打开文件对话框 ===');
    try {
      console.log('[CodeEditor] 1. 调用 fileService.openFilePicker()');
      const filePaths = await this.fileService.openFilePicker();
      
      console.log('[CodeEditor] 2. 返回结果类型:', typeof filePaths);
      console.log('[CodeEditor] 3. 返回结果:', JSON.stringify(filePaths));
      console.log('[CodeEditor] 4. 是否为数组:', Array.isArray(filePaths));
      console.log('[CodeEditor] 5. 数组长度:', filePaths?.length);
      
      if (filePaths && filePaths.length > 0) {
        console.log('[CodeEditor] 6. 开始打开文件，数量:', filePaths.length);
        for (let i = 0; i < filePaths.length; i++) {
          const filePath = filePaths[i];
          console.log(`[CodeEditor] 7.${i} 打开文件:`, filePath);
          await this.openFile(filePath);
        }
        console.log('[CodeEditor] 8. 所有文件打开完成');
          } else {
        console.log('[CodeEditor] ⚠️ 未选择任何文件或返回为空');
      }
    } catch (error) {
      console.error('[CodeEditor] ❌ 打开文件失败:', error);
      console.error('[CodeEditor] 错误类型:', error?.constructor?.name);
      console.error('[CodeEditor] 错误消息:', error?.message);
      console.error('[CodeEditor] 错误详情:', JSON.stringify(error));
    }
    console.log('=== 文件对话框处理结束 ===');
  }

  async openFile(filePath: string): Promise<void> {
    try {
      console.log('正在打开文件:', filePath);
      
      const tab = this.fileService.openFileInTab(filePath);
      console.log('创建标签页:', tab.fileName);
      
      const content = await this.fileService.readFileContent(filePath);
      console.log('读取文件内容，长度:', content.length);
      
      tab.content = content;
      this.fileService.updateTabContent(tab.id, content);
      
      // 更新状态
      this.tabs = this.fileService.getTabs();
      this.activeTab = this.fileService.getActiveTab();
      this.editorContent = content;
      this.isMarkdownFile = this.markdownService.isMarkdownFile(tab.fileName);
      this.isPreviewMode = this.isMarkdownFile;
      
      console.log('文件打开成功:', {
        tabsCount: this.tabs.length,
        activeTab: this.activeTab?.fileName,
        contentLength: this.editorContent.length,
        isMarkdown: this.isMarkdownFile
      });
      
      // 强制刷新状态
      this.tabs = [...this.tabs];
    } catch (error) {
      console.error('打开文件失败:', error);
      console.error('错误详情:', JSON.stringify(error));
    }
  }

  async saveCurrentFile() {
    if (!this.activeTab) return;
    try {
      const success = await this.fileService.writeFileContent(
        this.activeTab.filePath,
        this.editorContent
      );
      if (success) {
        this.fileService.markTabSaved(this.activeTab.id);
        this.activeTab.isModified = false;
      }
    } catch (error) {
      console.error('保存文件失败:', error);
    }
  }

  switchToTab(tabId: string) {
    this.fileService.setActiveTab(tabId);
    this.tabs = this.fileService.getTabs();
    this.activeTab = this.fileService.getActiveTab();
    if (this.activeTab) {
      this.loadTabContent(this.activeTab);
      this.isMarkdownFile = this.markdownService.isMarkdownFile(this.activeTab.fileName);
      if (!this.isMarkdownFile) {
        this.isPreviewMode = false;
      }
    }
  }

  async loadTabContent(tab: EditorTab) {
    try {
      this.editorContent = await this.fileService.readFileContent(tab.filePath);
    } catch (error) {
      console.error('加载标签页内容失败:', error);
    }
  }

  closeTab(tabId: string) {
    this.fileService.closeTab(tabId);
    this.tabs = this.fileService.getTabs();
    this.activeTab = this.fileService.getActiveTab();
    if (this.activeTab) {
      this.loadTabContent(this.activeTab);
    } else {
      this.editorContent = '';
      this.isMarkdownFile = false;
      this.isPreviewMode = false;
    }
  }

  togglePreviewMode() {
    if (!this.isMarkdownFile) return;
    this.isPreviewMode = !this.isPreviewMode;
  }

  onFileClick(file: FileItem) {
    if (!file.isDirectory) {
      this.openFile(file.path);
    }
  }

  toggleFolder(folder: FileItem) {
    if (this.expandedFolders.has(folder.path)) {
      this.expandedFolders.delete(folder.path);
    } else {
      this.expandedFolders.add(folder.path);
    }
    this.expandedFolders = new Set(this.expandedFolders);
  }

  private cycleTheme() {
    const themes = this.themeService.getAvailableThemes();
    const currentIndex = themes.findIndex(t => t.id === this.currentTheme.id);
    const nextIndex = (currentIndex + 1) % themes.length;
    const nextTheme = themes[nextIndex];
    if (this.themeService.switchTheme(nextTheme.id)) {
      this.themeService.saveThemePreference(nextTheme.id);
    }
  }

  private handleSearchResult(result: SearchResult) {
    this.openFile(result.filePath);
  }

  private getFileIcon(fileName: string): string {
    const ext = fileName.split('.').pop()?.toLowerCase() || '';
    const icons: Record<string, string> = {
      'js': '🟨', 'ts': '🔷', 'ets': '🔷', 'py': '🐍',
      'java': '☕', 'html': '🌐', 'css': '🎨', 'json': '📋',
      'md': '📝', 'txt': '📄'
    };
    return icons[ext] || '📄';
  }

  private setupAutoSave() {
    this.autoSaveInterval = setInterval(() => {
      this.tabs.forEach(tab => {
        if (tab.isModified) {
          this.fileService.writeFileContent(tab.filePath, tab.content);
          this.fileService.markTabSaved(tab.id);
        }
      });
    }, 5 * 60 * 1000);
  }

  private cleanupAutoSave() {
    if (this.autoSaveInterval) {
      clearInterval(this.autoSaveInterval);
    }
  }
}