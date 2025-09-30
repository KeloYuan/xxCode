# 鸿蒙原生代码编辑器

<div align="center">
  <h3>🚀 专为 HarmonyOS 5.0 打造的原生代码编辑器</h3>
  <p>融合代码编辑器和笔记本特性，提供流畅、高效的编程体验</p>
</div>

---

## ✨ 核心特性

### 🎨 现代化设计
- **HarmonyOS Design 语言**：遵循官方设计规范，界面美观流畅
- **深色/浅色主题**：支持主题切换，保护眼睛
- **优雅动画**：丰富的交互动画，提升使用体验
- **响应式布局**：完美适配各种屏幕尺寸

### 💻 强大的编辑功能
- **多语言支持**：JavaScript、TypeScript、Python、Java、C++、Go、Rust 等
- **语法高亮**：智能语法分析，清晰展示代码结构
- **代码补全**：智能代码提示，提高编码效率
- **实时预览**：Markdown 文件支持实时预览

### 📁 文件管理
- **多标签页**：同时编辑多个文件
- **文件选择器**：系统原生文件选择体验
- **自动保存**：定时自动保存，防止数据丢失
- **文件状态**：清晰标识已修改/未保存状态

### 🔍 搜索功能
- **全文搜索**：快速搜索文件内容
- **正则表达式**：支持正则表达式搜索
- **大小写敏感**：灵活的搜索选项
- **搜索历史**：保存常用搜索

## 🏗️ 技术架构

### 核心技术栈
- **开发语言**：ArkTS (HarmonyOS 原生开发语言)
- **UI 框架**：ArkUI 声明式 UI
- **系统版本**：HarmonyOS 5.0+
- **API 版本**：API 12

### 项目结构

```
xxCode/
├── entry/                          # 主模块
│   ├── src/
│   │   ├── main/
│   │   │   ├── ets/               # ArkTS 源码
│   │   │   │   ├── pages/         # 页面
│   │   │   │   │   ├── Index.ets          # 欢迎页
│   │   │   │   │   └── CodeEditor.ets     # 代码编辑器页
│   │   │   │   ├── components/    # 组件
│   │   │   │   │   ├── HighlightedText.ets    # 语法高亮组件
│   │   │   │   │   ├── MarkdownPreview.ets    # Markdown 预览组件
│   │   │   │   │   └── SearchDialog.ets       # 搜索对话框组件
│   │   │   │   ├── services/      # 服务层
│   │   │   │   │   ├── FileService.ets              # 文件服务接口
│   │   │   │   │   ├── RealFileService.ets          # 文件服务实现
│   │   │   │   │   ├── SyntaxHighlightService.ets   # 语法高亮服务
│   │   │   │   │   ├── MarkdownService.ets          # Markdown 服务
│   │   │   │   │   ├── SearchService.ets            # 搜索服务
│   │   │   │   │   ├── ThemeService.ets             # 主题服务
│   │   │   │   │   └── CodeCompletionService.ets    # 代码补全服务
│   │   │   │   ├── models/        # 数据模型
│   │   │   │   │   └── FileModel.ets       # 文件数据模型
│   │   │   │   └── entryability/  # 应用入口
│   │   │   │       └── EntryAbility.ets
│   │   │   └── resources/         # 资源文件
│   │   │       ├── base/          # 基础资源
│   │   │       │   ├── element/   # 颜色、字符串、尺寸
│   │   │       │   └── media/     # 图片资源
│   │   │       └── dark/          # 深色主题资源
│   │   └── module.json5           # 模块配置
│   └── build-profile.json5        # 构建配置
├── AppScope/                       # 应用全局配置
│   └── app.json5
├── build-profile.json5            # 项目构建配置
├── oh-package.json5               # 依赖配置
└── README.md                      # 本文件
```

### 架构设计

```
┌─────────────────────────────────────┐
│           UI Layer (ArkUI)          │
│   ┌─────────────┐ ┌─────────────┐   │
│   │   Pages     │ │ Components  │   │
│   └─────────────┘ └─────────────┘   │
├─────────────────────────────────────┤
│        Business Logic Layer         │
│   ┌─────────────┐ ┌─────────────┐   │
│   │   Services  │ │   Models    │   │
│   └─────────────┘ └─────────────┘   │
├─────────────────────────────────────┤
│       HarmonyOS System APIs         │
│   FileSystem    Storage    Picker   │
└─────────────────────────────────────┘
```

