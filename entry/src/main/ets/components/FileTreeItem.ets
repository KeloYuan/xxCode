import { FileItem } from '../models/FileModel';

@Component
export struct FileTreeItem {
  @Prop fileItem: FileItem;
  @Prop level: number = 0;
  @Prop isExpanded: boolean = false;
  @Prop isSelected: boolean = false;
  onFileClick?: (file: FileItem) => void;
  onFolderToggle?: (file: FileItem) => void;

  private getFileIcon(): string {
    if (this.fileItem.isDirectory) {
      return this.isExpanded ? '📂' : '📁';
    }

    const ext = this.fileItem.name.split('.').pop()?.toLowerCase() || '';
    const iconMap: Record<string, string> = {
      // 代码文件
      'js': '🟨', 'ts': '🔷', 'ets': '🔷', 'jsx': '⚛️', 'tsx': '⚛️',
      'py': '🐍', 'java': '☕', 'cpp': '⚙️', 'c': '⚙️', 'go': '🐹',
      'rs': '🦀', 'php': '🐘', 'rb': '💎', 'swift': '🦅',
      // Web 文件
      'html': '🌐', 'css': '🎨', 'scss': '🎨', 'vue': '💚',
      // 数据文件
      'json': '📦', 'xml': '📋', 'yaml': '📋', 'yml': '📋',
      // 文档文件
      'md': '📝', 'txt': '📄', 'pdf': '📕',
      // 图片文件
      'png': '🖼️', 'jpg': '🖼️', 'jpeg': '🖼️', 'gif': '🖼️', 'svg': '🎨'
    };
    return iconMap[ext] || '📄';
  }

  private getFileIconColor(): string {
    if (this.fileItem.isDirectory) {
      return this.isExpanded ? '#F59E0B' : '#6B7280';
    }
    
    const ext = this.fileItem.name.split('.').pop()?.toLowerCase() || '';
    const colorMap: Record<string, string> = {
      'js': '#F0DB4F', 'ts': '#3178C6', 'ets': '#3178C6',
      'py': '#3776AB', 'java': '#ED8B00', 'html': '#E34C26',
      'css': '#264DE4', 'json': '#292929', 'md': '#083FA1'
    };
    return colorMap[ext] || '#6B7280';
  }

  build() {
    Column() {
      // 文件/文件夹项
      Row() {
        // 缩进
        if (this.level > 0) {
          Blank().width(this.level * 20)
        }

        // 展开/折叠箭头（仅文件夹）
        if (this.fileItem.isDirectory) {
          Text(this.isExpanded ? '▼' : '▶')
            .fontSize(10)
            .fontColor($r('app.color.text_tertiary'))
            .width(16)
            .textAlign(TextAlign.Center)
            .margin({ right: 6 })
            .onClick(() => {
              if (this.onFolderToggle) {
                this.onFolderToggle(this.fileItem);
              }
            })
        } else {
          Blank().width(22)
        }

        // 文件图标
        Text(this.getFileIcon())
          .fontSize(16)
          .margin({ right: 10 })

        // 文件名
        Text(this.fileItem.name)
          .fontSize(14)
          .fontColor(this.isSelected ? $r('app.color.primary_brand') : $r('app.color.text_primary'))
          .fontWeight(this.isSelected ? FontWeight.Medium : FontWeight.Normal)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        // 文件大小（仅文件）
        if (!this.fileItem.isDirectory && this.fileItem.size) {
          Text(this.formatSize(this.fileItem.size))
            .fontSize(11)
            .fontColor($r('app.color.text_tertiary'))
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .height(36)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.isSelected ? $r('app.color.active_bg') : Color.Transparent)
      .borderRadius(6)
      .onClick(() => {
        if (this.fileItem.isDirectory) {
          if (this.onFolderToggle) {
            this.onFolderToggle(this.fileItem);
          }
        } else {
          if (this.onFileClick) {
            this.onFileClick(this.fileItem);
          }
        }
      })
      .stateStyles({
        normal: {
          .backgroundColor(this.isSelected ? $r('app.color.active_bg') : Color.Transparent)
        },
        pressed: {
          .backgroundColor($r('app.color.hover_bg'))
        }
      })

      // 子项（如果是已展开的文件夹）
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
          }, (item: FileItem) => item.path)
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  private formatSize(bytes: number): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return (bytes / Math.pow(k, i)).toFixed(1) + ' ' + sizes[i];
  }
}