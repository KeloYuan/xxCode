# Project Structure

## root
- `Log.md`: 开发变更日志
- `Project.md`: 项目结构说明

## entry/src/main/ets
核心代码目录

### components/ (UI组件)
- `ConsolePanel.ets`: 代码运行控制台面板 [新]
- `CodeEditorView.ets`: 代码编辑器核心组件
- `MarkdownPreview.ets`: Markdown 预览组件
- `TabBar.ets`: 顶部标签栏
- `FileBrowser.ets`: 文件浏览器
- `DrawerPanel.ets`: 侧边栏抽屉
- `BottomSheet.ets`: 底部面板
- `MobileMenu.ets`: 移动端菜单

### pages/ (页面)
- `CodeEditor.ets`: 主编辑器页面 [新增运行逻辑与 Web 沙箱]
- `Index.ets`: 入口页
- `Settings.ets`: 设置页

### services/ (服务)
- `CodeFormatterService.ets`: 代码格式化服务
- `SyntaxHighlightService.ets`: 语法高亮服务
- `MarkdownService.ets`: Markdown 解析服务
- `FileManagerService.ets`: 文件管理服务
- `ThemeService.ets`: 主题服务
- `BreakpointService.ets`: 断点/响应式布局服务

### models/ (数据模型)
- `FileTabModel.ets`: 文件标签页模型
- `EditorModels.ets`: 编辑器相关模型
