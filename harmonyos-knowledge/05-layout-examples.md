# 布局实战示例

## 常见布局模式

### 1. 卡片式布局

```typescript
@Entry
@Component
struct CardLayout {
  build() {
    Column({ space: 16 }) {
      // 卡片容器
      this.buildCard('推荐内容', '这是一段推荐的内容描述')
      this.buildCard('热门文章', '这是热门文章的内容简介')
      this.buildCard('最新动态', '查看最新发布的动态信息')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildCard(title: string, content: string) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })
      
      Text(content)
        .fontSize(14)
        .fontColor('#666666')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 0x1F000000,
      offsetX: 0,
      offsetY: 2
    })
  }
}
```

### 2. 顶部标题栏布局

```typescript
@Entry
@Component
struct TopBarLayout {
  @State title: string = '页面标题'

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        // 返回按钮
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back()
          })
        
        // 标题
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 更多按钮
        Image($r('app.media.ic_more'))
          .width(24)
          .height(24)
          .onClick(() => {
            console.info('更多操作')
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      // 页面内容
      Column() {
        Text('主要内容区域')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}
```

### 3. 底部导航栏布局

```typescript
@Entry
@Component
struct BottomTabBar {
  @State currentIndex: number = 0
  private tabList: TabItem[] = [
    { title: '首页', icon: $r('app.media.ic_home'), selectedIcon: $r('app.media.ic_home_selected') },
    { title: '发现', icon: $r('app.media.ic_discover'), selectedIcon: $r('app.media.ic_discover_selected') },
    { title: '消息', icon: $r('app.media.ic_message'), selectedIcon: $r('app.media.ic_message_selected') },
    { title: '我的', icon: $r('app.media.ic_profile'), selectedIcon: $r('app.media.ic_profile_selected') }
  ]

  build() {
    Column() {
      // 内容区域
      Stack() {
        if (this.currentIndex === 0) {
          HomePage()
        } else if (this.currentIndex === 1) {
          DiscoverPage()
        } else if (this.currentIndex === 2) {
          MessagePage()
        } else {
          ProfilePage()
        }
      }
      .layoutWeight(1)
      .width('100%')
      
      // 底部导航栏
      Row() {
        ForEach(this.tabList, (item: TabItem, index: number) => {
          Column() {
            Image(this.currentIndex === index ? item.selectedIcon : item.icon)
              .width(24)
              .height(24)
            
            Text(item.title)
              .fontSize(12)
              .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .padding({ top: 8, bottom: 8 })
          .onClick(() => {
            this.currentIndex = index
          })
        })
      }
      .width('100%')
      .height(60)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#F0F0F0' })
    }
    .width('100%')
    .height('100%')
  }
}

interface TabItem {
  title: string
  icon: Resource
  selectedIcon: Resource
}
```

### 4. 左右分栏布局

```typescript
@Entry
@Component
struct SidebarLayout {
  @State selectedCategory: number = 0
  private categories: string[] = ['电子产品', '服装', '食品', '图书', '家居']

  build() {
    Row() {
      // 左侧分类栏
      Column() {
        ForEach(this.categories, (category: string, index: number) => {
          Text(category)
            .width('100%')
            .height(50)
            .textAlign(TextAlign.Center)
            .fontSize(14)
            .backgroundColor(this.selectedCategory === index ? Color.White : '#F5F5F5')
            .fontColor(this.selectedCategory === index ? '#007DFF' : '#333333')
            .onClick(() => {
              this.selectedCategory = index
            })
        })
      }
      .width(80)
      .height('100%')
      .backgroundColor('#F5F5F5')
      
      // 右侧内容区
      Column() {
        Text(`${this.categories[this.selectedCategory]}的内容`)
          .fontSize(16)
          .padding(16)
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
  }
}
```

### 5. 网格布局

```typescript
@Entry
@Component
struct GridLayout {
  private items: GridItem[] = [
    { icon: $r('app.media.ic_scan'), title: '扫一扫' },
    { icon: $r('app.media.ic_payment'), title: '付款' },
    { icon: $r('app.media.ic_transfer'), title: '转账' },
    { icon: $r('app.media.ic_wallet'), title: '钱包' },
    { icon: $r('app.media.ic_card'), title: '卡包' },
    { icon: $r('app.media.ic_coupon'), title: '优惠券' },
    { icon: $r('app.media.ic_service'), title: '服务' },
    { icon: $r('app.media.ic_more'), title: '更多' }
  ]

  build() {
    Grid() {
      ForEach(this.items, (item: GridItem) => {
        GridItem() {
          Column() {
            Image(item.icon)
              .width(40)
              .height(40)
            
            Text(item.title)
              .fontSize(12)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')  // 4列
    .rowsGap(16)
    .columnsGap(16)
    .padding(16)
    .width('100%')
    .backgroundColor(Color.White)
  }
}

interface GridItem {
  icon: Resource
  title: string
}
```

### 6. 瀑布流布局

```typescript
@Entry
@Component
struct WaterfallLayout {
  @State images: WaterfallItem[] = []

  aboutToAppear() {
    // 模拟数据
    for (let i = 0; i < 20; i++) {
      this.images.push({
        id: i,
        height: Math.floor(Math.random() * 200) + 150,
        color: this.getRandomColor()
      })
    }
  }

  build() {
    WaterFlow() {
      ForEach(this.images, (item: WaterfallItem) => {
        FlowItem() {
          Column() {
            // 图片占位
            Column()
              .width('100%')
              .height(item.height)
              .backgroundColor(item.color)
              .borderRadius(8)
            
            Text(`项目 ${item.id}`)
              .fontSize(14)
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(8)
        }
      })
    }
    .columnsTemplate('1fr 1fr')  // 两列
    .columnsGap(8)
    .rowsGap(8)
    .padding(8)
    .width('100%')
    .height('100%')
  }

  getRandomColor(): string {
    const colors = ['#FFB6C1', '#FFA07A', '#87CEEB', '#98FB98', '#DDA0DD']
    return colors[Math.floor(Math.random() * colors.length)]
  }
}

interface WaterfallItem {
  id: number
  height: number
  color: string
}
```

