/**
 * 代码格式化服务
 * 提供基础的代码格式化功能
 */

export class CodeFormatterService {
  private static instance: CodeFormatterService | null = null;

  private constructor() {}

  public static getInstance(): CodeFormatterService {
    if (!CodeFormatterService.instance) {
      CodeFormatterService.instance = new CodeFormatterService();
    }
    return CodeFormatterService.instance;
  }

  /**
   * 格式化代码
   */
  public format(code: string, language: string): string {
    switch (language.toLowerCase()) {
      case 'javascript':
      case 'typescript':
      case 'ets':
        return this.formatJavaScript(code);
      case 'json':
        return this.formatJSON(code);
      case 'html':
        return this.formatHTML(code);
      case 'css':
        return this.formatCSS(code);
      default:
        return this.formatGeneric(code);
    }
  }

  /**
   * 格式化 JavaScript/TypeScript
   */
  private formatJavaScript(code: string): string {
    let formatted = '';
    let indentLevel = 0;
    const indentStr = '  '; // 2 空格缩进
    let inString = false;
    let stringChar = '';
    let inComment = false;
    
    for (let i = 0; i < code.length; i++) {
      const char = code[i];
      const nextChar = code[i + 1] || '';
      
      // 处理字符串
      if ((char === '"' || char === "'" || char === '`') && code[i - 1] !== '\\') {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char === stringChar) {
          inString = false;
        }
      }
      
      // 处理注释
      if (!inString && char === '/' && nextChar === '/') {
        inComment = true;
      }
      if (inComment && char === '\n') {
        inComment = false;
      }
      
      // 在字符串或注释中，直接添加字符
      if (inString || inComment) {
        formatted += char;
        continue;
      }
      
      // 处理大括号
      if (char === '{') {
        formatted += char + '\n';
        indentLevel++;
        formatted += indentStr.repeat(indentLevel);
        continue;
      }
      
      if (char === '}') {
        indentLevel = Math.max(0, indentLevel - 1);
        formatted = formatted.trimEnd() + '\n' + indentStr.repeat(indentLevel) + char;
        if (nextChar && nextChar !== ';' && nextChar !== ',' && nextChar !== ')') {
          formatted += '\n' + indentStr.repeat(indentLevel);
        }
        continue;
      }
      
      // 处理分号
      if (char === ';') {
        formatted += char;
        if (nextChar && nextChar !== '\n' && nextChar !== ' ') {
          formatted += '\n' + indentStr.repeat(indentLevel);
        }
        continue;
      }
      
      // 处理换行
      if (char === '\n') {
        formatted = formatted.trimEnd() + '\n';
        // 跳过多余的空白
        while (code[i + 1] === ' ' || code[i + 1] === '\t' || code[i + 1] === '\n') {
          i++;
        }
        if (code[i + 1]) {
          formatted += indentStr.repeat(indentLevel);
        }
        continue;
      }
      
      formatted += char;
    }
    
    return formatted.trim();
  }

  /**
   * 格式化 JSON
   */
  private formatJSON(code: string): string {
    try {
      const obj: Object = JSON.parse(code);
      return JSON.stringify(obj, null, 2);
    } catch (e) {
      return code; // 解析失败，返回原文
    }
  }

  /**
   * 格式化 HTML
   */
  private formatHTML(code: string): string {
    let formatted = '';
    let indentLevel = 0;
    const indentStr = '  ';
    let inTag = false;
    let tagContent = '';
    
    for (let i = 0; i < code.length; i++) {
      const char = code[i];
      
      if (char === '<') {
        if (tagContent.trim()) {
          formatted += tagContent;
        }
        tagContent = '';
        inTag = true;
        
        // 检查是否是闭合标签
        if (code[i + 1] === '/') {
          indentLevel = Math.max(0, indentLevel - 1);
          formatted = formatted.trimEnd() + '\n' + indentStr.repeat(indentLevel);
        } else if (formatted.length > 0) {
          formatted += '\n' + indentStr.repeat(indentLevel);
        }
      }
      
      if (inTag) {
        tagContent += char;
      } else {
        formatted += char;
      }
      
      if (char === '>') {
        inTag = false;
        formatted += tagContent;
        tagContent = '';
        
        // 检查是否是自闭合标签或特殊标签
        const isSelfClosing = formatted.endsWith('/>');
        const isSpecialTag = /<(br|hr|img|input|meta|link)/.test(formatted.substring(formatted.lastIndexOf('<')));
        
        if (!isSelfClosing && !isSpecialTag && code[i - 1] !== '/') {
          indentLevel++;
        }
      }
    }
    
    return formatted.trim();
  }

  /**
   * 格式化 CSS
   */
  private formatCSS(code: string): string {
    let formatted = '';
    let indentLevel = 0;
    const indentStr = '  ';
    
    for (let i = 0; i < code.length; i++) {
      const char = code[i];
      
      if (char === '{') {
        formatted += ' {\n';
        indentLevel++;
        formatted += indentStr.repeat(indentLevel);
        continue;
      }
      
      if (char === '}') {
        indentLevel = Math.max(0, indentLevel - 1);
        formatted = formatted.trimEnd() + '\n' + indentStr.repeat(indentLevel) + '}\n';
        if (code[i + 1]) {
          formatted += indentStr.repeat(indentLevel);
        }
        continue;
      }
      
      if (char === ';') {
        formatted += ';\n' + indentStr.repeat(indentLevel);
        continue;
      }
      
      if (char === '\n') {
        continue; // 跳过原有换行
      }
      
      formatted += char;
    }
    
    return formatted.trim();
  }

  /**
   * 通用格式化（整理缩进）
   */
  private formatGeneric(code: string): string {
    const lines = code.split('\n');
    let indentLevel = 0;
    const indentStr = '  ';
    const formatted: string[] = [];
    
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed) {
        formatted.push('');
        continue;
      }
      
      // 检查是否减少缩进
      if (trimmed.startsWith('}') || trimmed.startsWith(']') || trimmed.startsWith(')')) {
        indentLevel = Math.max(0, indentLevel - 1);
      }
      
      formatted.push(indentStr.repeat(indentLevel) + trimmed);
      
      // 检查是否增加缩进
      if (trimmed.endsWith('{') || trimmed.endsWith('[') || trimmed.endsWith('(')) {
        indentLevel++;
      }
    }
    
    return formatted.join('\n');
  }
}
