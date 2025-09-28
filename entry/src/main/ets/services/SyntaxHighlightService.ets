export interface HighlightToken {
  text: string;
  type: 'keyword' | 'string' | 'comment' | 'number' | 'function' | 'variable' | 'operator' | 'bracket' | 'text';
}

interface MatchResult {
  index: number;
  match: RegExpExecArray | null;
  patternIndex: number;
}

export class SyntaxHighlightService {
  private languagePatterns: Map<string, RegExp[]> = new Map();

  constructor() {
    this.initializePatterns();
  }

  private initializePatterns(): void {
    // JavaScript/TypeScript 模式
    this.languagePatterns.set('javascript', [
      // 关键字
      /\b(function|const|let|var|if|else|for|while|return|class|extends|import|export|from|async|await|try|catch|finally|throw|new|this|super|static|public|private|protected)\b/g,
      // 字符串
      /(["'])((?:\\.|(?!\1)[^\\])*)\1/g,
      // 单行注释
      /\/\/.*$/gm,
      // 多行注释
      /\/\*[\s\S]*?\*\//g,
      // 数字
      /\b\d+(\.\d+)?\b/g,
      // 函数调用
      /\b([a-zA-Z_$][a-zA-Z0-9_$]*)\s*(?=\()/g,
      // 括号和操作符
      /[{}[\]();,.+\-*\/=<>!&|?:]/g
    ]);

    const jsPatterns = this.languagePatterns.get('javascript') || [];
    this.languagePatterns.set('typescript', [
      // 继承JavaScript模式
      ...jsPatterns,
      // TypeScript特定关键字
      /\b(interface|type|enum|implements|readonly|keyof|typeof|instanceof|as|in|of|void|undefined|null|boolean|string|number|object|any|unknown|never)\b/g
    ]);

    // CSS 模式
    this.languagePatterns.set('css', [
      // 选择器
      /\b([a-zA-Z][a-zA-Z0-9-_]*)\s*(?=\{)/g,
      // 属性
      /\b([a-zA-Z-]+)\s*:/g,
      // 值
      /:\s*([^;]+);/g,
      // 字符串
      /(["'])((?:\\.|(?!\1)[^\\])*)\1/g,
      // 注释
      /\/\*[\s\S]*?\*\//g,
      // 数字和单位
      /\b\d+(\.\d+)?(%|px|em|rem|vh|vw|pt|pc|in|cm|mm|ex|ch|vmin|vmax)?\b/g
    ]);

    // Markdown 模式
    this.languagePatterns.set('markdown', [
      // 标题
      /^(#{1,6})\s+.*/gm,
      // 粗体和斜体
      /(\*\*|__)(.*?)\1/g,
      /(\*|_)(.*?)\1/g,
      // 代码块
      /```[\s\S]*?```/g,
      // 行内代码
      /`([^`]+)`/g,
      // 链接
      /\[([^\]]+)\]\(([^)]+)\)/g,
      // 列表
      /^[\s]*[-*+]\s+.*/gm,
      /^[\s]*\d+\.\s+.*/gm
    ]);

    // Python 模式
    this.languagePatterns.set('python', [
      // 关键字
      /\b(def|class|if|elif|else|for|while|return|import|from|as|try|except|finally|with|lambda|and|or|not|in|is|None|True|False|print|len|range|str|int|float|list|dict|set|tuple)\b/g,
      // 字符串
      /(["'])((?:\\.|(?!\1)[^\\])*)\1/g,
      // 注释
      /#.*$/gm,
      // 数字
      /\b\d+(\.\d+)?\b/g,
      // 函数定义
      /\bdef\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/g
    ]);
  }

  /**
   * 分析代码并返回高亮token列表
   */
  analyzeCode(code: string, language: string = 'javascript'): HighlightToken[] {
    const tokens: HighlightToken[] = [];
    const patterns = this.languagePatterns.get(language) || this.languagePatterns.get('javascript')!;

    // 创建一个副本用于处理
    let remainingCode = code;
    let currentIndex = 0;

    while (remainingCode.length > 0) {
      let earliestMatch: MatchResult | null = null;

      // 找到最早的匹配
      patterns.forEach((pattern, patternIndex) => {
        pattern.lastIndex = 0; // 重置正则表达式状态
        const match = pattern.exec(remainingCode);

        if (match && match.index === 0) { // 只匹配从开头开始的
          const currentLength = match[0].length;
          const earliestLength = earliestMatch?.match?.[0]?.length || 0;
          if (!earliestMatch || currentLength > earliestLength) {
            earliestMatch = { index: currentIndex, match, patternIndex };
          }
        }
      });

      if (earliestMatch !== null) {
        const matchData: MatchResult = earliestMatch;
        if (matchData.match !== null) {
          const matchResult: RegExpExecArray = matchData.match;
          const tokenText: string = matchResult[0];
          const patternIndex: number = matchData.patternIndex;

          // 确定token类型
          const tokenType = this.getTokenType(tokenText, language, patternIndex);

          tokens.push({
            text: tokenText,
            type: tokenType
          });

          // 更新位置和剩余代码
          currentIndex += tokenText.length;
          remainingCode = remainingCode.substring(tokenText.length);
        } else {
          // 没有匹配到任何模式，将剩余代码作为普通文本
          if (remainingCode.length > 0) {
            tokens.push({
              text: remainingCode.charAt(0),
              type: 'text'
            });
            currentIndex += 1;
            remainingCode = remainingCode.substring(1);
          }
        }
      } else {
        // 没有匹配到任何模式，将剩余代码作为普通文本
        if (remainingCode.length > 0) {
          tokens.push({
            text: remainingCode.charAt(0),
            type: 'text'
          });
          currentIndex += 1;
          remainingCode = remainingCode.substring(1);
        }
      }
    }

    return tokens;
  }

  private getTokenType(text: string, language: string, patternIndex: number): 'keyword' | 'string' | 'comment' | 'number' | 'function' | 'variable' | 'operator' | 'bracket' | 'text' {
    if (language === 'javascript') {
      switch (patternIndex) {
        case 0: return 'keyword';     // 关键字
        case 1: return 'string';      // 字符串
        case 2: return 'comment';     // 单行注释
        case 3: return 'comment';     // 多行注释
        case 4: return 'number';      // 数字
        case 5: return 'function';    // 函数
        case 6: return 'operator';    // 操作符和括号
        default: return 'text';
      }
    } else if (language === 'typescript') {
      switch (patternIndex) {
        case 0: return 'keyword';     // JavaScript关键字
        case 1: return 'string';      // 字符串
        case 2: return 'comment';     // 单行注释
        case 3: return 'comment';     // 多行注释
        case 4: return 'number';      // 数字
        case 5: return 'function';    // 函数
        case 6: return 'keyword';     // TypeScript关键字
        case 7: return 'operator';    // 操作符和括号
        default: return 'text';
      }
    } else if (language === 'css') {
      switch (patternIndex) {
        case 0: return 'variable';    // 选择器
        case 1: return 'keyword';     // 属性
        case 2: return 'string';      // 值
        case 3: return 'string';      // 字符串
        case 4: return 'comment';     // 注释
        case 5: return 'number';      // 数字和单位
        default: return 'text';
      }
    } else if (language === 'markdown') {
      switch (patternIndex) {
        case 0: return 'keyword';     // 标题
        case 1: return 'keyword';     // 粗体
        case 2: return 'keyword';     // 斜体
        case 3: return 'string';      // 代码块
        case 4: return 'string';      // 行内代码
        case 5: return 'keyword';     // 链接
        case 6: return 'keyword';     // 列表
        case 7: return 'keyword';     // 有序列表
        default: return 'text';
      }
    } else if (language === 'python') {
      switch (patternIndex) {
        case 0: return 'keyword';     // 关键字
        case 1: return 'string';      // 字符串
        case 2: return 'comment';     // 注释
        case 3: return 'number';      // 数字
        case 4: return 'function';    // 函数
        default: return 'text';
      }
    }

    return 'text';
  }

  /**
   * 获取语言支持列表
   */
  getSupportedLanguages(): string[] {
    return Array.from(this.languagePatterns.keys());
  }

  /**
   * 添加自定义语言模式
   */
  addLanguage(name: string, patterns: RegExp[]): void {
    this.languagePatterns.set(name, patterns);
  }
}
