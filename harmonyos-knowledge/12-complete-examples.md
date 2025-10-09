# 完整应用示例

## 示例 1：待办事项应用

### 数据模型

```typescript
// models/TodoModel.ets
export enum TodoStatus {
  PENDING = 'pending',
  COMPLETED = 'completed'
}

@Observed
export class TodoItem {
  id: string
  title: string
  description: string
  status: TodoStatus
  createdTime: Date
  completedTime?: Date

  constructor(title: string, description: string = '') {
    this.id = Date.now().toString()
    this.title = title
    this.description = description
    this.status = TodoStatus.PENDING
    this.createdTime = new Date()
  }

  toggle() {
    if (this.status === TodoStatus.PENDING) {
      this.status = TodoStatus.COMPLETED
      this.completedTime = new Date()
    } else {
      this.status = TodoStatus.PENDING
      this.completedTime = undefined
    }
  }
}
```

### 数据服务

```typescript
// services/TodoService.ets
import preferences from '@ohos.data.preferences'
import { TodoItem, TodoStatus } from '../models/TodoModel'

export class TodoService {
  private static instance: TodoService
  private preferences: preferences.Preferences | null = null
  private readonly STORAGE_KEY = 'todos'

  private constructor() {}

  static getInstance(): TodoService {
    if (!TodoService.instance) {
      TodoService.instance = new TodoService()
    }
    return TodoService.instance
  }

  async init(context: Context) {
    this.preferences = await preferences.getPreferences(context, 'TodoStorage')
  }

  // 获取所有待办
  async getAllTodos(): Promise<TodoItem[]> {
    try {
      const data = await this.preferences?.get(this.STORAGE_KEY, '[]')
      const todos = JSON.parse(data as string)
      return todos.map((item: any) => Object.assign(new TodoItem(''), item))
    } catch (error) {
      console.error('获取待办失败:', error)
      return []
    }
  }

  // 添加待办
  async addTodo(todo: TodoItem): Promise<void> {
    const todos = await this.getAllTodos()
    todos.unshift(todo)
    await this.saveTodos(todos)
  }

  // 更新待办
  async updateTodo(todo: TodoItem): Promise<void> {
    const todos = await this.getAllTodos()
    const index = todos.findIndex(t => t.id === todo.id)
    if (index !== -1) {
      todos[index] = todo
      await this.saveTodos(todos)
    }
  }

  // 删除待办
  async deleteTodo(id: string): Promise<void> {
    const todos = await this.getAllTodos()
    const filtered = todos.filter(t => t.id !== id)
    await this.saveTodos(todos)
  }

  // 保存待办列表
  private async saveTodos(todos: TodoItem[]): Promise<void> {
    await this.preferences?.put(this.STORAGE_KEY, JSON.stringify(todos))
    await this.preferences?.flush()
  }
}
```

### 主页面

