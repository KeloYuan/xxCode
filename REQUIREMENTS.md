# xxCode - 鸿蒙代码编辑器需求文档

## 📋 项目概述

**项目名称**：xxCode

**项目定位**：一款基于 HarmonyOS NEXT 的现代化代码编辑器，支持多种编程语言的语法高亮、文件管理和代码编辑功能。

**核心理念**：
- 📱 移动端优先的设计理念
- 🎨 精美现代的用户界面
- ⚡ 流畅自然的动画效果
- 📐 完善的响应式布局
- 🔧 深度集成鸿蒙原生组件

**技术栈**：
- 开发语言：ArkTS
- UI 框架：ArkUI
- 设计规范：HarmonyOS Design
- API 版本：HarmonyOS NEXT API 12+

---

## 🎯 功能需求

### 1. 核心功能模块

#### 1.1 文件管理
- ✅ **打开文件**
  - 支持系统文件选择器（使用 `@kit.CoreFileKit` 的 `picker` 模块）
  - 支持常见文本文件格式：`.txt`, `.md`, `.js`, `.ts`, `.json`, `.xml`, `.html`, `.css`, `.java`, `.py`, `.c`, `.cpp` 等
  - 文件大小限制：单文件不超过 10MB
  - 最近打开文件历史记录（最多 20 个）

- ✅ **保存文件**
  - 保存到原文件
  - 另存为新文件
  - 自动保存功能（可配置间隔：30秒/1分钟/3分钟/关闭）
  - 未保存提示标识

- ✅ **文件浏览**
  - 文件列表展示
  - 文件类型图标识别
  - 文件元信息显示（大小、修改时间、类型）
  - 文件搜索和过滤

#### 1.2 代码编辑
- ✅ **基础编辑**
  - 多行文本编辑（使用 `TextArea` 组件）
  - 撤销/重做功能
  - 复制/剪切/粘贴
  - 全选功能
  - 行号显示

- ✅ **高级编辑**
  - 语法高亮（支持主流编程语言）
  - 代码自动缩进
  - 括号匹配提示
  - 代码折叠功能
  - 快速查找和替换
  - 正则表达式搜索

#### 1.3 语法高亮
- ✅ **支持的语言**
  - JavaScript / TypeScript / ArkTS
  - HTML / CSS / JSON / XML
  - Python / Java / C / C++
  - Markdown
  - 更多语言扩展支持

- ✅ **高亮特性**
  - 关键字高亮
  - 字符串高亮
  - 注释高亮
  - 数字和常量高亮
  - 函数和类名高亮
  - 自定义配色方案

#### 1.4 多标签管理
- ✅ **标签功能**
  - 同时打开多个文件
  - 标签拖动排序
  - 标签快速切换
  - 标签关闭（单个/全部/其他）
  - 未保存文件标记

#### 1.5 主题系统
- ✅ **内置主题**
  - 浅色主题（默认）
  - 深色主题（护眼）
  - VS Code Dark
  - Monokai
  - Dracula
  - GitHub Light/Dark

- ✅ **主题自定义**
  - 背景色
  - 文本颜色
  - 语法高亮颜色
  - UI 元素颜色
  - 主题导入/导出

### 2. 用户体验功能

#### 2.1 智能辅助
- ✅ **编辑辅助**
  - 自动补全引号、括号
  - 智能缩进
  - 多光标编辑
  - 列选择模式
  - 代码片段插入

#### 2.2 工具功能
- ✅ **实用工具**
  - 字符/单词/行数统计
  - JSON 格式化
  - XML 格式化
  - Base64 编码/解码
  - URL 编码/解码
  - Markdown 预览

#### 2.3 设置与配置
- ✅ **编辑器设置**
  - 字体大小（10-30sp，默认 15sp）
  - 字体系列（Consolas, Monaco, JetBrains Mono）
  - Tab 大小（2/4/8 空格）
  - 自动换行开关
  - 行号显示开关
  - 自动保存间隔

---

## 🎨 UI/UX 设计规范

### 1. 设计原则

