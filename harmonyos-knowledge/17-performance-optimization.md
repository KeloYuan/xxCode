# 性能优化实践指南

> 本文档详细介绍 HarmonyOS Next 应用的性能优化技巧，包括渲染优化、内存优化、网络优化等最佳实践。

---

## 目录
- [渲染性能优化](#渲染性能优化)
- [LazyForEach 懒加载](#lazyforeach-懒加载)
- [组件复用](#组件复用)
- [内存优化](#内存优化)
- [网络性能优化](#网络性能优化)
- [启动优化](#启动优化)
- [动画性能优化](#动画性能优化)
- [性能监控工具](#性能监控工具)

---

## 渲染性能优化

### 减少不必要的重渲染

```typescript
// ❌ 不好的做法 - 每次都会重新创建数组
@Entry
@Component
struct BadExample {
  @State counter: number = 0
  
  build() {
    Column() {
      // 每次渲染都会创建新数组
      ForEach([1, 2, 3, 4, 5], (item: number) => {
        Text(`Item ${item}`)
      })
      
      Button(`Count: ${this.counter}`)
        .onClick(() => {
          this.counter++
        })
    }
  }
}

// ✅ 好的做法 - 使用 @State 管理数据
@Entry
@Component
struct GoodExample {
  @State counter: number = 0
  private readonly items: number[] = [1, 2, 3, 4, 5] // 常量数组
  
  build() {
    Column() {
      ForEach(this.items, (item: number) => {
        Text(`Item ${item}`)
      }, (item: number) => item.toString()) // 提供 keyGenerator
      
      Button(`Count: ${this.counter}`)
        .onClick(() => {
          this.counter++
        })
    }
  }
}
```

### 使用 @Builder 优化复杂组件

```typescript
@Entry
@Component
struct BuilderOptimization {
  @State list: string[] = ['Apple', 'Banana', 'Orange']
  
  // ✅ 使用 @Builder 提取重复的 UI 结构
  @Builder
  ItemBuilder(item: string, index: number) {
    Row() {
      Text(`${index + 1}`)
        .width(30)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
      
      Text(item)
        .layoutWeight(1)
        .fontSize(16)
      
      Image($r('app.media.arrow_right'))
        .width(20)
        .height(20)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
  }
  
  build() {
    Column() {
      List() {
        ForEach(this.list, (item: string, index: number) => {
          ListItem() {
            this.ItemBuilder(item, index)
          }
        }, (item: string) => item)
      }
    }
  }
}
```

### 条件渲染优化

```typescript
@Entry
@Component
struct ConditionalRenderOptimization {
  @State isLoading: boolean = false
  @State hasError: boolean = false
  @State data: string[] = []
  
  build() {
    Column() {
      // ✅ 使用 if-else 代替多个 if
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
      } else if (this.hasError) {
        Text('加载失败')
          .fontSize(16)
          .fontColor('#ff4d4f')
      } else if (this.data.length === 0) {
        Text('暂无数据')
          .fontSize(16)
          .fontColor('#999')
      } else {
        List() {
          ForEach(this.data, (item: string) => {
            ListItem() {
              Text(item)
            }
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## LazyForEach 懒加载

### 自定义数据源

```typescript
// 数据源接口
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  
  public totalCount(): number {
    return 0
  }
  
  public getData(index: number): any {
    return undefined
  }
  
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }
  
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }
  
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }
  
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }
  
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }
  
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }
  
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }
}

// 实现具体的数据源
class MyDataSource extends BasicDataSource {
  private dataArray: string[] = []
  
  public totalCount(): number {
    return this.dataArray.length
  }
  
  public getData(index: number): any {
    return this.dataArray[index]
  }
  
  public addData(index: number, data: string): void {
    this.dataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }
  
  public pushData(data: string): void {
    this.dataArray.push(data)
    this.notifyDataAdd(this.dataArray.length - 1)
  }
  
  public deleteData(index: number): void {
    this.dataArray.splice(index, 1)
    this.notifyDataDelete(index)
  }
  
  public reloadData(data: string[]): void {
    this.dataArray = data
    this.notifyDataReload()
  }
}
```

### LazyForEach 使用示例

```typescript
@Entry
@Component
struct LazyForEachExample {
  private data: MyDataSource = new MyDataSource()
  
