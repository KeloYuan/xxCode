/**
 * 帮助与快捷键页 - 液态玻璃设计
 * 离线说明与快捷键列表
 */
import { router } from '@kit.ArkUI';
import { ThemeService, Theme } from '../services/ThemeService';

@Entry
@Component
struct Help {
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
        .width(260)
        .height(260)
        .fill(`${this.currentTheme.colors.primary}15`)
        .position({ x: '80%', y: '15%' })
        .blur(60)

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

            Text($r('app.string.help_title'))
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

        // 内容区
        Scroll() {
          Column({ space: 16 }) {
            this.buildQuickStart()
            this.buildShortcuts()
            this.buildGestures()
            this.buildTips()
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

  @Builder
  buildSectionTitle(title: ResourceStr) {
    Text(title)
      .fontSize(13)
      .fontColor(this.currentTheme.colors.textSecondary)
      .width('100%')
      .padding({ left: 4, bottom: 8 })
  }

  @Builder
  buildQuickStart() {
    Column() {
      this.buildSectionTitle($r('app.string.help_quick_start'))
      Column({ space: 8 }) {
        this.buildBullet($r('app.string.help_quick_start_1'))
        this.buildBullet($r('app.string.help_quick_start_2'))
        this.buildBullet($r('app.string.help_quick_start_3'))
      }
      .width('100%')
      .padding(12)
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .backgroundColor(`${this.currentTheme.colors.surface}DD`)
      .backdropBlur(20)
      .borderRadius(16)
      .border({ width: 1, color: `${this.currentTheme.colors.border}60` })
      .shadow({
        radius: 16,
        color: `${this.currentTheme.colors.primary}15`,
        offsetX: 0,
        offsetY: 4
      })
    }
    .width('100%')
  }

  @Builder
  buildShortcuts() {
    Column() {
      this.buildSectionTitle($r('app.string.help_shortcuts'))
      Column({ space: 8 }) {
        // 设备限制提示 - 液态玻璃
        Row({ space: 8 }) {
          Text('⚠️')
            .fontSize(14)
          Text('快捷键仅支持电脑端或连接外接键盘的平板设备')
            .fontSize(12)
            .fontColor(this.currentTheme.colors.textSecondary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
        .backgroundColor(`${this.currentTheme.colors.primary}25`)
        .backdropBlur(10)
        .borderRadius(10)
        .border({ width: 1, color: `${this.currentTheme.colors.primary}40` })

        this.buildKeyRow('Ctrl + S', $r('app.string.help_shortcut_save'))
        this.buildKeyRow('Ctrl + F', $r('app.string.help_shortcut_search'))
        this.buildKeyRow('Ctrl + Alt + L', $r('app.string.help_shortcut_format'))
      }
      .width('100%')
      .padding(12)
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .backgroundColor(`${this.currentTheme.colors.surface}DD`)
      .backdropBlur(20)
      .borderRadius(16)
      .border({ width: 1, color: `${this.currentTheme.colors.border}60` })
      .shadow({
        radius: 16,
        color: `${this.currentTheme.colors.primary}15`,
        offsetX: 0,
        offsetY: 4
      })
    }
    .width('100%')
  }

  @Builder
  buildGestures() {
    Column() {
      this.buildSectionTitle($r('app.string.help_gestures'))
      Column({ space: 8 }) {
        this.buildBullet($r('app.string.help_gesture_left'))
        this.buildBullet($r('app.string.help_gesture_right'))
      }
      .width('100%')
      .padding(12)
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .backgroundColor(`${this.currentTheme.colors.surface}DD`)
      .backdropBlur(20)
      .borderRadius(16)
      .border({ width: 1, color: `${this.currentTheme.colors.border}60` })
      .shadow({
        radius: 16,
        color: `${this.currentTheme.colors.primary}15`,
        offsetX: 0,
        offsetY: 4
      })
    }
    .width('100%')
  }

  @Builder
  buildTips() {
    Column() {
      this.buildSectionTitle($r('app.string.help_tips'))
      Column({ space: 8 }) {
        this.buildBullet($r('app.string.help_tip_1'))
        this.buildBullet($r('app.string.help_tip_2'))
        this.buildBullet($r('app.string.help_tip_3'))
      }
      .width('100%')
      .padding(12)
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .backgroundColor(`${this.currentTheme.colors.surface}DD`)
      .backdropBlur(20)
      .borderRadius(16)
      .border({ width: 1, color: `${this.currentTheme.colors.border}60` })
      .shadow({
        radius: 16,
        color: `${this.currentTheme.colors.primary}15`,
        offsetX: 0,
        offsetY: 4
      })
    }
    .width('100%')
  }

  @Builder
  buildBullet(text: ResourceStr) {
    Row({ space: 8 }) {
      Text('•')
        .fontSize(14)
        .fontColor(this.currentTheme.colors.primary)
      Text(text)
        .fontSize(14)
        .fontColor(this.currentTheme.colors.text)
        .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  buildKeyRow(keyText: string, desc: ResourceStr) {
    Row({ space: 12 }) {
      Text(keyText)
        .fontSize(12)
        .fontColor(this.currentTheme.colors.text)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
        .backgroundColor(this.currentTheme.editor.background)
        .backdropBlur(10)
        .borderRadius(8)
        .border({ width: 1, color: this.currentTheme.colors.border })
      Text(desc)
        .fontSize(13)
        .fontColor(this.currentTheme.colors.textSecondary)
        .layoutWeight(1)
    }
    .width('100%')
  }
}