```typescript
// pages/TodoListPage.ets
import { TodoItem, TodoStatus } from '../models/TodoModel'
import { TodoService } from '../services/TodoService'

@Entry
@Component
struct TodoListPage {
  @State todos: TodoItem[] = []
  @State filterStatus: TodoStatus | 'all' = 'all'
  @State showAddDialog: boolean = false
  private todoService: TodoService = TodoService.getInstance()

  async aboutToAppear() {
    await this.todoService.init(getContext(this))
    await this.loadTodos()
  }

  build() {
    Column() {
      // 顶部栏
      this.buildHeader()

      // 筛选标签
      this.buildFilterTabs()

      // 待办列表
      this.buildTodoList()

      // 添加按钮
      this.buildAddButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildHeader() {
    Row() {
      Text('我的待办')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

      Text(`${this.getCompletedCount()}/${this.todos.length}`)
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildFilterTabs() {
    Row({ space: 16 }) {
      this.buildTab('全部', 'all')
      this.buildTab('待完成', TodoStatus.PENDING)
      this.buildTab('已完成', TodoStatus.COMPLETED)
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .margin({ top: 8 })
  }

  @Builder
  buildTab(title: string, status: TodoStatus | 'all') {
    Text(title)
      .fontSize(14)
      .fontColor(this.filterStatus === status ? '#007DFF' : '#333333')
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
      .backgroundColor(this.filterStatus === status ? '#E6F2FF' : Color.Transparent)
      .borderRadius(16)
      .onClick(() => {
        this.filterStatus = status
      })
  }

  @Builder
  buildTodoList() {
    List() {
      ForEach(this.getFilteredTodos(), (todo: TodoItem) => {
        ListItem() {
          this.buildTodoItem(todo)
        }
        .swipeAction({ end: this.buildDeleteButton(todo) })
      }, (todo: TodoItem) => todo.id)
    }
    .layoutWeight(1)
    .width('100%')
    .margin({ top: 8 })
    .divider({ strokeWidth: 1, color: '#F0F0F0' })
  }

  @Builder
  buildTodoItem(todo: TodoItem) {
    Row({ space: 12 }) {
      // 复选框
      Checkbox()
        .select(todo.status === TodoStatus.COMPLETED)
        .onChange((isChecked: boolean) => {
          todo.toggle()
          this.todoService.updateTodo(todo)
        })

      // 内容
      Column({ space: 4 }) {
        Text(todo.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .decoration({
            type: todo.status === TodoStatus.COMPLETED ? TextDecorationType.LineThrough : TextDecorationType.None
          })

        if (todo.description) {
          Text(todo.description)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
        }

        Text(this.formatTime(todo.createdTime))
          .fontSize(12)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  @Builder
  buildDeleteButton(todo: TodoItem) {
    Button('删除')
      .width(80)
      .height('100%')
      .backgroundColor('#FF0000')
      .onClick(() => {
        this.deleteTodo(todo)
      })
  }

  @Builder
  buildAddButton() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Button() {
        Image($r('app.media.ic_add'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
      }
      .width(56)
      .height(56)
      .type(ButtonType.Circle)
      .backgroundColor('#007DFF')
      .margin({ right: 24, bottom: 24 })
      .shadow({ radius: 12, color: 0x40000000, offsetY: 4 })
      .onClick(() => {
        this.showAddDialog = true
      })
    }
    .width('100%')
    .height(80)
  }

  async loadTodos() {
    this.todos = await this.todoService.getAllTodos()
  }

  getFilteredTodos(): TodoItem[] {
    if (this.filterStatus === 'all') {
      return this.todos
    }
    return this.todos.filter(todo => todo.status === this.filterStatus)
  }

  getCompletedCount(): number {
    return this.todos.filter(todo => todo.status === TodoStatus.COMPLETED).length
  }

  async deleteTodo(todo: TodoItem) {
    await this.todoService.deleteTodo(todo.id)
    await this.loadTodos()
  }

  formatTime(date: Date): string {
    const now = new Date()
    const diff = now.getTime() - new Date(date).getTime()
    const minutes = Math.floor(diff / 60000)

    if (minutes < 1) return '刚刚'
    if (minutes < 60) return `${minutes}分钟前`
    if (minutes < 1440) return `${Math.floor(minutes / 60)}小时前`
    return `${Math.floor(minutes / 1440)}天前`
  }
}
```

## 示例 2：天气应用

### 数据模型

```typescript
// models/WeatherModel.ets
export interface WeatherInfo {
  city: string
  temperature: number
  weather: string
  windDirection: string
  windPower: string
  humidity: string
  reportTime: string
}

export interface ForecastDay {
  date: string
  week: string
  dayWeather: string
  nightWeather: string
  dayTemp: string
  nightTemp: string
}
```

### 天气服务

```typescript
// services/WeatherService.ets
import http from '@ohos.net.http'
import { WeatherInfo, ForecastDay } from '../models/WeatherModel'

export class WeatherService {
  private static readonly API_KEY = 'your_api_key'
  private static readonly BASE_URL = 'https://restapi.amap.com/v3'

  // 获取当前天气
  static async getCurrentWeather(city: string): Promise<WeatherInfo> {
    try {
      const url = `${this.BASE_URL}/weather/weatherInfo?city=${city}&key=${this.API_KEY}`
      const httpRequest = http.createHttp()
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET
      })

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string)
        return data.lives[0] as WeatherInfo
      } else {
        throw new Error('获取天气失败')
      }
    } catch (error) {
      console.error('获取天气失败:', error)
      throw error
    }
  }

  // 获取天气预报
  static async getWeatherForecast(city: string): Promise<ForecastDay[]> {
    try {
      const url = `${this.BASE_URL}/weather/weatherInfo?city=${city}&key=${this.API_KEY}&extensions=all`
      const httpRequest = http.createHttp()
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET
      })

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string)
        return data.forecasts[0].casts as ForecastDay[]
      } else {
        throw new Error('获取预报失败')
      }
    } catch (error) {
      console.error('获取预报失败:', error)
      throw error
    }
  }
}
```

### 天气页面

