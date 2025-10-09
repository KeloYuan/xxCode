# 手势交互完整指南

## 基础手势

### TapGesture - 点击手势

```typescript
@Entry
@Component
struct TapGestureExample {
  @State singleTapCount: number = 0
  @State doubleTapCount: number = 0

  build() {
    Column({ space: 30 }) {
      // 单击手势
      Text('单击我')
        .fontSize(20)
        .width(200)
        .height(100)
        .textAlign(TextAlign.Center)
        .backgroundColor('#E6F2FF')
        .borderRadius(12)
        .gesture(
          TapGesture({ count: 1 })
            .onAction(() => {
              this.singleTapCount++
            })
        )

      Text(`单击次数: ${this.singleTapCount}`)

      // 双击手势
      Text('双击我')
        .fontSize(20)
        .width(200)
        .height(100)
        .textAlign(TextAlign.Center)
        .backgroundColor('#FFE6E6')
        .borderRadius(12)
        .gesture(
          TapGesture({ count: 2 })
            .onAction(() => {
              this.doubleTapCount++
            })
        )

      Text(`双击次数: ${this.doubleTapCount}`)

      // 多指点击
      Text('三指点击我')
        .fontSize(20)
        .width(200)
        .height(100)
        .textAlign(TextAlign.Center)
        .backgroundColor('#E6FFE6')
        .borderRadius(12)
        .gesture(
          TapGesture({ count: 1, fingers: 3 })
            .onAction(() => {
              console.info('三指点击')
            })
        )
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### LongPressGesture - 长按手势

```typescript
@Entry
@Component
struct LongPressExample {
  @State isPressed: boolean = false
  @State pressTime: number = 0

