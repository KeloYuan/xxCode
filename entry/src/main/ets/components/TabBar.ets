/**
 * 标签栏组件 - 鸿蒙设计风格
 * 卡片化标签、流畅动效、纯文字扩展名徽章
 */
import { FileTab } from '../models/FileTabModel';
import { curves } from '@kit.ArkUI';

@Component
export struct TabBar {
  @Prop @Watch('onTabsChange') tabs: FileTab[] = [];
  @Prop currentTabId: string = '';
  @Prop bgColor: ResourceColor = '#252526';
  @Prop textColor: ResourceColor = '#FFFFFF';
  @Prop tabBorderColor: ResourceColor = '#333333';
  @Prop activeTabBgColor: ResourceColor = '#0A59F7'; // 鸿蒙蓝
  @Prop activeColor: ResourceColor = '#0A59F7'; // 徽章主色
  onTabClick?: (tabId: string) => void;
  onTabClose?: (tabId: string) => void;

  @State private hoveredTab: string = '';
  @State private pressedTab: string = '';
  @State private barWidth: number = 0;
  private scroller: Scroller = new Scroller();
  private springCurve: ICurve = curves.springMotion(0.6, 0.9);

  // 鸿蒙动效时长
  private readonly MICRO_DURATION: number = 150;
  private readonly STANDARD_DURATION: number = 250;

  onTabsChange() {
    // 标签变化时滚动到当前标签
  }