  aboutToAppear() {
    // 模拟加载大量数据
    const list: string[] = []
    for (let i = 1; i <= 1000; i++) {
      list.push(`Item ${i}`)
    }
    this.data.reloadData(list)
  }
  
  build() {
    Column() {
      Text('LazyForEach 长列表优化')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })
      
      List({ space: 8 }) {
        // ✅ 使用 LazyForEach 实现懒加载
        LazyForEach(this.data, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(`${index + 1}`)
                .width(50)
                .fontSize(16)
                .fontColor('#1890ff')
                .fontWeight(FontWeight.Bold)
              
              Text(item)
                .layoutWeight(1)
                .fontSize(16)
              
              Button('删除')
                .fontSize(14)
                .onClick(() => {
                  this.data.deleteData(index)
                })
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
          }
        }, (item: string, index: number) => `${index}-${item}`)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 16, right: 16 })
      
      Button('添加数据')
        .onClick(() => {
          this.data.pushData(`New Item ${this.data.totalCount() + 1}`)
        })
        .margin({ top: 12, bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }
}
```

### 分页加载优化

```typescript
class PaginatedDataSource extends BasicDataSource {
  private dataArray: any[] = []
  private pageSize: number = 20
  private currentPage: number = 0
  private totalPages: number = 0
  private isLoading: boolean = false
  
  public totalCount(): number {
    return this.dataArray.length
  }
  
  public getData(index: number): any {
    // 当滚动到底部附近时触发加载
    if (index >= this.dataArray.length - 5 && !this.isLoading && this.hasMore()) {
      this.loadNextPage()
    }
    return this.dataArray[index]
  }
  
  public async loadNextPage(): Promise<void> {
    if (this.isLoading || !this.hasMore()) {
      return
    }
    
    this.isLoading = true
    
    // 模拟网络请求
    const newData = await this.fetchData(this.currentPage + 1, this.pageSize)
    
    const startIndex = this.dataArray.length
    this.dataArray.push(...newData)
    this.currentPage++
    this.isLoading = false
    
    // 通知数据变化
    for (let i = 0; i < newData.length; i++) {
      this.notifyDataAdd(startIndex + i)
    }
  }
  
  private async fetchData(page: number, size: number): Promise<any[]> {
    // 模拟 API 请求
    return new Promise((resolve) => {
      setTimeout(() => {
        const data = []
        for (let i = 0; i < size; i++) {
          data.push({ id: page * size + i, title: `Item ${page * size + i}` })
        }
        resolve(data)
      }, 500)
    })
  }
  
  private hasMore(): boolean {
    return this.totalPages === 0 || this.currentPage < this.totalPages
  }
  
  public reload(): void {
    this.dataArray = []
    this.currentPage = 0
    this.notifyDataReload()
    this.loadNextPage()
  }
}

@Entry
@Component
struct PaginationExample {
  private dataSource: PaginatedDataSource = new PaginatedDataSource()
  
  aboutToAppear() {
    this.dataSource.loadNextPage()
  }
  
  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: any) => {
          ListItem() {
            Row() {
              Text(item.title)
                .fontSize(16)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
          }
        }, (item: any) => item.id.toString())
      }
      .onReachEnd(() => {
        // 滚动到底部时加载更多
        this.dataSource.loadNextPage()
      })
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}
```

---

## 组件复用

### @Reusable 装饰器

```typescript
// ✅ 使用 @Reusable 标记可复用组件
@Reusable
@Component
struct ReusableListItem {
  @State data: any = {}
  
  // 组件复用时调用
  aboutToReuse(params: any): void {
    this.data = params.data
    console.info('Component reused')
  }
  
