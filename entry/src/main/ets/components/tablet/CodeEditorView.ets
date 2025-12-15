/**
 * 代码编辑器视图组件
 * 支持行号显示、语法高亮、可编辑
 */
import { ThemeColors, SyntaxToken, TokenType } from '../../models/EditorModels'
import { SyntaxHighlightService, Token } from '../../services/SyntaxHighlightService'
import { curves } from '@kit.ArkUI'

@Component
export struct CodeEditorView {
  @Prop content: string = ''
  @Prop language: string = 'typescript'
  @Prop fontSize: number = 14
  @Prop colors: ThemeColors
  @Prop cursorLine: number = 1

  onContentChange: (content: string) => void = () => {}
  onCursorChange: (line: number, column: number) => void = () => {}

  // 状态
  @State lines: string[] = []
  @State tokens: Token[][] = []
  @State currentLine: number = 1
  @State isEditing: boolean = false
  @State editContent: string = ''

  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance()
  private scroller: Scroller = new Scroller()
  private lineHeight: number = 0

  aboutToAppear() {
    this.lineHeight = this.fontSize * 1.7
    this.parseContent()
    this.editContent = this.content
  }

  private parseContent(): void {
    this.lines = this.content.split('\n')
    this.tokens = this.lines.map(line =>
      this.syntaxService.tokenize(line, this.language)
    )
  }

  build() {
    Column() {
      if (this.isEditing) {
        // 编辑模式 - 使用 TextArea
        this.EditMode()
      } else {
        // 查看模式 - 语法高亮显示
        this.ViewMode()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.colors.editorBg)
  }

  @Builder
  ViewMode() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll(this.scroller) {
        Row() {
          // 行号栏
          this.LineNumbers()

          // 代码内容区
          Column() {
            ForEach(this.lines, (line: string, lineIndex: number) => {
              this.CodeLine(line, lineIndex)
            }, (line: string, index: number) => `line_${index}`)
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 24, top: 8, bottom: 100 })
          .layoutWeight(1)
        }
        .alignItems(VerticalAlign.Top)
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarColor(this.colors.textDisabled)
      .scrollBarWidth(6)
      .edgeEffect(EdgeEffect.Spring)
      .friction(0.8)
      .width('100%')
      .height('100%')

      // 编辑按钮浮层
      this.EditFloatButton()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  LineNumbers() {
    Column() {
      ForEach(this.lines, (_: string, index: number) => {
        Text(`${index + 1}`)
          .fontSize(this.fontSize)
          .fontFamily('monospace')
          .fontColor(index + 1 === this.currentLine
            ? this.colors.primary
            : this.colors.lineNumber)
          .fontWeight(index + 1 === this.currentLine ? FontWeight.Medium : FontWeight.Normal)
          .textAlign(TextAlign.End)
          .width(45)
          .height(this.lineHeight)
          .backgroundColor(index + 1 === this.currentLine
            ? this.colors.currentLineBg
            : Color.Transparent)
      }, (_: string, index: number) => `ln_${index}`)
    }
    .width(55)
    .backgroundColor(this.colors.lineNumberBg)
    .padding({ top: 8, right: 8 })
    .alignItems(HorizontalAlign.End)
    .border({
      width: { right: 1 },
      color: this.colors.divider
    })
  }

  @Builder
  CodeLine(line: string, lineIndex: number) {
    Row() {
      Text() {
        if (line.length === 0) {
          // 空行占位
          Span(' ')
        } else {
          // 语法高亮渲染
          ForEach(this.tokens[lineIndex] || [], (token: Token, tokenIndex: number) => {
            Span(token.value)
              .fontColor(this.getTokenColor(token.type))
          }, (token: Token, index: number) => `t_${index}`)
        }
      }
      .fontSize(this.fontSize)
      .fontFamily('monospace')
      .lineHeight(this.lineHeight)
      .width('100%')
    }
    .width('100%')
    .height(this.lineHeight)
    .backgroundColor(lineIndex + 1 === this.currentLine
      ? this.colors.currentLineBg
      : Color.Transparent)
    .onClick(() => {
      this.currentLine = lineIndex + 1
      this.onCursorChange(lineIndex + 1, 1)
    })
  }

  @Builder
  EditFloatButton() {
    Column() {
      Blank().layoutWeight(1)

      Row() {
        Blank().layoutWeight(1)

        // 编辑按钮
        Row({ space: 8 }) {
          Text('✏️')
            .fontSize(16)
          Text('编辑')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .height(44)
        .padding({ left: 20, right: 24 })
        .borderRadius(22)
        .backgroundColor(this.colors.primary)
        .shadow({
          radius: 16,
          color: 'rgba(10, 89, 247, 0.3)',
          offsetX: 0,
          offsetY: 6
        })
        .margin({ right: 24, bottom: 24 })
        .onClick(() => {
          this.isEditing = true
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  EditMode() {
    Column() {
      // 编辑工具栏
      Row() {
        Text('正在编辑')
          .fontSize(14)
          .fontColor(this.colors.textSecondary)

        Blank()

        // 取消按钮
        Button('取消')
          .type(ButtonType.Normal)
          .fontSize(13)
          .fontColor(this.colors.textSecondary)
          .backgroundColor(Color.Transparent)
          .height(32)
          .onClick(() => {
            this.editContent = this.content
            this.isEditing = false
          })

        // 保存按钮
        Button('保存')
          .type(ButtonType.Normal)
          .fontSize(13)
          .fontColor(Color.White)
          .backgroundColor(this.colors.primary)
          .height(32)
          .borderRadius(8)
          .margin({ left: 8 })
          .onClick(() => {
            this.onContentChange(this.editContent)
            this.isEditing = false
            this.parseContent()
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.colors.surfaceVariant)
      .border({
        width: { bottom: 1 },
        color: this.colors.divider
      })

      // 编辑区
      TextArea({ text: this.editContent })
        .fontSize(this.fontSize)
        .fontFamily('monospace')
        .fontColor(this.colors.textPrimary)
        .caretColor(this.colors.primary)
        .backgroundColor(this.colors.editorBg)
        .padding(16)
        .layoutWeight(1)
        .width('100%')
        .onChange((value: string) => {
          this.editContent = value
        })
    }
    .width('100%')
    .height('100%')
  }

  private getTokenColor(type: string): ResourceColor {
    switch (type) {
      case 'keyword':
        return this.colors.syntaxKeyword
      case 'string':
        return this.colors.syntaxString
      case 'number':
        return this.colors.syntaxNumber
      case 'comment':
        return this.colors.syntaxComment
      case 'function':
        return this.colors.syntaxFunction
      case 'class':
      case 'type':
        return this.colors.syntaxClass
      case 'variable':
      case 'property':
        return this.colors.syntaxVariable
      case 'operator':
        return this.colors.syntaxOperator
      case 'decorator':
        return this.colors.syntaxDecorator
      case 'punctuation':
        return this.colors.syntaxPunctuation
      default:
        return this.colors.textPrimary
    }
  }
}
