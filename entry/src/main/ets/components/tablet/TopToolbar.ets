/**
 * 顶部工具栏组件
 * 鸿蒙6风格精美UI
 */
import { ThemeColors } from '../../models/EditorModels'
import { curves } from '@kit.ArkUI'

@Component
export struct TopToolbar {
  @Prop projectName: string = '未命名项目'
  @Prop isDarkMode: boolean = true
  @Prop colors: ThemeColors
  @Prop isSidebarVisible: boolean = true

  // 回调事件
  onMenuClick: () => void = () => {}
  onSaveClick: () => void = () => {}
  onThemeToggle: () => void = () => {}
  onOpenFile: () => void = () => {}

  // 按钮状态
  @State menuBtnScale: number = 1
  @State saveBtnScale: number = 1
  @State themeBtnScale: number = 1
  @State openBtnScale: number = 1
  @State themeBtnRotate: number = 0

  build() {
    Row() {
      // 左侧区域
      Row({ space: 12 }) {
        // 菜单按钮（控制侧边栏）
        this.IconButton(
          '☰',
          this.menuBtnScale,
          this.isSidebarVisible,
          () => this.onMenuClick(),
          (scale: number) => { this.menuBtnScale = scale }
        )

        // Logo 和项目名
        Row({ space: 8 }) {
          // Logo
          Text('⌘')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.colors.primary)

          // 项目名称
          Text(this.projectName)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colors.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }

      Blank()

      // 右侧操作按钮
      Row({ space: 8 }) {
        // 打开文件
        this.EnhancedActionButton(
          '📂',
          '打开',
          this.openBtnScale,
          () => this.onOpenFile(),
          (scale: number) => { this.openBtnScale = scale }
        )

        // 保存按钮
        this.EnhancedActionButton(
          '💾',
          '保存',
          this.saveBtnScale,
          () => this.onSaveClick(),
          (scale: number) => { this.saveBtnScale = scale }
        )

        // 分割线
        Divider()
          .vertical(true)
          .height(28)
          .color(this.colors.divider)
          .strokeWidth(1)
          .margin({ left: 6, right: 6 })

        // 主题切换（增强版）
        Stack() {
          // 背景光晕
          Circle()
            .width(50)
            .height(50)
            .fill(this.colors.primary + '10')
            .blur(10)
            .scale({ x: this.themeBtnScale, y: this.themeBtnScale })

          Column() {
            Text(this.isDarkMode ? '☀️' : '🌙')
              .fontSize(20)
              .rotate({ angle: this.themeBtnRotate })
          }
          .width(40)
          .height(40)
          .borderRadius(12)
          .backgroundColor(this.colors.surfaceVariant)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .scale({ x: this.themeBtnScale, y: this.themeBtnScale })
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.08)',
            offsetY: 2
          })
        }
        .animation({
          duration: 250,
          curve: curves.springMotion(0.5, 0.9)
        })
        .onClick(() => {
          // 旋转动画
          this.getUIContext().animateTo({
            duration: 400,
            curve: curves.springMotion(0.4, 0.8)
          }, () => {
            this.themeBtnRotate += 180
          })
          this.onThemeToggle()
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.themeBtnScale = 0.9
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.themeBtnScale = 1
          }
        })
      }
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.colors.surface)
    .shadow({
      radius: 8,
      color: this.isDarkMode ? 'rgba(0, 0, 0, 0.3)' : 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  IconButton(
    icon: string,
    scale: number,
    isActive: boolean,
    onClick: () => void,
    onScaleChange: (scale: number) => void
  ) {
    Column() {
      Text(icon)
        .fontSize(18)
        .fontColor(isActive ? this.colors.primary : this.colors.textSecondary)
    }
    .width(40)
    .height(40)
    .borderRadius(12)
    .backgroundColor(isActive ? this.colors.active : Color.Transparent)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .scale({ x: scale, y: scale })
    .animation({
      duration: 200,
      curve: curves.springMotion(0.5, 0.9)
    })
    .onClick(() => onClick())
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        onScaleChange(0.92)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        onScaleChange(1)
      }
    })
  }

  @Builder
  ActionButton(
    icon: string,
    label: string,
    scale: number,
    onClick: () => void,
    onScaleChange: (scale: number) => void
  ) {
    Row({ space: 6 }) {
      Text(icon)
        .fontSize(15)
      Text(label)
        .fontSize(13)
        .fontColor(this.colors.textSecondary)
        .fontWeight(FontWeight.Medium)
    }
    .height(36)
    .padding({ left: 12, right: 14 })
    .borderRadius(10)
    .backgroundColor(this.colors.surfaceVariant)
    .scale({ x: scale, y: scale })
    .animation({
      duration: 200,
      curve: curves.springMotion(0.5, 0.9)
    })
    .onClick(() => onClick())
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        onScaleChange(0.95)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        onScaleChange(1)
      }
    })
  }

  @Builder
  EnhancedActionButton(
    icon: string,
    label: string,
    scale: number,
    onClick: () => void,
    onScaleChange: (scale: number) => void
  ) {
    Row({ space: 8 }) {
      Text(icon)
        .fontSize(16)
      Text(label)
        .fontSize(13)
        .fontColor(this.colors.textPrimary)
        .fontWeight(FontWeight.Medium)
    }
    .height(38)
    .padding({ left: 14, right: 16 })
    .borderRadius(12)
    .backgroundColor(this.colors.surfaceVariant)
    .scale({ x: scale, y: scale })
    .shadow({
      radius: 6,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetY: 2
    })
    .animation({
      duration: 250,
      curve: curves.springMotion(0.5, 0.9)
    })
    .onClick(() => onClick())
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        onScaleChange(0.94)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        onScaleChange(1)
      }
    })
  }
}
