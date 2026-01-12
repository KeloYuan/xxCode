/**
 * 更新日志页 - 液态玻璃设计
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
    Stack() {
      // 渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 145,
          colors: [
            [this.currentTheme.colors.background, 0.0],
            [this.currentTheme.colors.surface, 0.5],
            [this.currentTheme.colors.background, 1.0]
          ]
        })

      // 装饰性光晕
      Circle()
        .width(280)
        .height(280)
        .fill(`${this.currentTheme.colors.primary}15`)
        .position({ x: '85%', y: '8%' })
        .blur(70)

      Circle()
        .width(200)
        .height(200)
        .fill(`${this.currentTheme.colors.primary}10`)
        .position({ x: '5%', y: '75%' })
        .blur(50)

      Column() {
        // 顶部占位
        Row()
          .width('100%')
          .height(this.topRectHeight > 0 ? this.topRectHeight / 3 : 0)

        // 液态玻璃导航栏
        Stack() {
          Row() {
            Button({ type: ButtonType.Normal }) {
              Row({ space: 6 }) {
                Text('←')
                  .fontSize(16)
                  .fontColor(this.currentTheme.colors.primary)
                Text($r('app.string.settings_back'))
                  .fontSize(15)
                  .fontColor(this.currentTheme.colors.primary)
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
        }
        .width('100%')
        .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
        .backgroundColor(`${this.currentTheme.colors.surface}CC`)
        .backdropBlur(20)
        .border({ width: { bottom: 0.5 }, color: `${this.currentTheme.colors.border}80` })

        // 更新日志列表
        Scroll() {
          Column({ space: 16 }) {
            ForEach(this.releases, (release: ReleaseNote) => {
              Stack() {
                // 主内容
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
                        .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
                        .backgroundColor(`${this.currentTheme.colors.primary}25`)
                        .backdropBlur(10)
                        .borderRadius(10)
                        .border({ width: 1, color: `${this.currentTheme.colors.primary}40` })
                    }
                  }

                  Column({ space: 6 }) {
                    ForEach(release.items, (item: string) => {
                      Row({ space: 8 }) {
                        Text('•')
                          .fontSize(12)
                          .fontColor(this.currentTheme.colors.primary)
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

                // 高光层
                Column()
                  .width('100%')
                  .height('100%')
                  .borderRadius(16)
                  .linearGradient({
                    angle: 135,
                    colors: [
                      ['rgba(255, 255, 255, 0.12)', 0.0],
                      ['rgba(255, 255, 255, 0.02)', 0.5],
                      ['rgba(255, 255, 255, 0)', 1.0]
                    ]
                  })
                  .hitTestBehavior(HitTestMode.None)
              }
              .width('100%')
              .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
              .backgroundColor(`${this.currentTheme.colors.surface}DD`)
              .backdropBlur(20)
              .borderRadius(16)
              .border({
                width: 1,
                color: `${this.currentTheme.colors.border}60`
              })
              .shadow({
                radius: 20,
                color: `${this.currentTheme.colors.primary}20`,
                offsetX: 0,
                offsetY: 6
              })
            }, (release: ReleaseNote) => release.version)
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .width('100%')

        // 底部占位
        Row()
          .width('100%')
          .height(this.bottomRectHeight > 0 ? this.bottomRectHeight / 3 : 0)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
