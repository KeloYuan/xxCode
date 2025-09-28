export interface MarkdownElement {
  type: 'heading' | 'paragraph' | 'code' | 'list' | 'blockquote' | 'link' | 'image' | 'text';
  content: string;
  level?: number;
  language?: string;
  items?: string[];
  href?: string;
  alt?: string;
  children?: MarkdownElement[];
}

export class MarkdownService {
  /**
   * 解析Markdown文本为结构化元素
   */
  parseMarkdown(text: string): MarkdownElement[] {
    const lines = text.split('\n');
    const elements: MarkdownElement[] = [];
    let i = 0;

    while (i < lines.length) {
      const line = lines[i].trim();

      if (line === '') {
        i++;
        continue;
      }

      // 标题
      if (line.startsWith('#')) {
        const match = line.match(/^(#{1,6})\s+(.+)$/);
        if (match) {
          elements.push({
            type: 'heading',
            content: match[2],
            level: match[1].length
          });
          i++;
          continue;
        }
      }

      // 代码块
      if (line.startsWith('```')) {
        const codeBlock = this.parseCodeBlock(lines, i);
        elements.push(codeBlock);
        i += codeBlock.items!.length + 2; // +2 for opening and closing ```
        continue;
      }

      // 列表
      if (line.startsWith('- ') || line.startsWith('* ') || /^\d+\.\s/.test(line)) {
        const list = this.parseList(lines, i);
        elements.push(list);
        i += list.items!.length;
        continue;
      }

      // 引用
      if (line.startsWith('> ')) {
        const quote = this.parseBlockquote(lines, i);
        elements.push(quote);
        i += quote.items!.length;
        continue;
      }

      // 普通段落
      const paragraph = this.parseParagraph(lines, i);
      if (paragraph.content) {
        elements.push(paragraph);
        i += paragraph.items!.length;
      } else {
        i++;
      }
    }

    return elements;
  }

  private parseCodeBlock(lines: string[], startIndex: number): MarkdownElement {
    const languageMatch = lines[startIndex].match(/```(\w+)?/);
    const language = languageMatch ? languageMatch[1] : '';

    const codeLines: string[] = [];
    let i = startIndex + 1;

    while (i < lines.length && !lines[i].trim().startsWith('```')) {
      codeLines.push(lines[i]);
      i++;
    }

    return {
      type: 'code',
      content: codeLines.join('\n'),
      language: language || 'text',
      items: codeLines
    };
  }

  private parseList(lines: string[], startIndex: number): MarkdownElement {
    const items: string[] = [];
    let i = startIndex;

    while (i < lines.length) {
      const line = lines[i].trim();

      if (line === '') break;

      if (line.startsWith('- ') || line.startsWith('* ')) {
        items.push(line.substring(2));
      } else if (/^\d+\.\s/.test(line)) {
        items.push(line.replace(/^\d+\.\s/, ''));
      } else {
        break;
      }

      i++;
    }

    return {
      type: 'list',
      content: items.join('\n'),
      items: items
    };
  }

  private parseBlockquote(lines: string[], startIndex: number): MarkdownElement {
    const items: string[] = [];
    let i = startIndex;

    while (i < lines.length) {
      const line = lines[i].trim();

      if (line === '') break;

      if (line.startsWith('> ')) {
        items.push(line.substring(2));
      } else {
        break;
      }

      i++;
    }

    return {
      type: 'blockquote',
      content: items.join('\n'),
      items: items
    };
  }

  private parseParagraph(lines: string[], startIndex: number): MarkdownElement {
    const items: string[] = [];
    let i = startIndex;

    while (i < lines.length) {
      const line = lines[i].trim();

      if (line === '') break;

      // 如果是其他类型的行，停止解析段落
      if (line.startsWith('#') || line.startsWith('```') ||
          line.startsWith('- ') || line.startsWith('* ') ||
          /^\d+\.\s/.test(line) || line.startsWith('> ')) {
        break;
      }

      items.push(line);
      i++;
    }

    return {
      type: 'paragraph',
      content: items.join(' '),
      items: items
    };
  }

  /**
   * 将Markdown元素转换为文本（用于显示）
   */
  elementToText(element: MarkdownElement): string {
    switch (element.type) {
      case 'heading':
        return '#'.repeat(element.level || 1) + ' ' + element.content;
      case 'code':
        return '```' + (element.language || '') + '\n' + element.content + '\n```';
      case 'list':
        return element.items?.map(item => '- ' + item).join('\n') || '';
      case 'blockquote':
        return element.items?.map(item => '> ' + item).join('\n') || '';
      case 'paragraph':
      default:
        return element.content;
    }
  }

  /**
   * 检查文本是否为Markdown文件
   */
  isMarkdownFile(fileName: string): boolean {
    return fileName.toLowerCase().endsWith('.md');
  }

  /**
   * 获取Markdown语法支持的功能列表
   */
  getSupportedFeatures(): string[] {
    return [
      '标题 (H1-H6)',
      '段落',
      '代码块',
      '无序列表',
      '有序列表',
      '引用块',
      '行内代码'
    ];
  }
}
