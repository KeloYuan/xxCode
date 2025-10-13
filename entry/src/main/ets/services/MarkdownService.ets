/**
 * Markdown 服务
 * 提供 Markdown 文件的识别和预览功能
 */

export interface OutlineItem {
  level: number;
  text: string;
  line: number;
}

export interface MarkdownStats {
  words: number;
  characters: number;
  lines: number;
  headings: number;
}

export class MarkdownService {
  private static instance: MarkdownService | null = null;

  private constructor() {}

  public static getInstance(): MarkdownService {
    if (!MarkdownService.instance) {
      MarkdownService.instance = new MarkdownService();
    }
    return MarkdownService.instance;
  }

  /**
   * 判断文件是否为 Markdown 文件
   */
  public isMarkdownFile(fileName: string): boolean {
    const ext = fileName.split('.').pop()?.toLowerCase() || '';
    return ext === 'md' || ext === 'markdown';
  }

  /**
   * 将 Markdown 转换为简单的 HTML（用于预览）
   */
  public convertToHtml(markdown: string): string {
    let html = markdown;

    // 标题
    html = html.replace(/^### (.*$)/gim, '<h3>$1</h3>');
    html = html.replace(/^## (.*$)/gim, '<h2>$1</h2>');
    html = html.replace(/^# (.*$)/gim, '<h1>$1</h1>');

    // 加粗
    html = html.replace(/\*\*(.*?)\*\*/gim, '<strong>$1</strong>');
    html = html.replace(/__(.*?)__/gim, '<strong>$1</strong>');

    // 斜体
    html = html.replace(/\*(.*?)\*/gim, '<em>$1</em>');
    html = html.replace(/_(.*?)_/gim, '<em>$1</em>');

    // 代码块
    html = html.replace(/```([\s\S]*?)```/gim, '<pre><code>$1</code></pre>');

    // 行内代码
    html = html.replace(/`([^`]+)`/gim, '<code>$1</code>');

    // 链接
    html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/gim, '<a href="$2">$1</a>');

    // 图片
    html = html.replace(/!\[([^\]]*)\]\(([^)]+)\)/gim, '<img src="$2" alt="$1" />');

    // 无序列表
    html = html.replace(/^\* (.*$)/gim, '<li>$1</li>');
    html = html.replace(/^- (.*$)/gim, '<li>$1</li>');
    html = html.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>');

    // 有序列表
    html = html.replace(/^\d+\. (.*$)/gim, '<li>$1</li>');

    // 段落
    html = html.replace(/\n\n/g, '</p><p>');
    html = '<p>' + html + '</p>';

    // 换行
    html = html.replace(/\n/g, '<br>');

    return html;
  }

  /**
   * 提取 Markdown 大纲（标题列表）
   */
  public extractOutline(markdown: string): Array<OutlineItem> {
    const outline: Array<OutlineItem> = [];
    const lines = markdown.split('\n');

    lines.forEach((line, index) => {
      const match = line.match(/^(#{1,6})\s+(.+)$/);
      if (match) {
        const item: OutlineItem = {
          level: match[1].length,
          text: match[2],
          line: index + 1
        };
        outline.push(item);
      }
    });

    return outline;
  }

  /**
   * 获取 Markdown 文件的统计信息
   */
  public getStats(markdown: string): MarkdownStats {
    const lines = markdown.split('\n');
    const words = markdown.split(/\s+/).filter(word => word.length > 0).length;
    const characters = markdown.length;
    const headings = markdown.match(/^#{1,6}\s+/gm)?.length || 0;

    const stats: MarkdownStats = {
      words,
      characters,
      lines: lines.length,
      headings
    };
    return stats;
  }
}

