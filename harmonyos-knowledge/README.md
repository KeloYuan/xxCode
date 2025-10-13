# HarmonyOS Next 开发知识库

这是一个完整的 HarmonyOS Next 开发知识库，包含丰富的代码示例和最佳实践。所有示例基于 HarmonyOS Next 纯血鸿蒙系统和 ArkTS 开发语言。

## 🔍 快速索引

**💡 想快速找到某个功能或组件？**

👉 查看 **[完整知识库索引](00-INDEX.md)** - 包含 400+ 代码示例的详细目录和快速查找表

- 📑 按功能查找（UI、交互、数据、网络、传感器、国际化、架构等）
- 🎨 按组件查找（70+ 组件完整索引）
- 🏷️ 按装饰器查找（所有状态管理装饰器）
- 🔧 按 API 查找（网络、文件、路由、动画、设备能力等）
- 📝 代码示例索引（400+ 可复制示例）
- 🎓 学习路线图（完整企业级开发体系）

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
- **[15-导航和路由完整指南](15-navigation-router.md)** ✅ **新增**
  - Router 页面路由跳转
  - Navigation 组件导航
  - 底部导航栏实现
  - Tab 页签导航
  - 页面转场动画
  - 共享元素转场
  - 路由拦截器和守卫
  - 深度链接处理

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

- **[16-数据存储方案](16-data-storage.md)** ✅ **新增**
  - Preferences 首选项存储
  - RelationalStore 关系型数据库
  - KV 键值存储
  - 数据加密
  - 文件存储
  - 数据备份和恢复
  - 完整笔记应用示例

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

- **[17-性能优化实践](17-performance-optimization.md)** ✅ **新增**
  - 渲染性能优化技巧
  - LazyForEach 懒加载详解
  - @Reusable 组件复用
  - 内存优化策略
  - 网络性能优化
  - 启动优化
  - 动画性能优化
  - 性能监控工具

- **[18-Web 组件使用指南](18-web-component.md)** ✅ **新增**
  - Web 组件基础使用
  - 网页加载和进度控制
  - JavaScript 与 ArkTS 互调
  - 页面导航控制
  - Cookie 和缓存管理
  - 文件上传下载
  - 调试和错误处理
  - 完整浏览器示例

- **[19-通知和后台任务](19-notification-background.md)** ✅ **新增**
  - 本地通知发送
  - 多种通知样式
  - 通知操作和管理
  - 通知权限请求
  - 短时后台任务
  - 长时后台任务
  - WorkScheduler 定时任务
  - 完整待办提醒示例

- **[20-API 最新实践和注意事项](20-api-best-practices.md)** ✅ **重要**
  - API 命名空间变更 (@system → @ohos)
  - 已废弃的 API 清单
  - 推荐的最新 API 用法
  - 常见迁移场景
  - 最佳实践建议
  - API 更新检查清单

### 🌟 高级主题
- **[21-传感器和设备能力](21-sensor-device.md)** ✅ **新增**
  - 加速度传感器、陀螺仪、磁力计
  - 设备信息获取
  - 振动反馈控制
  - 屏幕亮度调节
  - 电池信息监听
  - 网络状态检测
  - 地理定位服务
  - 完整设备仪表盘示例

- **[22-国际化与本地化](22-i18n-localization.md)** ✅ **新增**
  - 多语言资源文件配置
  - 带参数的本地化字符串
  - 动态语言切换服务
  - 日期时间格式化（Intl API）
  - 数字货币格式化
  - 相对时间显示
  - RTL 布局支持
  - 完整多语言博客应用

- **[23-架构模式与设计模式](23-architecture-patterns.md)** ✅ **新增**
  - MVVM 架构详解（Model-View-ViewModel）
  - 单例模式（服务管理）
  - 工厂模式（对象创建）
  - 观察者模式（事件总线）
  - 策略模式（支付策略）
  - 依赖注入（DI 容器）
  - Repository 模式（数据仓库）
  - 完整应用架构示例

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
14. ✅ [导航和路由](15-navigation-router.md) - 页面导航
15. ✅ [数据存储](16-data-storage.md) - 数据持久化
16. ✅ [性能优化](17-performance-optimization.md) - 提升性能

### 企业级开发（4-6 周）
17. ✅ [Web 组件](18-web-component.md) - 混合开发
18. ✅ [通知和后台任务](19-notification-background.md) - 后台能力
19. ✅ [传感器和设备](21-sensor-device.md) - 设备能力
20. ✅ [国际化](22-i18n-localization.md) - 多语言支持
21. ✅ [架构模式](23-architecture-patterns.md) - 设计模式
22. ✅ [完整应用示例](12-complete-examples.md) - 综合实战

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

### 2025-10-10 第二次重大更新 🎉
- ✅ **21-传感器和设备能力** - 完整的设备硬件访问指南
  - 加速度传感器、陀螺仪、磁力计详解
  - 设备信息、振动、亮度控制
  - 电池、网络、定位等系统能力
  - 完整设备仪表盘应用示例
  
- ✅ **22-国际化与本地化** - 多语言应用开发
  - 资源文件配置和管理
  - 动态语言切换服务
  - Intl API 日期时间格式化
  - 数字货币格式化
  - RTL 布局支持
  - 完整多语言博客应用
  
- ✅ **23-架构模式与设计模式** - 企业级架构指南
  - MVVM 架构实战
  - 6+ 种设计模式详解
  - 依赖注入和 Repository 模式
  - 完整应用架构示例
  
- ✅ 更新索引文档，新增 3250+ 行代码
- ✅ 知识库达到 **23 个文档，20,000+ 行代码，400+ 示例**

### 2025-10-10 知识库大扩展 🚀
- ✅ **15-导航和路由** - 页面导航完整指南
- ✅ **16-数据存储方案** - 数据持久化全方案
- ✅ **17-性能优化实践** - 性能提升专题
- ✅ **18-Web 组件使用** - 混合开发指南
- ✅ **19-通知和后台任务** - 后台能力详解
- ✅ **20-API 最新实践** - API 更新和最佳实践
- ✅ 创建完整知识库索引（00-INDEX.md）
- ✅ API 审查报告（API_UPDATE_REPORT.md）

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
- ✅ **新增** Web 组件使用指南（18）- WebView、JS交互、浏览器实现
- ✅ **新增** 通知和后台任务（19）- 通知管理、后台任务、定时任务
- ✅ **新增** API 最新实践（20）- 废弃API清单、迁移指南、最佳实践

### 待完成
- ⚠️ 整合更多官方示例
- ⚠️ 安全和权限管理详解
- ⚠️ 音视频处理
- ⚠️ 蓝牙和 NFC
- ⚠️ 分布式能力

## 💬 贡献

欢迎提交 Issue 和 Pull Request 来完善这个知识库！

## 📄 许可证

本知识库内容遵循 MIT 许可证。

---

**开始你的 HarmonyOS Next 开发之旅吧！🚀**