#### 1.1 HarmonyOS Design 规范
- **简约现代**：采用简洁的视觉语言，避免冗余元素
- **层次分明**：通过颜色、大小、间距建立清晰的视觉层次
- **一致性**：保持界面元素、交互方式的一致性
- **响应式**：适配不同屏幕尺寸和方向

#### 1.2 移动端适配
- **触控友好**：按钮最小点击区域 44×44 vp
- **手势支持**：滑动、捏合、双击等手势操作
- **单手操作**：重要功能可单手触达
- **状态反馈**：明确的视觉和触觉反馈

### 2. 界面布局

#### 2.1 启动页（Index.ets）
```
┌─────────────────────────────────┐
│                                 │
│     渐变背景 + 装饰性圆形        │
│                                 │
│         ┌─────────┐             │
│         │  Logo   │             │
│         └─────────┘             │
│                                 │
│      鸿蒙代码编辑器              │
│   现代化 · 轻量级 · 高效         │
│                                 │
│   ┌───────────────────────┐    │
│   │   特性卡片 1 ⚡       │    │
│   └───────────────────────┘    │
│   ┌───────────────────────┐    │
│   │   特性卡片 2 🎨       │    │
│   └───────────────────────┘    │
│                                 │
│   ┌───────────────────────┐    │
│   │    🚀 开始编码         │    │
│   └───────────────────────┘    │
│   ┌───────────────────────┐    │
│   │    📖 了解更多         │    │
│   └───────────────────────┘    │
│                                 │
└─────────────────────────────────┘
```

**设计要点**：
- 渐变背景（`#667eea` → `#764ba2`）
- 毛玻璃效果卡片（`backdropBlur(20)`）
- 入场动画（Logo 缩放 + 内容淡入）
- 圆润的卡片设计（`borderRadius: 20`）

#### 2.2 编辑器主界面（CodeEditor.ets）
```
┌─────────────────────────────────┐
│ ← 返回  │  文件名  │  ● 打开 保存│ ← 顶部工具栏
├─────────────────────────────────┤
│ Tab1 │ Tab2 │ Tab3+ │            │ ← 文件标签栏
├─────────────────────────────────┤
│  1 │ function hello() {         │
│  2 │   console.log("Hi");       │ ← 代码编辑区
│  3 │ }                          │   (语法高亮)
│  ... │                          │
│     │                           │
├─────────────────────────────────┤
│ 📝 字符:128 │ 行数:45 │ 已保存   │ ← 底部状态栏
└─────────────────────────────────┘
```

**设计要点**：
- 深色编辑器背景（`#1e1e1e`）
- 等宽字体（Consolas, Monaco）
- 语法高亮颜色
- 光标颜色（`#528bff`）
- 浮动操作按钮（快速操作）

#### 2.3 文件列表页（新增）
```
┌─────────────────────────────────┐
│ ☰ 菜单   文件   🔍 📁 +          │ ← 顶部栏
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │ 📄 index.html           │   │
│  │ 修改于 2小时前  2.3KB   │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ 📜 main.js             │   │ ← 文件卡片
│  │ 修改于 1天前   5.1KB    │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ 📋 styles.css          │   │
│  │ 修改于 3天前   1.8KB    │   │
│  └─────────────────────────┘   │
│                                 │
│           ┌───┐                 │
│           │ + │ ← 悬浮新建按钮   │
│           └───┘                 │
└─────────────────────────────────┘
```

### 3. 颜色规范

#### 3.1 浅色主题
```typescript
{
  primary: '#667eea',           // 主色调
  secondary: '#764ba2',         // 次要色
  background: '#FFFFFF',        // 背景色
  surface: '#F5F5F5',          // 表面色
  text_primary: '#333333',     // 主文本
  text_secondary: '#666666',   // 次要文本
  text_tertiary: '#999999',    // 三级文本
  divider: '#E0E0E0',          // 分割线
  error: '#F56C6C',            // 错误色
  success: '#16a34a',          // 成功色
  warning: '#ffd700',          // 警告色
}
```

#### 3.2 深色主题
```typescript
{
  primary: '#667eea',
  secondary: '#764ba2',
  background: '#1e1e1e',       // 深色背景
  surface: '#2d2d30',          // 表面色
  text_primary: '#d4d4d4',     // 浅色文本
  text_secondary: '#cccccc',
  text_tertiary: '#999999',
  divider: '#3e3e42',
  error: '#F56C6C',
  success: '#16a34a',
  warning: '#ffd700',
}
```

