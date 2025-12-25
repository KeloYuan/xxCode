# xxCode 项目代码结构文档

## 项目概述

xxCode 是一个基于鸿蒙原生技术栈开发的专业代码编辑器应用，采用 ArkTS 语言和鸿蒙设计语言构建，提供流畅的原生编程体验。

### 技术栈
- **开发语言**: ArkTS/eTS
- **UI框架**: 鸿蒙原生组件
- **构建工具**: Hvigor
- **包管理**: oh-package
- **测试框架**: Hypium + Hamock

---

## 目录结构

```
entry/src/main/ets/
├── entryability/          # 应用入口
├── pages/                 # 页面
├── components/            # 组件
│   ├── tablet/           # 平板端组件
│   └── ...
├── services/              # 服务层
├── models/                # 数据模型
└── common/                # 通用工具
```

---

## 1. 应用入口 (entryability)

### EntryAbility.ets
**类型**: 应用入口能力

**主要功能**:
- 应用生命周期管理
- 启动页面智能判断（根据用户状态直接加载目标页面）
- 沉浸式模式配置（全屏布局、状态栏透明）

**关键方法**:
| 方法 | 说明 |
|-----|------|
| `onCreate()` | 应用创建时的初始化 |
| `onWindowStageCreate()` | 窗口创建，加载启动页面 |
| `determineStartPage()` | 根据用户状态确定启动页面 |
| `configureImmersiveMode()` | 配置沉浸式效果 |

---

## 2. 页面文件 (pages)

### Agreement.ets - 用户协议页面
**类型**: 页面

**主要功能**:
- 首次启动时显示用户协议和隐私政策
- 用户同意后记录到本地存储
- 已同意用户不再显示此页面

### Index.ets - 欢迎页面
**类型**: 页面

**主要功能**:
- 应用欢迎界面
- 展示应用特性和功能介绍
- 引导用户开始使用

### CodeEditor.ets - 移动端代码编辑器
**类型**: 页面 (主页面)

**主要功能**:
- 移动端代码编辑主界面
- 多标签文件管理
- 代码编辑和预览
- 文件浏览器集成
- 移动端菜单集成

**核心功能**:
| 功能 | 说明 |
|-----|------|
| 多标签编辑 | 支持同时打开多个文件 |
| 语法高亮 | 实时语法高亮显示 |
| 快捷键 | Ctrl+S 保存、Ctrl+F 搜索等 |
| 文件管理 | 新建、打开、保存文件 |

### TabletCodeEditor.ets - 平板端代码编辑器
**类型**: 页面 (平板主页面)

**主要功能**:
- 平板端优化的代码编辑界面
- 鸿蒙6风格设计
- 更大的编辑区域和工具栏
- 平板端手势支持

### Settings.ets - 设置页面
**类型**: 页面

**主要功能**:
- 主题选择（6种预设主题）
- 编辑器字体大小调整
- 行高调整
- 行号显示开关
- 应用版本信息

### Changelog.ets - 更新日志
**类型**: 页面

**主要功能**:
- 显示版本更新记录
- 新功能介绍
- Bug 修复记录

### RecentProjects.ets - 最近项目
**类型**: 页面

**主要功能**:
- 显示最近打开的文件列表
- 快速打开最近文件
- 清空最近记录

### Templates.ets - 代码模板
**类型**: 页面

**主要功能**:
- 代码模板列表展示
- 模板分类和搜索
- 选择模板应用到编辑器

### Help.ets - 帮助页面
**类型**: 页面

**主要功能**:
- 应用使用说明
- 快捷键列表（含设备限制说明）
- 手势操作指南
- 使用技巧

### Learning.ets - 学习页面
**类型**: 页面

**主要功能**:
- 提供学习样本文件
- 带注释的代码示例
- 引导用户学习编程

---

## 3. 移动端组件 (components)

### CodeEditorView.ets - 代码编辑器视图
**类型**: 组件

**主要功能**:
- 实时语法高亮的代码编辑器
- 支持多语言语法分析
- 行号显示
- 代码格式化

### MobileMenu.ets - 移动端菜单
**类型**: 组件

