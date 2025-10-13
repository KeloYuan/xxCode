# Web 组件使用指南

> 本文档详细介绍 HarmonyOS Next 中 Web 组件的使用，包括网页加载、JavaScript 交互、Cookie 管理等。

---

## 目录
- [基础使用](#基础使用)
- [网页加载](#网页加载)
- [JavaScript 交互](#javascript-交互)
- [页面导航控制](#页面导航控制)
- [Cookie 和缓存管理](#cookie-和缓存管理)
- [文件上传下载](#文件上传下载)
- [调试和错误处理](#调试和错误处理)
- [完整应用示例](#完整应用示例)

---

## 基础使用

### 加载网页

```typescript
import web_webview from '@ohos.web.webview'

@Entry
@Component
struct BasicWebView {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  build() {
    Column() {
      // 基础 Web 组件
      Web({ src: 'https://www.example.com', controller: this.webviewController })
        .width('100%')
        .height('100%')
    }
  }
}
```

### 加载本地 HTML

```typescript
@Entry
@Component
struct LocalWebView {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  build() {
    Column() {
      // 加载本地资源
      Web({
        src: $rawfile('index.html'),
        controller: this.webviewController
      })
        .width('100%')
        .height('100%')
    }
  }
}
```

### 加载 HTML 字符串

```typescript
@Entry
@Component
struct HTMLStringWebView {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  private htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          font-family: Arial, sans-serif;
          padding: 20px;
          background: #f5f5f5;
        }
        .card {
          background: white;
          border-radius: 8px;
          padding: 20px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 {
          color: #1890ff;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>Hello HarmonyOS!</h1>
        <p>这是通过 loadData 加载的 HTML 内容</p>
        <button onclick="alert('Button clicked!')">点击我</button>
      </div>
    </body>
    </html>
  `
  
  aboutToAppear() {
    // 加载 HTML 字符串
    web_webview.WebviewController.loadData(
      this.webviewController,
      this.htmlContent,
      'text/html',
      'UTF-8'
    )
  }
  
  build() {
    Column() {
      Web({ src: '', controller: this.webviewController })
        .width('100%')
        .height('100%')
    }
  }
}
```

---

## 网页加载

### 页面加载进度

```typescript
@Entry
@Component
struct WebViewWithProgress {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  @State progress: number = 0
  @State isLoading: boolean = false
  
  build() {
    Column() {
      // 进度条
      if (this.isLoading) {
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(3)
          .color('#1890ff')
      }
      
      // Web 组件
      Web({ src: 'https://www.example.com', controller: this.webviewController })
        .width('100%')
        .layoutWeight(1)
        // 页面开始加载
        .onPageBegin((event) => {
          console.info('Page begin: ' + event.url)
          this.isLoading = true
          this.progress = 0
        })
        // 页面加载完成
        .onPageEnd((event) => {
          console.info('Page end: ' + event.url)
          this.isLoading = false
          this.progress = 100
        })
        // 加载进度变化
        .onProgressChange((event) => {
          this.progress = event.newProgress
          console.info('Progress: ' + event.newProgress)
        })
        // 加载错误
        .onErrorReceive((event) => {
          console.error('Error: ' + event.error.getErrorInfo())
          this.isLoading = false
        })
    }
  }
}
```

### 页面刷新和控制

```typescript
@Entry
@Component
struct WebViewController {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  @State canGoBack: boolean = false
  @State canGoForward: boolean = false
  
  build() {
    Column() {
      // 控制栏
      Row() {
        Button('后退')
          .enabled(this.canGoBack)
          .onClick(() => {
            this.webviewController.backward()
          })
        
        Button('前进')
          .enabled(this.canGoForward)
          .onClick(() => {
            this.webviewController.forward()
          })
          .margin({ left: 8 })
        
        Button('刷新')
          .onClick(() => {
            this.webviewController.refresh()
          })
          .margin({ left: 8 })
        
        Button('停止')
          .onClick(() => {
            this.webviewController.stop()
          })
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(12)
      .justifyContent(FlexAlign.SpaceAround)
      
      // Web 组件
      Web({ src: 'https://www.example.com', controller: this.webviewController })
        .width('100%')
        .layoutWeight(1)
        .onPageEnd(() => {
          // 更新导航状态
          this.canGoBack = this.webviewController.accessBackward()
          this.canGoForward = this.webviewController.accessForward()
        })
    }
  }
}
```

---

## JavaScript 交互

### ArkTS 调用 JavaScript

```typescript
@Entry
@Component
struct CallJavaScript {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  @State result: string = ''
  
  private htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
      <h1 id="title">初始标题</h1>
      <p id="message">初始消息</p>
      
      <script>
        // 定义可被 ArkTS 调用的函数
        function updateTitle(newTitle) {
          document.getElementById('title').innerText = newTitle;
          return 'Title updated to: ' + newTitle;
        }
        
        function getMessage() {
          return 'Hello from JavaScript!';
        }
        
        function calculate(a, b) {
          return a + b;
        }
      </script>
    </body>
    </html>
  `
  
  aboutToAppear() {
    web_webview.WebviewController.loadData(
      this.webviewController,
      this.htmlContent,
      'text/html',
      'UTF-8'
    )
  }
  
  build() {
    Column() {
      Row() {
        Button('调用 JS 函数')
          .onClick(async () => {
            try {
              // 调用 JavaScript 函数
              const result = await this.webviewController.runJavaScript('updateTitle("新标题")')
              console.info('JS Result: ' + result)
              this.result = result
            } catch (err) {
              console.error('Error calling JS: ' + err)
            }
          })
        
        Button('获取消息')
          .onClick(async () => {
            const result = await this.webviewController.runJavaScript('getMessage()')
            this.result = result
          })
          .margin({ left: 8 })
        
        Button('计算')
          .onClick(async () => {
            const result = await this.webviewController.runJavaScript('calculate(10, 20)')
            this.result = '计算结果: ' + result
          })
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(12)
      
      Text(`结果: ${this.result}`)
        .margin(12)
      
      Web({ src: '', controller: this.webviewController })
        .width('100%')
        .layoutWeight(1)
    }
  }
}
```

### JavaScript 调用 ArkTS

```typescript
@Entry
@Component
struct JSBridge {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  private htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { padding: 20px; }
        button {
          width: 100%;
          padding: 12px;
          margin: 8px 0;
          font-size: 16px;
          background: #1890ff;
          color: white;
          border: none;
          border-radius: 4px;
        }
      </style>
    </head>
    <body>
      <h2>JavaScript 调用 ArkTS</h2>
      
      <button onclick="callNative('showToast', { message: 'Hello from JS!' })">
        显示 Toast
      </button>
      
      <button onclick="callNative('vibrate')">
        震动
      </button>
      
      <button onclick="getUserInfo()">
        获取用户信息
      </button>
      
      <div id="result"></div>
      
      <script>
        // 调用原生方法
        function callNative(method, params) {
          const message = {
            method: method,
            params: params || {}
          };
          
          // 通过 message 事件与 ArkTS 通信
          window.messageChannel.postMessage(JSON.stringify(message));
        }
        
        async function getUserInfo() {
          callNative('getUserInfo');
        }
        
        // 接收 ArkTS 返回的数据
        function onNativeCallback(data) {
          document.getElementById('result').innerHTML = 
            '<p>收到返回: ' + JSON.stringify(data) + '</p>';
        }
      </script>
    </body>
    </html>
  `
  
  aboutToAppear() {
    web_webview.WebviewController.loadData(
      this.webviewController,
      this.htmlContent,
      'text/html',
      'UTF-8'
    )
  }
  
  build() {
    Column() {
      Web({ src: '', controller: this.webviewController })
        .width('100%')
        .height('100%')
        .javaScriptAccess(true)
        // 注册消息通道
        .onPageEnd(() => {
          // 创建消息端口
          const ports = this.webviewController.createWebMessagePorts()
          
          // 监听来自 H5 的消息
          ports[0].onMessageEvent((message) => {
            console.info('Received from H5: ' + message)
            const data = JSON.parse(message as string)
            
            // 处理不同的方法调用
            this.handleNativeCall(data.method, data.params, ports[0])
          })
          
          // 将端口发送到 H5
          this.webviewController.postMessage('messageChannel', [ports[1]], '*')
        })
    }
  }
  
  // 处理原生方法调用
  handleNativeCall(method: string, params: any, port: web_webview.WebMessagePort) {
    switch (method) {
      case 'showToast':
        promptAction.showToast({ message: params.message })
        break
        
      case 'vibrate':
        vibrator.vibrate({ duration: 100 })
        break
        
      case 'getUserInfo':
        const userInfo = {
          name: '张三',
          id: 12345,
          email: 'zhangsan@example.com'
        }
        // 发送数据回 H5
        port.postMessage(JSON.stringify({
          success: true,
          data: userInfo
        }))
        break
        
      default:
        console.warn('Unknown method: ' + method)
    }
  }
}
```

---

## 页面导航控制

### URL 拦截

```typescript
@Entry
@Component
struct URLInterception {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  build() {
    Column() {
      Web({ src: 'https://www.example.com', controller: this.webviewController })
        .width('100%')
        .height('100%')
        // 拦截 URL 加载
        .onUrlLoadIntercept((event) => {
          const url = event.data.toString()
          console.info('Intercepting URL: ' + url)
          
          // 拦截特定 URL
          if (url.startsWith('myapp://')) {
            // 处理自定义协议
            this.handleCustomProtocol(url)
            return true // 拦截
          }
          
          // 拦截外部链接
          if (url.startsWith('https://external.com')) {
            // 在外部浏览器打开
            this.openInExternalBrowser(url)
            return true
          }
          
          return false // 不拦截，继续加载
        })
    }
  }
  
  handleCustomProtocol(url: string) {
    // 解析自定义协议: myapp://action?param=value
    const action = url.split('//')[1].split('?')[0]
    console.info('Custom protocol action: ' + action)
    
    if (action === 'share') {
      promptAction.showToast({ message: '分享功能' })
    }
  }
  
  openInExternalBrowser(url: string) {
    console.info('Opening in external browser: ' + url)
    promptAction.showToast({ message: '在外部浏览器打开' })
  }
}
```

---

## Cookie 和缓存管理

### Cookie 操作

```typescript
import web_webview from '@ohos.web.webview'

@Entry
@Component
struct CookieManagement {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  // 设置 Cookie
  setCookie() {
    try {
      web_webview.WebCookieManager.setCookie(
        'https://www.example.com',
        'token=abc123; path=/; max-age=3600'
      )
      promptAction.showToast({ message: 'Cookie 已设置' })
    } catch (err) {
      console.error('Set cookie failed: ' + err)
    }
  }
  
  // 获取 Cookie
  getCookie() {
    try {
      const cookie = web_webview.WebCookieManager.getCookie('https://www.example.com')
      console.info('Cookie: ' + cookie)
      promptAction.showToast({ message: `Cookie: ${cookie}` })
    } catch (err) {
      console.error('Get cookie failed: ' + err)
    }
  }
  
  // 清除 Cookie
  clearCookies() {
    try {
      web_webview.WebCookieManager.deleteEntireCookie()
      promptAction.showToast({ message: 'Cookie 已清除' })
    } catch (err) {
      console.error('Clear cookies failed: ' + err)
    }
  }
  
  build() {
    Column() {
      Row() {
        Button('设置 Cookie')
          .onClick(() => {
            this.setCookie()
          })
        
        Button('获取 Cookie')
          .onClick(() => {
            this.getCookie()
          })
          .margin({ left: 8 })
        
        Button('清除 Cookie')
          .onClick(() => {
            this.clearCookies()
          })
          .margin({ left: 8 })
      }
      .padding(12)
      
      Web({ src: 'https://www.example.com', controller: this.webviewController })
        .width('100%')
        .layoutWeight(1)
    }
  }
}
```

### 缓存管理

```typescript
@Entry
@Component
struct CacheManagement {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  // 清除缓存
  clearCache() {
    try {
      this.webviewController.clearCache()
      promptAction.showToast({ message: '缓存已清除' })
    } catch (err) {
      console.error('Clear cache failed: ' + err)
    }
  }
  
  // 清除历史记录
  clearHistory() {
    try {
      this.webviewController.clearHistory()
      promptAction.showToast({ message: '历史记录已清除' })
    } catch (err) {
      console.error('Clear history failed: ' + err)
    }
  }
  
  build() {
    Column() {
      Row() {
        Button('清除缓存')
          .onClick(() => {
            this.clearCache()
          })
        
        Button('清除历史')
          .onClick(() => {
            this.clearHistory()
          })
          .margin({ left: 8 })
      }
      .padding(12)
      
      Web({ src: 'https://www.example.com', controller: this.webviewController })
        .width('100%')
        .layoutWeight(1)
        // 配置缓存模式
        .cacheMode(CacheMode.Default)
        // 启用 DOM Storage
        .domStorageAccess(true)
        // 启用数据库
        .databaseAccess(true)
    }
  }
}
```

---

## 文件上传下载

### 文件选择

```typescript
@Entry
@Component
struct FileUpload {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  private htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { padding: 20px; }
        input[type="file"] {
          width: 100%;
          padding: 12px;
          margin: 8px 0;
          font-size: 16px;
        }
      </style>
    </head>
    <body>
      <h2>文件上传</h2>
      <input type="file" accept="image/*" />
      <input type="file" accept="image/*" multiple />
    </body>
    </html>
  `
  
  aboutToAppear() {
    web_webview.WebviewController.loadData(
      this.webviewController,
      this.htmlContent,
      'text/html',
      'UTF-8'
    )
  }
  
  build() {
    Column() {
      Web({ src: '', controller: this.webviewController })
        .width('100%')
        .height('100%')
        // 处理文件选择
        .onShowFileSelector((event) => {
          console.info('File selector triggered')
          
          // 这里可以调用文件选择器
          // 选择完成后通过 event.result.handleFileList 返回文件列表
          
          return true
        })
    }
  }
}
```

---

## 调试和错误处理

### 控制台日志监听

```typescript
@Entry
@Component
struct ConsoleLogging {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  private htmlContent = `
    <!DOCTYPE html>
    <html>
    <body>
      <button onclick="console.log('Log message')">Log</button>
      <button onclick="console.warn('Warning message')">Warn</button>
      <button onclick="console.error('Error message')">Error</button>
      
      <script>
        console.log('Page loaded');
      </script>
    </body>
    </html>
  `
  
  aboutToAppear() {
    web_webview.WebviewController.loadData(
      this.webviewController,
      this.htmlContent,
      'text/html',
      'UTF-8'
    )
  }
  
  build() {
    Column() {
      Web({ src: '', controller: this.webviewController })
        .width('100%')
        .height('100%')
        // 监听控制台消息
        .onConsoleLog((event) => {
          console.info(`[WebView Console] ${event.message.getLevel()}: ${event.message.getMessage()}`)
          return false
        })
        // 监听 Alert 对话框
        .onAlert((event) => {
          AlertDialog.show({
            title: '提示',
            message: event.message,
            confirm: {
              value: '确定',
              action: () => {
                event.result.handleConfirm()
              }
            },
            cancel: () => {
              event.result.handleCancel()
            }
          })
          return true
        })
        // 监听 Confirm 对话框
        .onConfirm((event) => {
          AlertDialog.show({
            title: '确认',
            message: event.message,
            primaryButton: {
              value: '取消',
              action: () => {
                event.result.handleCancel()
              }
            },
            secondaryButton: {
              value: '确定',
              action: () => {
                event.result.handleConfirm()
              }
            }
          })
          return true
        })
    }
  }
}
```

---

## 完整应用示例

### 内置浏览器

```typescript
import web_webview from '@ohos.web.webview'
import router from '@ohos.router'

@Entry
@Component
struct MobileBrowser {
  @State url: string = 'https://www.harmonyos.com'
  @State currentUrl: string = ''
  @State progress: number = 0
  @State isLoading: boolean = false
  @State canGoBack: boolean = false
  @State canGoForward: boolean = false
  @State title: string = '浏览器'
  
  webviewController: web_webview.WebviewController = new web_webview.WebviewController()
  
  aboutToAppear() {
    // 获取传入的 URL
    const params = router.getParams() as any
    if (params?.url) {
      this.url = params.url
      this.currentUrl = params.url
    }
  }
  
  build() {
    Column() {
      // 顶部工具栏
      Column() {
        // 标题
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 8 })
        
        // 地址栏
        Row() {
          TextInput({ text: this.currentUrl })
            .layoutWeight(1)
            .fontSize(14)
            .onChange((value: string) => {
              this.url = value
            })
            .onSubmit(() => {
              this.loadUrl()
            })
          
          Button('转到')
            .fontSize(14)
            .onClick(() => {
              this.loadUrl()
            })
            .margin({ left: 8 })
        }
        .padding({ left: 16, right: 16, bottom: 8 })
        
        // 进度条
        if (this.isLoading) {
          Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(3)
            .color('#1890ff')
        }
      }
      .width('100%')
      .backgroundColor('#f5f5f5')
      
      // Web 内容
      Web({ src: this.url, controller: this.webviewController })
        .width('100%')
        .layoutWeight(1)
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onPageBegin((event) => {
          this.isLoading = true
          this.currentUrl = event.url
        })
        .onPageEnd((event) => {
          this.isLoading = false
          this.canGoBack = this.webviewController.accessBackward()
          this.canGoForward = this.webviewController.accessForward()
          
          // 获取页面标题
          this.webviewController.runJavaScript('document.title')
            .then(title => {
              this.title = title || '浏览器'
            })
        })
        .onProgressChange((event) => {
          this.progress = event.newProgress
        })
        .onErrorReceive((event) => {
          promptAction.showToast({
            message: '页面加载失败'
          })
        })
      
      // 底部导航栏
      Row() {
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.back'))
            .width(24)
            .height(24)
        }
        .enabled(this.canGoBack)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.webviewController.backward()
        })
        
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.forward'))
            .width(24)
            .height(24)
        }
        .enabled(this.canGoForward)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.webviewController.forward()
        })
        .margin({ left: 20 })
        
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.refresh'))
            .width(24)
            .height(24)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.webviewController.refresh()
        })
        .margin({ left: 20 })
        
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.home'))
            .width(24)
            .height(24)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.url = 'https://www.harmonyos.com'
          this.loadUrl()
        })
        .margin({ left: 20 })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor('#ffffff')
      .border({ width: { top: 1 }, color: '#e0e0e0' })
    }
  }
  
  loadUrl() {
    let targetUrl = this.url.trim()
    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      targetUrl = 'https://' + targetUrl
    }
    this.webviewController.loadUrl(targetUrl)
  }
}
```

---

## 最佳实践

### 1. 性能优化
- ✅ 启用硬件加速
- ✅ 合理设置缓存策略
- ✅ 避免频繁的 JS 交互
- ✅ 使用 Web Worker 处理耗时操作

### 2. 安全考虑
- ✅ 验证 URL 来源
- ✅ 限制 JavaScript 权限
- ✅ 过滤危险的 URL Scheme
- ✅ 使用 HTTPS

### 3. 用户体验
- ✅ 显示加载进度
- ✅ 处理加载错误
- ✅ 提供导航控制
- ✅ 优化移动端适配

### 4. 调试
- ✅ 监听控制台日志
- ✅ 使用 Chrome DevTools 远程调试
- ✅ 捕获 JavaScript 错误
- ✅ 记录性能指标

---

**完整代码可直接复制使用！** 🚀

