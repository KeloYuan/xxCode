/**
 * 文件右键菜单组件
 * 提供文件和文件夹的上下文操作菜单
 */
import { FileItem } from '../models/FileModel';
import { ThemeService, Theme } from '../services/ThemeService';

export interface MenuAction {
  icon: string;
  text: string;
  action: () => void;
  isDanger?: boolean;
}

@CustomDialog
export struct FileContextMenu {
  @Prop fileItem: FileItem;
  @State private currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  
  controller: CustomDialogController;
  
  onNewFile: () => void = () => {};
  onNewFolder: () => void = () => {};
  onRename: () => void = () => {};
  onDelete: () => void = () => {};
  onCopy: () => void = () => {};
  onCut: () => void = () => {};
  onPaste: () => void = () => {};

  private themeService: ThemeService = ThemeService.getInstance();

  aboutToAppear() {
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  build() {
    Column() {
      // 菜单标题
      Row() {
        Text(this.getFileIcon())
          .fontSize(16)
          .margin({ right: 8 })
        
        Text(this.fileItem.name)
          .fontSize(13)
          .fontColor(this.currentTheme.colors.text)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.currentTheme.colors.surface)

      Divider().color(this.currentTheme.colors.border)

      // 菜单项
      Column() {
        if (this.fileItem.isDirectory) {
          this.buildMenuItem('📄', '新建文件', () => {
            this.onNewFile();
            this.controller.close();
          })
          
          this.buildMenuItem('📁', '新建文件夹', () => {
            this.onNewFolder();
            this.controller.close();
          })
          
          Divider().color(this.currentTheme.colors.border).margin({ left: 16, right: 16 })
        }

        this.buildMenuItem('✏️', '重命名', () => {
          this.onRename();
          this.controller.close();
        })

        this.buildMenuItem('📋', '复制', () => {
          this.onCopy();
          this.controller.close();
        })

        this.buildMenuItem('✂️', '剪切', () => {
          this.onCut();
          this.controller.close();
        })

        if (this.fileItem.isDirectory) {
          this.buildMenuItem('📌', '粘贴', () => {
            this.onPaste();
            this.controller.close();
          })
        }

        Divider().color(this.currentTheme.colors.border).margin({ left: 16, right: 16 })

        this.buildMenuItem('🗑️', '删除', () => {
          this.onDelete();
          this.controller.close();
        }, true)
      }
      .padding({ top: 4, bottom: 4 })
    }
    .width(220)
    .backgroundColor(this.currentTheme.colors.background)
    .borderRadius(12)
    .shadow({
      radius: 20,
      color: '#00000020',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  buildMenuItem(icon: string, text: string, onClick: () => void, isDanger: boolean = false): void {
    Row() {
      Text(icon)
        .fontSize(16)
        .width(24)
        .margin({ right: 12 })

      Text(text)
        .fontSize(13)
        .fontColor(isDanger ? '#FF3B30' : this.currentTheme.colors.text)
        .layoutWeight(1)
    }
    .width('100%')
    .height(40)
    .padding({ left: 16, right: 16 })
    .borderRadius(8)
    .backgroundColor(Color.Transparent)
    .onClick(onClick)
  }

  private getFileIcon(): string {
    if (this.fileItem.isDirectory) {
      return '📁';
    }

    const ext = this.fileItem.type.toLowerCase();
    const iconMap: Record<string, string> = {
      'js': '🟨',
      'ts': '🔷',
      'ets': '🔶',
      'json': '📋',
      'json5': '📋',
      'md': '📝',
      'html': '🌐',
      'css': '🎨',
      'py': '🐍',
      'java': '☕',
      'cpp': '📘',
      'c': '📘',
      'txt': '📄'
    };

    return iconMap[ext] || '📄';
  }
}