### 4. 动画效果

#### 4.1 页面转场
- **页面进入**：从右侧滑入 + 淡入（300ms，`Curve.EaseOut`）
- **页面退出**：向右滑出 + 淡出（300ms，`Curve.EaseIn`）

```typescript
pageTransition() {
  PageTransitionEnter({ duration: 300 })
    .slide(SlideEffect.Right)
    .opacity(0)
  
  PageTransitionExit({ duration: 300 })
    .slide(SlideEffect.Left)
    .opacity(0)
}
```

#### 4.2 组件动画
- **按钮点击**：缩放效果（0.95x，100ms）
- **卡片展开**：高度变化 + 内容淡入（400ms，`Curve.EaseInOut`）
- **列表项插入**：从左滑入 + 淡入（300ms）
- **列表项删除**：向左滑出 + 淡出（300ms）

#### 4.3 入场动画
- **启动页**：
  - Logo 缩放（0 → 1，800ms，延迟 100ms）
  - 内容淡入（0 → 1，600ms，延迟 400ms）

```typescript
aboutToAppear() {
  setTimeout(() => {
    animateTo({ duration: 800, curve: Curve.EaseOut }, () => {
      this.logoScale = 1;
    });
  }, 100);
  
  setTimeout(() => {
    animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
      this.contentOpacity = 1;
    });
  }, 400);
}
```

#### 4.4 加载动画
- **文件加载**：旋转加载器（`LoadingProgress`）
- **下拉刷新**：拉动距离 → 刷新指示器旋转

### 5. 响应式布局

#### 5.1 断点定义
| 断点 | 屏幕宽度 | 设备类型 | 布局方式 |
|------|---------|---------|---------|
| sm   | 0-600vp | 手机竖屏 | 单列布局 |
| md   | 600-840vp | 手机横屏/小平板 | 双列布局 |
| lg   | 840vp+ | 大平板/折叠屏 | 三列或侧边栏布局 |

#### 5.2 自适应策略
- **手机竖屏（sm）**：
  - 单列文件列表
  - 全屏编辑器
  - 底部工具栏
  
- **手机横屏（md）**：
  - 文件列表占 30% 宽度
  - 编辑器占 70% 宽度
  
- **平板（lg）**：
  - 侧边栏文件导航（200vp）
  - 中间编辑区域（自适应）
  - 右侧工具面板（可选，200vp）

```typescript
GridRow({ columns: 12, gutter: 16 }) {
  GridCol({ span: { sm: 12, md: 6, lg: 4 } }) {
    FileCard()
  }
}
```

---

## ⚙️ 技术规范

### 1. 架构设计

#### 1.1 目录结构
```
entry/src/main/ets/
├── pages/                    # 页面
│   ├── Index.ets            # 启动页
│   ├── CodeEditor.ets       # 编辑器主页
│   ├── FileList.ets         # 文件列表页
│   └── Settings.ets         # 设置页
├── components/              # 组件
│   ├── SyntaxHighlighter.ets   # 语法高亮组件
│   ├── FileCard.ets            # 文件卡片
│   ├── TabBar.ets              # 标签栏
│   ├── CodeLineNumbers.ets     # 行号组件
│   └── ThemePicker.ets         # 主题选择器
├── services/                # 服务层
│   ├── FileService.ets         # 文件操作服务
│   ├── HighlightService.ets    # 高亮服务
│   ├── ThemeService.ets        # 主题服务
│   └── StorageService.ets      # 本地存储服务
├── models/                  # 数据模型
│   ├── FileModel.ets           # 文件模型
│   ├── ThemeModel.ets          # 主题模型
│   └── EditorConfig.ets        # 编辑器配置
├── utils/                   # 工具类
│   ├── SyntaxParser.ets        # 语法解析器
│   ├── FileUtils.ets           # 文件工具
│   └── ColorUtils.ets          # 颜色工具
└── constants/               # 常量
    ├── ThemeConstants.ets      # 主题常量
    └── LanguageConstants.ets   # 语言常量
```

