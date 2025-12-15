/**
 * 状态栏组件
 * 显示光标位置、语言类型、编码等信息
 */
import { ThemeColors } from '../../models/EditorModels'
import { curves } from '@kit.ArkUI'

@Component
export struct EditorStatusBar {
  @Prop line: number = 1
  @Prop column: number = 1
  @Prop language: string = 'Plain Text'
  @Prop encoding: string = 'UTF-8'
  @Prop lineEnding: string = 'LF'
  @Prop isDirty: boolean = false
  @Prop colors: ThemeColors

  @State languageBtnHover: boolean = false
  @State encodingBtnHover: boolean = false
  @State lineEndingHover: boolean = false
  @State cursorInfoHover: boolean = false

  build() {
    Row() {
      // 左侧信息
      Row({ space: 12 }) {
        // 光标位置 - 增强版
        Row({ space: 6 }) {
          Text('📍')
            .fontSize(12)
          Text(`行 ${this.line}, 列 ${this.column}`)
            .fontSize(12)
            .fontColor(this.colors.textPrimary)
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        .borderRadius(6)
        .backgroundColor(this.cursorInfoHover ? this.colors.primary + '20' : this.colors.primary + '10')
        .animation({
          duration: 200,
          curve: curves.springMotion()
        })
        .onHover((isHover: boolean) => {
          this.cursorInfoHover = isHover
        })

        // 分隔符
        Text('•')
          .fontSize(12)
          .fontColor(this.colors.textDisabled)
      }

      Blank()

      // 右侧信息
      Row({ space: 8 }) {
        // 编码格式
        this.EnhancedStatusItem('📝', this.encoding, this.encodingBtnHover, (hover) => {
          this.encodingBtnHover = hover
        })

        // 换行符
        this.EnhancedStatusItem('↩️', this.lineEnding, this.lineEndingHover, (hover) => {
          this.lineEndingHover = hover
        })

        // 语言类型
        Row({ space: 6 }) {
          Text('🔤')
            .fontSize(12)
          Text(this.getLanguageDisplayName())
            .fontSize(12)
            .fontColor(this.colors.primary)
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        .borderRadius(6)
        .backgroundColor(this.languageBtnHover ? this.colors.primary + '25' : this.colors.primary + '10')
        .animation({
          duration: 200,
          curve: curves.springMotion()
        })
        .onHover((isHover: boolean) => {
          this.languageBtnHover = isHover
        })

        // 分隔符
        if (this.isDirty) {
          Text('•')
            .fontSize(12)
            .fontColor(this.colors.textDisabled)
        }

        // 保存状态增强
        if (this.isDirty) {
          Row({ space: 4 }) {
            Text('●')
              .fontSize(10)
              .fontColor('#FF3B30')
            Text('未保存')
              .fontSize(11)
              .fontColor('#FF3B30')
              .fontWeight(FontWeight.Medium)
          }
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(6)
          .backgroundColor('#FF3B3015')
        } else {
          Text('✓')
            .fontSize(14)
            .fontColor('#34C759')
        }
      }
    }
    .width('100%')
    .height(28)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.colors.surfaceVariant)
    .border({
      width: { top: 1 },
      color: this.colors.divider
    })
  }

  @Builder
  StatusItem(text: string) {
    Text(text)
      .fontSize(12)
      .fontColor(this.colors.textSecondary)
  }

  @Builder
  EnhancedStatusItem(icon: string, text: string, isHovered: boolean, onHoverChange: (hover: boolean) => void) {
    Row({ space: 4 }) {
      Text(icon)
        .fontSize(12)
      Text(text)
        .fontSize(12)
        .fontColor(this.colors.textSecondary)
    }
    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
    .borderRadius(6)
    .backgroundColor(isHovered ? this.colors.hover : Color.Transparent)
    .animation({
      duration: 200,
      curve: curves.springMotion()
    })
    .onHover((isHover: boolean) => {
      onHoverChange(isHover)
    })
  }

  @Builder
  ClickableStatusItem(text: string, isHovered: boolean, onHoverChange: (hover: boolean) => void) {
    Text(text)
      .fontSize(12)
      .fontColor(this.colors.textSecondary)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      .borderRadius(4)
      .backgroundColor(isHovered ? this.colors.hover : Color.Transparent)
      .animation({
        duration: 150,
        curve: Curve.EaseOut
      })
      .onHover((isHover: boolean) => {
        onHoverChange(isHover)
      })
  }

  @Builder
  DirtyIndicator() {
    Row({ space: 6 }) {
      Circle()
        .width(6)
        .height(6)
        .fill('#F59E0B')

      Text('未保存')
        .fontSize(12)
        .fontColor('#F59E0B')
    }
    .padding({ left: 8, right: 8 })
    .height(22)
    .borderRadius(4)
    .backgroundColor('rgba(245, 158, 11, 0.1)')
  }

  private getLanguageDisplayName(): string {
    const nameMap: Record<string, string> = {
      'arkts': 'ArkTS',
      'typescript': 'TypeScript',
      'javascript': 'JavaScript',
      'json': 'JSON',
      'markdown': 'Markdown',
      'html': 'HTML',
      'css': 'CSS',
      'python': 'Python',
      'java': 'Java',
      'text': 'Plain Text'
    }
    return nameMap[this.language.toLowerCase()] || this.language
  }
}
