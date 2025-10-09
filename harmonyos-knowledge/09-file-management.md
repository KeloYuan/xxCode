# 文件管理完整指南

## 文件系统概述

HarmonyOS 采用沙箱文件系统，每个应用都有自己独立的文件目录。

### 应用沙箱目录结构

```
/data/storage/el2/base/
├── haps/                  # HAP 包目录
├── files/                 # 应用文件目录
├── cache/                 # 缓存目录
├── temp/                  # 临时文件目录
└── preferences/           # 首选项目录
```

### 用户目录（PC/平板）

```
用户目录/
├── Documents/            # 文档目录
├── Downloads/            # 下载目录
├── Desktop/              # 桌面目录
├── Pictures/             # 图片目录
├── Videos/               # 视频目录
└── Music/                # 音乐目录
```

## 基础文件操作

### 1. 获取应用目录路径

```typescript
import { Context } from '@ohos.app.ability.common'

@Entry
@Component
struct FilePathExample {
  private context: Context = getContext(this) as Context

  aboutToAppear() {
    // 获取应用文件目录
    const filesDir = this.context.filesDir
    console.info(`文件目录: ${filesDir}`)
    
    // 获取缓存目录
    const cacheDir = this.context.cacheDir
    console.info(`缓存目录: ${cacheDir}`)
    
    // 获取临时目录
    const tempDir = this.context.tempDir
    console.info(`临时目录: ${tempDir}`)
    
    // 获取数据库目录
    const databaseDir = this.context.databaseDir
    console.info(`数据库目录: ${databaseDir}`)
    
    // 获取首选项目录
    const preferencesDir = this.context.preferencesDir
    console.info(`首选项目录: ${preferencesDir}`)
  }

  build() {
    Column() {
      Text('文件路径示例')
    }
  }
}
```

### 2. 文件读写操作

```typescript
import fs from '@ohos.file.fs'

class FileManager {
  // 写入文件
  static async writeFile(filePath: string, content: string): Promise<void> {
    try {
      // 创建或打开文件
      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      
      // 写入内容
      fs.writeSync(file.fd, content)
      
      // 关闭文件
      fs.closeSync(file)
      
      console.info('文件写入成功')
    } catch (error) {
      console.error('文件写入失败:', error)
      throw error
    }
  }

  // 读取文件
  static async readFile(filePath: string): Promise<string> {
    try {
      // 打开文件
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY)
      
      // 获取文件大小
      const stat = fs.statSync(filePath)
      const buffer = new ArrayBuffer(stat.size)
      
      // 读取内容
      fs.readSync(file.fd, buffer)
      
      // 关闭文件
      fs.closeSync(file)
      
      // 转换为字符串
      const content = String.fromCharCode(...new Uint8Array(buffer))
      return content
    } catch (error) {
      console.error('文件读取失败:', error)
      throw error
    }
  }

  // 追加内容到文件
  static async appendFile(filePath: string, content: string): Promise<void> {
    try {
      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.APPEND)
      fs.writeSync(file.fd, content)
      fs.closeSync(file)
      console.info('内容追加成功')
    } catch (error) {
      console.error('追加失败:', error)
      throw error
    }
  }

  // 删除文件
  static async deleteFile(filePath: string): Promise<void> {
    try {
      fs.unlinkSync(filePath)
      console.info('文件删除成功')
    } catch (error) {
      console.error('文件删除失败:', error)
      throw error
    }
  }

  // 复制文件
  static async copyFile(srcPath: string, destPath: string): Promise<void> {
    try {
      fs.copyFileSync(srcPath, destPath)
      console.info('文件复制成功')
    } catch (error) {
      console.error('文件复制失败:', error)
      throw error
    }
  }

  // 移动/重命名文件
  static async moveFile(oldPath: string, newPath: string): Promise<void> {
    try {
      fs.renameSync(oldPath, newPath)
      console.info('文件移动成功')
    } catch (error) {
      console.error('文件移动失败:', error)
      throw error
    }
  }

  // 检查文件是否存在
  static fileExists(filePath: string): boolean {
    try {
      fs.accessSync(filePath)
      return true
    } catch (error) {
      return false
    }
  }

  // 获取文件信息
  static getFileInfo(filePath: string): fs.Stat {
    try {
      return fs.statSync(filePath)
    } catch (error) {
      console.error('获取文件信息失败:', error)
      throw error
    }
  }
}
```

