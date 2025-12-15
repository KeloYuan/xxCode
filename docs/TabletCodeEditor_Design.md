# 鸿蒙平板端代码编辑器设计方案

## 📋 设计概述

本设计方案遵循 **HarmonyOS Design** 设计规范，针对平板端设备设计一个类似 VS Code 操作体验的代码编辑器，主要功能包括：

- 📁 左侧文件目录树浏览
- ✏️ 右侧代码编辑区
- 🎨 语法高亮显示
- 📑 多标签页管理

---

## 🖼️ 整体布局设计

### 布局结构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           顶部工具栏 (56vp)                               │
│  ┌─────┐  ┌────────────────────┐                    ┌─────────────────┐ │
│  │ ☰   │  │   项目名称          │                    │ 主题 | 保存 | 更多 │ │
│  └─────┘  └────────────────────┘                    └─────────────────┘ │
├──────────────────┬──────────────────────────────────────────────────────┤
│   文件侧边栏      │                 编辑器区域                            │
│   (240-320vp)    │                                                      │
│  ┌──────────────┐│  ┌─────────────────────────────────────────────────┐ │
│  │ 📁 项目名称  ││  │ Tab1.ts  │  Tab2.ts  │  Tab3.ts  │     +        │ │
│  │  ├─📁 src    ││  ├─────────────────────────────────────────────────┤ │
│  │  │  ├─📄 a.ts││  │ 1  │ import { router } from '@kit.ArkUI';      │ │
│  │  │  ├─📄 b.ts││  │ 2  │                                            │ │
│  │  │  └─📄 c.ts││  │ 3  │ @Entry                                     │ │
│  │  ├─📁 test   ││  │ 4  │ @Component                                 │ │
│  │  └─📄 main.ts││  │ 5  │ struct MyPage {                            │ │
│  │              ││  │ 6  │   @State count: number = 0                 │ │
│  │              ││  │ 7  │                                            │ │
│  │              ││  │ 8  │   build() {                                │ │
│  │              ││  │ 9  │     Column() {                             │ │
│  │              ││  │ 10 │       Text('Hello World')                  │ │
│  │              ││  │ 11 │         .fontSize(24)                      │ │
│  └──────────────┘│  │ 12 │     }                                      │ │
│                  │  │ 13 │   }                                        │ │
│                  │  │ 14 │ }                                          │ │
│                  │  └─────────────────────────────────────────────────┘ │
│                  │  ┌─────────────────────────────────────────────────┐ │
│                  │  │ 行 5, 列 12  │  ArkTS  │  UTF-8  │  LF         │ │
│                  │  └─────────────────────────────────────────────────┘ │
└──────────────────┴──────────────────────────────────────────────────────┘
```

### 响应式断点设计

| 断点 | 屏幕宽度 | 布局策略 |
|-----|---------|---------|
| **md** | 600-840vp | 可折叠侧边栏（200vp），编辑器自适应 |
| **lg** | ≥840vp | 固定侧边栏（280vp），编辑器自适应 |
| **xl** | ≥1200vp | 宽侧边栏（320vp），可双编辑器分屏 |

---

## 📐 组件架构设计

### 核心组件结构

```
TabletCodeEditor (主页面)
├── TopToolbar (顶部工具栏)
│   ├── MenuButton (菜单按钮)
│   ├── ProjectTitle (项目名称)
│   └── ActionButtons (操作按钮组)
│
├── MainContent (主内容区 - Row布局)
│   ├── FileSidebar (文件侧边栏)
│   │   ├── SidebarHeader (侧边栏头部)
│   │   ├── FileTree (文件树)
│   │   │   └── FileTreeNode (文件树节点 - 递归)
│   │   └── SidebarFooter (侧边栏底部)
│   │
│   ├── Divider (可拖拽分割线)
│   │
│   └── EditorPanel (编辑器面板)
│       ├── TabBar (标签栏)
│       │   └── EditorTab (编辑器标签)
│       ├── CodeEditor (代码编辑区)
│       │   ├── LineNumbers (行号栏)
│       │   └── CodeContent (代码内容区)
│       │       └── HighlightedLine (高亮行)
│       └── StatusBar (状态栏)
│
└── ContextMenu (右键上下文菜单 - 弹出层)
```

---

## 🎨 视觉规范

### 颜色系统

```typescript
// 浅色主题
const LightTheme = {
  // 主色调
  primary: '#0A59F7',           // 鸿蒙蓝
  primaryLight: '#3D7BFF',
  
  // 背景色
  background: '#F1F3F5',        // 页面背景
  surface: '#FFFFFF',           // 卡片/面板背景
  sidebarBg: '#FAFAFA',         // 侧边栏背景
  
  // 文字颜色
  textPrimary: '#182431',       // 主文字
  textSecondary: '#99A0A8',     // 次要文字
  textDisabled: '#C4C9CF',      // 禁用文字
  
  // 边框和分割线
  border: '#E5E8EB',
  divider: '#F0F0F0',
  
  // 交互状态
  hover: 'rgba(0, 0, 0, 0.04)',
  active: 'rgba(10, 89, 247, 0.1)',
  
  // 编辑器
  editorBg: '#FFFFFF',
  lineNumberBg: '#FAFAFA',
  lineNumber: '#B0B8C1',
  currentLineBg: 'rgba(10, 89, 247, 0.06)',
  selection: 'rgba(10, 89, 247, 0.2)',
}

