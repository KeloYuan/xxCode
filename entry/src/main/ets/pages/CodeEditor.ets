/**
 * xxCode 主编辑器页面
 * 简化版代码编辑器，支持新建、打开、保存文件
 */
import { router, window, curves } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';
import { ThemeService, Theme } from '../services/ThemeService';
import { BreakpointService, Breakpoint } from '../services/BreakpointService';
import { SyntaxHighlightService, Token } from '../services/SyntaxHighlightService';
import { CodeFormatterService } from '../services/CodeFormatterService';
import { FileManagerService, FileItem } from '../services/FileManagerService';
import { FileTab } from '../models/FileTabModel';
import { CodeTemplate, CodeTemplateData } from '../models/CodeTemplateModel';
import { IconButton } from '../components/IconButton';
import { TabBar } from '../components/TabBar';
import { FileBrowser } from '../components/FileBrowser';
import { NewFileDialog } from '../components/NewFileDialog';
import { TemplateDialog } from '../components/TemplateDialog';
import { CodeEditorView } from '../components/CodeEditorView';
import { DrawerPanel } from '../components/DrawerPanel';
import { MobileMenu } from '../components/MobileMenu';
import { BottomSheet } from '../components/BottomSheet';
import { TabManagerPanel } from '../components/TabManagerPanel';
import { ConsolePanel } from '../components/ConsolePanel';
import { LetterDialog } from '../components/LetterDialog';
import { ResponsiveLayout, EditorState, EditorCallbacks } from '../components/layouts/ResponsiveLayout';
import { promptAction } from '@kit.ArkUI';
import webview from '@ohos.web.webview';

// 文件类型配置
interface FileTypeOption {
  name: string;
  suffix: string;
  language: string;
}

interface WindowBackgroundSetter {
  setWindowBackgroundColor?: (color: string) => void;
}

// 保存对话框参数
interface SaveDialogOptions {
  newFileNames: string[]
  fileSuffixChoices?: string[]
}

interface RecentFileEntry {
  name: string;
  path: string;
  lastOpened: number;
}

