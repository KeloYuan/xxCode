/**
 * 实时语法高亮的代码编辑器组件
 */
import { SyntaxHighlightService, Token } from '../services/SyntaxHighlightService';

// 基础数据源实现，用于 LazyForEach
class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: T[] = [];

  constructor(data: T[]) {
    this.originDataArray = data;
  }

  totalCount(): number {
    return this.originDataArray.length;
  }

  getData(index: number): T {
    return this.originDataArray[index];
  }

  addData(index: number, data: T): void {
    this.originDataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  pushData(data: T): void {
    this.originDataArray.push(data);
    this.notifyDataAdd(this.originDataArray.length - 1);
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

@Component
export struct CodeEditorView {
  @Prop @Watch('onContentChange') content: string = '';
  @Prop language: string = 'javascript';
  @Prop fontSize: number = 14;
  @Prop textColor: string = '#FFFFFF';
  @Prop bgColor: string = '#1E1E1E';
  @Prop lineNumberColor: string = '#858585';
  @Prop caretColor: string = '#0A59F7';
  @Prop editorBorderColor: string = '#3C3C3C';
  
  // 语法高亮颜色
  @Prop keywordColor: string = '#569CD6';
  @Prop stringColor: string = '#CE9178';
  @Prop commentColor: string = '#6A9955';
  @Prop numberColor: string = '#B5CEA8';
  @Prop functionColor: string = '#DCDCAA';
  
  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance();
  private editorScroller: Scroller = new Scroller();
  
  // 使用数据源管理行号
  private lineNumbersDataSource: BasicDataSource<number> = new BasicDataSource([]);
  private realLineCount: number = 0;
  
  onChange?: (value: string) => void;
  
  aboutToAppear() {
    this.updateLineNumbers();
  }

  onContentChange() {
    this.updateLineNumbers();
  }

  /**
   * 更新行号数据
   */
  private updateLineNumbers() {
    const lines = this.content.split('\n');
    this.realLineCount = lines.length;
    const lineCount = Math.max(this.realLineCount, 100);
    const numbers: number[] = [];
    for (let i = 1; i <= lineCount; i++) {
      numbers.push(i);
    }
    // 重新加载数据
    this.lineNumbersDataSource = new BasicDataSource(numbers);
  }
  
  /**
   * 获取代码行数组
   */
  private getCodeLines(): string[] {
    return this.content.split('\n');
  }
  
  /**
   * 获取 token 颜色
   */
  private getTokenColor(type: string): string {
    const colorMap: Record<string, string> = {
      'keyword': this.keywordColor,
      'string': this.stringColor,
      'comment': this.commentColor,
      'number': this.numberColor,
      'function': this.functionColor,
      'variable': this.textColor,
      'operator': this.textColor,
      'bracket': this.textColor,
      'type': this.keywordColor,
      'text': this.textColor  // 普通文本使用文字颜色
    };
    return colorMap[type] || this.textColor;
  }
  
  build() {
    Scroll() {
      Row() {
        // 行号列
        Column() {
          LazyForEach(this.lineNumbersDataSource, (lineNum: number) => {
            Text(`${lineNum}`)
              .fontSize(this.fontSize)
              .fontColor(this.lineNumberColor)
              .fontFamily('monospace')
              .width(40)
              .height(this.fontSize + 8)
              .textAlign(TextAlign.End)
              .padding({ right: 8 })
              .opacity(lineNum <= this.realLineCount ? 1.0 : 0.3)
          }, (lineNum: number) => `ln_${lineNum}`)
        }
        .alignItems(HorizontalAlign.End)
        .backgroundColor(this.bgColor)
        
        // 分隔线
        Column()
          .width(1)
          .height('100%')
          .backgroundColor(this.editorBorderColor)
        
        // 编辑区
        TextArea({ text: this.content })
          .layoutWeight(1)
          .fontSize(this.fontSize)
          .fontColor(this.textColor)
          .caretColor(this.caretColor)
          .backgroundColor(this.bgColor)
          .padding({ left: 8, right: 16, top: 0, bottom: 0 })
          .fontFamily('monospace')
          .lineHeight(this.fontSize + 8)
          .onChange((value: string) => {
            this.content = value;
            if (this.onChange) {
              this.onChange(value);
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 12, bottom: 12 })
    .scrollBar(BarState.On)
    .scrollBarWidth(10)
    .scrollBarColor(this.lineNumberColor)
    .backgroundColor(this.bgColor)
  }
}
