# 列表和网格实战

## List 列表组件

### 1. 基础列表

```typescript
@Entry
@Component
struct BasicList {
  private items: string[] = ['项目1', '项目2', '项目3', '项目4', '项目5']

  build() {
    List({ space: 10 }) {
      ForEach(this.items, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(`${index + 1}. ${item}`)
              .fontSize(16)
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .backgroundColor(Color.White)
          .borderRadius(8)
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding(16)
  }
}
```

### 2. 带图标的列表

```typescript
@Entry
@Component
struct IconList {
  private menuItems: MenuItem[] = [
    { icon: $r('app.media.ic_account'), title: '账号管理', subtitle: '修改密码和安全设置' },
    { icon: $r('app.media.ic_notification'), title: '消息通知', subtitle: '管理推送通知' },
    { icon: $r('app.media.ic_privacy'), title: '隐私设置', subtitle: '个人信息保护' },
    { icon: $r('app.media.ic_about'), title: '关于我们', subtitle: '版本信息和帮助' }
  ]

  build() {
    List() {
      ForEach(this.menuItems, (item: MenuItem) => {
        ListItem() {
          Row({ space: 12 }) {
            // 图标
            Image(item.icon)
              .width(40)
              .height(40)
              .borderRadius(8)
            
            // 文字信息
            Column({ space: 4 }) {
              Text(item.title)
                .fontSize(16)
                .fontColor('#333333')
              
              Text(item.subtitle)
                .fontSize(14)
                .fontColor('#999999')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            
            // 箭头
            Image($r('app.media.ic_arrow_right'))
              .width(20)
              .height(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
        }
        .onClick(() => {
          console.info(`点击了 ${item.title}`)
        })
      })
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 1, color: '#F0F0F0', startMargin: 68, endMargin: 16 })
  }
}

interface MenuItem {
  icon: Resource
  title: string
  subtitle: string
}
```

### 3. 滑动删除列表

```typescript
@Entry
@Component
struct SwipeDeleteList {
  @State items: ListItem[] = []

  aboutToAppear() {
    for (let i = 0; i < 10; i++) {
      this.items.push({ id: i, title: `项目 ${i}`, content: `这是项目${i}的内容` })
    }
  }

  build() {
    List() {
      ForEach(this.items, (item: ListItem, index: number) => {
        ListItem() {
          Row() {
            Column({ space: 4 }) {
              Text(item.title)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
              
              Text(item.content)
                .fontSize(14)
                .fontColor('#666666')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .height(70)
          .padding(16)
          .backgroundColor(Color.White)
        }
        .swipeAction({
          end: this.buildDeleteButton(index)
        })
      }, (item: ListItem) => item.id.toString())
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 1, color: '#F0F0F0' })
  }

  @Builder
  buildDeleteButton(index: number) {
    Button('删除')
      .width(80)
      .height('100%')
      .backgroundColor('#FF0000')
      .fontColor(Color.White)
      .onClick(() => {
        this.items.splice(index, 1)
      })
  }
}

interface ListItem {
  id: number
  title: string
  content: string
}
```

### 4. 下拉刷新和上拉加载

```typescript
@Entry
@Component
struct PullRefreshList {
  @State items: string[] = []
  @State isRefreshing: boolean = false
  @State hasMore: boolean = true

  aboutToAppear() {
    this.loadData()
  }

  build() {
    Column() {
      // 下拉刷新提示
      if (this.isRefreshing) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
          Text('正在刷新...')
            .fontSize(14)
            .margin({ left: 8 })
        }
        .width('100%')
        .height(50)
        .justifyContent(FlexAlign.Center)
      }
      
      // 列表
      List() {
        ForEach(this.items, (item: string, index: number) => {
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
        
        // 加载更多提示
        if (this.hasMore) {
          ListItem() {
            Row() {
              LoadingProgress()
                .width(20)
                .height(20)
              Text('加载中...')
                .fontSize(14)
                .margin({ left: 8 })
            }
            .width('100%')
            .height(50)
            .justifyContent(FlexAlign.Center)
          }
        }
      }
      .layoutWeight(1)
      .width('100%')
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
      .onScrollIndex((start: number, end: number) => {
        // 滚动到底部时加载更多
        if (end >= this.items.length - 1 && this.hasMore && !this.isRefreshing) {
          this.loadMore()
        }
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          // 记录触摸开始位置
        } else if (event.type === TouchType.Move) {
          // 判断是否下拉
        } else if (event.type === TouchType.Up) {
          // 触发刷新
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  loadData() {
    this.items = []
    for (let i = 0; i < 20; i++) {
      this.items.push(`项目 ${i}`)
    }
  }

  async loadMore() {
    await new Promise(resolve => setTimeout(resolve, 1000))
    const currentLength = this.items.length
    for (let i = 0; i < 10; i++) {
      this.items.push(`项目 ${currentLength + i}`)
    }
    if (this.items.length >= 50) {
      this.hasMore = false
    }
  }
}
```