// 深色主题
const DarkTheme = {
  primary: '#3D7BFF',
  primaryLight: '#5B93FF',
  
  background: '#1A1A1A',
  surface: '#262626',
  sidebarBg: '#1E1E1E',
  
  textPrimary: '#E8E8E8',
  textSecondary: '#8A8A8A',
  textDisabled: '#5A5A5A',
  
  border: '#3D3D3D',
  divider: '#333333',
  
  hover: 'rgba(255, 255, 255, 0.06)',
  active: 'rgba(61, 123, 255, 0.2)',
  
  editorBg: '#1E1E1E',
  lineNumberBg: '#1A1A1A',
  lineNumber: '#6E7681',
  currentLineBg: 'rgba(61, 123, 255, 0.1)',
  selection: 'rgba(61, 123, 255, 0.3)',
}
```

### 语法高亮颜色

```typescript
// 代码高亮配色（基于 VS Code 默认主题）
const SyntaxColors = {
  // 浅色主题
  light: {
    keyword: '#0000FF',       // 关键字：蓝色
    string: '#A31515',        // 字符串：红褐色
    number: '#098658',        // 数字：绿色
    comment: '#008000',       // 注释：绿色
    function: '#795E26',      // 函数名：棕色
    class: '#267F99',         // 类名：青色
    variable: '#001080',      // 变量：深蓝色
    property: '#001080',      // 属性：深蓝色
    operator: '#000000',      // 操作符：黑色
    decorator: '#795E26',     // 装饰器：棕色
    type: '#267F99',          // 类型：青色
    punctuation: '#000000',   // 标点：黑色
  },
  
  // 深色主题
  dark: {
    keyword: '#569CD6',       // 关键字：蓝色
    string: '#CE9178',        // 字符串：橙色
    number: '#B5CEA8',        // 数字：浅绿色
    comment: '#6A9955',       // 注释：绿色
    function: '#DCDCAA',      // 函数名：黄色
    class: '#4EC9B0',         // 类名：青色
    variable: '#9CDCFE',      // 变量：浅蓝色
    property: '#9CDCFE',      // 属性：浅蓝色
    operator: '#D4D4D4',      // 操作符：灰白色
    decorator: '#DCDCAA',     // 装饰器：黄色
    type: '#4EC9B0',          // 类型：青色
    punctuation: '#D4D4D4',   // 标点：灰白色
  }
}
```

### 尺寸规范

```typescript
const Dimensions = {
  // 工具栏
  toolbarHeight: 56,          // vp
  
  // 侧边栏
  sidebarMinWidth: 200,       // vp
  sidebarDefaultWidth: 280,   // vp
  sidebarMaxWidth: 400,       // vp
  
  // 标签栏
  tabBarHeight: 40,           // vp
  tabMinWidth: 80,            // vp
  tabMaxWidth: 200,           // vp
  
  // 编辑器
  lineNumberWidth: 50,        // vp
  editorPaddingH: 16,         // vp
  editorPaddingV: 8,          // vp
  
  // 状态栏
  statusBarHeight: 28,        // vp
  
  // 间距
  spacing: {
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
  },
  
  // 圆角
  radius: {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 16,
  }
}
```

---

## 🧩 核心数据模型

### 文件模型

```typescript
// 文件节点
interface FileNode {
  id: string;                    // 唯一标识
  name: string;                  // 文件名
  path: string;                  // 完整路径
  type: 'file' | 'folder';       // 类型
  extension?: string;            // 文件扩展名
  children?: FileNode[];         // 子节点（仅文件夹）
  size?: number;                 // 文件大小（字节）
  modifiedTime?: number;         // 修改时间戳
  isExpanded?: boolean;          // 是否展开（仅文件夹）
}

// 编辑器标签
interface EditorTab {
  id: string;                    // 唯一标识
  fileId: string;                // 关联的文件ID
  fileName: string;              // 文件名
  filePath: string;              // 文件路径
  content: string;               // 文件内容
  language: string;              // 编程语言
  isDirty: boolean;              // 是否有未保存的修改
  cursorPosition: CursorPosition; // 光标位置
  scrollPosition: number;        // 滚动位置
}

// 光标位置
interface CursorPosition {
  line: number;                  // 行号（从1开始）
  column: number;                // 列号（从1开始）
}

// 语法高亮Token
interface SyntaxToken {
  type: TokenType;               // Token类型
  value: string;                 // 文本值
  start: number;                 // 起始位置
  end: number;                   // 结束位置
  line: number;                  // 所在行
}

