/**
 * 搜索服务
 * 提供文本搜索和替换功能
 */

export interface SearchResult {
  line: number;
  column: number;
  length: number;
  match: string;
  lineText: string;
}

export interface SearchOptions {
  caseSensitive: boolean;
  wholeWord: boolean;
  useRegex: boolean;
}

export interface MatchInfo {
  index: number;
  length: number;
  text: string;
}

export interface ReplaceResult {
  text: string;
  count: number;
}

export class SearchService {
  private static instance: SearchService | null = null;

  private constructor() {}

  public static getInstance(): SearchService {
    if (!SearchService.instance) {
      SearchService.instance = new SearchService();
    }
    return SearchService.instance;
  }

  /**
   * 在文本中搜索
   */
  public search(text: string, searchTerm: string, options: SearchOptions): SearchResult[] {
    if (!searchTerm) {
      return [];
    }

    const results: SearchResult[] = [];
    const lines = text.split('\n');

    lines.forEach((line, lineIndex) => {
      const matches = this.findInLine(line, searchTerm, options);
      matches.forEach(match => {
        results.push({
          line: lineIndex + 1,
          column: match.index + 1,
          length: match.length,
          match: match.text,
          lineText: line
        });
      });
    });

    return results;
  }

  /**
   * 在单行中查找匹配项
   */
  private findInLine(line: string, searchTerm: string, options: SearchOptions): Array<MatchInfo> {
    const matches: Array<MatchInfo> = [];
    
    try {
      if (options.useRegex) {
        // 正则表达式搜索
        const flags = options.caseSensitive ? 'g' : 'gi';
        const regex = new RegExp(searchTerm, flags);
        let match: RegExpExecArray | null;
        
        while ((match = regex.exec(line)) !== null) {
          const matchInfo: MatchInfo = {
            index: match.index,
            length: match[0].length,
            text: match[0]
          };
          matches.push(matchInfo);
        }
      } else {
        // 普通文本搜索
        const searchText = options.caseSensitive ? line : line.toLowerCase();
        const term = options.caseSensitive ? searchTerm : searchTerm.toLowerCase();
        
        let index = 0;
        while ((index = searchText.indexOf(term, index)) !== -1) {
          // 如果需要全词匹配，检查边界
          if (options.wholeWord) {
            const before = index > 0 ? line[index - 1] : ' ';
            const after = index + term.length < line.length ? line[index + term.length] : ' ';
            
            if (/\w/.test(before) || /\w/.test(after)) {
              index++;
              continue;
            }
          }
          
          const matchInfo: MatchInfo = {
            index,
            length: term.length,
            text: line.substr(index, term.length)
          };
          matches.push(matchInfo);
          
          index += term.length;
        }
      }
    } catch (error) {
      console.error('搜索错误:', error);
    }

    return matches;
  }

  /**
   * 替换文本
   */
  public replace(text: string, searchTerm: string, replaceTerm: string, options: SearchOptions): string {
    if (!searchTerm) {
      return text;
    }

    try {
      if (options.useRegex) {
        const flags = options.caseSensitive ? 'g' : 'gi';
        const regex = new RegExp(searchTerm, flags);
        return text.replace(regex, replaceTerm);
      } else {
        const searchText = options.caseSensitive ? searchTerm : new RegExp(this.escapeRegex(searchTerm), 'gi');
        return text.replace(searchText, replaceTerm);
      }
    } catch (error) {
      console.error('替换错误:', error);
      return text;
    }
  }

  /**
   * 替换所有匹配项
   */
  public replaceAll(text: string, searchTerm: string, replaceTerm: string, options: SearchOptions): ReplaceResult {
    if (!searchTerm) {
      const result: ReplaceResult = { text, count: 0 };
      return result;
    }

    const results = this.search(text, searchTerm, options);
    const newText = this.replace(text, searchTerm, replaceTerm, options);

    const result: ReplaceResult = {
      text: newText,
      count: results.length
    };
    return result;
  }

  /**
   * 转义正则表达式特殊字符
   */
  private escapeRegex(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  /**
   * 高亮搜索结果
   */
  public highlightMatches(text: string, results: SearchResult[]): string {
    // 返回带有高亮标记的文本（简化实现）
    let highlighted = text;
    // 实际应用中需要更复杂的处理
    return highlighted;
  }
}