**主要功能**:
- 移动端功能菜单（11个菜单项）
- 分组显示（文件操作、编辑操作、视图操作）
- 触摸反馈动画

**菜单项**:
- 新建文件、保存、打开
- 搜索、替换、格式化
- 撤销、重做
- 设置

### TabBar.ets - 标签栏
**类型**: 组件

**主要功能**:
- 多标签页显示和管理
- 标签切换
- 关闭标签
- 悬停高亮效果

### TabManagerPanel.ets - 标签管理面板
**类型**: 组件

**主要功能**:
- 标签列表详细展示
- 批量关闭操作
- 标签排序

### FileBrowser.ets - 文件浏览器
**类型**: 组件

**主要功能**:
- 文件系统树形浏览
- 目录导航
- 文件过滤
- 右键上下文菜单

### BottomSheet.ets - 底部弹窗
**类型**: 组件

**主要功能**:
- 底部抽屉式面板
- 支持拖拽关闭
- 用于显示额外操作选项

### DrawerPanel.ets - 抽屉面板
**类型**: 组件

**主要功能**:
- 侧边抽屉式面板
- 用于移动端文件浏览器
- 滑动开关

### ConsolePanel.ets - 控制台面板
**类型**: 组件

**主要功能**:
- 显示代码执行输出
- 错误信息显示
- 日志查看

### FileTypeBadge.ets - 文件类型徽章
**类型**: 组件

**主要功能**:
- 显示文件类型标识
- 不同文件类型不同颜色
- 文件扩展名显示

### MarkdownPreview.ets - Markdown预览
**类型**: 组件

**主要功能**:
- Markdown 文件实时预览
- 支持标题、列表、代码块
- 渲染格式化内容

### NewFileDialog.ets - 新建文件对话框
**类型**: 组件

**主要功能**:
- 创建新文件界面
- 文件名输入
- 文件类型选择

### TemplateDialog.ets - 模板对话框
**类型**: 组件

**主要功能**:
- 选择代码模板界面
- 模板预览
- 应用模板到编辑器

### IconButton.ets - 图标按钮
**类型**: 组件 (通用组件)

**主要功能**:
- 带图标的按钮
- 支持悬停和按下效果
- 可配置大小和颜色

### SearchDialog.ets - 搜索对话框
**类型**: 组件

**主要功能**:
- 查找和替换界面
- 支持正则表达式
- 区分大小写选项

### WelcomeGuide.ets - 欢迎指南
**类型**: 组件

**主要功能**:
- 新用户使用引导
- 功能介绍
- 操作指南

### FileContextMenu.ets - 文件上下文菜单
**类型**: 组件

**主要功能**:
- 文件右键菜单
- 删除、重命名、复制等操作

### FileTreeItem.ets - 文件树项
**类型**: 组件

**主要功能**:
- 文件树中的单个节点
- 展开/折叠文件夹
- 显示文件图标

---

## 4. 平板端组件 (components/tablet)

### CodeEditorView.ets - 平板编辑器视图
**类型**: 组件 (平板版)

**主要功能**:
- 平板端优化的代码编辑器
- 更大的编辑区域
- 支持外接键盘快捷键

### EditorStatusBar.ets - 编辑器状态栏
**类型**: 组件

**主要功能**:
- 显示当前光标位置
- 文件编码信息
- 语言模式显示

### EditorTabBar.ets - 编辑器标签栏
**类型**: 组件 (平板版)

**主要功能**:
- 平板端的标签管理
- 更大的点击区域
- 支持标签拖拽

### FileSidebar.ets - 文件侧边栏
**类型**: 组件

**主要功能**:
- 平板端固定文件树侧边栏
- 目录导航
- 文件操作

### FileTreeNode.ets - 文件树节点
**类型**: 组件

**主要功能**:
- 文件树中的节点组件
- 展开/折叠动画
- 选择状态显示

### TopToolbar.ets - 顶部工具栏
**类型**: 组件

**主要功能**:
- 平板端顶部工具栏
- 常用操作按钮
- 主题切换入口

