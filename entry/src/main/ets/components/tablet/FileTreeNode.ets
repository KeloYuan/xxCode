/**
 * 文件树节点组件
 * 精美的文件/文件夹展示，带动画效果
 */
import { FileNode, ThemeColors } from '../../models/EditorModels'
import { curves } from '@kit.ArkUI'

@Component
export struct FileTreeNode {
  @Prop node: FileNode
  @Prop level: number = 0
  @Prop isExpanded: boolean = false
  @Prop isSelected: boolean = false
  @Prop colors: ThemeColors

  onSelect: (node: FileNode) => void = () => {}
  onToggle: (node: FileNode) => void = () => {}

  // 动画状态
  @State hoverState: boolean = false
  @State pressState: boolean = false
  @State arrowRotation: number = 0
  @State itemScale: number = 1
  @State iconBounce: number = 0
  @State bgOpacity: number = 0

  aboutToAppear() {
    this.arrowRotation = this.isExpanded ? 90 : 0
  }

  build() {
    Row() {
      // 缩进
      Blank().width(this.level * 16 + 8)

      // 展开箭头（仅文件夹）
      if (this.node.type === 'folder') {
        Text('▶')
          .fontSize(9)
          .fontColor(this.isSelected ? this.colors.primary : this.colors.textSecondary)
          .width(16)
          .textAlign(TextAlign.Center)
          .rotate({ angle: this.arrowRotation })
          .animation({
            duration: 250,
            curve: curves.springMotion(0.5, 0.85)
          })
      } else {
        Blank().width(16)
      }

      // 文件图标
      Text(this.getFileIcon())
        .fontSize(16)
        .margin({ left: 4, right: 10 })
        .translate({ y: this.iconBounce })
        .animation({
          duration: 300,
          curve: curves.springMotion(0.35, 0.7)
        })

      // 文件名
      Text(this.node.name)
        .fontSize(13)
        .fontColor(this.isSelected ? this.colors.primary : this.colors.textPrimary)
        .fontWeight(this.isSelected ? FontWeight.Medium : FontWeight.Normal)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      // 文件大小（仅文件）
      if (this.node.type === 'file' && this.node.size) {
        Text(this.formatSize(this.node.size))
          .fontSize(11)
          .fontColor(this.colors.textDisabled)
          .margin({ right: 8 })
          .opacity(this.hoverState ? 1 : 0)
          .animation({
            duration: 150,
            curve: Curve.EaseOut
          })
      }
    }
    .width('100%')
    .height(34)
    .padding({ right: 8 })
    .scale({ x: this.itemScale, y: this.itemScale })
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(8)
    .margin({ left: 4, right: 4, top: 1, bottom: 1 })
    .animation({
      duration: 180,
      curve: curves.springMotion(0.6, 0.95)
    })
    // 悬停效果
    .onHover((isHover: boolean) => {
      this.hoverState = isHover
      if (isHover) {
        // 图标弹跳
        this.iconBounce = -2
        setTimeout(() => {
          this.iconBounce = 0
        }, 100)
      }
    })
    // 点击效果
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressState = true
        this.itemScale = 0.98
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressState = false
        this.itemScale = 1
      }
    })
    .onClick(() => {
      if (this.node.type === 'folder') {
        // 展开/折叠动画
        this.arrowRotation = this.isExpanded ? 0 : 90
        this.onToggle(this.node)
      } else {
        this.onSelect(this.node)
      }
    })
  }

  getBackgroundColor(): ResourceColor {
    if (this.isSelected) {
      return this.colors.active
    } else if (this.pressState) {
      return this.colors.pressed
    } else if (this.hoverState) {
      return this.colors.hover
    }
    return Color.Transparent
  }

  getFileIcon(): string {
    if (this.node.type === 'folder') {
      return this.isExpanded ? '📂' : '📁'
    }

    // 根据扩展名返回图标
    const ext = this.node.extension?.toLowerCase() || ''
    const iconMap: Record<string, string> = {
      'ets': '🔶',
      'ts': '🔷',
      'js': '🟨',
      'json': '📋',
      'json5': '📋',
      'md': '📝',
      'html': '🌐',
      'css': '🎨',
      'py': '🐍',
      'java': '☕',
      'c': '📘',
      'cpp': '📘',
      'h': '📑',
      'txt': '📄',
      'xml': '📰',
      'yaml': '⚙️',
      'yml': '⚙️',
      'sh': '🖥️',
      'bat': '🖥️'
    }
    return iconMap[ext] || '📄'
  }

  formatSize(bytes: number): string {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }
}
