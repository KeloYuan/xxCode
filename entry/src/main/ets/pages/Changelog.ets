/**
 * 更新日志页
 * 展示离线版本更新内容
 */
import { router } from '@kit.ArkUI';
import { ThemeService, Theme } from '../services/ThemeService';

interface ReleaseNote {
  version: string;
  date: string;
  items: string[];
  highlight?: string;
}

@Entry
@Component
struct Changelog {
  pageTransition() {
    PageTransitionEnter({ duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;

  private themeService: ThemeService = ThemeService.getInstance();
  private releases: ReleaseNote[] = [
    {
      version: '3.0.0',
      date: '2025-01-10',
      highlight: '大型更新',
      items: [
        '新增学习模式、模板库、最近项目与帮助页面',
        '设置页扩展主题与外观，新增行高/行号开关',
        '编辑器稳定性与交互体验提升'
      ]
    },
    {
      version: '2.1.0',
      date: '2025-01-05',
      highlight: '学习模式上线',
      items: [
        '新增学习模式页面与示例文件',
        '模板库页支持预览与一键插入',
        '设置页增加主题与外观区'
      ]
    }
  ];

  aboutToAppear() {
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  private goBack() {
    try {
      router.back();
    } catch (e) {
      console.error('router.back error:', JSON.stringify(e));
    }
  }

  build() {
    Column() {
      Row()
        .width('100%')
        .height(this.topRectHeight > 0 ? this.topRectHeight / 3 : 0)
        .backgroundColor(this.currentTheme.colors.surface)

      Row() {
        Button({ type: ButtonType.Normal }) {
          Row({ space: 6 }) {
            Text('←').fontSize(16).fontColor(this.currentTheme.colors.primary)
            Text($r('app.string.settings_back')).fontSize(15).fontColor(this.currentTheme.colors.primary)
          }
        }
        .height(36)
        .padding({ left: 12, right: 12 })
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())

        Text($r('app.string.changelog_title'))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTheme.colors.text)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Row().width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor(this.currentTheme.colors.surface)
      .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })

      Scroll() {
        Column({ space: 16 }) {
          ForEach(this.releases, (release: ReleaseNote) => {
            Column({ space: 10 }) {
              Row({ space: 10 }) {
                Column({ space: 2 }) {
                  Text(`v${release.version}`)
                    .fontSize(16)
                    .fontColor(this.currentTheme.colors.text)
                    .fontWeight(FontWeight.Medium)
                  Text(release.date)
                    .fontSize(11)
                    .fontColor(this.currentTheme.colors.textSecondary)
                    .opacity(0.6)
                }
                .layoutWeight(1)

                if (release.highlight) {
                  Text(release.highlight)
                    .fontSize(11)
                    .fontColor(this.currentTheme.colors.primary)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor(`${this.currentTheme.colors.primary}15`)
                    .borderRadius(10)
                }
              }

              Column({ space: 6 }) {
                ForEach(release.items, (item: string) => {
                  Row({ space: 8 }) {
                    Text('•')
                      .fontSize(12)
                      .fontColor(this.currentTheme.colors.textSecondary)
                    Text(item)
                      .fontSize(13)
                      .fontColor(this.currentTheme.colors.text)
                      .layoutWeight(1)
                  }
                }, (item: string) => item)
              }
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.currentTheme.colors.surface)
            .borderRadius(12)
            .border({ width: 1, color: this.currentTheme.colors.border })
          }, (release: ReleaseNote) => release.version)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(this.currentTheme.colors.background)

      Row()
        .width('100%')
        .height(this.bottomRectHeight > 0 ? this.bottomRectHeight / 3 : 0)
        .backgroundColor(this.currentTheme.colors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.colors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
