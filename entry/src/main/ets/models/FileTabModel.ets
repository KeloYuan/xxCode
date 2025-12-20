/**
 * 文件标签模型
 * 用于多标签编辑器
 */

export class FileTab {
  id: string;
  fileName: string;
  filePath: string;
  content: string;
  isModified: boolean;
  language: string;

  constructor(
    id: string,
    fileName: string,
    filePath: string,
    content: string = '',
    language: string = 'text'
  ) {
    this.id = id;
    this.fileName = fileName;
    this.filePath = filePath;
    this.content = content;
    this.isModified = false;
    this.language = language;
  }

  /**
   * 生成唯一ID
   */
  static generateId(): string {
    return `tab_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 从文件路径获取语言类型
   */
  static getLanguageFromPath(filePath: string): string {
    const ext = filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
    const langMap: Record<string, string> = {
      'js': 'javascript',
      'ts': 'typescript',
      'ets': 'typescript',
      'py': 'python',
      'java': 'java',
      'html': 'html',
      'css': 'css',
      'json': 'json',
      'md': 'markdown',
      'txt': 'text'
    };
    return langMap[ext] || 'text';
  }
}
