/**
 * 文件树项组件
 * 用于显示文件和文件夹的树形结构
 */
import { FileItem } from '../models/FileModel';
import { ThemeService, Theme } from '../services/ThemeService';

@Component
export struct FileTreeItem {
  @Prop fileItem: FileItem = {
    name: '',
    path: '',
    type: '',
    size: 0,
    lastModified: 0,
    isDirectory: false
  };
  @Prop level: number = 0;
  @Prop isExpanded: boolean = false;
  @Prop isSelected: boolean = false;
  
  @State private currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  
  onFileClick: (file: FileItem) => void = () => {};
  onFolderToggle: (folder: FileItem) => void = () => {};
  
  private themeService: ThemeService = ThemeService.getInstance();

  aboutToAppear() {
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  build() {
    Column() {
      // 当前项
      Row() {
        // 缩进
        Blank()
          .width(this.level * 16)

        // 展开/折叠图标（仅文件夹）
        if (this.fileItem.isDirectory) {
          Text('▶')
            .fontSize(10)
            .fontColor(this.currentTheme.colors.textSecondary)
            .width(16)
            .textAlign(TextAlign.Center)
            .margin({ right: 6 })
            .rotate({ angle: this.isExpanded ? 90 : 0 })
            .animation({
              duration: 200,
              curve: Curve.EaseInOut
            })
        } else {
          Blank().width(22)
        }

        // 文件/文件夹图标
        Text(this.getFileIcon())
          .fontSize(16)
          .margin({ right: 8 })

        // 文件名
        Text(this.fileItem.name)
          .fontSize(14)
          .fontColor(this.isSelected ? this.currentTheme.colors.primary : this.currentTheme.colors.text)
          .fontWeight(this.isSelected ? FontWeight.Medium : FontWeight.Normal)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 文件大小（仅文件）
        if (!this.fileItem.isDirectory && this.fileItem.size > 0) {
          Text(this.formatFileSize(this.fileItem.size))
            .fontSize(11)
            .fontColor(this.currentTheme.colors.textSecondary)
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .height(36)
      .padding({ left: 8, right: 12 })
      .backgroundColor(this.isSelected ? this.currentTheme.colors.surface : Color.Transparent)
      .borderRadius(6)
      .onClick(() => {
        if (this.fileItem.isDirectory) {
          this.onFolderToggle(this.fileItem);
        } else {
          this.onFileClick(this.fileItem);
        }
      })
      .stateStyles({
        normal: {
          .opacity(1)
        },
        pressed: {
          .opacity(0.7)
        }
      })

      // 子项（仅当是文件夹且展开时）
      if (this.fileItem.isDirectory && this.isExpanded && this.fileItem.children && this.fileItem.children.length > 0) {
        Column() {
          ForEach(this.fileItem.children, (child: FileItem) => {
            FileTreeItem({
              fileItem: child,
              level: this.level + 1,
              isExpanded: false,
              isSelected: false,
              onFileClick: this.onFileClick,
              onFolderToggle: this.onFolderToggle
            })
          }, (child: FileItem) => child.path)
        }
        .width('100%')
        .transition({
          type: TransitionType.Insert,
          opacity: 0,
          translate: { x: -10, y: -10 },
          scale: { x: 0.95, y: 0.95 }
        })
        .transition({
          type: TransitionType.Delete,
          opacity: 0,
          translate: { x: -10, y: 0 }
        })
      }
    }
    .width('100%')
  }

  /**
   * 获取文件图标
   */
  private getFileIcon(): string {
    if (this.fileItem.isDirectory) {
      return this.isExpanded ? '📂' : '📁';
    }

    const ext = this.fileItem.type.toLowerCase();
    const iconMap: Record<string, string> = {
      'js': '📜',
      'ts': '📘',
      'ets': '📘',
      'json': '📋',
      'md': '📝',
      'html': '🌐',
      'css': '🎨',
      'py': '🐍',
      'java': '☕',
      'cpp': '⚙️',
      'c': '⚙️',
      'txt': '📄',
      'xml': '📰',
      'yaml': '⚙️',
      'yml': '⚙️'
    };

    return iconMap[ext] || '📄';
  }

  /**
   * 格式化文件大小
   */
  private formatFileSize(bytes: number): string {
    if (bytes < 1024) {
      return `${bytes} B`;
    } else if (bytes < 1024 * 1024) {
      return `${(bytes / 1024).toFixed(1)} KB`;
    } else {
      return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
    }
  }
}