#### 1.2 组件设计原则
- **单一职责**：每个组件只负责一个功能
- **可复用**：组件应该可在不同场景复用
- **解耦合**：组件之间低耦合，高内聚
- **状态管理**：合理使用 `@State`、`@Prop`、`@Link`

### 2. 核心 API 使用

#### 2.1 文件操作
```typescript
// 使用 @kit.CoreFileKit
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';

// 打开文件
const documentPicker = new picker.DocumentViewPicker();
const result = await documentPicker.select({
  maxSelectNumber: 1
});

// 读取文件
const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
const arrayBuffer = new ArrayBuffer(1048576);
const readLen = fileIo.readSync(file.fd, arrayBuffer);

// 保存文件
const file = fileIo.openSync(uri, fileIo.OpenMode.WRITE_ONLY);
fileIo.writeSync(file.fd, buffer.buffer);
fileIo.closeSync(file);
```

#### 2.2 UI 组件
```typescript
// TextArea - 代码编辑器
TextArea({ text: $$this.fileContent })
  .width('100%')
  .height('100%')
  .fontSize(15)
  .fontFamily('Consolas, Monaco, monospace')
  .fontColor('#d4d4d4')
  .backgroundColor('#1e1e1e')
  .caretColor('#528bff')

// List - 文件列表
List({ space: 12 }) {
  ForEach(this.files, (file: FileModel) => {
    ListItem() {
      FileCard({ file: file })
    }
  })
}

// Tabs - 多标签
Tabs({ barPosition: BarPosition.Start }) {
  ForEach(this.openFiles, (file: FileModel) => {
    TabContent() {
      CodeEditor({ file: file })
    }
    .tabBar(file.name)
  })
}
```

#### 2.3 动画 API
```typescript
// animateTo - 显式动画
animateTo({ 
  duration: 300, 
  curve: Curve.EaseOut 
}, () => {
  this.scale = 1.2;
});

// animation - 属性动画
Text('Hello')
  .scale({ x: this.scale, y: this.scale })
  .animation({
    duration: 300,
    curve: Curve.EaseInOut
  })

// 转场动画
transition({
  type: TransitionType.Insert,
  opacity: 0,
  translate: { x: -200 }
})
```

### 3. 性能优化

#### 3.1 编辑器性能
- **虚拟滚动**：大文件只渲染可见行
- **语法高亮优化**：使用 Web Worker 进行高亮计算
- **节流防抖**：输入事件使用防抖（300ms）
- **懒加载**：文件列表使用 `LazyForEach`

#### 3.2 内存管理
- **文件大小限制**：单文件最大 10MB
- **标签数量限制**：最多同时打开 10 个文件
- **历史记录限制**：保留最近 20 个文件
- **及时释放资源**：关闭文件时清理内存

#### 3.3 渲染优化
- **使用 renderGroup**：提升动画性能
- **避免频繁重渲染**：合理使用 `@State` 和 `@Watch`
- **图片优化**：使用合适的图片格式和尺寸
- **减少布局层级**：避免过深的嵌套

### 4. 数据存储

#### 4.1 本地存储方案
```typescript
import preferences from '@ohos.data.preferences';

// 保存设置
const pref = await preferences.getPreferences(context, 'settings');
await pref.put('theme', 'dark');
await pref.flush();

// 读取设置
const theme = await pref.get('theme', 'light');
```

#### 4.2 存储内容
- **用户设置**：主题、字体大小、自动保存间隔等
- **最近文件**：文件路径列表
- **编辑状态**：光标位置、滚动位置
- **自定义配置**：快捷键、代码片段

---

## 🚀 开发计划

### 第一阶段：MVP 核心功能（2周）
- [x] 项目架构搭建
- [x] 启动页设计与实现
- [x] 基础编辑器功能（TextArea）
- [x] 文件打开和保存
- [ ] 基础语法高亮（JavaScript/TypeScript）
- [ ] 简单主题切换（浅色/深色）

### 第二阶段：功能完善（2周）
- [ ] 多标签管理
- [ ] 文件列表页
- [ ] 更多语言支持（HTML/CSS/Python/Java）
- [ ] 代码行号显示
- [ ] 查找和替换功能
- [ ] 设置页面

