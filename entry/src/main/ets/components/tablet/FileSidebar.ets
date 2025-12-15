/**
 * 文件侧边栏组件
 * 包含文件树浏览、搜索等功能
 */
import { FileNode, ThemeColors } from '../../models/EditorModels'
import { FileTreeNode } from './FileTreeNode'
import { curves } from '@kit.ArkUI'

@Component
export struct FileSidebar {
  @Link expandedFolders: Set<string>
  @Prop rootFolder: FileNode | null = null
  @Prop selectedFileId: string = ''
  @Prop colors: ThemeColors
  @Prop isDarkMode: boolean = true

  onFileSelect: (file: FileNode) => void = () => {}
  onFolderToggle: (folder: FileNode) => void = () => {}
  onRefresh: () => void = () => {}

  // 状态
  @State searchText: string = ''
  @State isSearchFocused: boolean = false
  @State headerHover: boolean = false

  private scroller: Scroller = new Scroller()

  build() {
    Column() {
      // 侧边栏头部
      this.SidebarHeader()

      // 搜索框
      this.SearchBar()

      // 文件树
      if (this.rootFolder) {
        Scroll(this.scroller) {
          Column() {
            this.buildFileTree(this.rootFolder, 0)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 4, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarColor(this.colors.textDisabled)
        .scrollBarWidth(4)
        .edgeEffect(EdgeEffect.Spring)
        .friction(0.75)
      } else {
        // 空状态
        this.EmptyState()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.colors.sidebarBg)
    .border({
      width: { right: 1 },
      color: this.colors.divider
    })
  }

  @Builder
  SidebarHeader() {
    Column() {
      Row() {
        // 标题
        Row({ space: 8 }) {
          Text('📁')
            .fontSize(16)
          Column() {
            Text('资源管理器')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.colors.textPrimary)
            
            // 文件统计
            Text(this.getFileCount())
              .fontSize(10)
              .fontColor(this.colors.textDisabled)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
        }

        Blank()

        // 操作按钮
        Row({ space: 2 }) {
          this.HeaderIconButton('➕', '新建文件')
          this.HeaderIconButton('📁', '新建文件夹')
          this.HeaderIconButton('📤', '展开全部', () => this.expandAll())
          this.HeaderIconButton('📥', '折叠全部', () => this.collapseAll())
          this.HeaderIconButton('🔄', '刷新', () => this.onRefresh())
        }
        .opacity(this.headerHover ? 1 : 0.6)
        .animation({
          duration: 150,
          curve: Curve.EaseOut
        })
      }
      .width('100%')
      .height(44)
      .padding({ left: 12, right: 8 })
      .onHover((isHover: boolean) => {
        this.headerHover = isHover
      })
    }
  }

  private getFileCount(): string {
    if (!this.rootFolder) return '0 项'
    const count = this.countFiles(this.rootFolder)
    return `${count} 个文件`
  }

  private countFiles(node: FileNode): number {
    if (node.type === 'file') return 1
    let count = 0
    if (node.children) {
      node.children.forEach(child => {
        count += this.countFiles(child)
      })
    }
    return count
  }

  private expandAll(): void {
    if (!this.rootFolder) return
    const allFolders = this.getAllFolderIds(this.rootFolder)
    this.expandedFolders = new Set(allFolders)
  }

  private collapseAll(): void {
    this.expandedFolders = new Set(['root'])
  }

  private getAllFolderIds(node: FileNode): string[] {
    const ids: string[] = []
    if (node.type === 'folder') {
      ids.push(node.id)
      if (node.children) {
        node.children.forEach(child => {
          ids.push(...this.getAllFolderIds(child))
        })
      }
    }
    return ids
  }

  @Builder
  HeaderIconButton(icon: string, tooltip: string, onClick?: () => void) {
    Text(icon)
      .fontSize(14)
      .width(28)
      .height(28)
      .textAlign(TextAlign.Center)
      .borderRadius(6)
      .backgroundColor(Color.Transparent)
      .onClick(() => onClick?.())
  }

  @Builder
  SearchBar() {
    Row() {
      Text('🔍')
        .fontSize(14)
        .fontColor(this.colors.textSecondary)
        .margin({ right: 8 })

      TextInput({ placeholder: '搜索文件...', text: this.searchText })
        .placeholderColor(this.colors.textDisabled)
        .placeholderFont({ size: 13 })
        .fontSize(13)
        .fontColor(this.colors.textPrimary)
        .caretColor(this.colors.primary)
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
        .height(32)
        .padding(0)
        .onChange((value: string) => {
          this.searchText = value
        })
        .onFocus(() => {
          this.isSearchFocused = true
        })
        .onBlur(() => {
          this.isSearchFocused = false
        })

      if (this.searchText.length > 0) {
        Text('✕')
          .fontSize(12)
          .fontColor(this.colors.textSecondary)
          .width(20)
          .height(20)
          .textAlign(TextAlign.Center)
          .borderRadius(10)
          .backgroundColor(this.colors.hover)
          .onClick(() => {
            this.searchText = ''
          })
      }
    }
    .width('100%')
    .height(36)
    .padding({ left: 10, right: 10 })
    .margin({ left: 8, right: 8, top: 4, bottom: 8 })
    .borderRadius(10)
    .backgroundColor(this.colors.surfaceVariant)
    .border({
      width: 1,
      color: this.isSearchFocused ? this.colors.primary : Color.Transparent
    })
    .animation({
      duration: 200,
      curve: Curve.EaseOut
    })
  }

  @Builder
  EmptyState() {
    Column({ space: 12 }) {
      Text('📂')
        .fontSize(48)
        .opacity(0.5)

      Text('暂无打开的项目')
        .fontSize(14)
        .fontColor(this.colors.textSecondary)

      Button('打开文件夹')
        .type(ButtonType.Capsule)
        .fontSize(13)
        .fontColor(Color.White)
        .backgroundColor(this.colors.primary)
        .height(36)
        .padding({ left: 20, right: 20 })
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildFileTree(node: FileNode, level: number) {
    // 当前节点
    FileTreeNode({
      node: node,
      level: level,
      isExpanded: this.expandedFolders.has(node.id),
      isSelected: node.id === this.selectedFileId,
      colors: this.colors,
      onSelect: (file: FileNode) => this.onFileSelect(file),
      onToggle: (folder: FileNode) => this.onFolderToggle(folder)
    })

    // 递归渲染子节点
    if (node.type === 'folder' && node.children && this.expandedFolders.has(node.id)) {
      ForEach(node.children, (child: FileNode) => {
        this.buildFileTree(child, level + 1)
      })
    }
  }
}
