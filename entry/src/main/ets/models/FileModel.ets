export interface FileItem {
  name: string;
  path: string;
  type: string;
  size: number;
  lastModified: number;
  isDirectory: boolean;
  children?: FileItem[];
}

export interface EditorTab {
  id: string;
  filePath: string;
  fileName: string;
  content: string;
  language: string;
  isModified: boolean;
  isActive: boolean;
}

export interface EditorSettings {
  fontSize: number;
  fontFamily: string;
  tabSize: number;
  insertSpaces: boolean;
  wordWrap: boolean;
  theme: 'light' | 'dark';
  showLineNumbers: boolean;
  showMinimap: boolean;
}

export class FileModel {
  private files: FileItem[] = [];
  private tabs: EditorTab[] = [];
  private settings: EditorSettings = {
    fontSize: 14,
    fontFamily: 'monospace',
    tabSize: 2,
    insertSpaces: true,
    wordWrap: true,
    theme: 'light',
    showLineNumbers: true,
    showMinimap: false
  };

  constructor() {
    this.initializeDefaultFiles();
  }

  private initializeDefaultFiles(): void {
    this.files = [
      {
        name: 'src',
        path: '/src',
        type: 'folder',
        size: 0,
        lastModified: Date.now(),
        isDirectory: true,
        children: [
          {
            name: 'components',
            path: '/src/components',
            type: 'folder',
            size: 0,
            lastModified: Date.now(),
            isDirectory: true,
            children: [
              {
                name: 'Header.ets',
                path: '/src/components/Header.ets',
                type: 'ts',
                size: 1536,
                lastModified: Date.now(),
                isDirectory: false
              },
              {
                name: 'Button.ets',
                path: '/src/components/Button.ets',
                type: 'ts',
                size: 2048,
                lastModified: Date.now(),
                isDirectory: false
              }
            ]
          },
          {
            name: 'utils',
            path: '/src/utils',
            type: 'folder',
            size: 0,
            lastModified: Date.now(),
            isDirectory: true,
            children: [
              {
                name: 'helpers.ts',
                path: '/src/utils/helpers.ts',
                type: 'ts',
                size: 1024,
                lastModified: Date.now(),
                isDirectory: false
              }
            ]
          },
          {
            name: 'main.js',
            path: '/src/main.js',
            type: 'js',
            size: 1024,
            lastModified: Date.now(),
            isDirectory: false
          },
          {
            name: 'style.css',
            path: '/src/style.css',
            type: 'css',
            size: 512,
            lastModified: Date.now(),
            isDirectory: false
          }
        ]
      },
      {
        name: 'docs',
        path: '/docs',
        type: 'folder',
        size: 0,
        lastModified: Date.now(),
        isDirectory: true,
        children: [
          {
            name: 'API.md',
            path: '/docs/API.md',
            type: 'md',
            size: 4096,
            lastModified: Date.now(),
            isDirectory: false
          },
          {
            name: 'README.md',
            path: '/docs/README.md',
            type: 'md',
            size: 2048,
            lastModified: Date.now(),
            isDirectory: false
          }
        ]
      },
      {
        name: 'README.md',
        path: '/README.md',
        type: 'md',
        size: 2048,
        lastModified: Date.now(),
        isDirectory: false
      },
      {
        name: 'package.json',
        path: '/package.json',
        type: 'json',
        size: 512,
        lastModified: Date.now(),
        isDirectory: false
      }
    ];
  }

  // 文件操作方法
  getFiles(): FileItem[] {
    return this.files;
  }

  addFile(file: FileItem): void {
    this.files.push(file);
  }

  removeFile(path: string): void {
    const index = this.files.findIndex(file => file.path === path);
    if (index !== -1) {
      this.files.splice(index, 1);
    }
  }

  // 标签页操作方法
  getTabs(): EditorTab[] {
    return this.tabs;
  }

  addTab(tab: EditorTab): void {
    this.tabs.push(tab);
  }

  removeTab(id: string): void {
    const index = this.tabs.findIndex(tab => tab.id === id);
    if (index !== -1) {
      this.tabs.splice(index, 1);
    }
  }

  getActiveTab(): EditorTab | null {
    return this.tabs.find(tab => tab.isActive) || null;
  }

  // 设置相关方法
  getSettings(): EditorSettings {
    const result: EditorSettings = {
      fontSize: this.settings.fontSize,
      fontFamily: this.settings.fontFamily,
      tabSize: this.settings.tabSize,
      insertSpaces: this.settings.insertSpaces,
      wordWrap: this.settings.wordWrap,
      theme: this.settings.theme,
      showLineNumbers: this.settings.showLineNumbers,
      showMinimap: this.settings.showMinimap
    };
    return result;
  }

  updateSettings(newSettings: Partial<EditorSettings>): void {
    this.settings = {
      fontSize: newSettings.fontSize ?? this.settings.fontSize,
      fontFamily: newSettings.fontFamily ?? this.settings.fontFamily,
      tabSize: newSettings.tabSize ?? this.settings.tabSize,
      insertSpaces: newSettings.insertSpaces ?? this.settings.insertSpaces,
      wordWrap: newSettings.wordWrap ?? this.settings.wordWrap,
      theme: newSettings.theme ?? this.settings.theme,
      showLineNumbers: newSettings.showLineNumbers ?? this.settings.showLineNumbers,
      showMinimap: newSettings.showMinimap ?? this.settings.showMinimap
    };
  }

  // 根据文件扩展名获取语言类型
  getLanguageFromExtension(extension: string): string {
    const languageMap: Record<string, string> = {
      'js': 'javascript',
      'ts': 'typescript',
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
      'yml': 'yaml'
    };
    return languageMap[extension.toLowerCase()] || 'plaintext';
  }

  // 获取文件图标
  getFileIcon(type: string): string {
    const iconMap: Record<string, string> = {
      'folder': 'folder',
      'js': 'javascript',
      'ts': 'typescript',
      'py': 'python',
      'java': 'java',
      'cpp': 'cpp',
      'c': 'c',
      'go': 'go',
      'rs': 'rust',
      'md': 'markdown',
      'html': 'html',
      'css': 'css',
      'json': 'json',
      'xml': 'xml',
      'yaml': 'yaml',
      'default': 'file'
    };
    return iconMap[type] || iconMap['default'];
  }
}
