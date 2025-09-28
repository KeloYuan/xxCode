import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import { FileItem, EditorTab } from '../models/FileModel';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 定义文件模型接口
interface FileModelInterface {
  getTabs(): EditorTab[];
  getActiveTab(): EditorTab | null;
}

// 文件模型实现类
class FileModelImpl implements FileModelInterface {
  private service: RealFileService;

  constructor(service: RealFileService) {
    this.service = service;
  }

  getTabs(): EditorTab[] {
    return this.service.getTabs();
  }

  getActiveTab(): EditorTab | null {
    return this.service.getActiveTab();
  }
}

export class RealFileService {
  private tabs: EditorTab[] = [];
  private context: common.UIAbilityContext | null = null;

  constructor(context?: common.UIAbilityContext) {
    this.context = context || null;
  }

  // 设置context
  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  // 打开文件选择器
  async openFilePicker(): Promise<string[]> {
    try {
      const documentPicker = new picker.DocumentViewPicker();
      const result = await documentPicker.select({
        maxSelectNumber: 10,
        defaultFilePathUri: '',
        fileSuffixFilters: ['.txt', '.js', '.ts', '.md', '.json', '.xml', '.css', '.html', '.ets']
      });
      return result;
    } catch (error) {
      console.error('文件选择失败:', error);
      return [];
    }
  }

  // 保存文件选择器
  async saveFilePicker(suggestedName?: string): Promise<string> {
    try {
      const documentPicker = new picker.DocumentViewPicker();
      const result = await documentPicker.save({
        newFileNames: [suggestedName || 'untitled.txt']
      });
      return result[0] || '';
    } catch (error) {
      console.error('保存文件选择失败:', error);
      return '';
    }
  }

  // 读取文件内容
  async readFileContent(filePath: string): Promise<string> {
    try {
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(filePath);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      // 将ArrayBuffer转换为字符串
      const uint8Array = new Uint8Array(buffer);
      let result = '';
      for (let i = 0; i < uint8Array.length; i++) {
        result += String.fromCharCode(uint8Array[i]);
      }
      return result;
    } catch (error) {
      console.error('读取文件失败:', error);
      throw new Error(`读取文件失败: ${error}`);
    }
  }

  // 写入文件内容
  async writeFileContent(filePath: string, content: string): Promise<boolean> {
    try {
      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      
      // 将字符串转换为ArrayBuffer
      const uint8Array = new Uint8Array(content.length);
      for (let i = 0; i < content.length; i++) {
        uint8Array[i] = content.charCodeAt(i);
      }
      const buffer = uint8Array.buffer;
      
      fs.writeSync(file.fd, buffer);
      fs.closeSync(file);
      return true;
    } catch (error) {
      console.error('写入文件失败:', error);
      return false;
    }
  }

  // 获取文件信息
  async getFileInfo(filePath: string): Promise<FileItem | null> {
    try {
      const stat = fs.statSync(filePath);
      const fileName = filePath.split('/').pop() || '';
      const extension = fileName.split('.').pop() || '';

      return {
        name: fileName,
        path: filePath,
        type: extension,
        size: stat.size,
        lastModified: stat.mtime,
        isDirectory: stat.isDirectory()
      };
    } catch (error) {
      console.error('获取文件信息失败:', error);
      return null;
    }
  }

  // 获取目录内容
  async listDirectory(dirPath: string): Promise<FileItem[]> {
    try {
      const items: FileItem[] = [];
      const entries = fs.listFileSync(dirPath);

      for (const entry of entries) {
        const fullPath = `${dirPath}/${entry}`;
        const fileInfo = await this.getFileInfo(fullPath);
        if (fileInfo) {
          items.push(fileInfo);
        }
      }

      return items.sort((a, b) => {
        // 目录优先，然后按名称排序
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.localeCompare(b.name);
      });
    } catch (error) {
      console.error('读取目录失败:', error);
      return [];
    }
  }

  // 创建新文件
  async createFile(filePath: string, content: string = ''): Promise<boolean> {
    try {
      return await this.writeFileContent(filePath, content);
    } catch (error) {
      console.error('创建文件失败:', error);
      return false;
    }
  }

  // 删除文件
  async deleteFile(filePath: string): Promise<boolean> {
    try {
      fs.unlinkSync(filePath);
      return true;
    } catch (error) {
      console.error('删除文件失败:', error);
      return false;
    }
  }

  // 重命名文件
  async renameFile(oldPath: string, newPath: string): Promise<boolean> {
    try {
      fs.renameSync(oldPath, newPath);
      return true;
    } catch (error) {
      console.error('重命名文件失败:', error);
      return false;
    }
  }

  // 检查文件是否存在
  async fileExists(filePath: string): Promise<boolean> {
    try {
      fs.accessSync(filePath);
      return true;
    } catch {
      return false;
    }
  }

  // 标签页管理
  openFileInTab(filePath: string): EditorTab {
    // 检查是否已经打开
    const existingTab = this.tabs.find(tab => tab.filePath === filePath);
    if (existingTab) {
      this.setActiveTab(existingTab.id);
      return existingTab;
    }

    // 创建新标签页
    const fileName = filePath.split('/').pop() || '';
    const extension = fileName.split('.').pop() || '';

    const newTab: EditorTab = {
      id: `tab_${Date.now()}`,
      filePath,
      fileName,
      content: '',
      language: this.getLanguageFromExtension(extension),
      isModified: false,
      isActive: true
    };

    // 设置其他标签为非活跃状态
    this.tabs.forEach(tab => tab.isActive = false);
    this.tabs.push(newTab);

    return newTab;
  }

  closeTab(tabId: string): void {
    const index = this.tabs.findIndex(tab => tab.id === tabId);
    if (index !== -1) {
      const wasActive = this.tabs[index].isActive;
      this.tabs.splice(index, 1);

      // 如果关闭的是活跃标签，激活下一个标签
      if (wasActive && this.tabs.length > 0) {
        const nextIndex = Math.min(index, this.tabs.length - 1);
        this.tabs[nextIndex].isActive = true;
      }
    }
  }

  setActiveTab(tabId: string): void {
    this.tabs.forEach(tab => {
      tab.isActive = tab.id === tabId;
    });
  }

  getTabs(): EditorTab[] {
    return [...this.tabs];
  }

  getActiveTab(): EditorTab | null {
    return this.tabs.find(tab => tab.isActive) || null;
  }

  updateTabContent(tabId: string, content: string): void {
    const tab = this.tabs.find(t => t.id === tabId);
    if (tab) {
      tab.content = content;
      tab.isModified = true;
    }
  }

  markTabSaved(tabId: string): void {
    const tab = this.tabs.find(t => t.id === tabId);
    if (tab) {
      tab.isModified = false;
    }
  }

  // 根据文件扩展名获取语言类型
  private getLanguageFromExtension(extension: string): string {
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
      'txt': 'plaintext'
    };
    return languageMap[extension.toLowerCase()] || 'plaintext';
  }

  // 获取应用沙盒路径
  getAppSandboxPath(): string {
    if (this.context) {
      return this.context.filesDir;
    }
    return '';
  }

  // 获取缓存目录
  getCacheDir(): string {
    if (this.context) {
      return this.context.cacheDir;
    }
    return '';
  }

  // 创建一个简单的文件模型对象来兼容原有接口
  getFileModel(): FileModelInterface {
    return new FileModelImpl(this);
  }
}