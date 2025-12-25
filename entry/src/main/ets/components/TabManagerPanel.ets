/**
 * 标签页管理面板
 * 简洁设计
 */
import { FileTab } from '../models/FileTabModel';

@Component
export struct TabManagerPanel {
  @Prop tabs: FileTab[] = [];
  @Prop currentTabId: string = '';
  @Prop bgColor: string = '#FFFFFF';
  @Prop textColor: string = '#000000';
  onTabClick?: (tabId: string) => void;
  onTabClose?: (tabId: string) => void;
  onNewTab?: () => void;

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('标签页')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textColor)
          .layoutWeight(1)

        Text('+')
          .fontSize(20)
          .fontColor(this.textColor)
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onNewTab?.();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 16 })

      Divider().color(`${this.textColor}20`).strokeWidth(0.5)

      // 标签列表
      if (this.tabs.length === 0) {
        Column() {
          Text('暂无打开的标签页')
            .fontSize(14)
            .fontColor(`${this.textColor}60`)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          ForEach(this.tabs, (tab: FileTab) => {
            Row() {
              Column() {
                Text(tab.fileName + (tab.isModified ? ' •' : ''))
                  .fontSize(15)
                  .fontColor(this.textColor)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                if (tab.filePath && tab.filePath !== '') {
                  Text(this.getShortPath(tab.filePath))
                    .fontSize(12)
                    .fontColor(`${this.textColor}50`)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 2 })
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Text('×')
                .fontSize(18)
                .fontColor(`${this.textColor}50`)
                .width(32)
                .height(32)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  this.onTabClose?.(tab.id);
                })
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 12 })
            .backgroundColor(tab.id === this.currentTabId ? `${this.textColor}10` : 'transparent')
            .onClick(() => {
              this.onTabClick?.(tab.id);
            })
          }, (tab: FileTab) => tab.id)
        }
        .width('100%')
        .layoutWeight(1)
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
}
