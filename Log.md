# Changelog

## 2025-12-23
- **Bug 修复 (Bug Fixes)**:
  - **移动端按钮点击修复**: 修复了移动端工具栏按钮（左侧文件浏览器和右侧菜单按钮）点击无效的问题。原因是边缘手势检测区域的 `y` 坐标从 0 开始，覆盖了工具栏按钮。修改为从工具栏下方 (y: 100) 开始检测。
  - **保存功能优化**: 优化了未命名文件的保存逻辑，判断 `fileName` 去掉后缀是否为"未命名"来决定是否在工作区创建新文件。

- **移动端UI优化 (Mobile UI Enhancement)**:
  - **工具栏优化**:
    - 左侧按钮改为文件夹图标 📁，更直观地表示文件浏览器
    - 添加 `stateEffect: true` 提供更好的触摸反馈
    - 增大圆角 (24px) 符合鸿蒙设计规范
    - 添加 `TapGesture` 增强点击检测
    - 文件名区域添加背景和圆角，增强点击感知
  - **DrawerPanel 组件优化**:
    - 添加遮罩层渐变动画 (`maskOpacity`)
    - 添加抽屉内容阴影效果
    - 优化圆角设计（左侧 16px）
    - 添加入场动画和更流畅的过渡效果
  - **BottomSheet 组件优化**:
    - 添加遮罩层渐变动画
    - 优化拖动指示器样式
    - 增大顶部圆角到 20px
    - 添加阴影和入场动画效果
  - **TabManagerPanel 组件优化**:
    - 新建按钮改为圆形 "+" 图标按钮，更符合鸿蒙设计
    - 优化空状态显示，添加图标占位
    - 添加路径短显示功能 (`getShortPath`)，长路径只显示 ".../文件名"
    - 标签项高度优化为 68px，增加间距
    - 关闭按钮改为圆形 ✕ 按钮
    - 优化当前标签高亮效果

## 2025-12-22
- **Bug 修复 (Bug Fixes)**:
  - **崩溃修复**: 修复了 `ConsolePanel` 组件导致的运行时崩溃问题。原因是在 `onClose` 和 `onClear` 回调函数上错误地使用了 `@Prop` 装饰器。已移除该装饰器。
  - 修复了 `CodeEditor.ets` 中 `MessageLevel` 未定义的编译错误，将其更新为数字常量。
  - 修复了 `CodeEditor.ets` 中的编译错误：`Property 'ctrlKey' does not exist on type 'KeyEvent'`。
  - 修复了多个废弃 API 的警告 (`animateTo`, `promptAction`, `AlertDialog`)。

- **新功能 (New Feature)**:
  - **JavaScript 代码运行控制台 (Code Runner)**:
    - 集成 `Web` 组件作为沙箱环境，支持直接在应用内运行 JavaScript 代码。
    - 添加 `ConsolePanel` 组件，用于实时显示代码运行的日志 (console.log) 和错误信息。
    - 在移动端菜单中添加了"运行"按钮。

- **功能增强 (Feature Enhancement)**:
  - **Markdown 预览**: 修复了 Markdown 预览功能。
  - **快捷键支持**: 添加了 Ctrl+S (保存), Ctrl+F (搜索), Ctrl+Alt+L (格式化) 的支持。

- **性能优化 (Performance Optimization)**:
  - 优化了编辑器行号渲染 (`LazyForEach`)。