### 5. 分组列表

```typescript
@Entry
@Component
struct GroupedList {
  private contacts: ContactGroup[] = [
    {
      letter: 'A',
      contacts: [
        { name: '阿强', phone: '138****1234' },
        { name: '安娜', phone: '139****5678' }
      ]
    },
    {
      letter: 'B',
      contacts: [
        { name: '白云', phone: '136****9012' },
        { name: '博文', phone: '137****3456' }
      ]
    },
    {
      letter: 'C',
      contacts: [
        { name: '陈明', phone: '135****7890' },
        { name: '翠花', phone: '134****1234' }
      ]
    }
  ]

  build() {
    List() {
      ForEach(this.contacts, (group: ContactGroup) => {
        ListItemGroup({ header: this.buildGroupHeader(group.letter) }) {
          ForEach(group.contacts, (contact: Contact) => {
            ListItem() {
              Row({ space: 12 }) {
                // 头像
                Text(contact.name.charAt(0))
                  .width(40)
                  .height(40)
                  .fontSize(18)
                  .fontColor(Color.White)
                  .backgroundColor('#007DFF')
                  .borderRadius(20)
                  .textAlign(TextAlign.Center)
                
                // 联系信息
                Column({ space: 4 }) {
                  Text(contact.name)
                    .fontSize(16)
                    .fontColor('#333333')
                  
                  Text(contact.phone)
                    .fontSize(14)
                    .fontColor('#999999')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
            }
          })
        }
      })
    }
    .width('100%')
    .height('100%')
    .sticky(StickyStyle.Header)  // 头部吸顶
  }

  @Builder
  buildGroupHeader(letter: string) {
    Row() {
      Text(letter)
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .height(30)
    .padding({ left: 16 })
    .backgroundColor('#F5F5F5')
  }
}

interface ContactGroup {
  letter: string
  contacts: Contact[]
}

interface Contact {
  name: string
  phone: string
}
```

### 6. 多选列表

```typescript
@Entry
@Component
struct MultiSelectList {
  @State items: SelectableItem[] = []
  @State isEditMode: boolean = false
  @State selectedCount: number = 0

  aboutToAppear() {
    for (let i = 0; i < 20; i++) {
      this.items.push({ id: i, title: `项目 ${i}`, selected: false })
    }
  }

  build() {
    Column() {
      // 顶部操作栏
      Row() {
        if (this.isEditMode) {
          Text(`已选择 ${this.selectedCount} 项`)
            .fontSize(16)
            .layoutWeight(1)
          
          Button('全选')
            .onClick(() => this.selectAll())
          
          Button('取消')
            .margin({ left: 8 })
            .onClick(() => this.cancelEdit())
        } else {
          Text('我的列表')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          
          Button('编辑')
            .onClick(() => this.isEditMode = true)
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      // 列表
      List() {
        ForEach(this.items, (item: SelectableItem, index: number) => {
          ListItem() {
            Row() {
              if (this.isEditMode) {
                Checkbox()
                  .select(item.selected)
                  .onChange((isChecked: boolean) => {
                    item.selected = isChecked
                    this.updateSelectedCount()
                  })
                  .margin({ right: 12 })
              }
              
              Text(item.title)
                .fontSize(16)
                .layoutWeight(1)
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.White)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
      
      // 底部操作栏
      if (this.isEditMode) {
        Row({ space: 16 }) {
          Button('删除选中')
            .layoutWeight(1)
            .backgroundColor('#FF0000')
            .enabled(this.selectedCount > 0)
            .onClick(() => this.deleteSelected())
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .border({ width: { top: 1 }, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .height('100%')
  }

  selectAll() {
    this.items.forEach(item => item.selected = true)
    this.updateSelectedCount()
  }

  cancelEdit() {
    this.isEditMode = false
    this.items.forEach(item => item.selected = false)
    this.selectedCount = 0
  }

  deleteSelected() {
    this.items = this.items.filter(item => !item.selected)
    this.selectedCount = 0
  }

  updateSelectedCount() {
    this.selectedCount = this.items.filter(item => item.selected).length
  }
}

interface SelectableItem {
  id: number
  title: string
  selected: boolean
}
```

## Grid 网格组件

### 1. 基础网格

```typescript
@Entry
@Component
struct BasicGrid {
  private items: number[] = Array.from({ length: 12 }, (_, i) => i)

  build() {
    Grid() {
      ForEach(this.items, (item: number) => {
        GridItem() {
          Column() {
            Text(`项目 ${item}`)
              .fontSize(16)
          }
          .width('100%')
          .height(100)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr')  // 3列
    .rowsGap(16)
    .columnsGap(16)
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
```

### 2. 图片网格（相册）

