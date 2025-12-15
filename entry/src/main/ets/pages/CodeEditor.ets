/**
 * xxCode 主编辑器页面
 * 简化版代码编辑器，支持新建、打开、保存文件
 */
import { router, window } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';
import { ThemeService, Theme } from '../services/ThemeService';
import { BreakpointService, Breakpoint } from '../services/BreakpointService';
import { SyntaxHighlightService, Token } from '../services/SyntaxHighlightService';
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
  // 编辑器状态
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
  
  // 避让区高度
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  
  // 滚动控制器
  private editorScroller: Scroller = new Scroller();
  
  private context: common.UIAbilityContext | null = null;
  private themeService: ThemeService = ThemeService.getInstance();
  private breakpointService: BreakpointService = BreakpointService.getInstance();
  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance();
  
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
      await this.saveToPath(this.filePath);
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
   * 切换主题
   */
  private cycleTheme() {
    const nextTheme = this.themeService.getNextTheme();
    this.themeService.switchTheme(nextTheme.id);
    this.themeService.saveThemePreference(nextTheme.id);
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
        .height(px2vp(this.topRectHeight))
        .backgroundColor(this.currentTheme.colors.surface)

      // 顶部工具栏
      this.buildToolbar()

      // 编辑区域
      Column() {
        // 文件信息栏
        this.buildFileInfoBar()
        
        // 编辑器主体
        this.buildEditor()
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(this.currentTheme.editor.background)

      // 底部导航栏占位区域
      Row()
        .width('100%')
        .height(px2vp(this.bottomRectHeight))
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
        // 设置按钮
        Button({ type: ButtonType.Circle }) {
          Text('⚙️')
            .fontSize(16)
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.openSettings();
        })
        
        // 编辑/预览切换
        Button({ type: ButtonType.Normal }) {
          Text(this.isPreviewMode ? '✏️ 编辑' : '👁️ 预览')
            .fontSize(13)
            .fontColor(this.isPreviewMode ? Color.White : this.currentTheme.colors.text)
        }
        .height(32)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.isPreviewMode ? this.currentTheme.colors.primary : this.currentTheme.colors.surface)
        .borderRadius(6)
        .onClick(() => {
          this.isPreviewMode = !this.isPreviewMode;
        })

        // 主题切换
        Button({ type: ButtonType.Circle }) {
          Text('🎨')
            .fontSize(16)
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.cycleTheme();
        })

        // 新建文件
        Button({ type: ButtonType.Normal }) {
          Text('新建')
            .fontSize(13)
            .fontColor(this.currentTheme.colors.text)
        }
        .height(32)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.currentTheme.colors.surface)
        .borderRadius(6)
        .onClick(() => {
          this.newFile();
        })

        // 打开文件
        Button({ type: ButtonType.Normal }) {
          Text('打开')
            .fontSize(13)
            .fontColor(this.currentTheme.colors.text)
        }
        .height(32)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.currentTheme.colors.surface)
        .borderRadius(6)
        .onClick(() => {
          this.openFile();
        })

        // 保存文件
        Button({ type: ButtonType.Normal }) {
          Text('保存')
            .fontSize(13)
            .fontColor(Color.White)
        }
        .height(32)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.isModified ? this.currentTheme.colors.primary : this.currentTheme.colors.surface)
        .borderRadius(6)
        .onClick(() => {
          this.saveFile();
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
          .backgroundColor(this.currentTheme.colors.surface)
          
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
                  }, (token: Token, tokenIndex: number) => `${lineIndex}_${tokenIndex}_${token.start}`)
                }
                .width('100%')
                .lineHeight(this.fontSize + 8)
              }
              .width('100%')
              .height(this.fontSize + 8)
              .alignItems(VerticalAlign.Top)
            }, (line: string, lineIndex: number) => `hl_${lineIndex}_${line.substring(0, 20)}`)
          }
          .layoutWeight(1)
          .padding({ left: 8, right: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .padding({ top: 12, bottom: 12 })
      }
      .width('100%')
      .layoutWeight(1)
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
          .backgroundColor(this.currentTheme.colors.surface)
          
          // 分隔线
          Column()
            .width(1)
            .backgroundColor(this.currentTheme.colors.border)
          
          // 右侧代码编辑区 - 使用固定高度的 TextArea
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
        .padding({ top: 12, bottom: 12 })
      }
      .width('100%')
      .layoutWeight(1)
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
   * 获取显示的行号（至少显示 100 行，保证一屏都有行号）
   */
  private getDisplayLineNumbers(): number[] {
    const minLines = 100; // 至少显示 100 行
    const totalLines = Math.max(this.lineCount, minLines);
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
   * 返回上一页（封装新 API）
   */
  private goBack() {
    try {
      router.back();
    } catch (e) {
      console.error('router.back error:', JSON.stringify(e));
    }
  }
}