@Entry
@Component
struct CodeEditor {
  // 页面转场动画 - 统一的滑动效果
  pageTransition() {
    PageTransitionEnter({ duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
  
  // 多标签状态
  @State tabs: FileTab[] = [];
  @State currentTabId: string = '';
  @State showFileBrowser: boolean = true;
  @State sidebarWidth: number = 200; // 侧边栏宽度
  @State internalFiles: FileItem[] = [];
  
  // 移动端状态
  @State isMobileMode: boolean = false;
  @State showLeftDrawer: boolean = false;
  @State showRightDrawer: boolean = false;
  @State showTabManager: boolean = false;
  
  // 运行控制台状态
  @State showConsole: boolean = false;
  @State consoleLogs: string[] = [];
  private webController: webview.WebviewController = new webview.WebviewController();
  
  // 编辑器状态（当前标签）
  @State content: string = '';
  @State fileName: string = '未命名';
  @State filePath: string = '';
  @State isModified: boolean = false;
  @State language: string = 'text';
  @State lineCount: number = 1;
  
  // UI 状态
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  @State currentBreakpoint: Breakpoint = 'sm';
  @State showFileTypeMenu: boolean = false;
  @State isPreviewMode: boolean = false; // 预览模式（显示高亮）
  @State fontSize: number = 14; // 字体大小
  @State lineHeight: number = 22; // 行高
  @State showLineNumbers: boolean = true; // 是否显示行号
  @State editorScale: number = 1; // 编辑器缩放
  @State workspacePath: string = '';
  
  // 搜索替换状态
  @State showSearchBar: boolean = false;
  @State searchText: string = '';
  @State replaceText: string = '';
  @State searchResults: number[] = []; // 匹配的位置
  @State currentSearchIndex: number = -1;
  
  // 键盘状态
  @State isCtrlPressed: boolean = false;
  @State isAltPressed: boolean = false;

  // 用于强制刷新布局的计数器
  @State layoutRefreshCounter: number = 0;
  
  // 动画曲线
  private springCurve: ICurve = curves.springMotion(0.6, 0.8);
  
  // 对话框控制器
  private newFileDialogController: CustomDialogController = new CustomDialogController({
    builder: NewFileDialog({
      bgColor: this.currentTheme.colors.surface,
      textColor: this.currentTheme.colors.text,
      primaryColor: this.currentTheme.colors.primary,
      titleText: '新建文件',
      confirmText: '创建',
      initialName: '',
      placeholderText: '例如: test.js',
      onConfirm: (fileName: string) => {
        this.handleCreateFile(fileName);
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });
  
  private templateDialogController: CustomDialogController = new CustomDialogController({
    builder: TemplateDialog({
      bgColor: this.currentTheme.colors.surface,
      textColor: this.currentTheme.colors.text,
      primaryColor: this.currentTheme.colors.primary,
      onConfirm: (template: CodeTemplate) => {
        this.insertTemplate(template);
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  private letterDialogController: CustomDialogController = new CustomDialogController({
    builder: LetterDialog({
      bgColor: this.currentTheme.colors.surface,
      textColor: this.currentTheme.colors.text,
      accentColor: this.currentTheme.colors.primary,
      onConfirm: () => {
        this.markLetterShown();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  private renameDialogController: CustomDialogController = new CustomDialogController({
    builder: NewFileDialog({
      bgColor: this.currentTheme.colors.surface,
      textColor: this.currentTheme.colors.text,
      primaryColor: this.currentTheme.colors.primary,
      titleText: '重命名',
      confirmText: '保存',
      initialName: '',
      placeholderText: '例如: main.ts',
      onConfirm: (fileName: string) => {
        this.handleRenameFile(this.renameTargetFile, fileName);
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  @State renameTargetFile: FileItem | null = null;
  
  // 避让区高度
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  
  // 滚动控制器
  private editorScroller: Scroller = new Scroller();
  
  private context: common.UIAbilityContext | null = null;
  private themeService: ThemeService = ThemeService.getInstance();
  private breakpointService: BreakpointService = BreakpointService.getInstance();
  private formatterService: CodeFormatterService = CodeFormatterService.getInstance();
  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance();
  private fileManager: FileManagerService = FileManagerService.getInstance();
  
  // 支持的文件类型
  private fileTypes: FileTypeOption[] = [
    { name: '文本文件', suffix: '.txt', language: 'text' },
    { name: 'ArkTS 文件', suffix: '.ets', language: 'typescript' },
    { name: 'TypeScript', suffix: '.ts', language: 'typescript' },
    { name: 'JavaScript', suffix: '.js', language: 'javascript' },
    { name: 'Python', suffix: '.py', language: 'python' },
    { name: 'Java', suffix: '.java', language: 'java' },
    { name: 'C++', suffix: '.cpp', language: 'cpp' },
    { name: 'C', suffix: '.c', language: 'c' },
    { name: 'HTML', suffix: '.html', language: 'html' },
    { name: 'CSS', suffix: '.css', language: 'css' },
    { name: 'JSON', suffix: '.json', language: 'json' },
    { name: 'Markdown', suffix: '.md', language: 'markdown' }
  ];

  async aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    
    // 初始化文件管理器（异步）
    if (this.context) {
      await this.fileManager.init(this.context);
      this.loadInternalFiles();
      this.workspacePath = this.fileManager.getWorkspacePath();
    }

    this.handlePendingOpenFile();
    this.handlePendingTemplate();
    
    // 创建默认标签
    this.createNewTab();
    
    // 注册断点系统
    this.breakpointService.register();
    this.currentBreakpoint = this.breakpointService.getCurrentBreakpoint();
    // 初始时根据当前断点立即应用布局，避免抽屉宽度为 0 导致无法显示
    this.applyResponsiveLayout(this.breakpointService.isMobile(), false);
    
    this.breakpointService.onChange((breakpoint: Breakpoint) => {
      this.currentBreakpoint = breakpoint;
      const newMobileMode = this.breakpointService.isMobile();
      this.applyResponsiveLayout(newMobileMode, true);
    });
    
    // 监听主题变化
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
      this.updateSystemBarColor(theme);
    });

    // 初始化时设置状态栏颜色
    this.updateSystemBarColor(this.currentTheme);
    
    // 加载字体大小设置
    this.loadFontSize();

    // 首次进入编辑器显示致用户的一封信
    this.showLetterIfNeeded();
  }
  
  /**
   * 加载字体大小设置
   */
  private loadFontSize() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'settings' });
      this.fontSize = store.getSync('fontSize', 14) as number;
      const storedLineHeight = store.getSync('lineHeight', this.fontSize + 8) as number;
      this.lineHeight = Math.max(this.fontSize + 4, storedLineHeight);
      this.showLineNumbers = store.getSync('showLineNumbers', true) as boolean;
    } catch (e) {
      console.error('加载字体大小失败:', JSON.stringify(e));
    }
  }
  
  /**
   * 打开设置页面
   */
  private openSettings() {
    router.pushUrl({ url: 'pages/Settings' });
  }

  private showLetterIfNeeded() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'user_settings' });
      const shown = store.getSync('letter_shown', false) as boolean;
      if (!shown) {
        this.letterDialogController = new CustomDialogController({
          builder: LetterDialog({
            bgColor: this.currentTheme.colors.surface,
            textColor: this.currentTheme.colors.text,
            accentColor: this.currentTheme.colors.primary,
            onConfirm: () => {
              this.markLetterShown();
            }
          }),
          autoCancel: false,
          alignment: DialogAlignment.Center,
          customStyle: true
        });
        this.letterDialogController.open();
      }
    } catch (e) {
      console.error('showLetterIfNeeded error:', JSON.stringify(e));
    }
  }

  private markLetterShown() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'user_settings' });
      store.putSync('letter_shown', true);
      store.flush();
    } catch (e) {
      console.error('markLetterShown error:', JSON.stringify(e));
    }
  }

  aboutToDisappear() {
    this.breakpointService.unregister();
  }
  
  onPageShow() {
    // 从设置页面返回时重新加载字体大小
    this.loadFontSize();
    // 处理待打开的文件和模板
    this.handlePendingOpenFile();
    this.handlePendingTemplate();
  }

  /**
   * 根据当前主题更新系统状态栏颜色
   */
  private updateSystemBarColor(theme: Theme) {
    try {
      if (!this.context) {
        return;
      }
      
      // 判断是否为深色主题
      const isDarkTheme = theme.id !== 'light' && theme.id !== 'harmony-light';
      
      window.getLastWindow(this.context).then((windowClass) => {
        const systemBarProperties: window.SystemBarProperties = {
          statusBarContentColor: isDarkTheme ? '#FFFFFF' : '#000000',
          navigationBarContentColor: isDarkTheme ? '#FFFFFF' : '#000000',
          statusBarColor: '#00000000',
          navigationBarColor: '#00000000'
        };
        
        windowClass.setWindowSystemBarProperties(systemBarProperties);
        const windowRef = windowClass as WindowBackgroundSetter;
        windowRef.setWindowBackgroundColor?.(theme.colors.background);
      }).catch((err: Error) => {
        console.error('Failed to get window:', err.message);
      });
    } catch (error) {
      console.error('Failed to update system bar color:', JSON.stringify(error));
    }
  }

  /**
   * 根据当前断点应用布局
   */
  private applyResponsiveLayout(isMobile: boolean, animate: boolean = false) {
    const update = () => {
      this.isMobileMode = isMobile;
      if (this.isMobileMode) {
        // 移动端：隐藏左侧栏，使用抽屉
        this.sidebarWidth = 0;
        this.showFileBrowser = false;
      } else {
        // 大屏：固定侧边栏
        this.sidebarWidth = 200;
        this.showFileBrowser = true;
      }
    };

    if (animate) {
      this.getUIContext().animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, update);
    } else {
      update();
    }
  }

  /**
   * 新建文件
   */
  private newFile() {
    if (this.isModified) {
      // 提示保存
      this.showConfirmDialog('提示', '当前文件未保存，是否保存？', (index: number) => {
        if (index === 0) {
          // 不保存，直接新建
          this.resetEditor();
        } else if (index === 1) {
          // 先保存再新建
          this.saveFileAs().then(() => {
            this.resetEditor();
          });
        }
        // index === 2 取消，不做任何操作
      });
    } else {
      this.resetEditor();
    }
  }

  /**
   * 重置编辑器为空白状态
   */
  private resetEditor() {
    this.content = '';
    this.fileName = '未命名';
    this.filePath = '';
    this.isModified = false;
    this.language = 'text';
  }

  /**
   * 打开文件
   */
  private async openFile() {
    try {
      if (!this.context) {
        this.showToast('无法获取应用上下文');
        return;
      }

      const documentPicker = new picker.DocumentViewPicker(this.context);
      const result = await documentPicker.select({
        maxSelectNumber: 1
      });
      
      if (!result || result.length === 0) {
        return;
      }
      
      const fileUri = result[0];
      
      // 读取文件内容
      const file = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(file.fd);
      const arrayBuffer = new ArrayBuffer(stat.size);
      const readLen = fileIo.readSync(file.fd, arrayBuffer);
      fileIo.closeSync(file);

      // 转换为字符串
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const fileContent = textDecoder.decodeToString(new Uint8Array(arrayBuffer.slice(0, readLen)));

      // 从 URI 提取文件名
      const extractedFileName = this.extractFileName(fileUri);
      
      // 更新编辑器状态
      this.content = fileContent;
      this.fileName = extractedFileName;
      this.filePath = fileUri;
      this.isModified = false;
      this.language = this.getLanguageFromFileName(extractedFileName);
      this.lineCount = fileContent.split('\n').length;
      this.addRecentFile(fileUri, extractedFileName);

      this.showToast('文件已打开');
    } catch (err) {
      const error = err as Error;
      console.error('打开文件失败:', error.message);
      this.showToast(`打开失败: ${error.message}`);
    }
  }

  /**
   * 打开工作区文件夹
   */
  private async openWorkspaceFolder() {
    try {
      if (!this.context) {
        this.showToast('无法获取应用上下文');
        return;
      }

      const documentPicker = new picker.DocumentViewPicker(this.context);
      const result = await documentPicker.select({
        maxSelectNumber: 1
      });

      if (!result || result.length === 0) {
        return;
      }

      let targetPath = result[0];
      try {
        const stat = fileIo.statSync(targetPath);
        if (!stat.isDirectory()) {
          targetPath = targetPath.substring(0, targetPath.lastIndexOf('/'));
        }
      } catch (e) {
        targetPath = targetPath.substring(0, targetPath.lastIndexOf('/'));
      }

      if (!targetPath) {
        this.showToast('无法解析文件夹路径');
        return;
      }

      this.fileManager.setWorkspaceDir(targetPath);
      this.workspacePath = this.fileManager.getWorkspacePath();
      this.loadInternalFiles();
      this.showToast('已打开工作区');
    } catch (err) {
      const error = err as Error;
      console.error('打开工作区失败:', error.message);
      this.showToast(`打开失败: ${error.message}`);
    }
  }

  /**
   * 保存文件（如果已有路径则直接保存，否则另存为）
   */
  private async saveFile() {
    if (this.filePath) {
      // 判断是内部文件还是外部文件
      if (this.filePath.startsWith(this.fileManager.getCodesDir())) {
        // 内部文件，直接保存
        try {
          this.fileManager.writeFile(this.filePath, this.content);
          this.isModified = false;
          this.saveCurrentTabState();
          this.showToast('保存成功');
          this.loadInternalFiles();
        } catch (e) {
          this.showToast('保存失败');
        }
      } else {
        // 外部文件，使用原有方法
        await this.saveToPath(this.filePath);
      }
    } else {
      // 如果没有文件路径，检查是否是未命名文件
      const baseName = this.stripExtension(this.fileName);
      const isUntitled = baseName === '未命名';
      if (isUntitled) {
        // 在工作区创建文件
        try {
          const saveFileName = this.fileName === '未命名' ? 'untitled.txt' : this.fileName;
          this.filePath = this.fileManager.createFile(saveFileName, this.content);
          this.isModified = false;
          this.saveCurrentTabState();
          this.showToast('保存成功');
          this.loadInternalFiles();
        } catch (e) {
          this.showToast('创建文件失败，请选择保存位置');
          await this.saveFileAs();
        }
      } else {
        // 其他情况使用另存为
        await this.saveFileAs();
      }
    }
  }

  /**
   * 另存为（调用系统文件选择器选择保存位置）
   */
  private async saveFileAs() {
    try {
      if (!this.context) {
        this.showToast('无法获取应用上下文');
        return;
      }

      const documentPicker = new picker.DocumentViewPicker(this.context);

      // 获取当前文件后缀，填充到文件格式列表，避免系统下拉为空
      const currentSuffix = this.getCurrentFileSuffix();
      const suffixWithoutDot = currentSuffix.replace(/^\./, '') || 'txt';
      const commonFormats: string[] = ['txt', 'md', 'json', 'js', 'ts', 'ets', 'html', 'css', 'scss', 'xml', 'yaml', 'yml', 'java', 'py', 'c', 'cpp', 'rs', 'go'];
      const fileSuffixChoices = [suffixWithoutDot, ...commonFormats.filter(ext => ext !== suffixWithoutDot)];
      // 预填名称带上当前后缀，让系统在切换格式时替换后缀而不是拼接
      const baseName = this.stripExtension(this.fileName === '未命名' ? '新文件' : this.fileName);
      const prefillName = suffixWithoutDot ? `${baseName}.${suffixWithoutDot}` : baseName;
      const saveOptions: SaveDialogOptions = {
        newFileNames: [prefillName],
        fileSuffixChoices: fileSuffixChoices
      };
      const result = await documentPicker.save(saveOptions);
      
      if (!result || result.length === 0) {
        return;
      }
      
      const saveUri = result[0];
      await this.saveToPath(saveUri);
      
      // 更新文件信息
      this.filePath = saveUri;
      this.fileName = this.extractFileName(saveUri);
      this.language = this.getLanguageFromFileName(this.fileName);
      // 同步更新到当前标签
      this.saveCurrentTabState();
      
    } catch (err) {
      const error = err as Error;
      console.error('保存文件失败:', error.message);
      this.showToast(`保存失败: ${error.message}`);
    }
  }


  /**
   * 导入外部文件到工作区并打开
   */
  private async importFileToWorkspace() {
    try {
      if (!this.context) {
        this.showToast('无法获取应用上下文');
        return;
      }

      const documentPicker = new picker.DocumentViewPicker(this.context);
      const result = await documentPicker.select({ maxSelectNumber: 10 });
      if (!result || result.length === 0) {
        return;
      }

      let imported = 0;
      for (const fileUri of result) {
        try {
          const file = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
          const stat = fileIo.statSync(file.fd);
          const buffer = new ArrayBuffer(stat.size);
          const readLen = fileIo.readSync(file.fd, buffer);
          fileIo.closeSync(file);

          const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
          const content = decoder.decodeToString(new Uint8Array(buffer.slice(0, readLen)));
          const fileName = this.extractFileName(fileUri);

          const targetPath = `${this.fileManager.getCodesDir()}/${fileName}`;
          this.fileManager.writeFile(targetPath, content);

          const fileItem: FileItem = {
            name: fileName,
            path: targetPath,
            isDirectory: false,
            size: stat.size,
            modifiedTime: Date.now()
          };
          this.openInternalFile(fileItem);
          imported++;
        } catch (innerErr) {
          console.error('导入单个文件失败:', JSON.stringify(innerErr));
        }
      }

      if (imported > 0) {
        this.loadInternalFiles();
        this.showToast(`已导入 ${imported} 个文件到工作区`);
      } else {
        this.showToast('导入失败');
      }
    } catch (e) {
      console.error('importFileToWorkspace error:', JSON.stringify(e));
      this.showToast('导入失败');
    }
  }

  /**
   * 保存到指定路径
   */
  private async saveToPath(uri: string) {
    try {
      // 将字符串转换为 Uint8Array
      const textEncoder = util.TextEncoder.create();
      const buffer: Uint8Array = textEncoder.encodeInto(this.content);

      // 写入文件
      const file = fileIo.openSync(uri, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(file.fd, buffer.buffer);
      fileIo.closeSync(file);

      this.isModified = false;
      // 同步更新到当前标签
      this.saveCurrentTabState();
      this.showToast('保存成功');
    } catch (err) {
      const error = err as Error;
      console.error('保存失败详细信息:', JSON.stringify(err));
      throw new Error(`写入文件失败: ${error.message}`);
    }
  }

  /**
   * 从 URI 提取文件名（解码 URL 编码的中文）
   */
  private extractFileName(uri: string): string {
    const parts = uri.split('/');
    const encodedName = parts[parts.length - 1] || '未命名';
    try {
      // 解码 URL 编码的文件名（如 %E4%B8%AD%E6%96%87 -> 中文）
      return decodeURIComponent(encodedName);
    } catch (e) {
      return encodedName;
    }
  }

  /**
   * 获取当前文件后缀
   */
  private getCurrentFileSuffix(): string {
    if (this.fileName.includes('.')) {
      return '.' + this.fileName.split('.').pop();
    }
    return '.txt';
  }

  /** 去掉已有后缀，交由系统按所选格式追加 */
  private stripExtension(name: string): string {
    const lastDot = name.lastIndexOf('.');
    if (lastDot > 0) {
      return name.substring(0, lastDot);
    }
    return name;
  }

  /**
   * 从文件名获取语言类型
   */
  private getLanguageFromFileName(fileName: string): string {
    const ext = fileName.split('.').pop()?.toLowerCase() || '';
    const languageMap: Record<string, string> = {
      'js': 'javascript',
      'ts': 'typescript',
      'ets': 'typescript',
      'py': 'python',
      'java': 'java',
      'cpp': 'cpp',
      'c': 'c',
      'go': 'go',
      'rs': 'rust',
      'md': 'markdown',
      'html': 'html',
      'css': 'css',
      'scss': 'scss',
      'json': 'json',
      'xml': 'xml',
      'yaml': 'yaml',
      'yml': 'yaml',
      'txt': 'text'
    };
    return languageMap[ext] || 'text';
  }

  /**
   * 切换主题（带动画）
   */
  private cycleTheme() {
    this.getUIContext().animateTo({ 
      duration: 300, 
      curve: Curve.EaseInOut 
    }, () => {
      const nextTheme = this.themeService.getNextTheme();
      this.themeService.switchTheme(nextTheme.id);
      this.themeService.saveThemePreference(nextTheme.id);
    });
  }

  /**
   * 内容变化时的处理
   */
  private onContentChange(newContent: string) {
    this.content = newContent;
    this.isModified = true;
    // 更新行数
    this.lineCount = newContent.split('\n').length;
    // 保存到当前标签
    this.saveCurrentTabState();
  }

  private buildEditorState(): EditorState {
    return {
      // 多标签状态
      tabs: this.tabs,
      currentTabId: this.currentTabId,
      showFileBrowser: this.showFileBrowser,
      sidebarWidth: this.sidebarWidth,
      internalFiles: this.internalFiles,
      workspacePath: this.workspacePath,

      // 移动端状态
      showLeftDrawer: this.showLeftDrawer,
      showRightDrawer: this.showRightDrawer,
      showTabManager: this.showTabManager,

      // 运行控制台状态
      showConsole: this.showConsole,
      consoleLogs: this.consoleLogs,

      // 编辑器状态
      content: this.content,
      fileName: this.fileName,
      isModified: this.isModified,
      language: this.language,
      lineCount: this.lineCount,
      filePath: this.filePath,

      // UI 状态
      currentTheme: this.currentTheme,
      showSearchBar: this.showSearchBar,
      searchText: this.searchText,
      replaceText: this.replaceText,
      searchResults: this.searchResults,
      currentSearchIndex: this.currentSearchIndex,
      isPreviewMode: this.isPreviewMode,
      fontSize: this.fontSize,
      lineHeight: this.lineHeight,
      showLineNumbers: this.showLineNumbers,
      editorScale: this.editorScale,

      // 避让区高度
      topRectHeight: this.topRectHeight,
      bottomRectHeight: this.bottomRectHeight,

      // Web控制器
      webController: this.webController
    };
  }

  private buildEditorCallbacks(): EditorCallbacks {
    return {
      // 文件操作
      onFileClick: (file: FileItem): void => {
        this.openInternalFile(file);
      },
      onNewFile: (): void => {
        this.createInternalFile();
      },
      onRenameFile: (file: FileItem): void => {
        this.renameInternalFile(file);
      },
      onDeleteFile: (file: FileItem): void => {
        this.deleteInternalFile(file);
      },

      // 标签操作
      onTabClick: (tabId: string): void => {
        this.switchToTab(tabId);
      },
      onTabClose: (tabId: string): void => {
        this.closeTab(tabId);
      },
      onNewTab: (): void => {
        this.createNewTab();
      },

      // 工具栏操作
      onToggleFileBrowser: (): void => {
        this.toggleFileBrowser();
      },
      onOpenSettings: (): void => {
        this.openSettings();
      },
      onRunCode: (): void => {
        this.runCode();
      },
      onFormatCode: (): void => {
        this.formatCode();
      },
      onToggleSearchBar: (): void => {
        this.getUIContext().animateTo({
          duration: 250,
          curve: Curve.EaseInOut
        }, () => {
          this.showSearchBar = !this.showSearchBar;
        });
      },
      onTogglePreviewMode: (): void => {
        this.getUIContext().animateTo({
          duration: 300,
          curve: this.springCurve
        }, () => {
          this.isPreviewMode = !this.isPreviewMode;
          this.editorScale = this.isPreviewMode ? 0.98 : 1;
        });
        setTimeout(() => {
          this.getUIContext().animateTo({ duration: 200 }, () => {
            this.editorScale = 1;
          });
        }, 100);
      },
      onOpenTemplateDialog: (): void => {
        this.openTemplateDialog();
      },
      onSaveFile: (): void => {
        this.saveFile();
      },
      onOpenFile: (): void => {
        this.openFile();
      },
      onImportFile: (): void => {
        this.importFileToWorkspace();
      },
      onExportFile: (): void => {
        this.saveFileAs();
      },

      // 搜索操作
      onSearchChange: (value: string): void => {
        this.searchText = value;
      },
      onReplaceChange: (value: string): void => {
        this.replaceText = value;
      },
      onPerformSearch: (): void => {
        this.performSearch();
      },
      onNextSearch: (): void => {
        this.nextSearchResult();
      },
      onPrevSearch: (): void => {
        this.prevSearchResult();
      },
      onReplaceCurrent: (): void => {
        this.replaceCurrent();
      },
      onReplaceAll: (): void => {
        this.replaceAll();
      },
      onCloseSearchBar: (): void => {
        this.showSearchBar = false;
        this.searchResults = [];
      },

      // 编辑器操作
      onContentChange: (content: string): void => {
        this.onContentChange(content);
      },

      // 控制台操作
      onCloseConsole: (): void => {
        this.showConsole = false;
      },
      onClearConsole: (): void => {
        this.consoleLogs = [];
      },

      // 移动端抽屉操作
      onToggleLeftDrawer: (show: boolean): void => {
        this.showLeftDrawer = show;
      },
      onToggleRightDrawer: (show: boolean): void => {
        this.showRightDrawer = show;
      },
      onToggleTabManager: (show: boolean): void => {
        this.showTabManager = show;
      },

      // 菜单操作
      onMenuAction: (action: string): void => {
        this.handleMenuAction(action);
      }
    };
  }

  build() {
    // 使用响应式布局 - 使用 key 强制重新渲染
    Stack() {
      ResponsiveLayout({
        breakpointService: this.breakpointService,
        callbacks: this.buildEditorCallbacks(),
        state: this.buildEditorState()
      })
      .key(`layout_${this.layoutRefreshCounter}_${this.isMobileMode}`)
    }
    .width('100%')
    .height('100%')
    .onKeyEvent((event: KeyEvent) => {
      // 更新修饰键状态
      if (event.keyCode === 2072 || event.keyCode === 2073) { // Ctrl
        this.isCtrlPressed = (event.type === KeyType.Down);
      }
      if (event.keyCode === 2074 || event.keyCode === 2075) { // Alt
        this.isAltPressed = (event.type === KeyType.Down);
      }

      if (event.type === KeyType.Down) {
        // Ctrl + S : 保存
        if (event.keyCode === 2056 && this.isCtrlPressed) {
          this.saveFile();
          return;
        }
        // Ctrl + F : 搜索
        if (event.keyCode === 2034 && this.isCtrlPressed) {
          this.getUIContext().animateTo({
            duration: 250,
            curve: Curve.EaseInOut
          }, () => {
            this.showSearchBar = true;
          });
          return;
        }
        // Ctrl + Alt + L : 格式化
        if (event.keyCode === 2043 && this.isCtrlPressed && this.isAltPressed) {
          this.formatCode();
          return;
        }
      }
    })
  }

  /**
   * 显示 Toast 提示（封装新 API）
   */
  private showToast(message: string) {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message });
    } catch (e) {
      console.error('showToast error:', JSON.stringify(e));
    }
  }

  /**
   * 显示确认对话框（封装新 API）
   */
  private showConfirmDialog(title: string, message: string, callback: (index: number) => void) {
    try {
      this.getUIContext().getPromptAction().showDialog({
        title: title,
        message: message,
        buttons: [
          { text: '不保存', color: this.currentTheme.colors.textSecondary },
          { text: '保存', color: this.currentTheme.colors.primary },
          { text: '取消', color: this.currentTheme.colors.textSecondary }
        ]
      }).then((result) => {
        callback(result.index);
      }).catch((err: Error) => {
        console.error('showDialog error:', err.message);
      });
    } catch (e) {
      console.error('showConfirmDialog error:', JSON.stringify(e));
    }
  }

  /**
   * 搜索文本
   */
  private performSearch() {
    if (!this.searchText) {
      this.searchResults = [];
      this.currentSearchIndex = -1;
      return;
    }
    
    const results: number[] = [];
    const searchLower = this.searchText.toLowerCase();
    const contentLower = this.content.toLowerCase();
    
    let index = contentLower.indexOf(searchLower);
    while (index !== -1) {
      results.push(index);
      index = contentLower.indexOf(searchLower, index + 1);
    }
    
    this.searchResults = results;
    this.currentSearchIndex = results.length > 0 ? 0 : -1;
    
    if (results.length > 0) {
      this.showToast(`找到 ${results.length} 个匹配项`);
    } else {
      this.showToast('未找到匹配项');
    }
  }
  
  /**
   * 跳转到下一个搜索结果
   */
  private nextSearchResult() {
    if (this.searchResults.length === 0) return;
    this.currentSearchIndex = (this.currentSearchIndex + 1) % this.searchResults.length;
  }
  
  /**
   * 跳转到上一个搜索结果
   */
  private prevSearchResult() {
    if (this.searchResults.length === 0) return;
    this.currentSearchIndex = (this.currentSearchIndex - 1 + this.searchResults.length) % this.searchResults.length;
  }
  
  /**
   * 替换当前匹配项
   */
  private replaceCurrent() {
    if (this.currentSearchIndex === -1 || this.searchResults.length === 0) return;
    
    const pos = this.searchResults[this.currentSearchIndex];
    const before = this.content.substring(0, pos);
    const after = this.content.substring(pos + this.searchText.length);
    
    this.content = before + this.replaceText + after;
    this.isModified = true;
    this.lineCount = this.content.split('\n').length;
    
    // 重新搜索
    this.performSearch();
  }
  
  /**
   * 替换所有匹配项
   */
  private replaceAll() {
    if (this.searchResults.length === 0) return;
    
    const regex = new RegExp(this.searchText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi');
    this.content = this.content.replace(regex, this.replaceText);
    this.isModified = true;
    this.lineCount = this.content.split('\n').length;
    
    this.showToast(`已替换 ${this.searchResults.length} 处`);
    this.searchResults = [];
    this.currentSearchIndex = -1;
  }
  
  /**
   * 运行代码
   */
  private runCode() {
    // 1. 显示控制台
    this.getUIContext().animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
      this.showConsole = true;
    });
    this.consoleLogs = []; // 清空日志
    this.consoleLogs.push('[System] Starting execution...');

    // 2. 检查语言
    if (this.language !== 'javascript' && this.language !== 'typescript') {
      this.consoleLogs.push('[System] Warning: Currently only JavaScript execution is supported directly.');
      if (this.language === 'html') {
         this.consoleLogs.push('[System] Tip: For HTML, please use "Preview" mode.');
      }
      return;
    }

    // 3. 准备沙箱代码
    // 我们重写 console.log 以捕获输出
    // 为了防止死循环卡死 UI，建议加上超时机制（这里简化处理）
    const codeToRun = this.content
      .replace(/\\/g, '\\\\') // 转义反斜杠
      .replace(/`/g, '\\`')   // 转义反引号
      .replace(/\$/g, '\\$'); // 转义美元符号

    const sandboxScript = `
      (function() {
        try {
          ${this.content}
        } catch (e) {
          console.error(e.toString());
        }
      })();
    `;

    // 4. 执行
    try {
      // 必须先加载一个基础页面才能运行 JS，我们在 Web 组件初始化时已经加载了 about:blank
      this.webController.runJavaScript(sandboxScript);
    } catch (e) {
      this.consoleLogs.push('[System] Execution failed: ' + JSON.stringify(e));
    }
  }

  /**
   * 格式化代码
   */
  private formatCode() {
    try {
      const formatted = this.formatterService.format(this.content, this.language);
      this.content = formatted;
      this.isModified = true;
      this.lineCount = this.content.split('\n').length;
      this.showToast('代码已格式化');
    } catch (e) {
      this.showToast('格式化失败');
      console.error('格式化错误:', JSON.stringify(e));
    }
  }
  
  /**
   * 处理移动端菜单操作
   */
  private handleMenuAction(action: string) {
    switch (action) {
      case 'run':
        this.runCode();
        break;
      case 'template':
        this.openTemplateDialog();
        break;
      case 'format':
        this.formatCode();
        break;
      case 'search':
        this.getUIContext().animateTo({
          duration: 250,
          curve: Curve.EaseInOut
        }, () => {
          this.showSearchBar = true;
        });
        break;
      case 'preview':
        this.getUIContext().animateTo({
          duration: 300,
          curve: this.springCurve
        }, () => {
          this.isPreviewMode = !this.isPreviewMode;
          this.editorScale = this.isPreviewMode ? 0.98 : 1;
        });
        setTimeout(() => {
          this.getUIContext().animateTo({ duration: 200 }, () => {
            this.editorScale = 1;
          });
        }, 100);
        break;
      case 'save':
        this.saveFile();
        break;
      case 'export':
        this.saveFileAs();
        break;
      case 'open':
        this.openFile();
        break;
      case 'import':
        this.importFileToWorkspace();
        break;
      case 'settings':
        this.openSettings();
        break;
    }
    // 强制刷新布局以更新状态
    this.layoutRefreshCounter++;
  }

  /**
   * 返回上一页（封装新 API）
   */
  private goBack() {
    try {
      router.back();
    } catch (e) {
      console.error('router.back error:', JSON.stringify(e));
    }
  }

  /**
   * 加载应用内部文件列表
   */
  private loadInternalFiles() {
    try {
      this.internalFiles = this.fileManager.listFiles();
    } catch (e) {
      console.error('加载文件列表失败:', JSON.stringify(e));
    }
  }

  /**
   * 创建新标签
   */
  private createNewTab() {
    const newTab = new FileTab(
      FileTab.generateId(),
      '未命名.txt',
      '',
      '',
      'text'
    );
    this.tabs.push(newTab);
    this.switchToTab(newTab.id);
  }

  /**
   * 切换到指定标签
   */
  private switchToTab(tabId: string) {
    // 保存当前标签内容
    this.saveCurrentTabState();
    
    // 切换标签
    this.currentTabId = tabId;
    const tab = this.tabs.find(t => t.id === tabId);
    if (tab) {
      // 更新编辑器状态
      this.content = tab.content;
      this.fileName = tab.fileName;
      this.filePath = tab.filePath;
      this.isModified = tab.isModified;
      this.language = tab.language;
      this.lineCount = tab.content.split('\n').length;
      
      // 强制刷新编辑器
      this.isPreviewMode = false;
    }
  }

  /**
   * 保存当前标签状态
   */
  private saveCurrentTabState() {
    const currentTab = this.tabs.find(t => t.id === this.currentTabId);
    if (currentTab) {
      currentTab.content = this.content;
      currentTab.fileName = this.fileName;
      currentTab.filePath = this.filePath;
      currentTab.isModified = this.isModified;
      currentTab.language = this.language;
    }
  }

  /**
   * 关闭标签
   */
  private closeTab(tabId: string) {
    const tabIndex = this.tabs.findIndex(t => t.id === tabId);
    if (tabIndex === -1) return;
    
    const tab = this.tabs[tabIndex];
    
    if (tab.isModified) {
      this.showConfirmDialog('提示', '文件未保存，是否保存？', (index: number) => {
        if (index === 0) {
          // 不保存，直接关闭
          this.removeTab(tabId, tabIndex);
        } else if (index === 1) {
          // 保存后关闭
          this.saveTabFile(tab).then(() => {
            this.removeTab(tabId, tabIndex);
          });
        }
      });
    } else {
      this.removeTab(tabId, tabIndex);
    }
  }

  /**
   * 移除标签
   */
  private removeTab(tabId: string, tabIndex: number) {
    this.tabs.splice(tabIndex, 1);
    
    // 如果关闭的是当前标签，切换到其他标签
    if (tabId === this.currentTabId) {
      if (this.tabs.length > 0) {
        const newIndex = Math.min(tabIndex, this.tabs.length - 1);
        this.switchToTab(this.tabs[newIndex].id);
      } else {
        // 没有标签了，创建新标签
        this.createNewTab();
      }
    }
  }

  /**
   * 保存标签文件
   */
  private async saveTabFile(tab: FileTab): Promise<void> {
    if (tab.filePath && tab.filePath.startsWith(this.fileManager.getCodesDir())) {
      // 内部文件，直接保存
      try {
        this.fileManager.writeFile(tab.filePath, tab.content);
        tab.isModified = false;
        this.showToast('保存成功');
      } catch (e) {
        this.showToast('保存失败');
      }
    } else {
      // 外部文件或新文件，使用系统选择器
      await this.saveFileAs();
    }
  }

  /**
   * 从文件浏览器打开文件
   */
  private openInternalFile(file: FileItem) {
    try {
      // 检查是否已经打开
      const existingTab = this.tabs.find(t => t.filePath === file.path);
      if (existingTab) {
        this.switchToTab(existingTab.id);
        return;
      }
      
      // 读取文件内容
      const content = this.fileManager.readFile(file.path);
      const language = FileTab.getLanguageFromPath(file.path);
      
      // 创建新标签
      const newTab = new FileTab(
        FileTab.generateId(),
        file.name,
        file.path,
        content,
        language
      );
      
      this.tabs.push(newTab);
      this.switchToTab(newTab.id);
      this.addRecentFile(file.path, file.name);
      
    } catch (e) {
      this.showToast('打开文件失败');
      console.error('打开内部文件失败:', JSON.stringify(e));
    }
  }

  private handlePendingOpenFile() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'recent' });
      const pendingPath = store.getSync('pendingOpenFilePath', '') as string;
      if (!pendingPath) return;
      store.putSync('pendingOpenFilePath', '');
      store.flush();
      this.openFileFromPath(pendingPath);
    } catch (e) {
      console.error('处理待打开文件失败:', JSON.stringify(e));
    }
  }

  private handlePendingTemplate() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'templates' });
      const pendingId = store.getSync('pendingTemplateId', '') as string;
      if (!pendingId) return;
      store.putSync('pendingTemplateId', '');
      store.flush();
      const template = CodeTemplateData.getTemplateById(pendingId);
      if (template) {
        this.insertTemplate(template);
      }
    } catch (e) {
      console.error('处理待插入模板失败:', JSON.stringify(e));
    }
  }

  private openFileFromPath(filePath: string) {
    try {
      if (!filePath) return;
      const existingTab = this.tabs.find(t => t.filePath === filePath);
      if (existingTab) {
        this.switchToTab(existingTab.id);
        return;
      }
      const content = this.fileManager.readFile(filePath);
      const fileName = this.extractFileName(filePath);
      const language = FileTab.getLanguageFromPath(filePath);
      const newTab = new FileTab(
        FileTab.generateId(),
        fileName,
        filePath,
        content,
        language
      );
      this.tabs.push(newTab);
      this.switchToTab(newTab.id);
      this.addRecentFile(filePath, fileName);
    } catch (e) {
      this.showToast('打开文件失败');
      console.error('打开文件失败:', JSON.stringify(e));
    }
  }

  private addRecentFile(filePath: string, fileName: string) {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'recent' });
      const raw = store.getSync('recentFiles', '') as string;
      let list: RecentFileEntry[] = [];
      if (raw) {
        try {
          list = JSON.parse(raw) as RecentFileEntry[];
        } catch (e) {
          list = [];
        }
      }
      list = list.filter(item => item.path !== filePath);
      list.unshift({ name: fileName, path: filePath, lastOpened: Date.now() } as RecentFileEntry);
      if (list.length > 20) {
        list = list.slice(0, 20);
      }
      store.putSync('recentFiles', JSON.stringify(list));
      store.flush();
    } catch (e) {
      console.error('更新最近文件失败:', JSON.stringify(e));
    }
  }

  /**
   * 创建新的内部文件
   */
  private createInternalFile() {
    // 重新创建对话框控制器以使用最新的主题
    this.newFileDialogController = new CustomDialogController({
      builder: NewFileDialog({
        bgColor: this.currentTheme.colors.surface,
        textColor: this.currentTheme.colors.text,
        primaryColor: this.currentTheme.colors.primary,
        titleText: '新建文件',
        confirmText: '创建',
        initialName: '',
        placeholderText: '例如: test.js',
        onConfirm: (fileName: string) => {
          this.handleCreateFile(fileName);
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    
    this.newFileDialogController.open();
  }

  /**
   * 处理创建文件
   */
  private handleCreateFile(fileName: string) {
    try {
      const filePath = this.fileManager.createFile(fileName, '');
      this.loadInternalFiles();
      
      // 打开新创建的文件
      const file: FileItem = {
        name: fileName,
        path: filePath,
        isDirectory: false,
        size: 0,
        modifiedTime: Date.now()
      };
      this.openInternalFile(file);
      
      this.showToast('文件已创建');
    } catch (e) {
      this.showToast('创建文件失败');
      console.error('创建文件失败:', JSON.stringify(e));
    }
  }

  /**
   * 重命名内部文件
   */
  private renameInternalFile(file: FileItem) {
    this.renameTargetFile = file;
    this.renameDialogController = new CustomDialogController({
      builder: NewFileDialog({
        bgColor: this.currentTheme.colors.surface,
        textColor: this.currentTheme.colors.text,
        primaryColor: this.currentTheme.colors.primary,
        titleText: '重命名',
        confirmText: '保存',
        initialName: file.name,
        placeholderText: '例如: main.ts',
        onConfirm: (newName: string) => {
          this.handleRenameFile(this.renameTargetFile, newName);
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });

    this.renameDialogController.open();
  }

  private handleRenameFile(file: FileItem | null, newName: string) {
    if (!file) {
      return;
    }
    const trimmedName = newName.trim();
    if (!trimmedName) {
      this.showToast('文件名不能为空');
      return;
    }

    if (trimmedName === file.name) {
      return;
    }

    if (trimmedName.includes('/') || trimmedName.includes('\\')) {
      this.showToast('文件名不能包含路径符号');
      return;
    }

    const dir = file.path.substring(0, file.path.lastIndexOf('/'));
    const newPathCandidate = `${dir}/${trimmedName}`;
    if (this.fileManager.fileExists(newPathCandidate)) {
      this.showToast('同名文件已存在');
      return;
    }

    try {
      const newPath = this.fileManager.renameFile(file.path, trimmedName);
      const newLanguage = this.getLanguageFromFileName(trimmedName);

      this.tabs.forEach((tab) => {
        if (tab.filePath === file.path) {
          tab.filePath = newPath;
          tab.fileName = trimmedName;
          tab.language = newLanguage;
        }
      });

      if (this.filePath === file.path) {
        this.filePath = newPath;
        this.fileName = trimmedName;
        this.language = newLanguage;
      }

      this.loadInternalFiles();
      this.showToast('重命名成功');
    } catch (e) {
      this.showToast('重命名失败');
      console.error('重命名失败:', JSON.stringify(e));
    }
  }

  /**
   * 删除内部文件
   */
  private deleteInternalFile(file: FileItem) {
    this.getUIContext().getPromptAction().showDialog({
      title: '确认删除',
      message: `确定要删除 ${file.name} 吗？`,
      buttons: [
        { text: '取消', color: this.currentTheme.colors.textSecondary },
        { text: '删除', color: '#FF4444' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        try {
          this.fileManager.deleteFile(file.path);
          this.loadInternalFiles();
          
          // 如果文件在标签中打开，关闭标签
          const tab = this.tabs.find(t => t.filePath === file.path);
          if (tab) {
            this.closeTab(tab.id);
          }
          
          this.showToast('文件已删除');
        } catch (e) {
          this.showToast('删除文件失败');
        }
      }
    });
  }

  /**
   * 打开模板对话框
   */
  private openTemplateDialog() {
    // 重新创建对话框以使用最新主题
    this.templateDialogController = new CustomDialogController({
      builder: TemplateDialog({
        bgColor: this.currentTheme.colors.surface,
        textColor: this.currentTheme.colors.text,
        primaryColor: this.currentTheme.colors.primary,
        onConfirm: (template: CodeTemplate) => {
          this.insertTemplate(template);
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    
    this.templateDialogController.open();
  }
  
  /**
   * 插入模板代码
   */
  private insertTemplate(template: CodeTemplate) {
    if (this.content) {
      // 如果有内容，在末尾添加
      this.content += '\n\n' + template.code;
    } else {
      // 如果是空文件，直接插入
      this.content = template.code;
    }
    
    // 更新语言类型
    this.language = template.language;
    
    // 自动更新文件名后缀
    const suffixMap: Record<string, string> = {
      'javascript': '.js',
      'typescript': '.ts',
      'html': '.html',
      'css': '.css',
      'python': '.py',
      'json': '.json',
      'markdown': '.md',
      'text': '.txt'
    };
    const newSuffix = suffixMap[template.language] || '.txt';
    
    // 如果是未命名文件，替换后缀
    if (this.fileName === '未命名') {
      this.fileName = '未命名' + newSuffix;
    } else {
      // 如果是已命名文件，替换现有后缀
      const lastDotIndex = this.fileName.lastIndexOf('.');
      if (lastDotIndex > 0) {
        this.fileName = this.fileName.substring(0, lastDotIndex) + newSuffix;
      } else {
        this.fileName = this.fileName + newSuffix;
      }
    }
    
    this.isModified = true;
    this.lineCount = this.content.split('\n').length;
    this.saveCurrentTabState();
    
    this.showToast(`已插入模板: ${template.name}`);
  }
  
  /**
   * 切换文件浏览器显示
   */
    private toggleFileBrowser() {
      this.getUIContext().animateTo({ 
        duration: 350, 
        curve: Curve.EaseInOut 
      }, () => {
        this.showFileBrowser = !this.showFileBrowser;
        this.sidebarWidth = this.showFileBrowser ? 200 : 0;
      });
    }}
