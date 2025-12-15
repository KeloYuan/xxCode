/**
 * 平板端代码编辑器主页面
 * 鸿蒙6风格精美UI设计
 */
import { curves } from '@kit.ArkUI'
import {
  FileNode,
  EditorTab,
  ThemeColors,
  createSampleFileTree,
  SampleCodeContents
} from '../models/EditorModels'
import { ThemeManager, LightTheme, DarkTheme } from '../services/ThemeManager'
import { SyntaxHighlightService } from '../services/SyntaxHighlightService'
import { TopToolbar } from '../components/tablet/TopToolbar'
import { FileSidebar } from '../components/tablet/FileSidebar'
import { EditorTabBar } from '../components/tablet/EditorTabBar'
import { CodeEditorView } from '../components/tablet/CodeEditorView'
import { EditorStatusBar } from '../components/tablet/EditorStatusBar'
import { WelcomeView } from '../components/tablet/WelcomeView'

@Entry
@Component
struct TabletCodeEditor {
  // 主题状态
  @State isDarkMode: boolean = true
  @State colors: ThemeColors = DarkTheme.colors

  // 文件系统状态
  @State rootFolder: FileNode | null = null
  @State expandedFolders: Set<string> = new Set()
  @State selectedFileId: string = ''

  // 编辑器状态
  @State tabs: EditorTab[] = []
  @State activeTabId: string = ''
  @State currentContent: string = ''
  @State currentLanguage: string = 'text'
  @State cursorLine: number = 1
  @State cursorColumn: number = 1

  // UI状态
  @State isSidebarVisible: boolean = true
  @State sidebarWidth: number = 280
  @State sidebarOpacity: number = 1
  @State isDividerHovered: boolean = false
  @State showLoadingToast: boolean = false
  @State toastMessage: string = ''

  // 动画状态
  @State pageOpacity: number = 0
  @State pageScale: number = 0.98

  private themeManager: ThemeManager = ThemeManager.getInstance()
  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance()

  aboutToAppear() {
    // 初始化主题
    this.isDarkMode = this.themeManager.isDarkMode()
    this.colors = this.themeManager.getColors()

    // 加载示例文件树
    this.rootFolder = createSampleFileTree()
    this.expandedFolders.add('root')

    // 入场动画 - 通过直接赋值触发 animation 属性动画
    setTimeout(() => {
      this.pageOpacity = 1
      this.pageScale = 1
    }, 50)
  }