```typescript
@Entry
@Component
struct PhotoGrid {
  @State photos: Photo[] = []

  aboutToAppear() {
    // 模拟照片数据
    for (let i = 0; i < 20; i++) {
      this.photos.push({
        id: i,
        url: $r('app.media.photo_placeholder'),
        selected: false
      })
    }
  }

  build() {
    Grid() {
      ForEach(this.photos, (photo: Photo, index: number) => {
        GridItem() {
          Stack({ alignContent: Alignment.TopEnd }) {
            // 照片
            Image(photo.url)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(4)
            
            // 选择标记
            if (photo.selected) {
              Image($r('app.media.ic_check'))
                .width(24)
                .height(24)
                .margin(8)
            }
          }
          .width('100%')
          .aspectRatio(1)  // 保持正方形
        }
        .onClick(() => {
          photo.selected = !photo.selected
        })
      })
    }
    .columnsTemplate('1fr 1fr 1fr')  // 3列
    .rowsGap(8)
    .columnsGap(8)
    .padding(8)
    .width('100%')
    .height('100%')
  }
}

interface Photo {
  id: number
  url: Resource
  selected: boolean
}
```

### 3. 自适应网格

```typescript
@Entry
@Component
struct AdaptiveGrid {
  private products: Product[] = []

  aboutToAppear() {
    for (let i = 0; i < 20; i++) {
      this.products.push({
        id: i,
        name: `商品 ${i}`,
        price: Math.floor(Math.random() * 1000) + 100,
        image: $r('app.media.product_placeholder')
      })
    }
  }

  build() {
    Grid() {
      ForEach(this.products, (product: Product) => {
        GridItem() {
          Column({ space: 8 }) {
            // 商品图片
            Image(product.image)
              .width('100%')
              .aspectRatio(1)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
            
            // 商品信息
            Text(product.name)
              .fontSize(14)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            
            Text(`¥${product.price}`)
              .fontSize(16)
              .fontColor('#FF0000')
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(8)
        }
        .onClick(() => {
          console.info(`点击商品 ${product.name}`)
        })
      })
    }
    .columnsTemplate('1fr 1fr')  // 2列
    .rowsGap(12)
    .columnsGap(12)
    .padding(12)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

interface Product {
  id: number
  name: string
  price: number
  image: Resource
}
```

### 4. 不规则网格

```typescript
@Entry
@Component
struct IrregularGrid {
  build() {
    Grid() {
      GridItem() {
        this.buildGridCell('大图', 2, 2, '#FFB6C1')
      }
      .columnStart(0)
      .columnEnd(1)
      .rowStart(0)
      .rowEnd(1)
      
      GridItem() {
        this.buildGridCell('小图1', 1, 1, '#87CEEB')
      }
      
      GridItem() {
        this.buildGridCell('小图2', 1, 1, '#98FB98')
      }
      
      GridItem() {
        this.buildGridCell('横图', 2, 1, '#DDA0DD')
      }
      .columnStart(0)
      .columnEnd(1)
      
      GridItem() {
        this.buildGridCell('竖图', 1, 2, '#F0E68C')
      }
      .rowStart(2)
      .rowEnd(3)
      
      GridItem() {
        this.buildGridCell('小图3', 1, 1, '#FFE4B5')
      }
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('100vp 100vp 100vp 100vp')
    .columnsGap(8)
    .rowsGap(8)
    .padding(8)
    .width('100%')
    .height('100%')
  }

  @Builder
  buildGridCell(text: string, cols: number, rows: number, color: string) {
    Column() {
      Text(text)
        .fontSize(16)
        .fontColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(color)
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
  }
}
```

## LazyForEach 懒加载

### 完整示例

```typescript
// 数据源类
class MyDataSource implements IDataSource {
  private dataArray: string[] = []
  private listeners: DataChangeListener[] = []

  constructor() {
    for (let i = 0; i < 10000; i++) {
      this.dataArray.push(`项目 ${i}`)
    }
  }

  totalCount(): number {
    return this.dataArray.length
  }

  getData(index: number): string {
    return this.dataArray[index]
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
}

@Entry
@Component
struct LazyLoadList {
  private data: MyDataSource = new MyDataSource()

  build() {
    List() {
      LazyForEach(this.data, (item: string, index: number) => {
        ListItem() {
          Row() {
            Text(`${index}. ${item}`)
              .fontSize(16)
          }
          .width('100%')
          .height(60)
          .padding({ left: 16, right: 16 })
          .backgroundColor(Color.White)
        }
      }, (item: string, index: number) => index.toString())
    }
    .width('100%')
    .height('100%')
    .cachedCount(5)  // 缓存5个屏幕外的项
    .divider({ strokeWidth: 1, color: '#F0F0F0' })
  }
}
```

## 下一步

继续学习 [网络请求与 HTTP](08-network-http.md)