### 3. 目录操作

```typescript
import fs from '@ohos.file.fs'

class DirectoryManager {
  // 创建目录
  static createDirectory(dirPath: string): void {
    try {
      fs.mkdirSync(dirPath)
      console.info('目录创建成功')
    } catch (error) {
      console.error('目录创建失败:', error)
      throw error
    }
  }

  // 递归创建目录
  static createDirectoryRecursive(dirPath: string): void {
    try {
      // 拆分路径
      const parts = dirPath.split('/')
      let currentPath = ''
      
      for (const part of parts) {
        if (!part) continue
        
        currentPath += '/' + part
        
        if (!this.directoryExists(currentPath)) {
          fs.mkdirSync(currentPath)
        }
      }
      
      console.info('目录递归创建成功')
    } catch (error) {
      console.error('目录递归创建失败:', error)
      throw error
    }
  }

  // 删除目录
  static deleteDirectory(dirPath: string): void {
    try {
      fs.rmdirSync(dirPath)
      console.info('目录删除成功')
    } catch (error) {
      console.error('目录删除失败:', error)
      throw error
    }
  }

  // 检查目录是否存在
  static directoryExists(dirPath: string): boolean {
    try {
      const stat = fs.statSync(dirPath)
      return stat.isDirectory()
    } catch (error) {
      return false
    }
  }

  // 列出目录内容
  static listDirectory(dirPath: string): string[] {
    try {
      return fs.listFileSync(dirPath)
    } catch (error) {
      console.error('列出目录失败:', error)
      throw error
    }
  }

  // 递归列出所有文件
  static listFilesRecursive(dirPath: string): string[] {
    const results: string[] = []
    
    try {
      const items = fs.listFileSync(dirPath)
      
      for (const item of items) {
        const fullPath = `${dirPath}/${item}`
        const stat = fs.statSync(fullPath)
        
        if (stat.isDirectory()) {
          results.push(...this.listFilesRecursive(fullPath))
        } else {
          results.push(fullPath)
        }
      }
      
      return results
    } catch (error) {
      console.error('递归列出文件失败:', error)
      return results
    }
  }

  // 计算目录大小
  static getDirectorySize(dirPath: string): number {
    let totalSize = 0
    
    try {
      const items = fs.listFileSync(dirPath)
      
      for (const item of items) {
        const fullPath = `${dirPath}/${item}`
        const stat = fs.statSync(fullPath)
        
        if (stat.isDirectory()) {
          totalSize += this.getDirectorySize(fullPath)
        } else {
          totalSize += stat.size
        }
      }
      
      return totalSize
    } catch (error) {
      console.error('计算目录大小失败:', error)
      return 0
    }
  }
}
```

## 用户目录文件生成（官方示例）

### 示例概述

这是来自 HarmonyOS 官方的示例，展示如何在 PC 或二合一设备上，使用 `fileIo` 和 `Environment` 接口，在**文档**、**下载**和**桌面**目录中生成文件。

来源：https://gitee.com/harmonyos_samples/GeneratingUserDirectoryEnvironmentFile

### 权限配置

在 `module.json5` 中声明所需权限：

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.READ_WRITE_DOCUMENTS_DIRECTORY",
        "reason": "$string:permission_documents_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.READ_WRITE_DOWNLOAD_DIRECTORY",
        "reason": "$string:permission_download_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.READ_WRITE_DESKTOP_DIRECTORY",
        "reason": "$string:permission_desktop_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

### 完整实现代码