type TokenType = 
  | 'keyword' | 'string' | 'number' | 'comment'
  | 'function' | 'class' | 'variable' | 'property'
  | 'operator' | 'decorator' | 'type' | 'punctuation'
  | 'plain';
```

### 编辑器状态

```typescript
// 编辑器全局状态
interface EditorState {
  // 文件系统
  rootFolder: FileNode | null;
  selectedFile: FileNode | null;
  expandedFolders: Set<string>;
  
  // 标签管理
  openTabs: EditorTab[];
  activeTabId: string | null;
  
  // 编辑器设置
  theme: 'light' | 'dark';
  fontSize: number;
  tabSize: number;
  wordWrap: boolean;
  lineNumbers: boolean;
  
  // UI状态
  sidebarVisible: boolean;
  sidebarWidth: number;
}
```

---

## 📦 组件详细设计

### 1. 顶部工具栏 (TopToolbar)

```typescript
@Component
struct TopToolbar {
  @Prop projectName: string = '未命名项目'
  @Prop theme: 'light' | 'dark' = 'light'
  
  // 回调事件
  onMenuClick: () => void = () => {}
  onSaveClick: () => void = () => {}
  onThemeToggle: () => void = () => {}
  onSettingsClick: () => void = () => {}
  
  build() {
    Row() {
      // 左侧：菜单按钮 + 项目名
      Row({ space: 12 }) {
        // 菜单按钮（控制侧边栏显隐）
        Button() {
          Image($r('app.media.ic_menu'))
            .width(24)
            .height(24)
            .fillColor($r('app.color.text_primary'))
        }
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.onMenuClick())
        
        // 项目名称
        Text(this.projectName)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      
      Blank()  // 弹性空间
      
      // 右侧：操作按钮组
      Row({ space: 8 }) {
        // 主题切换
        IconButton({
          icon: this.theme === 'light' ? '🌙' : '☀️',
          onClick: () => this.onThemeToggle()
        })
        
        // 保存按钮
        IconButton({
          icon: $r('app.media.ic_save'),
          onClick: () => this.onSaveClick()
        })
        
        // 更多设置
        IconButton({
          icon: $r('app.media.ic_more'),
          onClick: () => this.onSettingsClick()
        })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.surface'))
    .shadow({
      radius: 2,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetY: 1
    })
  }
}
```

### 2. 文件侧边栏 (FileSidebar)

```typescript
@Component
struct FileSidebar {
  @Link rootFolder: FileNode | null
  @Link expandedFolders: Set<string>
  @Link selectedFile: FileNode | null
  
  onFileSelect: (file: FileNode) => void = () => {}
  onFolderToggle: (folder: FileNode) => void = () => {}
  onRefresh: () => void = () => {}
  onNewFile: () => void = () => {}
  onNewFolder: () => void = () => {}
  
  build() {
    Column() {
      // 侧边栏头部
      Row() {
        Text('资源管理器')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        
        Blank()
        
        Row({ space: 4 }) {
          // 新建文件
          SmallIconButton({ icon: '📄', onClick: () => this.onNewFile() })
          // 新建文件夹  
          SmallIconButton({ icon: '📁', onClick: () => this.onNewFolder() })
          // 刷新
          SmallIconButton({ icon: '🔄', onClick: () => this.onRefresh() })
        }
      }
      .width('100%')
      .height(40)
      .padding({ left: 12, right: 8 })
      .backgroundColor($r('app.color.sidebar_header'))
      
      // 文件树
      if (this.rootFolder) {
        Scroll() {
          Column() {
            this.buildFileTree(this.rootFolder, 0)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      } else {
        // 空状态
        Column() {
          Text('📂')
            .fontSize(48)
            .margin({ bottom: 16 })
          Text('暂无打开的项目')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          Button('打开文件夹')
            .type(ButtonType.Capsule)
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.sidebar_bg'))
  }
  
  @Builder
  buildFileTree(node: FileNode, level: number): void {
    FileTreeNode({
      node: node,
      level: level,
      isExpanded: this.expandedFolders.has(node.id),
      isSelected: this.selectedFile?.id === node.id,
      onSelect: (file) => this.onFileSelect(file),
      onToggle: (folder) => this.onFolderToggle(folder)
    })
    
    // 递归渲染子节点
    if (node.type === 'folder' && node.children && this.expandedFolders.has(node.id)) {
      ForEach(node.children, (child: FileNode) => {
        this.buildFileTree(child, level + 1)
      })
    }
  }
}
```

### 3. 文件树节点 (FileTreeNode)

```typescript
@Component
struct FileTreeNode {
  @Prop node: FileNode
  @Prop level: number = 0
  @Prop isExpanded: boolean = false
  @Prop isSelected: boolean = false
  
  onSelect: (file: FileNode) => void = () => {}
  onToggle: (folder: FileNode) => void = () => {}
  
  build() {
    Row() {
      // 缩进
      Blank().width(this.level * 16 + 8)
      
      // 展开/折叠箭头（仅文件夹）
      if (this.node.type === 'folder') {
        Text('▶')
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
          .width(16)
          .rotate({ angle: this.isExpanded ? 90 : 0 })
          .animation({ duration: 150, curve: Curve.EaseOut })
      } else {
        Blank().width(16)
      }
      
      // 文件/文件夹图标
      Text(this.getFileIcon())
        .fontSize(16)
        .margin({ left: 4, right: 8 })
      
      // 文件名
      Text(this.node.name)
        .fontSize(13)
        .fontColor(this.isSelected 
          ? $r('app.color.primary') 
          : $r('app.color.text_primary'))
        .fontWeight(this.isSelected ? FontWeight.Medium : FontWeight.Normal)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .width('100%')
    .height(32)
    .padding({ right: 8 })
    .backgroundColor(this.isSelected 
      ? $r('app.color.active_bg') 
      : Color.Transparent)
    .borderRadius(4)
    .onClick(() => {
      if (this.node.type === 'folder') {
        this.onToggle(this.node)
      } else {
        this.onSelect(this.node)
      }
    })
    .gesture(
      LongPressGesture()
        .onAction(() => {
          // 显示右键菜单
          this.showContextMenu()
        })
    )
  }
  
  private getFileIcon(): string {
    if (this.node.type === 'folder') {
      return this.isExpanded ? '📂' : '📁'
    }
    // 根据扩展名返回图标
    const ext = this.node.extension?.toLowerCase()
    const iconMap: Record<string, string> = {
      'ts': '🔷',
      'ets': '🔶',
      'js': '🟨',
      'json': '📋',
      'md': '📝',
      'html': '🌐',
      'css': '🎨',
      'py': '🐍',
      'java': '☕',
    }
    return iconMap[ext || ''] || '📄'
  }
  
  private showContextMenu(): void {
    // 实现右键菜单逻辑
  }
}
```

### 4. 标签栏 (TabBar)

```typescript
@Component
struct TabBar {
  @Link tabs: EditorTab[]
  @Link activeTabId: string | null
  
  onTabSelect: (tabId: string) => void = () => {}
  onTabClose: (tabId: string) => void = () => {}
  onNewTab: () => void = () => {}
  
  build() {
    Row() {
      // 可滚动的标签区域
      Scroll() {
        Row({ space: 2 }) {
          ForEach(this.tabs, (tab: EditorTab) => {
            EditorTabItem({
              tab: tab,
              isActive: tab.id === this.activeTabId,
              onSelect: () => this.onTabSelect(tab.id),
              onClose: () => this.onTabClose(tab.id)
            })
          })
        }
        .padding({ left: 8, right: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      
      // 新建标签按钮
      Button() {
        Text('+')
          .fontSize(18)
          .fontColor($r('app.color.text_secondary'))
      }
      .type(ButtonType.Circle)
      .width(28)
      .height(28)
      .backgroundColor(Color.Transparent)
      .margin({ right: 8 })
      .onClick(() => this.onNewTab())
    }
    .width('100%')
    .height(40)
    .backgroundColor($r('app.color.surface'))
    .border({
      width: { bottom: 1 },
      color: $r('app.color.border')
    })
  }
}

@Component
struct EditorTabItem {
  @Prop tab: EditorTab
  @Prop isActive: boolean = false
  
  onSelect: () => void = () => {}
  onClose: () => void = () => {}
  
  build() {
    Row({ space: 8 }) {
      // 文件图标
      Text(this.getLanguageIcon())
        .fontSize(14)
      
      // 文件名
      Text(this.tab.fileName)
        .fontSize(13)
        .fontColor(this.isActive 
          ? $r('app.color.primary') 
          : $r('app.color.text_primary'))
        .maxLines(1)
      
      // 修改指示器或关闭按钮
      if (this.tab.isDirty) {
        Circle()
          .width(8)
          .height(8)
          .fill($r('app.color.primary'))
      } else {
        Text('×')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .onClick((e: ClickEvent) => {
            e.stopPropagation()
            this.onClose()
          })
      }
    }
    .height(32)
    .padding({ left: 12, right: 8 })
    .backgroundColor(this.isActive 
      ? $r('app.color.editor_bg') 
      : Color.Transparent)
    .borderRadius({ topLeft: 6, topRight: 6 })
    .border({
      width: { bottom: this.isActive ? 2 : 0 },
      color: $r('app.color.primary')
    })
    .onClick(() => this.onSelect())
  }
  
  private getLanguageIcon(): string {
    const iconMap: Record<string, string> = {
      'typescript': '🔷',
      'arkts': '🔶',
      'javascript': '🟨',
      'json': '📋',
      'markdown': '📝',
    }
    return iconMap[this.tab.language] || '📄'
  }
}
```

### 5. 代码编辑区 (CodeEditor)

```typescript
@Component
struct CodeEditorView {
  @Link content: string
  @Prop language: string = 'typescript'
  @Prop fontSize: number = 14
  @Prop lineNumbers: boolean = true
  @Prop @Watch('onContentChange') isEditable: boolean = true
  
  @State lines: string[] = []
  @State tokens: SyntaxToken[][] = []  // 每行的token数组
  @State currentLine: number = 1
  @State currentColumn: number = 1
  @State scrollY: number = 0
  
  private syntaxHighlighter: SyntaxHighlighter = new SyntaxHighlighter()
  
  aboutToAppear() {
    this.parseContent()
  }
  
  private parseContent(): void {
    this.lines = this.content.split('\n')
    this.tokens = this.lines.map(line => 
      this.syntaxHighlighter.tokenize(line, this.language)
    )
  }
  
  onContentChange(): void {
    this.parseContent()
  }
  
  build() {
    Column() {
      // 编辑区域
      Scroll() {
        Row() {
          // 行号栏
          if (this.lineNumbers) {
            Column() {
              ForEach(this.lines, (_: string, index: number) => {
                Text(`${index + 1}`)
                  .fontSize(this.fontSize)
                  .fontFamily('monospace')
                  .fontColor($r('app.color.line_number'))
                  .textAlign(TextAlign.End)
                  .width('100%')
                  .height(this.fontSize * 1.6)
                  .backgroundColor(index + 1 === this.currentLine 
                    ? $r('app.color.current_line_bg') 
                    : Color.Transparent)
              })
            }
            .width(50)
            .padding({ right: 12 })
            .backgroundColor($r('app.color.line_number_bg'))
            .alignItems(HorizontalAlign.End)
          }
          
          // 代码内容区
          Column() {
            ForEach(this.lines, (line: string, lineIndex: number) => {
              Row() {
                // 使用 Span 实现语法高亮
                Text() {
                  ForEach(this.tokens[lineIndex] || [], (token: SyntaxToken) => {
                    Span(token.value)
                      .fontColor(this.getTokenColor(token.type))
                  })
                  // 确保空行也有高度
                  if (line.length === 0) {
                    Span(' ')
                  }
                }
                .fontSize(this.fontSize)
                .fontFamily('monospace')
                .width('100%')
              }
              .width('100%')
              .height(this.fontSize * 1.6)
              .backgroundColor(lineIndex + 1 === this.currentLine 
                ? $r('app.color.current_line_bg') 
                : Color.Transparent)
            })
          }
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Top)
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .width('100%')
      .backgroundColor($r('app.color.editor_bg'))
      .onScroll((xOffset: number, yOffset: number) => {
        this.scrollY = yOffset
      })
    }
    .width('100%')
    .height('100%')
  }
  
  private getTokenColor(type: TokenType): ResourceColor {
    const colorMap: Record<TokenType, string> = {
      'keyword': '#569CD6',
      'string': '#CE9178',
      'number': '#B5CEA8',
      'comment': '#6A9955',
      'function': '#DCDCAA',
      'class': '#4EC9B0',
      'variable': '#9CDCFE',
      'property': '#9CDCFE',
      'operator': '#D4D4D4',
      'decorator': '#DCDCAA',
      'type': '#4EC9B0',
      'punctuation': '#D4D4D4',
      'plain': '#D4D4D4',
    }
    return colorMap[type] || '#D4D4D4'
  }
}
```

### 6. 状态栏 (StatusBar)

```typescript
@Component
struct StatusBar {
  @Prop line: number = 1
  @Prop column: number = 1
  @Prop language: string = 'Plain Text'
  @Prop encoding: string = 'UTF-8'
  @Prop lineEnding: string = 'LF'
  @Prop isDirty: boolean = false
  
  build() {
    Row() {
      // 左侧信息
      Row({ space: 16 }) {
        // 光标位置
        Text(`行 ${this.line}, 列 ${this.column}`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        
        // 编程语言
        Text(this.getLanguageLabel())
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .backgroundColor($r('app.color.hover_bg'))
          .borderRadius(4)
      }
      
      Blank()
      
      // 右侧信息
      Row({ space: 16 }) {
        // 编码
        Text(this.encoding)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        
        // 换行符
        Text(this.lineEnding)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
        
        // 保存状态
        if (this.isDirty) {
          Row({ space: 4 }) {
            Circle()
              .width(6)
              .height(6)
              .fill($r('app.color.warning'))
            Text('未保存')
              .fontSize(12)
              .fontColor($r('app.color.warning'))
          }
        }
      }
    }
    .width('100%')
    .height(28)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.surface'))
    .border({
      width: { top: 1 },
      color: $r('app.color.border')
    })
  }
  
  private getLanguageLabel(): string {
    const labelMap: Record<string, string> = {
      'typescript': 'TypeScript',
      'arkts': 'ArkTS',
      'javascript': 'JavaScript',
      'json': 'JSON',
      'markdown': 'Markdown',
      'html': 'HTML',
      'css': 'CSS',
      'python': 'Python',
    }
    return labelMap[this.language.toLowerCase()] || this.language
  }
}
```

---

## 🔧 核心服务设计

### 1. 语法高亮服务

```typescript
// services/SyntaxHighlightService.ts

export interface SyntaxToken {
  type: TokenType
  value: string
  start: number
  end: number
}

export type TokenType = 
  | 'keyword' | 'string' | 'number' | 'comment'
  | 'function' | 'class' | 'variable' | 'property'
  | 'operator' | 'decorator' | 'type' | 'punctuation'
  | 'plain'

export class SyntaxHighlighter {
  // ArkTS/TypeScript 关键字
  private static readonly KEYWORDS = new Set([
    'import', 'export', 'from', 'as', 'default',
    'class', 'interface', 'type', 'enum', 'extends', 'implements',
    'function', 'const', 'let', 'var', 'return', 'yield',
    'if', 'else', 'switch', 'case', 'break', 'continue',
    'for', 'while', 'do', 'in', 'of',
    'try', 'catch', 'finally', 'throw',
    'new', 'this', 'super', 'static', 'public', 'private', 'protected',
    'async', 'await', 'void', 'null', 'undefined', 'true', 'false',
    'struct', 'build', 'State', 'Prop', 'Link', 'Watch',
    'Entry', 'Component', 'Builder', 'Styles'
  ])
  
  /**
   * 将代码行分解为语法token
   */
  tokenize(line: string, language: string): SyntaxToken[] {
    const tokens: SyntaxToken[] = []
    let pos = 0
    
    while (pos < line.length) {
      const remaining = line.slice(pos)
      let matched = false
      
      // 跳过空白
      const wsMatch = remaining.match(/^(\s+)/)
      if (wsMatch) {
        tokens.push({
          type: 'plain',
          value: wsMatch[1],
          start: pos,
          end: pos + wsMatch[1].length
        })
        pos += wsMatch[1].length
        continue
      }
      
      // 单行注释
      if (remaining.startsWith('//')) {
        tokens.push({
          type: 'comment',
          value: remaining,
          start: pos,
          end: line.length
        })
        break
      }
      
      // 字符串（双引号）
      const dqMatch = remaining.match(/^"([^"\\]|\\.)*"/)
      if (dqMatch) {
        tokens.push({
          type: 'string',
          value: dqMatch[0],
          start: pos,
          end: pos + dqMatch[0].length
        })
        pos += dqMatch[0].length
        continue
      }
      
      // 字符串（单引号）
      const sqMatch = remaining.match(/^'([^'\\]|\\.)*'/)
      if (sqMatch) {
        tokens.push({
          type: 'string',
          value: sqMatch[0],
          start: pos,
          end: pos + sqMatch[0].length
        })
        pos += sqMatch[0].length
        continue
      }
      
      // 模板字符串
      const tmplMatch = remaining.match(/^`([^`\\]|\\.)*`/)
      if (tmplMatch) {
        tokens.push({
          type: 'string',
          value: tmplMatch[0],
          start: pos,
          end: pos + tmplMatch[0].length
        })
        pos += tmplMatch[0].length
        continue
      }
      
      // 数字
      const numMatch = remaining.match(/^\d+(\.\d+)?([eE][+-]?\d+)?/)
      if (numMatch) {
        tokens.push({
          type: 'number',
          value: numMatch[0],
          start: pos,
          end: pos + numMatch[0].length
        })
        pos += numMatch[0].length
        continue
      }
      
      // 装饰器
      const decoratorMatch = remaining.match(/^@\w+/)
      if (decoratorMatch) {
        tokens.push({
          type: 'decorator',
          value: decoratorMatch[0],
          start: pos,
          end: pos + decoratorMatch[0].length
        })
        pos += decoratorMatch[0].length
        continue
      }
      
      // 标识符/关键字
      const idMatch = remaining.match(/^[a-zA-Z_$][\w$]*/)
      if (idMatch) {
        const word = idMatch[0]
        let type: TokenType = 'variable'
        
        if (SyntaxHighlighter.KEYWORDS.has(word)) {
          type = 'keyword'
        } else if (word.match(/^[A-Z]/)) {
          // 首字母大写视为类名或类型
          type = 'class'
        }
        
        // 检查是否是函数调用
        const afterId = line.slice(pos + word.length).trimStart()
        if (afterId.startsWith('(') && type === 'variable') {
          type = 'function'
        }
        
        tokens.push({
          type: type,
          value: word,
          start: pos,
          end: pos + word.length
        })
        pos += word.length
        continue
      }
      
      // 操作符和标点
      const opMatch = remaining.match(/^[+\-*/%=<>!&|^~?:;,.(){}[\]]/)
      if (opMatch) {
        tokens.push({
          type: 'punctuation',
          value: opMatch[0],
          start: pos,
          end: pos + opMatch[0].length
        })
        pos += opMatch[0].length
        continue
      }
      
      // 其他字符
      tokens.push({
        type: 'plain',
        value: line[pos],
        start: pos,
        end: pos + 1
      })
      pos++
    }
    
    return tokens
  }
  
  /**
   * 根据文件扩展名获取语言类型
   */
  getLanguageFromExtension(ext: string): string {
    const extMap: Record<string, string> = {
      'ts': 'typescript',
      'ets': 'arkts',
      'js': 'javascript',
      'json': 'json',
      'md': 'markdown',
      'html': 'html',
      'css': 'css',
      'py': 'python',
      'java': 'java',
      'c': 'c',
      'cpp': 'cpp',
      'h': 'c',
    }
    return extMap[ext.toLowerCase()] || 'text'
  }
}
```

### 2. 文件服务

```typescript
// services/FileService.ts

import { fileIo, picker } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'

export class FileService {
  private context: common.UIAbilityContext
  
  constructor(context: common.UIAbilityContext) {
    this.context = context
  }
  
  /**
   * 打开文件选择器
   */
  async openFile(): Promise<{ name: string, path: string, content: string }> {
    const documentPicker = new picker.DocumentViewPicker(this.context)
    
    const result = await documentPicker.select({
      maxSelectNumber: 1,
      fileSuffixFilters: ['.ts', '.ets', '.js', '.json', '.md', '.txt', '.html', '.css']
    })
    
    if (result.length === 0) {
      throw new Error('未选择文件')
    }
    
    const uri = result[0]
    const file = await fileIo.open(uri, fileIo.OpenMode.READ_ONLY)
    const stat = await fileIo.stat(uri)
    const buffer = new ArrayBuffer(stat.size)
    await fileIo.read(file.fd, buffer)
    await fileIo.close(file.fd)
    
    const content = this.bufferToString(buffer)
    const name = uri.split('/').pop() || 'unknown'
    
    return { name, path: uri, content }
  }
  
  /**
   * 保存文件
   */
  async saveFile(path: string, content: string): Promise<void> {
    const file = await fileIo.open(path, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE)
    const buffer = this.stringToBuffer(content)
    await fileIo.write(file.fd, buffer)
    await fileIo.close(file.fd)
  }
  
  /**
   * 另存为
   */
  async saveAsFile(content: string, defaultName: string): Promise<string> {
    const documentPicker = new picker.DocumentViewPicker(this.context)
    
    const result = await documentPicker.save({
      newFileNames: [defaultName]
    })
    
    if (result.length === 0) {
      throw new Error('未选择保存位置')
    }
    
    const path = result[0]
    await this.saveFile(path, content)
    return path
  }
  
  private bufferToString(buffer: ArrayBuffer): string {
    return new TextDecoder().decode(buffer)
  }
  
  private stringToBuffer(str: string): ArrayBuffer {
    return new TextEncoder().encode(str).buffer
  }
}
```

---

## 🔄 状态管理设计

使用 `@State`、`@Link`、`@Prop` 实现组件间状态传递：

```typescript
// 主页面状态管理
@Entry
@Component
struct TabletCodeEditorPage {
  // 文件系统状态
  @State rootFolder: FileNode | null = null
  @State expandedFolders: Set<string> = new Set()
  @State selectedFile: FileNode | null = null
  
  // 编辑器状态
  @State tabs: EditorTab[] = []
  @State activeTabId: string | null = null
  @State currentContent: string = ''
  @State currentLanguage: string = 'typescript'
  
  // UI 状态
  @State sidebarVisible: boolean = true
  @State sidebarWidth: number = 280
  @State theme: 'light' | 'dark' = 'dark'
  
  // 编辑器设置
  @State fontSize: number = 14
  @State tabSize: number = 2
  @State lineNumbers: boolean = true
  
  private fileService: FileService | null = null
  private syntaxHighlighter: SyntaxHighlighter = new SyntaxHighlighter()
  
  aboutToAppear() {
    const context = getContext(this) as common.UIAbilityContext
    this.fileService = new FileService(context)
  }
  
  build() {
    Column() {
      // 顶部工具栏
      TopToolbar({
        projectName: this.rootFolder?.name || '未命名项目',
        theme: this.theme,
        onMenuClick: () => { this.sidebarVisible = !this.sidebarVisible },
        onSaveClick: () => { this.handleSave() },
        onThemeToggle: () => { this.toggleTheme() },
        onSettingsClick: () => { this.showSettings() }
      })
      
      // 主内容区
      Row() {
        // 侧边栏
        if (this.sidebarVisible) {
          FileSidebar({
            rootFolder: $rootFolder,
            expandedFolders: $expandedFolders,
            selectedFile: $selectedFile,
            onFileSelect: (file) => this.openFileInTab(file),
            onFolderToggle: (folder) => this.toggleFolder(folder)
          })
          .width(this.sidebarWidth)
          .transition({ type: TransitionType.Insert, opacity: 1 })
          .transition({ type: TransitionType.Delete, opacity: 0 })
        }
        
        // 编辑器面板
        Column() {
          // 标签栏
          TabBar({
            tabs: $tabs,
            activeTabId: $activeTabId,
            onTabSelect: (id) => this.switchTab(id),
            onTabClose: (id) => this.closeTab(id),
            onNewTab: () => this.createNewTab()
          })
          
          // 代码编辑区
          if (this.activeTabId) {
            CodeEditorView({
              content: $currentContent,
              language: this.currentLanguage,
              fontSize: this.fontSize,
              lineNumbers: this.lineNumbers
            })
            .layoutWeight(1)
          } else {
            // 空状态 - 欢迎界面
            WelcomeView({
              onOpenFile: () => this.handleOpenFile(),
              onOpenFolder: () => this.handleOpenFolder()
            })
            .layoutWeight(1)
          }
          
          // 状态栏
          StatusBar({
            line: this.getCurrentLine(),
            column: this.getCurrentColumn(),
            language: this.currentLanguage,
            encoding: 'UTF-8',
            lineEnding: 'LF',
            isDirty: this.isCurrentTabDirty()
          })
        }
        .layoutWeight(1)
        .height('100%')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
  
  // ... 实现各种处理方法
}
```

---

## ⌨️ 交互设计

### 手势操作

| 操作 | 触发方式 | 响应 |
|------|---------|------|
| 选择文件/标签 | 单击 | 切换当前编辑的文件 |
| 展开/折叠文件夹 | 单击文件夹 | 切换展开状态 |
| 右键菜单 | 长按（平板）/ 右键 | 显示上下文菜单 |
| 关闭标签 | 点击标签X / 中键点击 | 关闭当前标签 |
| 滚动代码 | 双指滑动 | 垂直滚动代码区 |
| 调整侧边栏宽度 | 拖拽分割线 | 改变侧边栏宽度 |

### 快捷键支持（外接键盘）

| 快捷键 | 功能 |
|--------|------|
| Ctrl + S | 保存当前文件 |
| Ctrl + O | 打开文件 |
| Ctrl + W | 关闭当前标签 |
| Ctrl + Tab | 切换到下一个标签 |
| Ctrl + Shift + Tab | 切换到上一个标签 |
| Ctrl + + | 增大字号 |
| Ctrl + - | 减小字号 |
| Ctrl + 0 | 重置字号 |

---

## 📱 响应式适配

```typescript
import { mediaquery } from '@kit.ArkUI'

@Entry
@Component
struct TabletCodeEditorPage {
  @State isLargeScreen: boolean = true
  @State sidebarWidth: number = 280
  
  private mdListener = mediaquery.matchMediaSync('(min-width: 600vp)')
  private lgListener = mediaquery.matchMediaSync('(min-width: 840vp)')
  private xlListener = mediaquery.matchMediaSync('(min-width: 1200vp)')
  
  aboutToAppear() {
    this.mdListener.on('change', (result) => {
      if (!result.matches) {
        // 小屏幕：隐藏侧边栏
        this.sidebarVisible = false
        this.sidebarWidth = 0
      }
    })
    
    this.lgListener.on('change', (result) => {
      if (result.matches) {
        // 大屏幕：显示侧边栏
        this.sidebarVisible = true
        this.sidebarWidth = 280
      }
    })
    
    this.xlListener.on('change', (result) => {
      if (result.matches) {
        // 超大屏幕：加宽侧边栏
        this.sidebarWidth = 320
      }
    })
  }
}
```

---

## 🎯 设计总结

本设计方案的核心特点：

1. **模块化组件设计**：将编辑器拆分为独立的可复用组件
2. **完整的语法高亮**：支持 ArkTS/TypeScript 等语言的关键字、字符串、注释等高亮
3. **类 VS Code 交互**：左侧文件树 + 右侧编辑器的经典布局
4. **响应式布局**：适配平板横竖屏及不同尺寸设备
5. **主题支持**：内置浅色/深色主题切换
6. **状态管理**：使用鸿蒙装饰器进行高效的状态同步

### 推荐文件结构

```
entry/src/main/ets/
├── pages/
│   └── TabletCodeEditor.ets       # 主页面
├── components/
│   ├── editor/
│   │   ├── TopToolbar.ets         # 顶部工具栏
│   │   ├── FileSidebar.ets        # 文件侧边栏
│   │   ├── FileTreeNode.ets       # 文件树节点
│   │   ├── TabBar.ets             # 标签栏
│   │   ├── EditorTabItem.ets      # 标签项
│   │   ├── CodeEditorView.ets     # 代码编辑视图
│   │   ├── StatusBar.ets          # 状态栏
│   │   └── WelcomeView.ets        # 欢迎界面
│   └── common/
│       ├── IconButton.ets         # 图标按钮
│       └── ContextMenu.ets        # 上下文菜单
├── services/
│   ├── SyntaxHighlighter.ts       # 语法高亮服务
│   ├── FileService.ts             # 文件操作服务
│   └── ThemeService.ts            # 主题服务
├── models/
│   ├── FileNode.ts                # 文件节点模型
│   └── EditorTab.ts               # 编辑器标签模型
└── theme/
    ├── LightTheme.ts              # 浅色主题
    └── DarkTheme.ts               # 深色主题
```

---

如需要，我可以继续实现具体的代码文件。
