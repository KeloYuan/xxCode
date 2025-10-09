# ArkUI 组件库完整参考

## 基础组件

### Text - 文本组件

```typescript
@Entry
@Component
struct TextExample {
  build() {
    Column({ space: 20 }) {
      // 基础文本
      Text('基础文本')
        .fontSize(16)
        .fontColor('#333333')

      // 多样式文本
      Text() {
        Span('这是')
        Span('高亮文本')
          .fontColor('#FF0000')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Span('的示例')
      }

      // 长文本溢出处理
      Text('这是一段很长的文本内容，用于演示文本溢出处理的效果...')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('80%')

      // 文本装饰
      Text('下划线文本')
        .decoration({
          type: TextDecorationType.Underline,
          color: Color.Blue
        })

      // 文本对齐
      Text('居中文本')
        .width('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .padding(20)
  }
}
```

### Image - 图片组件

```typescript
@Entry
@Component
struct ImageExample {
  build() {
    Column({ space: 20 }) {
      // 本地资源图片
      Image($r('app.media.icon'))
        .width(100)
        .height(100)

      // 网络图片
      Image('https://example.com/image.jpg')
        .width(200)
        .height(150)
        .objectFit(ImageFit.Cover)
        .alt($r('app.media.placeholder'))  // 占位图
        .onComplete(() => {
          console.info('图片加载完成')
        })
        .onError(() => {
          console.error('图片加载失败')
        })

      // 圆形图片
      Image($r('app.media.avatar'))
        .width(80)
        .height(80)
        .borderRadius(40)

      // 图片渲染模式
      Image($r('app.media.logo'))
        .width(120)
        .height(120)
        .renderMode(ImageRenderMode.Original)  // Original, Template

      // 图片插值
      Image($r('app.media.photo'))
        .width(300)
        .height(200)
        .interpolation(ImageInterpolation.High)  // 高质量插值
    }
    .width('100%')
    .padding(20)
  }
}
```

### Button - 按钮组件

```typescript
@Entry
@Component
struct ButtonExample {
  build() {
    Column({ space: 16 }) {
      // 普通按钮
      Button('普通按钮')
        .width(200)
        .onClick(() => {
          console.info('按钮点击')
        })

      // 胶囊按钮
      Button('胶囊按钮')
        .type(ButtonType.Capsule)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)

      // 圆形按钮
      Button() {
        Image($r('app.media.ic_add'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
      }
      .type(ButtonType.Circle)
      .width(56)
      .height(56)
      .backgroundColor('#FF6B6B')

      // 自定义按钮
      Button() {
        Row({ space: 8 }) {
          Image($r('app.media.ic_download'))
            .width(20)
            .height(20)
          Text('下载')
            .fontSize(16)
        }
      }
      .width(150)
      .height(44)

      // 按钮状态
      Button('禁用按钮')
        .enabled(false)
        .backgroundColor('#CCCCCC')

      // 加载按钮
      Button() {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(Color.White)
          Text('加载中...')
        }
      }
      .width(150)
      .backgroundColor('#007DFF')
    }
    .width('100%')
    .padding(20)
  }
}
```

## 高级组件

### Marquee - 跑马灯

```typescript
@Entry
@Component
struct MarqueeExample {
  @State start: boolean = false

  build() {
    Column({ space: 20 }) {
      // 基础跑马灯
      Marquee({
        start: this.start,
        step: 10,
        loop: -1,  // 无限循环
        fromStart: true,
        src: '这是一条重要通知，请大家注意查看！'
      })
        .width('100%')
        .fontSize(16)
        .fontColor('#333333')

      Button(this.start ? '停止' : '开始')
        .onClick(() => {
          this.start = !this.start
        })
    }
    .width('100%')
    .padding(20)
  }
}
```

### TextClock - 文本时钟

```typescript
@Entry
@Component
struct TextClockExample {
  build() {
    Column({ space: 20 }) {
      // 12小时制
      TextClock({ timeZoneOffset: 0 })
        .format('hh:mm:ss')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)

      // 24小时制
      TextClock()
        .format('HH:mm:ss')
        .fontSize(32)

      // 日期时间
      TextClock()
        .format('yyyy年MM月dd日 HH:mm:ss')
        .fontSize(16)

      // 自定义样式
      TextClock()
        .format('HH:mm')
        .fontSize(60)
        .fontColor('#007DFF')
        .fontWeight(FontWeight.Bold)
        .onDateChange((value: number) => {
          console.info('时间变化：' + value)
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### TextTimer - 文本计时器

```typescript
@Entry
@Component
struct TextTimerExample {
  @State isRunning: boolean = false
  private controller: TextTimerController = new TextTimerController()

