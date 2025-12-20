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
import { IconButton } from '../components/IconButton';
import { TabBar } from '../components/TabBar';
import { FileBrowser } from '../components/FileBrowser';
import { NewFileDialog } from '../components/NewFileDialog';
import { promptAction } from '@kit.ArkUI';

// 文件类型配置
interface FileTypeOption {
  name: string;
  suffix: string;
  language: string;
}

@Entry
@Component
struct CodeEditor {
  // 页面转场动画配置
  pageTransition() {
    // 进入动画：从右侧滑入
    PageTransitionEnter({ duration: 350, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    // 退出动画：向左侧滑出
    PageTransitionExit({ duration: 350, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
  }
  
  // 多标签状态
  @State tabs: FileTab[] = [];
  @State currentTabId: string = '';
  @State showFileBrowser: boolean = true;
  @State sidebarWidth: number = 200; // 侧边栏宽度
  @State internalFiles: FileItem[] = [];
  
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
  @State editorScale: number = 1; // 编辑器缩放
  
  // 搜索替换状态
  @State showSearchBar: boolean = false;
  @State searchText: string = '';
  @State replaceText: string = '';
  @State searchResults: number[] = []; // 匹配的位置
  @State currentSearchIndex: number = -1;
  
  // 动画曲线
  private springCurve: ICurve = curves.springMotion(0.6, 0.8);
  
  // 对话框控制器
  private newFileDialogController: CustomDialogController = new CustomDialogController({
    builder: NewFileDialog({
      bgColor: this.currentTheme.colors.surface,
      textColor: this.currentTheme.colors.text,
      primaryColor: this.currentTheme.colors.primary,
      onConfirm: (fileName: string) => {
        this.handleCreateFile(fileName);
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });
  
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

  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    
    // 初始化文件管理器
    if (this.context) {
      this.fileManager.init(this.context);
      this.loadInternalFiles();
    }
    
    // 创建默认标签
    this.createNewTab();
    
    // 注册断点系统
    this.breakpointService.register();
    this.currentBreakpoint = this.breakpointService.getCurrentBreakpoint();
    this.breakpointService.onChange((breakpoint: Breakpoint) => {
      this.currentBreakpoint = breakpoint;
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
  }
  
  /**
   * 加载字体大小设置
   */
  private loadFontSize() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'settings' });
      this.fontSize = store.getSync('fontSize', 14) as number;
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

  aboutToDisappear() {
    this.breakpointService.unregister();
  }
  
  onPageShow() {
    // 从设置页面返回时重新加载字体大小
    this.loadFontSize();
  }

  /**
   * 根据当前主题更新系统状态栏颜色
   */
  private updateSystemBarColor(theme: Theme) {
    try {
      if (!this.context) {
        return;
      }
      
      const isDarkTheme = theme.id !== 'light';
      
      window.getLastWindow(this.context).then((windowClass) => {
        const systemBarProperties: window.SystemBarProperties = {
          statusBarContentColor: isDarkTheme ? '#FFFFFF' : '#000000',
          navigationBarContentColor: isDarkTheme ? '#FFFFFF' : '#000000',
          statusBarColor: '#00000000',
          navigationBarColor: '#00000000'
        };
        
        windowClass.setWindowSystemBarProperties(systemBarProperties);
      }).catch((err: Error) => {
        console.error('Failed to get window:', err.message);
      });
    } catch (error) {
      console.error('Failed to update system bar color:', JSON.stringify(error));
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

      this.showToast('文件已打开');
    } catch (err) {
      const error = err as Error;
      console.error('打开文件失败:', error.message);
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
      await this.saveFileAs();
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
      
      // 获取当前文件后缀对应的文件类型
      const currentSuffix = this.getCurrentFileSuffix();
      
      const result = await documentPicker.save({
        newFileNames: [this.fileName === '未命名' ? `新文件${currentSuffix}` : this.fileName],
      });
      
      if (!result || result.length === 0) {
        return;
      }
      
      const saveUri = result[0];
      await this.saveToPath(saveUri);
      
      // 更新文件信息
      this.filePath = saveUri;
      this.fileName = this.extractFileName(saveUri);
      this.language = this.getLanguageFromFileName(this.fileName);
      
    } catch (err) {
      const error = err as Error;
      console.error('保存文件失败:', error.message);
      this.showToast(`保存失败: ${error.message}`);
    }
  }

  /**
   * 保存到指定路径
   */
  private async saveToPath(uri: string) {
    try {
      // 将字符串转换为 Uint8Array
      const textEncoder = util.TextEncoder.create();
      const buffer = textEncoder.encodeInto(this.content);

      // 写入文件
      const file = fileIo.openSync(uri, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(file.fd, buffer.buffer);
      fileIo.closeSync(file);

      this.isModified = false;
      this.showToast('保存成功');
    } catch (err) {
      const error = err as Error;
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
    animateTo({ 
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
  }

  /**
   * 获取代码行数组
   */
  private getCodeLines(): string[] {
    return this.content.split('\n');
  }

  /**
   * 获取 token 对应的颜色
   */
  private getTokenColor(type: string): string {
    const colorMap: Record<string, string> = {
      'keyword': this.currentTheme.syntax.keyword,
      'string': this.currentTheme.syntax.string,
      'comment': this.currentTheme.syntax.comment,
      'number': this.currentTheme.syntax.number,
      'function': this.currentTheme.syntax.function,
      'variable': this.currentTheme.syntax.variable,
      'operator': this.currentTheme.syntax.operator,
      'bracket': this.currentTheme.editor.text,
      'type': this.currentTheme.syntax.type,
      'text': this.currentTheme.editor.text
    };
    return colorMap[type] || this.currentTheme.editor.text;
  }

  /**
   * 生成行号数组
   */
  private getLineNumbers(): number[] {
    const lines: number[] = [];
    for (let i = 1; i <= this.lineCount; i++) {
      lines.push(i);
    }
    return lines;
  }

  /**
   * 获取每行的缩进级别（以2个空格为一级）
   */
  private getLineIndentLevels(): number[] {
    const lines = this.content.split('\n');
    const indentLevels: number[] = [];
    
    for (const line of lines) {
      let spaces = 0;
      for (const char of line) {
        if (char === ' ') {
          spaces++;
        } else if (char === '\t') {
          spaces += 2; // tab 算 2 个空格
        } else {
          break;
        }
      }
      // 每 2 个空格算一级缩进
      indentLevels.push(Math.floor(spaces / 2));
    }
    
    return indentLevels;
  }

  /**
   * 获取最大缩进级别
   */
  private getMaxIndentLevel(): number {
    const levels = this.getLineIndentLevels();
    return Math.max(...levels, 0);
  }

  build() {
    Column() {
      // 状态栏占位区域
      Row()
        .width('100%')
        .height(this.topRectHeight > 0 ? this.topRectHeight / 3 : 0)
        .backgroundColor(this.currentTheme.colors.surface)

      // 顶部工具栏
      this.buildToolbar()

      // 主内容区域
      Row() {
        // 文件浏览器侧边栏（带伸缩动画）
        FileBrowser({
          files: this.internalFiles,
          currentFilePath: this.filePath,
          workspacePath: this.fileManager.getWorkspacePath(),
          bgColor: this.currentTheme.colors.surface,
          textColor: this.currentTheme.colors.text,
          fileBorderColor: this.currentTheme.colors.border,
          activeFileBgColor: this.currentTheme.editor.background,
          onFileClick: (file: FileItem) => {
            this.openInternalFile(file);
          },
          onNewFile: () => {
            this.createInternalFile();
          },
          onDeleteFile: (file: FileItem) => {
            this.deleteInternalFile(file);
          }
        })
          .width(this.sidebarWidth)
          .opacity(this.sidebarWidth > 0 ? 1 : 0)
          .clip(true)
          .animation({ 
            duration: 350, 
            curve: this.springCurve 
          })

        // 编辑区域
        Column() {
          // 标签栏（左对齐，带动画）
          Row() {
            TabBar({
              tabs: this.tabs,
              currentTabId: this.currentTabId,
              bgColor: this.currentTheme.colors.surface,
              textColor: this.currentTheme.colors.text,
              tabBorderColor: this.currentTheme.colors.border,
              activeTabBgColor: this.currentTheme.editor.background,
              onTabClick: (tabId: string) => {
                this.switchToTab(tabId);
              },
              onTabClose: (tabId: string) => {
                this.closeTab(tabId);
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .animation({ 
            duration: 350, 
            curve: this.springCurve 
          })
          
          // 文件信息栏
          this.buildFileInfoBar()
          
          // 搜索替换栏
          if (this.showSearchBar) {
            this.buildSearchBar()
          }
          
          // 编辑器主体
          this.buildEditor()
        }
        .layoutWeight(1)
        .backgroundColor(this.currentTheme.editor.background)
        .scale({ x: this.editorScale, y: this.editorScale })
        .animation({ 
          duration: 300, 
          curve: this.springCurve 
        })
      }
      .layoutWeight(1)
      .width('100%')

      // 底部导航栏占位区域
      Row()
        .width('100%')
        .height(this.bottomRectHeight > 0 ? this.bottomRectHeight / 3 : 0)
        .backgroundColor(this.currentTheme.editor.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.colors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildToolbar(): void {
    Row() {
      // 左侧：标题
      Column() {
        Text(this.fileName + (this.isModified ? ' •' : ''))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTheme.colors.text)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 右侧：操作按钮
      Row({ space: 8 }) {
        // 文件浏览器切换
        IconButton({
          icon: '📂',
          text: '文件',
          isActive: this.showFileBrowser,
          bgColor: this.currentTheme.colors.surface,
          activeColor: this.currentTheme.colors.primary,
          textColor: this.currentTheme.colors.text,
          btnSize: 32,
          fontSize: 13,
          onButtonClick: () => {
            this.toggleFileBrowser();
          }
        })
        
        // 新建标签
        IconButton({
          icon: '➕',
          text: '新标签',
          bgColor: this.currentTheme.colors.surface,
          textColor: this.currentTheme.colors.text,
          btnSize: 32,
          fontSize: 13,
          onButtonClick: () => {
            this.createNewTab();
          }
        })
        
        // 格式化按钮
        IconButton({
          icon: '✨',
          text: '格式化',
          bgColor: this.currentTheme.colors.surface,
          textColor: this.currentTheme.colors.text,
          btnSize: 32,
          fontSize: 13,
          onButtonClick: () => {
            this.formatCode();
          }
        })
        
        // 搜索按钮
        IconButton({
          icon: '🔍',
          text: '搜索',
          isActive: this.showSearchBar,
          bgColor: this.currentTheme.colors.surface,
          activeColor: this.currentTheme.colors.primary,
          textColor: this.currentTheme.colors.text,
          btnSize: 32,
          fontSize: 13,
          onButtonClick: () => {
            animateTo({ 
              duration: 250, 
              curve: Curve.EaseInOut 
            }, () => {
              this.showSearchBar = !this.showSearchBar;
            });
          }
        })
        
        // 编辑/预览切换
        IconButton({
          icon: this.isPreviewMode ? '✏️' : '👁️',
          text: this.isPreviewMode ? '编辑' : '预览',
          isActive: this.isPreviewMode,
          bgColor: this.currentTheme.colors.surface,
          activeColor: this.currentTheme.colors.primary,
          textColor: this.currentTheme.colors.text,
          btnSize: 32,
          fontSize: 13,
          onButtonClick: () => {
            animateTo({ 
              duration: 300, 
              curve: this.springCurve 
            }, () => {
              this.isPreviewMode = !this.isPreviewMode;
              this.editorScale = this.isPreviewMode ? 0.98 : 1;
            });
            setTimeout(() => {
              animateTo({ duration: 200 }, () => {
                this.editorScale = 1;
              });
            }, 100);
          }
        })

        // 主题切换
        IconButton({
          icon: '🎨',
          text: '主题',
          bgColor: this.currentTheme.colors.surface,
          textColor: this.currentTheme.colors.text,
          btnSize: 32,
          fontSize: 13,
          onButtonClick: () => {
            this.cycleTheme();
          }
        })

        // 打开外部文件
        IconButton({
          icon: '📁',
          text: '打开',
          bgColor: this.currentTheme.colors.surface,
          textColor: this.currentTheme.colors.text,
          btnSize: 32,
          fontSize: 13,
          onButtonClick: () => {
            this.openFile();
          }
        })

        // 保存文件
        IconButton({
          icon: '💾',
          text: '保存',
          isActive: this.isModified,
          bgColor: this.currentTheme.colors.surface,
          activeColor: this.currentTheme.colors.primary,
          textColor: this.currentTheme.colors.text,
          btnSize: 32,
          fontSize: 13,
          onButtonClick: () => {
            this.saveFile();
          }
        })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.currentTheme.colors.surface)
    .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })
  }

  @Builder
  buildFileInfoBar(): void {
    Row() {
      // 文件类型标识
      Text(this.language.toUpperCase())
        .fontSize(11)
        .fontColor(this.currentTheme.colors.textSecondary)
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        .backgroundColor(this.currentTheme.colors.background)
        .borderRadius(4)

      Blank()

      // 字符数统计
      Text(`${this.content.length} 字符`)
        .fontSize(11)
        .fontColor(this.currentTheme.colors.textSecondary)
      
      Text(' | ')
        .fontSize(11)
        .fontColor(this.currentTheme.colors.border)
      
      // 行数统计
      Text(`${this.lineCount} 行`)
        .fontSize(11)
        .fontColor(this.currentTheme.colors.textSecondary)
    }
    .width('100%')
    .height(28)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.currentTheme.colors.surface)
    .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })
  }

  @Builder
  buildSearchBar(): void {
    Column() {
      // 搜索行
      Row({ space: 8 }) {
        TextInput({ placeholder: '搜索', text: this.searchText })
          .layoutWeight(1)
          .height(36)
          .fontSize(14)
          .backgroundColor(this.currentTheme.editor.background)
          .fontColor(this.currentTheme.colors.text)
          .placeholderColor(this.currentTheme.colors.textSecondary)
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit(() => {
            this.performSearch();
          })
        
        Button('搜索')
          .height(36)
          .fontSize(13)
          .backgroundColor(this.currentTheme.colors.primary)
          .fontColor(Color.White)
          .stateEffect(true)
          .onClick(() => {
            this.performSearch();
          })
        
        Button('上一个')
          .height(36)
          .fontSize(13)
          .backgroundColor(this.currentTheme.editor.background)
          .fontColor(this.currentTheme.colors.text)
          .stateEffect(true)
          .onClick(() => {
            this.prevSearchResult();
          })
        
        Button('下一个')
          .height(36)
          .fontSize(13)
          .backgroundColor(this.currentTheme.editor.background)
          .fontColor(this.currentTheme.colors.text)
          .stateEffect(true)
          .onClick(() => {
            this.nextSearchResult();
          })
        
        Button('关闭')
          .height(36)
          .fontSize(13)
          .backgroundColor(Color.Transparent)
          .fontColor(this.currentTheme.colors.text)
          .stateEffect(true)
          .onClick(() => {
            this.showSearchBar = false;
            this.searchResults = [];
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8 })
      
      // 替换行
      Row({ space: 8 }) {
        TextInput({ placeholder: '替换为', text: this.replaceText })
          .layoutWeight(1)
          .height(36)
          .fontSize(14)
          .backgroundColor(this.currentTheme.editor.background)
          .fontColor(this.currentTheme.colors.text)
          .placeholderColor(this.currentTheme.colors.textSecondary)
          .onChange((value: string) => {
            this.replaceText = value;
          })
        
        Button('替换')
          .height(36)
          .fontSize(13)
          .backgroundColor(this.currentTheme.editor.background)
          .fontColor(this.currentTheme.colors.text)
          .stateEffect(true)
          .onClick(() => {
            this.replaceCurrent();
          })
        
        Button('全部替换')
          .height(36)
          .fontSize(13)
          .backgroundColor(this.currentTheme.editor.background)
          .fontColor(this.currentTheme.colors.text)
          .stateEffect(true)
          .onClick(() => {
            this.replaceAll();
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 4, bottom: 8 })
      
      // 搜索结果提示
      if (this.searchResults.length > 0) {
        Text(`${this.currentSearchIndex + 1} / ${this.searchResults.length}`)
          .fontSize(12)
          .fontColor(this.currentTheme.colors.text)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ bottom: 4 })
      }
    }
    .width('100%')
    .backgroundColor(this.currentTheme.colors.surface)
    .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })
    .opacity(this.showSearchBar ? 1 : 0)
    .height(this.showSearchBar ? undefined : 0)
    .clip(true)
    .animation({ 
      duration: 250, 
      curve: Curve.EaseInOut 
    })
  }

  @Builder
  buildEditor(): void {
    if (this.isPreviewMode) {
      // 预览模式：行号和代码一起滚动
      Scroll(this.editorScroller) {
        Row() {
          // 行号列
          Column() {
            ForEach(this.getDisplayLineNumbers(), (lineNum: number) => {
              Text(`${lineNum}`)
                .fontSize(this.fontSize)
                .fontColor(this.currentTheme.editor.lineNumber)
                .fontFamily('monospace')
                .width(40)
                .height(this.fontSize + 8)
                .textAlign(TextAlign.End)
                .padding({ right: 8 })
                .opacity(lineNum <= this.lineCount ? 1.0 : 0.3)
            }, (lineNum: number) => `ln_${lineNum}`)
          }
          .alignItems(HorizontalAlign.End)
          .backgroundColor(this.currentTheme.editor.background)
          
          // 分隔线
          Column()
            .width(1)
            .height('100%')
            .backgroundColor(this.currentTheme.colors.border)
          
          // 代码区域（高亮）
          Column() {
            ForEach(this.getCodeLines(), (line: string, lineIndex: number) => {
              Row() {
                Text() {
                  ForEach(this.syntaxService.tokenize(line, this.language), (token: Token, tokenIndex: number) => {
                    // 将空格替换为不间断空格，防止被折叠
                    Span(token.value.replace(/ /g, '\u00A0'))
                      .fontSize(this.fontSize)
                      .fontColor(this.getTokenColor(token.type))
                      .fontFamily('monospace')
                  }, (token: Token, tokenIndex: number) => `t_${lineIndex}_${tokenIndex}`)
                }
                .fontSize(this.fontSize)
                .fontFamily('monospace')
                .lineHeight(this.fontSize + 8)
                .textOverflow({ overflow: TextOverflow.Clip })
                .maxLines(1)
              }
              .width('100%')
              .height(this.fontSize + 8)
              .alignItems(VerticalAlign.Top)
            }, (line: string, lineIndex: number) => `line_${lineIndex}`)
          }
          .layoutWeight(1)
          .padding({ left: 8, right: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .scrollBar(BarState.On)
      .scrollBarWidth(10)
      .scrollBarColor(this.currentTheme.colors.textSecondary)
      .backgroundColor(this.currentTheme.editor.background)
    } else {
      // 编辑模式：使用 Scroll 包裹行号和 TextArea，实现同步滚动
      Scroll(this.editorScroller) {
        Row() {
          // 左侧行号区域
          Column() {
            ForEach(this.getDisplayLineNumbers(), (lineNum: number) => {
              Text(`${lineNum}`)
                .fontSize(this.fontSize)
                .fontColor(this.currentTheme.editor.lineNumber)
                .fontFamily('monospace')
                .width(40)
                .height(this.fontSize + 8)
                .textAlign(TextAlign.End)
                .padding({ right: 8 })
                .opacity(lineNum <= this.lineCount ? 1.0 : 0.3)
            }, (lineNum: number) => `edit_ln_${lineNum}`)
          }
          .alignItems(HorizontalAlign.End)
          .backgroundColor(this.currentTheme.editor.background)
          
          // 分隔线
          Column()
            .width(1)
            .height('100%')
            .backgroundColor(this.currentTheme.colors.border)
          
          // 右侧代码编辑区
          Column() {
            TextArea({ text: this.content, placeholder: '在此输入代码...' })
              .width('100%')
              .constraintSize({ minHeight: this.getEditorMinHeight() })
              .fontSize(this.fontSize)
              .fontColor(this.currentTheme.editor.text)
              .caretColor(this.currentTheme.colors.primary)
              .placeholderColor(this.currentTheme.colors.textSecondary)
              .backgroundColor(Color.Transparent)
              .padding(0)
              .fontFamily('monospace')
              .lineHeight(this.fontSize + 8)
              .wordBreak(WordBreak.BREAK_ALL)
              .onChange((value: string) => {
                this.onContentChange(value);
              })
          }
          .layoutWeight(1)
          .padding({ left: 8, right: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .scrollBar(BarState.On)
      .scrollBarWidth(10)
      .scrollBarColor(this.currentTheme.colors.textSecondary)
      .backgroundColor(this.currentTheme.editor.background)
    }
  }
  
  /**
   * 计算编辑器最小高度，确保行号和内容对齐
   */
  private getEditorMinHeight(): number {
    const lineHeight = this.fontSize + 8;
    const minLines = Math.max(this.lineCount, 100);
    return minLines * lineHeight;
  }

  /**
   * 获取显示的行号
   * 预览模式：只显示实际代码行数
   * 编辑模式：至少显示100行，方便编辑
   */
  private getDisplayLineNumbers(): number[] {
    // 直接根据内容计算行数，不依赖 lineCount 状态
    const actualLines = this.content.split('\n').length;
    // 预览模式只显示实际行数，编辑模式至少显示100行
    const minLines = this.isPreviewMode ? actualLines : 100;
    const totalLines = Math.max(actualLines, minLines);
    const lines: number[] = [];
    for (let i = 1; i <= totalLines; i++) {
      lines.push(i);
    }
    return lines;
  }

  /**
   * 显示 Toast 提示（封装新 API）
   */
  private showToast(message: string) {
    try {
      promptAction.showToast({ message: message });
    } catch (e) {
      console.error('showToast error:', JSON.stringify(e));
    }
  }

  /**
   * 显示确认对话框（封装新 API）
   */
  private showConfirmDialog(title: string, message: string, callback: (index: number) => void) {
    try {
      promptAction.showDialog({
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
      this.content = tab.content;
      this.fileName = tab.fileName;
      this.filePath = tab.filePath;
      this.isModified = tab.isModified;
      this.language = tab.language;
      this.lineCount = tab.content.split('\n').length;
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
      
    } catch (e) {
      this.showToast('打开文件失败');
      console.error('打开内部文件失败:', JSON.stringify(e));
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
   * 删除内部文件
   */
  private deleteInternalFile(file: FileItem) {
    promptAction.showDialog({
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
   * 切换文件浏览器显示
   */
  private toggleFileBrowser() {
    animateTo({ 
      duration: 350, 
      curve: this.springCurve 
    }, () => {
      if (this.showFileBrowser) {
        // 收起：宽度变为0
        this.sidebarWidth = 0;
      } else {
        // 展开：宽度变为200
        this.sidebarWidth = 200;
      }
      this.showFileBrowser = !this.showFileBrowser;
    });
  }
}
