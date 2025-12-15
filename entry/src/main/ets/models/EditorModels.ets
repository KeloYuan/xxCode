/**
 * 文件节点模型
 * 用于表示文件树中的文件和文件夹
 */
export interface FileNode {
  id: string                    // 唯一标识
  name: string                  // 文件名
  path: string                  // 完整路径
  type: 'file' | 'folder'       // 类型
  extension?: string            // 文件扩展名
  children?: FileNode[]         // 子节点（仅文件夹）
  size?: number                 // 文件大小（字节）
  modifiedTime?: number         // 修改时间戳
}

/**
 * 编辑器标签模型
 */
export interface EditorTab {
  id: string                    // 唯一标识
  fileId: string                // 关联的文件ID
  fileName: string              // 文件名
  filePath: string              // 文件路径
  content: string               // 文件内容
  language: string              // 编程语言
  isDirty: boolean              // 是否有未保存的修改
  cursorLine: number            // 光标行
  cursorColumn: number          // 光标列
  scrollPosition: number        // 滚动位置
}

/**
 * 语法Token类型
 */
export type TokenType =
  | 'keyword' | 'string' | 'number' | 'comment'
  | 'function' | 'class' | 'variable' | 'property'
  | 'operator' | 'decorator' | 'type' | 'punctuation'
  | 'plain'

/**
 * 语法高亮Token
 */
export interface SyntaxToken {
  type: TokenType
  value: string
  start: number
  end: number
}

/**
 * 主题颜色配置
 */
export interface ThemeColors {
  // 主色调
  primary: string
  primaryLight: string

  // 背景色
  background: string
  surface: string
  surfaceVariant: string
  sidebarBg: string

  // 文字颜色
  textPrimary: string
  textSecondary: string
  textDisabled: string

  // 边框和分割线
  border: string
  divider: string

  // 交互状态
  hover: string
  active: string
  pressed: string

  // 编辑器
  editorBg: string
  lineNumberBg: string
  lineNumber: string
  currentLineBg: string
  selection: string

  // 语法高亮
  syntaxKeyword: string
  syntaxString: string
  syntaxNumber: string
  syntaxComment: string
  syntaxFunction: string
  syntaxClass: string
  syntaxVariable: string
  syntaxOperator: string
  syntaxDecorator: string
  syntaxPunctuation: string
}

/**
 * 主题配置
 */
export interface Theme {
  name: string
  isDark: boolean
  colors: ThemeColors
}

/**
 * 创建示例文件树
 */
export function createSampleFileTree(): FileNode {
  return {
    id: 'root',
    name: 'my-project',
    path: '/my-project',
    type: 'folder',
    children: [
      {
        id: 'src',
        name: 'src',
        path: '/my-project/src',
        type: 'folder',
        children: [
          {
            id: 'pages',
            name: 'pages',
            path: '/my-project/src/pages',
            type: 'folder',
            children: [
              { id: 'index', name: 'Index.ets', path: '/my-project/src/pages/Index.ets', type: 'file', extension: 'ets', size: 2048 },
              { id: 'home', name: 'HomePage.ets', path: '/my-project/src/pages/HomePage.ets', type: 'file', extension: 'ets', size: 3512 },
              { id: 'settings', name: 'Settings.ets', path: '/my-project/src/pages/Settings.ets', type: 'file', extension: 'ets', size: 1824 }
            ]
          },
          {
            id: 'components',
            name: 'components',
            path: '/my-project/src/components',
            type: 'folder',
            children: [
              { id: 'button', name: 'Button.ets', path: '/my-project/src/components/Button.ets', type: 'file', extension: 'ets', size: 1256 },
              { id: 'card', name: 'Card.ets', path: '/my-project/src/components/Card.ets', type: 'file', extension: 'ets', size: 892 }
            ]
          },
          {
            id: 'services',
            name: 'services',
            path: '/my-project/src/services',
            type: 'folder',
            children: [
              { id: 'api', name: 'ApiService.ts', path: '/my-project/src/services/ApiService.ts', type: 'file', extension: 'ts', size: 4096 },
              { id: 'storage', name: 'StorageService.ts', path: '/my-project/src/services/StorageService.ts', type: 'file', extension: 'ts', size: 2048 }
            ]
          },
          { id: 'main', name: 'main.ets', path: '/my-project/src/main.ets', type: 'file', extension: 'ets', size: 512 }
        ]
      },
      {
        id: 'resources',
        name: 'resources',
        path: '/my-project/resources',
        type: 'folder',
        children: [
          { id: 'config', name: 'config.json', path: '/my-project/resources/config.json', type: 'file', extension: 'json', size: 256 }
        ]
      },
      { id: 'readme', name: 'README.md', path: '/my-project/README.md', type: 'file', extension: 'md', size: 1024 },
      { id: 'package', name: 'package.json', path: '/my-project/package.json', type: 'file', extension: 'json', size: 512 }
    ]
  }
}

/**
 * 示例代码内容
 */
export const SampleCodeContents: Record<string, string> = {
  'Index.ets': `import { router } from '@kit.ArkUI'
import { HomePage } from './HomePage'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World'
  @State count: number = 0

  build() {
    Column() {
      Text(this.message)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 20 })

      Button('点击计数: ' + this.count)
        .fontSize(18)
        .width(200)
        .height(50)
        .backgroundColor('#0A59F7')
        .borderRadius(25)
        .onClick(() => {
          this.count++
        })

      Button('跳转首页')
        .fontSize(16)
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/HomePage' })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}`,

  'HomePage.ets': `@Component
export struct HomePage {
  @State title: string = '首页'
  @State items: string[] = ['项目1', '项目2', '项目3']

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(this.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 列表内容
      List() {
        ForEach(this.items, (item: string, index: number) => {
          ListItem() {
            Text(item)
              .fontSize(16)
              .padding(16)
          }
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}`,

  'README.md': `# My HarmonyOS Project

## 简介

这是一个使用 ArkTS 开发的鸿蒙应用项目。

## 功能特性

- 🚀 高性能渲染
- 🎨 精美UI设计
- 📱 多设备适配

## 开始使用

\`\`\`bash
# 安装依赖
npm install

# 运行项目
npm run dev
\`\`\`

## 目录结构

\`\`\`
src/
├── pages/          # 页面组件
├── components/     # 通用组件
├── services/       # 服务层
└── main.ets        # 入口文件
\`\`\`
`
}