  build() {
    if (this.tabs.length === 0) {
      Row() {
        Text($r('app.string.text_no_tabs'))
          .fontSize(13)
          .fontColor(this.textColor)
          .opacity(0.5)
      }
      .width('100%')
      .height(48)
      .backgroundColor(this.bgColor)
      .border({ width: { bottom: 0.5 }, color: this.tabBorderColor })
      .padding({ left: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
    } else {
      Scroll(this.scroller) {
        Row({ space: 6 }) {
          ForEach(this.tabs, (tab: FileTab) => {
            this.buildTab(tab)
          }, (tab: FileTab) => tab.id)
        }
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .justifyContent(FlexAlign.Start)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(48)
      .backgroundColor(this.bgColor)
      .border({ width: { bottom: 0.5 }, color: this.tabBorderColor })
      .align(Alignment.TopStart)
      .onAreaChange((oldArea, newArea) => {
        // 记录可用宽度，用于动态计算标签宽度
        const width = this.lengthToNumber(newArea.width)
        if (width > 0) {
          this.barWidth = width
        }
      })
    }
  }

  private lengthToNumber(length: Length): number {
    if (typeof length === 'number') {
      return length
    }
    if (typeof length === 'string') {
      const parsed = parseFloat(length)
      return Number.isFinite(parsed) ? parsed : 0
    }
    return 0
  }

  private getTabWidth(): number {
    // 经验值：两侧 padding 合计 16，标签间距约 6
    // tabs 少时更宽；tabs 多时变窄，必要时由横向滚动承载
    if (this.tabs.length === 0) return 0;
    if (this.barWidth <= 0) return 180;

    const horizontalPadding = 16;
    const totalGaps = Math.max(0, this.tabs.length - 1) * 6;
    const available = Math.max(0, this.barWidth - horizontalPadding - totalGaps);
    const raw = available / this.tabs.length;
    const minWidth = 120;
    const maxWidth = 360;
    return Math.max(minWidth, Math.min(maxWidth, raw));
  }

  /**
   * 获取文件扩展名徽章文本
   */
  private getFileExtensionBadge(fileName: string): string {
    const ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    const extUpper = ext.toUpperCase();
    // 如果没有扩展名或文件名本身是扩展名格式，返回原扩展名
    if (!ext || ext === fileName) {
      return 'TXT';
    }
    return extUpper.substring(0, 4); // 最多4个字符
  }

  /**
   * 根据扩展名获取徽章颜色
   */
  private getBadgeColor(fileName: string): string {
    const ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    const colorMap: Record<string, string> = {
      'js': '#F7DF1E',     // JavaScript 黄色
      'ts': '#3178C6',     // TypeScript 蓝色
      'ets': '#0A59F7',    // ArkTS 鸿蒙蓝
      'py': '#3776AB',     // Python 蓝色
      'java': '#007396',   // Java 深蓝
      'html': '#E34F26',   // HTML 橙色
      'css': '#1572B6',    // CSS 蓝色
      'json': '#292929',   // JSON 深灰
      'md': '#083FA1',     // Markdown 蓝色
      'txt': '#6B7280'     // 纯文本 灰色
    };
    return colorMap[ext] || this.activeColor as string;
  }

  @Builder
  buildTab(tab: FileTab): void {
    Row({ space: 8 }) {
      // 文件扩展名徽章
      Text(`.${this.getFileExtensionBadge(tab.fileName)}`)
        .fontSize(10)
        .fontColor(tab.id === this.currentTabId ? Color.White : this.getBadgeColor(tab.fileName))
        .fontWeight(FontWeight.Medium)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .backgroundColor(tab.id === this.currentTabId ? 'rgba(255, 255, 255, 0.2)' : `${this.getBadgeColor(tab.fileName)}20`)
        .borderRadius(4)
        .border({
          width: tab.id === this.currentTabId ? 0 : 0.5,
          color: this.getBadgeColor(tab.fileName)
        })

      // 文件名 - 激活时使用白色，非激活时使用主题颜色
      Text(tab.fileName + (tab.isModified ? ' •' : ''))
        .fontSize(13)
        .fontColor(tab.id === this.currentTabId ? '#FFFFFF' : this.textColor)
        .fontWeight(tab.id === this.currentTabId ? FontWeight.Medium : FontWeight.Regular)
        .opacity(tab.id === this.currentTabId ? 1.0 : 0.75)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      // 关闭按钮 - 增大热区以符合 HarmonyOS 规范（最小 44x44 vp）
      Button({ type: ButtonType.Circle }) {
        Text('×')
          .fontSize(18)
          .fontColor(tab.id === this.currentTabId ? '#FFFFFF' : this.textColor)
          .fontWeight(FontWeight.Medium)
      }
      .width(28)
      .height(28)
      .backgroundColor(Color.Transparent)
      .padding(0)
      .stateEffect(true)
      .responseRegion({
        x: -8,
        y: -8,
        width: 44,
        height: 44
      })
      .onClick(() => {
        if (this.onTabClose) {
          this.onTabClose(tab.id);
        }
      })
    }
    .height(36)
    .padding({ left: 10, right: 8 })
    .width(this.getTabWidth())
    .backgroundColor(tab.id === this.currentTabId ?
      this.activeTabBgColor : (this.hoveredTab === tab.id ?
        'rgba(255, 255, 255, 0.05)' : Color.Transparent))
    .border({
      width: tab.id === this.currentTabId ? 0 : 0.5,
      color: tab.id === this.currentTabId ? this.activeTabBgColor : this.tabBorderColor
    })
    .borderRadius(10)
    .scale({
      x: this.hoveredTab === tab.id ? 1.02 : (this.pressedTab === tab.id ? 0.98 : 1),
      y: this.hoveredTab === tab.id ? 1.02 : (this.pressedTab === tab.id ? 0.98 : 1)
    })
    .shadow(tab.id === this.currentTabId ? {
      radius: 8,
      color: `${this.activeColor}40`,
      offsetX: 0,
      offsetY: 2
    } : undefined)
    .animation({
      duration: this.STANDARD_DURATION,
      curve: this.springCurve
    })
    .transition(
      TransitionEffect.OPACITY.animation({ duration: 180, curve: Curve.EaseOut })
        .combine(TransitionEffect.translate({ y: 6 }))
        .combine(TransitionEffect.scale({ x: 0.96, y: 0.96 }))
    )
    .onHover((isHover: boolean) => {
      animateTo({
        duration: this.STANDARD_DURATION,
        curve: this.springCurve
      }, () => {
        this.hoveredTab = isHover ? tab.id : '';
      });
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedTab = tab.id;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedTab = '';
      }
    })
    .onClick(() => {
      if (this.onTabClick) {
        this.onTabClick(tab.id);
      }
    })
  }
}
