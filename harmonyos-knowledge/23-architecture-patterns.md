# 架构模式与设计模式

> 本文档介绍 HarmonyOS Next 应用开发中的常见架构模式和设计模式，帮助构建可维护、可扩展的应用。

---

## 目录
- [MVVM 架构](#mvvm-架构)
- [单例模式](#单例模式)
- [工厂模式](#工厂模式)
- [观察者模式](#观察者模式)
- [策略模式](#策略模式)
- [依赖注入](#依赖注入)
- [Repository 模式](#repository-模式)
- [完整应用架构](#完整应用架构)

---

## MVVM 架构

### Model-View-ViewModel 模式

MVVM 是 HarmonyOS 推荐的架构模式，通过状态管理实现数据与 UI 的双向绑定。

#### Model (数据模型)

```typescript
/**
 * 用户数据模型
 */
@Observed
export class User {
  id: string
  name: string
  email: string
  avatar: string
  age: number
  
  constructor(
    id: string,
    name: string,
    email: string,
    avatar: string = '',
    age: number = 0
  ) {
    this.id = id
    this.name = name
    this.email = email
    this.avatar = avatar
    this.age = age
  }
  
  // 验证方法
  isValid(): boolean {
    return this.name.length > 0 && this.email.includes('@')
  }
  
  // 转换为 JSON
  toJSON(): object {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      avatar: this.avatar,
      age: this.age
    }
  }
  
  // 从 JSON 创建
  static fromJSON(json: any): User {
    return new User(
      json.id || '',
      json.name || '',
      json.email || '',
      json.avatar || '',
      json.age || 0
    )
  }
}
```

#### ViewModel (视图模型)

```typescript
import { User } from '../models/User'
import { UserRepository } from '../repositories/UserRepository'

/**
 * 用户列表 ViewModel
 */
export class UserListViewModel {
  @State users: User[] = []
  @State isLoading: boolean = false
  @State errorMessage: string = ''
  
  private repository: UserRepository
  
  constructor() {
    this.repository = new UserRepository()
  }
  
  /**
   * 加载用户列表
   */
  async loadUsers(): Promise<void> {
    this.isLoading = true
    this.errorMessage = ''
    
    try {
      this.users = await this.repository.getAllUsers()
    } catch (error) {
      this.errorMessage = `加载失败: ${error}`
      console.error('加载用户失败:', error)
    } finally {
      this.isLoading = false
    }
  }
  
  /**
   * 添加用户
   */
  async addUser(user: User): Promise<boolean> {
    try {
      const newUser = await this.repository.createUser(user)
      this.users.push(newUser)
      return true
    } catch (error) {
      this.errorMessage = `添加失败: ${error}`
      return false
    }
  }
  
  /**
   * 删除用户
   */
  async deleteUser(userId: string): Promise<boolean> {
    try {
      await this.repository.deleteUser(userId)
      this.users = this.users.filter(u => u.id !== userId)
      return true
    } catch (error) {
      this.errorMessage = `删除失败: ${error}`
      return false
    }
  }
  
  /**
   * 搜索用户
   */
  searchUsers(keyword: string): User[] {
    if (!keyword) {
      return this.users
    }
    
    return this.users.filter(user =>
      user.name.toLowerCase().includes(keyword.toLowerCase()) ||
      user.email.toLowerCase().includes(keyword.toLowerCase())
    )
  }
}
```

#### View (视图)

```typescript
import { UserListViewModel } from '../viewmodels/UserListViewModel'
import { User } from '../models/User'

@Entry
@Component
struct UserListPage {
  @State viewModel: UserListViewModel = new UserListViewModel()
  @State searchKeyword: string = ''
  
  aboutToAppear() {
    this.viewModel.loadUsers()
  }
  
  build() {
    Navigation() {
      Column() {
        // 搜索框
        Search({ value: this.searchKeyword })
          .onChange((value: string) => {
            this.searchKeyword = value
          })
          .margin({ bottom: 16 })
        
        // 加载状态
        if (this.viewModel.isLoading) {
          this.LoadingView()
        }
        // 错误状态
        else if (this.viewModel.errorMessage) {
          this.ErrorView()
        }
        // 用户列表
        else {
          this.UserList()
        }
      }
      .width('100%')
      .height('100%')
      .padding(20)
    }
    .title('用户列表')
    .titleMode(NavigationTitleMode.Mini)
  }
  
  @Builder
  UserList() {
    List({ space: 12 }) {
      ForEach(
        this.viewModel.searchUsers(this.searchKeyword),
        (user: User) => {
          ListItem() {
            this.UserCard(user)
          }
        },
        (user: User) => user.id
      )
    }
    .layoutWeight(1)
  }
  
  @Builder
  UserCard(user: User) {
    Row() {
      // 头像
      Image(user.avatar || $r('app.media.default_avatar'))
        .width(50)
        .height(50)
        .borderRadius(25)
        .margin({ right: 16 })
      
      // 用户信息
      Column({ space: 4 }) {
        Text(user.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        
        Text(user.email)
          .fontSize(14)
          .fontColor('#666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      // 删除按钮
      Button('删除')
        .fontSize(14)
        .backgroundColor('#ff4d4f')
        .onClick(() => {
          this.viewModel.deleteUser(user.id)
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#0000001A', offsetY: 2 })
  }
  
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
      
      Text('加载中...')
        .fontSize(14)
        .fontColor('#666')
        .margin({ top: 12 })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
  
  @Builder
  ErrorView() {
    Column() {
      Text('❌')
        .fontSize(48)
      
      Text(this.viewModel.errorMessage)
        .fontSize(14)
        .fontColor('#ff4d4f')
        .margin({ top: 12 })
      
      Button('重试')
        .margin({ top: 20 })
        .onClick(() => {
          this.viewModel.loadUsers()
        })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## 单例模式

### 服务单例

```typescript
/**
 * 配置管理服务 - 单例模式
 */
export class ConfigService {
  private static instance: ConfigService | null = null
  private config: Map<string, any> = new Map()
  
  // 私有构造函数
  private constructor() {
    this.loadDefaultConfig()
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): ConfigService {
    if (!ConfigService.instance) {
      ConfigService.instance = new ConfigService()
    }
    return ConfigService.instance
  }
  
  /**
   * 加载默认配置
   */
  private loadDefaultConfig(): void {
    this.config.set('apiBaseUrl', 'https://api.example.com')
    this.config.set('timeout', 30000)
    this.config.set('retryCount', 3)
  }
  
  /**
   * 获取配置
   */
  public get<T>(key: string, defaultValue?: T): T {
    return this.config.get(key) ?? defaultValue
  }
  
  /**
   * 设置配置
   */
  public set(key: string, value: any): void {
    this.config.set(key, value)
  }
  
  /**
   * 重置单例（用于测试）
   */
  public static reset(): void {
    ConfigService.instance = null
  }
}

// 使用示例
const config = ConfigService.getInstance()
const apiUrl = config.get<string>('apiBaseUrl')
config.set('theme', 'dark')
```

---

## 工厂模式

### 简单工厂

```typescript
/**
 * 通知类型枚举
 */
export enum NotificationType {
  INFO = 'info',
  SUCCESS = 'success',
  WARNING = 'warning',
  ERROR = 'error'
}

/**
 * 通知接口
 */
export interface Notification {
  type: NotificationType
  title: string
  message: string
  icon: string
  color: string
  show(): void
}

/**
 * 具体通知类
 */
class InfoNotification implements Notification {
  type = NotificationType.INFO
  icon = 'ℹ️'
  color = '#1890ff'
  
  constructor(public title: string, public message: string) {}
  
  show(): void {
    console.info(`[INFO] ${this.title}: ${this.message}`)
  }
}

class SuccessNotification implements Notification {
  type = NotificationType.SUCCESS
  icon = '✓'
  color = '#52c41a'
  
  constructor(public title: string, public message: string) {}
  
  show(): void {
    console.info(`[SUCCESS] ${this.title}: ${this.message}`)
  }
}

class WarningNotification implements Notification {
  type = NotificationType.WARNING
  icon = '⚠️'
  color = '#faad14'
  
  constructor(public title: string, public message: string) {}
  
  show(): void {
    console.warn(`[WARNING] ${this.title}: ${this.message}`)
  }
}

class ErrorNotification implements Notification {
  type = NotificationType.ERROR
  icon = '✕'
  color = '#ff4d4f'
  
  constructor(public title: string, public message: string) {}
  
  show(): void {
    console.error(`[ERROR] ${this.title}: ${this.message}`)
  }
}

/**
 * 通知工厂
 */
export class NotificationFactory {
  public static create(
    type: NotificationType,
    title: string,
    message: string
  ): Notification {
    switch (type) {
      case NotificationType.INFO:
        return new InfoNotification(title, message)
      case NotificationType.SUCCESS:
        return new SuccessNotification(title, message)
      case NotificationType.WARNING:
        return new WarningNotification(title, message)
      case NotificationType.ERROR:
        return new ErrorNotification(title, message)
      default:
        return new InfoNotification(title, message)
    }
  }
}

// 使用示例
const notification = NotificationFactory.create(
  NotificationType.SUCCESS,
  '操作成功',
  '数据已保存'
)
notification.show()
```

---

## 观察者模式

### 事件总线

```typescript
/**
 * 事件处理器类型
 */
type EventHandler<T = any> = (data: T) => void

/**
 * 事件总线 - 观察者模式实现
 */
export class EventBus {
  private static instance: EventBus | null = null
  private events: Map<string, EventHandler[]> = new Map()
  
  private constructor() {}
  
  public static getInstance(): EventBus {
    if (!EventBus.instance) {
      EventBus.instance = new EventBus()
    }
    return EventBus.instance
  }
  
  /**
   * 订阅事件
   */
  public on<T = any>(eventName: string, handler: EventHandler<T>): void {
    if (!this.events.has(eventName)) {
      this.events.set(eventName, [])
    }
    this.events.get(eventName)!.push(handler)
  }
  
  /**
   * 取消订阅
   */
  public off<T = any>(eventName: string, handler: EventHandler<T>): void {
    const handlers = this.events.get(eventName)
    if (handlers) {
      const index = handlers.indexOf(handler)
      if (index > -1) {
        handlers.splice(index, 1)
      }
    }
  }
  
  /**
   * 触发事件
   */
  public emit<T = any>(eventName: string, data: T): void {
    const handlers = this.events.get(eventName)
    if (handlers) {
      handlers.forEach(handler => {
        try {
          handler(data)
        } catch (error) {
          console.error(`事件处理器错误 [${eventName}]:`, error)
        }
      })
    }
  }
  
  /**
   * 订阅一次性事件
   */
  public once<T = any>(eventName: string, handler: EventHandler<T>): void {
    const onceHandler = (data: T) => {
      handler(data)
      this.off(eventName, onceHandler)
    }
    this.on(eventName, onceHandler)
  }
  
  /**
   * 清除所有订阅
   */
  public clear(): void {
    this.events.clear()
  }
}

// 使用示例
const eventBus = EventBus.getInstance()

// 订阅事件
eventBus.on('userLogin', (user) => {
  console.log('用户登录:', user)
})

// 触发事件
eventBus.emit('userLogin', { id: '1', name: 'Zhang San' })

// 取消订阅
// eventBus.off('userLogin', handler)
```

### 在组件中使用

```typescript
import { EventBus } from '../utils/EventBus'

@Entry
@Component
struct EventBusExample {
  @State message: string = ''
  private eventBus: EventBus = EventBus.getInstance()
  
  private messageHandler = (data: any) => {
    this.message = data.text
  }
  
  aboutToAppear() {
    // 订阅事件
    this.eventBus.on('newMessage', this.messageHandler)
  }
  
  aboutToDisappear() {
    // 取消订阅
    this.eventBus.off('newMessage', this.messageHandler)
  }
  
  build() {
    Column() {
      Text(this.message || '等待消息...')
        .fontSize(18)
        .margin({ bottom: 20 })
      
      Button('发送消息')
        .onClick(() => {
          this.eventBus.emit('newMessage', {
            text: `消息时间: ${new Date().toLocaleTimeString()}`
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## 策略模式

### 支付策略

```typescript
/**
 * 支付策略接口
 */
export interface PaymentStrategy {
  pay(amount: number): Promise<boolean>
  getName(): string
}

/**
 * 微信支付策略
 */
class WeChatPayStrategy implements PaymentStrategy {
  async pay(amount: number): Promise<boolean> {
    console.log(`微信支付: ¥${amount}`)
    // 调用微信支付 API
    return true
  }
  
  getName(): string {
    return '微信支付'
  }
}

/**
 * 支付宝支付策略
 */
class AlipayStrategy implements PaymentStrategy {
  async pay(amount: number): Promise<boolean> {
    console.log(`支付宝支付: ¥${amount}`)
    // 调用支付宝 API
    return true
  }
  
  getName(): string {
    return '支付宝'
  }
}

/**
 * 银行卡支付策略
 */
class BankCardStrategy implements PaymentStrategy {
  async pay(amount: number): Promise<boolean> {
    console.log(`银行卡支付: ¥${amount}`)
    // 调用银行卡支付 API
    return true
  }
  
  getName(): string {
    return '银行卡'
  }
}

/**
 * 支付上下文
 */
export class PaymentContext {
  private strategy: PaymentStrategy | null = null
  
  setStrategy(strategy: PaymentStrategy): void {
    this.strategy = strategy
  }
  
  async executePayment(amount: number): Promise<boolean> {
    if (!this.strategy) {
      throw new Error('未设置支付策略')
    }
    
    console.log(`使用 ${this.strategy.getName()} 进行支付`)
    return await this.strategy.pay(amount)
  }
}

// 使用示例
const paymentContext = new PaymentContext()

// 选择支付方式
paymentContext.setStrategy(new WeChatPayStrategy())
await paymentContext.executePayment(99.99)

// 切换支付方式
paymentContext.setStrategy(new AlipayStrategy())
await paymentContext.executePayment(199.99)
```

---

## 依赖注入

### 简单的 DI 容器

```typescript
/**
 * 依赖注入容器
 */
export class DIContainer {
  private static instance: DIContainer | null = null
  private services: Map<string, any> = new Map()
  private factories: Map<string, () => any> = new Map()
  
  private constructor() {}
  
  public static getInstance(): DIContainer {
    if (!DIContainer.instance) {
      DIContainer.instance = new DIContainer()
    }
    return DIContainer.instance
  }
  
  /**
   * 注册单例服务
   */
  public registerSingleton<T>(key: string, instance: T): void {
    this.services.set(key, instance)
  }
  
  /**
   * 注册工厂函数
   */
  public registerFactory<T>(key: string, factory: () => T): void {
    this.factories.set(key, factory)
  }
  
  /**
   * 解析服务
   */
  public resolve<T>(key: string): T {
    // 先检查单例
    if (this.services.has(key)) {
      return this.services.get(key)
    }
    
    // 然后检查工厂
    if (this.factories.has(key)) {
      const factory = this.factories.get(key)!
      const instance = factory()
      this.services.set(key, instance) // 缓存实例
      return instance
    }
    
    throw new Error(`服务未注册: ${key}`)
  }
  
  /**
   * 检查服务是否已注册
   */
  public has(key: string): boolean {
    return this.services.has(key) || this.factories.has(key)
  }
  
  /**
   * 清除容器
   */
  public clear(): void {
    this.services.clear()
    this.factories.clear()
  }
}

// 使用示例

// 注册服务
const container = DIContainer.getInstance()

container.registerFactory('httpClient', () => {
  return new HttpClient('https://api.example.com')
})

container.registerSingleton('logger', new Logger())

// 解析服务
const httpClient = container.resolve<HttpClient>('httpClient')
const logger = container.resolve<Logger>('logger')
```

---

## Repository 模式

### 数据仓库抽象

```typescript
/**
 * 通用仓库接口
 */
export interface IRepository<T> {
  getAll(): Promise<T[]>
  getById(id: string): Promise<T | null>
  create(entity: T): Promise<T>
  update(id: string, entity: T): Promise<T>
  delete(id: string): Promise<boolean>
}

/**
 * 用户仓库实现
 */
export class UserRepository implements IRepository<User> {
  private httpClient: HttpClient
  private baseUrl: string = '/users'
  
  constructor() {
    this.httpClient = DIContainer.getInstance().resolve<HttpClient>('httpClient')
  }
  
  async getAll(): Promise<User[]> {
    const response = await this.httpClient.get(this.baseUrl)
    return response.data.map((item: any) => User.fromJSON(item))
  }
  
  async getById(id: string): Promise<User | null> {
    try {
      const response = await this.httpClient.get(`${this.baseUrl}/${id}`)
      return User.fromJSON(response.data)
    } catch (error) {
      console.error('获取用户失败:', error)
      return null
    }
  }
  
  async create(user: User): Promise<User> {
    const response = await this.httpClient.post(this.baseUrl, user.toJSON())
    return User.fromJSON(response.data)
  }
  
  async update(id: string, user: User): Promise<User> {
    const response = await this.httpClient.put(`${this.baseUrl}/${id}`, user.toJSON())
    return User.fromJSON(response.data)
  }
  
  async delete(id: string): Promise<boolean> {
    try {
      await this.httpClient.delete(`${this.baseUrl}/${id}`)
      return true
    } catch (error) {
      console.error('删除用户失败:', error)
      return false
    }
  }
}
```

---

## 完整应用架构

### 项目结构

```
src/main/ets/
├── models/              # 数据模型
│   ├── User.ets
│   └── Product.ets
├── repositories/        # 数据仓库
│   ├── UserRepository.ets
│   └── ProductRepository.ets
├── viewmodels/          # 视图模型
│   ├── UserListViewModel.ets
│   └── ProductListViewModel.ets
├── views/               # 视图组件
│   ├── UserListView.ets
│   └── ProductListView.ets
├── pages/               # 页面
│   ├── Index.ets
│   └── DetailPage.ets
├── services/            # 业务服务
│   ├── AuthService.ets
│   └── ConfigService.ets
├── utils/               # 工具类
│   ├── EventBus.ets
│   ├── DIContainer.ets
│   └── HttpClient.ets
└── constants/           # 常量定义
    └── AppConstants.ets
```

### 架构图

```
┌─────────────┐
│   Pages    │ ← 页面入口
└──────┬──────┘
       │
┌──────▼──────┐
│    Views   │ ← UI 组件
└──────┬──────┘
       │
┌──────▼──────┐
│ ViewModels │ ← 业务逻辑
└──────┬──────┘
       │
┌──────▼──────┐
│Repositories│ ← 数据访问
└──────┬──────┘
       │
┌──────▼──────┐
│   Models   │ ← 数据模型
└─────────────┘
```

---

## 最佳实践

### 1. 架构选择
- ✅ 小型项目使用简单 MVVM
- ✅ 中大型项目添加 Repository 层
- ✅ 复杂业务使用 Clean Architecture
- ✅ 保持层次清晰，职责分离

### 2. 设计模式
- ✅ 合理使用设计模式，避免过度设计
- ✅ 优先使用组合而非继承
- ✅ 依赖抽象而非具体实现
- ✅ 保持代码简洁易懂

### 3. 代码组织
- ✅ 按功能模块组织代码
- ✅ 使用清晰的命名约定
- ✅ 保持文件大小适中
- ✅ 避免循环依赖

### 4. 测试友好
- ✅ 使用依赖注入便于测试
- ✅ 接口化设计方便 Mock
- ✅ 避免全局状态
- ✅ 保持函数纯净

---

**构建可维护的应用架构！** 🏗️


