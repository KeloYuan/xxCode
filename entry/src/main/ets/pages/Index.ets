/**
 * 元代码 启动欢迎页
 * 符合 HarmonyOS Design 规范的现代化欢迎界面
 * 只在首次启动时显示
 */
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BreakpointService, Breakpoint, ResponsiveUtils } from '../services/BreakpointService';

class FeatureCardData {
  public icon: string;
  public title: string;
  public description: string;
  
  constructor(icon: string, title: string, description: string) {
    this.icon = icon;
    this.title = title;
    this.description = description;
  }
}

@Entry
@Component
struct Index {
  // 页面转场动画配置
  pageTransition() {
    // 进入动画：从右侧滑入
    PageTransitionEnter({ duration: 350, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    // 退出动画：向左侧滑出
    PageTransitionExit({ duration: 350, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
  }
  @State private currentStep: number = 0;
  @State private currentBreakpoint: Breakpoint = 'sm';
  @State private isLoading: boolean = true;
  // 获取避让区高度
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  
  private breakpointService: BreakpointService = BreakpointService.getInstance();
  private context: common.UIAbilityContext | null = null;
  
  // 特性卡片数据
  private features: Array<FeatureCardData> = [
    new FeatureCardData('⚡', '极速启动', '毫秒级启动，流畅编辑体验'),
    new FeatureCardData('🎨', '语法高亮', '支持多种编程语言高亮'),
    new FeatureCardData('📁', '文件管理', '强大的文件浏览和管理'),
    new FeatureCardData('🌙', '多主题', '深色/浅色/Monokai/Dracula')
  ];

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
      // 渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            ['#667eea', 0.0],
            ['#764ba2', 1.0]
          ]
        })

      if (this.isLoading) {
        // 加载中显示
        LoadingProgress()
          .width(48)
          .height(48)
          .color(Color.White)
      } else {
        // 装饰性圆形
        Circle()
          .width(300)
          .height(300)
          .fill('rgba(255, 255, 255, 0.1)')
          .position({ x: '80%', y: '10%' })
          .blur(50)

        Circle()
          .width(200)
          .height(200)
          .fill('rgba(255, 255, 255, 0.08)')
          .position({ x: '10%', y: '70%' })
          .blur(40)

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
    Column({ space: 16 }) {
      // Logo 符号
      Column() {
        Text('<>')
          .fontSize(48)
          .fontColor('rgba(255, 255, 255, 0.95)')
          .fontWeight(FontWeight.Bold)
          .fontFamily('SF Mono, Monaco, Menlo, Consolas, monospace')
          .scale({ x: this.currentStep >= 0 ? 1 : 0.3, y: this.currentStep >= 0 ? 1 : 0.3 })
          .opacity(this.currentStep >= 0 ? 1 : 0)
          .rotate({ angle: this.currentStep >= 0 ? 0 : 180 })
          .animation({
            duration: 800,
            curve: Curve.Friction,
            delay: 200
          })
      }
      .margin({ bottom: 40 })

      // 主标题
      Text('元代码')
        .fontSize(this.breakpointService.isPhone() ? 32 : 42)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .scale({ x: this.currentStep >= 1 ? 1 : 0.9, y: this.currentStep >= 1 ? 1 : 0.9 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 600,
          curve: Curve.EaseOut,
          delay: 400
        })

      // 副标题
      Text('现代化 · 轻量级 · 高效')
        .fontSize(this.breakpointService.isPhone() ? 15 : 18)
        .fontColor('rgba(255, 255, 255, 0.85)')
        .textAlign(TextAlign.Center)
        .letterSpacing(2)
        .scale({ x: this.currentStep >= 1 ? 1 : 0.9, y: this.currentStep >= 1 ? 1 : 0.9 })
        .opacity(this.currentStep >= 1 ? 1 : 0)
        .animation({
          duration: 600,
          curve: Curve.EaseOut,
          delay: 500
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
      ForEach(this.features, (feature: FeatureCardData, index: number) => {
        GridCol({ span: { xs: 4, sm: 2, md: 4, lg: 3, xl: 3 } }) {
          this.buildFeatureCard(feature.icon, feature.title, feature.description, index)
        }
      }, (feature: FeatureCardData) => feature.title)
    }
    .width('100%')
    .margin({ bottom: 48 })
  }

  @Builder
  buildFeatureCard(icon: string, title: string, description: string, index: number): void {
    Column() {
      Text(icon)
        .fontSize(this.breakpointService.isPhone() ? 32 : 40)
        .margin({ bottom: 16 })

      Text(title)
        .fontSize(ResponsiveUtils.getFontSize({ xs: 15, sm: 16, md: 17, lg: 18, xl: 19 }))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 8 })

      Text(description)
        .fontSize(ResponsiveUtils.getFontSize({ xs: 12, sm: 13, md: 14, lg: 14, xl: 15 }))
        .fontColor('rgba(255, 255, 255, 0.7)')
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .lineHeight(20)
    }
    .width('100%')
    .height(this.breakpointService.isPhone() ? 140 : 160)
    .padding(this.breakpointService.isPhone() ? 20 : 24)
    .backgroundColor('rgba(255, 255, 255, 0.12)')
    .backdropBlur(20)
    .borderRadius(this.breakpointService.isLargeScreen() ? 24 : 20)
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
    .scale({ x: this.currentStep >= 2 ? 1 : 0.85, y: this.currentStep >= 2 ? 1 : 0.85 })
    .opacity(this.currentStep >= 2 ? 1 : 0)
    .translate({ y: this.currentStep >= 2 ? 0 : 20 })
    .animation({
      duration: 600,
      curve: Curve.Friction,
      delay: 600 + index * 100
    })

  }

  @Builder
  buildCTASection(): void {
    Column({ space: 16 }) {
      // 主按钮
      Button({ type: ButtonType.Normal }) {
        Row() {
          Text('✏️')
            .fontSize(20)
            .margin({ right: 8 })
          
          Text('开始编码')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
        }
      }
      .width(this.breakpointService.isPhone() ? '100%' : 280)
      .height(56)
      .backgroundColor('rgba(255, 255, 255, 0.95)')
      .borderRadius(28)
      .shadow({
        radius: 25,
        color: 'rgba(0, 0, 0, 0.2)',
        offsetX: 0,
        offsetY: 12
      })
      .scale({ x: this.currentStep >= 3 ? 1 : 0.9, y: this.currentStep >= 3 ? 1 : 0.9 })
      .opacity(this.currentStep >= 3 ? 1 : 0)
      .animation({
        duration: 600,
        curve: Curve.EaseOut,
        delay: 1000
      })
      .onClick(async () => {
        await this.markWelcomeShown();
        // 使用 pushUrl 触发转场动画
        router.pushUrl({ 
          url: 'pages/CodeEditor'
        }, router.RouterMode.Single);
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
