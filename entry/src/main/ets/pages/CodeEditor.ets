import { RealFileService } from '../services/RealFileService';
import { FileItem, EditorTab } from '../models/FileModel';
import { HighlightedText } from '../components/HighlightedText';
import { MarkdownPreview } from '../components/MarkdownPreview';
import { MarkdownService } from '../services/MarkdownService';
import { ThemeService, Theme } from '../services/ThemeService';
import { SearchDialog } from '../components/SearchDialog';
import { SearchResult } from '../services/SearchService';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

@Entry
@Component
struct CodeEditor {
  private fileService: RealFileService = new RealFileService();
  private context: common.UIAbilityContext | null = null;

  @State currentFile: string = '';
  @State isFileTreeVisible: boolean = true;
  @State files: FileItem[] = [];
  @State tabs: EditorTab[] = [];
  @State activeTab: EditorTab | null = null;
  @State editorContent: string = '';
  @State isLoading: boolean = false;
  @State expandedFolders: Set<string> = new Set();
  @State isPreviewMode: boolean = false;
  @State isMarkdownFile: boolean = false;
  @State showSearchDialog: boolean = false;

  private highlightedTextRef: HighlightedText | null = null;
  private markdownService: MarkdownService = new MarkdownService();
  private themeService: ThemeService = new ThemeService();

  @State currentTheme: Theme = this.themeService.getCurrentTheme();

  aboutToAppear() {
    // 获取UIAbility的context
    this.context = getContext(this) as common.UIAbilityContext;
    this.fileService.setContext(this.context);

    this.setupThemeListener();
    this.loadSavedTheme();
    this.initializeWelcomePage();
  }

  aboutToDisappear() {
    this.cleanupThemeListener();
  }

