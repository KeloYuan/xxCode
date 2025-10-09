# HarmonyOS Next 概览

## 什么是 HarmonyOS Next？

HarmonyOS Next 是华为推出的**纯血鸿蒙操作系统**，完全摆脱了 Android 代码，是真正意义上的自主操作系统。

### 核心特点

1. **纯鸿蒙内核** - 完全自研，不再兼容 Android
2. **分布式能力** - 多设备无缝协同
3. **高性能** - 优化的渲染引擎和资源管理
4. **全场景** - 手机、平板、手表、车机等全覆盖
5. **安全性** - 更严格的权限管理和数据保护

## 开发语言：ArkTS

ArkTS 是 TypeScript 的超集，专为 HarmonyOS 设计。

### 为什么选择 ArkTS？

```typescript
// ✅ 强类型系统
let count: number = 0
let message: string = "Hello"
let isActive: boolean = true

// ✅ 声明式 UI
@Entry
@Component
struct HelloWorld {
  build() {
    Text('Hello HarmonyOS')
      .fontSize(20)
      .fontColor(Color.Blue)
  }
}

// ✅ 装饰器语法
@State count: number = 0  // 响应式状态
@Prop title: string       // 属性传递
@Link data: Array<string> // 双向绑定
```

## 应用架构：Stage 模型

### UIAbility - 应用入口

```typescript
// EntryAbility.ets
import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    console.info('Ability onCreate')
  }

  onDestroy() {
    console.info('Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('Failed to load content')
        return
      }
      console.info('Succeeded in loading content')
    })
  }

  onForeground() {
    console.info('Ability onForeground')
  }

  onBackground() {
    console.info('Ability onBackground')
  }
}
```

## 项目结构

```
MyApp/
├── AppScope/              # 应用全局配置
│   └── app.json5         # 应用配置文件
├── entry/                # 主模块
│   ├── src/
│   │   ├── main/
│   │   │   ├── ets/      # ArkTS 源码
│   │   │   │   ├── entryability/
│   │   │   │   │   └── EntryAbility.ets
│   │   │   │   ├── pages/           # 页面
│   │   │   │   │   ├── Index.ets
│   │   │   │   │   └── Detail.ets
│   │   │   │   ├── components/      # 组件
│   │   │   │   ├── services/        # 服务层
│   │   │   │   └── models/          # 数据模型
│   │   │   └── resources/           # 资源文件
│   │   │       ├── base/
│   │   │       │   ├── element/
│   │   │       │   │   ├── string.json
│   │   │       │   │   ├── color.json
│   │   │       │   │   └── float.json
│   │   │       │   └── media/       # 图片资源
│   │   │       └── dark/            # 深色主题
│   │   └── module.json5             # 模块配置
│   └── oh-package.json5             # 依赖配置
└── oh_modules/                      # 依赖包
```

## 第一个应用

### 1. 创建页面

```typescript
// pages/Index.ets
@Entry
@Component
struct Index {
  @State message: string = 'Hello HarmonyOS Next'
  @State count: number = 0

  build() {
    Column({ space: 20 }) {
      // 标题
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
      
      // 计数显示
      Text(`点击次数: ${this.count}`)
        .fontSize(18)
      
      // 按钮
      Button('点击我')
        .width(200)
        .height(50)
        .onClick(() => {
          this.count++
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 2. 注册页面

```json5
// resources/base/profile/main_pages.json
{
  "src": [
    "pages/Index"
  ]
}
```

### 3. 配置应用

```json5
// AppScope/app.json5
{
  "app": {
    "bundleName": "com.example.myapp",
    "vendor": "example",
    "versionCode": 1000000,
    "versionName": "1.0.0",
    "icon": "$media:app_icon",
    "label": "$string:app_name"
  }
}
```

## 生命周期

### 页面生命周期

```typescript
@Entry
@Component
struct LifecyclePage {
  @State data: string = ''

  // 页面即将显示
  aboutToAppear() {
    console.info('页面即将显示')
    this.loadData()
  }

  // 页面已显示
  onPageShow() {
    console.info('页面已显示')
  }

  // 页面即将隐藏
  onPageHide() {
    console.info('页面即将隐藏')
  }

  // 页面即将销毁
  aboutToDisappear() {
    console.info('页面即将销毁')
    this.cleanup()
  }

