# API 最新实践和注意事项

> 本文档整理了 HarmonyOS Next 开发中的 API 最新实践、已废弃的 API 列表，以及推荐的替代方案。

---

## 目录
- [API 命名空间变更](#api-命名空间变更)
- [已废弃的 API](#已废弃的-api)
- [推荐的最新 API](#推荐的最新-api)
- [常见迁移场景](#常见迁移场景)
- [最佳实践建议](#最佳实践建议)

---

## API 命名空间变更

### ❌ 已废弃：@system 命名空间

HarmonyOS Next 中，所有 `@system` 命名空间的 API 都已废弃，必须使用 `@ohos` 命名空间。

```typescript
// ❌ 已废弃 - 不要使用
import router from '@system.router'
import prompt from '@system.prompt'
import file from '@system.file'

// ✅ 推荐 - 使用 @ohos
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import fs from '@ohos.file.fs'
```

---

## 已废弃的 API

### 1. 文件选择 API

#### ❌ @ohos.document (已废弃 API 9+)

```typescript
// ❌ 已废弃 - 会抛出异常
import document from '@ohos.document'

document.choose() // 已废弃
document.show()   // 已废弃
```

#### ✅ 推荐替代方案

```typescript
// ✅ 使用文件选择器 API
import picker from '@ohos.file.picker'

// 选择图片
const photoSelectOptions = new picker.PhotoSelectOptions()
photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
photoSelectOptions.maxSelectNumber = 5

const photoPicker = new picker.PhotoViewPicker()
const photoSelectResult = await photoPicker.select(photoSelectOptions)

console.info('选中的图片: ' + JSON.stringify(photoSelectResult.photoUris))
```

```typescript
// 选择文档
const documentSelectOptions = new picker.DocumentSelectOptions()
const documentPicker = new picker.DocumentViewPicker()
const documentSelectResult = await documentPicker.select(documentSelectOptions)

console.info('选中的文档: ' + JSON.stringify(documentSelectResult))
```

### 2. Ability 相关 API

#### ❌ @ohos.ability.featureAbility (部分已废弃)

```typescript
// ❌ 已废弃的用法
import featureAbility from '@ohos.ability.featureAbility'

const context = featureAbility.getContext() // 不推荐
```

#### ✅ 推荐替代方案

```typescript
// ✅ 使用 UIAbility 的 context
import UIAbility from '@ohos.app.ability.UIAbility'
import common from '@ohos.app.ability.common'

// 在组件中获取 context
@Entry
@Component
struct MyComponent {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  
  build() {
    Column() {
      Button('使用 Context')
        .onClick(() => {
          // 使用最新的 context API
          const cacheDir = this.context.cacheDir
          console.info('缓存目录: ' + cacheDir)
        })
    }
  }
}
```

### 3. 提示 API

#### ❌ 旧的提示方法

```typescript
// ❌ 已废弃
import prompt from '@system.prompt'

prompt.showToast({ message: 'Hello' }) // 不推荐
```

#### ✅ 推荐替代方案

```typescript
// ✅ 使用 promptAction
import promptAction from '@ohos.promptAction'

promptAction.showToast({
  message: 'Hello',
  duration: 2000,
  bottom: 100
})

// 显示对话框
promptAction.showDialog({
  title: '提示',
  message: '这是一条消息',
  buttons: [
    { text: '取消', color: '#000000' },
    { text: '确定', color: '#1890ff' }
  ]
}).then((data) => {
  console.info('点击了按钮: ' + data.index)
})
```

---

## 推荐的最新 API

### 1. 路由导航

```typescript
// ✅ 推荐使用方式
import router from '@ohos.router'

// 页面跳转
router.pushUrl({
  url: 'pages/DetailPage',
  params: {
    id: 123,
    data: { name: '商品' }
  }
}, router.RouterMode.Standard)

// 页面返回
router.back()

// 替换页面
router.replaceUrl({
  url: 'pages/LoginPage'
})

// 获取参数
const params = router.getParams()
```

### 2. 数据存储

#### Preferences (首选项)

```typescript
// ✅ 最新用法
import dataPreferences from '@ohos.data.preferences'

// 获取 Preferences 实例
const preferences = await dataPreferences.getPreferences(context, 'myStore')

// 存储数据
await preferences.put('username', 'zhangsan')
await preferences.flush() // 持久化

// 读取数据
const username = await preferences.get('username', '')

// 删除数据
await preferences.delete('username')
await preferences.flush()
```

#### 关系型数据库

```typescript
// ✅ 最新用法
import relationalStore from '@ohos.data.relationalStore'

// 数据库配置
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'mydb.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

// 获取数据库实例
const store = await relationalStore.getRdbStore(context, STORE_CONFIG)

// 创建表
const createTableSql = `
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    age INTEGER
  )
`
await store.executeSql(createTableSql)

// 插入数据
const valueBucket: relationalStore.ValuesBucket = {
  name: 'zhangsan',
  age: 25
}
await store.insert('users', valueBucket)

// 查询数据
const predicates = new relationalStore.RdbPredicates('users')
predicates.equalTo('name', 'zhangsan')
const resultSet = await store.query(predicates)
```

### 3. 网络请求

```typescript
// ✅ 最新用法
import http from '@ohos.net.http'

// 创建 HTTP 请求
const httpRequest = http.createHttp()

// 发起 GET 请求
const response = await httpRequest.request('https://api.example.com/data', {
  method: http.RequestMethod.GET,
  header: {
    'Content-Type': 'application/json'
  },
  expectDataType: http.HttpDataType.STRING,
  connectTimeout: 60000,
  readTimeout: 60000
})

console.info('响应: ' + response.result)

// 发起 POST 请求
const postResponse = await httpRequest.request('https://api.example.com/data', {
  method: http.RequestMethod.POST,
  header: {
    'Content-Type': 'application/json'
  },
  extraData: JSON.stringify({ key: 'value' })
})

// 销毁请求
httpRequest.destroy()
```

### 4. 文件操作

```typescript
// ✅ 最新用法
import fs from '@ohos.file.fs'

// 打开文件
const file = fs.openSync('/path/to/file.txt', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)

// 写入文件
const writeLen = fs.writeSync(file.fd, 'Hello World')
console.info(`写入 ${writeLen} 字节`)

// 读取文件
const arrayBuffer = new ArrayBuffer(1024)
const readLen = fs.readSync(file.fd, arrayBuffer)
const content = String.fromCharCode(...new Uint8Array(arrayBuffer.slice(0, readLen)))
console.info('文件内容: ' + content)

// 关闭文件
fs.closeSync(file)

// 文件信息
const stat = fs.statSync('/path/to/file.txt')
console.info(`文件大小: ${stat.size} 字节`)

// 创建目录
fs.mkdirSync('/path/to/directory')

// 列出目录
const files = fs.listFileSync('/path/to/directory')
console.info('文件列表: ' + JSON.stringify(files))
```

### 5. Web 组件

```typescript
// ✅ 最新用法
import web_webview from '@ohos.web.webview'

@Entry
@Component
struct WebPage {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  build() {
    Column() {
      Web({ src: 'https://www.example.com', controller: this.webviewController })
        .width('100%')
        .height('100%')
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onPageBegin((event) => {
          console.info('页面开始加载: ' + event.url)
        })
        .onPageEnd((event) => {
          console.info('页面加载完成: ' + event.url)
        })
    }
  }
  
  // 调用 JavaScript
  async callJS() {
    const result = await this.webviewController.runJavaScript('document.title')
    console.info('页面标题: ' + result)
  }
  
  // 刷新页面
  refresh() {
    this.webviewController.refresh()
  }
  
  // 前进后退
  goBack() {
    if (this.webviewController.accessBackward()) {
      this.webviewController.backward()
    }
  }
}
```

### 6. 通知

```typescript
// ✅ 最新用法
import notificationManager from '@ohos.notificationManager'

// 发送基础通知
const notificationRequest: notificationManager.NotificationRequest = {
  id: 1,
  content: {
    contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
    normal: {
      title: '通知标题',
      text: '通知内容'
    }
  }
}

await notificationManager.publish(notificationRequest)

// 取消通知
await notificationManager.cancel(1)

// 取消所有通知
await notificationManager.cancelAll()

// 检查通知权限
const isEnabled = await notificationManager.isNotificationEnabled()
```

### 7. 后台任务

```typescript
// ✅ 最新用法
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'

// 申请延迟挂起
const delayInfo = await backgroundTaskManager.requestSuspendDelay('数据同步', () => {
  console.warn('延迟即将到期')
})

// 取消延迟挂起
backgroundTaskManager.cancelSuspendDelay(delayInfo.requestId)

// 长时任务
import wantAgent from '@ohos.app.ability.wantAgent'

const wantAgentInfo: wantAgent.WantAgentInfo = {
  wants: [{
    bundleName: 'com.example.app',
    abilityName: 'EntryAbility'
  }],
  requestCode: 0,
  operationType: wantAgent.OperationType.START_ABILITY,
  wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
}

const agent = await wantAgent.getWantAgent(wantAgentInfo)

await backgroundTaskManager.startBackgroundRunning(
  context,
  backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
  agent
)
```

---

## 常见迁移场景

### 场景 1: 从 @system 迁移到 @ohos

#### 迁移前
```typescript
import router from '@system.router'
import prompt from '@system.prompt'
import file from '@system.file'
import storage from '@system.storage'

// 路由跳转
router.push({ uri: 'pages/detail' })

// 显示提示
prompt.showToast({ message: 'Hello' })

// 文件操作
file.writeText({
  uri: 'internal://app/test.txt',
  text: 'Hello World'
})

// 存储数据
storage.set({ key: 'name', value: 'zhangsan' })
```

#### 迁移后
```typescript
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import fs from '@ohos.file.fs'
import dataPreferences from '@ohos.data.preferences'

// 路由跳转
router.pushUrl({ url: 'pages/detail' })

// 显示提示
promptAction.showToast({ message: 'Hello' })

// 文件操作
const file = fs.openSync('/path/to/file.txt', fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE)
fs.writeSync(file.fd, 'Hello World')
fs.closeSync(file)

// 存储数据
const preferences = await dataPreferences.getPreferences(context, 'myStore')
await preferences.put('name', 'zhangsan')
await preferences.flush()
```

### 场景 2: 文件选择器迁移

#### 迁移前
```typescript
import document from '@ohos.document'

// ❌ 已废弃
document.choose({
  success: (uri) => {
    console.info('选中文件: ' + uri)
  }
})
```

#### 迁移后
```typescript
import picker from '@ohos.file.picker'

// ✅ 推荐
// 选择图片
const photoSelectOptions = new picker.PhotoSelectOptions()
photoSelectOptions.maxSelectNumber = 5
const photoPicker = new picker.PhotoViewPicker()
const result = await photoPicker.select(photoSelectOptions)

console.info('选中图片: ' + JSON.stringify(result.photoUris))

// 选择文档
const documentSelectOptions = new picker.DocumentSelectOptions()
const documentPicker = new picker.DocumentViewPicker()
const docResult = await documentPicker.select(documentSelectOptions)

console.info('选中文档: ' + JSON.stringify(docResult))
```

### 场景 3: Context 获取方式

#### 迁移前
```typescript
import featureAbility from '@ohos.ability.featureAbility'

// ❌ 不推荐
const context = featureAbility.getContext()
```

#### 迁移后
```typescript
import common from '@ohos.app.ability.common'

// ✅ 在组件中
@Entry
@Component
struct MyComponent {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  
  build() {
    Column() {
      Button('获取应用信息')
        .onClick(() => {
          const bundleName = this.context.applicationInfo.name
          const cacheDir = this.context.cacheDir
          console.info(`应用名: ${bundleName}, 缓存目录: ${cacheDir}`)
        })
    }
  }
}

// ✅ 在 UIAbility 中
import UIAbility from '@ohos.app.ability.UIAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    // 直接使用 this.context
    const filesDir = this.context.filesDir
    console.info('文件目录: ' + filesDir)
  }
}
```

---

## 最佳实践建议

### 1. API 版本检查

```typescript
// ✅ 检查 API 版本
import deviceInfo from '@ohos.deviceInfo'

const sdkApiVersion = deviceInfo.sdkApiVersion
console.info('当前 API 版本: ' + sdkApiVersion)

if (sdkApiVersion >= 12) {
  // 使用 API 12 的新特性
} else {
  // 使用兼容方案
}
```

### 2. 导入规范

```typescript
// ✅ 推荐的导入方式
import router from '@ohos.router'                          // 路由
import promptAction from '@ohos.promptAction'              // 提示
import http from '@ohos.net.http'                         // 网络
import fs from '@ohos.file.fs'                            // 文件系统
import dataPreferences from '@ohos.data.preferences'       // 首选项
import relationalStore from '@ohos.data.relationalStore'   // 数据库
import notificationManager from '@ohos.notificationManager' // 通知
import web_webview from '@ohos.web.webview'               // Web组件
import common from '@ohos.app.ability.common'             // 通用能力
```

### 3. 错误处理

```typescript
// ✅ 推荐的错误处理方式
import { BusinessError } from '@ohos.base'

async function loadData() {
  try {
    const response = await http.createHttp().request('https://api.example.com/data')
    console.info('数据加载成功: ' + response.result)
  } catch (err) {
    const error = err as BusinessError
    console.error(`错误码: ${error.code}, 错误信息: ${error.message}`)
  }
}
```

### 4. 异步操作

```typescript
// ✅ 推荐使用 async/await
async function performTask() {
  try {
    // 数据存储
    const preferences = await dataPreferences.getPreferences(context, 'myStore')
    await preferences.put('key', 'value')
    await preferences.flush()
    
    // 网络请求
    const httpRequest = http.createHttp()
    const response = await httpRequest.request('https://api.example.com/data')
    
    // 文件操作
    const content = await fs.readText('/path/to/file.txt')
    
    console.info('所有操作完成')
  } catch (err) {
    console.error('操作失败: ' + JSON.stringify(err))
  }
}
```

### 5. 资源释放

```typescript
// ✅ 及时释放资源
@Entry
@Component
struct MyComponent {
  private httpRequest: http.HttpRequest | null = null
  private timer: number = -1
  
  aboutToAppear() {
    this.httpRequest = http.createHttp()
    this.timer = setInterval(() => {
      console.info('定时任务')
    }, 1000)
  }
  
  aboutToDisappear() {
    // 清理资源
    if (this.httpRequest) {
      this.httpRequest.destroy()
      this.httpRequest = null
    }
    
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }
  
  build() {
    Column() {
      Text('组件内容')
    }
  }
}
```

---

## API 更新检查清单

在更新或审查代码时，请检查以下项目：

### 必须检查项
- [ ] 是否使用了 `@system` 命名空间？（必须替换为 `@ohos`）
- [ ] 是否使用了 `@ohos.document`？（已废弃，使用 picker）
- [ ] 是否使用了 `featureAbility.getContext()`？（使用 getContext(this)）
- [ ] 文件操作是否使用了旧的 API？（使用 @ohos.file.fs）
- [ ] 提示是否使用了 `prompt`？（使用 promptAction）

### 推荐检查项
- [ ] 是否正确处理了异步操作？（使用 async/await）
- [ ] 是否正确处理了错误？（try-catch）
- [ ] 是否及时释放了资源？（destroy, close, clear）
- [ ] 是否使用了合适的数据存储方案？
- [ ] 是否遵循了最新的命名规范？

---

## 参考资源

### 官方文档
- [HarmonyOS 开发者官网](https://developer.harmonyos.com/)
- [API 参考文档](https://developer.harmonyos.com/cn/docs/documentation)
- [文档升级公告](https://device.harmonyos.com/cn/docs-update-notice/)

### 迁移指南
- [从 FA 模型迁移到 Stage 模型](https://developer.harmonyos.com/cn/docs/documentation)
- [API 变更说明](https://developer.harmonyos.com/cn/docs/documentation)

---

**本文档持续更新，请定期查看最新版本！** 🔄

*最后更新: 2025-10-10*