  build() {
    Row() {
      Image(this.data.avatar)
        .width(50)
        .height(50)
        .borderRadius(25)
      
      Column() {
        Text(this.data.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        
        Text(this.data.description)
          .fontSize(14)
          .fontColor('#666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#fff')
    .borderRadius(8)
  }
}

@Entry
@Component
struct ReusableListExample {
  @State list: any[] = []
  
  aboutToAppear() {
    // 生成大量数据
    for (let i = 0; i < 1000; i++) {
      this.list.push({
        id: i,
        name: `User ${i}`,
        description: `Description ${i}`,
        avatar: $r('app.media.avatar')
      })
    }
  }
  
  build() {
    List() {
      ForEach(this.list, (item: any) => {
        ListItem() {
          // 组件会被复用，提高性能
          ReusableListItem({ data: item })
        }
      }, (item: any) => item.id.toString())
    }
  }
}
```

---

## 内存优化

### 及时释放资源

```typescript
@Entry
@Component
struct MemoryOptimization {
  private timer: number = -1
  private subscription: any = null
  
  aboutToAppear() {
    // 启动定时器
    this.timer = setInterval(() => {
      console.info('Timer tick')
    }, 1000)
    
    // 订阅事件
    this.subscription = eventBus.subscribe('data-update', this.handleDataUpdate)
  }
  
  // ✅ 组件销毁时清理资源
  aboutToDisappear() {
    // 清除定时器
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
    
    // 取消订阅
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
    
    console.info('Resources cleaned up')
  }
  
  handleDataUpdate = (data: any) => {
    console.info('Data updated:', data)
  }
  
  build() {
    Column() {
      Text('内存优化示例')
    }
  }
}
```

### 图片内存优化

```typescript
@Entry
@Component
struct ImageOptimization {
  @State imageList: string[] = []
  
  build() {
    List() {
      ForEach(this.imageList, (url: string) => {
        ListItem() {
          Image(url)
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            // ✅ 设置解码尺寸，减少内存占用
            .sourceSize({ width: 750, height: 400 })
            // ✅ 异步渲染
            .renderMode(ImageRenderMode.Original)
            // ✅ 使用缓存
            .syncLoad(false)
        }
      })
    }
    // ✅ 启用缓存节点
    .cachedCount(3)
  }
}
```

### 大数据集优化

```typescript
@Entry
@Component
struct LargeDataOptimization {
  // ❌ 不好的做法 - 直接存储大量数据
  // @State largeData: any[] = new Array(10000).fill({...})
  
  // ✅ 好的做法 - 使用数据源 + 分页
  private dataSource: PaginatedDataSource = new PaginatedDataSource()
  
  aboutToAppear() {
    this.dataSource.loadNextPage()
  }
  
  build() {
    List() {
      LazyForEach(this.dataSource, (item: any) => {
        ListItem() {
          // 只渲染可见项
          this.ItemView(item)
        }
      }, (item: any) => item.id.toString())
    }
    // ✅ 设置缓存数量
    .cachedCount(5)
  }
  
  @Builder
  ItemView(item: any) {
    Row() {
      Text(item.title)
    }
    .padding(12)
  }
}
```

---

## 网络性能优化

### 请求合并

```typescript
export class RequestBatcher {
  private pendingRequests: Map<string, Promise<any>> = new Map()
  
  // ✅ 合并相同的请求
  async fetch(url: string): Promise<any> {
    // 如果已有相同请求在进行中，直接返回
    if (this.pendingRequests.has(url)) {
      return this.pendingRequests.get(url)
    }
    
    const promise = http.createHttp()
      .request(url)
      .then(response => {
        this.pendingRequests.delete(url)
        return response.result
      })
      .catch(err => {
        this.pendingRequests.delete(url)
        throw err
      })
    
    this.pendingRequests.set(url, promise)
    return promise
  }
}
```

### 数据缓存

```typescript
export class DataCache {
  private cache: Map<string, { data: any, timestamp: number }> = new Map()
  private readonly CACHE_DURATION = 5 * 60 * 1000 // 5分钟
  
  // ✅ 缓存数据，减少网络请求
  async get(key: string, fetcher: () => Promise<any>): Promise<any> {
    const cached = this.cache.get(key)
    
    // 检查缓存是否有效
    if (cached && Date.now() - cached.timestamp < this.CACHE_DURATION) {
      console.info('Using cached data')
      return cached.data
    }
    
    // 获取新数据
    const data = await fetcher()
    this.cache.set(key, {
      data: data,
      timestamp: Date.now()
    })
    
    return data
  }
  
  // 清除缓存
  clear(): void {
    this.cache.clear()
  }
  
  // 删除特定缓存
  delete(key: string): void {
    this.cache.delete(key)
  }
}

// 使用示例
@Entry
@Component
struct CachedDataExample {
  @State data: any[] = []
  private cache = new DataCache()
  
  async loadData() {
    const data = await this.cache.get('user-list', async () => {
      // 实际的网络请求
      const response = await http.createHttp().request('https://api.example.com/users')
      return JSON.parse(response.result.toString())
    })
    
    this.data = data
  }
  
  build() {
    Column() {
      Button('加载数据')
        .onClick(() => {
          this.loadData()
        })
      
      List() {
        ForEach(this.data, (item: any) => {
          ListItem() {
            Text(item.name)
          }
        })
      }
    }
  }
}
```

### 图片预加载

```typescript
export class ImagePreloader {
  // ✅ 预加载图片
  async preloadImages(urls: string[]): Promise<void> {
    const promises = urls.map(url => {
      return new Promise((resolve, reject) => {
        const img = new Image()
        img.onload = () => resolve(url)
        img.onerror = () => reject(url)
        img.src = url
      })
    })
    
    await Promise.allSettled(promises)
    console.info('Images preloaded')
  }
}
```

---

## 启动优化

### 延迟初始化

```typescript
// EntryAbility.ets
export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    console.info('[EntryAbility] onCreate')
    
    // ✅ 只初始化必要的服务
    this.initEssentialServices()
    
    // ❌ 不要在这里初始化所有服务
    // this.initAllServices()
  }
  
  private initEssentialServices() {
    // 初始化核心服务
    ConfigService.getInstance().init()
  }
  
  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        return
      }
      
