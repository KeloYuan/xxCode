/**
 * xxCode 主编辑器页面
 * 完整功能的代码编辑器，支持多标签、语法高亮、主题切换等
 */
import { router } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { RealFileService } from '../services/RealFileService';
import { ThemeService, Theme } from '../services/ThemeService';
import { MarkdownService } from '../services/MarkdownService';
import { FileItem, EditorTab } from '../models/FileModel';
import { HighlightedText } from '../components/HighlightedText';
import { FileTreeItem } from '../components/FileTreeItem';
import { WelcomeGuide } from '../components/WelcomeGuide';
import { SearchDialog } from '../components/SearchDialog';
import { BreakpointService, Breakpoint } from '../services/BreakpointService';

@Entry
@Component
struct CodeEditor {
  @State tabs: EditorTab[] = [];
  @State activeTab: EditorTab | null = null;
  @State isFileTreeVisible: boolean = true;
  @State fileTree: FileItem[] = [];
  @State expandedFolders: Set<string> = new Set();
  @State isPreviewMode: boolean = false;
  @State showWelcomeGuide: boolean = false;
  @State showSearchDialog: boolean = false;
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  @State currentBreakpoint: Breakpoint = 'sm';
  
  private context: common.UIAbilityContext | null = null;
  private fileService: RealFileService = new RealFileService();
  private themeService: ThemeService = ThemeService.getInstance();
  private markdownService: MarkdownService = MarkdownService.getInstance();
  private breakpointService: BreakpointService = BreakpointService.getInstance();
  
  private searchDialogController: CustomDialogController = new CustomDialogController({
    builder: SearchDialog({
      content: this.activeTab?.content || '',
      onClose: () => {
        this.showSearchDialog = false;
      }
    }),
    autoCancel: true
  });

  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.fileService.setContext(this.context);
    
    // 注册断点系统
    this.breakpointService.register();
    this.currentBreakpoint = this.breakpointService.getCurrentBreakpoint();
    this.breakpointService.onChange((breakpoint: Breakpoint) => {
      this.currentBreakpoint = breakpoint;
      if (this.breakpointService.isPhone()) {
        this.isFileTreeVisible = false;
      }
    });
    
    // 手机默认隐藏文件树
    if (this.breakpointService.isPhone()) {
      this.isFileTreeVisible = false;
    }
    
    // 监听主题变化
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
    
    // 检查首次启动
    this.checkFirstLaunch();
    