```typescript
import fs from '@ohos.file.fs'
import { Environment } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'

class Logger {
  static info(tag: string, message: string) {
    console.info(`[${tag}] ${message}`)
  }

  static error(tag: string, message: string) {
    console.error(`[${tag}] ${message}`)
  }
}

enum DirectoryType {
  DOCUMENTS = 'Documents',
  DOWNLOADS = 'Downloads',
  DESKTOP = 'Desktop'
}

@Entry
@Component
struct GenerateFileInUserDirectory {
  @State fileName: string = 'test.txt'
  @State fileContent: string = 'Hello HarmonyOS!'
  @State selectedDirectory: DirectoryType = DirectoryType.DOCUMENTS
  @State message: string = ''
  private tag: string = 'GenerateFileInUserDirectory'

  build() {
    Column({ space: 20 }) {
      Text('用户目录文件生成')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      // 文件名输入
      Column({ space: 8 }) {
        Text('文件名：')
          .fontSize(16)
          .alignSelf(ItemAlign.Start)
        
        TextInput({ placeholder: '请输入文件名', text: this.fileName })
          .onChange((value: string) => {
            this.fileName = value
          })
      }
      .width('90%')

      // 文件内容输入
      Column({ space: 8 }) {
        Text('文件内容：')
          .fontSize(16)
          .alignSelf(ItemAlign.Start)
        
        TextArea({ placeholder: '请输入文件内容', text: this.fileContent })
          .height(120)
          .onChange((value: string) => {
            this.fileContent = value
          })
      }
      .width('90%')

      // 目录选择
      Column({ space: 8 }) {
        Text('选择目录：')
          .fontSize(16)
          .alignSelf(ItemAlign.Start)
        
        Row({ space: 16 }) {
          this.buildDirectoryButton('文档', DirectoryType.DOCUMENTS)
          this.buildDirectoryButton('下载', DirectoryType.DOWNLOADS)
          this.buildDirectoryButton('桌面', DirectoryType.DESKTOP)
        }
      }
      .width('90%')

      // 生成按钮
      Button('生成文件')
        .width('90%')
        .height(50)
        .fontSize(18)
        .onClick(() => {
          this.generateFile()
        })

      // 提示信息
      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor(this.message.includes('成功') ? Color.Green : Color.Red)
          .margin({ top: 10 })
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }

  @Builder
  buildDirectoryButton(label: string, type: DirectoryType) {
    Button(label)
      .backgroundColor(this.selectedDirectory === type ? '#007DFF' : '#E0E0E0')
      .fontColor(this.selectedDirectory === type ? Color.White : '#333333')
      .onClick(() => {
        this.selectedDirectory = type
      })
  }

  // 生成文件
  async generateFile() {
    try {
      // 验证输入
      if (!this.fileName) {
        this.message = '请输入文件名'
        return
      }

      // 获取用户目录路径
      const userDir = await this.getUserDirectory(this.selectedDirectory)
      Logger.info(this.tag, `用户目录: ${userDir}`)

      // 生成完整文件路径
      const filePath = `${userDir}/${this.fileName}`
      Logger.info(this.tag, `文件路径: ${filePath}`)

      // 创建并写入文件
      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      fs.writeSync(file.fd, this.fileContent)
      fs.closeSync(file)

      this.message = `文件生成成功！\n路径: ${filePath}`
      Logger.info(this.tag, '文件生成成功')
    } catch (error) {
      const err = error as BusinessError
      this.message = `文件生成失败: ${err.message}`
      Logger.error(this.tag, `文件生成失败: ${err.message}`)
    }
  }

  // 获取用户目录路径
  async getUserDirectory(type: DirectoryType): Promise<string> {
    let dirType: string

    switch (type) {
      case DirectoryType.DOCUMENTS:
        dirType = Environment.getUserDownloadDir()
        break
      case DirectoryType.DOWNLOADS:
        dirType = Environment.getUserDownloadDir()
        break
      case DirectoryType.DESKTOP:
        dirType = Environment.getUserDownloadDir()
        break
      default:
        throw new Error('未知的目录类型')
    }

    return dirType
  }
}
```

