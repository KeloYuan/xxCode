/**
 * 通用常量定义
 */
export class CommonConstants {
  // Z-Index 层级
  static readonly OVERLAY_Z_INDEX: number = 1000;
  static readonly DIALOG_Z_INDEX: number = 900;
  static readonly TOAST_Z_INDEX: number = 800;
  
  // 编辑器配置
  static readonly MAX_FILE_SIZE: number = 10 * 1024 * 1024; // 10MB
  static readonly MAX_TABS: number = 10;
  static readonly MAX_RECENT_FILES: number = 20;
  
  // 自动保存间隔（毫秒）
  static readonly AUTO_SAVE_INTERVAL: number = 30000; // 30秒
  
  // 字体大小范围
  static readonly MIN_FONT_SIZE: number = 10;
  static readonly MAX_FONT_SIZE: number = 30;
  static readonly DEFAULT_FONT_SIZE: number = 14;
  
  // Tab 大小选项
  static readonly TAB_SIZES: number[] = [2, 4, 8];
  static readonly DEFAULT_TAB_SIZE: number = 2;
  
  // 动画时长
  static readonly ANIMATION_DURATION_SHORT: number = 200;
  static readonly ANIMATION_DURATION_NORMAL: number = 300;
  static readonly ANIMATION_DURATION_LONG: number = 500;
}

