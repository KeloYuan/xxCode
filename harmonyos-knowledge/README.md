# HarmonyOS Next 开发知识库

这是一个完整的 HarmonyOS Next 开发知识库，包含丰富的代码示例和最佳实践。所有示例基于 HarmonyOS Next 纯血鸿蒙系统和 ArkTS 开发语言。

## 🔍 快速索引

**💡 想快速找到某个功能或组件？**

👉 查看 **[完整知识库索引](00-INDEX.md)** - 包含 200+ 代码示例的详细目录和快速查找表

- 📑 按功能查找（UI、交互、数据、网络等）
- 🎨 按组件查找（50+ 组件完整索引）
- 🏷️ 按装饰器查找（所有状态管理装饰器）
- 🔧 按 API 查找（网络、文件、路由、动画等）
- 📝 代码示例索引（200+ 可复制示例）
- 🎓 学习路线图（21天完整学习计划）

## 📚 知识库目录

### 🎯 基础知识
- **[01-HarmonyOS Next 概览](01-harmonyos-next-overview.md)**
  - 什么是 HarmonyOS Next
  - 项目结构详解
  - 生命周期管理
  - 装饰器速查表
  - 开发工具介绍

- **[02-ArkTS 基础语法](02-arkts-basics.md)**
  - 变量和类型
  - 类和继承
  - 函数和高阶函数
  - 异步编程（Promise、Async/Await）
  - 泛型
  - 模块化
  - 装饰器

### 🎨 UI 开发
- **[03-组件库完整参考](03-component-library.md)** ✅
  - 基础组件（Text、Image、Button 等）
  - 高级组件（Marquee、TextClock、QRCode、Gauge 等）
  - 容器组件（WaterFlow、Refresh、SideBarContainer 等）
  - 表单组件（Rating、Select、Radio 等）
  - 完整示例和最佳实践

- **[04-状态管理详解](04-state-management.md)** ✅
  - @State / @Prop / @Link 完整用法
  - @Provide / @Consume 跨层级传递
  - @Observed / @ObjectLink 复杂对象管理
  - @Watch 状态监听
  - AppStorage / LocalStorage / PersistentStorage
  - 最佳实践和性能优化

- **[05-布局实战示例](05-layout-examples.md)** ✅
  - 卡片式布局
  - 顶部标题栏
  - 底部导航栏
  - 左右分栏布局
  - 网格布局
  - 瀑布流布局
  - 头部折叠布局
  - 固定底部按钮
  - 悬浮操作按钮
  - 响应式布局

- **[06-列表和网格实战](06-list-grid-examples.md)** ✅
  - 基础列表
  - 带图标列表
  - 滑动删除
  - 下拉刷新和上拉加载
  - 分组列表
  - 多选列表
  - 图片网格（相册）
  - LazyForEach 懒加载

- **[07-一次开发多端部署](07-multi-device-development.md)** ✅ **新增**
  - 响应式布局（LayoutWeight、百分比、Flex）
  - 栅格系统（GridRow/GridCol、断点系统）
  - 自适应布局（MediaQuery、断点监听）
  - 资源限定词（设备类型、屏幕尺寸）
  - 设备类型判断和窗口信息
  - 完整实战案例（新闻应用、卡片列表）

### 🧭 导航与路由
- **[导航和路由完整指南](navigation-router.md)** ⚠️ 待创建
  - Router 路由跳转
  - Navigation 组件
  - 底部导航实现
  - 页面转场动画
  - 深度链接
  - 路由拦截器

### 🖐️ 手势交互
- **[13-手势交互](13-gestures.md)** ✅ **新增**
  - 基础手势（Tap、LongPress、Pan、Pinch、Rotation、Swipe）
  - 手势组合（GestureGroup、并行手势）
  - 可拖拽排序列表
  - 图片查看器（拖拽、缩放、旋转）
  - 滑动删除
  - 手势优先级

### 🎬 高级动画
- **[14-高级动画技巧](14-advanced-animations.md)** ✅ **新增**
  - 弹簧动画和曲线（springCurve、responsiveSpringMotion）
  - 贝塞尔曲线（cubicBezierCurve）
  - 关键帧动画
  - 动画链和并行
  - 自定义动画控制器
  - 动画性能优化

