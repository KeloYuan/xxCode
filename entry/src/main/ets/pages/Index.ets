/**
 * 元代码 启动欢迎页
 * 符合 HarmonyOS Design 规范的现代化欢迎界面
 * 只在首次启动时显示
 */
import { router, curves } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BreakpointService, Breakpoint, ResponsiveUtils } from '../services/BreakpointService';

@Entry
@Component
struct Index {
  // 页面转场动画 - 统一的滑动效果
  pageTransition() {
    PageTransitionEnter({ duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
  @State private currentStep: number = 0;
  @State private currentBreakpoint: Breakpoint = 'sm';
  @State private isLoading: boolean = true;
  // 获取避让区高度
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  
  private breakpointService: BreakpointService = BreakpointService.getInstance();
  private context: common.UIAbilityContext | null = null;

  async aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    
    // 检查是否已看过欢迎页
    try {
      const dataPreferences = await preferences.getPreferences(this.context, 'user_settings');
      const welcomed = await dataPreferences.get('welcome_shown', false);
      
      if (welcomed) {
        // 已看过欢迎页，直接跳转到编辑器
        router.pushUrl({ url: 'pages/CodeEditor' }, router.RouterMode.Single);
        return;
      }
    } catch (err) {
      console.error('读取首选项失败:', JSON.stringify(err));
    }
    
    this.isLoading = false;
    
    // 注册断点系统
    this.breakpointService.register();
    this.currentBreakpoint = this.breakpointService.getCurrentBreakpoint();
    
    this.breakpointService.onChange((breakpoint: Breakpoint) => {
      this.currentBreakpoint = breakpoint;
    });
    
    // 启动动画
    setTimeout(() => {
      this.animateSteps();
    }, 100);
  }

  aboutToDisappear() {
    this.breakpointService.unregister();
  }
  
  private async markWelcomeShown() {
    try {
      if (this.context) {
        const dataPreferences = await preferences.getPreferences(this.context, 'user_settings');
        await dataPreferences.put('welcome_shown', true);
        await dataPreferences.flush();
      }
    } catch (err) {
      console.error('保存首选项失败:', JSON.stringify(err));
    }
  }

  private animateSteps() {
    const delays = [0, 200, 500, 800];
    for (let i = 0; i <= 3; i++) {
      setTimeout(() => {
        this.currentStep = i;
      }, delays[i]);
    }
  }

  build() {
    Stack() {
      // === 简洁渐变背景 ===
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 145,
          colors: [
            ['#1a1a2e', 0.0],
            ['#16213e', 0.5],
            ['#0f3460', 1.0]
          ]
        })

      // === 微妙的光晕效果 ===
      Circle()
        .width(400)
        .height(400)
        .fill('rgba(99, 102, 241, 0.08)')
        .position({ x: '70%', y: '15%' })
        .blur(100)

      if (this.isLoading) {
        // 加载中显示
        LoadingProgress()
          .width(64)
          .height(64)
          .color(Color.White)
      } else {
        // 主内容区
        this.buildMainContent()
      }
    }
    .width('100%')
    .height('100%')
    // 将背景延伸到状态栏和导航栏区域，实现沉浸式效果
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildMainContent(): void {
    Scroll() {
      Column() {
        // Logo 和标题区
        this.buildHeroSection()
        
        // 特性卡片网格
        this.buildFeatureGrid()
        
        // 行动召唤按钮
        this.buildCTASection()
      }
      .width('100%')
      .padding({ 
        left: ResponsiveUtils.getMargin(), 
        right: ResponsiveUtils.getMargin(), 
        // 顶部padding考虑状态栏高度（px转vp近似值）
        top: this.topRectHeight / 3 + (this.breakpointService.isLargeScreen() ? 40 : 30), 
        // 底部padding考虑导航栏高度
        bottom: this.bottomRectHeight / 3 + 30 
      })
      .constraintSize({ 
        maxWidth: this.breakpointService.isDesktop() ? 1400 : 1200 
      })
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  buildHeroSection(): void {
    Column({ space: 20 }) {
      // Logo 图片
      Image($r('app.media.app_logo'))
        .width(this.breakpointService.isPhone() ? 100 : 120)
        .height(this.breakpointService.isPhone() ? 100 : 120)
        .objectFit(ImageFit.Cover)
        .borderRadius(28)
        .clip(true)
        .shadow({
          radius: 40,
          color: 'rgba(99, 102, 241, 0.3)',
          offsetY: 0
        })
        .scale({ x: this.currentStep >= 0 ? 1 : 0.85, y: this.currentStep >= 0 ? 1 : 0.85 })
        .opacity(this.currentStep >= 0 ? 1 : 0)
        .animation({
          duration: 800,
          curve: curves.springMotion(0.7, 0.95),
          delay: 200
        })
        .margin({ bottom: 28 })

      // 主标题
      Text('元代码')
        .fontSize(this.breakpointService.isPhone() ? 36 : 44)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .letterSpacing(4)
        .scale({ x: this.currentStep >= 1 ? 1 : 0.95, y: this.currentStep >= 1 ? 1 : 0.95 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 700,
          curve: curves.springMotion(0.7, 0.95),
          delay: 350
        })

      // 副标题
      Text($r('app.string.app_slogan'))
        .fontSize(this.breakpointService.isPhone() ? 14 : 16)
        .fontColor('rgba(255, 255, 255, 0.65)')
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .letterSpacing(1)
        .scale({ x: this.currentStep >= 1 ? 1 : 0.95, y: this.currentStep >= 1 ? 1 : 0.95 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 700,
          curve: curves.springMotion(0.7, 0.95),
          delay: 420
        })
    }
    .width('100%')
    .margin({ bottom: 60 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildFeatureGrid(): void {
    GridRow({
      columns: { xs: 4, sm: 4, md: 8, lg: 12, xl: 12 },
      gutter: { x: ResponsiveUtils.getGutter(), y: ResponsiveUtils.getGutter() }
    }) {
      GridCol({ span: { xs: 4, sm: 2, md: 4, lg: 3, xl: 3 } }) {
        this.buildFeatureCard('⚡', $r('app.string.feature_fast_title'), $r('app.string.feature_fast_desc'), 0)
      }
      GridCol({ span: { xs: 4, sm: 2, md: 4, lg: 3, xl: 3 } }) {
        this.buildFeatureCard('🎨', $r('app.string.feature_highlight_title'), $r('app.string.feature_highlight_desc'), 1)
      }
      GridCol({ span: { xs: 4, sm: 2, md: 4, lg: 3, xl: 3 } }) {
        this.buildFeatureCard('📁', $r('app.string.feature_files_title'), $r('app.string.feature_files_desc'), 2)
      }
      GridCol({ span: { xs: 4, sm: 2, md: 4, lg: 3, xl: 3 } }) {
        this.buildFeatureCard('🌙', $r('app.string.feature_themes_title'), $r('app.string.feature_themes_desc'), 3)
      }
    }
    .width('100%')
    .margin({ bottom: 48 })
  }

  @Builder
  buildFeatureCard(icon: string, title: ResourceStr, description: ResourceStr, index: number): void {
    Column() {
      // 简洁图标
      Text(icon)
        .fontSize(40)
        .margin({ bottom: 16 })

      Text(title)
        .fontSize(ResponsiveUtils.getFontSize({ xs: 16, sm: 17, md: 18, lg: 18, xl: 19 }))
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .margin({ bottom: 8 })

      Text(description)
        .fontSize(ResponsiveUtils.getFontSize({ xs: 12, sm: 13, md: 13, lg: 14, xl: 14 }))
        .fontColor('rgba(255, 255, 255, 0.6)')
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .lineHeight(20)
        .padding({ left: 8, right: 8 })
    }
    .width('100%')
    .height(this.breakpointService.isPhone() ? 160 : 170)
    .padding(this.breakpointService.isPhone() ? 20 : 24)
    .backgroundColor('rgba(255, 255, 255, 0.05)')
    .backdropBlur(10)
    .borderRadius(20)
    .border({
      width: 1,
      color: 'rgba(255, 255, 255, 0.08)'
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .scale({ x: this.currentStep >= 2 ? 1 : 0.92, y: this.currentStep >= 2 ? 1 : 0.92 })
    .opacity(this.currentStep >= 2 ? 1 : 0)
    .translate({ y: this.currentStep >= 2 ? 0 : 20 })
    .animation({
      duration: 700,
      curve: curves.springMotion(0.7, 0.95),
      delay: 500 + index * 80
    })
  }

  @Builder
  buildCTASection(): void {
    Column({ space: 24 }) {
      // 主按钮 - 简洁设计
      Button({ type: ButtonType.Normal }) {
        Row({ space: 10 }) {
          Text($r('app.string.btn_start_coding'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)

          Text('→')
            .fontSize(14)
        }
      }
      .width(this.breakpointService.isPhone() ? '80%' : 280)
      .height(52)
      .backgroundColor('rgba(255, 255, 255, 0.95)')
      .fontColor('#1a1a2e')
      .borderRadius(26)
      .shadow({
        radius: 20,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetY: 6
      })
      .scale({ x: this.currentStep >= 3 ? 1 : 0.92, y: this.currentStep >= 3 ? 1 : 0.92 })
      .opacity(this.currentStep >= 3 ? 1 : 0)
      .animation({
        duration: 700,
        curve: curves.springMotion(0.7, 0.95),
        delay: 800
      })
      .stateEffect(true)
      .onClick(async () => {
        await this.markWelcomeShown();
        router.pushUrl({
          url: 'pages/CodeEditor'
        }, router.RouterMode.Single);
      })

      // 底部信息
      Row({ space: 16 }) {
        Text('v4.0.0')
          .fontSize(11)
          .fontColor('rgba(255, 255, 255, 0.4)')

        Text('•')
          .fontSize(11)
          .fontColor('rgba(255, 255, 255, 0.3)')

        Text('鸿蒙原生')
          .fontSize(11)
          .fontColor('rgba(255, 255, 255, 0.4)')

        Text('•')
          .fontSize(11)
          .fontColor('rgba(255, 255, 255, 0.3)')

        Text('开源')
          .fontSize(11)
          .fontColor('rgba(255, 255, 255, 0.4)')
      }
      .opacity(this.currentStep >= 3 ? 0.7 : 0)
      .animation({
        duration: 700,
        curve: curves.springMotion(0.7, 0.95),
        delay: 950
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
