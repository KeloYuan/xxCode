import router from '@ohos.router';
import { NavigationTitleMode } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State private isLoading: boolean = false;
  @State private showWelcome: boolean = false;

  aboutToAppear() {
    // 添加启动动画延迟
    setTimeout(() => {
      this.showWelcome = true;
    }, 300);
  }

  build() {
    Navigation() {
      Stack() {
        this.buildGradientBackground()
        this.buildLandingContent()

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .color($r('app.color.primary_brand'))
              .margin({ bottom: 16 })

            Text('正在启动编辑器...')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(255, 255, 255, 0.9)')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background_secondary'))
    }
    .title($r('app.string.index_page_title'))
    .titleMode(NavigationTitleMode.Mini)
  }

  @Builder
  private buildGradientBackground(): void {
    Column()
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 135,
        colors: [
          ['#F0F9FF', 0.0],
          ['#E0F2FE', 0.3],
          ['#BAE6FD', 0.7],
          ['#7DD3FC', 1.0]
        ]
      })
  }

  @Builder
  private buildLandingContent(): void {
    Scroll() {
      Column() {
        this.buildHeroSection()
        this.buildFeatureCards()
        this.buildCallToAction()
      }
      .padding({ left: 24, right: 24, top: 60, bottom: 60 })
      .width('100%')
      .maxWidth(780)
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHeroSection(): void {
    Column() {
      Stack() {
        Circle()
          .width(120)
          .height(120)
          .fill($r('app.color.primary_brand'))
          .shadow({
            radius: 20,
            color: 'rgba(0, 125, 255, 0.3)',
            offsetX: 0,
            offsetY: 8
          })

        Text('{ }')
          .fontSize(48)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .fontFamily('SF Pro Display, -apple-system, system-ui')
      }
      .margin({ bottom: 32 })
      .scale({ x: this.showWelcome ? 1 : 0.8, y: this.showWelcome ? 1 : 0.8 })
      .opacity(this.showWelcome ? 1 : 0)
      .animation({
        duration: 800,
        curve: Curve.EaseInOut,
        playMode: PlayMode.Normal
      })

      Text('鸿蒙代码编辑器')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .fontFamily('PingFang SC, Microsoft YaHei')
        .margin({ bottom: 12 })
        .scale({ x: this.showWelcome ? 1 : 0.9, y: this.showWelcome ? 1 : 0.9 })
        .opacity(this.showWelcome ? 1 : 0)
        .animation({
          duration: 800,
          curve: Curve.EaseInOut,
          delay: 200,
          playMode: PlayMode.Normal
        })

      Text('专业的原生代码编辑体验')
        .fontSize(18)
        .fontColor($r('app.color.text_secondary'))
        .fontFamily('PingFang SC, Microsoft YaHei')
        .margin({ bottom: 48 })
        .opacity(this.showWelcome ? 1 : 0)
        .animation({
          duration: 800,
          curve: Curve.EaseInOut,
          delay: 400,
          playMode: PlayMode.Normal
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildCallToAction(): void {
    Column() {
      Button({ type: ButtonType.Capsule, stateEffect: true }) {
        Row() {
          Text('🚀')
            .fontSize(20)
            .margin({ right: 12 })

          Text('开始编码')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width(280)
      .height(56)
      .backgroundColor($r('app.color.primary_brand'))
      .shadow({
        radius: 16,
        color: 'rgba(0, 125, 255, 0.4)',
        offsetX: 0,
        offsetY: 8
      })
      .margin({ bottom: 16 })
      .scale({ x: this.showWelcome ? 1 : 0.95, y: this.showWelcome ? 1 : 0.95 })
      .opacity(this.showWelcome ? 1 : 0)
      .animation({
        duration: 800,
        curve: Curve.EaseInOut,
        delay: 800,
        playMode: PlayMode.Normal
      })
      .accessibilityText('开始编码按钮')
      .onClick(() => {
        this.navigateToEditor();
      })

      Button({ type: ButtonType.Capsule, stateEffect: true }) {
        Row() {
          Text('📚')
            .fontSize(16)
            .margin({ right: 8 })

          Text('查看功能')
            .fontSize(16)
            .fontColor($r('app.color.primary_brand'))
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width(200)
      .height(48)
      .backgroundColor($r('app.color.background_primary'))
      .border({
        width: 1,
        color: $r('app.color.border_light')
      })
      .borderRadius(24)
      .scale({ x: this.showWelcome ? 1 : 0.95, y: this.showWelcome ? 1 : 0.95 })
      .opacity(this.showWelcome ? 1 : 0)
      .animation({
        duration: 800,
        curve: Curve.EaseInOut,
        delay: 900,
        playMode: PlayMode.Normal
      })
      .accessibilityText('查看功能按钮')
      .onClick(() => {
        this.showFeatureIntro();
      })
    }
    .alignItems(HorizontalAlign.Center)
    .padding({ bottom: 48 })
  }

  @Builder
  buildFeatureCards(): void {
    Column() {
      Row() {
        this.buildFeatureCard('⚡', '高性能', '原生鸿蒙技术栈')
        Blank().width(16)
        this.buildFeatureCard('🎨', '现代设计', '鸿蒙设计语言')
        Blank().width(16)
        this.buildFeatureCard('🔧', '多功能', '代码高亮与预览')
      }
      .width('100%')
      .margin({ bottom: 32 })
    }
    .opacity(this.showWelcome ? 1 : 0)
    .animation({
      duration: 800,
      curve: Curve.EaseInOut,
      delay: 600,
      playMode: PlayMode.Normal
    })
  }

  @Builder
  buildFeatureCard(icon: string, title: string, description: string): void {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 12 })

      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 6 })

      Text(description)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
        .maxLines(2)
    }
    .layoutWeight(1)
    .padding(20)
    .backgroundColor($r('app.color.surface_elevated'))
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height(120)
  }

  private async navigateToEditor() {
    this.isLoading = true;

    // 模拟加载过程
    setTimeout(async () => {
      try {
        router.replaceUrl({
          url: 'pages/CodeEditor'
        });
      } catch (error) {
        console.error('导航失败:', error);
      } finally {
        this.isLoading = false;
      }
    }, 1000);
  }

  private showFeatureIntro() {
    // 这里可以显示功能介绍对话框或跳转到介绍页面
    console.log('显示功能介绍');
  }
}