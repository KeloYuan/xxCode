/**
 * xxCode 主编辑器页面
 * 简化版代码编辑器，支持新建、打开、保存文件
 */
import { router, window } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { ThemeService, Theme } from '../services/ThemeService';
import { BreakpointService, Breakpoint } from '../services/BreakpointService';
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
  
  // 避让区高度
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  
  // 滚动控制器
  private editorScroller: Scroller = new Scroller();
  
  private context: common.UIAbilityContext | null = null;
  private themeService: ThemeService = ThemeService.getInstance();
  private breakpointService: BreakpointService = BreakpointService.getInstance();
  
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
  }

  aboutToDisappear() {
    this.breakpointService.unregister();
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
   * 从 URI 提取文件名
   */
  private extractFileName(uri: string): string {
    const parts = uri.split('/');
    return parts[parts.length - 1] || '未命名';
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
   * 生成行号数组
   */
  private getLineNumbers(): number[] {
    const lines: number[] = [];
    for (let i = 1; i <= this.lineCount; i++) {
      lines.push(i);
    }
    return lines;
  }

  build() {
    Column() {
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.colors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .padding({ top: this.topRectHeight / 3, bottom: this.bottomRectHeight / 3 })
  }

  @Builder
  buildToolbar(): void {
    Row() {
      // 左侧：返回按钮
      Button({ type: ButtonType.Circle }) {
        Text('←')
          .fontSize(18)
          .fontColor(this.currentTheme.colors.text)
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        if (this.isModified) {
          this.showConfirmDialog('提示', '当前文件未保存，是否保存后退出？', (index: number) => {
            if (index === 0) {
              this.goBack();
            } else if (index === 1) {
              this.saveFile().then(() => {
                this.goBack();
              });
            }
          });
        } else {
          this.goBack();
        }
      })

      // 中间：标题
      Column() {
        Text(this.fileName + (this.isModified ? ' •' : ''))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTheme.colors.text)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      // 右侧：操作按钮
      Row({ space: 8 }) {
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
    Scroll(this.editorScroller) {
      Row() {
        // 行号区域
        Column() {
          ForEach(this.getLineNumbers(), (lineNum: number) => {
            Text(`${lineNum}`)
              .fontSize(14)
              .fontColor(this.currentTheme.editor.lineNumber)
              .fontFamily('monospace')
              .width(40)
              .height(22)
              .textAlign(TextAlign.End)
              .padding({ right: 12 })
          }, (lineNum: number) => lineNum.toString())
        }
        .alignItems(HorizontalAlign.End)
        .backgroundColor(this.currentTheme.colors.surface)
        .padding({ top: 12 })

        // 编辑器区域
        TextArea({ text: this.content, placeholder: '在此输入代码...' })
          .layoutWeight(1)
          .constraintSize({ minHeight: 500 })
          .fontSize(14)
          .fontColor(this.currentTheme.editor.text)
          .caretColor(this.currentTheme.colors.primary)
          .placeholderColor(this.currentTheme.colors.textSecondary)
          .backgroundColor(Color.Transparent)
          .padding({ left: 8, right: 12, top: 12, bottom: 12 })
          .fontFamily('monospace')
          .lineHeight(22)
          .onChange((value: string) => {
            this.onContentChange(value);
          })
      }
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    .backgroundColor(this.currentTheme.editor.background)
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
