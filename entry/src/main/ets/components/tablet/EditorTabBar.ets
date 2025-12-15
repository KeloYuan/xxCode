/**
 * 编辑器标签栏组件
 * 支持多标签切换、关闭、滑动等
 */
import { EditorTab, ThemeColors } from '../../models/EditorModels'
import { curves } from '@kit.ArkUI'

@Component
export struct EditorTabBar {
  @Prop tabs: EditorTab[] = []
  @Prop activeTabId: string = ''
  @Prop colors: ThemeColors

  onTabSelect: (tabId: string) => void = () => {}
  onTabClose: (tabId: string) => void = () => {}
  onNewTab: () => void = () => {}

  // 指示器动画
  @State indicatorOffset: number = 0
  @State indicatorWidth: number = 0
  @State newBtnScale: number = 1

  private scroller: Scroller = new Scroller()

  build() {
    Row() {
      // 可滚动的标签区域
      Scroll(this.scroller) {
        Row({ space: 2 }) {
          ForEach(this.tabs, (tab: EditorTab, index: number) => {
            EditorTabItem({
              tab: tab,
              isActive: tab.id === this.activeTabId,
              colors: this.colors,
              onSelect: () => this.onTabSelect(tab.id),
              onClose: () => this.onTabClose(tab.id)
            })
          }, (tab: EditorTab) => tab.id)
        }
        .padding({ left: 8, right: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      // 新建标签按钮
      Column() {
        Text('+')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.colors.textSecondary)
      }
      .width(36)
      .height(36)
      .borderRadius(10)
      .backgroundColor(this.colors.surfaceVariant)
      .margin({ left: 8, right: 12 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .scale({ x: this.newBtnScale, y: this.newBtnScale })
      .animation({
        duration: 200,
        curve: curves.springMotion(0.5, 0.9)
      })
      .onClick(() => this.onNewTab())
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.newBtnScale = 0.9
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.newBtnScale = 1
        }
      })
    }
    .width('100%')
    .height(44)
    .backgroundColor(this.colors.surface)
    .border({
      width: { bottom: 1 },
      color: this.colors.divider
    })
  }
}

@Component
struct EditorTabItem {
  @Prop tab: EditorTab
  @Prop isActive: boolean = false
  @Prop colors: ThemeColors

  onSelect: () => void = () => {}
  onClose: () => void = () => {}

  // 动画状态
  @State isHovered: boolean = false
  @State itemScale: number = 1
  @State closeBtnOpacity: number = 0

  build() {
    Row({ space: 8 }) {
      // 文件图标
      Text(this.getLanguageIcon())
        .fontSize(14)

      // 文件名
      Text(this.tab.fileName)
        .fontSize(13)
        .fontColor(this.isActive ? this.colors.primary : this.colors.textPrimary)
        .fontWeight(this.isActive ? FontWeight.Medium : FontWeight.Normal)
        .maxLines(1)
        .constraintSize({ maxWidth: 120 })
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 修改指示器 或 关闭按钮
      Column() {
        if (this.tab.isDirty) {
          // 未保存指示点
          Circle()
            .width(8)
            .height(8)
            .fill('#F59E0B')
        } else {
          // 关闭按钮
          Text('✕')
            .fontSize(12)
            .fontColor(this.colors.textSecondary)
            .opacity(this.isHovered || this.isActive ? 1 : 0)
            .animation({
              duration: 150,
              curve: Curve.EaseOut
            })
        }
      }
      .width(20)
      .height(20)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius(4)
      .onClick(() => {
        this.onClose()
      })
    }
    .height(34)
    .padding({ left: 12, right: 8 })
    .borderRadius({ topLeft: 8, topRight: 8 })
    .backgroundColor(this.isActive ? this.colors.surfaceVariant : Color.Transparent)
    .border({
      width: { bottom: this.isActive ? 2 : 0 },
      color: this.colors.primary
    })
    .scale({ x: this.itemScale, y: this.itemScale })
    .animation({
      duration: 180,
      curve: curves.springMotion(0.6, 0.95)
    })
    .onHover((isHover: boolean) => {
      this.isHovered = isHover
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.itemScale = 0.97
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.itemScale = 1
      }
    })
    .onClick(() => this.onSelect())
  }

  getLanguageIcon(): string {
    const lang = this.tab.language.toLowerCase()
    const iconMap: Record<string, string> = {
      'arkts': '🔶',
      'typescript': '🔷',
      'javascript': '🟨',
      'json': '📋',
      'markdown': '📝',
      'html': '🌐',
      'css': '🎨',
      'python': '🐍'
    }
    return iconMap[lang] || '📄'
  }
}
