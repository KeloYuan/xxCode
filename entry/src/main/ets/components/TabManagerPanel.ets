/**
 * 标签页管理面板
 * 简洁设计
 */
import { FileTab } from '../models/FileTabModel';
import { curves } from '@kit.ArkUI';

@Component
export struct TabManagerPanel {
  @Prop tabs: FileTab[] = [];
  @Prop @Watch('onCurrentTabChange') currentTabId: string = '';
  @Prop bgColor: string = '#FFFFFF';
  @Prop textColor: string = '#000000';
  @Prop activeColor: string = '#0A59F7';
  @Prop dividerColor: ResourceColor = '#E5E7EB';
  onTabClick?: (tabId: string) => void;
  onTabClose?: (tabId: string) => void;
  onNewTab?: () => void;

  @State private pressedTabId: string = '';
  @State private activeTabId: string = '';
  private springCurve: ICurve = curves.springMotion(0.6, 0.9);

  aboutToAppear() {
    this.activeTabId = this.currentTabId;
  }

  private onCurrentTabChange(): void {
    if (this.currentTabId === this.activeTabId) {
      return;
    }
    animateTo({ duration: 220, curve: this.springCurve }, () => {
      this.activeTabId = this.currentTabId;
    });
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('标签页')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textColor)
          .layoutWeight(1)

        Button({ type: ButtonType.Normal }) {
          Text('+')
            .fontSize(20)
            .fontColor(this.activeColor)
            .fontWeight(FontWeight.Bold)
        }
        .width(40)
        .height(40)
        .backgroundColor(this.alphaColor(this.activeColor, 0.12))
        .borderRadius(12)
        .border({ width: 1, color: this.alphaColor(this.activeColor, 0.35) })
        .shadow({
          radius: 10,
          color: this.alphaColor(this.activeColor, 0.2),
          offsetX: 0,
          offsetY: 3
        })
        .stateEffect(true)
        .responseRegion({
          x: -6,
          y: -6,
          width: 48,
          height: 48
        })
        .onClick(() => {
          this.onNewTab?.();
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 16 })

      Divider().color(this.dividerColor).strokeWidth(0.5)

      // 标签列表
      if (this.tabs.length === 0) {
        Column() {
          Text('暂无打开的标签页')
            .fontSize(14)
            .fontColor(this.textColor)
            .opacity(0.6)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column({ space: 10 }) {
          ForEach(this.tabs, (tab: FileTab) => {
            Row() {
              Column() {
                Text(tab.fileName + (tab.isModified ? ' •' : ''))
                  .fontSize(15)
                  .fontColor(tab.id === this.activeTabId ? '#FFFFFF' : this.textColor)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                if (tab.filePath && tab.filePath !== '') {
                  Text(this.getShortPath(tab.filePath))
                    .fontSize(12)
                    .fontColor(tab.id === this.activeTabId ? 'rgba(255, 255, 255, 0.75)' : this.textColor)
                    .opacity(tab.id === this.activeTabId ? 1 : 0.55)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 2 })
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Button({ type: ButtonType.Normal }) {
                Text('×')
                  .fontSize(16)
                  .fontColor(tab.id === this.activeTabId ? 'rgba(255, 255, 255, 0.9)' : this.textColor)
                  .fontWeight(FontWeight.Medium)
              }
              .width(32)
              .height(32)
              .backgroundColor(tab.id === this.activeTabId ? 'rgba(255, 255, 255, 0.22)' : this.alphaColor(this.textColor, 0.08))
              .borderRadius(12)
              .border({
                width: 1,
                color: tab.id === this.activeTabId ? 'rgba(255, 255, 255, 0.28)' : this.alphaColor(this.textColor, 0.16)
              })
              .stateEffect(true)
              .responseRegion({
                x: -6,
                y: -6,
                width: 48,
                height: 48
              })
              .onClick(() => {
                this.onTabClose?.(tab.id);
              })
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 12 })
            .backgroundColor(tab.id === this.activeTabId ?
              this.activeColor : (this.pressedTabId === tab.id ?
                this.alphaColor(this.activeColor, 0.12) : this.alphaColor(this.textColor, 0.04)))
            .border({
              width: tab.id === this.activeTabId ? 0 : 1,
              color: tab.id === this.activeTabId ? this.activeColor : this.dividerColor
            })
            .borderRadius(16)
            .shadow(tab.id === this.activeTabId ? {
              radius: 12,
              color: this.alphaColor(this.activeColor, 0.35),
              offsetX: 0,
              offsetY: 4
            } : undefined)
            .scale({
              x: this.pressedTabId === tab.id ? 0.98 : 1,
              y: this.pressedTabId === tab.id ? 0.98 : 1
            })
            .animation({
              duration: 200,
              curve: this.springCurve
            })
            .transition(
              TransitionEffect.OPACITY.animation({ duration: 180, curve: Curve.EaseOut })
                .combine(TransitionEffect.translate({ y: 8 }))
                .combine(TransitionEffect.scale({ x: 0.96, y: 0.96 }))
            )
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.pressedTabId = tab.id;
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.pressedTabId = '';
              }
            })
            .onClick(() => {
              this.onTabClick?.(tab.id);
            })
          }, (tab: FileTab) => tab.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 12, right: 12, top: 12, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
  }

  private getShortPath(path: string): string {
    const parts = path.split('/');
    if (parts.length > 2) {
      return '.../' + parts[parts.length - 1];
    }
    return path;
  }

  private alphaColor(color: string, alpha: number): string {
    const clampedAlpha = Math.max(0, Math.min(1, alpha));
    const trimmed = color.trim();
    if (trimmed.startsWith('#')) {
      let hex = trimmed.slice(1);
      if (hex.length === 3) {
        hex = hex.split('').map((value) => value + value).join('');
      } else if (hex.length === 8) {
        hex = hex.slice(0, 6);
      }
      if (hex.length === 6) {
        const r = parseInt(hex.slice(0, 2), 16);
        const g = parseInt(hex.slice(2, 4), 16);
        const b = parseInt(hex.slice(4, 6), 16);
        return `rgba(${r}, ${g}, ${b}, ${clampedAlpha})`;
      }
    }
    const rgbMatch = trimmed.match(/rgba?\(([^)]+)\)/i);
    if (rgbMatch) {
      const parts = rgbMatch[1].split(',').map((value) => value.trim());
      if (parts.length >= 3) {
        const r = Number(parts[0]);
        const g = Number(parts[1]);
        const b = Number(parts[2]);
        if ([r, g, b].every((value) => Number.isFinite(value))) {
          return `rgba(${r}, ${g}, ${b}, ${clampedAlpha})`;
        }
      }
    }
    return color;
  }
}