    // 创建欢迎标签
    this.createWelcomeTab();
  }

  aboutToDisappear() {
    this.breakpointService.unregister();
  }

  private checkFirstLaunch() {
    const hasLaunched = AppStorage.get<boolean>('hasLaunched');
    if (!hasLaunched) {
      setTimeout(() => {
        this.showWelcomeGuide = true;
      }, 500);
      AppStorage.setOrCreate('hasLaunched', true);
    }
  }

  private createWelcomeTab() {
    const welcomeTab = this.fileService.createNewTab(
      'Welcome.md',
      '',
      `# 欢迎使用 xxCode 编辑器

## 🚀 快速开始

### 打开文件
点击右上角的"打开"按钮，选择您想要编辑的代码文件。

### 支持的语言
- JavaScript / TypeScript / ArkTS
- Python / Java / C / C++
- HTML / CSS / JSON
- Markdown

### 主题切换
点击右上角的"🎨"图标切换主题：
- 深色主题
- 浅色主题
- Monokai
- Dracula

### 快捷功能
- **Ctrl+S**: 保存文件
- **Ctrl+F**: 搜索
- **Ctrl+H**: 替换

## 📝 开始编码吧！

修改此文本或打开新文件即可开始。`
    );
    this.fileService.addTab(welcomeTab);
    this.updateTabs();
  }

  private updateTabs() {
    this.tabs = this.fileService.getTabs();
    this.activeTab = this.fileService.getActiveTab();
    this.isPreviewMode = this.activeTab ? 
      this.markdownService.isMarkdownFile(this.activeTab.fileName) : false;
  }

  private async openFile() {
    try {
      const content = await this.fileService.openFile();
      // 这里应该获取文件名和路径，简化处理
      const fileName = '新文件.txt';
      const tab = this.fileService.createNewTab(fileName, '', content);
      this.fileService.addTab(tab);
      this.updateTabs();
    } catch (error) {
      console.error('打开文件失败:', error);
    }
  }

  private async saveFile() {
    if (!this.activeTab || !this.activeTab.filePath) {
      return;
    }
    
    try {
      await this.fileService.saveFile(this.activeTab.filePath, this.activeTab.content);
      this.fileService.markTabAsModified(this.activeTab.id, false);
      this.updateTabs();
    } catch (error) {
      console.error('保存文件失败:', error);
    }
  }

  private switchTab(tabId: string) {
    this.fileService.setActiveTab(tabId);
    this.updateTabs();
  }

  private closeTab(tabId: string) {
    this.fileService.removeTab(tabId);
    this.updateTabs();
  }

  private onContentChange(content: string) {
    if (this.activeTab) {
      this.fileService.updateTabContent(this.activeTab.id, content);
      this.updateTabs();
    }
  }

  private cycleTheme() {
    const nextTheme = this.themeService.getNextTheme();
    this.themeService.switchTheme(nextTheme.id);
    this.themeService.saveThemePreference(nextTheme.id);
  }

  build() {
    Column() {
      // 顶部工具栏
      this.buildToolbar()

      Row() {
        // 文件树（侧边栏）
        if (this.isFileTreeVisible) {
          this.buildSidebar()
        }

        // 主编辑区
        Column() {
          // 标签栏
          if (this.tabs.length > 0) {
            this.buildTabBar()
          }

          // 编辑器内容
          if (this.activeTab) {
            HighlightedText({
              code: this.activeTab.content,
              language: this.activeTab.language,
              isEditable: true,
              fontSize: 14
            })
          } else {
            this.buildEmptyState()
          }
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(this.currentTheme.editor.background)
      }
      .layoutWeight(1)
      .width('100%')

      // 欢迎引导
      if (this.showWelcomeGuide) {
        WelcomeGuide({
          visible: this.showWelcomeGuide,
          onClose: () => {
            this.showWelcomeGuide = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.colors.background)
  }

  @Builder
  buildToolbar(): void {
    Row() {
      // 左侧：返回和文件树切换
      Row({ space: 8 }) {
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(18)
            .fontColor(this.currentTheme.colors.text)
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Button({ type: ButtonType.Circle }) {
          Text('☰')
            .fontSize(16)
            .fontColor(this.currentTheme.colors.text)
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.isFileTreeVisible = !this.isFileTreeVisible;
        })
      }

      // 中间：标题
      Text('xxCode')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentTheme.colors.text)
        .layoutWeight(1)
        .margin({ left: 12 })

      // 右侧：操作按钮
      Row({ space: 8 }) {
        Button({ type: ButtonType.Circle }) {
          Text('🔍')
            .fontSize(16)
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.showSearchDialog = true;
          this.searchDialogController.open();
        })

        Button({ type: ButtonType.Circle }) {
          Text('🎨')
            .fontSize(16)
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.cycleTheme();
        })

        Button({ type: ButtonType.Normal }) {
          Text('打开')
            .fontSize(13)
            .fontColor(this.currentTheme.colors.text)
        }
        .height(32)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.currentTheme.colors.surface)
        .borderRadius(6)
        .onClick(() => {
          this.openFile();
        })

        Button({ type: ButtonType.Normal }) {
          Text('保存')
            .fontSize(13)
            .fontColor(Color.White)
        }
        .height(32)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.currentTheme.colors.primary)
        .borderRadius(6)
        .onClick(() => {
          this.saveFile();
        })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.currentTheme.colors.surface)
    .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })
  }

  @Builder
  buildSidebar(): void {
    Column() {
      Row() {
        Text('文件')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.colors.text)
          .layoutWeight(1)

        if (this.breakpointService.isPhone()) {
          Button({ type: ButtonType.Circle }) {
            Text('×')
              .fontSize(18)
              .fontColor(this.currentTheme.colors.textSecondary)
          }
          .width(28)
          .height(28)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.isFileTreeVisible = false;
          })
        }
      }
      .width('100%')
      .padding(12)

      Divider().color(this.currentTheme.colors.border)

      Scroll() {
        Column() {
          if (this.fileTree.length > 0) {
            ForEach(this.fileTree, (item: FileItem) => {
              FileTreeItem({
                fileItem: item,
                level: 0,
                isExpanded: this.expandedFolders.has(item.path),
                isSelected: false,
                onFileClick: (file: FileItem) => {},
                onFolderToggle: (folder: FileItem) => {
                  if (this.expandedFolders.has(folder.path)) {
                    this.expandedFolders.delete(folder.path);
                  } else {
                    this.expandedFolders.add(folder.path);
                  }
                  this.expandedFolders = new Set(this.expandedFolders);
                }
              })
            }, (item: FileItem) => item.path)
          } else {
            this.buildEmptySidebar()
          }
        }
        .padding(8)
      }
      .layoutWeight(1)
    }
    .width(this.breakpointService.isPhone() ? '85%' : 
           this.breakpointService.isTablet() ? 320 : 360)
    .height('100%')
    .backgroundColor(this.currentTheme.colors.surface)
    .border({ width: { right: 1 }, color: this.currentTheme.colors.border })
  }

  @Builder
  buildEmptySidebar(): void {
    Column() {
      Text('📂')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('暂无文件')
        .fontSize(14)
        .fontColor(this.currentTheme.colors.textSecondary)
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildTabBar(): void {
    Scroll() {
      Row({ space: 4 }) {
        ForEach(this.tabs, (tab: EditorTab) => {
          Row({ space: 6 }) {
            Text(tab.fileName)
              .fontSize(13)
              .fontColor(tab.isActive ? this.currentTheme.colors.primary : this.currentTheme.colors.text)
              .fontWeight(tab.isActive ? FontWeight.Medium : FontWeight.Normal)

            if (tab.isModified) {
              Circle()
                .width(6)
                .height(6)
                .fill(this.currentTheme.colors.warning)
            }

            Button({ type: ButtonType.Circle }) {
              Text('×')
                .fontSize(14)
                .fontColor(this.currentTheme.colors.textSecondary)
            }
            .width(16)
            .height(16)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.closeTab(tab.id);
            })
          }
          .height(36)
          .padding({ left: 12, right: 8 })
          .backgroundColor(tab.isActive ? this.currentTheme.colors.surface : Color.Transparent)
          .borderRadius(6)
          .onClick(() => {
            this.switchTab(tab.id);
          })
        }, (tab: EditorTab) => tab.id)
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(44)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.currentTheme.editor.background)
    .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })
  }

  @Builder
  buildEmptyState(): void {
    Column() {
      Text('📝')
        .fontSize(64)
        .margin({ bottom: 20 })
      
      Text('没有打开的文件')
        .fontSize(18)
        .fontColor(this.currentTheme.colors.text)
        .margin({ bottom: 8 })
      
      Text('点击"打开"按钮选择文件')
        .fontSize(14)
        .fontColor(this.currentTheme.colors.textSecondary)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.currentTheme.editor.background)
  }
}