```typescript
// pages/WeatherPage.ets
import { WeatherInfo, ForecastDay } from '../models/WeatherModel'
import { WeatherService } from '../services/WeatherService'

@Entry
@Component
struct WeatherPage {
  @State currentCity: string = '北京'
  @State weatherInfo: WeatherInfo | null = null
  @State forecast: ForecastDay[] = []
  @State isLoading: boolean = false

  aboutToAppear() {
    this.loadWeather()
  }

  build() {
    Column() {
      if (this.isLoading) {
        this.buildLoading()
      } else if (this.weatherInfo) {
        this.buildWeatherContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.weather_bg'))
    .backgroundImageSize(ImageSize.Cover)
  }

  @Builder
  buildLoading() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(Color.White)
      
      Text('加载中...')
        .fontSize(16)
        .fontColor(Color.White)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildWeatherContent() {
    Column() {
      // 顶部城市选择
      Row() {
        Text(this.currentCity)
          .fontSize(20)
          .fontColor(Color.White)
        
        Image($r('app.media.ic_location'))
          .width(20)
          .height(20)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)

      // 当前温度
      Column() {
        Text(`${this.weatherInfo!.temperature}°`)
          .fontSize(80)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Text(this.weatherInfo!.weather)
          .fontSize(24)
          .fontColor(Color.White)
          .margin({ top: 16 })
      }
      .margin({ top: 60 })

      // 详细信息
      Row({ space: 40 }) {
        this.buildInfoItem('湿度', this.weatherInfo!.humidity)
        this.buildInfoItem('风向', this.weatherInfo!.windDirection)
        this.buildInfoItem('风力', this.weatherInfo!.windPower)
      }
      .margin({ top: 60 })

      // 未来天气预报
      Column() {
        Text('未来预报')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 16 })

        List() {
          ForEach(this.forecast, (day: ForecastDay) => {
            ListItem() {
              this.buildForecastItem(day)
            }
          })
        }
        .width('100%')
      }
      .width('90%')
      .padding(20)
      .backgroundColor(0x80FFFFFF)
      .borderRadius(16)
      .margin({ top: 60 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildInfoItem(label: string, value: string) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor(0xCCFFFFFF)
      
      Text(value)
        .fontSize(16)
        .fontColor(Color.White)
    }
  }

  @Builder
  buildForecastItem(day: ForecastDay) {
    Row() {
      Text(day.week)
        .fontSize(14)
        .fontColor('#333333')
        .width(60)
      
      Text(day.dayWeather)
        .fontSize(14)
        .fontColor('#666666')
        .layoutWeight(1)
      
      Text(`${day.nightTemp}° ~ ${day.dayTemp}°`)
        .fontSize(14)
        .fontColor('#333333')
    }
    .width('100%')
    .height(44)
  }

  async loadWeather() {
    this.isLoading = true
    
    try {
      this.weatherInfo = await WeatherService.getCurrentWeather(this.currentCity)
      this.forecast = await WeatherService.getWeatherForecast(this.currentCity)
    } catch (error) {
      console.error('加载天气失败:', error)
    } finally {
      this.isLoading = false
    }
  }
}
```

## 示例 3：购物车应用

### 商品模型

```typescript
// models/ProductModel.ets
@Observed
export class Product {
  id: string
  name: string
  price: number
  image: string
  description: string
  stock: number

  constructor(id: string, name: string, price: number, image: string, description: string = '', stock: number = 100) {
    this.id = id
    this.name = name
    this.price = price
    this.image = image
    this.description = description
    this.stock = stock
  }
}

@Observed
export class CartItem {
  product: Product
  quantity: number
  selected: boolean

  constructor(product: Product, quantity: number = 1) {
    this.product = product
    this.quantity = quantity
    this.selected = true
  }

  get totalPrice(): number {
    return this.product.price * this.quantity
  }
}
```

### 购物车服务

```typescript
// services/CartService.ets
import { Product, CartItem } from '../models/ProductModel'

export class CartService {
  private static instance: CartService
  @State items: CartItem[] = []

  private constructor() {}

  static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService()
    }
    return CartService.instance
  }

  // 添加到购物车
  addToCart(product: Product, quantity: number = 1) {
    const existingItem = this.items.find(item => item.product.id === product.id)
    
    if (existingItem) {
      existingItem.quantity += quantity
    } else {
      this.items.push(new CartItem(product, quantity))
    }
  }

  // 移除商品
  removeItem(productId: string) {
    const index = this.items.findIndex(item => item.product.id === productId)
    if (index !== -1) {
      this.items.splice(index, 1)
    }
  }

  // 更新数量
  updateQuantity(productId: string, quantity: number) {
    const item = this.items.find(item => item.product.id === productId)
    if (item) {
      item.quantity = Math.max(1, quantity)
    }
  }

  // 切换选中状态
  toggleSelect(productId: string) {
    const item = this.items.find(item => item.product.id === productId)
    if (item) {
      item.selected = !item.selected
    }
  }

  // 全选/取消全选
  toggleSelectAll() {
    const allSelected = this.items.every(item => item.selected)
    this.items.forEach(item => item.selected = !allSelected)
  }

  // 获取选中商品总价
  getSelectedTotalPrice(): number {
    return this.items
      .filter(item => item.selected)
      .reduce((total, item) => total + item.totalPrice, 0)
  }

  // 获取选中商品数量
  getSelectedCount(): number {
    return this.items.filter(item => item.selected).length
  }

  // 清空购物车
  clear() {
    this.items = []
  }
}
```