      // ✅ 页面加载后再初始化其他服务
      this.initNonEssentialServices()
    })
  }
  
  private async initNonEssentialServices() {
    // 延迟初始化非核心服务
    await DatabaseService.getInstance().init(this.context)
    await AnalyticsService.getInstance().init()
    console.info('Non-essential services initialized')
  }
}
```

### 首屏优化

```typescript
@Entry
@Component
struct OptimizedHomePage {
  @State isReady: boolean = false
  @State criticalData: any[] = [] // 关键数据
  @State nonCriticalData: any[] = [] // 非关键数据
  
  async aboutToAppear() {
    // ✅ 优先加载关键数据
    await this.loadCriticalData()
    this.isReady = true
    
    // ✅ 延迟加载非关键数据
    setTimeout(() => {
      this.loadNonCriticalData()
    }, 100)
  }
  
  async loadCriticalData() {
    // 加载首屏必需的数据
    this.criticalData = await fetchCriticalData()
  }
  
  async loadNonCriticalData() {
    // 加载其他数据
    this.nonCriticalData = await fetchNonCriticalData()
  }
  
  build() {
    Column() {
      if (!this.isReady) {
        // ✅ 显示骨架屏
        this.SkeletonScreen()
      } else {
        // 显示真实内容
        this.Content()
      }
    }
  }
  