### 🌐 数据与网络
- **[08-网络请求与 HTTP](08-network-http.md)** ✅ **包含官方示例**
  - HTTP 基础请求（GET、POST、PUT、DELETE）
  - 带 Token 的请求
  - 文件上传/下载
  - 新闻应用完整示例（FluentNewsHomepage 官方示例）
  - 请求拦截器
  - 错误处理

- **[09-文件管理](09-file-management.md)** ✅ **包含官方示例**
  - 应用沙箱目录
  - 文件读写操作
  - 目录操作
  - **用户目录文件生成（GeneratingUserDirectoryEnvironmentFile 官方示例）**
  - 文件选择器
  - 文件下载保存

- **[10-数据存储方案](10-data-storage.md)** ⚠️ 待创建
  - Preferences（首选项）
  - RelationalStore（关系型数据库）
  - KV 存储
  - 数据加密

### 🎭 进阶主题
- **[10-自定义弹窗](10-custom-dialogs.md)** ✅ **包含官方示例**
  - CustomDialog 自定义弹窗（CustomDialogGathers 官方示例）
  - bindContentCover 全屏模态
  - bindSheet 半模态
  - ActionSheet 操作列表
  - AlertDialog 系统弹窗
  - Toast 提示

- **[11-动画效果实战](11-animations.md)** ✅
  - animateTo 显式动画
  - animation 属性动画
  - 弹簧动画
  - 页面转场
  - 组件转场
  - 共享元素转场
  - 列表动画
  - 下拉刷新动画
  - 路径动画
  - 粒子动画

- **[11-性能优化实践](11-performance-optimization.md)** ⚠️ 待创建
  - 渲染性能优化
  - LazyForEach 懒加载
  - 组件复用
  - 内存优化
  - 网络性能

- **[12-常用开发模式](12-common-patterns.md)** ⚠️ 待创建
  - MVVM 模式
  - 单例模式
  - 工厂模式
  - 观察者模式
  - 事件总线

### 🚀 实战项目
- **[12-完整应用示例](12-complete-examples.md)** ✅
  - **待办事项应用**（数据持久化、CRUD 操作）
  - **天气应用**（网络请求、数据展示）
  - **购物车应用**（状态管理、购物车逻辑）

## 🎯 官方示例集成

本知识库整合了以下 HarmonyOS 官方示例：

### ✅ 已整合
1. **GeneratingUserDirectoryEnvironmentFile** - 用户目录文件生成
   - 文档：[09-文件管理](09-file-management.md)
   - 功能：在文档/下载/桌面目录生成文件
   - 包含完整权限配置和实现代码

2. **FluentNewsHomepage** - 新闻类首页
   - 文档：[08-网络请求与 HTTP](08-network-http.md)
   - 功能：地址选择、动态图标、下拉刷新、上拉加载
   - 包含网络请求、列表渲染、数据模型

3. **CustomDialogGathers** - 自定义弹窗集合
   - 文档：[10-自定义弹窗](10-custom-dialogs.md)
   - 功能：CustomDialog、全屏模态、半模态转场
   - 9种不同类型弹窗示例

### 📝 待整合
4. **MultiTravelAccommodation** - 响应式布局
   - 功能：栅格布局、多场景响应式

5. **Accountkit-Samplecode-Clientdemo-ArkTS** - 华为账号服务
   - 功能：一键登录、静默登录、获取用户信息

6. **CoreVisionKit-SampleCode-ArkTS-OcrDemo** - OCR 文字识别
   - 功能：图像转文字

## 🎓 学习路径

### 新手入门（1-2 周）
1. ✅ [HarmonyOS Next 概览](01-harmonyos-next-overview.md) - 了解基本概念
2. ✅ [ArkTS 基础语法](02-arkts-basics.md) - 掌握开发语言
3. ✅ [组件库完整参考](03-component-library.md) - 熟悉常用组件
4. ✅ [状态管理详解](04-state-management.md) - 理解响应式编程

