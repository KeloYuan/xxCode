# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个基于鸿蒙原生技术栈开发的专业代码编辑器应用，采用ArkTS语言和鸿蒙设计语言构建，提供流畅的原生编程体验。

### 技术栈
- **开发语言**: ArkTS/eTS
- **UI框架**: 鸿蒙原生组件
- **构建工具**: Hvigor
- **包管理**: oh-package
- **测试框架**: Hypium + Hamock

## 核心架构

该项目采用分层架构设计，实现了一次开发多端部署的鸿蒙代码编辑器：

### 多设备响应式架构
- **断点系统** (`BreakpointService`)：5级断点 (xs/sm/md/lg/xl) 适配不同屏幕尺寸
- **布局策略**：移动端使用抽屉面板，桌面端使用固定侧边栏
- **响应式组件**：根据断点自动切换UI布局和交互模式

### 服务层架构 (单例模式)
- **ThemeService**：6种主题管理，支持实时切换和系统适配
- **FileManagerService**：统一文件操作接口，支持内部工作区和外部文件
- **BreakpointService**：实时监听设备变化，发布响应式布局指令
- **SyntaxHighlightService**：多语言语法高亮引擎

### 文件管理策略
- **多标签系统**：`FileTab` 模型管理文件状态，支持修改标记和语言检测
- **双文件模式**：内部工作区文件 (直接编辑) + 外部文件 (导入编辑)
- **编辑器双模式**：编辑模式 (实时预览) + 预览模式 (只读查看)

## 开发命令

### 构建和运行

```bash
# 开发构建
hvigorw assembleHap

# 生产构建
hvigorw assembleHap --mode release

# 清理缓存
hvigorw clean

# 增量构建
hvigorw assembleHap --daemon
```

### 设备调试

```bash
# 查看连接设备
hdc list targets

# 安装HAP包
hdc install entry/build/default/outputs/default/entry-default-signed.hap

# 启动应用
hdc shell aa start -a EntryAbility -b com.example.codeeditor

# 查看应用日志
hdc hilog | grep xxCode

# 卸载应用
hdc uninstall com.example.codeeditor
```

### 测试

```bash
# 运行单元测试
hvigor test

# 运行特定测试
hvigor test --tests "**/MobileMenu.test.ets"

# 运行UI测试
hvigor testOhosTest
```

## 关键开发模式

### 响应式开发模式
开发组件时必须考虑多端适配：
```typescript
// 使用 BreakpointService 检测当前布局
const isMobile = BreakpointService.getInstance().isMobile();

// 条件渲染不同UI
if (isMobile) {
  // 移动端：抽屉面板、底部菜单
} else {
  // 桌面端：固定侧边栏、顶部工具栏
}
```

### 主题适配模式
所有UI组件必须支持主题切换：
```typescript
// 从 ThemeService 获取当前主题
const theme = ThemeService.getInstance().getCurrentTheme();
// 使用 theme.colors 和 theme.syntax
```

### 服务使用模式
服务层采用单例模式，确保全局状态一致：
```typescript
// 正确的服务获取方式
const fileManager = FileManagerService.getInstance();
const themeService = ThemeService.getInstance();
```

### 代码验证模式
**重要：每次编写代码后必须遵循以下流程**
1. **构建验证**：完成代码修改后，先运行 `hvigorw assembleHap` 检测是否有编译错误
2. **错误修复**：如果存在错误，先自行修复所有编译问题
3. **需求确认**：如果实现与需求存在歧义或冲突，必须先询问用户确认方案
4. **完成汇报**：只有在构建成功且无错误时，才告知用户代码已完成

```bash
# 标准验证流程
hvigorw assembleHap
```

## 重要设计模式

### 组件通信
- **父子组件**: 使用 @Prop 和 @State
- **跨组件**: 通过服务层的观察者模式
- **全局状态**: AppStorage + 服务单例

### 文件操作流程
1. **内部文件**: 工作区文件，直接读写
2. **外部文件**: 通过picker获取，可选择导入到工作区
3. **文件保存**: 自动保存 + 手动保存双重保障

### 测试规范
- **测试文件命名**: `FeatureName.test.ets`
- **测试框架**: Hypium + Hamock
- **测试结构**: describe/beforeAll/it/expect
- **Mock策略**: 使用 @ohos/hamock 模拟外部依赖

## 关键文件说明

### 配置文件
- `build-profile.json5`: 构建配置，包含签名信息
- `oh-package.json5`: 项目依赖，包含测试框架
- `AppScope/app.json5`: 应用全局配置

### 核心服务
- `BreakpointService.ets`: 响应式布局核心
- `ThemeService.ets`: 主题管理核心
- `FileManagerService.ets`: 文件操作统一接口

### 重要组件
- `MobileMenu.ets`: 移动端分组菜单 (11个菜单项)
- `CodeEditorView.ets`: 代码编辑器核心组件
- `TabBar.ets`: 多标签页管理

## 常见问题解决

### 测试问题
- Hypium测试的 `it` 函数不接受第三个参数
- 确保测试用例与实际组件功能保持同步
- 使用 `expect().assertEqual()` 而非 `toBe()`

### 构建问题
- 使用 `hvigorw` 而非 `hvigor` 命令
- 确保签名配置正确
- 清理缓存：`hvigorw clean`

### 主题问题
- 新组件必须从 ThemeService 获取颜色
- 支持深色/浅色主题切换
- 使用 `$r()` 资源引用