  build() {
    Column({ space: 30 }) {
      Text(this.isPressed ? '长按中...' : '长按我')
        .fontSize(24)
        .width(200)
        .height(200)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.isPressed ? '#FF6B6B' : '#E6F2FF')
        .borderRadius(100)
        .gesture(
          LongPressGesture({ repeat: true, duration: 500 })
            .onAction((event: GestureEvent) => {
              if (event.repeat) {
                this.pressTime++
              }
            })
            .onActionEnd(() => {
              this.isPressed = false
              this.pressTime = 0
            })
            .onActionStart(() => {
              this.isPressed = true
            })
        )

      if (this.pressTime > 0) {
        Text(`长按时间: ${this.pressTime * 500}ms`)
          .fontSize(16)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### PanGesture - 拖拽手势

```typescript
@Entry
@Component
struct PanGestureExample {
  @State offsetX: number = 0
  @State offsetY: number = 0
  @State startX: number = 0
  @State startY: number = 0

  build() {
    Column() {
      Column() {
        Image($r('app.media.ic_drag'))
          .width(50)
          .height(50)
      }
      .width(100)
      .height(100)
      .backgroundColor('#007DFF')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .translate({ x: this.offsetX, y: this.offsetY })
      .gesture(
        PanGesture({ fingers: 1, direction: PanDirection.All, distance: 5 })
          .onActionStart((event: GestureEvent) => {
            this.startX = this.offsetX
            this.startY = this.offsetY
          })
          .onActionUpdate((event: GestureEvent) => {
            this.offsetX = this.startX + event.offsetX
            this.offsetY = this.startY + event.offsetY
          })
          .onActionEnd(() => {
            console.info('拖拽结束')
          })
      )

      Text(`位置: (${this.offsetX.toFixed(0)}, ${this.offsetY.toFixed(0)})`)
        .fontSize(16)
        .margin({ top: 30 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### PinchGesture - 捏合手势

```typescript
@Entry
@Component
struct PinchGestureExample {
  @State scale: number = 1
  @State baseScale: number = 1

  build() {
    Column() {
      Image($r('app.media.photo'))
        .width(300)
        .height(300)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
        .scale({ x: this.scale, y: this.scale })
        .gesture(
          PinchGesture({ fingers: 2, distance: 5 })
            .onActionStart(() => {
              this.baseScale = this.scale
            })
            .onActionUpdate((event: GestureEvent) => {
              this.scale = this.baseScale * event.scale
            })
            .onActionEnd(() => {
              console.info(`最终缩放: ${this.scale}`)
            })
        )

      Row({ space: 16 }) {
        Button('缩小')
          .onClick(() => {
            this.scale = Math.max(0.5, this.scale - 0.1)
          })

        Button('重置')
          .onClick(() => {
            this.scale = 1
          })

        Button('放大')
          .onClick(() => {
            this.scale = Math.min(3, this.scale + 0.1)
          })
      }
      .margin({ top: 30 })

      Text(`当前缩放: ${this.scale.toFixed(2)}x`)
        .fontSize(16)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### RotationGesture - 旋转手势

```typescript
@Entry
@Component
struct RotationGestureExample {
  @State angle: number = 0
  @State baseAngle: number = 0

  build() {
    Column() {
      Column() {
        Image($r('app.media.ic_rotate'))
          .width(80)
          .height(80)
      }
      .width(200)
      .height(200)
      .backgroundColor('#E6F2FF')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .rotate({ angle: this.angle })
      .gesture(
        RotationGesture({ fingers: 2 })
          .onActionStart(() => {
            this.baseAngle = this.angle
          })
          .onActionUpdate((event: GestureEvent) => {
            this.angle = this.baseAngle + event.angle
          })
      )

      Row({ space: 16 }) {
        Button('逆时针')
          .onClick(() => {
            animateTo({ duration: 300 }, () => {
              this.angle -= 90
            })
          })

        Button('重置')
          .onClick(() => {
            animateTo({ duration: 300 }, () => {
              this.angle = 0
            })
          })

        Button('顺时针')
          .onClick(() => {
            animateTo({ duration: 300 }, () => {
              this.angle += 90
            })
          })
      }
      .margin({ top: 30 })

      Text(`旋转角度: ${this.angle.toFixed(0)}°`)
        .fontSize(16)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### SwipeGesture - 滑动手势

```typescript
@Entry
@Component
struct SwipeGestureExample {
  @State direction: string = '向任意方向滑动'
  @State bgColor: string = '#E6F2FF'

  build() {
    Column() {
      Column() {
        Text(this.direction)
          .fontSize(20)
          .fontColor(Color.White)
      }
      .width(300)
      .height(300)
      .backgroundColor(this.bgColor)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .gesture(
        SwipeGesture({ fingers: 1, direction: SwipeDirection.All, speed: 100 })
          .onAction((event: GestureEvent) => {
            if (event.angle > -45 && event.angle < 45) {
              this.direction = '向右滑动'
              this.bgColor = '#FF6B6B'
            } else if (event.angle >= 45 && event.angle < 135) {
              this.direction = '向下滑动'
              this.bgColor = '#4ECDC4'
            } else if (event.angle >= 135 || event.angle < -135) {
              this.direction = '向左滑动'
              this.bgColor = '#45B7D1'
            } else {
              this.direction = '向上滑动'
              this.bgColor = '#F7B731'
            }
          })
      )
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 组合手势

### GestureGroup - 手势组合

```typescript
@Entry
@Component
struct GestureGroupExample {
  @State offsetX: number = 0
  @State offsetY: number = 0
  @State scale: number = 1
  @State angle: number = 0

  build() {
    Column() {
      Image($r('app.media.photo'))
        .width(250)
        .height(250)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
        .translate({ x: this.offsetX, y: this.offsetY })
        .scale({ x: this.scale, y: this.scale })
        .rotate({ angle: this.angle })
        // 并行手势 - 可以同时识别
        .parallelGesture(
          GestureGroup(GestureMode.Parallel,
            PanGesture()
              .onActionUpdate((event: GestureEvent) => {
                this.offsetX += event.offsetX
                this.offsetY += event.offsetY
              }),
            PinchGesture()
              .onActionUpdate((event: GestureEvent) => {
                this.scale *= event.scale
              }),
            RotationGesture()
              .onActionUpdate((event: GestureEvent) => {
                this.angle += event.angle
              })
          )
        )

      Button('重置')
        .margin({ top: 30 })
        .onClick(() => {
          animateTo({ duration: 300 }, () => {
            this.offsetX = 0
            this.offsetY = 0
            this.scale = 1
            this.angle = 0
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 高级手势应用

### 可拖拽排序列表

```typescript
@Entry
@Component
struct DraggableList {
  @State items: DragItem[] = []
  @State dragIndex: number = -1

  aboutToAppear() {
    for (let i = 0; i < 10; i++) {
      this.items.push({
        id: i,
        title: `项目 ${i}`,
        offsetY: 0
      })
    }
  }

  build() {
    Column() {
      List() {
        ForEach(this.items, (item: DragItem, index: number) => {
          ListItem() {
            Row() {
              Image($r('app.media.ic_drag'))
                .width(24)
                .height(24)
                .margin({ right: 12 })

              Text(item.title)
                .fontSize(16)
                .layoutWeight(1)
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.dragIndex === index ? '#E6F2FF' : Color.White)
            .borderRadius(8)
            .translate({ y: item.offsetY })
          }
          .gesture(
            GestureGroup(GestureMode.Parallel,
              LongPressGesture({ duration: 500 })
                .onAction(() => {
                  this.dragIndex = index
                }),
              PanGesture()
                .onActionUpdate((event: GestureEvent) => {
                  if (this.dragIndex === index) {
                    item.offsetY = event.offsetY
                  }
                })
                .onActionEnd(() => {
                  // 处理拖拽结束，交换位置
                  item.offsetY = 0
                  this.dragIndex = -1
                })
            )
          )
        }, (item: DragItem) => item.id.toString())
      }
      .width('90%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 20 })
  }
}

interface DragItem {
  id: number
  title: string
  offsetY: number
}
```

### 图片查看器（拖拽、缩放、旋转）

```typescript
@Entry
@Component
struct ImageViewer {
  @State images: string[] = []
  @State currentIndex: number = 0
  @State offsetX: number = 0
  @State offsetY: number = 0
  @State scale: number = 1
  @State angle: number = 0
  @State baseScale: number = 1
  @State startOffsetX: number = 0
  @State startOffsetY: number = 0

  aboutToAppear() {
    this.images = [
      'image1.jpg',
      'image2.jpg',
      'image3.jpg'
    ]
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)

      // 图片
      Image(this.images[this.currentIndex])
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .translate({ x: this.offsetX, y: this.offsetY })
        .scale({ x: this.scale, y: this.scale })
        .rotate({ angle: this.angle })
        .parallelGesture(
          GestureGroup(GestureMode.Parallel,
            // 拖拽
            PanGesture()
              .onActionStart(() => {
                this.startOffsetX = this.offsetX
                this.startOffsetY = this.offsetY
              })
              .onActionUpdate((event: GestureEvent) => {
                this.offsetX = this.startOffsetX + event.offsetX
                this.offsetY = this.startOffsetY + event.offsetY
              }),
            // 缩放
            PinchGesture()
              .onActionStart(() => {
                this.baseScale = this.scale
              })
              .onActionUpdate((event: GestureEvent) => {
                this.scale = this.baseScale * event.scale
              }),
            // 旋转
            RotationGesture()
              .onActionUpdate((event: GestureEvent) => {
                this.angle += event.angle
              })
          )
        )
        // 双击重置
        .gesture(
          TapGesture({ count: 2 })
            .onAction(() => {
              animateTo({ duration: 300 }, () => {
                this.resetTransform()
              })
            })
        )

      // 底部工具栏
      Row({ space: 30 }) {
        Button('上一张')
          .onClick(() => {
            this.previousImage()
          })
          .enabled(this.currentIndex > 0)

        Text(`${this.currentIndex + 1}/${this.images.length}`)
          .fontSize(16)
          .fontColor(Color.White)

        Button('下一张')
          .onClick(() => {
            this.nextImage()
          })
          .enabled(this.currentIndex < this.images.length - 1)
      }
      .width('100%')
      .padding(20)
      .justifyContent(FlexAlign.Center)
      .position({ y: '90%' })
    }
    .width('100%')
    .height('100%')
  }

  resetTransform() {
    this.offsetX = 0
    this.offsetY = 0
    this.scale = 1
    this.angle = 0
  }

  previousImage() {
    if (this.currentIndex > 0) {
      animateTo({ duration: 300 }, () => {
        this.currentIndex--
        this.resetTransform()
      })
    }
  }

  nextImage() {
    if (this.currentIndex < this.images.length - 1) {
      animateTo({ duration: 300 }, () => {
        this.currentIndex++
        this.resetTransform()
      })
    }
  }
}
```

### 滑动删除

```typescript
@Entry
@Component
struct SwipeDeleteList {
  @State items: SwipeItem[] = []

  aboutToAppear() {
    for (let i = 0; i < 10; i++) {
      this.items.push({
        id: i,
        title: `项目 ${i}`,
        offsetX: 0,
        isDeleting: false
      })
    }
  }

  build() {
    List() {
      ForEach(this.items, (item: SwipeItem, index: number) => {
        ListItem() {
          Stack({ alignContent: Alignment.End }) {
            // 删除按钮（背景）
            Row() {
              Button('删除')
                .backgroundColor('#FF0000')
                .fontColor(Color.White)
                .onClick(() => {
                  this.deleteItem(index)
                })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.End)
            .padding({ right: 16 })

            // 主内容
            Row() {
              Text(item.title)
                .fontSize(16)
                .layoutWeight(1)
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.White)
            .translate({ x: item.offsetX })
            .gesture(
              PanGesture({ direction: PanDirection.Horizontal })
                .onActionUpdate((event: GestureEvent) => {
                  // 只允许向左滑动
                  item.offsetX = Math.min(0, event.offsetX)
                })
                .onActionEnd((event: GestureEvent) => {
                  // 滑动超过一半时显示删除按钮
                  if (item.offsetX < -80) {
                    animateTo({ duration: 200 }, () => {
                      item.offsetX = -100
                    })
                  } else {
                    animateTo({ duration: 200 }, () => {
                      item.offsetX = 0
                    })
                  }
                })
            )
          }
          .width('100%')
          .height(60)
        }
      }, (item: SwipeItem) => item.id.toString())
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 1, color: '#F0F0F0' })
  }

  deleteItem(index: number) {
    const item = this.items[index]
    item.isDeleting = true

    animateTo({
      duration: 300,
      onFinish: () => {
        this.items.splice(index, 1)
      }
    }, () => {
      item.offsetX = -500
    })
  }
}

interface SwipeItem {
  id: number
  title: string
  offsetX: number
  isDeleting: boolean
}
```

## 手势优先级

```typescript
@Entry
@Component
struct GesturePriorityExample {
  @State message: string = '点击测试'

  build() {
    Column() {
      Text(this.message)
        .fontSize(20)
        .width(200)
        .height(200)
        .textAlign(TextAlign.Center)
        .backgroundColor('#E6F2FF')
        .borderRadius(12)
        // 高优先级手势
        .priorityGesture(
          TapGesture()
            .onAction(() => {
              this.message = '高优先级点击'
            })
        )
        // 普通手势
        .gesture(
          TapGesture()
            .onAction(() => {
              this.message = '普通点击'
            })
        )
        // 并行手势
        .parallelGesture(
          LongPressGesture()
            .onAction(() => {
              this.message = '长按'
            })
        )
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 下一步

继续学习 [高级动画技巧](14-advanced-animations.md)