  // 页面返回拦截
  onBackPress() {
    console.info('用户按下返回键')
    // 返回 true 拦截返回，false 不拦截
    return false
  }

  loadData() {
    // 加载数据
  }

  cleanup() {
    // 清理资源
  }

  build() {
    Column() {
      Text('生命周期示例')
    }
  }
}
```

### 组件生命周期

```typescript
@Component
struct CustomComponent {
  @State value: string = ''
  private timer: number = -1

  // 组件即将创建
  aboutToAppear() {
    console.info('组件即将创建')
    this.timer = setInterval(() => {
      console.info('定时任务')
    }, 1000)
  }

  // 组件即将销毁
  aboutToDisappear() {
    console.info('组件即将销毁')
    if (this.timer !== -1) {
      clearInterval(this.timer)
    }
  }

  build() {
    Text(this.value)
  }
}
```

## 常用装饰器速查

### 组件装饰器

| 装饰器 | 说明 | 示例 |
|--------|------|------|
| `@Entry` | 页面入口 | `@Entry @Component struct Index {}` |
| `@Component` | 自定义组件 | `@Component struct MyCard {}` |
| `@Preview` | 预览器预览 | `@Preview @Component struct Demo {}` |
| `@Reusable` | 可复用组件 | `@Reusable @Component struct Item {}` |

### 状态装饰器

| 装饰器 | 说明 | 示例 |
|--------|------|------|
| `@State` | 组件内状态 | `@State count: number = 0` |
| `@Prop` | 单向传递 | `@Prop title: string` |
| `@Link` | 双向绑定 | `@Link data: Array<string>` |
| `@Provide` | 跨层提供 | `@Provide('theme') theme: string` |
| `@Consume` | 跨层消费 | `@Consume('theme') theme: string` |
| `@Observed` | 可观察对象 | `@Observed class Person {}` |
| `@ObjectLink` | 对象链接 | `@ObjectLink person: Person` |
| `@Watch` | 状态监听 | `@State @Watch('onChange') value` |

### 全局状态装饰器

| 装饰器 | 说明 | 示例 |
|--------|------|------|
| `@StorageLink` | 应用级双向绑定 | `@StorageLink('user') user: string` |
| `@StorageProp` | 应用级单向传递 | `@StorageProp('theme') theme: string` |
| `@LocalStorageLink` | 页面级双向绑定 | `@LocalStorageLink('data') data: string` |
| `@LocalStorageProp` | 页面级单向传递 | `@LocalStorageProp('flag') flag: boolean` |

### 样式装饰器

| 装饰器 | 说明 | 示例 |
|--------|------|------|
| `@Styles` | 样式复用 | `@Styles function cardStyle() {}` |
| `@Extend` | 组件扩展 | `@Extend(Text) function fancy() {}` |
| `@Builder` | UI 构建器 | `@Builder itemBuilder() {}` |
| `@BuilderParam` | 构建器参数 | `@BuilderParam content: () => void` |

## 开发工具

### DevEco Studio

华为官方 IDE，基于 IntelliJ IDEA，提供：

- 代码提示和补全
- 实时预览
- 调试工具
- 性能分析
- 多设备模拟器

### ohpm - 包管理器

```bash
# 安装依赖
ohpm install

# 添加依赖
ohpm install @ohos/axios

# 查看依赖
ohpm list

# 更新依赖
ohpm update
```

### hvigor - 构建工具

```bash
# 构建项目
hvigorw assembleHap

# 清理构建
hvigorw clean

# 运行测试
hvigorw test
```

## 快速开始清单

### ✅ 环境准备
- [ ] 安装 DevEco Studio
- [ ] 配置 HarmonyOS SDK
- [ ] 创建项目
- [ ] 连接模拟器/真机

### ✅ 学习路径
1. [ ] 理解 ArkTS 基础语法
2. [ ] 掌握组件化开发
3. [ ] 学习状态管理
4. [ ] 熟悉路由导航
5. [ ] 掌握网络请求
6. [ ] 学习数据存储
7. [ ] 实战项目开发

### ✅ 实用资源
- [官方文档](https://developer.harmonyos.com/)
- [API 参考](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V3/development-intro-0000001053942228-V3)
- [示例代码](https://gitee.com/harmonyos)
- [开发者社区](https://developer.huawei.com/consumer/cn/forum/home)

## 下一步

继续学习 [ArkTS 基础语法](02-arkts-basics.md)