  @Builder
  SkeletonScreen() {
    Column() {
      ForEach([1, 2, 3], (item: number) => {
        Row() {
          Column()
            .width(60)
            .height(60)
            .backgroundColor('#e0e0e0')
            .borderRadius(8)
          
          Column() {
            Column()
              .width('80%')
              .height(20)
              .backgroundColor('#e0e0e0')
              .borderRadius(4)
            
            Column()
              .width('60%')
              .height(16)
              .backgroundColor('#e0e0e0')
              .borderRadius(4)
              .margin({ top: 8 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .margin({ bottom: 12 })
      })
    }
    .padding(16)
  }
  
  @Builder
  Content() {
    List() {
      ForEach(this.criticalData, (item: any) => {
        ListItem() {
          Text(item.title)
        }
      })
    }
  }
}
```

---

## 动画性能优化

### 使用 GPU 加速

```typescript
@Entry
@Component
struct AnimationOptimization {
  @State offsetX: number = 0
  @State scale: number = 1
  
  build() {
    Column() {
      // ✅ 使用 transform 属性触发 GPU 加速
      Image($r('app.media.image'))
        .width(100)
        .height(100)
        .translate({ x: this.offsetX, y: 0 })
        .scale({ x: this.scale, y: this.scale })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
      
      Button('移动')
        .onClick(() => {
          // ✅ 使用 translate 代替 position
          this.offsetX = this.offsetX === 0 ? 100 : 0
        })
      
      Button('缩放')
        .onClick(() => {
          // ✅ 使用 scale 代替 width/height
          this.scale = this.scale === 1 ? 1.5 : 1
        })
    }
  }
}
```

### 减少动画层级

```typescript
@Entry
@Component
struct AnimationLayerOptimization {
  @State isExpanded: boolean = false
  
  build() {
    Column() {
      // ✅ 将动画应用在外层容器
      Column() {
        Text('标题')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        if (this.isExpanded) {
          Text('详细内容详细内容详细内容')
            .fontSize(14)
            .margin({ top: 8 })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#fff')
      .borderRadius(8)
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
      
      Button('展开/收起')
        .onClick(() => {
          this.isExpanded = !this.isExpanded
        })
        .margin({ top: 12 })
    }
    .padding(16)
  }
}
```

---

## 性能监控工具

### 性能埋点

```typescript
export class PerformanceMonitor {
  private static marks: Map<string, number> = new Map()
  
  // 开始计时
  static mark(name: string): void {
    this.marks.set(name, Date.now())
  }
  
  // 结束计时并输出
  static measure(name: string): number {
    const startTime = this.marks.get(name)
    if (!startTime) {
      console.warn(`No mark found for ${name}`)
      return 0
    }
    
    const duration = Date.now() - startTime
    console.info(`[Performance] ${name}: ${duration}ms`)
    this.marks.delete(name)
    
    return duration
  }
  
  // 测量异步操作
  static async measureAsync<T>(name: string, operation: () => Promise<T>): Promise<T> {
    this.mark(name)
    try {
      const result = await operation()
      this.measure(name)
      return result
    } catch (err) {
      this.measure(name)
      throw err
    }
  }
}

// 使用示例
@Entry
@Component
struct PerformanceMonitorExample {
  async loadData() {
    const data = await PerformanceMonitor.measureAsync('load-user-data', async () => {
      const response = await http.createHttp().request('https://api.example.com/users')
      return JSON.parse(response.result.toString())
    })
    
    console.info('Data loaded:', data)
  }
  
  build() {
    Column() {
      Button('加载数据')
        .onClick(() => {
          this.loadData()
        })
    }
  }
}
```

### FPS 监控

```typescript
export class FPSMonitor {
  private lastTime: number = 0
  private frames: number = 0
  private fps: number = 0
  
  start(): void {
    this.lastTime = Date.now()
    this.tick()
  }
  
  private tick = (): void => {
    this.frames++
    const now = Date.now()
    
    if (now >= this.lastTime + 1000) {
      this.fps = Math.round((this.frames * 1000) / (now - this.lastTime))
      console.info(`[FPS] ${this.fps}`)
      
      this.frames = 0
      this.lastTime = now
    }
    
    requestAnimationFrame(this.tick)
  }
  
  getFPS(): number {
    return this.fps
  }
}
```

---

## 性能优化检查清单

### 渲染性能
- ✅ 使用 LazyForEach 处理长列表
- ✅ 合理使用 @Builder 和 @Reusable
- ✅ 避免不必要的重渲染
- ✅ 减少组件嵌套层级
- ✅ 使用 cachedCount 设置缓存

### 内存性能
- ✅ 及时清理定时器和订阅
- ✅ 图片使用 sourceSize 限制尺寸
- ✅ 避免内存泄漏
- ✅ 合理使用数据缓存

### 网络性能
- ✅ 实现数据缓存机制
- ✅ 合并重复请求
- ✅ 使用图片预加载
- ✅ 实现分页加载

### 启动性能
- ✅ 延迟初始化非核心服务
- ✅ 优先加载首屏数据
- ✅ 使用骨架屏提升体验
- ✅ 减少启动时的同步操作

### 动画性能
- ✅ 使用 transform 触发 GPU 加速
- ✅ 避免在动画中修改布局
- ✅ 减少动画层级
- ✅ 使用合适的动画曲线

---

**完整代码可直接复制使用！** 🚀

