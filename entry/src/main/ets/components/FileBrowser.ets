/**
 * 文件浏览器组件 - 鸿蒙设计风格
 * 卡片化设计、流畅动效、纯文字标识
 */
import { FileManagerService, FileItem } from '../services/FileManagerService';
import { curves } from '@kit.ArkUI';

@Component
export struct FileBrowser {
  @Prop @Watch('onFilesChange') files: FileItem[] = [];
  @Prop currentFilePath: string = '';
  @Prop workspacePath: ResourceStr = ''; // 工作区路径显示（支持资源引用）
  @Prop bgColor: ResourceColor = '#1E1E1E';
  @Prop textColor: ResourceColor = '#FFFFFF';
  @Prop fileBorderColor: ResourceColor = '#333333';
  @Prop activeFileBgColor: ResourceColor = '#0A59F7'; // 鸿蒙蓝
  @Prop primaryColor: ResourceColor = '#0A59F7'; // 主色
  onFileClick?: (file: FileItem) => void;
  onNewFile?: () => void;
  onDeleteFile?: (file: FileItem) => void;
  onRenameFile?: (file: FileItem) => void;

  @State private expandedDirs: Set<string> = new Set();
  @State private hoveredFile: string = '';
  private springCurve: ICurve = curves.springMotion(0.6, 0.9);

  // 鸿蒙动效时长
  private readonly MICRO_DURATION: number = 150;
  private readonly STANDARD_DURATION: number = 250;

  onFilesChange() {
    // 文件列表变化时的处理
  }

  /**
   * 获取文件扩展名徽章文本
   */
  private getFileExtensionBadge(fileName: string): string {
    const ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    const extUpper = ext.toUpperCase();
    if (!ext || ext === fileName) {
      return 'FILE';
    }
    return extUpper.substring(0, 4);
  }

  /**
   * 根据扩展名获取徽章颜色
   */
  private getBadgeColor(fileName: string): string {
    const ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    const colorMap: Record<string, string> = {
      'js': '#F7DF1E',
      'ts': '#3178C6',
      'ets': '#0A59F7',
      'py': '#3776AB',
      'java': '#007396',
      'html': '#E34F26',
      'css': '#1572B6',
      'json': '#292929',
      'md': '#083FA1',
      'txt': '#6B7280'
    };
    return colorMap[ext] || (this.primaryColor as string);
  }

  build() {
    Column() {
      // 标题栏 - 鸿蒙风格
      Column() {
        Row() {
          // 标题 - 纯文字
          Text($r('app.string.btn_files'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textColor)
            .layoutWeight(1)

          // 新建文件按钮
          Button({ type: ButtonType.Normal }) {
            Text('+ 新建')
              .fontSize(13)
              .fontColor(this.primaryColor)
              .fontWeight(FontWeight.Medium)
          }
          .height(32)
          .padding({ left: 12, right: 12 })
          .backgroundColor(`${this.primaryColor}15`)
          .borderRadius(8)
          .border({ width: 1, color: `${this.primaryColor}30` })
          .stateEffect(true)
          .onClick(() => {
            if (this.onNewFile) {
              this.onNewFile();
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 12, top: 12, bottom: 8 })

        // 路径信息已移除，避免占用空间
      }
      .width('100%')
      .backgroundColor(this.bgColor)
      .border({ width: { bottom: 0.5 }, color: this.fileBorderColor })

      // 文件列表
      if (this.files.length === 0) {
        Column() {
          Text($r('app.string.text_no_files'))
            .fontSize(13)
            .fontColor(this.textColor)
            .opacity(0.5)
        }
        .width('100%')
        .padding(32)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: 4 }) {
            ForEach(this.files, (file: FileItem) => {
              this.buildFileItem(file)
            }, (file: FileItem) => file.path)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 8, bottom: 8, left: 8, right: 8 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.bgColor)
  }

  @Builder
  buildFileItem(file: FileItem): void {
    Row({ space: 10 }) {
      // 文件夹/文件类型标识
      if (file.isDirectory) {
        // 文件夹 - 文字标识
        Text('DIR')
          .fontSize(10)
          .fontColor(this.textColor)
          .fontWeight(FontWeight.Medium)
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .backgroundColor(`${this.primaryColor}15`)
          .borderRadius(4)
          .opacity(0.6)
      } else {
        // 文件 - 扩展名徽章
        Text(`.${this.getFileExtensionBadge(file.name)}`)
          .fontSize(10)
          .fontColor(this.getBadgeColor(file.name))
          .fontWeight(FontWeight.Medium)
          .padding({ left: 5, right: 5, top: 2, bottom: 2 })
          .backgroundColor(`${this.getBadgeColor(file.name)}20`)
          .borderRadius(4)
          .border({
            width: 0.5,
            color: this.getBadgeColor(file.name)
          })
      }

      // 文件名
      Text(file.name)
        .fontSize(14)
        .fontColor(file.path === this.currentFilePath ? Color.White : this.textColor)
        .fontWeight(file.path === this.currentFilePath ? FontWeight.Medium : FontWeight.Regular)
        .opacity(file.path === this.currentFilePath ? 1.0 : 0.85)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 操作按钮（仅文件）
      if (!file.isDirectory) {
        Row({ space: 4 }) {
          // 编辑按钮
          Text('编辑')
            .fontSize(11)
            .fontColor(this.textColor)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            .borderRadius(6)
            .backgroundColor('rgba(255, 255, 255, 0.06)')
            .hitTestBehavior(HitTestMode.Block)
            .onClick(() => {
              if (this.onRenameFile) {
                this.onRenameFile(file);
              }
            })

          // 删除按钮
          Text('删除')
            .fontSize(11)
            .fontColor('#FA2A2D')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            .borderRadius(6)
            .backgroundColor('rgba(250, 42, 45, 0.1)')
            .hitTestBehavior(HitTestMode.Block)
            .onClick(() => {
              if (this.onDeleteFile) {
                this.onDeleteFile(file);
              }
            })
        }
        .opacity(1)
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 10, right: 10 })
    .backgroundColor(file.path === this.currentFilePath ?
      this.activeFileBgColor : (this.hoveredFile === file.path ?
        'rgba(255, 255, 255, 0.05)' : Color.Transparent))
    .borderRadius(10)
    .scale({
      x: this.hoveredFile === file.path ? 1.01 : 1,
      y: this.hoveredFile === file.path ? 1.01 : 1
    })
    .shadow(file.path === this.currentFilePath ? {
      radius: 8,
      color: `${this.primaryColor}40`,
      offsetX: 0,
      offsetY: 2
    } : undefined)
    .animation({
      duration: this.STANDARD_DURATION,
      curve: this.springCurve
    })
    .onHover((isHover: boolean) => {
      animateTo({
        duration: this.STANDARD_DURATION,
        curve: this.springCurve
      }, () => {
        this.hoveredFile = isHover ? file.path : '';
      });
    })
    .onClick(() => {
      if (!file.isDirectory && this.onFileClick) {
        this.onFileClick(file);
      }
    })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          if (this.onDeleteFile) {
            this.onDeleteFile(file);
          }
        })
    )
  }
}
