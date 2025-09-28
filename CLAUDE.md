# 鸿蒙代码编辑器 - 开发指南

## 项目概述

这是一个基于鸿蒙原生技术栈开发的专业代码编辑器应用，采用ArkTS语言和鸿蒙设计语言构建，提供流畅的原生编程体验。

### 技术栈
- **开发语言**: ArkTS/eTS
- **UI框架**: 鸿蒙原生组件
- **构建工具**: Hvigor
- **包管理**: oh-package
- **测试框架**: Hypium + Hamock

### 项目结构
```
entry/src/main/ets/
├── components/           # 可复用组件
│   ├── HighlightedText.ets    # 语法高亮文本编辑器
│   ├── MarkdownPreview.ets    # Markdown预览组件
│   └── SearchDialog.ets       # 搜索对话框
├── models/              # 数据模型
│   └── FileModel.ets          # 文件和标签页模型
├── pages/               # 页面
│   ├── Index.ets              # 主页面
│   └── CodeEditor.ets         # 代码编辑器主页面
└── services/            # 业务服务
    ├── FileService.ets        # 文件服务抽象
    ├── RealFileService.ets    # 真实文件系统服务
    ├── MarkdownService.ets    # Markdown处理服务
    ├── SearchService.ets      # 搜索服务
    ├── SyntaxHighlightService.ets  # 语法高亮服务
    └── ThemeService.ets       # 主题服务
```

## 开发命令

### 环境设置

```bash
# 检查鸿蒙开发环境
hdc version

# 检查设备连接
hdc list targets

# 安装依赖
npm install
```

### 构建命令

```bash
# 清理构建缓存
hvigor clean

# 开发构建
hvigor assembleHap

# 生产构建
hvigor assembleHap --mode release

# 增量构建
hvigor assembleHap --daemon

# 构建并安装到设备
hvigor installHapDebug

# 构建分析
hvigor assembleHap --scan
```

### 运行和调试

```bash
# 启动应用
hdc shell aa start -a EntryAbility -b com.example.codeeditor

# 停止应用
hdc shell aa force-stop com.example.codeeditor

# 查看日志
hdc hilog

# 过滤应用日志
hdc hilog | grep CodeEditor

# 清除日志
hdc hilog -r

# 实时日志监控
hdc hilog -w
```

### 代码质量检查

```bash
# 运行ESLint检查
npm run lint

# 自动修复代码风格
npm run lint:fix

# TypeScript类型检查
npm run type-check

# 代码格式化
npm run format
```

### 测试命令

```bash
# 运行所有单元测试
hvigor test

# 运行特定测试文件
hvigor test --tests "**/FileService.test.ets"

# 运行测试并生成覆盖率报告
hvigor test --coverage

# 运行UI测试
hvigor testOhosTest

# 持续测试模式
hvigor test --watch

# 测试结果输出到文件
hvigor test --reporter json > test-results.json
```

### 性能分析

```bash
# 性能分析构建
hvigor assembleHap --mode profile

# 内存使用分析
hdc shell hidumper -s all -a "-p [pid]"

# CPU使用分析
hdc shell top

# 启动时间分析
hdc shell hilog | grep "app start"

# 包大小分析
ls -la entry/build/default/outputs/default/*.hap

# 依赖分析
npm ls
npm audit
```

### 设备调试

```bash
# 查看设备信息
hdc shell getprop

# 查看应用信息
hdc shell bm dump -a com.example.codeeditor

# 查看文件系统权限
hdc shell ls -la /data/app/el2/100/base/com.example.codeeditor

# 推送文件到设备
hdc file send local_file /data/app/el2/100/base/com.example.codeeditor/

# 从设备拉取文件
hdc file recv /data/app/el2/100/base/com.example.codeeditor/remote_file ./

# 安装HAP包
hdc install entry/build/default/outputs/default/entry-default-signed.hap

# 卸载应用
hdc uninstall com.example.codeeditor
```

### 开发服务器

```bash
# 启动开发服务器（如果有）
npm run dev

# 启动预览服务
npm run preview

# 热重载开发
npm run dev:hot
```

## 功能测试

### 文件操作测试

```bash
# 测试文件选择器
echo "测试文件选择功能..."

# 测试文件读取
echo "测试大文件读取性能..."

# 测试文件保存
echo "测试文件保存功能..."

# 测试文件权限
hdc shell ls -la /storage/emulated/0/
```

### UI组件测试

```bash
# 测试语法高亮性能
echo "测试语法高亮渲染性能..."

# 测试标签页切换
echo "测试多标签页切换..."

# 测试主题切换
echo "测试主题切换功能..."

# 测试响应式布局
echo "测试不同屏幕尺寸适配..."
```

### 集成测试

```bash
# 端到端测试
hvigor integrationTest

# 性能基准测试
hvigor benchmarkTest

# 兼容性测试
hvigor compatibilityTest
```

## 发布和部署

### 打包发布

```bash
# 生成签名HAP包
hvigor assembleHap --mode release

# 验证HAP包
hdc install -s entry/build/default/outputs/default/entry-release-signed.hap

# 生成App包（如果需要）
hvigor assembleApp --mode release
```

### 版本管理

```bash
# 更新版本号
npm version patch
npm version minor
npm version major

# 创建发布标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## 故障排除

### 常见问题

```bash
# 清理项目
hvigor clean
rm -rf node_modules oh_modules
npm install

# 重置设备应用数据
hdc shell pm clear com.example.codeeditor

# 检查权限设置
hdc shell dumpsys permission com.example.codeeditor

# 查看崩溃日志
hdc hilog | grep -E "(CRASH|ERROR|Exception)"

# 内存泄漏检查
hdc shell dumpsys meminfo com.example.codeeditor
```

### 调试技巧

```bash
# 启用详细日志
export HILOG_LEVEL=DEBUG

# 性能监控
hdc shell perf record -p [pid] sleep 10
hdc shell perf report

# 网络调试（如果有网络功能）
hdc shell netstat -an

# ADB over WiFi（如果支持）
hdc tconn 192.168.1.100:8710
```

## 代码质量标准

### 编码规范

- 使用ArkTS官方编码规范
- 组件命名采用PascalCase
- 变量和方法命名采用camelCase
- 常量命名采用UPPER_SNAKE_CASE
- 文件名采用PascalCase

### 性能要求

- 应用启动时间 < 3秒
- 页面切换动画流畅（60fps）
- 内存使用 < 200MB
- 文件打开响应时间 < 1秒（100KB以下文件）

### 测试覆盖率

- 单元测试覆盖率 > 80%
- 核心功能集成测试覆盖率 100%
- UI组件测试覆盖率 > 70%

## 贡献指南

### 开发流程

1. Fork项目并创建特性分支
2. 编写代码并确保通过所有测试
3. 提交代码并创建Pull Request
4. 代码审查和合并

### 提交规范

```bash
# 提交格式
git commit -m "type(scope): description"

# 类型说明
feat: 新功能
fix: bug修复
docs: 文档更新
style: 代码格式调整
refactor: 重构
test: 测试相关
chore: 构建或配置相关
```

## 相关链接

- [鸿蒙开发者文档](https://developer.harmonyos.com/)
- [ArkTS语言指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-overview-0000001531611153)
- [鸿蒙设计规范](https://developer.harmonyos.com/cn/design/)
- [Hvigor构建工具](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/hvigor-overview-0000001524196217)