### WelcomeView.ets - 平板欢迎页
**类型**: 组件

**主要功能**:
- 平板端欢迎界面
- 最近项目快速访问
- 功能入口

---

## 5. 服务层 (services)

### ThemeService.ets - 主题服务
**类型**: 服务 (单例)

**主要功能**:
- 管理 6 种预设主题
- 主题切换和持久化
- 系统主题适配

**主题列表**:
| 主题ID | 主题名称 | 风格 |
|-------|---------|------|
| monokai | Monokai | 深色暖色调 |
| github | GitHub Dimmed | 浅色清爽 |
| dracula | Dracula | 深色紫色调 |
| nord | Nord | 深色冷色调 |
| solarized | Solarized | 柔和色调 |
| light | Light | 浅色简约 |

### FileManagerService.ets - 文件管理服务
**类型**: 服务 (单例)

**主要功能**:
- 统一文件操作接口
- 支持内部工作区和外部文件
- 文件读写、创建、删除
- 文件编码处理

**核心方法**:
| 方法 | 说明 |
|-----|------|
| `init()` | 初始化工作区 |
| `readFile()` | 读取文件内容 |
| `writeFile()` | 写入文件内容 |
| `createFile()` | 创建新文件 |
| `deleteFile()` | 删除文件 |
| `getCodesDir()` | 获取代码目录 |

### BreakpointService.ets - 断点服务
**类型**: 服务 (单例)

**主要功能**:
- 5 级断点响应式系统
- 实时监听设备变化
- 发布布局变更指令

**断点定义**:
| 断点 | 屏幕宽度 | 适用设备 |
|-----|---------|---------|
| xs | 0-360vp | 小屏手机 |
| sm | 360-480vp | 手机 |
| md | 480-840vp | 大屏手机/小平板 |
| lg | 840-1280vp | 平板 |
| xl | >=1280vp | 桌面 |

### SyntaxHighlightService.ets - 语法高亮服务
**类型**: 服务 (单例)

**主要功能**:
- 多语言语法高亮分析引擎
- Token 分类和着色
- 支持的语言：JS/TS/ETS、Python、Java、Markdown、JSON、HTML/CSS

**Token 类型**:
- 关键字 (keyword)
- 字符串 (string)
- 注释 (comment)
- 数字 (number)
- 函数名 (function)
- 操作符 (operator)

### CodeFormatterService.ets - 代码格式化服务
**类型**: 服务

**主要功能**:
- 代码格式化和美化
- 缩进调整
- 代码风格统一

### ThemeManager.ets - 主题管理器
**类型**: 服务

**主要功能**:
- 主题配置管理
- 主题切换逻辑

### SystemBarService.ets - 系统栏服务
**类型**: 服务

**主要功能**:
- 状态栏和导航栏管理
- 沉浸式模式配置

### FileService.ets / RealFileService.ets - 文件服务
**类型**: 服务

**主要功能**:
- 基础文件操作
- 真实文件系统访问

### MarkdownService.ets - Markdown服务
**类型**: 服务

**主要功能**:
- Markdown 文件解析
- 渲染为富文本

### SearchService.ets - 搜索服务
**类型**: 服务

**主要功能**:
- 文件内容搜索
- 代码搜索
- 正则表达式支持

---

## 6. 数据模型 (models)

### EditorModels.ets - 编辑器模型
**类型**: 数据模型

**主要定义**:
- `FileNode`: 文件树节点结构
- `EditorTab`: 编辑器标签数据结构
- `SyntaxToken`: 语法高亮 Token
- `CodeTemplate`: 代码模板数据结构

### FileModel.ets - 文件模型
**类型**: 数据模型

**主要定义**:
- 文件基础数据结构

### EditorTab.ets - 编辑器标签
**类型**: 数据模型

**主要属性**:
| 属性 | 类型 | 说明 |
|-----|------|------|
| id | string | 标签唯一标识 |
| name | string | 文件名 |
| path | string | 文件路径 |
| content | string | 文件内容 |
| language | string | 语言类型 |
| isModified | boolean | 是否已修改 |

