/**
 * 响应式布局包装器
 * 根据断点自动切换移动端/桌面端布局
 */
import { BreakpointService, Breakpoint } from '../../services/BreakpointService';
import { FileItem } from '../../services/FileManagerService';
import { Theme } from '../../services/ThemeService';
import { FileTab } from '../../models/FileTabModel';
import webview from '@ohos.web.webview';
import { MobileLayout } from './MobileLayout';
import { DesktopLayout } from './DesktopLayout';

// 编辑器状态接口
export interface EditorState {
  // 多标签状态
  tabs: FileTab[];
  currentTabId: string;
  showFileBrowser: boolean;
  sidebarWidth: number;
  internalFiles: FileItem[];
  workspacePath: string;

  // 移动端状态
  showLeftDrawer: boolean;
  showRightDrawer: boolean;
  showTabManager: boolean;

  // 运行控制台状态
  showConsole: boolean;
  consoleLogs: string[];

  // 编辑器状态
  content: string;
  fileName: string;
  isModified: boolean;
  language: string;
  lineCount: number;
  filePath: string;

  // UI 状态
  currentTheme: Theme;
  showSearchBar: boolean;
  searchText: string;
  replaceText: string;
  searchResults: number[];
  currentSearchIndex: number;
  isPreviewMode: boolean;
  fontSize: number;
  lineHeight: number;
  showLineNumbers: boolean;
  editorScale: number;

  // 避让区高度
  topRectHeight: number;
  bottomRectHeight: number;

  // Web控制器
  webController: webview.WebviewController;
}

// 回调函数接口
export interface EditorCallbacks {
  // 文件操作
  onFileClick: (file: FileItem) => void;
  onNewFile: () => void;
  onRenameFile: (file: FileItem) => void;
  onDeleteFile: (file: FileItem) => void;

  // 标签操作
  onTabClick: (tabId: string) => void;
  onTabClose: (tabId: string) => void;
  onNewTab: () => void;

  // 工具栏操作
  onToggleFileBrowser: () => void;
  onOpenSettings: () => void;
  onRunCode: () => void;
  onFormatCode: () => void;
  onToggleSearchBar: () => void;
  onTogglePreviewMode: () => void;
  onOpenTemplateDialog: () => void;
  onSaveFile: () => void;
  onOpenFile: () => void;
  onImportFile: () => void;
  onExportFile: () => void;

  // 搜索操作
  onSearchChange: (value: string) => void;
  onReplaceChange: (value: string) => void;
  onPerformSearch: () => void;
  onNextSearch: () => void;
  onPrevSearch: () => void;
  onReplaceCurrent: () => void;
  onReplaceAll: () => void;
  onCloseSearchBar: () => void;

  // 编辑器操作
  onContentChange: (content: string) => void;

  // 控制台操作
  onCloseConsole: () => void;
  onClearConsole: () => void;

  // 移动端抽屉操作
  onToggleLeftDrawer: (show: boolean) => void;
  onToggleRightDrawer: (show: boolean) => void;
  onToggleTabManager: (show: boolean) => void;

  // 菜单操作
  onMenuAction: (action: string) => void;
}

@Component
export struct ResponsiveLayout {
  @Prop breakpointService: BreakpointService;
  @State currentBreakpoint: Breakpoint = 'sm';
  @State isMobile: boolean = false;

  // 编辑器状态和回调
  @Prop state: EditorState;
  @Prop callbacks: EditorCallbacks;

  aboutToAppear() {
    this.currentBreakpoint = this.breakpointService.getCurrentBreakpoint();
    this.isMobile = this.breakpointService.isMobile();

    this.breakpointService.onChange((breakpoint: Breakpoint) => {
      this.currentBreakpoint = breakpoint;
      this.isMobile = this.breakpointService.isMobile();
    });
  }

  build() {
    if (this.isMobile) {
      // 移动端布局 - 传递 state
      MobileLayout({
        state: this.state,
        callbacks: this.callbacks,
        breakpointService: this.breakpointService
      })
    } else {
      // 桌面端布局 - 传递 state
      DesktopLayout({
        state: this.state,
        callbacks: this.callbacks,
        breakpointService: this.breakpointService
      })
    }
  }
}
