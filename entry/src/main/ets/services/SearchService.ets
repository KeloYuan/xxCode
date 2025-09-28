export interface SearchResult {
  filePath: string;
  fileName: string;
  lineNumber: number;
  columnNumber: number;
  lineContent: string;
  matchedText: string;
  matchType: 'exact' | 'partial' | 'regex';
}

export interface SearchOptions {
  query: string;
  caseSensitive: boolean;
  useRegex: boolean;
  searchInContent: boolean;
  searchInFileNames: boolean;
  fileExtensions: string[];
}

interface MatchInfo {
  text: string;
  start: number;
}

export class SearchService {
  private searchCache: Map<string, SearchResult[]> = new Map();

  /**
   * 执行搜索
   */
  async search(options: SearchOptions): Promise<SearchResult[]> {
    const cacheKey = this.generateCacheKey(options);
    const cached = this.searchCache.get(cacheKey);

    if (cached) {
      return cached;
    }

    const results: SearchResult[] = [];

    try {
      if (options.searchInFileNames) {
        const fileNameResults = await this.searchFileNames(options);
        results.push(...fileNameResults);
      }

      if (options.searchInContent) {
        const contentResults = await this.searchInContent(options);
        results.push(...contentResults);
      }

      // 去重和排序
      const uniqueResults = this.deduplicateResults(results);
      const sortedResults = this.sortResults(uniqueResults);

      this.searchCache.set(cacheKey, sortedResults);
      return sortedResults;
    } catch (error) {
      console.error('搜索失败:', error);
      return [];
    }
  }

  /**
   * 搜索文件名
   */
  private async searchFileNames(options: SearchOptions): Promise<SearchResult[]> {
    const results: SearchResult[] = [];

    // 这里应该获取实际的文件列表
    // 暂时使用模拟数据
    const mockFiles = [
      '/src/main.js',
      '/src/utils/helpers.js',
      '/README.md',
      '/package.json',
      '/src/components/Button.js'
    ];

    for (const filePath of mockFiles) {
      const fileName = filePath.split('/').pop() || '';

      if (this.matchesQuery(fileName, options)) {
        results.push({
          filePath,
          fileName,
          lineNumber: 0,
          columnNumber: 0,
          lineContent: fileName,
          matchedText: fileName,
          matchType: options.useRegex ? 'regex' : 'partial'
        });
      }
    }

    return results;
  }

  /**
   * 搜索文件内容
   */
  private async searchInContent(options: SearchOptions): Promise<SearchResult[]> {
    const results: SearchResult[] = [];

    // 这里应该读取实际文件内容并搜索
    // 暂时使用模拟数据
    const mockFileContents: Record<string, string> = {
      '/src/main.js': `function main() {
  console.log('Hello World');
  const message = 'This is a test';
  return message;
}`,
      '/src/utils/helpers.js': `export function helper() {
  return 'helper function';
}`,
      '/README.md': `# 项目说明
这是一个示例项目。
包含以下功能：
- 文件管理
- 代码编辑
- 搜索功能`
    };

    const entries = Object.entries(mockFileContents);
    for (let i = 0; i < entries.length; i++) {
      const filePath = entries[i][0];
      const content = entries[i][1];
      const lines = content.split('\n');

      for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        const line = lines[lineIndex];

        if (this.matchesQuery(line, options)) {
          const match = this.findMatchInLine(line, options);
          if (match) {
            results.push({
              filePath,
              fileName: filePath.split('/').pop() || '',
              lineNumber: lineIndex + 1,
              columnNumber: match.start,
              lineContent: line,
              matchedText: match.text,
              matchType: options.useRegex ? 'regex' : 'partial'
            });
          }
        }
      }
    }

    return results;
  }

  /**
   * 检查文本是否匹配查询
   */
  private matchesQuery(text: string, options: SearchOptions): boolean {
    let query = options.query;
    let searchText = text;

    if (!options.caseSensitive) {
      query = query.toLowerCase();
      searchText = searchText.toLowerCase();
    }

    if (options.useRegex) {
      try {
        const regex = new RegExp(query, options.caseSensitive ? 'g' : 'gi');
        return regex.test(searchText);
      } catch (error) {
        // 无效的正则表达式
        return false;
      }
    } else {
      return searchText.includes(query);
    }
  }

  /**
   * 在行中查找匹配
   */
  private findMatchInLine(line: string, options: SearchOptions): MatchInfo | null {
    let query = options.query;
    let searchText = line;

    if (!options.caseSensitive) {
      query = query.toLowerCase();
      searchText = searchText.toLowerCase();
    }

    let start = -1;
    if (options.useRegex) {
      try {
        const regex = new RegExp(query, options.caseSensitive ? 'g' : 'gi');
        const match = regex.exec(searchText);
        if (match) {
          start = match.index;
        }
      } catch (error) {
        return null;
      }
    } else {
      start = searchText.indexOf(query);
    }

    if (start !== -1) {
      const end = start + query.length;
      const matchInfo: MatchInfo = {
        text: line.substring(start, end),
        start
      };
      return matchInfo;
    }

    return null;
  }

  /**
   * 去重搜索结果
   */
  private deduplicateResults(results: SearchResult[]): SearchResult[] {
    const seen = new Set<string>();
    return results.filter(result => {
      const key = `${result.filePath}:${result.lineNumber}:${result.columnNumber}`;
      if (seen.has(key)) {
        return false;
      }
      seen.add(key);
      return true;
    });
  }

  /**
   * 排序搜索结果
   */
  private sortResults(results: SearchResult[]): SearchResult[] {
    return results.sort((a, b) => {
      // 按文件路径排序
      if (a.filePath !== b.filePath) {
        return a.filePath.localeCompare(b.filePath);
      }
      // 按行号排序
      return a.lineNumber - b.lineNumber;
    });
  }

  /**
   * 生成缓存键
   */
  private generateCacheKey(options: SearchOptions): string {
    return `${options.query}_${options.caseSensitive}_${options.useRegex}_${options.searchInContent}_${options.searchInFileNames}_${options.fileExtensions.join(',')}`;
  }

  /**
   * 清空搜索缓存
   */
  clearCache(): void {
    this.searchCache.clear();
  }

  /**
   * 获取搜索建议（基于历史搜索）
   */
  getSearchSuggestions(): string[] {
    // 这里可以从历史搜索记录中获取建议
    return [
      'function',
      'const',
      'import',
      'export',
      'class',
      'console.log',
      'README',
      'package.json'
    ];
  }

  /**
   * 高亮搜索结果中的匹配文本
   */
  highlightMatch(text: string, query: string, caseSensitive: boolean = false): string {
    if (!query) return text;

    let searchText = text;
    let searchQuery = query;

    if (!caseSensitive) {
      searchText = searchText.toLowerCase();
      searchQuery = searchQuery.toLowerCase();
    }

    const index = searchText.indexOf(searchQuery);
    if (index === -1) return text;

    const before = text.substring(0, index);
    const match = text.substring(index, index + query.length);
    const after = text.substring(index + query.length);

    return `${before}<mark>${match}</mark>${after}`;
  }
}
