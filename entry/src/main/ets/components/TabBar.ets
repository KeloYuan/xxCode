/**
 * 标签栏组件
 * 显示打开的文件标签
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
  @Prop activeTabBgColor: ResourceColor = '#3E3E42'; // 当前标签背景色
  onTabClick?: (tabId: string) => void;
  onTabClose?: (tabId: string) => void;
  
  private scroller: Scroller = new Scroller();
  private springCurve: ICurve = curves.springMotion(0.6, 0.8);

  onTabsChange() {
    // 标签变化时滚动到当前标签
  }

  build() {
    if (this.tabs.length === 0) {
      Row() {
        Text('无打开文件')
          .fontSize(12)
          .fontColor(this.textColor)
          .opacity(0.5)
          .padding({ left: 12 })
      }
      .width('100%')
      .height(40)
      .backgroundColor(this.bgColor)
      .border({ width: { bottom: 1 }, color: this.tabBorderColor })
      .justifyContent(FlexAlign.Start)
    } else {
      Scroll(this.scroller) {
        Row({ space: 0 }) {
          ForEach(this.tabs, (tab: FileTab) => {
            this.buildTab(tab)
          }, (tab: FileTab) => tab.id)
        }
        .justifyContent(FlexAlign.Start)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(40)
      .backgroundColor(this.bgColor)
      .border({ width: { bottom: 1 }, color: this.tabBorderColor })
      .align(Alignment.Start)
    }
  }

  @Builder
  buildTab(tab: FileTab): void {
    Row({ space: 6 }) {
      // 文件名
      Text(tab.fileName + (tab.isModified ? ' •' : ''))
        .fontSize(13)
        .fontColor(this.textColor)
        .opacity(tab.id === this.currentTabId ? 1.0 : 0.7)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      
      // 关闭按钮
      Button({ type: ButtonType.Normal }) {
        Text('×')
          .fontSize(18)
          .fontColor(this.textColor)
          .opacity(0.7)
      }
      .width(20)
      .height(20)
      .backgroundColor(Color.Transparent)
      .borderRadius(4)
      .padding(0)
      .stateEffect(true)
      .onClick(() => {
        if (this.onTabClose) {
          this.onTabClose(tab.id);
        }
      })
    }
    .height(40)
    .padding({ left: 12, right: 8 })
    .constraintSize({ minWidth: 100, maxWidth: 200 })
    .backgroundColor(tab.id === this.currentTabId ? 
      this.activeTabBgColor : Color.Transparent)
    .border({ 
      width: { right: 1 }, 
      color: this.tabBorderColor 
    })
    .borderRadius({ topLeft: 4, topRight: 4 })
    .onClick(() => {
      if (this.onTabClick) {
        this.onTabClick(tab.id);
      }
    })
  }
}