  build() {
    Column({ space: 20 }) {
      // 倒计时
      TextTimer({ isCountDown: true, count: 60000 })
        .format('mm:ss')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .onTimer((utc: number, elapsedTime: number) => {
          console.info(`计时：${elapsedTime}ms`)
        })

      // 正计时
      TextTimer({ controller: this.controller })
        .format('HH:mm:ss.SS')
        .fontSize(32)
        .fontColor('#007DFF')

      Row({ space: 16 }) {
        Button('开始')
          .onClick(() => {
            this.controller.start()
          })

        Button('暂停')
          .onClick(() => {
            this.controller.pause()
          })

        Button('重置')
          .onClick(() => {
            this.controller.reset()
          })
      }
    }
    .width('100%')
    .padding(20)
  }
}
```

### QRCode - 二维码

```typescript
@Entry
@Component
struct QRCodeExample {
  @State qrValue: string = 'https://www.harmonyos.com'

  build() {
    Column({ space: 20 }) {
      // 基础二维码
      QRCode(this.qrValue)
        .width(200)
        .height(200)
        .backgroundColor(Color.White)

      // 自定义颜色二维码
      QRCode('Hello HarmonyOS')
        .width(180)
        .height(180)
        .color('#007DFF')
        .backgroundColor('#F5F5F5')

      // 输入框修改二维码内容
      TextInput({ placeholder: '请输入二维码内容', text: this.qrValue })
        .onChange((value: string) => {
          this.qrValue = value
        })
    }
    .width('100%')
    .padding(20)
  }
}
```

### DataPanel - 数据面板

```typescript
@Entry
@Component
struct DataPanelExample {
  private values: number[] = [30, 20, 30, 20]

  build() {
    Column({ space: 40 }) {
      // 圆形数据面板
      DataPanel({ values: this.values, max: 100, type: DataPanelType.Circle })
        .width(200)
        .height(200)

      // 线性数据面板
      DataPanel({ values: this.values, max: 100, type: DataPanelType.Line })
        .width('80%')
        .height(10)

      // 自定义颜色
      DataPanel({
        values: [25, 25, 25, 25],
        max: 100
      })
        .width(200)
        .height(200)
        .valueColors([
          [Color.Red, Color.Orange],
          [Color.Blue, Color.Green],
          [Color.Yellow, Color.Pink],
          [Color.Purple, Color.Grey]
        ])
    }
    .width('100%')
    .padding(20)
  }
}
```

### Gauge - 仪表盘

```typescript
@Entry
@Component
struct GaugeExample {
  @State value: number = 50

