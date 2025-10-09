import fs from '@ohos.file.fs';
import picker from '@ohos.file.picker';
import util from '@ohos.util';
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
    console.log('[RealFileService] === 开始文件选择流程 ===');
    try {
      console.log('[RealFileService] 1. 创建 DocumentViewPicker');
      const documentPicker = new picker.DocumentViewPicker();
      
      console.log('[RealFileService] 2. 创建 DocumentSelectOptions');
      const documentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 10;
      
      console.log('[RealFileService] 3. 调用 select() 方法...');
      const result = await documentPicker.select(documentSelectOptions);
      
      console.log('[RealFileService] 4. 收到结果');
      console.log('[RealFileService] 结果类型:', typeof result);
      console.log('[RealFileService] 结果内容:', JSON.stringify(result));
      console.log('[RealFileService] 是否为数组:', Array.isArray(result));
      
      // 检查返回格式
      if (Array.isArray(result)) {
        console.log('[RealFileService] ✓ 返回格式正确（数组）');
        console.log('[RealFileService] 文件数量:', result.length);
        if (result.length > 0) {
          console.log('[RealFileService] 第一个文件:', result[0]);
        }
        return result;
      } else if (result && typeof result === 'object') {
        console.log('[RealFileService] ⚠️ 返回对象，尝试提取属性');
        console.log('[RealFileService] 对象键:', Object.keys(result));
        
        // 类型转换为 Record
        const resultObj = result as Record<string, string[] | string>;
        
        // 可能的属性名
        if (resultObj.uris && Array.isArray(resultObj.uris)) {
          console.log('[RealFileService] 找到 uris 属性');
          return resultObj.uris as string[];
        }
        if (resultObj.uri && typeof resultObj.uri === 'string') {
          console.log('[RealFileService] 找到 uri 属性');
          return [resultObj.uri];
        }
        return [];
      } else {
        console.log('[RealFileService] ⚠️ 未知返回格式');
        return [];
      }
    } catch (error) {
      console.error('[RealFileService] ❌ 文件选择失败');
      console.error('[RealFileService] 错误类型:', error?.constructor?.name);
      console.error('[RealFileService] 错误消息:', (error as Error)?.message);
      console.error('[RealFileService] 完整错误:', JSON.stringify(error));
      return [];
    } finally {
      console.log('[RealFileService] === 文件选择流程结束 ===');
    }
  }

  // 打开文件夹选择器
  async openFolderPicker(): Promise<string> {
    try {
      // 注意：HarmonyOS 的 picker 暂时不支持直接选择文件夹
      // 我们需要使用其他方式，比如让用户选择一个文件，然后获取其父目录
      // 或者使用应用沙盒目录作为起点
      
      // 暂时返回应用沙盒目录
      if (this.context) {
        return this.context.filesDir;
      }
      return '';
    } catch (error) {
      console.error('文件夹选择失败:', error);
      return '';
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
      console.log('[RealFileService] 开始读取文件:', filePath);
      
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(filePath);
      console.log('[RealFileService] 文件大小:', stat.size);
      
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      // 将ArrayBuffer转换为字符串 - 使用 TextDecoder 处理 UTF-8
      const uint8Array = new Uint8Array(buffer);
      const decoder = new util.TextDecoder('utf-8');
      const result = decoder.decode(uint8Array, { stream: false });
      
      console.log('[RealFileService] 文件读取成功，内容长度:', result.length);
      return result;
    } catch (error) {
      console.error('[RealFileService] 读取文件失败:', error);
      console.error('[RealFileService] 文件路径:', filePath);
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

  // 递归读取文件树（带过滤）
  async readDirectoryTree(dirPath: string, maxDepth: number = 5, currentDepth: number = 0): Promise<FileItem[]> {
    try {
      if (currentDepth >= maxDepth) {
        return [];
      }

      const items: FileItem[] = [];
      const entries = fs.listFileSync(dirPath);

      // 忽略的目录和文件
      const ignoredDirs = ['node_modules', '.git', 'dist', 'build', 'out', '.idea', '.vscode', '__pycache__'];
      const ignoredFiles = ['.DS_Store', 'Thumbs.db'];

      for (const entry of entries) {
        // 跳过隐藏文件和忽略的目录
        if (entry.startsWith('.') && entry !== '.') continue;
        if (ignoredDirs.includes(entry)) continue;
        if (ignoredFiles.includes(entry)) continue;

        const fullPath = `${dirPath}/${entry}`;
        const fileInfo = await this.getFileInfo(fullPath);
        
        if (fileInfo) {
          // 如果是目录，递归读取子目录
          if (fileInfo.isDirectory) {
            const children = await this.readDirectoryTree(fullPath, maxDepth, currentDepth + 1);
            fileInfo.children = children;
          }
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
      console.error('读取文件树失败:', error);
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