### FileTabModel.ets - 文件标签模型
**类型**: 数据模型

**主要功能**:
- 扩展的标签数据模型
- 支持更多标签属性

### CodeTemplateModel.ets - 代码模板模型
**类型**: 数据模型

**主要定义**:
- `CodeTemplate`: 模板数据结构
- 模板分类和元数据

---

## 7. 通用工具 (common)

### CommonConstants.ets - 通用常量
**类型**: 常量定义

**主要常量**:
- Z-Index 层级配置
- 编辑器配置常量
- 动画时长配置

---

## 核心架构设计

### 多设备响应式架构

```
┌─────────────────────────────────────┐
│         BreakpointService          │
│  (5级断点: xs/sm/md/lg/xl)         │
└──────────────┬──────────────────────┘
               │
       ┌───────┴───────┐
       ▼               ▼
┌──────────┐    ┌──────────┐
│ 移动端UI  │    │ 平板端UI │
│ 抽屉面板  │    │ 固定侧栏 │
└──────────┘    └──────────┘
```

### 服务层单例模式

所有服务采用单例模式确保全局状态一致：

```typescript
// 获取服务实例
const themeService = ThemeService.getInstance();
const fileManager = FileManagerService.getInstance();
const breakpointService = BreakpointService.getInstance();
```

### 文件管理策略

| 模式 | 说明 | 用途 |
|-----|------|------|
| 内部工作区 | 直接读写 | 应用内创建的文件 |
| 外部文件 | 导入编辑 | 从系统选择导入的文件 |

### 页面路由流程

```
EntryAbility
    │
    ├─ determineStartPage()
    │
    ├─ 未同意协议 → Agreement.ets
    │      │
    │      └─ 同意 → Index.ets → CodeEditor.ets
    │
    ├─ 已同意、未看过欢迎 → Index.ets → CodeEditor.ets
    │
    └─ 已完成引导 → CodeEditor.ets (直接进入)
```

---

## 快捷键说明

| 快捷键 | 功能 | 设备限制 |
|-------|------|---------|
| Ctrl + S | 保存文件 | 仅电脑端/外接键盘 |
| Ctrl + F | 搜索 | 仅电脑端/外接键盘 |
| Ctrl + Alt + L | 格式化代码 | 仅电脑端/外接键盘 |

---

## 主题列表

| 主题ID | 名称 | 背景色 | 适用场景 |
|-------|------|-------|---------|
| monokai | Monokai | #272822 | 深色编码 |
| github | GitHub Dimmed | #ffffff | 浅色办公 |
| dracula | Dracula | #282a36 | 深色紫调 |
| nord | Nord | #2e3440 | 深色冷调 |
| solarized | Solarized | #fdf6e3 | 柔和护眼 |
| light | Light | #ffffff | 浅色简约 |

---

## 开发命令

### 构建命令
```bash
# 开发构建
hvigorw assembleHap

# 生产构建
hvigorw assembleHap --mode release

# 清理缓存
hvigorw clean
```

### 设备调试
```bash
# 查看连接设备
hdc list targets

# 安装 HAP
hdc install entry/build/default/outputs/default/entry-default-signed.hap

# 启动应用
hdc shell aa start -a EntryAbility -b com.example.codeeditor

# 查看日志
hdc hilog | grep xxCode
```

---

## 版本历史

| 版本 | 日期 | 主要更新 |
|-----|------|---------|
| 3.0.0 | 2024-12 | 启动流程优化、快捷键说明、API警告处理 |
| 2.0.0 | - | 基础功能完善 |
| 1.0.0 | - | 初始版本 |

---

## 总结

xxCode 是一个完整的鸿蒙原生代码编辑器应用，具有以下特点：

1. **多端适配**: 一套代码，多端部署
2. **响应式设计**: 5级断点系统，智能适配
3. **主题丰富**: 6种预设主题，支持深浅色
4. **功能完整**: 编辑、预览、搜索、格式化
5. **架构清晰**: 分层设计，单例服务
6. **用户体验**: 沉浸式界面，流畅动画

该项目充分展示了鸿蒙原生开发的优秀实践。
