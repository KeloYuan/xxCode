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
    const delays = [0, 200, 500, 900];
    for (let i = 0; i <= 3; i++) {
      setTimeout(() => {
        this.currentStep = i;
      }, delays[i]);
    }
  }

  build() {
    Stack() {
      // === 鸿蒙风格渐变背景 ===
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 145,
          colors: [
            ['#0A59F7', 0.0],    // 鸿蒙蓝
            ['#0091FF', 0.4],    // 天空蓝
            ['#5B8FF9', 0.7],    // 浅蓝
            ['#7C3AED', 1.0]     // 紫色点缀
          ]
        })
        .opacity(0.95)

      if (this.isLoading) {
        // 加载中显示
        LoadingProgress()
          .width(64)
          .height(64)
          .color(Color.White)
      } else {
        // 简化的装饰效果
        Circle()
          .width(300)
          .height(300)
          .fill('rgba(255, 255, 255, 0.08)')
          .position({ x: '80%', y: '10%' })
          .blur(60)

        Circle()
          .width(200)
          .height(200)
          .fill('rgba(255, 255, 255, 0.06)')
          .position({ x: '10%', y: '75%' })
          .blur(50)

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
    Column({ space: 24 }) {
      // Logo 符号 - 简化设计
      Column() {
        Text('<>')
          .fontSize(this.breakpointService.isPhone() ? 48 : 56)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .fontFamily('SF Mono, Monaco, Menlo, Consolas, monospace')
          .letterSpacing(2)
          .scale({ x: this.currentStep >= 0 ? 1 : 0.3, y: this.currentStep >= 0 ? 1 : 0.3 })
          .opacity(this.currentStep >= 0 ? 1 : 0)
          .rotate({ angle: this.currentStep >= 0 ? 0 : 180 })
          .animation({
            duration: 700,
            curve: curves.springMotion(0.6, 0.9),
            delay: 150
          })
      }
      .width(this.breakpointService.isPhone() ? 90 : 100)
      .height(this.breakpointService.isPhone() ? 90 : 100)
      .backgroundColor('rgba(255, 255, 255, 0.10)')
      .backdropBlur(15)
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 24 })

      // 主标题 - 简化
      Text($r('app.string.app_name'))
        .fontSize(this.breakpointService.isPhone() ? 36 : 44)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .letterSpacing(2)
        .scale({ x: this.currentStep >= 1 ? 1 : 0.9, y: this.currentStep >= 1 ? 1 : 0.9 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 700,
          curve: curves.springMotion(0.6, 0.9),
          delay: 350
        })

      // 副标题
      Text($r('app.string.app_slogan'))
        .fontSize(this.breakpointService.isPhone() ? 15 : 18)
        .fontColor('rgba(255, 255, 255, 0.85)')
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .letterSpacing(2)
        .scale({ x: this.currentStep >= 1 ? 1 : 0.9, y: this.currentStep >= 1 ? 1 : 0.9 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 700,
          curve: curves.springMotion(0.6, 0.9),
          delay: 450
        })
    }
    .width('100%')
    .margin({ bottom: 72 })
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
      // 图标 - 简化
      Text(icon)
        .fontSize(this.breakpointService.isPhone() ? 36 : 42)
        .margin({ bottom: 16 })

      Text(title)
        .fontSize(ResponsiveUtils.getFontSize({ xs: 16, sm: 17, md: 18, lg: 19, xl: 20 }))
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ bottom: 10 })

      Text(description)
        .fontSize(ResponsiveUtils.getFontSize({ xs: 13, sm: 14, md: 14, lg: 15, xl: 15 }))
        .fontColor('rgba(255, 255, 255, 0.75)')
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .lineHeight(22)
    }
    .width('100%')
    .height(this.breakpointService.isPhone() ? 170 : 190)
    .padding(this.breakpointService.isPhone() ? 24 : 28)
    .backgroundColor('rgba(255, 255, 255, 0.10)')
    .backdropBlur(30)
    .borderRadius(this.breakpointService.isLargeScreen() ? 24 : 20)
    .border({
      width: 1,
      color: 'rgba(255, 255, 255, 0.20)'
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .scale({ x: this.currentStep >= 2 ? 1 : 0.9, y: this.currentStep >= 2 ? 1 : 0.9 })
    .opacity(this.currentStep >= 2 ? 1 : 0)
    .translate({ y: this.currentStep >= 2 ? 0 : 20 })
    .animation({
      duration: 700,
      curve: curves.springMotion(0.6, 0.9),
      delay: 550 + index * 100
    })
  }

  @Builder
  buildCTASection(): void {
    Column({ space: 16 }) {
      // 主按钮 - 简化
      Button({ type: ButtonType.Normal }) {
        Row({ space: 10 }) {
          Text('✨')
            .fontSize(20)
          
          Text($r('app.string.btn_start_coding'))
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
        }
      }
      .width(this.breakpointService.isPhone() ? '80%' : 280)
      .height(56)
      .backgroundColor('#FFFFFF')
      .fontColor('#0A59F7')
      .borderRadius(28)
      .scale({ x: this.currentStep >= 3 ? 1 : 0.9, y: this.currentStep >= 3 ? 1 : 0.9 })
      .opacity(this.currentStep >= 3 ? 1 : 0)
      .animation({
        duration: 700,
        curve: curves.springMotion(0.6, 0.9),
        delay: 900
      })
      .stateEffect(true)
      .onClick(async () => {
        await this.markWelcomeShown();
        router.pushUrl({
          url: 'pages/CodeEditor'
        }, router.RouterMode.Single);
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