## 🚀 快速开始

### 环境要求
- **DevEco Studio**：5.0.0 或更高版本
- **HarmonyOS SDK**：API 12 或更高版本
- **Node.js**：建议 16.0.0 或更高版本

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/xxCode.git
   cd xxCode
   ```

2. **安装依赖**
   ```bash
   # 项目会自动下载依赖
   ```

3. **配置签名**
   - 在 DevEco Studio 中配置调试签名
   - 或使用自动签名功能

4. **运行项目**
   ```bash
   # 使用 DevEco Studio 运行
   # 或使用命令行
   hvigorw assembleHap
   ```

### 编译命令

```bash
# 清理构建
hvigorw clean

# 编译 HAP 包
hvigorw assembleHap --mode module

# 编译 Release 版本
hvigorw assembleHap --mode module -p product=default -p buildMode=release
```

## 📖 使用指南

### 基础操作

1. **打开文件**
   - 点击工具栏的 📁 按钮
   - 或在欢迎页点击"打开文件"

2. **新建文件**
   - 点击工具栏的 📄 按钮
   - 选择保存位置和文件名

3. **编辑代码**
   - 在编辑器中直接输入
   - 自动语法高亮显示
   - 支持代码补全

4. **保存文件**
   - 点击工具栏的 💾 按钮
   - 或等待自动保存（5分钟）

5. **切换主题**
   - 点击工具栏的 🎨 按钮
   - 循环切换不同主题

### 高级功能

#### Markdown 预览
- 打开 `.md` 文件
- 点击"预览"按钮切换预览模式
- 支持实时渲染

#### 搜索功能
- 点击工具栏的 🔍 按钮
- 输入搜索关键词
- 支持正则表达式和大小写敏感

#### 多标签页管理
- 同时打开多个文件
- 点击标签页切换文件
- 点击 × 关闭标签页

## 🎨 设计特色

### 颜色系统
- **主色调**：#007DFF（鸿蒙蓝）
- **语法高亮**：
  - 关键字：紫色 `#8B5CF6`
  - 字符串：绿色 `#10B981`
  - 注释：灰色 `#6B7280`
  - 数字：橙色 `#F59E0B`
  - 函数：蓝色 `#3B82F6`

### 动画效果
- 启动动画：渐显 + 缩放
- 页面切换：流畅过渡
- 按钮交互：按压反馈
- 动画时长：200-800ms

## 🔧 开发规范

### 代码规范
- 遵循 HarmonyOS ArkTS 编码规范
- 使用 `@Entry` 标记页面入口
- 使用 `@Component` 定义组件
- 使用 `@State` 管理状态

### 组件设计
- 高度可复用
- 清晰的接口定义
- 完善的错误处理
- 详细的注释说明

### 服务层设计
- 单一职责原则
- 接口与实现分离
- 异步操作使用 `async/await`
- 统一的错误处理

## 📝 开发计划

### 已完成 ✅
- [x] 项目基础架构
- [x] 文件管理功能
- [x] 语法高亮显示
- [x] Markdown 预览
- [x] 搜索功能
- [x] 主题切换
- [x] 自动保存

### 计划中 🚧
- [ ] Git 集成
- [ ] 代码格式化
- [ ] 更多语言支持
- [ ] 插件系统
- [ ] 云同步功能
- [ ] 协作编辑

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

### 参与方式
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码审查
- 确保代码符合项目规范
- 通过所有测试用例
- 添加必要的文档和注释

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- HarmonyOS 官方文档和示例
- DevEco Studio 开发工具
- 所有贡献者和支持者

## 📞 联系方式

- **问题反馈**：GitHub Issues
- **讨论交流**：GitHub Discussions
- **邮箱**：your-email@example.com

---

<div align="center">
  <p>用 ❤️ 打造的 HarmonyOS 原生应用</p>
  <p>⭐ 如果这个项目对你有帮助，请给我们一个星标！</p>
</div>

