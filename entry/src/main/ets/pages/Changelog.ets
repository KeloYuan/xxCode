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
      version: '4.0.0',
      date: '2025-12-29',
      highlight: '重大版本更新',
      items: [
        '全新响应式布局架构，完美适配移动端与桌面端',
        '新增代码执行服务，支持实时运行代码',
        '优化编辑器性能与交互体验',
        '新增多主题支持，实时切换',
        '文件管理功能全面升级'
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
