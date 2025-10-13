/**
 * 断点系统服务
 * 实现 HarmonyOS 一次开发多端部署的核心能力
 */

import mediaquery from '@ohos.mediaquery';

export type Breakpoint = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

export interface BreakpointConfig {
  name: Breakpoint;
  minWidth: number;
  maxWidth: number;
  columns: number;
  gutter: number;
  margin: number;
}

/**
 * HarmonyOS 标准断点配置
 */
export class BreakpointConfigs {
  static readonly xs: BreakpointConfig = {
    name: 'xs',
    minWidth: 0,
    maxWidth: 320,
    columns: 4,
    gutter: 12,
    margin: 12
  };
  
  static readonly sm: BreakpointConfig = {
    name: 'sm',
    minWidth: 320,
    maxWidth: 600,
    columns: 4,
    gutter: 16,
    margin: 16
  };
  
  static readonly md: BreakpointConfig = {
    name: 'md',
    minWidth: 600,
    maxWidth: 840,
    columns: 8,
    gutter: 24,
    margin: 24
  };
  
  static readonly lg: BreakpointConfig = {
    name: 'lg',
    minWidth: 840,
    maxWidth: 1280,
    columns: 12,
    gutter: 24,
    margin: 32
  };
  
  static readonly xl: BreakpointConfig = {
    name: 'xl',
    minWidth: 1280,
    maxWidth: Infinity,
    columns: 12,
    gutter: 32,
    margin: 48
  };

  static get(breakpoint: Breakpoint): BreakpointConfig {
    switch (breakpoint) {
      case 'xs': return BreakpointConfigs.xs;
      case 'sm': return BreakpointConfigs.sm;
      case 'md': return BreakpointConfigs.md;
      case 'lg': return BreakpointConfigs.lg;
      case 'xl': return BreakpointConfigs.xl;
    }
  }
}

export class BreakpointService {
  private static instance: BreakpointService | null = null;
  
  private currentBreakpoint: Breakpoint = 'sm';
  private listeners: ((breakpoint: Breakpoint) => void)[] = [];
  
  private xsListener: mediaquery.MediaQueryListener;
  private smListener: mediaquery.MediaQueryListener;
  private mdListener: mediaquery.MediaQueryListener;
  private lgListener: mediaquery.MediaQueryListener;
  private xlListener: mediaquery.MediaQueryListener;
  
  private isRegistered: boolean = false;

  private constructor() {
    this.xsListener = mediaquery.matchMediaSync('(0vp <= width < 320vp)');
    this.smListener = mediaquery.matchMediaSync('(320vp <= width < 600vp)');
    this.mdListener = mediaquery.matchMediaSync('(600vp <= width < 840vp)');
    this.lgListener = mediaquery.matchMediaSync('(840vp <= width < 1280vp)');
    this.xlListener = mediaquery.matchMediaSync('(width >= 1280vp)');
  }

  public static getInstance(): BreakpointService {
    if (!BreakpointService.instance) {
      BreakpointService.instance = new BreakpointService();
    }
    return BreakpointService.instance;
  }

  public register(): void {
    if (this.isRegistered) {
      return;
    }

    this.xsListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint('xs');
      }
    });

    this.smListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint('sm');
      }
    });

    this.mdListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint('md');
      }
    });

    this.lgListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint('lg');
      }
    });

    this.xlListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint('xl');
      }
    });

    this.currentBreakpoint = this.detectCurrentBreakpoint();
    this.isRegistered = true;
  }

  public unregister(): void {
    if (!this.isRegistered) {
      return;
    }

    this.xsListener.off('change');
    this.smListener.off('change');
    this.mdListener.off('change');
    this.lgListener.off('change');
    this.xlListener.off('change');
    
    this.isRegistered = false;
  }

  public onChange(callback: (breakpoint: Breakpoint) => void): void {
    this.listeners.push(callback);
  }

  public removeChangeListener(callback: (breakpoint: Breakpoint) => void): void {
    const index = this.listeners.indexOf(callback);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  public getCurrentBreakpoint(): Breakpoint {
    return this.currentBreakpoint;
  }

  public getCurrentConfig(): BreakpointConfig {
    return BreakpointConfigs.get(this.currentBreakpoint);
  }

  public isPhone(): boolean {
    return this.currentBreakpoint === 'xs' || this.currentBreakpoint === 'sm';
  }

  public isTablet(): boolean {
    return this.currentBreakpoint === 'md' || this.currentBreakpoint === 'lg';
  }

  public isDesktop(): boolean {
    return this.currentBreakpoint === 'xl';
  }

  public isSmallScreen(): boolean {
    return ['xs', 'sm', 'md'].includes(this.currentBreakpoint);
  }

  public isLargeScreen(): boolean {
    return ['lg', 'xl'].includes(this.currentBreakpoint);
  }

  private detectCurrentBreakpoint(): Breakpoint {
    if (this.xsListener.matches) {
      return 'xs';
    } else if (this.smListener.matches) {
      return 'sm';
    } else if (this.mdListener.matches) {
      return 'md';
    } else if (this.lgListener.matches) {
      return 'lg';
    } else if (this.xlListener.matches) {
      return 'xl';
    }
    return 'sm';
  }

  private updateBreakpoint(breakpoint: Breakpoint): void {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      
      this.listeners.forEach(listener => {
        try {
          listener(breakpoint);
        } catch (error) {
          console.error('[BreakpointService] 监听器执行错误:', error);
        }
      });
    }
  }
}

/**
 * 响应式字体配置
 */
export interface ResponsiveFontConfig {
  xs?: number;
  sm?: number;
  md?: number;
  lg?: number;
  xl?: number;
}

/**
 * 响应式尺寸配置
 */
export interface ResponsiveSizeConfig {
  xs?: number | string;
  sm?: number | string;
  md?: number | string;
  lg?: number | string;
  xl?: number | string;
}

/**
 * 响应式布局工具类
 */
export class ResponsiveUtils {
  public static getFontSize(config: ResponsiveFontConfig): number {
    const breakpoint = BreakpointService.getInstance().getCurrentBreakpoint();
    switch (breakpoint) {
      case 'xs': return config.xs ?? config.sm ?? 14;
      case 'sm': return config.sm ?? 14;
      case 'md': return config.md ?? config.sm ?? 14;
      case 'lg': return config.lg ?? config.md ?? config.sm ?? 14;
      case 'xl': return config.xl ?? config.lg ?? config.md ?? config.sm ?? 14;
      default: return 14;
    }
  }

  public static getWidth(config: ResponsiveSizeConfig): number | string {
    const breakpoint = BreakpointService.getInstance().getCurrentBreakpoint();
    switch (breakpoint) {
      case 'xs': return config.xs ?? config.sm ?? '100%';
      case 'sm': return config.sm ?? '100%';
      case 'md': return config.md ?? config.sm ?? '100%';
      case 'lg': return config.lg ?? config.md ?? config.sm ?? '100%';
      case 'xl': return config.xl ?? config.lg ?? config.md ?? config.sm ?? '100%';
      default: return '100%';
    }
  }

  public static getMargin(): number {
    return BreakpointService.getInstance().getCurrentConfig().margin;
  }

  public static getGutter(): number {
    return BreakpointService.getInstance().getCurrentConfig().gutter;
  }
}