  private setupThemeListener() {
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  private cleanupThemeListener() {
    // 移除主题变化监听器（如果需要的话）
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

  private getHighlightedTextRef() {
    // 在ArkTS中，可以直接通过ID获取组件引用
    // 这里暂时注释掉，后续可以根据需要实现
    // this.highlightedTextRef = this.findComponentById('highlightedText') as HighlightedText;
  }

  build() {
    Stack() {
      Column() {
        // 顶部工具栏
        this.buildToolbar()

        // 标签页区域
        if (this.tabs.length > 0) {
          this.buildTabBar()
        }

        // 主内容区域
        Row() {
          // 左侧文件树
          if (this.isFileTreeVisible) {
            this.buildFileTree()
          }

          // 编辑器区域
          this.buildEditorArea()
        }
        .layoutWeight(1)
      }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.White)

      // 搜索对话框
      if (this.showSearchDialog) {
        SearchDialog({
          visible: this.showSearchDialog,
          onClose: () => {
            this.showSearchDialog = false;
          },
          onResultSelect: (result: SearchResult) => {
            this.handleSearchResult(result);
          }
        })
      }
    }
    .height('100%')
    .width('100%')
  }

  private initializeWelcomePage(): void {
    // 初始化欢迎页面，不加载任何文件
    this.files = [];
    this.tabs = [];
    this.isLoading = false;
  }

  @Builder
  buildToolbar() {
    Row() {
      // 打开文件按钮 - 使用鸿蒙风格
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('📁').fontSize(16).margin({ right: 4 })
          Text('打开文件').fontSize(14)
        }
      }
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .borderRadius(8)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .onClick(() => {
        this.openFileDialog();
      })

      Blank().width(8)

      // 保存文件按钮
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('💾').fontSize(16).margin({ right: 4 })
          Text('保存').fontSize(14)
        }
      }
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .borderRadius(8)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .enabled(!!this.activeTab)
      .onClick(() => {
        this.saveCurrentFile();
      })

      Blank().width(8)

      // 新建文件按钮
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('📄').fontSize(16).margin({ right: 4 })
          Text('新建').fontSize(14)
        }
      }
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .borderRadius(8)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .onClick(() => {
        this.createNewFileDialog();
      })

      // 预览模式切换（仅对Markdown文件显示）
      if (this.isMarkdownFile) {
        Blank().width(8)
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text(this.isPreviewMode ? '编辑' : '预览').fontSize(14)
        }
        .backgroundColor(this.isPreviewMode ? $r('sys.color.ohos_id_color_emphasize') : $r('sys.color.ohos_id_color_button_normal'))
        .fontColor(this.isPreviewMode ? Color.White : $r('sys.color.ohos_id_color_text_primary'))
        .borderRadius(8)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.togglePreviewMode();
        })
      }

      // 占位符，推送右侧内容
      Blank().layoutWeight(1)

      // 右侧功能按钮区域
      Row() {
        // 搜索按钮
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('🔍').fontSize(16)
        }
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .width(36)
        .height(36)
        .onClick(() => {
          this.showSearchDialog = true;
        })

        Blank().width(8)

        // 主题切换按钮
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('🎨').fontSize(16)
        }
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .width(36)
        .height(36)
        .onClick(() => {
          this.showThemeMenu();
        })

        Blank().width(8)

        // 文件树切换按钮
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text(this.isFileTreeVisible ? '📋' : '📂').fontSize(16)
        }
        .backgroundColor(this.isFileTreeVisible ? $r('sys.color.ohos_id_color_emphasize') : $r('sys.color.ohos_id_color_button_normal'))
        .fontColor(this.isFileTreeVisible ? Color.White : $r('sys.color.ohos_id_color_text_primary'))
        .width(36)
        .height(36)
        .onClick(() => {
          this.isFileTreeVisible = !this.isFileTreeVisible;
        })
      }
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .border({ width: { bottom: 0.5 }, color: $r('sys.color.ohos_id_color_list_separator') })
  }

  // 打开文件对话框
  async openFileDialog() {
    try {
      const filePaths = await this.fileService.openFilePicker();
      if (filePaths.length > 0) {
        for (const filePath of filePaths) {
          await this.openRealFile(filePath);
        }
      }
    } catch (error) {
      console.error('打开文件失败:', error);
    }
  }

  // 新建文件对话框
  async createNewFileDialog() {
    try {
      const filePath = await this.fileService.saveFilePicker('untitled.txt');
      if (filePath) {
        const success = await this.fileService.createFile(filePath, '');
        if (success) {
          await this.openRealFile(filePath);
        }
      }
    } catch (error) {
      console.error('创建文件失败:', error);
    }
  }

  // 打开真实文件
  async openRealFile(filePath: string) {
    try {
      const tab = this.fileService.openFileInTab(filePath);
      const content = await this.fileService.readFileContent(filePath);

      tab.content = content;
      this.fileService.updateTabContent(tab.id, content);

      this.tabs = this.fileService.getTabs();
      this.activeTab = this.fileService.getActiveTab();
      this.editorContent = content;

      // 检查是否为Markdown文件
      this.isMarkdownFile = this.checkIsMarkdownFile(tab.fileName);
      this.isPreviewMode = this.isMarkdownFile;

    } catch (error) {
      console.error('打开文件失败:', error);
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
        console.log('文件保存成功');
      }
    } catch (error) {
      console.error('保存文件失败:', error);
    }
  }

  getStatusText(): string {
    if (!this.activeTab) return '未选择文件';
    return `第 1 行，${this.editorContent.length} 字符`;
  }

  @Builder
  buildTabBar() {
    Scroll() {
      Row() {
        ForEach(this.tabs, (tab: EditorTab) => {
          Row() {
            // 文件名和修改状态
            Row() {
              Text(tab.fileName)
                .fontSize(12)
                .fontColor(tab.isActive ? Color.White : Color.Black)
                .layoutWeight(1)

              // 修改状态指示器
              if (tab.isModified) {
                Text('•')
                  .fontSize(14)
                  .fontColor(tab.isActive ? Color.White : Color.Orange)
                  .margin({ left: 4 })
              }
            }
            .padding(8)
            .backgroundColor(tab.isActive ? Color.Blue : Color.White)
            .borderRadius(4)
            .onClick(() => {
              this.switchToTab(tab.id);
            })

            // 关闭按钮
            Button('×')
              .fontSize(12)
              .width(24)
              .height(24)
              .backgroundColor(Color.Transparent)
              .fontColor(tab.isActive ? Color.White : Color.Gray)
              .margin({ left: 2 })
              .onClick(() => {
                this.closeTab(tab.id);
              })
          }
          .margin({ right: 4 })
          .borderRadius(4)
          .backgroundColor(tab.isActive ? Color.Blue : Color.White)
        })
      }
      // scrollBar property not available in this ArkTS version
    }
    .height(40)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: Color.Gray })
  }

  @Builder
  buildFileTree() {
    Column() {
      // 文件树头部
      Row() {
        Text('已打开文件')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .layoutWeight(1)

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('📁').fontSize(14)
        }
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .width(32)
        .height(32)
        .onClick(() => {
          this.openFileDialog();
        })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor($r('sys.color.ohos_id_color_background'))

      Divider()
        .color($r('sys.color.ohos_id_color_list_separator'))
        .strokeWidth(0.5)

      // 打开的文件标签页列表
      if (this.tabs.length === 0) {
        Column() {
          Text('📂')
            .fontSize(48)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .margin({ bottom: 16 })

          Text('未打开任何文件')
            .fontSize(16)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .margin({ bottom: 8 })

          Text('点击"打开文件"开始编辑')
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))

          Blank().height(24)

          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Row() {
              Text('📁').fontSize(16).margin({ right: 6 })
              Text('打开文件').fontSize(14)
            }
          }
          .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .onClick(() => {
            this.openFileDialog();
          })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
        .padding(24)
      } else {
        // 显示已打开的文件列表
        Scroll() {
          Column() {
            ForEach(this.tabs, (tab: EditorTab) => {
              this.buildFileTabItem(tab)
            })
          }
          .padding({ top: 8, bottom: 8 })
        }
        .layoutWeight(1)
      }
    }
    .width(280)
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .border({ width: { right: 0.5 }, color: $r('sys.color.ohos_id_color_list_separator') })
  }

  @Builder
  buildFileTabItem(tab: EditorTab) {
    Row() {
      // 文件类型图标
      Text(this.getFileTypeIcon(tab.fileName))
        .fontSize(16)
        .margin({ right: 8 })

      // 文件名
      Column() {
        Text(tab.fileName)
          .fontSize(14)
          .fontColor(tab.isActive ? $r('sys.color.ohos_id_color_emphasize') : $r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(tab.isActive ? FontWeight.Medium : FontWeight.Normal)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.getShortPath(tab.filePath))
          .fontSize(11)
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 修改状态指示器
      if (tab.isModified) {
        Text('●')
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .margin({ right: 8 })
      }

      // 关闭按钮
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('×')
          .fontSize(16)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      }
      .backgroundColor(Color.Transparent)
      .width(24)
      .height(24)
      .onClick(() => {
        this.closeTab(tab.id);
      })
    }
    .padding({ left: 16, right: 12, top: 12, bottom: 12 })
    .backgroundColor(tab.isActive ? $r('sys.color.ohos_id_color_background_transparent') : Color.Transparent)
    .borderRadius(8)
    .margin({ left: 8, right: 8, bottom: 4 })
    .onClick(() => {
      this.switchToTab(tab.id);
    })
  }

  @Builder
  buildFileItem(item: FileItem, level: number) {
    Column() {
      // 文件项
      Row() {
        // 缩进
        if (level > 0) {
          Text('  '.repeat(level * 2))
            .fontSize(12)
            .fontColor(Color.Transparent)
        }

        // 展开/折叠图标（仅文件夹）
        if (item.isDirectory) {
          Button(this.expandedFolders.has(item.path) ? '▼' : '▶')
            .fontSize(10)
            .width(16)
            .height(16)
            .backgroundColor(Color.Transparent)
            .fontColor(Color.Gray)
            .margin({ right: 4 })
            .onClick(() => {
              this.toggleFolder(item.path);
            })
        } else {
          // 文件没有展开图标，占位
          Text('  ')
            .fontSize(10)
            .width(16)
            .height(16)
            .margin({ right: 4 })
        }

        // 文件图标
        if (item.isDirectory) {
          Text('📁')
            .width(20)
            .height(20)
            .margin({ right: 8 })
        } else {
          Text('📄')
            .width(20)
            .height(20)
            .margin({ right: 8 })
        }

        Text(item.name)
          .layoutWeight(1)
          .fontSize(13)
          .onClick(() => {
            if (item.isDirectory) {
              this.toggleFolder(item.path);
            } else {
              this.openFile(item.path);
            }
          })

        // 文件大小（仅文件）
        if (!item.isDirectory) {
          Text(this.formatFileSize(item.size))
            .fontSize(10)
            .fontColor(Color.Gray)
            .margin({ left: 8 })
        }
      }
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .width('100%')
      .height(40)
      .onClick(() => {
        if (item.isDirectory) {
          this.toggleFolder(item.path);
        } else {
          this.openFile(item.path);
        }
      })

      // 子项（如果文件夹已展开）
      if (item.isDirectory && this.expandedFolders.has(item.path) && item.children) {
        this.buildFileList(item.children, level + 1)
      }
    }
  }

  toggleFolder(folderPath: string) {
    if (this.expandedFolders.has(folderPath)) {
      this.expandedFolders.delete(folderPath);
    } else {
      this.expandedFolders.add(folderPath);
    }
  }

  formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  }

  @Builder
  buildEditorArea() {
    Column() {
      // 编辑器工具栏
      Row() {
        Text(this.activeTab?.fileName || '未选择文件')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .layoutWeight(1)

        // 显示当前模式
        if (this.isMarkdownFile) {
          Text(this.isPreviewMode ? '预览模式' : '编辑模式')
            .fontSize(12)
            .fontColor(Color.Gray)
            .margin({ right: 8 })
        }

        // 行号、字符数等信息
        Text(this.getStatusText())
          .fontSize(12)
          .fontColor(Color.Gray)
      }
      .padding(12)
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: Color.Gray })

      // 编辑器内容区域
      if (this.isMarkdownFile && this.isPreviewMode) {
        // Markdown预览模式
        this.buildMarkdownPreview()
      } else {
        // 普通编辑模式
        this.buildTextEditor()
      }
    }
    .layoutWeight(1)
    .height('100%')
  }

  @Builder
  buildTextEditor() {
    HighlightedText({
      code: this.editorContent,
      language: this.activeTab?.language || 'javascript',
      fontSize: 14,
      editable: true,
      onChange: (value: string) => {
        this.handleContentChange(value);
      }
    })
    .height('100%')
    .width('100%')
    .borderRadius(8)
    .margin(16)
    .id('highlightedText')
  }

  @Builder
  buildMarkdownPreview() {
    MarkdownPreview({
      markdown: this.editorContent,
      fontSize: 14
    })
    .height('100%')
    .width('100%')
    .margin(16)
  }

  // 获取文件类型图标
  private getFileTypeIcon(fileName: string): string {
    const extension = fileName.split('.').pop()?.toLowerCase() || '';
    const iconMap: Record<string, string> = {
      'js': '🟨',
      'ts': '🔷',
      'ets': '🔷',
      'py': '🐍',
      'java': '☕',
      'html': '🌐',
      'css': '🎨',
      'json': '📋',
      'md': '📝',
      'txt': '📄',
      'xml': '📜',
      'yaml': '⚙️',
      'yml': '⚙️'
    };
    return iconMap[extension] || '📄';
  }

  // 获取短路径
  private getShortPath(fullPath: string): string {
    const maxLength = 35;
    if (fullPath.length <= maxLength) {
      return fullPath;
    }
    return '...' + fullPath.substring(fullPath.length - maxLength + 3);
  }

  switchToTab(tabId: string) {
    this.fileService.setActiveTab(tabId);
    this.tabs = this.fileService.getFileModel().getTabs();
    this.activeTab = this.fileService.getFileModel().getActiveTab();

    if (this.activeTab) {
      // 加载标签页内容
      this.loadTabContent(this.activeTab);

      // 检查是否为Markdown文件
      this.isMarkdownFile = this.checkIsMarkdownFile(this.activeTab.fileName);

      // 如果不是Markdown文件，退出预览模式
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
    this.tabs = this.fileService.getFileModel().getTabs();
    this.activeTab = this.fileService.getFileModel().getActiveTab();

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

    // 如果切换到预览模式，确保内容是最新的
    if (this.isPreviewMode) {
      // 预览模式不需要特殊处理，MarkdownPreview会自动更新
    } else {
      // 切换回编辑模式，确保编辑器内容同步
      // 这里可以添加逻辑来确保编辑器内容与预览内容同步
    }
  }

  // 检查文件是否为Markdown文件
  private checkIsMarkdownFile(fileName: string): boolean {
    return this.markdownService.isMarkdownFile(fileName);
  }

  // 主题相关方法
  private showThemeMenu() {
    const themes = this.themeService.getAvailableThemes();
    // 这里可以显示一个主题选择对话框
    // 暂时通过循环切换主题来演示功能
    this.cycleTheme();
  }

  private cycleTheme() {
    const themes = this.themeService.getAvailableThemes();
    const currentIndex = themes.findIndex(t => t.id === this.currentTheme.id);
    const nextIndex = (currentIndex + 1) % themes.length;
    const nextTheme = themes[nextIndex];

    if (this.themeService.switchTheme(nextTheme.id)) {
      this.saveCurrentTheme(nextTheme.id);
      console.log('切换到主题:', nextTheme.name);
    }
  }

  private async saveCurrentTheme(themeId: string) {
    try {
      await this.themeService.saveThemePreference(themeId);
    } catch (error) {
      console.error('保存主题设置失败:', error);
    }
  }

  // 搜索相关方法
  private handleSearchResult(result: SearchResult) {
    // 打开搜索结果对应的文件
    this.openFile(result.filePath);

    // TODO: 跳转到特定的行和列
    console.log('搜索结果:', result.filePath, '行:', result.lineNumber, '列:', result.columnNumber);
  }

  // 内容变化处理方法
  private handleContentChange(value: string) {
    this.editorContent = value;
    if (this.activeTab) {
      this.activeTab.isModified = true;
    }
  }
}
