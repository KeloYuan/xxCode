# 鸿蒙原生代码编辑器

## 项目介绍

这是一个专为鸿蒙5系统设计的原生代码编辑器应用，融合了代码编辑器和笔记本的特性，为开发者提供流畅、高效的编程体验。

## 功能特性

### 核心功能
- ✅ **多标签页支持** - 同时打开多个文件进行编辑
- ✅ **文件树导航** - 树状结构展示项目文件，支持文件夹展开/折叠
- ✅ **语法高亮** - 支持主流编程语言（JavaScript、TypeScript、Python、Java、C++、Go、Rust等）
- ✅ **Markdown实时预览** - 智能检测Markdown文件，提供实时预览功能
- ✅ **主题切换** - 支持浅色、深色、鸿蒙三种主题
- ✅ **全文搜索** - 支持搜索文件内容和文件名，带搜索建议
- ✅ **代码格式化** - 智能代码格式化和缩进管理

### 技术特性
- 🏗️ **原生鸿蒙体验** - 深度集成鸿蒙系统能力，使用原生组件
- ⚡ **高性能** - 基于鸿蒙原生技术栈，追求极致性能
- 🎨 **鸿蒙美学** - 采用Material You设计语言，丰富的动画效果
- 🧩 **模块化架构** - 清晰的分层架构，便于维护和扩展

## 开发环境

- **开发框架**: ArkTS + eTS
- **目标系统**: HarmonyOS 5.0+
- **支持设备**: 手机、平板、2合1设备
- **开发工具**: DevEco Studio

## 项目结构

```
├── entry/                          # 主模块
│   ├── src/main/
│   │   ├── ets/                    # 源代码
│   │   │   ├── components/         # 组件
│   │   │   │   ├── HighlightedText.ets    # 高亮文本组件
│   │   │   │   ├── MarkdownPreview.ets    # Markdown预览组件
│   │   │   │   └── SearchDialog.ets       # 搜索对话框
│   │   │   ├── models/             # 数据模型
│   │   │   │   └── FileModel.ets
│   │   │   ├── pages/              # 页面
│   │   │   │   └── CodeEditor.ets
│   │   │   └── services/           # 服务层
│   │   │       ├── FileService.ets
│   │   │       ├── SyntaxHighlightService.ets
│   │   │       ├── MarkdownService.ets
│   │   │       ├── ThemeService.ets
│   │   │       └── SearchService.ets
│   │   ├── module.json5            # 模块配置
│   │   └── resources/              # 资源文件
│   └── build/                      # 构建输出
├── AppScope/                       # 应用配置
└── build-profile.json5            # 构建配置
```

## 运行方法

### 方法1: DevEco Studio（推荐）
1. 打开 DevEco Studio
2. 选择 "Open" > 选择此项目文件夹
3. 等待项目加载完成
4. 点击运行按钮或按 `Ctrl + R` 运行应用

### 方法2: 命令行构建
```bash
# 安装依赖
npm install

# 构建应用
hvigorw assembleApp --mode debug

# 生成HAP包
hvigorw buildApp --mode debug
```

### 方法3: 设备安装
```bash
# 安装到设备（需要hdc工具）
hdc install -r entry-default-signed.hap
```

## 使用说明

### 基本操作
1. **打开文件** - 点击文件树中的文件打开编辑
2. **新建文件** - 点击工具栏的"新建文件"按钮
3. **保存文件** - 点击工具栏的"保存"按钮
4. **切换标签页** - 点击标签页进行切换
5. **关闭标签页** - 点击标签页上的"×"按钮

### 高级功能
1. **Markdown预览** - 打开.md文件时自动启用预览模式
2. **主题切换** - 点击工具栏的"主题"按钮切换主题
3. **搜索功能** - 点击工具栏的"搜索"按钮进行全文搜索
4. **文件树导航** - 点击文件夹展开/折叠，支持多层级浏览

### 快捷键
- `Ctrl + S` - 保存当前文件
- `Ctrl + N` - 新建文件
- `Ctrl + F` - 搜索
- `Tab` - 插入制表符
- `Shift + Tab` - 减少缩进

## 开发状态

- ✅ **Phase 1** - 基础框架搭建（完成）
- ✅ **Phase 2** - 核心编辑功能（完成）
- ✅ **Phase 3** - 高级功能开发（完成）
- ✅ **代码优化** - 修复所有编译错误（完成）
- ✅ **构建测试** - 应用可以成功编译（完成）

## 技术架构

### 架构分层
```
┌─────────────────────────────────────┐
│           UI Layer                  │
│   Pages + Components + Utils        │
├─────────────────────────────────────┤
│        Business Logic Layer         │
│   Services (File, Theme, Search)    │
├─────────────────────────────────────┤
│         Data Layer                  │
│   Models + Preferences + Storage    │
├─────────────────────────────────────┤
│       System APIs                   │
│   FileSystem + UI + Network         │
└─────────────────────────────────────┘
```

### 核心技术栈
- **前端框架**: ArkTS + eTS
- **UI组件**: 鸿蒙原生组件
- **数据存储**: Preferences + 文件系统
- **语法解析**: 自定义正则表达式引擎
- **主题系统**: 动态颜色切换

## 许可证

MIT License

## 作者

Niki

---

**鸿蒙原生代码编辑器现已完成，可以正常使用！** 🎊
