/**
 * 实际文件操作服务实现
 * 负责文件的读写、标签页管理等核心功能
 */
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { FileService } from './FileService';
import { FileItem, EditorTab } from '../models/FileModel';

export class RealFileService implements FileService {
  private context: common.UIAbilityContext | null = null;
  private tabs: EditorTab[] = [];
  private activeTabId: string = '';

  /**
   * 设置上下文
   */
  public setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  /**
   * 打开文件选择器并读取文件
   */
  public async openFile(uri: string = ''): Promise<string> {
    try {
      let fileUri = uri;
      
      // 如果没有提供 URI，打开文件选择器
      if (!fileUri && this.context) {
        const documentPicker = new picker.DocumentViewPicker(this.context);
        const result = await documentPicker.select({
          maxSelectNumber: 1
        });
        
        if (!result || result.length === 0) {
          throw new Error('未选择文件');
        }
        
        fileUri = result[0];
      }

      // 读取文件内容
      const file = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(file.fd);
      const arrayBuffer = new ArrayBuffer(stat.size);
      const readLen = fileIo.readSync(file.fd, arrayBuffer);
      fileIo.closeSync(file);

      // 转换为字符串
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const content = textDecoder.decodeToString(new Uint8Array(arrayBuffer.slice(0, readLen)));

      return content;
    } catch (err) {
      const error = err as Error;
      console.error('打开文件失败:', error.message);
      throw new Error(`打开文件失败: ${error.message}`);
    }
  }

  /**
   * 保存文件
   */
  public async saveFile(uri: string, content: string): Promise<void> {
    try {
      if (!uri) {
        throw new Error('文件路径不能为空');
      }

      // 将字符串转换为 Uint8Array
      const textEncoder = util.TextEncoder.create();
      const buffer = textEncoder.encodeInto(content);

      // 写入文件
      const file = fileIo.openSync(uri, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);
      fileIo.writeSync(file.fd, buffer.buffer);
      fileIo.closeSync(file);

      console.info('文件保存成功:', uri);
    } catch (err) {
      const error = err as Error;
      console.error('保存文件失败:', error.message);
      throw new Error(`保存文件失败: ${error.message}`);
    }
  }

  /**
   * 获取文件树（模拟实现）
   */
  public async getFileTree(folderUri: string): Promise<FileItem[]> {
    // 这里返回模拟数据，实际项目中应该扫描真实目录
    return [];
  }

  /**
   * 添加新标签页
   */
  public addTab(tab: EditorTab): void {
    // 检查是否已存在相同文件的标签
    const existingTab = this.tabs.find(t => t.filePath === tab.filePath);
    if (existingTab) {
      this.setActiveTab(existingTab.id);
      return;
    }

    // 添加新标签
    this.tabs.push(tab);
    this.setActiveTab(tab.id);
  }

  /**
   * 移除标签页
   */
  public removeTab(tabId: string): void {
    const index = this.tabs.findIndex(t => t.id === tabId);
    if (index === -1) {
      return;
    }

    this.tabs.splice(index, 1);

    // 如果删除的是活动标签，激活相邻标签
    if (this.activeTabId === tabId) {
      if (this.tabs.length > 0) {
        const newActiveIndex = Math.min(index, this.tabs.length - 1);
        this.setActiveTab(this.tabs[newActiveIndex].id);
      } else {
        this.activeTabId = '';
      }
    }
  }

  /**
   * 设置活动标签页
   */
  public setActiveTab(tabId: string): void {
    this.activeTabId = tabId;
    this.tabs.forEach(tab => {
      tab.isActive = tab.id === tabId;
    });
  }

  /**
   * 获取活动标签页
   */
  public getActiveTab(): EditorTab | null {
    return this.tabs.find(t => t.id === this.activeTabId) || null;
  }

  /**
   * 获取所有标签页
   */
  public getTabs(): EditorTab[] {
    return this.tabs;
  }

  /**
   * 更新标签页内容
   */
  public updateTabContent(tabId: string, content: string): void {
    const tab = this.tabs.find(t => t.id === tabId);
    if (tab) {
      tab.content = content;
      tab.isModified = true;
    }
  }

  /**
   * 标记标签页为已修改/未修改
   */
  public markTabAsModified(tabId: string, modified: boolean): void {
    const tab = this.tabs.find(t => t.id === tabId);
    if (tab) {
      tab.isModified = modified;
    }
  }

  /**
   * 从文件名获取语言类型
   */
  public getLanguageFromFileName(fileName: string): string {
    const ext = fileName.split('.').pop()?.toLowerCase() || '';
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
      'txt': 'text'
    };
    return languageMap[ext] || 'text';
  }

  /**
   * 创建新标签页
   */
  public createNewTab(fileName: string, filePath: string, content: string = ''): EditorTab {
    const language = this.getLanguageFromFileName(fileName);
    return {
      id: `tab_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      fileName,
      filePath,
      content,
      language,
      isModified: false,
      isActive: false
    };
  }
}