  build() {
    Stack() {
      Column() {
        // 顶部工具栏
        TopToolbar({
          projectName: this.rootFolder?.name || '未命名项目',
          isDarkMode: this.isDarkMode,
          colors: this.colors,
          isSidebarVisible: this.isSidebarVisible,
          onMenuClick: () => this.toggleSidebar(),
          onSaveClick: () => this.saveCurrentFile(),
          onThemeToggle: () => this.toggleTheme(),
          onOpenFile: () => this.openFile()
        })

      // 主内容区
      Row() {
        // 侧边栏
        if (this.isSidebarVisible) {
          FileSidebar({
            rootFolder: this.rootFolder,
            selectedFileId: this.selectedFileId,
            expandedFolders: $expandedFolders,
            colors: this.colors,
            isDarkMode: this.isDarkMode,
            onFileSelect: (file: FileNode) => this.openFileInTab(file),
            onFolderToggle: (folder: FileNode) => this.toggleFolder(folder),
            onRefresh: () => this.refreshFileTree()
          })
          .width(this.sidebarWidth)
          .opacity(this.sidebarOpacity)
          .transition(TransitionEffect.OPACITY.animation({
            duration: 250,
            curve: curves.springMotion(0.5, 0.9)
          }))
        }

        // 可拖拽分割线
        if (this.isSidebarVisible) {
          this.buildResizeDivider()
        }

        // 编辑器面板
        Column() {
          if (this.tabs.length > 0) {
            // 标签栏
            EditorTabBar({
              tabs: this.tabs,
              activeTabId: this.activeTabId,
              colors: this.colors,
              onTabSelect: (tabId: string) => this.switchTab(tabId),
              onTabClose: (tabId: string) => this.closeTab(tabId),
              onNewTab: () => this.createNewFile()
            })

            // 代码编辑区
            CodeEditorView({
              content: this.currentContent,
              language: this.currentLanguage,
              fontSize: 14,
              colors: this.colors,
              cursorLine: this.cursorLine,
              onContentChange: (content: string) => this.updateContent(content),
              onCursorChange: (line: number, column: number) => {
                this.cursorLine = line
                this.cursorColumn = column
              }
            })
            .layoutWeight(1)

            // 状态栏
            EditorStatusBar({
              line: this.cursorLine,
              column: this.cursorColumn,
              language: this.currentLanguage,
              encoding: 'UTF-8',
              lineEnding: 'LF',
              isDirty: this.isCurrentTabDirty(),
              colors: this.colors
            })
          } else {
            // 欢迎页面
            WelcomeView({
              colors: this.colors,
              onOpenFile: () => this.openFile(),
              onOpenFolder: () => this.openFolder(),
              onNewFile: () => this.createNewFile()
            })
          }
        }
        .layoutWeight(1)
        .height('100%')
      }
      .layoutWeight(1)
      .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.colors.background)
      .opacity(this.pageOpacity)
      .scale({ x: this.pageScale, y: this.pageScale })
      .animation({
        duration: 400,
        curve: curves.springMotion(0.5, 0.9)
      })

      // Toast 提示
      if (this.showLoadingToast) {
        this.ToastOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ToastOverlay() {
    Column() {
      Blank().layoutWeight(1)

      Row({ space: 12 }) {
        LoadingProgress()
          .width(20)
          .height(20)
          .color(Color.White)

        Text(this.toastMessage)
          .fontSize(14)
          .fontColor(Color.White)
      }
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .borderRadius(24)
      .backgroundColor('rgba(0, 0, 0, 0.75)')
      .backdropBlur(10)
      .shadow({
        radius: 16,
        color: 'rgba(0, 0, 0, 0.3)',
        offsetY: 4
      })
      .margin({ bottom: 100 })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  buildResizeDivider() {
    Stack({
      alignContent: Alignment.Center
    }) {
      // 可点击区域
      Column()
        .width(4)
        .height('100%')
        .backgroundColor(Color.Transparent)

      // 悬停时显示的手势提示线
      Column()
        .width(1)
        .height('100%')
        .backgroundColor(this.colors.divider)
        .opacity(this.isDividerHovered ? 1 : 0)
        .animation({
          duration: 150,
          curve: Curve.EaseOut
        })
    }
    .width(4)
    .height('100%')
    .hitTestBehavior(HitTestMode.Block)
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionUpdate((event: GestureEvent) => {
          let newWidth = this.sidebarWidth + event.offsetX
          newWidth = Math.max(200, Math.min(400, newWidth))
          this.sidebarWidth = newWidth
        })
        .onActionEnd(() => {
          // 吸附效果
          if (this.sidebarWidth < 220) {
            this.sidebarWidth = 200
          } else if (this.sidebarWidth > 380) {
            this.sidebarWidth = 400
          }
        })
    )
    .onHover((hover: boolean) => {
      this.isDividerHovered = hover
    })
  }

  // ==================== 业务逻辑方法 ====================

  /**
   * 切换侧边栏显示
   */
  toggleSidebar(): void {
    this.isSidebarVisible = !this.isSidebarVisible
  }

  /**
   * 切换主题
   */
  toggleTheme(): void {
    this.isDarkMode = !this.isDarkMode
    this.colors = this.isDarkMode ? DarkTheme.colors : LightTheme.colors
    this.themeManager.toggleTheme()
  }

  /**
   * 切换文件夹展开状态
   */
  toggleFolder(folder: FileNode): void {
    if (this.expandedFolders.has(folder.id)) {
      this.expandedFolders.delete(folder.id)
    } else {
      this.expandedFolders.add(folder.id)
    }
    // 触发更新
    this.expandedFolders = new Set(this.expandedFolders)
  }

  /**
   * 在标签中打开文件
   */
  openFileInTab(file: FileNode): void {
    if (file.type !== 'file') return

    this.selectedFileId = file.id

    // 检查是否已打开
    const existingTab = this.tabs.find(tab => tab.fileId === file.id)
    if (existingTab) {
      this.switchTab(existingTab.id)
      return
    }

    // 获取文件内容
    const content = SampleCodeContents[file.name] ||
      `// ${file.name}\n// 文件内容加载中...\n\nconsole.log('Hello, ${file.name}!');`

    // 创建新标签
    const newTab: EditorTab = {
      id: `tab_${Date.now()}`,
      fileId: file.id,
      fileName: file.name,
      filePath: file.path,
      content: content,
      language: this.syntaxService.getLanguageFromExtension(file.extension || ''),
      isDirty: false,
      cursorLine: 1,
      cursorColumn: 1,
      scrollPosition: 0
    }

    this.tabs = [...this.tabs, newTab]
    this.switchTab(newTab.id)
  }

  /**
   * 切换标签
   */
  switchTab(tabId: string): void {
    const tab = this.tabs.find(t => t.id === tabId)
    if (tab) {
      this.activeTabId = tabId
      this.currentContent = tab.content
      this.currentLanguage = tab.language
      this.cursorLine = tab.cursorLine
      this.cursorColumn = tab.cursorColumn
    }
  }

  /**
   * 关闭标签
   */
  closeTab(tabId: string): void {
    const index = this.tabs.findIndex(t => t.id === tabId)
    if (index === -1) return

    this.tabs = this.tabs.filter(t => t.id !== tabId)

    // 如果关闭的是当前标签，切换到相邻标签
    if (this.activeTabId === tabId && this.tabs.length > 0) {
      const newIndex = Math.min(index, this.tabs.length - 1)
      this.switchTab(this.tabs[newIndex].id)
    } else if (this.tabs.length === 0) {
      this.activeTabId = ''
      this.currentContent = ''
      this.selectedFileId = ''
    }
  }

  /**
   * 更新内容
   */
  updateContent(content: string): void {
    this.currentContent = content
    const tab = this.tabs.find(t => t.id === this.activeTabId)
    if (tab) {
      tab.content = content
      tab.isDirty = true
      // 触发更新
      this.tabs = [...this.tabs]
    }
  }

  /**
   * 保存当前文件
   */
  saveCurrentFile(): void {
    const tab = this.tabs.find(t => t.id === this.activeTabId)
    if (tab) {
      // 显示保存提示
      this.showToast('正在保存...')

      setTimeout(() => {
        if (tab) {
          tab.isDirty = false
          this.tabs = [...this.tabs]
          this.showToast('✓ 保存成功')

          setTimeout(() => {
            this.hideToast()
          }, 1500)
        }
      }, 500)
    }
  }

  /**
   * 显示 Toast 提示
   */
  private showToast(message: string): void {
    this.toastMessage = message
    this.showLoadingToast = true
  }

  /**
   * 隐藏 Toast 提示
   */
  private hideToast(): void {
    this.showLoadingToast = false
  }

  /**
   * 创建新文件
   */
  createNewFile(): void {
    const newTab: EditorTab = {
      id: `tab_${Date.now()}`,
      fileId: `new_${Date.now()}`,
      fileName: 'Untitled.ets',
      filePath: '/Untitled.ets',
      content: `// 新建文件\n\n@Entry\n@Component\nstruct NewPage {\n  build() {\n    Column() {\n      Text('Hello World')\n        .fontSize(24)\n    }\n    .width('100%')\n    .height('100%')\n  }\n}`,
      language: 'arkts',
      isDirty: true,
      cursorLine: 1,
      cursorColumn: 1,
      scrollPosition: 0
    }

    this.tabs = [...this.tabs, newTab]
    this.switchTab(newTab.id)
  }

  /**
   * 当前标签是否有未保存修改
   */
  isCurrentTabDirty(): boolean {
    const tab = this.tabs.find(t => t.id === this.activeTabId)
    return tab?.isDirty || false
  }

  /**
   * 刷新文件树
   */
  refreshFileTree(): void {
    // 重新加载文件树
    this.rootFolder = createSampleFileTree()
    console.info('文件树已刷新')
  }

  /**
   * 打开文件（模拟）
   */
  openFile(): void {
    // 这里可以调用系统文件选择器
    console.info('打开文件选择器')
  }

  /**
   * 打开文件夹（模拟）
   */
  openFolder(): void {
    // 这里可以调用系统文件夹选择器
    console.info('打开文件夹选择器')
  }
}