### 7. 头部折叠布局

```typescript
@Entry
@Component
struct CollapseHeaderLayout {
  @State scrollOffset: number = 0
  private maxHeaderHeight: number = 200
  private minHeaderHeight: number = 56

  build() {
    Column() {
      // 可折叠的头部
      Stack({ alignContent: Alignment.Bottom }) {
        // 背景图
        Image($r('app.media.header_bg'))
          .width('100%')
          .height(this.getHeaderHeight())
          .objectFit(ImageFit.Cover)
        
        // 标题
        Text('个人中心')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .padding({ bottom: 16 })
      }
      .width('100%')
      .height(this.getHeaderHeight())
      
      // 滚动内容
      List() {
        ForEach(Array.from({ length: 30 }, (_, i) => i), (item: number) => {
          ListItem() {
            Text(`列表项 ${item}`)
              .width('100%')
              .height(50)
              .padding({ left: 16 })
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .onScroll((scrollOffset: number) => {
        this.scrollOffset = scrollOffset
      })
    }
    .width('100%')
    .height('100%')
  }

  getHeaderHeight(): number {
    const height = this.maxHeaderHeight - this.scrollOffset
    return Math.max(this.minHeaderHeight, Math.min(this.maxHeaderHeight, height))
  }
}
```

### 8. 固定底部按钮布局

```typescript
@Entry
@Component
struct FixedBottomButton {
  @State items: string[] = []

  aboutToAppear() {
    // 模拟列表数据
    for (let i = 0; i < 20; i++) {
      this.items.push(`列表项 ${i}`)
    }
  }

  build() {
    Column() {
      // 滚动内容区
      List() {
        ForEach(this.items, (item: string) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize(16)
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.White)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
      
      // 固定底部按钮
      Row({ space: 16 }) {
        Button('取消')
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
        
        Button('确认')
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#007DFF')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#F0F0F0' })
    }
    .width('100%')
    .height('100%')
  }
}
```

### 9. 悬浮操作按钮布局

```typescript
@Entry
@Component
struct FloatingActionButton {
  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 主内容
      Column() {
        Text('页面内容')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      
      // 悬浮按钮
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
      .shadow({
        radius: 12,
        color: 0x40000000,
        offsetY: 4
      })
      .onClick(() => {
        console.info('创建新项目')
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

### 10. 响应式布局

```typescript
@Entry
@Component
struct ResponsiveLayout {
  @State windowWidth: number = 0

  aboutToAppear() {
    // 获取窗口宽度
    this.windowWidth = 360  // 示例值
  }

  build() {
    Column() {
      // 根据屏幕宽度调整布局
      if (this.windowWidth < 600) {
        // 手机布局 - 单列
        this.buildMobileLayout()
      } else if (this.windowWidth < 840) {
        // 平板布局 - 两列
        this.buildTabletLayout()
      } else {
        // 桌面布局 - 三列
        this.buildDesktopLayout()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildMobileLayout() {
    Column() {
      this.buildCard()
      this.buildCard()
      this.buildCard()
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  buildTabletLayout() {
    Grid() {
      GridItem() { this.buildCard() }
      GridItem() { this.buildCard() }
      GridItem() { this.buildCard() }
      GridItem() { this.buildCard() }
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(16)
    .rowsGap(16)
    .padding(16)
  }

  @Builder
  buildDesktopLayout() {
    Grid() {
      GridItem() { this.buildCard() }
      GridItem() { this.buildCard() }
      GridItem() { this.buildCard() }
      GridItem() { this.buildCard() }
      GridItem() { this.buildCard() }
      GridItem() { this.buildCard() }
    }
    .columnsTemplate('1fr 1fr 1fr')
    .columnsGap(16)
    .rowsGap(16)
    .padding(16)
  }

  @Builder
  buildCard() {
    Column() {
      Text('卡片内容')
        .fontSize(16)
    }
    .width('100%')
    .height(150)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
  }
}
```

## 布局最佳实践

### 1. 使用 LayoutWeight 实现自适应

```typescript
Row() {
  Text('固定宽度')
    .width(100)
  
  Text('自适应宽度')
    .layoutWeight(1)  // 占据剩余空间
  
  Text('固定宽度')
    .width(100)
}
.width('100%')
```

### 2. 使用 Stack 实现叠加效果

```typescript
Stack() {
  Image($r('app.media.background'))
    .width('100%')
    .height(200)
  
  Column() {
    Text('覆盖在图片上的文字')
      .fontColor(Color.White)
  }
  .width('100%')
  .height(200)
  .justifyContent(FlexAlign.Center)
}
```

### 3. 使用 RelativeContainer 实现相对定位

```typescript
RelativeContainer() {
  Text('顶部')
    .id('top')
    .alignRules({
      top: { anchor: '__container__', align: VerticalAlign.Top },
      middle: { anchor: '__container__', align: HorizontalAlign.Center }
    })
  
  Text('居中')
    .id('center')
    .alignRules({
      center: { anchor: '__container__', align: VerticalAlign.Center },
      middle: { anchor: '__container__', align: HorizontalAlign.Center }
    })
  
  Text('底部')
    .id('bottom')
    .alignRules({
      bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
      middle: { anchor: '__container__', align: HorizontalAlign.Center }
    })
}
.width('100%')
.height('100%')
```

## 下一步

继续学习 [列表和网格实战](06-list-grid-examples.md)

