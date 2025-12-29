/**
 * 移动端布局组件
 * 专为小屏设备优化的编辑器布局
 *
 * 布局结构:
 * - 顶部工具栏 (56vp): 文件按钮 + 文件名 + 菜单按钮
 * - 编辑器主体: 搜索栏 + 文件信息栏 + 编辑区域
 * - 底部操作栏 (64vp): 6个快捷操作按钮
 * - 左侧抽屉: 文件浏览器
 * - 右侧抽屉: 功能菜单
 * - 底部面板: 标签管理
 * - 控制台面板: 可折叠
 */
import { curves } from '@kit.ArkUI';
import { BreakpointService } from '../../services/BreakpointService';
import { CodeEditorView } from '../CodeEditorView';
import { DrawerPanel } from '../DrawerPanel';
import { BottomSheet } from '../BottomSheet';
import { MobileMenu } from '../MobileMenu';
import { TabManagerPanel } from '../TabManagerPanel';
import { ConsolePanel } from '../ConsolePanel';
import { FileBrowser } from '../FileBrowser';
import { IconButton } from '../IconButton';
import { EditorState, EditorCallbacks } from './ResponsiveLayout';
import { SyntaxHighlightService, Token } from '../../services/SyntaxHighlightService';
import { FileItem } from '../../services/FileManagerService';

@Component
export struct MobileLayout {
  @Prop state: EditorState;
  @Prop callbacks: EditorCallbacks;
  @Prop breakpointService: BreakpointService;

  // 滚动控制器
  private editorScroller: Scroller = new Scroller();
  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance();

  // 动画曲线
  private springCurve: ICurve = curves.springMotion(0.6, 0.8);

