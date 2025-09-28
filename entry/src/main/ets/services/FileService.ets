import { FileModel, FileItem, EditorTab } from '../models/FileModel';

export class FileService {
  private fileModel: FileModel;
  private fileOperationCallbacks: Map<string, Function[]> = new Map();

  constructor() {
    this.fileModel = new FileModel();
  }

  // 文件树操作
  async loadFileTree(): Promise<FileItem[]> {
    try {
      // 这里模拟异步加载文件树
      await new Promise<void>(resolve => setTimeout(resolve, 100));
      return this.fileModel.getFiles();
    } catch (error) {
      console.error('加载文件树失败:', error);
      const emptyArray: FileItem[] = [];
    return emptyArray;
    }
  }

  async createFile(name: string, parentPath: string = '/'): Promise<boolean> {
    try {
      const extension = name.split('.').pop() || '';
      const newFile: FileItem = {
        name,
        path: `${parentPath}/${name}`,
        type: extension,
        size: 0,
        lastModified: Date.now(),
        isDirectory: false
      };

      this.fileModel.addFile(newFile);

      // 触发文件变化回调
      this.notifyFileChange('create', newFile);
      return true;
    } catch (error) {
      console.error('创建文件失败:', error);
      return false;
    }
  }

  async deleteFile(path: string): Promise<boolean> {
    try {
      const file = this.findFileByPath(path);
      if (!file) {
        return false;
      }

      this.fileModel.removeFile(path);

      // 关闭相关的标签页
      const tabs = this.fileModel.getTabs();
      tabs.forEach(tab => {
        if (tab.filePath === path) {
          this.closeTab(tab.id);
        }
      });

      this.notifyFileChange('delete', file);
      return true;
    } catch (error) {
      console.error('删除文件失败:', error);
      return false;
    }
  }

  async renameFile(oldPath: string, newName: string): Promise<boolean> {
    try {
      const file = this.findFileByPath(oldPath);
      if (!file) {
        return false;
      }

      const oldName = file.name;
      file.name = newName;
      file.path = file.path.replace(oldName, newName);
      file.lastModified = Date.now();

      // 更新相关的标签页
      const tabs = this.fileModel.getTabs();
      tabs.forEach(tab => {
        if (tab.filePath === oldPath) {
          tab.fileName = newName;
          tab.filePath = file.path;
        }
      });

      this.notifyFileChange('rename', file);
      return true;
    } catch (error) {
      console.error('重命名文件失败:', error);
      return false;
    }
  }

  // 标签页操作
  openFile(filePath: string): EditorTab | null {
    const file = this.findFileByPath(filePath);
    if (!file || file.isDirectory) {
      return null;
    }

    // 检查是否已经打开
    const existingTab = this.fileModel.getTabs().find(tab => tab.filePath === filePath);
    if (existingTab) {
      this.setActiveTab(existingTab.id);
      return existingTab;
    }

    // 创建新的标签页
    const extension = file.name.split('.').pop() || '';
    const language = this.fileModel.getLanguageFromExtension(extension);

    const newTab: EditorTab = {
      id: `tab_${Date.now()}`,
      filePath,
      fileName: file.name,
      content: '', // 这里应该从文件系统读取
      language,
      isModified: false,
      isActive: true
    };

    this.fileModel.addTab(newTab);
    this.setActiveTab(newTab.id);

    return newTab;
  }

  closeTab(tabId: string): boolean {
    const tabs = this.fileModel.getTabs();
    const tabIndex = tabs.findIndex(tab => tab.id === tabId);

    if (tabIndex === -1) {
      return false;
    }

    // 如果是当前活动标签页，切换到其他标签页
    const tab = tabs[tabIndex];
    if (tab.isActive && tabs.length > 1) {
      const nextTab = tabs[tabIndex + 1] || tabs[tabIndex - 1];
      if (nextTab) {
        this.setActiveTab(nextTab.id);
      }
    }

    this.fileModel.removeTab(tabId);
    return true;
  }

  setActiveTab(tabId: string): void {
    const tabs = this.fileModel.getTabs();
    tabs.forEach(tab => {
      tab.isActive = tab.id === tabId;
    });
  }

  // 内容操作
  async readFileContent(filePath: string): Promise<string> {
    try {
      // 模拟从文件系统读取内容
      await new Promise<void>(resolve => setTimeout(resolve, 50));

      // 这里应该实现实际的文件读取逻辑
      const defaultContent: Record<string, string> = {
        'js': `// ${filePath.split('/').pop()}\n\nfunction main() {\n  console.log('Hello, World!');\n}\n\nmain();`,
        'css': `/* ${filePath.split('/').pop()} */\n\nbody {\n  margin: 0;\n  padding: 0;\n  font-family: Arial, sans-serif;\n}`,
        'md': `# ${filePath.split('/').pop()}\n\n这是文件内容。\n\n## 功能特性\n\n- 代码高亮\n- 多标签页\n- 文件管理\n\n## 使用方法\n\n1. 打开文件\n2. 开始编辑\n3. 保存更改`,
        'default': `// 文件内容\n\n在这里编写你的代码...`
      };

      const file = this.findFileByPath(filePath);
      const extension = file?.name.split('.').pop() || 'default';
      const defaultContentMap: Record<string, string> = defaultContent;
      const content = defaultContentMap[extension] || defaultContentMap['default'];
      return content;
    } catch (error) {
      console.error('读取文件内容失败:', error);
      return '';
    }
  }

  async saveFileContent(filePath: string, content: string): Promise<boolean> {
    try {
      const file = this.findFileByPath(filePath);
      if (!file) {
        return false;
      }

      file.lastModified = Date.now();
      file.size = content.length;

      // 更新标签页内容
      const tabs = this.fileModel.getTabs();
      const tab = tabs.find(t => t.filePath === filePath);
      if (tab) {
        tab.content = content;
        tab.isModified = false;
      }

      // 这里应该实现实际的文件保存逻辑
      console.log('保存文件:', filePath, '内容长度:', content.length);

      return true;
    } catch (error) {
      console.error('保存文件失败:', error);
      return false;
    }
  }

  // 工具方法
  private findFileByPath(path: string): FileItem | null {
    const files = this.fileModel.getFiles();

    const findFile = (items: FileItem[]): FileItem | null => {
      for (const item of items) {
        if (item.path === path) {
          return item;
        }
        if (item.children) {
          const found = findFile(item.children);
          if (found) return found;
        }
      }
      return null;
    };

    return findFile(files);
  }

  // 事件回调系统
  onFileChange(event: string, callback: Function): void {
    if (!this.fileOperationCallbacks.has(event)) {
      this.fileOperationCallbacks.set(event, []);
    }
    this.fileOperationCallbacks.get(event)!.push(callback);
  }

  private notifyFileChange(event: string, file: FileItem): void {
    const callbacks = this.fileOperationCallbacks.get(event);
    if (callbacks) {
      callbacks.forEach((callback: Function): void => {
        callback(file);
      });
    }
  }

  // 获取器方法
  getFileModel(): FileModel {
    return this.fileModel;
  }
}
