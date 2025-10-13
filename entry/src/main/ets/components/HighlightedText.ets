/**
 * 语法高亮文本组件
 * 用于显示带有语法高亮的代码
 */
import { SyntaxHighlightService, Token } from '../services/SyntaxHighlightService';
import { ThemeService, Theme } from '../services/ThemeService';
import { CommonConstants } from '../common/CommonConstants';

@Component
export struct HighlightedText {
  @Prop code: string = '';
  @Prop language: string = 'text';
  @Prop fontSize: number = CommonConstants.DEFAULT_FONT_SIZE;
  @Prop @Watch('onCodeChange') isEditable: boolean = true;
  
  @State private internalCode: string = '';
  @State private tokens: Token[] = [];
  @State private currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  
  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();
  private onContentChange?: (content: string) => void;

  aboutToAppear() {
    this.internalCode = this.code;
    this.updateHighlight();
    
    // 监听主题变化
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  onCodeChange() {
    this.internalCode = this.code;
    this.updateHighlight();
  }

  private updateHighlight() {
    if (this.language !== 'text') {
      this.tokens = this.syntaxService.tokenize(this.internalCode, this.language);
    }
  }

  private handleTextChange(value: string) {
    this.internalCode = value;
    this.updateHighlight();
    if (this.onContentChange) {
      this.onContentChange(value);
    }
  }

  build() {
    Column() {
      if (this.isEditable) {
        this.buildEditableEditor();
      } else {
        this.buildReadOnlyEditor();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildEditableEditor(): void {
    Column() {
      // 工具栏
      Row() {
        Row() {
          Text('▣')
            .fontSize(12)
            .fontColor(this.currentTheme.colors.primary)
            .margin({ right: 6 })
          
          Text(this.getLanguageLabel())
            .fontSize(12)
            .fontColor(this.currentTheme.colors.textSecondary)
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor(this.currentTheme.colors.surface)
        .borderRadius(6)

        Blank()

        Row({ space: 8 }) {
          Text(`${this.getLineCount()} 行`)
            .fontSize(11)
            .fontColor(this.currentTheme.colors.textSecondary)
          
          Text(`${this.internalCode.length} 字符`)
            .fontSize(11)
            .fontColor(this.currentTheme.colors.textSecondary)
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.currentTheme.editor.background)

      Divider()
        .color(this.currentTheme.colors.border)
        .strokeWidth(0.5)

      // 可编辑文本区域
      TextArea({
        placeholder: '// 开始编写代码...\n// 支持语法高亮',
        text: this.internalCode
      })
        .width('100%')
        .layoutWeight(1)
        .fontSize(this.fontSize)
        .lineHeight(this.fontSize * 1.6)
        .fontFamily('SF Mono, Monaco, Menlo, Consolas, "Courier New", monospace')
        .fontColor(this.currentTheme.editor.text)
        .backgroundColor(this.currentTheme.editor.background)
        .borderRadius(0)
        .border({ width: 0 })
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        .placeholderColor(this.currentTheme.colors.textSecondary)
        .caretColor(this.currentTheme.editor.cursor)
        .onChange((value: string) => {
          this.handleTextChange(value);
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.editor.background)
  }

  @Builder
  buildReadOnlyEditor(): void {
    Scroll() {
      Column() {
        if (this.tokens.length > 0) {
          this.buildHighlightedCode();
        } else {
          Text(this.internalCode)
            .fontSize(this.fontSize)
            .fontFamily('SF Mono, Monaco, Consolas, monospace')
            .fontColor(this.currentTheme.editor.text)
            .lineHeight(this.fontSize * 1.6)
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.editor.background)
    .scrollBar(BarState.Auto)
  }

  @Builder
  buildHighlightedCode(): void {
    Text() {
      ForEach(this.tokens, (token: Token, index: number) => {
        Span(token.value)
          .fontSize(this.fontSize)
          .fontColor(this.getTokenColor(token.type))
          .fontFamily('SF Mono, Monaco, Consolas, monospace')
      }, (token: Token, index: number) => `${index}_${token.start}`)
    }
    .lineHeight(this.fontSize * 1.6)
  }

  private getTokenColor(type: string): string {
    const colorMap: Record<string, string> = {
      'keyword': this.currentTheme.syntax.keyword,
      'string': this.currentTheme.syntax.string,
      'comment': this.currentTheme.syntax.comment,
      'number': this.currentTheme.syntax.number,
      'function': this.currentTheme.syntax.function,
      'variable': this.currentTheme.syntax.variable,
      'operator': this.currentTheme.syntax.operator,
      'bracket': this.currentTheme.editor.text,
      'type': this.currentTheme.syntax.type,
      'text': this.currentTheme.editor.text
    };
    return colorMap[type] || this.currentTheme.editor.text;
  }

  private getLanguageLabel(): string {
    return this.syntaxService.getLanguageDisplayName(this.language);
  }

  private getLineCount(): number {
    return this.internalCode.split('\n').length;
  }

  /**
   * 设置内容变化回调
   */
  public setOnContentChange(callback: (content: string) => void): void {
    this.onContentChange = callback;
  }
}