### 日志工具类

```typescript
// common/Logger.ets
export class Logger {
  private static readonly DOMAIN: number = 0xFF00
  private static readonly PREFIX: string = '[FileManager]'

  static debug(tag: string, message: string): void {
    console.debug(`${this.PREFIX}[${tag}] ${message}`)
  }

  static info(tag: string, message: string): void {
    console.info(`${this.PREFIX}[${tag}] ${message}`)
  }

  static warn(tag: string, message: string): void {
    console.warn(`${this.PREFIX}[${tag}] ${message}`)
  }

  static error(tag: string, message: string): void {
    console.error(`${this.PREFIX}[${tag}] ${message}`)
  }

  static fatal(tag: string, message: string): void {
    console.error(`${this.PREFIX}[FATAL][${tag}] ${message}`)
  }
}
```

## 文件选择器

### 选择图片

```typescript
import picker from '@ohos.file.picker'

@Entry
@Component
struct ImagePickerExample {
  @State selectedImages: string[] = []

  build() {
    Column({ space: 20 }) {
      Button('选择图片')
        .onClick(() => {
          this.selectImages()
        })

      // 显示选中的图片
      List() {
        ForEach(this.selectedImages, (imageUri: string) => {
          ListItem() {
            Image(imageUri)
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
          }
        })
      }
    }
    .width('100%')
    .padding(16)
  }

  async selectImages() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 5

      const photoPicker = new picker.PhotoViewPicker()
      const result = await photoPicker.select(photoSelectOptions)

      this.selectedImages = result.photoUris
      console.info(`选择了 ${result.photoUris.length} 张图片`)
    } catch (error) {
      console.error('选择图片失败:', error)
    }
  }
}
```

### 选择文档

```typescript
import picker from '@ohos.file.picker'

@Entry
@Component
struct DocumentPickerExample {
  @State selectedFiles: string[] = []

  build() {
    Column({ space: 20 }) {
      Button('选择文档')
        .onClick(() => {
          this.selectDocuments()
        })

      // 显示选中的文件
      List() {
        ForEach(this.selectedFiles, (fileUri: string) => {
          ListItem() {
            Text(fileUri)
              .fontSize(14)
          }
        })
      }
    }
    .width('100%')
    .padding(16)
  }

  async selectDocuments() {
    try {
      const documentSelectOptions = new picker.DocumentSelectOptions()
      const documentPicker = new picker.DocumentViewPicker()
      const result = await documentPicker.select(documentSelectOptions)

      this.selectedFiles = result.length > 0 ? [result[0]] : []
      console.info(`选择了文档: ${result}`)
    } catch (error) {
      console.error('选择文档失败:', error)
    }
  }
}
```

## 文件下载保存

```typescript
import fs from '@ohos.file.fs'
import http from '@ohos.net.http'
import { Context } from '@ohos.app.ability.common'

class FileDownloader {
  private context: Context

  constructor(context: Context) {
    this.context = context
  }

  // 下载文件
  async downloadFile(url: string, fileName: string): Promise<string> {
    try {
      // 创建 HTTP 请求
      const httpRequest = http.createHttp()

      // 发起请求
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER
      })

      if (response.responseCode === 200) {
        // 保存文件
        const filePath = `${this.context.filesDir}/${fileName}`
        const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        
        fs.writeSync(file.fd, response.result as ArrayBuffer)
        fs.closeSync(file)

        console.info(`文件下载成功: ${filePath}`)
        return filePath
      } else {
        throw new Error(`下载失败，状态码: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('下载文件失败:', error)
      throw error
    }
  }

  // 下载并保存到相册
  async downloadAndSaveToGallery(url: string, fileName: string): Promise<void> {
    try {
      // 先下载到应用目录
      const tempPath = await this.downloadFile(url, fileName)

      // 使用 picker 保存到相册
      const photoSaveOptions = new picker.PhotoSaveOptions()
      photoSaveOptions.newFileNames = [fileName]

      const photoPicker = new picker.PhotoViewPicker()
      await photoPicker.save(photoSaveOptions)

      console.info('图片已保存到相册')
    } catch (error) {
      console.error('保存到相册失败:', error)
      throw error
    }
  }
}
```

## 文件类型判断

```typescript
class FileTypeUtil {
  // 根据扩展名判断文件类型
  static getFileType(fileName: string): string {
    const ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()

    const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
    const videoExts = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv']
    const audioExts = ['mp3', 'wav', 'flac', 'aac', 'm4a']
    const documentExts = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']

    if (imageExts.includes(ext)) return 'image'
    if (videoExts.includes(ext)) return 'video'
    if (audioExts.includes(ext)) return 'audio'
    if (documentExts.includes(ext)) return 'document'

    return 'unknown'
  }

