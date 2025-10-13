/**
 * 欢迎引导组件
 * 首次启动时显示的引导教程
 */
import { ThemeService, Theme } from '../services/ThemeService';
import { CommonConstants } from '../common/CommonConstants';

interface GuideStep {
  title: string;
  description: string;
  icon: string;
}

@Component
export struct WelcomeGuide {
  @Prop visible: boolean = false;
  onClose: () => void = () => {};
  
  @State currentStep: number = 0;
  @State private currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  
  private themeService: ThemeService = ThemeService.getInstance();
  private steps: GuideStep[] = [
    {
      title: '欢迎使用 xxCode',
      description: '一款现代化的鸿蒙代码编辑器，支持多种编程语言的语法高亮和智能编辑。',
      icon: '👋'
    },
    {
      title: '打开文件',
      description: '点击右上角的"打开"按钮，选择您想要编辑的代码文件。支持 JS、TS、Python、Java 等多种语言。',
      icon: '📁'
    },
    {
      title: '语法高亮',
      description: '编辑器会自动识别文件类型，提供语法高亮和代码着色，让代码更易读。',
      icon: '🎨'
    },
    {
      title: '多主题切换',
      description: '点击右上角的主题按钮，可以切换不同的主题风格，包括深色、浅色、Monokai 和 Dracula。',
      icon: '🌙'
    },
    {
      title: '开始编码',
      description: '现在您可以开始编写代码了！编辑器支持自动保存、搜索替换等强大功能。',
      icon: '🚀'
    }
  ];

  aboutToAppear() {
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  build() {
    if (this.visible) {
      Stack() {
        // 半透明背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            // 点击背景不关闭
          })

        // 引导卡片
        Column({ space: 24 }) {
          // 进度指示器
          Row({ space: 8 }) {
            ForEach(this.steps, (step: GuideStep, index: number) => {
              Circle()
                .width(8)
                .height(8)
                .fill(index === this.currentStep ? 
                  this.currentTheme.colors.primary : 
                  this.currentTheme.colors.border)
                .animation({
                  duration: 300,
                  curve: Curve.EaseOut
                })
            }, (step: GuideStep, index: number) => `${index}`)
          }
          .justifyContent(FlexAlign.Center)

          // 当前步骤内容
          Column({ space: 16 }) {
            Text(this.steps[this.currentStep].icon)
              .fontSize(48)

            Text(this.steps[this.currentStep].title)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentTheme.colors.text)
              .textAlign(TextAlign.Center)

            Text(this.steps[this.currentStep].description)
              .fontSize(15)
              .fontColor(this.currentTheme.colors.textSecondary)
              .textAlign(TextAlign.Center)
              .lineHeight(24)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })

          // 按钮组
          Row({ space: 12 }) {
            if (this.currentStep > 0) {
              Button('上一步')
                .fontSize(15)
                .backgroundColor(this.currentTheme.colors.surface)
                .fontColor(this.currentTheme.colors.text)
                .layoutWeight(1)
                .onClick(() => {
                  if (this.currentStep > 0) {
                    this.currentStep--;
                  }
                })
            }

            Button(this.currentStep === this.steps.length - 1 ? '开始使用' : '下一步')
              .fontSize(15)
              .backgroundColor(this.currentTheme.colors.primary)
              .fontColor(Color.White)
              .layoutWeight(1)
              .onClick(() => {
                if (this.currentStep < this.steps.length - 1) {
                  this.currentStep++;
                } else {
                  this.onClose();
                }
              })
          }
          .width('100%')
        }
        .width('90%')
        .constraintSize({ maxWidth: 480 })
        .padding(28)
        .backgroundColor(this.currentTheme.colors.background)
        .borderRadius(20)
        .shadow({
          radius: 40,
          color: 'rgba(0, 0, 0, 0.2)',
          offsetX: 0,
          offsetY: 15
        })
        .scale({ 
          x: this.visible ? 1 : 0.9, 
          y: this.visible ? 1 : 0.9 
        })
        .opacity(this.visible ? 1 : 0)
        .animation({
          duration: 400,
          curve: Curve.Friction,
          delay: 100
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}

