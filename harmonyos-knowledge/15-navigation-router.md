# 导航和路由完整指南

> 本文档详细介绍 HarmonyOS Next 中的页面导航和路由管理，包括 Router 页面路由、Navigation 组件导航、底部导航栏实现等。

---

## 目录
- [Router 页面路由](#router-页面路由)
- [Navigation 组件](#navigation-组件)
- [页面参数传递](#页面参数传递)
- [底部导航栏实现](#底部导航栏实现)
- [Tab 页签导航](#tab-页签导航)
- [页面转场动画](#页面转场动画)
- [路由拦截器](#路由拦截器)
- [深度链接](#深度链接)
- [完整应用示例](#完整应用示例)

---

## Router 页面路由

### 基础路由跳转

Router 是 HarmonyOS 提供的页面路由管理器，用于页面间的跳转。

```typescript
import router from '@ohos.router'

@Entry
@Component
struct HomePage {
  build() {
    Column() {
      Text('首页')
        .fontSize(24)
        .margin({ bottom: 20 })
      
      // 跳转到详情页
      Button('跳转到详情页')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/DetailPage'
          })
        })
      
      // 跳转并传递参数
      Button('跳转并传参')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/DetailPage',
            params: {
              id: 123,
              name: '商品名称',
              price: 99.9
            }
          })
        })
      
      // 替换当前页面
      Button('替换页面')
        .onClick(() => {
          router.replaceUrl({
            url: 'pages/LoginPage'
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 页面返回

```typescript
@Entry
@Component
struct DetailPage {
  @State pageParams: object = {}
  
  aboutToAppear() {
    // 获取页面参数
    this.pageParams = router.getParams() || {}
  }
  
  build() {
    Column() {
      Text('详情页')
        .fontSize(24)
      
      Text(`接收到的参数: ${JSON.stringify(this.pageParams)}`)
        .margin({ top: 20 })
      
      // 返回上一页
      Button('返回')
        .onClick(() => {
          router.back()
        })
      
      // 返回并携带数据
      Button('返回并携带数据')
        .onClick(() => {
          router.back({
            url: 'pages/HomePage',
            params: {
              result: 'success',
              data: '处理结果'
            }
          })
        })
      
      // 返回到指定页面
      Button('返回到首页')
        .onClick(() => {
          router.clear() // 清空路由栈
          router.pushUrl({
            url: 'pages/Index'
          })
        })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

---

## Navigation 组件

Navigation 组件提供了更强大的导航能力，支持标题栏、工具栏、返回按钮等。

### 基础 Navigation

```typescript
@Entry
@Component
struct NavigationExample {
  build() {
    Navigation() {
      Column() {
        Text('页面内容')
          .fontSize(20)
      }
      .width('100%')
      .height('100%')
    }
    .title('页面标题')
    .titleMode(NavigationTitleMode.Mini)
    .menus([
      {
        value: '搜索',
        icon: 'common/ic_search.png',
        action: () => {
          console.info('点击搜索')
        }
      },
      {
        value: '更多',
        icon: 'common/ic_more.png',
        action: () => {
          console.info('点击更多')
        }
      }
    ])
  }
}
```

### 自定义标题栏

```typescript
@Entry
@Component
struct CustomNavigationBar {
  @Builder
  CustomTitle() {
    Row() {
      Image($r('app.media.app_icon'))
        .width(30)
        .height(30)
        .margin({ right: 10 })
      
      Text('自定义标题')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
    }
  }
  
  build() {
    Navigation() {
      Column() {
        Text('页面内容')
      }
      .width('100%')
      .height('100%')
    }
    .title(this.CustomTitle())
    .titleMode(NavigationTitleMode.Full)
    .hideBackButton(false)
    .onTitleModeChange((titleModel: NavigationTitleMode) => {
      console.info('titleModel:' + titleModel)
    })
  }
}
```

### 带工具栏的 Navigation

```typescript
@Entry
@Component
struct NavigationWithToolbar {
  @State currentIndex: number = 0
  
  @Builder
  ToolbarBuilder() {
    Row() {
      ForEach([
        { icon: $r('app.media.home'), text: '首页' },
        { icon: $r('app.media.category'), text: '分类' },
        { icon: $r('app.media.cart'), text: '购物车' },
        { icon: $r('app.media.profile'), text: '我的' }
      ], (item: any, index: number) => {
        Column() {
          Image(item.icon)
            .width(24)
            .height(24)
            .fillColor(this.currentIndex === index ? '#1890ff' : '#666')
          
          Text(item.text)
            .fontSize(12)
            .fontColor(this.currentIndex === index ? '#1890ff' : '#666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentIndex = index
        })
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor('#fff')
  }
  
  build() {
    Navigation() {
      Column() {
        Text(`当前选中: ${this.currentIndex}`)
          .fontSize(20)
      }
      .width('100%')
      .height('100%')
    }
    .title('应用')
    .toolBar(this.ToolbarBuilder())
  }
}
```

---

## 页面参数传递

### 简单参数传递

```typescript
// 发送页面
@Entry
@Component
struct SenderPage {
  build() {
    Column() {
      Button('传递字符串')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ReceiverPage',
            params: {
              message: 'Hello World'
            }
          })
        })
      
      Button('传递对象')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ReceiverPage',
            params: {
              user: {
                id: 1,
                name: '张三',
                age: 25
              }
            }
          })
        })
      
      Button('传递数组')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ReceiverPage',
            params: {
              items: ['苹果', '香蕉', '橙子']
            }
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
}
```

```typescript
// 接收页面
interface RouterParams {
  message?: string
  user?: {
    id: number
    name: string
    age: number
  }
  items?: string[]
}

@Entry
@Component
struct ReceiverPage {
  @State params: RouterParams = {}
  
  aboutToAppear() {
    this.params = router.getParams() as RouterParams
  }
  
  build() {
    Column() {
      Text('接收到的参数:')
        .fontSize(20)
        .margin({ bottom: 20 })
      
      if (this.params.message) {
        Text(`消息: ${this.params.message}`)
      }
      
      if (this.params.user) {
        Text(`用户: ${this.params.user.name}, 年龄: ${this.params.user.age}`)
      }
      
      if (this.params.items) {
        Text(`数组: ${this.params.items.join(', ')}`)
      }
      
      Button('返回')
        .onClick(() => {
          router.back()
        })
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

---

## 底部导航栏实现

### 使用 Tabs 实现

```typescript
@Entry
@Component
struct BottomTabNavigation {
  @State currentIndex: number = 0
  
  @Builder
  TabBarBuilder(title: string, icon: Resource, activeIcon: Resource, index: number) {
    Column() {
      Image(this.currentIndex === index ? activeIcon : icon)
        .width(24)
        .height(24)
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#1890ff' : '#666')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
  
  build() {
    Tabs({ index: this.currentIndex }) {
      TabContent() {
        HomePage()
      }
      .tabBar(this.TabBarBuilder('首页', $r('app.media.home'), $r('app.media.home_active'), 0))
      
      TabContent() {
        CategoryPage()
      }
      .tabBar(this.TabBarBuilder('分类', $r('app.media.category'), $r('app.media.category_active'), 1))
      
      TabContent() {
        CartPage()
      }
      .tabBar(this.TabBarBuilder('购物车', $r('app.media.cart'), $r('app.media.cart_active'), 2))
      
      TabContent() {
        ProfilePage()
      }
      .tabBar(this.TabBarBuilder('我的', $r('app.media.profile'), $r('app.media.profile_active'), 3))
    }
    .barPosition(BarPosition.End)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}

// 各个页面组件
@Component
struct HomePage {
  build() {
    Column() {
      Text('首页')
        .fontSize(24)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct CategoryPage {
  build() {
    Column() {
      Text('分类')
        .fontSize(24)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct CartPage {
  build() {
    Column() {
      Text('购物车')
        .fontSize(24)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct ProfilePage {
  build() {
    Column() {
      Text('我的')
        .fontSize(24)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 带徽标的底部导航

```typescript
@Entry
@Component
struct BottomTabWithBadge {
  @State currentIndex: number = 0
  @State cartCount: number = 5
  @State messageCount: number = 99
  
  @Builder
  TabBarWithBadge(title: string, icon: Resource, index: number, badgeCount?: number) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(this.currentIndex === index ? '#1890ff' : '#666')
        
        Text(title)
          .fontSize(12)
          .fontColor(this.currentIndex === index ? '#1890ff' : '#666')
          .margin({ top: 4 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      
      if (badgeCount && badgeCount > 0) {
        Text(badgeCount > 99 ? '99+' : badgeCount.toString())
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor('#ff4d4f')
          .borderRadius(10)
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .position({ x: '50%', y: 0 })
          .translate({ x: 5, y: -5 })
      }
    }
    .width('100%')
    .height('100%')
  }
  
  build() {
    Tabs({ index: this.currentIndex }) {
      TabContent() {
        Text('首页内容')
      }
      .tabBar(this.TabBarWithBadge('首页', $r('app.media.home'), 0))
      
      TabContent() {
        Text('消息内容')
      }
      .tabBar(this.TabBarWithBadge('消息', $r('app.media.message'), 1, this.messageCount))
      
      TabContent() {
        Text('购物车内容')
      }
      .tabBar(this.TabBarWithBadge('购物车', $r('app.media.cart'), 2, this.cartCount))
      
      TabContent() {
        Text('我的内容')
      }
      .tabBar(this.TabBarWithBadge('我的', $r('app.media.profile'), 3))
    }
    .barPosition(BarPosition.End)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}
```

---

## Tab 页签导航

### 基础 Tab 页签

```typescript
@Entry
@Component
struct BasicTabs {
  @State currentIndex: number = 0
  
  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          Text('推荐内容')
            .fontSize(20)
        }
        .tabBar('推荐')
        
        TabContent() {
          Text('关注内容')
            .fontSize(20)
        }
        .tabBar('关注')
        
        TabContent() {
          Text('热榜内容')
            .fontSize(20)
        }
        .tabBar('热榜')
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentIndex = index
        console.info('Tab切换到:' + index)
      })
    }
  }
}
```

### 可滚动的 Tab 页签

```typescript
@Entry
@Component
struct ScrollableTabs {
  @State currentIndex: number = 0
  private categories: string[] = [
    '推荐', '热点', '科技', '娱乐', '体育', 
    '财经', '军事', '汽车', '时尚', '游戏'
  ]
  
  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        ForEach(this.categories, (category: string, index: number) => {
          TabContent() {
            Column() {
              Text(`${category}内容`)
                .fontSize(20)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
          .tabBar(category)
        })
      }
      .barMode(BarMode.Scrollable)
      .barWidth('100%')
      .barHeight(56)
      .animationDuration(300)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
  }
}
```

### 自定义 Tab 样式

```typescript
@Entry
@Component
struct CustomTabStyle {
  @State currentIndex: number = 0
  
  @Builder
  CustomTabBar(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(this.currentIndex === index ? 18 : 16)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? '#1890ff' : '#666')
      
      // 选中时显示下划线
      if (this.currentIndex === index) {
        Divider()
          .width(30)
          .height(3)
          .color('#1890ff')
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 10, bottom: 10 })
  }
  
  build() {
    Column() {
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          Text('推荐内容')
        }
        .tabBar(this.CustomTabBar('推荐', 0))
        
        TabContent() {
          Text('视频内容')
        }
        .tabBar(this.CustomTabBar('视频', 1))
        
        TabContent() {
          Text('直播内容')
        }
        .tabBar(this.CustomTabBar('直播', 2))
        
        TabContent() {
          Text('图片内容')
        }
        .tabBar(this.CustomTabBar('图片', 3))
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
  }
}
```

---

## 页面转场动画

### 自定义页面转场

```typescript
// 页面转场需要在 module.json5 中配置
// "pageTransition": {
//   "enterAnimation": "translate",
//   "exitAnimation": "fade"
// }

@Entry
@Component
struct PageTransitionExample {
  // 页面转场效果
  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    
    PageTransitionExit({ duration: 300, curve: Curve.EaseIn })
      .slide(SlideEffect.Left)
  }
  
  build() {
    Column() {
      Text('带转场动画的页面')
        .fontSize(24)
      
      Button('跳转到下一页')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/NextPage'
          })
        })
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 共享元素转场

```typescript
// 列表页
@Entry
@Component
struct ListPageWithSharedElement {
  private items: Array<{ id: number, title: string, image: Resource }> = [
    { id: 1, title: '商品1', image: $r('app.media.product1') },
    { id: 2, title: '商品2', image: $r('app.media.product2') },
    { id: 3, title: '商品3', image: $r('app.media.product3') }
  ]
  
  build() {
    List() {
      ForEach(this.items, (item: any) => {
        ListItem() {
          Row() {
            Image(item.image)
              .width(80)
              .height(80)
              .borderRadius(8)
              .sharedTransition(`image_${item.id}`, {
                duration: 300,
                curve: Curve.EaseInOut
              })
            
            Text(item.title)
              .fontSize(16)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding(12)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ProductDetail',
              params: { product: item }
            })
          })
        }
      })
    }
  }
}

// 详情页
@Entry
@Component
struct ProductDetailWithSharedElement {
  @State product: any = {}
  
  aboutToAppear() {
    const params = router.getParams() as any
    this.product = params?.product || {}
  }
  
  build() {
    Column() {
      Image(this.product.image)
        .width('100%')
        .height(300)
        .sharedTransition(`image_${this.product.id}`, {
          duration: 300,
          curve: Curve.EaseInOut
        })
      
      Text(this.product.title)
        .fontSize(24)
        .margin({ top: 20 })
      
      Button('返回')
        .onClick(() => {
          router.back()
        })
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
  }
}
```

---

## 路由拦截器

### 实现路由守卫

```typescript
// 路由守卫服务
export class RouterGuard {
  private static isLoggedIn: boolean = false
  
  // 需要登录的页面列表
  private static authRequiredPages: string[] = [
    'pages/ProfilePage',
    'pages/OrderPage',
    'pages/SettingsPage'
  ]
  
  static setLoginStatus(status: boolean) {
    this.isLoggedIn = status
  }
  
  static getLoginStatus(): boolean {
    return this.isLoggedIn
  }
  
  // 路由跳转前检查
  static async navigateTo(url: string, params?: object): Promise<boolean> {
    // 检查是否需要登录
    if (this.authRequiredPages.includes(url) && !this.isLoggedIn) {
      // 跳转到登录页
      await router.pushUrl({
        url: 'pages/LoginPage',
        params: {
          redirectUrl: url,
          redirectParams: params
        }
      })
      return false
    }
    
    // 允许跳转
    await router.pushUrl({
      url: url,
      params: params
    })
    return true
  }
}

// 使用示例
@Entry
@Component
struct HomeWithGuard {
  build() {
    Column() {
      Button('访问个人中心')
        .onClick(() => {
          RouterGuard.navigateTo('pages/ProfilePage')
        })
      
      Button('访问订单页')
        .onClick(() => {
          RouterGuard.navigateTo('pages/OrderPage')
        })
      
      Button('登录')
        .onClick(() => {
          // 模拟登录
          RouterGuard.setLoginStatus(true)
        })
      
      Button('退出登录')
        .onClick(() => {
          RouterGuard.setLoginStatus(false)
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
}
```

---

## 深度链接

### URL Scheme 处理

```typescript
// EntryAbility.ets
import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'
import router from '@ohos.router'

export default class EntryAbility extends UIAbility {
  onNewWant(want, launchParam) {
    console.info('[EntryAbility] onNewWant')
    
    // 获取 URL Scheme
    const uri = want.uri
    if (uri) {
      this.handleDeepLink(uri)
    }
  }
  
  private handleDeepLink(uri: string) {
    // 解析 URL: myapp://page/detail?id=123
    const url = new URL(uri)
    const path = url.pathname // /page/detail
    const params = {}
    
    // 解析参数
    url.searchParams.forEach((value, key) => {
      params[key] = value
    })
    
    // 根据路径跳转
    if (path === '/page/detail') {
      router.pushUrl({
        url: 'pages/DetailPage',
        params: params
      })
    }
  }
}
```

---

## 完整应用示例

### 带导航的完整应用

```typescript
import router from '@ohos.router'

// 路由配置
export class RouteConfig {
  static readonly HOME = 'pages/Index'
  static readonly CATEGORY = 'pages/CategoryPage'
  static readonly PRODUCT_DETAIL = 'pages/ProductDetailPage'
  static readonly CART = 'pages/CartPage'
  static readonly ORDER = 'pages/OrderPage'
  static readonly PROFILE = 'pages/ProfilePage'
  static readonly LOGIN = 'pages/LoginPage'
}

// 主页面 - 底部导航
@Entry
@Component
struct MainApp {
  @State currentTabIndex: number = 0
  @Provide('router') routerService: any = router
  
  @Builder
  TabBarBuilder(title: string, icon: Resource, activeIcon: Resource, index: number) {
    Column() {
      Image(this.currentTabIndex === index ? activeIcon : icon)
        .width(24)
        .height(24)
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? '#1890ff' : '#666')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
  
  build() {
    Tabs({ index: this.currentTabIndex }) {
      // 首页
      TabContent() {
        Navigation() {
          HomeContent()
        }
        .title('首页')
        .titleMode(NavigationTitleMode.Mini)
        .hideBackButton(true)
      }
      .tabBar(this.TabBarBuilder('首页', $r('app.media.home'), $r('app.media.home_active'), 0))
      
      // 分类
      TabContent() {
        Navigation() {
          CategoryContent()
        }
        .title('分类')
        .titleMode(NavigationTitleMode.Mini)
        .hideBackButton(true)
      }
      .tabBar(this.TabBarBuilder('分类', $r('app.media.category'), $r('app.media.category_active'), 1))
      
      // 购物车
      TabContent() {
        Navigation() {
          CartContent()
        }
        .title('购物车')
        .titleMode(NavigationTitleMode.Mini)
        .hideBackButton(true)
      }
      .tabBar(this.TabBarBuilder('购物车', $r('app.media.cart'), $r('app.media.cart_active'), 2))
      
      // 我的
      TabContent() {
        Navigation() {
          ProfileContent()
        }
        .title('我的')
        .titleMode(NavigationTitleMode.Mini)
        .hideBackButton(true)
      }
      .tabBar(this.TabBarBuilder('我的', $r('app.media.profile'), $r('app.media.profile_active'), 3))
    }
    .barPosition(BarPosition.End)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentTabIndex = index
    })
  }
}

// 首页内容
@Component
struct HomeContent {
  @Consume('router') routerService: any
  
  build() {
    Column() {
      // 轮播图
      Swiper() {
        Image($r('app.media.banner1')).borderRadius(8)
        Image($r('app.media.banner2')).borderRadius(8)
        Image($r('app.media.banner3')).borderRadius(8)
      }
      .height(200)
      .margin({ bottom: 20 })
      .autoPlay(true)
      
      // 商品列表
      Text('热门商品')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })
      
      Grid() {
        GridItem() {
          this.ProductCard('商品1', 99.9, $r('app.media.product1'))
        }
        GridItem() {
          this.ProductCard('商品2', 129.9, $r('app.media.product2'))
        }
        GridItem() {
          this.ProductCard('商品3', 89.9, $r('app.media.product3'))
        }
        GridItem() {
          this.ProductCard('商品4', 149.9, $r('app.media.product4'))
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
  
  @Builder
  ProductCard(name: string, price: number, image: Resource) {
    Column() {
      Image(image)
        .width('100%')
        .height(120)
        .borderRadius(8)
      
      Text(name)
        .fontSize(14)
        .margin({ top: 8 })
      
      Text(`¥${price}`)
        .fontSize(16)
        .fontColor('#ff4d4f')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(8)
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
    .onClick(() => {
      this.routerService.pushUrl({
        url: RouteConfig.PRODUCT_DETAIL,
        params: { name, price, image }
      })
    })
  }
}

@Component
struct CategoryContent {
  build() {
    Text('分类页面')
      .fontSize(20)
  }
}

@Component
struct CartContent {
  build() {
    Text('购物车页面')
      .fontSize(20)
  }
}

@Component
struct ProfileContent {
  build() {
    Column() {
      Text('个人中心')
        .fontSize(20)
      
      Button('查看订单')
        .onClick(() => {
          router.pushUrl({
            url: RouteConfig.ORDER
          })
        })
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## 最佳实践

### 1. 路由管理
- ✅ 使用常量定义路由路径，避免硬编码
- ✅ 统一管理路由配置，方便维护
- ✅ 合理使用 `pushUrl` 和 `replaceUrl`

### 2. 参数传递
- ✅ 定义参数接口，确保类型安全
- ✅ 在 `aboutToAppear` 中获取参数
- ✅ 处理参数为空的情况

### 3. 导航体验
- ✅ 合理设置页面转场动画
- ✅ 底部导航使用图标+文字
- ✅ 添加页面加载状态提示

### 4. 性能优化
- ✅ 避免频繁的路由跳转
- ✅ 及时清理不需要的页面栈
- ✅ 使用懒加载优化首屏性能

---

**完整代码可直接复制使用！** 🚀

