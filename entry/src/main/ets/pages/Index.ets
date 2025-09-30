import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State private isLoading: boolean = false;
  @State private showContent: boolean = false;
  @State private currentStep: number = 0;

  aboutToAppear() {
    // 阶梯式动画
    setTimeout(() => {
      this.showContent = true;
      this.animateSteps();
    }, 200);
  }

  private animateSteps() {
    for (let i = 0; i <= 3; i++) {
      setTimeout(() => {
        this.currentStep = i;
      }, i * 150);
    }
  }

  build() {
    Navigation() {
      Stack() {
        // 现代化渐变背景
        this.buildModernBackground()
        
        // 主内容区域
        this.buildMainContent()

        // 加载遮罩
        if (this.isLoading) {
          this.buildLoadingOverlay()
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
  }

  @Builder
  buildModernBackground(): void {
    Stack() {
      // 基础渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            [$r('app.color.gradient_start'), 0.0],
            [$r('app.color.gradient_end'), 1.0]
          ]
        })
      
      // 装饰性几何元素
      Stack() {
        // 大圆形装饰
        Circle()
          .width(400)
          .height(400)
          .fill('rgba(255, 255, 255, 0.08)')
          .position({ x: '70%', y: '10%' })
          .blur(60)

        Circle()
          .width(300)
          .height(300)
          .fill('rgba(255, 255, 255, 0.05)')
          .position({ x: '-10%', y: '60%' })
          .blur(50)

        // 渐变装饰条
        Column()
          .width(200)
          .height(200)
          .rotate({ angle: 45 })
          .position({ x: '85%', y: '75%' })
          .linearGradient({
            angle: 45,
            colors: [
              ['rgba(255, 255, 255, 0.1)', 0.0],
              ['rgba(255, 255, 255, 0)', 1.0]
            ]
          })
          .blur(30)
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  buildMainContent(): void {
    Scroll() {
      Column() {
        // Logo 和主标题区
        this.buildHeroSection()
        
        // 特性卡片
        this.buildFeatureGrid()
        
        // 行动召唤按钮
        this.buildCTASection()
      }
      .width('100%')
      .padding({ left: 32, right: 32, top: 80, bottom: 60 })
      .constraintSize({ maxWidth: 1200 })
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  buildHeroSection(): void {
    Column() {
      // Logo 图标
      Stack() {
        // 外圈光晕
        Circle()
          .width(140)
          .height(140)
          .fill('rgba(255, 255, 255, 0.1)')
          .blur(20)
          .scale({ x: this.currentStep >= 0 ? 1 : 0.5, y: this.currentStep >= 0 ? 1 : 0.5 })
          .opacity(this.currentStep >= 0 ? 1 : 0)
          .animation({
            duration: 600,
            curve: Curve.EaseOut
          })

        // 主圆形背景
        Circle()
          .width(120)
          .height(120)
          .fill('rgba(255, 255, 255, 0.15)')
          .backdropBlur(30)
          .border({
            width: 2,
            color: 'rgba(255, 255, 255, 0.3)'
          })
          .scale({ x: this.currentStep >= 0 ? 1 : 0.8, y: this.currentStep >= 0 ? 1 : 0.8 })
          .opacity(this.currentStep >= 0 ? 1 : 0)
          .animation({
            duration: 600,
            curve: Curve.Friction,
            delay: 100
          })

        // Logo 符号
        Text('<>')
          .fontSize(48)
          .fontColor('rgba(255, 255, 255, 0.95)')
          .fontWeight(FontWeight.Bold)
          .fontFamily('SF Mono, Monaco, Consolas, monospace')
          .scale({ x: this.currentStep >= 0 ? 1 : 0.5, y: this.currentStep >= 0 ? 1 : 0.5 })
          .opacity(this.currentStep >= 0 ? 1 : 0)
          .animation({
            duration: 600,
            curve: Curve.Friction,
            delay: 200
          })
      }
      .margin({ bottom: 40 })

      // 主标题
      Text('鸿蒙代码编辑器')
        .fontSize(42)
        .fontWeight(900)
        .fontColor(Color.White)
        .letterSpacing(1)
        .margin({ bottom: 16 })
        .textShadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.2)',
          offsetX: 0,
          offsetY: 4
        })
        .scale({ x: this.currentStep >= 1 ? 1 : 0.95, y: this.currentStep >= 1 ? 1 : 0.95 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 500,
          curve: Curve.EaseOut,
          delay: 300
        })

      // 副标题
      Text('现代化 · 轻量级 · 强大')
        .fontSize(18)
        .fontColor('rgba(255, 255, 255, 0.85)')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 500,
          curve: Curve.EaseOut,
          delay: 400
        })

      Text('为 HarmonyOS 打造的专业代码编辑体验')
        .fontSize(16)
        .fontColor('rgba(255, 255, 255, 0.7)')
        .margin({ bottom: 60 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 500,
          curve: Curve.EaseOut,
          delay: 500
        })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildFeatureGrid(): void {
    Grid() {
      GridItem() {
        this.buildFeatureCard('⚡', '极速启动', '毫秒级启动，流畅编辑', 0)
      }
      
      GridItem() {
        this.buildFeatureCard('🎨', '语法高亮', '多语言语法高亮支持', 1)
      }
      
      GridItem() {
        this.buildFeatureCard('📁', '文件管理', '强大的文件浏览器', 2)
      }
      
      GridItem() {
        this.buildFeatureCard('🌙', '主题切换', '深色/浅色主题自由切换', 3)
      }
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('1fr 1fr')
    .columnsGap(16)
    .rowsGap(16)
    .width('100%')
    .height(360)
    .margin({ bottom: 48 })
  }

  @Builder
  buildFeatureCard(icon: string, title: string, description: string, index: number): void {
    Column() {
      Text(icon)
        .fontSize(36)
        .margin({ bottom: 16 })

      Text(title)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 8 })

      Text(description)
        .fontSize(13)
        .fontColor('rgba(255, 255, 255, 0.7)')
        .textAlign(TextAlign.Center)
        .maxLines(2)
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor('rgba(255, 255, 255, 0.12)')
    .backdropBlur(20)
    .borderRadius(20)
    .border({
      width: 1,
      color: 'rgba(255, 255, 255, 0.2)'
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .shadow({
      radius: 20,
      color: 'rgba(0, 0, 0, 0.15)',
      offsetX: 0,
      offsetY: 10
    })
    .scale({ x: this.currentStep >= 2 ? 1 : 0.9, y: this.currentStep >= 2 ? 1 : 0.9 })
    .opacity(this.currentStep >= 2 ? 1 : 0)
      .animation({
        duration: 500,
        curve: Curve.Friction,
        delay: 600 + index * 100
      })
  }

  @Builder
  buildCTASection(): void {
    Column() {
      // 主按钮
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('开始编码')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_inverse'))
            .margin({ right: 12 })
          
          Text('→')
            .fontSize(20)
            .fontColor($r('app.color.text_inverse'))
        }
      }
      .width(280)
      .height(60)
      .backgroundColor(Color.White)
      .borderRadius(30)
      .shadow({
        radius: 30,
        color: 'rgba(255, 255, 255, 0.3)',
        offsetX: 0,
        offsetY: 15
      })
      .margin({ bottom: 20 })
      .scale({ x: this.currentStep >= 3 ? 1 : 0.9, y: this.currentStep >= 3 ? 1 : 0.9 })
      .opacity(this.currentStep >= 3 ? 1 : 0)
      .animation({
        duration: 500,
        curve: Curve.Friction,
        delay: 900
      })
      .onClick(() => {
        this.navigateToEditor();
      })

      // 次要按钮
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('📖')
            .fontSize(16)
            .margin({ right: 8 })
          
          Text('了解更多')
            .fontSize(15)
            .fontColor('rgba(255, 255, 255, 0.9)')
        }
      }
      .width(200)
      .height(50)
      .backgroundColor('rgba(255, 255, 255, 0.15)')
      .backdropBlur(10)
      .borderRadius(25)
      .border({
        width: 1.5,
        color: 'rgba(255, 255, 255, 0.3)'
      })
      .scale({ x: this.currentStep >= 3 ? 1 : 0.9, y: this.currentStep >= 3 ? 1 : 0.9 })
      .opacity(this.currentStep >= 3 ? 1 : 0)
      .animation({
        duration: 500,
        curve: Curve.Friction,
        delay: 1000
      })
      .onClick(() => {
        this.showFeatureDetails();
      })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildLoadingOverlay(): void {
    Column() {
      // 加载动画
      Stack() {
        Circle()
          .width(80)
          .height(80)
          .fill('rgba(255, 255, 255, 0.2)')
          .backdropBlur(20)
        
        LoadingProgress()
          .width(50)
          .height(50)
          .color(Color.White)
      }
      .margin({ bottom: 24 })

      Text('正在启动编辑器...')
        .fontSize(17)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(99, 102, 241, 0.95)')
    .backdropBlur(30)
  }

  private async navigateToEditor() {
    this.isLoading = true;

    setTimeout(() => {
      try {
        router.pushUrl(
          {
            url: 'pages/CodeEditor'
          },
          router.RouterMode.Standard,
          (err) => {
            if (err) {
              console.error('导航失败:', err);
            }
            this.isLoading = false;
          }
        );
      } catch (error) {
        console.error('导航异常:', error);
        this.isLoading = false;
      }
    }, 800);
  }

  private showFeatureDetails() {
    console.log('显示功能详情');
    // TODO: 实现功能详情对话框
  }
}