  build() {
    Column({ space: 30 }) {
      // 基础仪表盘
      Gauge({ value: this.value, min: 0, max: 100 })
        .width(200)
        .height(200)
        .colors([
          [Color.Green, 1],
          [Color.Yellow, 1],
          [Color.Red, 1]
        ])
        .strokeWidth(20)

      // 滑块控制
      Slider({
        value: this.value,
        min: 0,
        max: 100,
        step: 1
      })
        .width('80%')
        .onChange((value: number) => {
          this.value = value
        })

      Text(`当前值: ${this.value.toFixed(0)}`)
        .fontSize(20)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 容器组件高级用法

### WaterFlow - 瀑布流

```typescript
@Entry
@Component
struct WaterFlowExample {
  @State items: WaterFlowItem[] = []

  aboutToAppear() {
    for (let i = 0; i < 100; i++) {
      this.items.push({
        id: i,
        height: Math.random() * 200 + 100,
        image: $r('app.media.placeholder')
      })
    }
  }

  build() {
    WaterFlow() {
      ForEach(this.items, (item: WaterFlowItem) => {
        FlowItem() {
          Column() {
            Image(item.image)
              .width('100%')
              .height(item.height)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)

            Text(`Item ${item.id}`)
              .fontSize(14)
              .padding(8)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(8)
        }
      }, (item: WaterFlowItem) => item.id.toString())
    }
    .columnsTemplate('1fr 1fr')  // 2列
    .columnsGap(10)
    .rowsGap(10)
    .padding(10)
    .width('100%')
    .height('100%')
    .layoutDirection(FlexDirection.Column)
  }
}

interface WaterFlowItem {
  id: number
  height: number
  image: Resource
}
```

### Refresh - 下拉刷新

```typescript
@Entry
@Component
struct RefreshExample {
  @State items: string[] = []
  @State isRefreshing: boolean = false

  aboutToAppear() {
    this.loadData()
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing }) {
        List() {
          ForEach(this.items, (item: string) => {
            ListItem() {
              Text(item)
                .width('100%')
                .height(60)
                .padding({ left: 16 })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.loadData()
          this.isRefreshing = false
        }, 2000)
      })
    }
    .width('100%')
    .height('100%')
  }

  loadData() {
    this.items = []
    for (let i = 0; i < 20; i++) {
      this.items.push(`Item ${Date.now() + i}`)
    }
  }
}
```

### SideBarContainer - 侧边栏容器

```typescript
@Entry
@Component
struct SideBarExample {
  @State showSideBar: boolean = true

  build() {
    SideBarContainer(SideBarContainerType.Embed) {
      // 侧边栏内容
      Column() {
        Text('侧边栏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 20 })

        List() {
          ForEach(['首页', '消息', '设置', '关于'], (item: string) => {
            ListItem() {
              Text(item)
                .width('100%')
                .height(50)
                .padding({ left: 16 })
            }
            .onClick(() => {
              console.info(`点击了 ${item}`)
            })
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 主内容区
      Column() {
        Row() {
          Button('切换侧边栏')
            .onClick(() => {
              this.showSideBar = !this.showSideBar
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16 })

        Text('主内容区域')
          .fontSize(18)
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .showSideBar(this.showSideBar)
    .sideBarWidth(200)
    .minSideBarWidth(150)
    .maxSideBarWidth(300)
  }
}
```

### RelativeContainer - 相对布局

```typescript
@Entry
@Component
struct RelativeContainerExample {
  build() {
    RelativeContainer() {
      // 顶部标题
      Text('顶部标题')
        .id('header')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .margin({ top: 20, left: 20 })

      // 中心图片
      Image($r('app.media.logo'))
        .id('centerImage')
        .width(100)
        .height(100)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })

      // 底部按钮
      Button('确定')
        .id('confirmButton')
        .width(200)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
  }
}
```

## 表单组件

### Rating - 评分组件

```typescript
@Entry
@Component
struct RatingExample {
  @State rating: number = 3.5

  build() {
    Column({ space: 30 }) {
      // 基础评分
      Rating({ rating: this.rating, indicator: false })
        .stars(5)
        .stepSize(0.5)
        .onChange((value: number) => {
          this.rating = value
        })

      Text(`评分: ${this.rating}`)
        .fontSize(18)

      // 只读评分（指示器）
      Rating({ rating: 4, indicator: true })
        .stars(5)
        .starStyle({
          backgroundUri: $r('app.media.star_empty'),
          foregroundUri: $r('app.media.star_filled'),
          secondaryUri: $r('app.media.star_half')
        })
    }
    .width('100%')
    .padding(20)
  }
}
```

### Select - 下拉选择

```typescript
@Entry
@Component
struct SelectExample {
  @State selected: number = 0
  private options: SelectOption[] = [
    { value: '选项1' },
    { value: '选项2' },
    { value: '选项3' },
    { value: '选项4' }
  ]

  build() {
    Column({ space: 20 }) {
      Select(this.options)
        .selected(this.selected)
        .value('请选择')
        .font({ size: 16, weight: FontWeight.Medium })
        .fontColor('#182431')
        .selectedOptionFont({ size: 16, weight: FontWeight.Regular })
        .optionFont({ size: 16, weight: FontWeight.Regular })
        .onSelect((index: number) => {
          this.selected = index
          console.info(`选择了：${this.options[index].value}`)
        })

      Text(`当前选择：${this.options[this.selected].value}`)
        .fontSize(16)
    }
    .width('100%')
    .padding(20)
  }
}
```

### Radio - 单选框

```typescript
@Entry
@Component
struct RadioExample {
  @State selectedValue: string = 'option1'

  build() {
    Column({ space: 16 }) {
      Text('请选择一个选项：')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Row({ space: 12 }) {
        Radio({ value: 'option1', group: 'radioGroup' })
          .checked(this.selectedValue === 'option1')
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.selectedValue = 'option1'
            }
          })
        Text('选项1')
      }

      Row({ space: 12 }) {
        Radio({ value: 'option2', group: 'radioGroup' })
          .checked(this.selectedValue === 'option2')
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.selectedValue = 'option2'
            }
          })
        Text('选项2')
      }

      Row({ space: 12 }) {
        Radio({ value: 'option3', group: 'radioGroup' })
          .checked(this.selectedValue === 'option3')
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.selectedValue = 'option3'
            }
          })
        Text('选项3')
      }

      Text(`当前选择：${this.selectedValue}`)
        .fontSize(16)
        .fontColor('#007DFF')
        .margin({ top: 20 })
    }
    .width('100%')
    .padding(20)
  }
}
```

## 下一步

继续学习 [状态管理详解](04-state-management.md)

