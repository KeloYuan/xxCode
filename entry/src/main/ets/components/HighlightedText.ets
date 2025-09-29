import { SyntaxHighlightService, HighlightToken } from '../services/SyntaxHighlightService';
import { CodeCompletionService, CompletionSuggestion } from '../services/CodeCompletionService';

@Component
export struct HighlightedText {
  @Prop code: string = '';
  @Prop language: string = 'javascript';
  @Prop fontSize: number = 14;
  @Prop editable: boolean = false;

  @State internalCode: string = '';
  @State suggestions: CompletionSuggestion[] = [];
  @State showSuggestions: boolean = false;
  @State currentWord: string = '';

  private highlightService: SyntaxHighlightService = new SyntaxHighlightService();
  @State tokens: HighlightToken[] = [];

  private completionService: CodeCompletionService = CodeCompletionService.getInstance();

  aboutToAppear() {
    this.internalCode = this.code;
    this.updateHighlight();
  }

  build() {
    Stack() {
      if (this.editable) {
        // 可编辑模式
        this.buildEditableText()
      } else {
        // 只读模式
        this.buildReadOnlyText()
      }
      this.buildSuggestionList()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildEditableText(): void {
    TextInput({
      placeholder: '// 在这里编写代码...\n// 支持语法高亮和自动补全',
      text: this.internalCode
    })
    .height('100%')
    .width('100%')
    .fontSize(this.fontSize)
    .fontFamily('SF Mono, Monaco, Consolas, "Liberation Mono", "Courier New", monospace')
    .textAlign(TextAlign.Start)
    .caretColor('#007DFF')
    .backgroundColor('#FAFBFC')
    .borderRadius(8)
    .border({
      width: 1,
      color: '#E5E8EB'
    })
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .placeholderColor('#9CA3AF')
    .placeholderFont({
      size: this.fontSize,
      family: 'SF Mono, Monaco, Consolas, "Liberation Mono", "Courier New", monospace'
    })
    .onChange((value: string) => {
      this.internalCode = value;
      this.updateHighlight();
      // 触发外部回调
      if (this.onChange) {
        this.onChange(value);
      }
    })
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 2
    })
  }

  // 事件回调
  onChange?: (value: string) => void;

  @Builder
  buildReadOnlyText(): void {
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

  private handleInputChange(value: string, caretPosition: number) {
    this.internalCode = value;
    this.updateHighlight();
    
    // Get current word at caret
    const beforeCaret = value.substring(0, caretPosition);
    const wordMatch = beforeCaret.match(/\w*$/);
    if (wordMatch) {
      this.currentWord = wordMatch[0];
      if (this.currentWord.length > 0) {
        this.getSuggestions(this.currentWord, beforeCaret);
      } else {
        this.suggestions = [];
        this.showSuggestions = false;
      }
    }
    
    if (this.onChange) {
      this.onChange(value);
    }
  }

  private async getSuggestions(prefix: string, context: string) {
    try {
      this.suggestions = await this.completionService.getSuggestions(this.language, prefix, context);
      this.showSuggestions = this.suggestions.length > 0;
    } catch (error) {
      console.error('Failed to get suggestions:', error);
      this.showSuggestions = false;
    }
  }

  @Builder
  buildSuggestionList() {
    if (!this.showSuggestions) return;
    
    List({ space: 4 }) {
      ForEach(this.suggestions, (item: CompletionSuggestion) => {
        ListItem() {
          Row() {
            Text(item.text)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
            Blank()
            Text(item.description || '')
              .fontSize(12)
              .fontColor(Color.Gray)
          }
          .padding(8)
        }
        .onClick(() => {
          this.insertSuggestion(item.text);
        })
      }, item => item.text)
    }
    .width(200)
    .height('auto')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4 })
    .position({ x: 'caretX', y: 'caretY - height' }) // Need to calculate position
  }

  private insertSuggestion(text: string) {
    // Logic to insert suggestion into text
    // This requires access to TextInput controller to set text and caret
    // For now, simulate
    this.internalCode = this.internalCode.replace(new RegExp(this.currentWord + '$'), text);
    this.showSuggestions = false;
  }

  private getTokenColor(type: string): Color | string {
    const colorMap: Record<string, string> = {
      'keyword': '#8B5CF6',     // 紫色 - 关键字
      'string': '#10B981',      // 绿色 - 字符串  
      'comment': '#6B7280',     // 灰色 - 注释
      'number': '#F59E0B',      // 橙色 - 数字
      'function': '#3B82F6',    // 蓝色 - 函数
      'variable': '#1A1D29',    // 深灰 - 变量
      'operator': '#6B7280',    // 灰色 - 操作符
      'bracket': '#6B7280',     // 灰色 - 括号
      'text': '#1A1D29'         // 深灰 - 普通文本
    };
    return colorMap[type] || '#1A1D29';
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