  build() {
    Stack() {
      // 主内容区域
      Column() {
        // 状态栏占位
        Row()
          .width('100%')
          .height(this.state.topRectHeight > 0 ? this.state.topRectHeight / 3 : 0)
          .backgroundColor(this.state.currentTheme.colors.surface)

        // 移动端顶部工具栏
        this.buildMobileToolbar()

        // 编辑器主区域
        Column() {
          // 搜索替换栏
          if (this.state.showSearchBar) {
            this.buildSearchBar()
          }

          // 文件信息栏
          this.buildFileInfoBar()

          // 编辑器主体
          this.buildEditor()

          // 移动端底部操作栏
          this.buildMobileActionBar()

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

        // 底部导航栏占位
        Row()
          .width('100%')
          .height(this.state.bottomRectHeight > 0 ? this.state.bottomRectHeight / 3 : 0)
          .backgroundColor(this.state.currentTheme.editor.background)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.state.currentTheme.colors.background)

      // 左侧抽屉（文件浏览器）
      DrawerPanel({
        visible: this.state.showLeftDrawer,
        drawerPosition: 'left',
        drawerWidth: this.breakpointService.getDrawerWidth(),
        bgColor: this.state.currentTheme.colors.surface,
        onClose: () => {
          this.callbacks.onToggleLeftDrawer(false);
        }
      }) {
        Column() {
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
              this.callbacks.onToggleLeftDrawer(false);
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
        }
        .padding({ top: this.state.topRectHeight })
      }

      // 右侧抽屉（功能菜单）
      DrawerPanel({
        visible: this.state.showRightDrawer,
        drawerPosition: 'right',
        drawerWidth: this.breakpointService.getDrawerWidth(),
        bgColor: this.state.currentTheme.colors.surface,
        onClose: () => {
          this.callbacks.onToggleRightDrawer(false);
        }
      }) {
        Column() {
          MobileMenu({
            bgColor: this.state.currentTheme.colors.surface,
            textColor: this.state.currentTheme.colors.text,
            onMenuClick: (action: string) => {
              this.callbacks.onMenuAction(action);
              this.callbacks.onToggleRightDrawer(false);
            }
          })
        }
        .padding({ top: this.state.topRectHeight })
      }

      // 底部面板（标签管理）
      BottomSheet({
        visible: this.state.showTabManager,
        sheetHeight: '60%',
        bgColor: this.state.currentTheme.colors.surface,
        onClose: () => {
          this.callbacks.onToggleTabManager(false);
        }
      }) {
        TabManagerPanel({
          tabs: this.state.tabs,
          currentTabId: this.state.currentTabId,
          bgColor: this.state.currentTheme.colors.surface,
          textColor: this.state.currentTheme.colors.text,
          onTabClick: (tabId: string) => {
            this.callbacks.onTabClick(tabId);
            this.callbacks.onToggleTabManager(false);
          },
          onTabClose: (tabId: string) => {
            this.callbacks.onTabClose(tabId);
          },
          onNewTab: () => {
            this.callbacks.onNewTab();
            this.callbacks.onToggleTabManager(false);
          }
        })
      }

      // 左边缘手势检测
      if (this.state.showLeftDrawer === false && this.state.showTabManager === false) {
        Row()
          .width(28)
          .height('60%')
          .position({ x: 0, y: this.state.showSearchBar ? 160 : 120 })
          .backgroundColor('rgba(0, 0, 0, 0)')
          .gesture(
            PanGesture({ direction: PanDirection.Horizontal })
              .onActionStart((event: GestureEvent) => {
                if (event && event.offsetX > 50) {
                  this.callbacks.onToggleLeftDrawer(true);
                }
              })
          )
      }

      // 右边缘手势检测
      if (this.state.showRightDrawer === false && this.state.showTabManager === false) {
        Row()
          .width(28)
          .height('60%')
          .position({ x: '100%', y: this.state.showSearchBar ? 160 : 120 })
          .markAnchor({ x: 28, y: 0 })
          .backgroundColor('rgba(0, 0, 0, 0)')
          .gesture(
            PanGesture({ direction: PanDirection.Horizontal })
              .onActionStart((event: GestureEvent) => {
                if (event && event.offsetX < -50) {
                  this.callbacks.onToggleRightDrawer(true);
                }
              })
          )
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.state.currentTheme.colors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  /**
   * 移动端顶部工具栏
   * 左侧: 文件按钮 | 中间: 文件名(点击打开标签管理) | 右侧: 菜单按钮
   */
  @Builder
  buildMobileToolbar(): void {
    Row({ space: 8 }) {
      // 左侧: 文件按钮
      Button($r('app.string.btn_files'))
        .height(44)
        .padding({ left: 12, right: 12 })
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.state.currentTheme.colors.text)
        .backgroundColor(this.state.currentTheme.editor.background)
        .borderRadius(10)
        .border({ width: 1, color: this.state.currentTheme.colors.border })
        .onClick(() => {
          this.callbacks.onToggleLeftDrawer(true);
        })

      // 中间: 文件名 (点击打开标签管理)
      Text(this.state.fileName + (this.state.isModified ? ' •' : ''))
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.state.currentTheme.colors.text)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onClick(() => {
          this.callbacks.onToggleTabManager(true);
        })

      // 预览/编辑切换按钮
      Button(this.state.isPreviewMode ? $r('app.string.btn_edit') : $r('app.string.btn_preview'))
        .height(44)
        .padding({ left: 12, right: 12 })
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.state.currentTheme.colors.text)
        .backgroundColor(this.state.currentTheme.editor.background)
        .borderRadius(10)
        .border({ width: 1, color: this.state.currentTheme.colors.border })
        .stateEffect(true)
        .onClick(() => {
          this.callbacks.onTogglePreviewMode();
        })

      // 右侧: 菜单按钮
      Button('...')
        .height(44)
        .padding({ left: 12, right: 12 })
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.state.currentTheme.colors.text)
        .backgroundColor(this.state.currentTheme.editor.background)
        .borderRadius(10)
        .border({ width: 1, color: this.state.currentTheme.colors.border })
        .onClick(() => {
          this.callbacks.onToggleRightDrawer(true);
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.state.currentTheme.colors.surface)
    .border({ width: { bottom: 0.5 }, color: this.state.currentTheme.colors.border })
  }

  /**
   * 移动端底部操作栏
   * 6个快捷操作按钮: 文件 | 标签 | 搜索 | 预览 | 保存 | 菜单
   */
  @Builder
  buildMobileActionBar(): void {
    Scroll() {
      Row({ space: 8 }) {
        IconButton({
          text: $r('app.string.btn_files'),
          isActive: this.state.showLeftDrawer,
          bgColor: this.state.currentTheme.colors.surface,
          activeColor: this.state.currentTheme.colors.primary,
          textColor: this.state.currentTheme.colors.text,
          btnSize: 48,
          fontSize: 12,
          onButtonClick: () => {
            this.callbacks.onToggleLeftDrawer(true);
          }
        })
        IconButton({
          text: $r('app.string.btn_tabs'),
          isActive: this.state.showTabManager,
          bgColor: this.state.currentTheme.colors.surface,
          activeColor: this.state.currentTheme.colors.primary,
          textColor: this.state.currentTheme.colors.text,
          btnSize: 48,
          fontSize: 12,
          onButtonClick: () => {
            this.callbacks.onToggleTabManager(true);
          }
        })
        IconButton({
          text: $r('app.string.btn_search'),
          isActive: this.state.showSearchBar,
          bgColor: this.state.currentTheme.colors.surface,
          activeColor: this.state.currentTheme.colors.primary,
          textColor: this.state.currentTheme.colors.text,
          btnSize: 48,
          fontSize: 12,
          onButtonClick: () => {
            this.callbacks.onToggleSearchBar();
          }
        })
        IconButton({
          text: this.state.isPreviewMode ? $r('app.string.btn_edit') : $r('app.string.btn_preview'),
          isActive: this.state.isPreviewMode,
          bgColor: this.state.currentTheme.colors.surface,
          activeColor: this.state.currentTheme.colors.primary,
          textColor: this.state.currentTheme.colors.text,
          btnSize: 48,
          fontSize: 12,
          onButtonClick: () => {
            this.callbacks.onTogglePreviewMode();
          }
        })
        IconButton({
          text: $r('app.string.btn_save'),
          isActive: this.state.isModified,
          bgColor: this.state.currentTheme.colors.surface,
          activeColor: this.state.currentTheme.colors.primary,
          textColor: this.state.currentTheme.colors.text,
          btnSize: 48,
          fontSize: 12,
          onButtonClick: () => {
            this.callbacks.onSaveFile();
          }
        })
        IconButton({
          text: $r('app.string.btn_menu'),
          bgColor: this.state.currentTheme.colors.surface,
          textColor: this.state.currentTheme.colors.text,
          btnSize: 48,
          fontSize: 12,
          onButtonClick: () => {
            this.callbacks.onToggleRightDrawer(true);
          }
        })
      }
      .padding({ left: 12, right: 12 })
      .alignItems(VerticalAlign.Center)
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(64)
    .backgroundColor(this.state.currentTheme.colors.surface)
    .border({ width: { top: 0.5 }, color: this.state.currentTheme.colors.border })
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
          .height(44)
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

        Button($r('app.string.btn_search'))
          .height(40)
          .padding({ left: 12, right: 12 })
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.colors.primary)
          .fontColor(Color.White)
          .borderRadius(10)
          .stateEffect(true)
          .onClick(() => {
            this.callbacks.onPerformSearch();
          })

        Button($r('app.string.btn_close'))
          .height(40)
          .padding({ left: 12, right: 12 })
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Transparent)
          .fontColor(this.state.currentTheme.colors.textSecondary)
          .borderRadius(10)
          .stateEffect(true)
          .onClick(() => {
            this.callbacks.onCloseSearchBar();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      Row({ space: 8 }) {
        Button($r('app.string.btn_previous'))
          .height(40)
          .padding({ left: 12, right: 12 })
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .borderRadius(10)
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
          .padding({ left: 12, right: 12 })
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .borderRadius(10)
          .border({
            width: 1,
            color: this.state.currentTheme.colors.border
          })
          .stateEffect(true)
          .enabled(this.state.searchResults.length > 0)
          .onClick(() => {
            this.callbacks.onNextSearch();
          })

        Blank()

        if (this.state.searchResults.length > 0) {
          Text(`${this.state.currentSearchIndex + 1}/${this.state.searchResults.length}`)
            .fontSize(12)
            .fontColor(this.state.currentTheme.colors.textSecondary)
            .fontWeight(FontWeight.Medium)
        } else {
          Text('0/0')
            .fontSize(12)
            .fontColor(this.state.currentTheme.colors.textSecondary)
            .opacity(0.6)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8 })

      // 替换行
      Row({ space: 8 }) {
        TextInput({ placeholder: $r('app.string.placeholder_replace'), text: this.state.replaceText })
          .layoutWeight(1)
          .height(44)
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
          .padding({ left: 12, right: 12 })
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .borderRadius(10)
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
          .padding({ left: 12, right: 12 })
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.state.currentTheme.editor.background)
          .fontColor(this.state.currentTheme.colors.text)
          .borderRadius(10)
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
    .transition(
      TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseInOut })
        .combine(TransitionEffect.translate({ y: -12 }))
    )
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
}
