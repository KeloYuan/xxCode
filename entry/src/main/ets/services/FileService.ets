/**
 * 文件服务接口
 */
import { FileItem, EditorTab } from '../models/FileModel';

export interface FileService {
  openFile(uri: string): Promise<string>;
  saveFile(uri: string, content: string): Promise<void>;
  getFileTree(folderUri: string): Promise<FileItem[]>;
  
  // 标签管理
  addTab(tab: EditorTab): void;
  removeTab(tabId: string): void;
  setActiveTab(tabId: string): void;
  getActiveTab(): EditorTab | null;
  getTabs(): EditorTab[];
  updateTabContent(tabId: string, content: string): void;
  markTabAsModified(tabId: string, modified: boolean): void;
}

