/**
 * 文件管理服务
 * 管理应用内的文件，提供导出到用户目录的功能
 */
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';

export interface FileItem {
  name: string;
  path: string;
  isDirectory: boolean;
  size: number;
  modifiedTime: number;
}

export class FileManagerService {
  private static instance: FileManagerService | null = null;
  private workspaceDir: string = '';
  private workspaceLabel: string = 'App Workspace';
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  public static getInstance(): FileManagerService {
    if (!FileManagerService.instance) {
      FileManagerService.instance = new FileManagerService();
    }
    return FileManagerService.instance;
  }

  /**
   * 初始化文件管理器
   * 使用应用内部存储的codes目录作为工作区
   */
  public async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    this.workspaceDir = `${context.filesDir}/codes`;
    this.workspaceLabel = this.workspaceDir;
    
    try {
      // 确保工作区目录存在
      if (!fileIo.accessSync(this.workspaceDir)) {
        fileIo.mkdirSync(this.workspaceDir);
        console.info('✅ 创建工作区目录成功:', this.workspaceDir);
      } else {
        console.info('✅ 工作区目录已存在:', this.workspaceDir);
      }
    } catch (e) {
      console.error('❌ 创建工作区目录失败:', JSON.stringify(e));
    }
  }

  /**
   * 获取代码目录路径（工作区）
   */
  public getCodesDir(): string {
    return this.workspaceDir;
  }

  /**
   * 获取工作区显示路径
   */
  public getWorkspacePath(): string {
    return this.workspaceLabel || 'App Workspace';
  }

  /**
   * 设置工作区目录（来自系统选择的文件夹或文件路径）
   */
  public setWorkspaceDir(dirPath: string): void {
    if (!dirPath) {
      return;
    }
    this.workspaceDir = dirPath;
    this.workspaceLabel = dirPath;
  }

  /**
   * 列出目录下的文件
   */
  public listFiles(dirPath?: string): FileItem[] {
    const targetDir = dirPath || this.getCodesDir();
    const files: FileItem[] = [];

    try {
      const fileNames = fileIo.listFileSync(targetDir);
      
      for (const name of fileNames) {
        const fullPath = `${targetDir}/${name}`;
        try {
          const stat = fileIo.statSync(fullPath);
          files.push({
            name: name,
            path: fullPath,
            isDirectory: stat.isDirectory(),
            size: stat.size,
            modifiedTime: stat.mtime
          });
        } catch (e) {
          console.error('获取文件信息失败:', name, JSON.stringify(e));
        }
      }
    } catch (e) {
      console.error('列出文件失败:', JSON.stringify(e));
    }

    return files.sort((a, b) => {
      // 目录排在前面
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      // 按名称排序
      return a.name.localeCompare(b.name);
    });
  }

  /**
   * 创建新文件
   */
  public createFile(fileName: string, content: string = ''): string {
    const filePath = `${this.getCodesDir()}/${fileName}`;
    try {
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      if (content) {
        fileIo.writeSync(file.fd, content);
      }
      fileIo.closeSync(file);
      return filePath;
    } catch (e) {
      console.error('创建文件失败:', JSON.stringify(e));
      throw new Error('创建文件失败');
    }
  }

  /**
   * 读取文件内容
   */
  public readFile(filePath: string): string {
    try {
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, buffer);
      fileIo.closeSync(file);

      const decoder = new util.TextDecoder('utf-8');
      return decoder.decodeWithStream(new Uint8Array(buffer));
    } catch (e) {
      console.error('读取文件失败:', JSON.stringify(e));
      throw new Error('读取文件失败');
    }
  }

  /**
   * 写入文件内容
   */
  public writeFile(filePath: string, content: string): void {
    try {
      const file = fileIo.openSync(filePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(file.fd, content);
      fileIo.closeSync(file);
    } catch (e) {
      console.error('写入文件失败:', JSON.stringify(e));
      throw new Error('写入文件失败');
    }
  }

  /**
   * 删除文件
   */
  public deleteFile(filePath: string): void {
    try {
      fileIo.unlinkSync(filePath);
    } catch (e) {
      console.error('删除文件失败:', JSON.stringify(e));
      throw new Error('删除文件失败');
    }
  }

  /**
   * 重命名文件
   */
  public renameFile(oldPath: string, newName: string): string {
    try {
      const dir = oldPath.substring(0, oldPath.lastIndexOf('/'));
      const newPath = `${dir}/${newName}`;
      fileIo.renameSync(oldPath, newPath);
      return newPath;
    } catch (e) {
      console.error('重命名文件失败:', JSON.stringify(e));
      throw new Error('重命名文件失败');
    }
  }

  /**
   * 检查文件是否存在
   */
  public fileExists(filePath: string): boolean {
    try {
      return fileIo.accessSync(filePath);
    } catch (e) {
      return false;
    }
  }
}