  // 格式化文件大小
  static formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B'

    const units = ['B', 'KB', 'MB', 'GB', 'TB']
    const k = 1024
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return `${(bytes / Math.pow(k, i)).toFixed(2)} ${units[i]}`
  }

  // 获取 MIME 类型
  static getMimeType(fileName: string): string {
    const ext = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()

    const mimeTypes: Record<string, string> = {
      'txt': 'text/plain',
      'html': 'text/html',
      'css': 'text/css',
      'js': 'application/javascript',
      'json': 'application/json',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg'
    }

    return mimeTypes[ext] || 'application/octet-stream'
  }
}
```

## 完整的文件管理器示例

```typescript
@Entry
@Component
struct FileManagerApp {
  @State currentPath: string = ''
  @State files: FileInfo[] = []
  private context: Context = getContext(this) as Context

  aboutToAppear() {
    this.currentPath = this.context.filesDir
    this.loadFiles()
  }

  build() {
    Column() {
      // 顶部路径栏
      Row() {
        Text(this.currentPath)
          .fontSize(14)
          .layoutWeight(1)
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#F5F5F5')

      // 文件列表
      List() {
        ForEach(this.files, (file: FileInfo) => {
          ListItem() {
            Row({ space: 12 }) {
              // 图标
              Image(file.isDirectory ? $r('app.media.ic_folder') : $r('app.media.ic_file'))
                .width(40)
                .height(40)

              // 文件信息
              Column({ space: 4 }) {
                Text(file.name)
                  .fontSize(16)
                
                if (!file.isDirectory) {
                  Text(FileTypeUtil.formatFileSize(file.size))
                    .fontSize(12)
                    .fontColor('#999999')
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
          }
          .onClick(() => {
            if (file.isDirectory) {
              this.currentPath = file.path
              this.loadFiles()
            }
          })
        })
      }
      .layoutWeight(1)
      .width('100%')
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
    }
    .width('100%')
    .height('100%')
  }

  loadFiles() {
    try {
      const fileNames = fs.listFileSync(this.currentPath)
      this.files = []

      for (const name of fileNames) {
        const fullPath = `${this.currentPath}/${name}`
        const stat = fs.statSync(fullPath)

        this.files.push({
          name: name,
          path: fullPath,
          size: stat.size,
          isDirectory: stat.isDirectory(),
          modifiedTime: stat.mtime
        })
      }
    } catch (error) {
      console.error('加载文件列表失败:', error)
    }
  }
}

interface FileInfo {
  name: string
  path: string
  size: number
  isDirectory: boolean
  modifiedTime: number
}
```

## 注意事项

1. **权限管理**：访问用户目录需要申请相应权限
2. **路径安全**：使用沙箱路径，不要直接访问系统路径
3. **异常处理**：文件操作需要处理各种异常情况
4. **资源释放**：及时关闭文件句柄，避免资源泄漏
5. **路径拼接**：使用正确的路径分隔符
6. **性能优化**：大文件操作使用流式读写

## 下一步

继续学习 [网络请求与 HTTP](08-network-http.md)

