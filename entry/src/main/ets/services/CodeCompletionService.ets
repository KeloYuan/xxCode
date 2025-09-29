export interface CompletionSuggestion {
  text: string;
  type: 'keyword' | 'function' | 'variable' | 'snippet';
  description?: string;
}

export class CodeCompletionService {
  private static instance: CodeCompletionService | null = null;
  
  private completionData: Map<string, string[]> = new Map();
  
  private constructor() {
    this.initializeCompletionData();
  }
  
  public static getInstance(): CodeCompletionService {
    if (!CodeCompletionService.instance) {
      CodeCompletionService.instance = new CodeCompletionService();
    }
    return CodeCompletionService.instance;
  }
  
  private initializeCompletionData() {
    // JavaScript/TypeScript suggestions
    this.completionData.set('javascript', [
      'function', 'const', 'let', 'var', 'if', 'else', 'for', 'while', 'return', 
      'class', 'extends', 'import', 'export', 'async', 'await', 'try', 'catch'
    ]);
    this.completionData.set('typescript', [
      ...this.completionData.get('javascript') || [],
      'interface', 'type', 'enum', 'readonly', 'keyof', 'typeof'
    ]);
    
    // Add more languages as needed
  }
  
  public async getSuggestions(language: string, prefix: string, context: string): Promise<CompletionSuggestion[]> {
    try {
      const suggestions = this.completionData.get(language) || [];
      return suggestions
        .filter(word => word.startsWith(prefix) && word !== prefix)
        .map(word => ({
          text: word,
          type: 'keyword',
          description: `Keyword: ${word}`
        }));
    } catch (error) {
      console.error('Error getting suggestions:', error);
      return [];
    }
  }
}