### 进阶学习（2-3 周）
5. ✅ [布局实战示例](05-layout-examples.md) - 学习布局技巧
6. ✅ [列表和网格](06-list-grid-examples.md) - 掌握列表开发
7. ✅ [一次开发多端部署](07-multi-device-development.md) - 多设备适配
8. ✅ [网络请求](08-network-http.md) - 学习数据交互
9. ✅ [文件管理](09-file-management.md) - 掌握文件操作

### 高级应用（3-4 周）
10. ✅ [自定义弹窗](10-custom-dialogs.md) - 实现交互效果
11. ✅ [动画效果](11-animations.md) - 基础动画
12. ✅ [手势交互](13-gestures.md) - 手势和拖拽
13. ✅ [高级动画技巧](14-advanced-animations.md) - 进阶动画
14. ✅ [完整应用示例](12-complete-examples.md) - 综合实战

## 💡 快速开始

### 环境准备
1. 下载安装 [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio)
2. 配置 HarmonyOS SDK
3. 创建第一个项目
4. 连接模拟器或真机

### 第一个应用
```typescript
@Entry
@Component
struct HelloWorld {
  @State message: string = 'Hello HarmonyOS Next'

  build() {
    Column() {
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      Button('点击我')
        .onClick(() => {
          this.message = 'Hello World!'
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 📖 使用说明

### 代码示例特点
- ✅ **完整可运行** - 所有示例都是完整的，可直接复制使用
- ✅ **详细注释** - 关键代码都有清晰的注释说明
- ✅ **最佳实践** - 遵循 HarmonyOS 官方开发规范
- ✅ **实战导向** - 基于真实应用场景

### 如何使用
1. **按需学习** - 根据目录选择需要的章节
2. **动手实践** - 复制示例代码到项目中运行
3. **举一反三** - 理解原理后自己扩展
4. **参考文档** - 遇到问题查阅官方文档

## 📚 官方资源

### 开发者网站
- [华为开发者联盟](https://developer.huawei.com/)
- [HarmonyOS 官网](https://www.harmonyos.com/)
- [DevEco Studio 下载](https://developer.harmonyos.com/cn/develop/deveco-studio)

### 文档和社区
- [API 参考文档](https://developer.harmonyos.com/cn/docs/documentation)
- [HarmonyOS Design 设计规范](https://developer.harmonyos.com/cn/design/)
- [官方示例仓库](https://gitee.com/harmonyos_samples)
- [开发者论坛](https://developer.huawei.com/consumer/cn/forum/home)
- [鸿蒙应用开发资讯站](https://harmonyos.io/)

## 🔄 更新日志

### 2025-10-09 初始版本
- ✅ 创建知识库框架
- ✅ 完成基础知识文档（01-02）
- ✅ 完成布局实战（05）
- ✅ 完成列表和网格（06）
- ✅ 完成网络请求（08，整合 FluentNewsHomepage 官方示例）
- ✅ 完成文件管理（09，整合 GeneratingUserDirectoryEnvironmentFile 官方示例）
- ✅ 完成自定义弹窗（10，整合 CustomDialogGathers 官方示例）
- ✅ 完成动画效果（11）
- ✅ 完成完整应用示例（12）

### 2025-10-09 深度优化版
- ✅ **新增** 组件库完整参考（03）- 20+高级组件详解
- ✅ **新增** 状态管理详解（04）- 完整的状态管理体系
- ✅ **新增** 一次开发多端部署（07）- 响应式布局、栅格系统、媒体查询
- ✅ **新增** 手势交互（13）- 6种基础手势 + 高级应用
- ✅ **新增** 高级动画技巧（14）- 弹簧曲线、关键帧、性能优化

### 待完成
- ⚠️ 导航和路由
- ⚠️ 数据存储方案（10-data-storage）
- ⚠️ 性能优化详解
- ⚠️ 常用开发模式
- ⚠️ 整合更多官方示例

## 💬 贡献

欢迎提交 Issue 和 Pull Request 来完善这个知识库！

## 📄 许可证

本知识库内容遵循 MIT 许可证。

---

**开始你的 HarmonyOS Next 开发之旅吧！🚀**