### 第三阶段：体验优化（2周）
- [ ] 完善动画效果
- [ ] 响应式布局适配
- [ ] 性能优化
- [ ] 更多主题支持
- [ ] 代码自动缩进
- [ ] 括号匹配

### 第四阶段：高级功能（2周）
- [ ] 代码折叠
- [ ] 多光标编辑
- [ ] 代码片段
- [ ] Markdown 预览
- [ ] 工具集成（格式化、编码转换）
- [ ] 云同步功能

### 第五阶段：测试与发布（1周）
- [ ] 单元测试
- [ ] 集成测试
- [ ] 性能测试
- [ ] 多设备适配测试
- [ ] 应用签名
- [ ] 应用商店发布

---

## 📱 兼容性要求

### 1. 系统要求
- **操作系统**：HarmonyOS NEXT 5.0+
- **API Level**：API 12+
- **设备类型**：
  - ✅ 手机（Phone）
  - ✅ 平板（Tablet）
  - ✅ 折叠屏（Foldable）
  - ⚠️ 智能穿戴（Wearable，功能受限）

### 2. 屏幕适配
- **最小屏幕宽度**：320vp
- **最大屏幕宽度**：1920vp
- **支持方向**：竖屏、横屏
- **像素密度**：适配 1x、2x、3x

### 3. 性能指标
- **启动时间**：< 2秒
- **文件打开**：< 1秒（< 1MB 文件）
- **滑动帧率**：≥ 60fps
- **内存占用**：< 200MB（无大文件打开时）

---

## 🔒 安全与隐私

### 1. 权限申请
- **读写文件**：`ohos.permission.READ_USER_STORAGE`
- **访问网络**：`ohos.permission.INTERNET`（云同步功能）

### 2. 数据安全
- **本地加密**：敏感配置使用加密存储
- **无追踪**：不收集用户个人信息
- **离线优先**：核心功能完全离线可用

---

## 📚 参考资料

### 1. 官方文档
- [HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/application-dev-guide-V5)
- [ArkTS 语言规范](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-get-started-V5)
- [ArkUI 组件参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/arkui-overview-V5)
- [HarmonyOS Design 设计规范](https://developer.huawei.com/consumer/cn/design/harmonyos-design/)

### 2. 知识库文档
- `harmonyos-knowledge/03-component-library.md` - ArkUI 组件库
- `harmonyos-knowledge/05-layout-examples.md` - 布局实战
- `harmonyos-knowledge/07-multi-device-development.md` - 多端适配
- `harmonyos-knowledge/11-animations.md` - 动画效果
- `harmonyos-knowledge/09-file-management.md` - 文件管理

### 3. 设计参考
- HarmonyOS 系统应用（备忘录、文件管理器）
- VS Code Mobile
- CodeEditor - Monaco Editor

---

## ✅ 验收标准

### 1. 功能完整性
- ✅ 所有核心功能正常工作
- ✅ 支持至少 5 种编程语言的语法高亮
- ✅ 多标签管理流畅
- ✅ 文件保存可靠

### 2. 性能表现
- ✅ 启动时间 < 2秒
- ✅ 滑动流畅，无卡顿
- ✅ 内存占用合理
- ✅ 无内存泄漏

### 3. 用户体验
- ✅ UI 美观现代
- ✅ 动画流畅自然
- ✅ 响应式布局完善
- ✅ 操作逻辑清晰

### 4. 代码质量
- ✅ 代码结构清晰
- ✅ 注释完整
- ✅ 符合 ArkTS 编码规范
- ✅ 通过静态代码检查

---

## 📝 更新日志

### v1.0.0（计划中）
- ✅ 基础编辑器功能
- ✅ 文件管理
- ✅ 语法高亮
- ✅ 主题切换
- ✅ 多标签管理

### 未来规划
- 🔮 代码提示和自动补全
- 🔮 Git 集成
- 🔮 插件系统
- 🔮 终端集成
- 🔮 远程编辑
- 🔮 协作编辑

---

**文档版本**：v1.0  
**创建日期**：2025-10-10  
**最后更新**：2025-10-10  
**负责人**：开发团队

