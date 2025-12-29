/**
 * 桌面端布局组件
 * 适用于大屏设备的编辑器布局
 *
 * 布局结构:
 * - 顶部工具栏 (60vp): 文件信息 + 11个操作按钮
 * - 左侧文件浏览器 (200vp): 可折叠
 * - 标签栏 (48vp): 水平标签切换
 * - 编辑器主体: 搜索栏 + 文件信息栏 + 编辑区域
 * - 控制台面板: 可折叠
 */
import { BreakpointService } from '../../services/BreakpointService';
import { CodeEditorView } from '../CodeEditorView';
import { TabBar } from '../TabBar';
import { FileBrowser } from '../FileBrowser';
import { IconButton } from '../IconButton';
import { ConsolePanel } from '../ConsolePanel';
import { EditorState, EditorCallbacks } from './ResponsiveLayout';
import { SyntaxHighlightService, Token } from '../../services/SyntaxHighlightService';
import { FileItem } from '../../services/FileManagerService';

@Component
export struct DesktopLayout {
  @Prop state: EditorState;
  @Prop callbacks: EditorCallbacks;
  @Prop breakpointService: BreakpointService;

  // 滚动控制器
  private editorScroller: Scroller = new Scroller();
  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance();

  build() {
    Column() {
      // 状态栏占位
      Row()
        .width('100%')
        .height(this.state.topRectHeight > 0 ? this.state.topRectHeight / 3 : 0)
        .backgroundColor(this.state.currentTheme.colors.surface)

      // 桌面端顶部工具栏
      this.buildToolbar()

      // 主内容区域
      Row() {
        // 文件浏览器侧边栏
        if (this.state.showFileBrowser) {
          FileBrowser({
            files: this.state.internalFiles,
            currentFilePath: this.state.filePath,
            workspacePath: this.state.workspacePath || $r('app.string.text_workspace'),
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            fileBorderColor: this.state.currentTheme.colors.border,
            activeFileBgColor: this.state.currentTheme.editor.background,
            onFileClick: (file: FileItem) => {
              this.callbacks.onFileClick(file);
            },
            onNewFile: () => {
              this.callbacks.onNewFile();
            },
            onRenameFile: (file: FileItem) => {
              this.callbacks.onRenameFile(file);
            },
            onDeleteFile: (file: FileItem) => {
              this.callbacks.onDeleteFile(file);
            }
          })
            .width(this.state.sidebarWidth)
            .height('100%')
            .opacity(this.state.sidebarWidth > 0 ? 1 : 0)
            .clip(true)
            .transition(TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut })
                .combine(TransitionEffect.translate({ x: -50 })),
              TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut })
                .combine(TransitionEffect.translate({ x: -50 }))
            ))
        }

        // 编辑区域
        Column() {
          // 标签栏
          Row() {
            TabBar({
              tabs: this.state.tabs,
              currentTabId: this.state.currentTabId,
              bgColor: this.state.currentTheme.colors.surface,
              textColor: this.state.currentTheme.colors.text,
              tabBorderColor: this.state.currentTheme.colors.border,
              activeTabBgColor: this.state.currentTheme.colors.primary,
              onTabClick: (tabId: string) => {
                this.callbacks.onTabClick(tabId);
              },
              onTabClose: (tabId: string) => {
                this.callbacks.onTabClose(tabId);
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Top)
          .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut })
            .combine(TransitionEffect.translate({ y: -10 })))

          // 文件信息栏
          this.buildFileInfoBar()

          // 搜索替换栏
          if (this.state.showSearchBar) {
            this.buildSearchBar()
          }

          // 编辑器主体
          this.buildEditor()

          // 控制台面板
          ConsolePanel({
            visible: this.state.showConsole,
            logs: this.state.consoleLogs,
            isExecuting: this.state.isExecutingCode,
            panelHeight: 300,
            onClose: () => {
              this.callbacks.onCloseConsole();
            },
            onClear: () => {
              this.callbacks.onClearConsole();
            }
          })

          // 隐藏的 Web 组件
          Web({ src: 'about:blank', controller: this.state.webController })
            .width(0)
            .height(0)
            .visibility(Visibility.Visible)
            .onConsole((event) => {
              if (event) {
                const msg = event.message.getMessage();
                const level = event.message.getMessageLevel();
                let prefix = '[Log] ';
                if (level === 4) prefix = '[Error] ';
                if (level === 3) prefix = '[Warn] ';

                this.state.consoleLogs.push(prefix + msg);
                return true;
              }
              return false;
            })
        }
        .layoutWeight(1)
        .backgroundColor(this.state.currentTheme.editor.background)
        .scale({ x: this.state.editorScale, y: this.state.editorScale })
      }
      .alignItems(VerticalAlign.Top)
      .layoutWeight(1)
      .width('100%')

      // 底部导航栏占位
      Row()
        .width('100%')
        .height(this.state.bottomRectHeight > 0 ? this.state.bottomRectHeight / 3 : 0)
        .backgroundColor(this.state.currentTheme.editor.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.state.currentTheme.colors.background)
  }

  /**
   * 桌面端顶部工具栏
   * 左侧: 文件信息 | 右侧: 11个操作按钮 (横向滚动)
   */
  @Builder
  buildToolbar(): void {
    Row() {
      // 左侧: 标题和状态
      Column() {
        Row({ space: 8 }) {
          // 文件扩展名徽章
          Text(`.${this.getFileExtensionBadge()}`)
            .fontSize(11)
            .fontColor(this.state.currentTheme.colors.primary)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(`${this.state.currentTheme.colors.primary}15`)
            .borderRadius(4)
            .border({
              width: 0.5,
              color: this.state.currentTheme.colors.primary
            })

          Text(this.state.fileName + (this.state.isModified ? ' •' : ''))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.state.currentTheme.colors.text)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 右侧: 操作按钮组
      Scroll() {
        Row({ space: 6 }) {
          // 文件浏览器切换
          IconButton({
            text: this.state.showFileBrowser ? $r('app.string.btn_hide') : $r('app.string.btn_files'),
            isActive: this.state.showFileBrowser,
            bgColor: this.state.currentTheme.colors.surface,
            activeColor: this.state.currentTheme.colors.primary,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onToggleFileBrowser();
            }
          })

          // 新建标签
          IconButton({
            text: $r('app.string.btn_new'),
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onNewTab();
            }
          })

          // 插入模板按钮
          IconButton({
            text: $r('app.string.btn_template'),
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onOpenTemplateDialog();
            }
          })

          // 格式化按钮
          IconButton({
            text: $r('app.string.btn_format'),
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onFormatCode();
            }
          })

          // 搜索按钮
          IconButton({
            text: $r('app.string.btn_search'),
            isActive: this.state.showSearchBar,
            bgColor: this.state.currentTheme.colors.surface,
            activeColor: this.state.currentTheme.colors.primary,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onToggleSearchBar();
            }
          })

          // 编辑/预览切换
          IconButton({
            text: this.state.isPreviewMode ? $r('app.string.btn_edit') : $r('app.string.btn_preview'),
            isActive: this.state.isPreviewMode,
            bgColor: this.state.currentTheme.colors.surface,
            activeColor: this.state.currentTheme.colors.primary,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onTogglePreviewMode();
            }
          })

          // 打开外部文件
          IconButton({
            text: $r('app.string.btn_open'),
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onOpenFile();
            }
          })

          // 导入到工作区
          IconButton({
            text: $r('app.string.btn_import'),
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onImportFile();
            }
          })

          // 保存文件
          IconButton({
            text: $r('app.string.btn_save'),
            isActive: this.state.isModified,
            bgColor: this.state.currentTheme.colors.surface,
            activeColor: this.state.currentTheme.colors.primary,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onSaveFile();
            }
          })

          // 导出副本
          IconButton({
            text: $r('app.string.btn_export'),
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onExportFile();
            }
          })

          // 设置按钮
          IconButton({
            text: $r('app.string.btn_settings'),
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            btnSize: 40,
            fontSize: 14,
            onButtonClick: () => {
              this.callbacks.onOpenSettings();
            }
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.state.currentTheme.colors.surface)
    .border({ width: { bottom: 0.5 }, color: this.state.currentTheme.colors.border })
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * 文件信息栏
   */
  @Builder
  buildFileInfoBar(): void {
    Row() {
      // 文件类型标识
      Text(this.state.language.toUpperCase())
        .fontSize(11)
        .fontColor(this.state.currentTheme.colors.primary)
        .fontWeight(FontWeight.Medium)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(this.state.currentTheme.colors.background)
        .borderRadius(8)
        .border({
          width: 1,
          color: this.state.currentTheme.colors.primary
        })

      Blank()

      // 统计信息
      Row({ space: 12 }) {
        Row({ space: 4 }) {
          Text('字符')
            .fontSize(11)
            .fontColor(this.state.currentTheme.colors.textSecondary)
            .opacity(0.6)
          Text(`${this.state.content.length}`)
            .fontSize(12)
            .fontColor(this.state.currentTheme.colors.textSecondary)
            .fontWeight(FontWeight.Medium)
        }

        Row({ space: 4 }) {
          Text('行数')
            .fontSize(11)
            .fontColor(this.state.currentTheme.colors.textSecondary)
            .opacity(0.6)
          Text(`${this.state.lineCount}`)
            .fontSize(12)
            .fontColor(this.state.currentTheme.colors.textSecondary)
            .fontWeight(FontWeight.Medium)
        }
      }
    }
    .width('100%')
    .height(32)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.state.currentTheme.colors.surface)
    .border({ width: { bottom: 0.5 }, color: this.state.currentTheme.colors.border })
  }

  /**
   * 搜索替换栏
   */
  @Builder
  buildSearchBar(): void {
    Column() {
      // 搜索行
      Row({ space: 8 }) {
        TextInput({ placeholder: $r('app.string.placeholder_search'), text: this.state.searchText })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .placeholderColor(this.state.currentTheme.colors.textSecondary)
          .borderRadius(12)
          .padding({ left: 12, right: 12 })
          .border({
            width: 1,
            color: this.state.currentTheme.colors.border
          })
          .onChange((value: string) => {
            this.callbacks.onSearchChange(value);
          })
          .onSubmit(() => {
            this.callbacks.onPerformSearch();
          })

        if (this.state.searchResults.length > 0) {
          Text(`${this.state.currentSearchIndex + 1}/${this.state.searchResults.length}`)
            .fontSize(12)
            .fontColor(this.state.currentTheme.colors.textSecondary)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 8, right: 8 })
        }

        Button($r('app.string.btn_previous'))
          .height(40)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .borderRadius(12)
          .border({
            width: 1,
            color: this.state.currentTheme.colors.border
          })
          .stateEffect(true)
          .enabled(this.state.searchResults.length > 0)
          .onClick(() => {
            this.callbacks.onPrevSearch();
          })

        Button($r('app.string.btn_next'))
          .height(40)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .borderRadius(12)
          .border({
            width: 1,
            color: this.state.currentTheme.colors.border
          })
          .stateEffect(true)
          .enabled(this.state.searchResults.length > 0)
          .onClick(() => {
            this.callbacks.onNextSearch();
          })

        Button($r('app.string.btn_search'))
          .height(40)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.colors.primary)
          .fontColor(Color.White)
          .borderRadius(12)
          .stateEffect(true)
          .onClick(() => {
            this.callbacks.onPerformSearch();
          })

        Button($r('app.string.btn_close'))
          .height(40)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Transparent)
          .fontColor(this.state.currentTheme.colors.textSecondary)
          .borderRadius(12)
          .stateEffect(true)
          .onClick(() => {
            this.callbacks.onCloseSearchBar();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      // 替换行
      Row({ space: 8 }) {
        TextInput({ placeholder: $r('app.string.placeholder_replace'), text: this.state.replaceText })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .placeholderColor(this.state.currentTheme.colors.textSecondary)
          .borderRadius(12)
          .padding({ left: 12, right: 12 })
          .border({
            width: 1,
            color: this.state.currentTheme.colors.border
          })
          .onChange((value: string) => {
            this.callbacks.onReplaceChange(value);
          })

        Button($r('app.string.btn_replace'))
          .height(40)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .borderRadius(12)
          .border({
            width: 1,
            color: this.state.currentTheme.colors.border
          })
          .stateEffect(true)
          .enabled(this.state.searchResults.length > 0)
          .onClick(() => {
            this.callbacks.onReplaceCurrent();
          })

        Button($r('app.string.btn_all'))
          .height(40)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .borderRadius(12)
          .border({
            width: 1,
            color: this.state.currentTheme.colors.border
          })
          .stateEffect(true)
          .enabled(this.state.searchResults.length > 0)
          .onClick(() => {
            this.callbacks.onReplaceAll();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 12 })
    }
    .width('100%')
    .backgroundColor(this.state.currentTheme.colors.surface)
    .border({ width: { bottom: 0.5 }, color: this.state.currentTheme.colors.border })
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * 编辑器主体
   */
  @Builder
  buildEditor(): void {
    if (this.state.isPreviewMode) {
      // 预览模式
      Scroll(this.editorScroller) {
        Row() {
          // 行号列
          if (this.state.showLineNumbers) {
            Column() {
              ForEach(this.getDisplayLineNumbers(), (lineNum: number) => {
                Text(`${lineNum}`)
                  .fontSize(this.state.fontSize)
                  .fontColor(this.state.currentTheme.editor.lineNumber)
                  .fontFamily('monospace')
                  .width(40)
                  .height(this.state.lineHeight)
                  .textAlign(TextAlign.End)
                  .padding({ right: 8 })
                  .opacity(lineNum <= this.state.lineCount ? 1.0 : 0.3)
              }, (lineNum: number) => `ln_${lineNum}`)
            }
            .alignItems(HorizontalAlign.End)
            .backgroundColor(this.state.currentTheme.editor.background)

            Column()
              .width(1)
              .height('100%')
              .backgroundColor(this.state.currentTheme.colors.border)
          }

          // 代码区域
          Column() {
            ForEach(this.getCodeLines(), (line: string, lineIndex: number) => {
              Row() {
                Text() {
                  ForEach(this.syntaxService.tokenize(line, this.state.language), (token: Token, tokenIndex: number) => {
                    Span(token.value.replace(/ /g, '\u00A0'))
                      .fontSize(this.state.fontSize)
                      .fontColor(this.getTokenColor(token.type))
                      .fontFamily('monospace')
                  }, (token: Token, tokenIndex: number) => `t_${lineIndex}_${tokenIndex}`)
                }
                .fontSize(this.state.fontSize)
                .fontFamily('monospace')
                .lineHeight(this.state.lineHeight)
                .textOverflow({ overflow: TextOverflow.Clip })
                .maxLines(1)
              }
              .width('100%')
              .height(this.state.lineHeight)
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
      .scrollBarColor(this.state.currentTheme.colors.textSecondary)
      .backgroundColor(this.state.currentTheme.editor.background)
    } else {
      // 编辑模式
      CodeEditorView({
        content: this.state.content,
        language: this.state.language,
        fontSize: this.state.fontSize,
        textColor: this.state.currentTheme.editor.text,
        bgColor: this.state.currentTheme.editor.background,
        lineNumberColor: this.state.currentTheme.editor.lineNumber,
        caretColor: this.state.currentTheme.colors.primary,
        editorBorderColor: this.state.currentTheme.colors.border,
        keywordColor: this.state.currentTheme.syntax.keyword,
        stringColor: this.state.currentTheme.syntax.string,
        commentColor: this.state.currentTheme.syntax.comment,
        numberColor: this.state.currentTheme.syntax.number,
        functionColor: this.state.currentTheme.syntax.function,
        onChange: (value: string) => {
          this.callbacks.onContentChange(value);
        }
      })
    }
  }

  /**
   * 获取 token 颜色
   */
  private getTokenColor(type: string): string {
    const colorMap: Record<string, string> = {
      'keyword': this.state.currentTheme.syntax.keyword,
      'string': this.state.currentTheme.syntax.string,
      'comment': this.state.currentTheme.syntax.comment,
      'number': this.state.currentTheme.syntax.number,
      'function': this.state.currentTheme.syntax.function,
      'variable': this.state.currentTheme.syntax.variable,
      'operator': this.state.currentTheme.syntax.operator,
      'bracket': this.state.currentTheme.editor.text,
      'type': this.state.currentTheme.syntax.type,
      'text': this.state.currentTheme.editor.text
    };
    return colorMap[type] || this.state.currentTheme.editor.text;
  }

  /**
   * 获取代码行数组
   */
  private getCodeLines(): string[] {
    return this.state.content.split('\n');
  }

  /**
   * 获取显示的行号
   */
  private getDisplayLineNumbers(): number[] {
    const actualLines = this.state.content.split('\n').length;
    const minLines = this.state.isPreviewMode ? actualLines : 100;
    const totalLines = Math.max(actualLines, minLines);
    const lines: number[] = [];
    for (let i = 1; i <= totalLines; i++) {
      lines.push(i);
    }
    return lines;
  }

  /**
   * 获取文件扩展名徽章
   */
  private getFileExtensionBadge(): string {
    const ext = this.state.fileName.substring(this.state.fileName.lastIndexOf('.') + 1).toLowerCase();
    const extUpper = ext.toUpperCase();
    if (!ext || ext === this.state.fileName) {
      return 'FILE';
    }
    return extUpper.substring(0, 4);
  }
}
