/**
 * 欢迎页面组件
 * 无文件打开时显示的引导界面
 */
import { ThemeColors } from '../../models/EditorModels'
import { curves } from '@kit.ArkUI'

@Component
export struct WelcomeView {
  @Prop colors: ThemeColors

  onOpenFile: () => void = () => {}
  onOpenFolder: () => void = () => {}
  onNewFile: () => void = () => {}

  // 动画状态
  @State logoScale: number = 0.8
  @State logoOpacity: number = 0
  @State contentOffset: number = 30
  @State contentOpacity: number = 0

  aboutToAppear() {
    // 入场动画 - 使用延迟和直接赋值触发动画
    setTimeout(() => {
      this.logoScale = 1
      this.logoOpacity = 1
    }, 100)

    setTimeout(() => {
      this.contentOffset = 0
      this.contentOpacity = 1
    }, 250)
  }

  build() {
    Stack() {
      // 渐变背景装饰
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            [this.colors.editorBg, 0.0],
            [this.colors.primary + '08', 0.5],
            [this.colors.editorBg, 1.0]
          ]
        })

      Column({ space: 24 }) {
        Blank().layoutWeight(1)

        // Logo 带光晕效果
        Column({ space: 12 }) {
          Stack() {
            // 光晕
            Circle()
              .width(100)
              .height(100)
              .fill(this.colors.primary + '20')
              .blur(30)

            Text('⌘')
              .fontSize(64)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.colors.primary)
          }

          Text('xxCode')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.textPrimary)
            .letterSpacing(1)

          Text('专业的鸿蒙原生代码编辑器')
            .fontSize(14)
            .fontColor(this.colors.textSecondary)
        }
        .scale({ x: this.logoScale, y: this.logoScale })
        .opacity(this.logoOpacity)
        .animation({
          duration: 600,
          curve: curves.springMotion(0.5, 0.8)
        })

        // 特性卡片
        Row({ space: 12 }) {
          this.FeatureCard('⚡', '极速启动')
          this.FeatureCard('🎨', '精美主题')
          this.FeatureCard('📝', '语法高亮')
        }
        .width('100%')
        .constraintSize({ maxWidth: 400 })
        .padding({ left: 24, right: 24 })
        .opacity(this.contentOpacity)
        .animation({
          duration: 500,
          curve: curves.springMotion(0.6, 0.9)
        })

      // 快捷操作
      Column({ space: 12 }) {
        this.QuickAction('📄', '新建文件', '创建一个空白文件', () => this.onNewFile())
        this.QuickAction('📂', '打开文件', '打开本地文件进行编辑', () => this.onOpenFile())
        this.QuickAction('🗂️', '打开文件夹', '打开项目目录', () => this.onOpenFolder())
      }
      .width('100%')
      .constraintSize({ maxWidth: 360 })
      .padding({ left: 24, right: 24 })
      .translate({ y: this.contentOffset })
      .opacity(this.contentOpacity)
      .animation({
        duration: 500,
        curve: curves.springMotion(0.6, 0.9)
      })

      // 快捷键提示
      Column({ space: 8 }) {
        Text('快捷键')
          .fontSize(12)
          .fontColor(this.colors.textDisabled)
          .margin({ bottom: 4 })

        Row({ space: 24 }) {
          this.ShortcutItem('Ctrl+O', '打开')
          this.ShortcutItem('Ctrl+S', '保存')
          this.ShortcutItem('Ctrl+N', '新建')
        }
      }
      .translate({ y: this.contentOffset })
      .opacity(this.contentOpacity)
      .margin({ top: 24 })
      .animation({
        duration: 500,
        curve: curves.springMotion(0.6, 0.9)
      })

      Blank().layoutWeight(1)

      // 版本和链接
      Row({ space: 16 }) {
        Text('v1.0.0')
          .fontSize(11)
          .fontColor(this.colors.textDisabled)

        Text('•')
          .fontSize(11)
          .fontColor(this.colors.textDisabled)

        Text('GitHub')
          .fontSize(11)
          .fontColor(this.colors.primary)
          .decoration({ type: TextDecorationType.Underline })

        Text('•')
          .fontSize(11)
          .fontColor(this.colors.textDisabled)

        Text('文档')
          .fontSize(11)
          .fontColor(this.colors.primary)
          .decoration({ type: TextDecorationType.Underline })
      }
      .margin({ bottom: 24 })
      .opacity(this.contentOpacity)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FeatureCard(icon: string, label: string) {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(28)

      Text(label)
        .fontSize(12)
        .fontColor(this.colors.textSecondary)
    }
    .layoutWeight(1)
    .height(80)
    .borderRadius(12)
    .backgroundColor(this.colors.surface)
    .justifyContent(FlexAlign.Center)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetY: 2
    })
  }

  @Builder
  QuickAction(icon: string, title: string, desc: string, onClick: () => void) {
    Row() {
      // 图标
      Column() {
        Text(icon)
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .borderRadius(12)
      .backgroundColor(this.colors.surfaceVariant)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 文字
      Column({ space: 2 }) {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.colors.textPrimary)

        Text(desc)
          .fontSize(12)
          .fontColor(this.colors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })
      .layoutWeight(1)

      // 箭头
      Text('›')
        .fontSize(20)
        .fontColor(this.colors.textDisabled)
    }
    .width('100%')
    .height(68)
    .padding({ left: 12, right: 16 })
    .borderRadius(16)
    .backgroundColor(this.colors.surface)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetY: 2
    })
    .onClick(() => onClick())
  }

  @Builder
  ShortcutItem(key: string, action: string) {
    Row({ space: 6 }) {
      Text(key)
        .fontSize(11)
        .fontColor(this.colors.textSecondary)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .borderRadius(4)
        .backgroundColor(this.colors.surfaceVariant)

      Text(action)
        .fontSize(11)
        .fontColor(this.colors.textDisabled)
    }
  }
}
