/**
 * 主题管理器
 * 提供浅色/深色主题配置与切换
 */
import { Theme, ThemeColors } from '../models/EditorModels'

/**
 * 浅色主题
 */
export const LightTheme: Theme = {
  name: 'light',
  isDark: false,
  colors: {
    // 主色调
    primary: '#0A59F7',
    primaryLight: '#3D7BFF',

    // 背景色
    background: '#F4F5F7',
    surface: '#FFFFFF',
    surfaceVariant: '#F8F9FA',
    sidebarBg: '#FAFBFC',

    // 文字颜色
    textPrimary: '#1F2937',
    textSecondary: '#6B7280',
    textDisabled: '#9CA3AF',

    // 边框和分割线
    border: '#E5E7EB',
    divider: '#F0F1F3',

    // 交互状态
    hover: 'rgba(0, 0, 0, 0.04)',
    active: 'rgba(10, 89, 247, 0.08)',
    pressed: 'rgba(10, 89, 247, 0.12)',

    // 编辑器
    editorBg: '#FFFFFF',
    lineNumberBg: '#F8F9FA',
    lineNumber: '#9CA3AF',
    currentLineBg: 'rgba(10, 89, 247, 0.05)',
    selection: 'rgba(10, 89, 247, 0.15)',

    // 语法高亮
    syntaxKeyword: '#0000FF',
    syntaxString: '#A31515',
    syntaxNumber: '#098658',
    syntaxComment: '#008000',
    syntaxFunction: '#795E26',
    syntaxClass: '#267F99',
    syntaxVariable: '#001080',
    syntaxOperator: '#000000',
    syntaxDecorator: '#795E26',
    syntaxPunctuation: '#000000'
  }
}

/**
 * 深色主题
 */
export const DarkTheme: Theme = {
  name: 'dark',
  isDark: true,
  colors: {
    // 主色调
    primary: '#3D7BFF',
    primaryLight: '#5B93FF',

    // 背景色
    background: '#15161A',
    surface: '#1E1F26',
    surfaceVariant: '#252630',
    sidebarBg: '#1A1B21',

    // 文字颜色
    textPrimary: '#E4E6EB',
    textSecondary: '#8B8D93',
    textDisabled: '#5C5E66',

    // 边框和分割线
    border: '#2D2E36',
    divider: '#252630',

    // 交互状态
    hover: 'rgba(255, 255, 255, 0.06)',
    active: 'rgba(61, 123, 255, 0.15)',
    pressed: 'rgba(61, 123, 255, 0.25)',

    // 编辑器
    editorBg: '#1E1F26',
    lineNumberBg: '#1A1B21',
    lineNumber: '#5C5E66',
    currentLineBg: 'rgba(61, 123, 255, 0.08)',
    selection: 'rgba(61, 123, 255, 0.25)',

    // 语法高亮 (VS Code Dark+ 风格)
    syntaxKeyword: '#569CD6',
    syntaxString: '#CE9178',
    syntaxNumber: '#B5CEA8',
    syntaxComment: '#6A9955',
    syntaxFunction: '#DCDCAA',
    syntaxClass: '#4EC9B0',
    syntaxVariable: '#9CDCFE',
    syntaxOperator: '#D4D4D4',
    syntaxDecorator: '#DCDCAA',
    syntaxPunctuation: '#D4D4D4'
  }
}

/**
 * 主题管理器类
 */
export class ThemeManager {
  private static instance: ThemeManager
  private currentTheme: Theme = DarkTheme
  private listeners: ((theme: Theme) => void)[] = []

  private constructor() {}

  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager()
    }
    return ThemeManager.instance
  }

  getTheme(): Theme {
    return this.currentTheme
  }

  getColors(): ThemeColors {
    return this.currentTheme.colors
  }

  isDarkMode(): boolean {
    return this.currentTheme.isDark
  }

  setTheme(theme: Theme): void {
    this.currentTheme = theme
    this.notifyListeners()
  }

  toggleTheme(): void {
    this.currentTheme = this.currentTheme.isDark ? LightTheme : DarkTheme
    this.notifyListeners()
  }

  addListener(listener: (theme: Theme) => void): void {
    this.listeners.push(listener)
  }

  removeListener(listener: (theme: Theme) => void): void {
    const index = this.listeners.indexOf(listener)
    if (index > -1) {
      this.listeners.splice(index, 1)
    }
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this.currentTheme))
  }
}