### 购物车页面

```typescript
// pages/ShoppingCartPage.ets
import { CartItem } from '../models/ProductModel'
import { CartService } from '../services/CartService'

@Entry
@Component
struct ShoppingCartPage {
  private cartService: CartService = CartService.getInstance()

  build() {
    Column() {
      // 顶部栏
      this.buildHeader()

      if (this.cartService.items.length === 0) {
        this.buildEmptyCart()
      } else {
        // 购物车列表
        this.buildCartList()

        // 底部结算栏
        this.buildBottomBar()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildHeader() {
    Row() {
      Text('购物车')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
      
      Text('管理')
        .fontSize(14)
        .fontColor('#007DFF')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildEmptyCart() {
    Column() {
      Image($r('app.media.ic_empty_cart'))
        .width(120)
        .height(120)
      
      Text('购物车是空的')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })
      
      Button('去逛逛')
        .margin({ top: 30 })
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildCartList() {
    List() {
      ForEach(this.cartService.items, (item: CartItem) => {
        ListItem() {
          this.buildCartItem(item)
        }
        .swipeAction({ end: this.buildDeleteButton(item) })
      }, (item: CartItem) => item.product.id)
    }
    .layoutWeight(1)
    .width('100%')
    .divider({ strokeWidth: 8, color: '#F5F5F5' })
  }

  @Builder
  buildCartItem(item: CartItem) {
    Row({ space: 12 }) {
      // 复选框
      Checkbox()
        .select(item.selected)
        .onChange((isChecked: boolean) => {
          this.cartService.toggleSelect(item.product.id)
        })

      // 商品图片
      Image(item.product.image)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 商品信息
      Column({ space: 8 }) {
        Text(item.product.name)
          .fontSize(14)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`¥${item.product.price}`)
          .fontSize(16)
          .fontColor('#FF0000')
          .fontWeight(FontWeight.Bold)

        // 数量控制
        Row({ space: 12 }) {
          Button('-')
            .width(28)
            .height(28)
            .fontSize(16)
            .backgroundColor('#F5F5F5')
            .fontColor('#333333')
            .onClick(() => {
              this.cartService.updateQuantity(item.product.id, item.quantity - 1)
            })

          Text(item.quantity.toString())
            .fontSize(14)
            .width(40)
            .textAlign(TextAlign.Center)

          Button('+')
            .width(28)
            .height(28)
            .fontSize(16)
            .backgroundColor('#F5F5F5')
            .fontColor('#333333')
            .onClick(() => {
              this.cartService.updateQuantity(item.product.id, item.quantity + 1)
            })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  @Builder
  buildDeleteButton(item: CartItem) {
    Button('删除')
      .width(80)
      .height('100%')
      .backgroundColor('#FF0000')
      .onClick(() => {
        this.cartService.removeItem(item.product.id)
      })
  }

  @Builder
  buildBottomBar() {
    Row() {
      // 全选
      Row({ space: 8 }) {
        Checkbox()
          .select(this.cartService.items.every(item => item.selected))
          .onChange(() => {
            this.cartService.toggleSelectAll()
          })
        
        Text('全选')
          .fontSize(14)
      }

      Blank()

      // 总价和结算
      Row({ space: 16 }) {
        Column({ space: 4 }) {
          Text('合计:')
            .fontSize(12)
            .fontColor('#666666')
          
          Text(`¥${this.cartService.getSelectedTotalPrice().toFixed(2)}`)
            .fontSize(18)
            .fontColor('#FF0000')
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(HorizontalAlign.End)

        Button(`结算(${this.cartService.getSelectedCount()})`)
          .height(44)
          .backgroundColor('#FF0000')
          .onClick(() => {
            // 跳转到结算页面
          })
      }
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#F0F0F0' })
  }
}
```

## 总结

这些完整示例展示了：

1. **数据管理**：使用 Preferences 持久化存储
2. **服务层**：封装业务逻辑和 API 调用
3. **状态管理**：使用 @State、@Observed、@ObjectLink
4. **组件化**：拆分可复用组件
5. **用户交互**：滑动删除、下拉刷新等
6. **网络请求**：HTTP 请求和错误处理
7. **UI 设计**：现代化的界面设计

## 下一步

恭喜你完成了 HarmonyOS Next 开发知识库的学习！现在你可以：

1. 结合这些示例开发自己的应用
2. 参考官方文档深入学习特定功能
3. 加入开发者社区交流经验
4. 持续关注 HarmonyOS 生态更新

