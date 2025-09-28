import { SyntaxHighlightService, HighlightToken } from '../services/SyntaxHighlightService';

@Component
export struct HighlightedText {
  @Prop code: string = '';
  @Prop language: string = 'javascript';
  @Prop fontSize: number = 14;
  @Prop editable: boolean = false;

  @State internalCode: string = '';

  private highlightService: SyntaxHighlightService = new SyntaxHighlightService();
  @State tokens: HighlightToken[] = [];

  aboutToAppear() {
    this.internalCode = this.code;
    this.updateHighlight();
  }

  build() {
    Column() {
      if (this.editable) {
        // 可编辑模式
        this.buildEditableText()
      } else {
        // 只读模式
        this.buildReadOnlyText()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildEditableText() {
    TextInput({
      placeholder: '在这里编写代码...',
      text: this.internalCode
    })
    .height('100%')
    .width('100%')
    .fontSize(this.fontSize)
    .fontFamily('monospace')
    .textAlign(TextAlign.Start)
    .caretColor(Color.Blue)
    .backgroundColor(Color.White)
    .padding(16)
    .onChange((value: string) => {
      this.internalCode = value;
      this.updateHighlight();
      // 触发外部回调
      if (this.onChange) {
        this.onChange(value);
      }
    })
  }

  // 事件回调
  onChange?: (value: string) => void;

  @Builder
  buildReadOnlyText() {
    Scroll() {
      Column() {
        ForEach(this.tokens, (token: HighlightToken, index: number) => {
          Text(token.text)
            .fontSize(this.fontSize)
            .fontFamily('monospace')
            .textAlign(TextAlign.Start)
            .fontColor(this.getTokenColor(token.type))
            .backgroundColor(this.getTokenBackgroundColor(token.type))
        })
      }
      .padding(16)
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White)
    // scrollable property not available in this ArkTS version
  }

  private updateHighlight() {
    if (this.internalCode) {
      this.tokens = this.highlightService.analyzeCode(this.internalCode, this.language);
    } else {
      this.tokens = [];
    }
  }

  private getTokenColor(type: string): Color {
    const colorMap: Record<string, Color> = {
      'keyword': Color.Blue,
      'string': Color.Green,
      'comment': Color.Gray,
      'number': Color.Red,
      'function': Color.Orange,
      'variable': Color.Blue,
      'operator': Color.Gray,
      'bracket': Color.Gray,
      'text': Color.Black
    };
    const result = colorMap[type];
    return result !== undefined ? result : Color.Black;
  }

  private getTokenBackgroundColor(type: string): Color {
    // 目前只为选中的文本提供背景色
    return Color.Transparent;
  }

  // 公共方法供父组件调用
  public refreshHighlight() {
    this.updateHighlight();
  }

  public setCode(code: string) {
    this.internalCode = code;
    this.updateHighlight();
  }

  public setLanguage(language: string) {
    this.language = language;
    this.updateHighlight();
  }

  public getCode(): string {
    return this.internalCode;
  }
}
