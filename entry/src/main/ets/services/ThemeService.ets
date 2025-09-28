export interface ThemeColors {
  // 背景颜色
  background: string;
  surface: string;
  surfaceVariant: string;

  // 文本颜色
  textPrimary: string;
  textSecondary: string;
  textDisabled: string;

  // 主要颜色
  primary: string;
  primaryVariant: string;
  secondary: string;
  secondaryVariant: string;

  // 功能性颜色
  error: string;
  warning: string;
  success: string;
  info: string;

  // 边框和分割线
  divider: string;
  border: string;

  // 特殊颜色
  codeBackground: string;
  selection: string;
  hover: string;
}

export interface Theme {
  id: string;
  name: string;
  type: 'light' | 'dark';
  colors: ThemeColors;
}

export class ThemeService {
  private currentTheme: Theme;
  private themes: Map<string, Theme> = new Map();
  private themeChangeListeners: Function[] = [];

  constructor() {
    this.initializeThemes();
    this.currentTheme = this.themes.get('light')!;
  }

  private initializeThemes(): void {
    // 浅色主题
    const lightTheme: Theme = {
      id: 'light',
      name: '浅色主题',
      type: 'light',
      colors: {
        background: '#FFFFFF',
        surface: '#F8F9FA',
        surfaceVariant: '#E9ECEF',

        textPrimary: '#212529',
        textSecondary: '#6C757D',
        textDisabled: '#ADB5BD',

        primary: '#007BFF',
        primaryVariant: '#0056B3',
        secondary: '#6C757D',
        secondaryVariant: '#545B62',

        error: '#DC3545',
        warning: '#FFC107',
        success: '#28A745',
        info: '#17A2B8',

        divider: '#DEE2E6',
        border: '#CED4DA',

        codeBackground: '#F8F9FA',
        selection: '#007BFF33',
        hover: '#007BFF0D'
      }
    };

    // 深色主题
    const darkTheme: Theme = {
      id: 'dark',
      name: '深色主题',
      type: 'dark',
      colors: {
        background: '#121212',
        surface: '#1E1E1E',
        surfaceVariant: '#2A2A2A',

        textPrimary: '#FFFFFF',
        textSecondary: '#B3B3B3',
        textDisabled: '#666666',

        primary: '#BB86FC',
        primaryVariant: '#9965F4',
        secondary: '#03DAC6',
        secondaryVariant: '#00B3A6',

        error: '#CF6679',
        warning: '#FFB74D',
        success: '#81C784',
        info: '#4FC3F7',

        divider: '#333333',
        border: '#404040',

        codeBackground: '#1E1E1E',
        selection: '#BB86FC33',
        hover: '#BB86FC0D'
      }
    };

    // 鸿蒙主题（Material You风格）
    const harmonyTheme: Theme = {
      id: 'harmony',
      name: '鸿蒙主题',
      type: 'light',
      colors: {
        background: '#FEFEFE',
        surface: '#F7F7F7',
        surfaceVariant: '#EEEEEE',

        textPrimary: '#1A1A1A',
        textSecondary: '#666666',
        textDisabled: '#999999',

        primary: '#007DFF',
        primaryVariant: '#005BCC',
        secondary: '#FF6B35',
        secondaryVariant: '#E85D2E',

        error: '#FF4757',
        warning: '#FFA726',
        success: '#66BB6A',
        info: '#42A5F5',

        divider: '#E0E0E0',
        border: '#D0D0D0',

        codeBackground: '#FAFAFA',
        selection: '#007DFF33',
        hover: '#007DFF0D'
      }
    };

    this.themes.set('light', lightTheme);
    this.themes.set('dark', darkTheme);
    this.themes.set('harmony', harmonyTheme);
  }

  /**
   * 获取当前主题
   */
  getCurrentTheme(): Theme {
    return this.currentTheme;
  }

  /**
   * 获取所有可用主题
   */
  getAvailableThemes(): Theme[] {
    return Array.from(this.themes.values());
  }

  /**
   * 切换主题
   */
  switchTheme(themeId: string): boolean {
    const theme = this.themes.get(themeId);
    if (!theme) {
      console.error(`Theme ${themeId} not found`);
      return false;
    }

    this.currentTheme = theme;
    this.notifyThemeChange(theme);
    return true;
  }

  /**
   * 根据系统偏好自动选择主题
   */
  autoSwitchTheme(): void {
    // 这里可以根据系统设置自动选择明暗主题
    // 暂时默认使用浅色主题
    this.switchTheme('light');
  }

  /**
   * 获取主题颜色值
   */
  getColor(colorKey: keyof ThemeColors): string {
    const colors = this.currentTheme.colors;
    switch (colorKey) {
      case 'background': return colors.background;
      case 'surface': return colors.surface;
      case 'surfaceVariant': return colors.surfaceVariant;
      case 'textPrimary': return colors.textPrimary;
      case 'textSecondary': return colors.textSecondary;
      case 'textDisabled': return colors.textDisabled;
      case 'primary': return colors.primary;
      case 'primaryVariant': return colors.primaryVariant;
      case 'secondary': return colors.secondary;
      case 'secondaryVariant': return colors.secondaryVariant;
      case 'error': return colors.error;
      case 'warning': return colors.warning;
      case 'success': return colors.success;
      case 'info': return colors.info;
      case 'divider': return colors.divider;
      case 'border': return colors.border;
      case 'codeBackground': return colors.codeBackground;
      case 'selection': return colors.selection;
      case 'hover': return colors.hover;
      default: return '';
    }
  }

  /**
   * 监听主题变化
   */
  onThemeChange(callback: Function): void {
    this.themeChangeListeners.push(callback);
  }

  /**
   * 移除主题变化监听器
   */
  removeThemeChangeListener(callback: Function): void {
    const index = this.themeChangeListeners.indexOf(callback);
    if (index > -1) {
      this.themeChangeListeners.splice(index, 1);
    }
  }

  /**
   * 通知主题变化
   */
  private notifyThemeChange(theme: Theme): void {
    this.themeChangeListeners.forEach(listener => {
      try {
        listener(theme);
      } catch (error) {
        console.error('Theme change listener error:', error);
      }
    });
  }

  /**
   * 应用主题到全局样式（如果需要）
   */
  applyThemeToGlobalStyles(): void {
    // 这里可以添加逻辑来应用主题到CSS变量或全局样式
    console.log('Applying theme:', this.currentTheme.name);
  }

  /**
   * 保存主题设置到持久化存储
   */
  async saveThemePreference(themeId: string): Promise<boolean> {
    try {
      // 这里应该保存到Preferences或其他持久化存储
      console.log('Saving theme preference:', themeId);
      return true;
    } catch (error) {
      console.error('Failed to save theme preference:', error);
      return false;
    }
  }

  /**
   * 从持久化存储加载主题设置
   */
  async loadThemePreference(): Promise<string | null> {
    try {
      // 这里应该从Preferences或其他持久化存储加载
      console.log('Loading theme preference');
      return 'light'; // 默认返回浅色主题
    } catch (error) {
      console.error('Failed to load theme preference:', error);
      return null;
    }
  }
}
