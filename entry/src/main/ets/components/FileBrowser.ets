/**
 * 文件浏览器组件
 * 显示应用内文件列表
 */
import { FileManagerService, FileItem } from '../services/FileManagerService';
import { curves } from '@kit.ArkUI';

@Component
export struct FileBrowser {
  @Prop @Watch('onFilesChange') files: FileItem[] = [];
  @Prop currentFilePath: string = '';
  @Prop workspacePath: string = ''; // 工作区路径显示
  @Prop bgColor: ResourceColor = '#1E1E1E';
  @Prop textColor: ResourceColor = '#FFFFFF';
  @Prop fileBorderColor: ResourceColor = '#333333';
  @Prop activeFileBgColor: ResourceColor = '#3E3E42'; // 当前文件背景色
  onFileClick?: (file: FileItem) => void;
  onNewFile?: () => void;
  onDeleteFile?: (file: FileItem) => void;
  
  @State private expandedDirs: Set<string> = new Set();
  private springCurve: ICurve = curves.springMotion(0.6, 0.8);

  onFilesChange() {
    // 文件列表变化时的处理
  }

  build() {
    Column() {
      // 标题栏
      Column() {
        Row() {
          Text('文件')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textColor)
            .layoutWeight(1)
          
          // 新建文件按钮
          Button({ type: ButtonType.Normal }) {
            Text('+')
              .fontSize(18)
              .fontColor(this.textColor)
          }
          .width(28)
          .height(28)
          .backgroundColor(Color.Transparent)
          .borderRadius(4)
          .stateEffect(true)
          .onClick(() => {
            if (this.onNewFile) {
              this.onNewFile();
            }
          })
        }
        .width('100%')
        .padding({ left: 12, right: 8, top: 8 })
        
        // 工作区路径
        if (this.workspacePath) {
          Text(this.workspacePath)
            .fontSize(11)
            .fontColor(this.textColor)
            .opacity(0.6)
            .width('100%')
            .padding({ left: 12, right: 12, bottom: 8 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width('100%')
      .backgroundColor(this.bgColor)
      .border({ width: { bottom: 1 }, color: this.fileBorderColor })

      // 文件列表
      if (this.files.length === 0) {
        Column() {
          Text('暂无文件')
            .fontSize(12)
            .fontColor(this.textColor)
            .opacity(0.5)
        }
        .width('100%')
        .padding(16)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.files, (file: FileItem) => {
              this.buildFileItem(file)
            }, (file: FileItem) => file.path)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
  }

  @Builder
  buildFileItem(file: FileItem): void {
    Row({ space: 8 }) {
      // 文件图标
      Text(file.isDirectory ? '📁' : this.getFileIcon(file.name))
        .fontSize(16)
      
      // 文件名
      Text(file.name)
        .fontSize(13)
        .fontColor(this.textColor)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(36)
    .padding({ left: 12, right: 12 })
    .backgroundColor(file.path === this.currentFilePath ? 
      this.activeFileBgColor : Color.Transparent)
    .borderRadius(4)
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

  /**
   * 根据文件扩展名获取图标
   */
  private getFileIcon(fileName: string): string {
    const ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    const iconMap: Record<string, string> = {
      'js': '📜',
      'ts': '📘',
      'ets': '📗',
      'py': '🐍',
      'java': '☕',
      'html': '🌐',
      'css': '🎨',
      'json': '📋',
      'md': '📝',
      'txt': '📄'
    };
    return iconMap[ext] || '📄';
  }
}
