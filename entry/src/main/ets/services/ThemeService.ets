/**
 * 主题服务
 * 管理应用的主题切换和颜色配置
 */

export interface ThemeColors {
  background: string;
  surface: string;
  primary: string;
  secondary: string;
  text: string;
  textSecondary: string;
  border: string;
  error: string;
  success: string;
  warning: string;
}

export interface EditorColors {
  background: string;
  lineNumber: string;
  selection: string;
  cursor: string;
  text: string;
}

export interface SyntaxColors {
  keyword: string;
  string: string;
  comment: string;
  number: string;
  function: string;
  variable: string;
  operator: string;
  type: string;
}

export interface Theme {
  id: string;
  name: string;
  colors: ThemeColors;
  editor: EditorColors;
  syntax: SyntaxColors;
}

export class ThemeService {
  private static instance: ThemeService | null = null;
  private currentTheme: Theme;
  private themes: Map<string, Theme> = new Map();
  private listeners: ((theme: Theme) => void)[] = [];

  private constructor() {
    this.initializeThemes();
    this.currentTheme = this.themes.get('dark')!;
  }

  public static getInstance(): ThemeService {
    if (!ThemeService.instance) {
      ThemeService.instance = new ThemeService();
    }
    return ThemeService.instance;
  }

  /**
   * 初始化内置主题
   */
  private initializeThemes(): void {
    // 深色主题（默认）
    const darkTheme: Theme = {
      id: 'dark',
      name: '深色主题',
      colors: {
        background: '#1e1e1e',
        surface: '#2d2d30',
        primary: '#667eea',
        secondary: '#764ba2',
        text: '#d4d4d4',
        textSecondary: '#cccccc',
        border: '#3e3e42',
        error: '#F56C6C',
        success: '#16a34a',
        warning: '#ffd700'
      },
      editor: {
        background: '#1e1e1e',
        lineNumber: '#858585',
        selection: '#264f78',
        cursor: '#528bff',
        text: '#d4d4d4'
      },
      syntax: {
        keyword: '#C678DD',
        string: '#98C379',
        comment: '#5C6370',
        number: '#D19A66',
        function: '#61AFEF',
        variable: '#E06C75',
        operator: '#56B6C2',
        type: '#E5C07B'
      }
    };
    this.themes.set('dark', darkTheme);

    // 浅色主题
    const lightTheme: Theme = {
      id: 'light',
      name: '浅色主题',
      colors: {
        background: '#FFFFFF',
        surface: '#F5F5F5',
        primary: '#667eea',
        secondary: '#764ba2',
        text: '#333333',
        textSecondary: '#666666',
        border: '#E0E0E0',
        error: '#F56C6C',
        success: '#16a34a',
        warning: '#ffd700'
      },
      editor: {
        background: '#FFFFFF',
        lineNumber: '#999999',
        selection: '#ADD6FF',
        cursor: '#528bff',
        text: '#333333'
      },
      syntax: {
        keyword: '#0000FF',
        string: '#A31515',
        comment: '#008000',
        number: '#098658',
        function: '#795E26',
        variable: '#001080',
        operator: '#000000',
        type: '#267F99'
      }
    };
    this.themes.set('light', lightTheme);

    // Monokai 主题
    const monokaiTheme: Theme = {
      id: 'monokai',
      name: 'Monokai',
      colors: {
        background: '#272822',
        surface: '#3E3D32',
        primary: '#F92672',
        secondary: '#66D9EF',
        text: '#F8F8F2',
        textSecondary: '#F8F8F2',
        border: '#49483E',
        error: '#F92672',
        success: '#A6E22E',
        warning: '#E6DB74'
      },
      editor: {
        background: '#272822',
        lineNumber: '#90908A',
        selection: '#49483E',
        cursor: '#F8F8F0',
        text: '#F8F8F2'
      },
      syntax: {
        keyword: '#F92672',
        string: '#E6DB74',
        comment: '#75715E',
        number: '#AE81FF',
        function: '#A6E22E',
        variable: '#F8F8F2',
        operator: '#F92672',
        type: '#66D9EF'
      }
    };
    this.themes.set('monokai', monokaiTheme);

    // Dracula 主题
    const draculaTheme: Theme = {
      id: 'dracula',
      name: 'Dracula',
      colors: {
        background: '#282A36',
        surface: '#44475A',
        primary: '#BD93F9',
        secondary: '#FF79C6',
        text: '#F8F8F2',
        textSecondary: '#F8F8F2',
        border: '#6272A4',
        error: '#FF5555',
        success: '#50FA7B',
        warning: '#F1FA8C'
      },
      editor: {
        background: '#282A36',
        lineNumber: '#6272A4',
        selection: '#44475A',
        cursor: '#F8F8F0',
        text: '#F8F8F2'
      },
      syntax: {
        keyword: '#FF79C6',
        string: '#F1FA8C',
        comment: '#6272A4',
        number: '#BD93F9',
        function: '#50FA7B',
        variable: '#F8F8F2',
        operator: '#FF79C6',
        type: '#8BE9FD'
      }
    };
    this.themes.set('dracula', draculaTheme);
  }

  /**
   * 获取当前主题
   */
  public getCurrentTheme(): Theme {
    return this.currentTheme;
  }

  /**
   * 获取所有主题
   */
  public getAllThemes(): Theme[] {
    return Array.from(this.themes.values());
  }

  /**
   * 切换主题
   */
  public switchTheme(themeId: string): boolean {
    const theme = this.themes.get(themeId);
    if (!theme) {
      console.error('主题不存在:', themeId);
      return false;
    }

    this.currentTheme = theme;
    this.notifyListeners();
    return true;
  }

  /**
   * 添加主题变化监听器
   */
  public onThemeChange(callback: (theme: Theme) => void): void {
    this.listeners.push(callback);
  }

  /**
   * 移除主题变化监听器
   */
  public removeThemeChangeListener(callback: (theme: Theme) => void): void {
    const index = this.listeners.indexOf(callback);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    this.listeners.forEach(listener => {
      try {
        listener(this.currentTheme);
      } catch (error) {
        console.error('主题监听器执行错误:', error);
      }
    });
  }

  /**
   * 保存主题偏好设置
   */
  public saveThemePreference(themeId: string): void {
    AppStorage.setOrCreate('selectedTheme', themeId);
  }

  /**
   * 加载主题偏好设置
   */
  public loadThemePreference(): void {
    const savedThemeId = AppStorage.get<string>('selectedTheme');
    if (savedThemeId && this.themes.has(savedThemeId)) {
      this.switchTheme(savedThemeId);
    }
  }

  /**
   * 获取下一个主题（用于主题切换循环）
   */
  public getNextTheme(): Theme {
    const themeIds = Array.from(this.themes.keys());
    const currentIndex = themeIds.indexOf(this.currentTheme.id);
    const nextIndex = (currentIndex + 1) % themeIds.length;
    return this.themes.get(themeIds[nextIndex])!;
  }
}

