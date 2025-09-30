import { SyntaxHighlightService, HighlightToken } from '../services/SyntaxHighlightService';
import { CodeCompletionService, CompletionSuggestion } from '../services/CodeCompletionService';

@Component
export struct HighlightedText {
  @Prop code: string = '';
  @Prop language: string = 'javascript';
  @Prop fontSize: number = 15;
  @Prop editable: boolean = false;
  
  @State internalCode: string = '';
  @State suggestions: CompletionSuggestion[] = [];
  @State showSuggestions: boolean = false;
  
  private highlightService: SyntaxHighlightService = new SyntaxHighlightService();
  private completionService: CodeCompletionService = CodeCompletionService.getInstance();
  @State tokens: HighlightToken[] = [];

  onChange?: (value: string) => void;

  aboutToAppear() {
    this.internalCode = this.code;
    this.updateHighlight();
  }

  build() {
    Stack() {
      if (this.editable) {
        this.buildEditableEditor()
      } else {
        this.buildReadOnlyView()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildEditableEditor(): void {
    Column() {
      // 编辑器工具栏
      Row() {
        Text(this.getLanguageLabel())
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor($r('app.color.background_tertiary'))
          .borderRadius(4)
        
        Blank()
        
        Text(`${this.getLineCount()} 行 · ${this.internalCode.length} 字符`)
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 编辑器区域
      TextArea({
        placeholder: '// 开始编写代码...\n// 支持语法高亮',
        text: this.internalCode
      })
      .width('100%')
      .layoutWeight(1)
      .fontSize(this.fontSize)
      .fontFamily('SF Mono, Monaco, Menlo, Consolas, "Courier New", monospace')
      .backgroundColor($r('app.color.editor_background'))
      .borderRadius(0)
      .border({ width: 0 })
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      .placeholderColor($r('app.color.text_tertiary'))
      .onChange((value: string): void => {
        this.internalCode = value;
        this.updateHighlight();
        if (this.onChange) {
          this.onChange(value);
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildReadOnlyView(): void {
    Scroll() {
      Column() {
        ForEach(this.tokens, (token: HighlightToken) => {
          Text(token.text)
            .fontSize(this.fontSize)
            .fontFamily('monospace')
            .fontColor(this.getTokenColor(token.type))
        })
      }
      .alignItems(HorizontalAlign.Start)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.editor_background'))
  }

  private updateHighlight() {
    if (this.internalCode) {
      this.tokens = this.highlightService.analyzeCode(this.internalCode, this.language);
    } else {
      this.tokens = [];
    }
  }

  private getTokenColor(type: string): string {
    const colorMap: Record<string, string> = {
      'keyword': '#C678DD',      // 紫色 - 关键字
      'string': '#98C379',       // 绿色 - 字符串  
      'comment': '#7F848E',      // 灰色 - 注释
      'number': '#D19A66',       // 橙色 - 数字
      'function': '#61AFEF',     // 蓝色 - 函数
      'variable': '#E06C75',     // 红色 - 变量
      'operator': '#ABB2BF',     // 浅灰 - 操作符
      'bracket': '#ABB2BF',      // 浅灰 - 括号
      'text': '#ABB2BF'          // 浅灰 - 普通文本
    };
    return colorMap[type] || '#ABB2BF';
  }

  private getLanguageLabel(): string {
    const labels: Record<string, string> = {
      'javascript': 'JavaScript',
      'typescript': 'TypeScript',
      'python': 'Python',
      'java': 'Java',
      'html': 'HTML',
      'css': 'CSS',
      'json': 'JSON',
      'markdown': 'Markdown'
    };
    return labels[this.language] || this.language.toUpperCase();
  }

  private getLineCount(): number {
    return this.internalCode ? this.internalCode.split('\n').length : 1;
  }

  // 公共方法
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