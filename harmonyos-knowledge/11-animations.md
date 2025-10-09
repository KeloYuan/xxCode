# 动画效果实战

## 属性动画

### 1. animateTo 显式动画

```typescript
@Entry
@Component
struct AnimateToExample {
  @State scale: number = 1
  @State rotate: number = 0
  @State opacity: number = 1

  build() {
    Column({ space: 30 }) {
      // 动画目标
      Image($r('app.media.ic_logo'))
        .width(100)
        .height(100)
        .scale({ x: this.scale, y: this.scale })
        .rotate({ angle: this.rotate })
        .opacity(this.opacity)

      // 控制按钮
      Button('缩放动画')
        .onClick(() => {
          animateTo({
            duration: 500,
            curve: Curve.EaseInOut,
            iterations: 1,
            playMode: PlayMode.Normal
          }, () => {
            this.scale = this.scale === 1 ? 1.5 : 1
          })
        })

      Button('旋转动画')
        .onClick(() => {
          animateTo({
            duration: 1000,
            curve: Curve.Linear
          }, () => {
            this.rotate += 360
          })
        })

      Button('淡入淡出')
        .onClick(() => {
          animateTo({
            duration: 500
          }, () => {
            this.opacity = this.opacity === 1 ? 0.2 : 1
          })
        })

      Button('组合动画')
        .onClick(() => {
          animateTo({
            duration: 800,
            curve: Curve.EaseInOut
          }, () => {
            this.scale = this.scale === 1 ? 1.5 : 1
            this.rotate += 180
            this.opacity = this.opacity === 1 ? 0.5 : 1
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 2. animation 属性动画

```typescript
@Entry
@Component
struct PropertyAnimationExample {
  @State width: number = 100
  @State height: number = 100
  @State color: Color = Color.Blue

  build() {
    Column({ space: 30 }) {
      // 动画目标
      Column()
        .width(this.width)
        .height(this.height)
        .backgroundColor(this.color)
        .animation({
          duration: 500,
          curve: Curve.EaseInOut,
          delay: 0,
          iterations: 1,
          playMode: PlayMode.Normal
        })

      // 控制按钮
      Button('改变尺寸')
        .onClick(() => {
          this.width = this.width === 100 ? 200 : 100
          this.height = this.height === 100 ? 200 : 100
        })

      Button('改变颜色')
        .onClick(() => {
          this.color = this.color === Color.Blue ? Color.Red : Color.Blue
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 3. 弹簧动画

```typescript
@Entry
@Component
struct SpringAnimationExample {
  @State translateY: number = 0

  build() {
    Column({ space: 30 }) {
      // 小球
      Circle()
        .width(50)
        .height(50)
        .fill(Color.Red)
        .translate({ y: this.translateY })

      Button('弹跳')
        .onClick(() => {
          animateTo({
            duration: 1000,
            curve: Curve.Spring,
            iterations: 1,
            playMode: PlayMode.Alternate
          }, () => {
            this.translateY = 200
          })
        })

      Button('自定义弹簧')
        .onClick(() => {
          animateTo({
            duration: 1000,
            curve: curves.springCurve(10, 1, 1, 1.2),
            iterations: 1,
            playMode: PlayMode.Alternate
          }, () => {
            this.translateY = 200
          })
        })
    }
    .width('100%')
    .height('100%')
    .padding(50)
  }
}
```

## 转场动画

### 1. 页面转场

```typescript
// PageA.ets
@Entry
@Component
struct PageA {
  build() {
    Column() {
      Text('页面 A')
        .fontSize(24)

      Button('跳转到页面 B')
        .onClick(() => {
          router.pushUrl({ url: 'pages/PageB' })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 页面转场动画
  pageTransition() {
    PageTransitionEnter({ duration: 300 })
      .slide(SlideEffect.Right)
      .opacity(0)

    PageTransitionExit({ duration: 300 })
      .slide(SlideEffect.Left)
      .opacity(0)
  }
}

// PageB.ets
@Entry
@Component
struct PageB {
  build() {
    Column() {
      Text('页面 B')
        .fontSize(24)

      Button('返回')
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300 })
      .slide(SlideEffect.Left)
      .opacity(0)

    PageTransitionExit({ duration: 300 })
      .slide(SlideEffect.Right)
      .opacity(0)
  }
}
```

### 2. 组件转场

```typescript
@Entry
@Component
struct ComponentTransitionExample {
  @State isShow: boolean = true

  build() {
    Column({ space: 30 }) {
      // 带转场效果的组件
      if (this.isShow) {
        Column() {
          Text('这是一个卡片')
            .fontSize(16)
        }
        .width(200)
        .height(100)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .transition({
          type: TransitionType.Insert,
          opacity: 0,
          translate: { x: -200 }
        })
        .transition({
          type: TransitionType.Delete,
          opacity: 0,
          translate: { x: 200 }
        })
      }

      Button(this.isShow ? '隐藏' : '显示')
        .onClick(() => {
          animateTo({ duration: 500 }, () => {
            this.isShow = !this.isShow
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
```

### 3. 共享元素转场

```typescript
// 列表页
@Entry
@Component
struct ListPage {
  private items: Item[] = [
    { id: '1', title: '项目 1', image: $r('app.media.img1') },
    { id: '2', title: '项目 2', image: $r('app.media.img2') },
    { id: '3', title: '项目 3', image: $r('app.media.img3') }
  ]

  build() {
    List() {
      ForEach(this.items, (item: Item) => {
        ListItem() {
          Row({ space: 12 }) {
            Image(item.image)
              .width(80)
              .height(80)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
              .sharedTransition(item.id, { duration: 300 })

            Text(item.title)
              .fontSize(16)
          }
          .width('100%')
          .padding(16)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DetailPage',
              params: { item: item }
            })
          })
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}

// 详情页
@Entry
@Component
struct DetailPage {
  private item: Item = router.getParams()['item']

  build() {
    Column() {
      Image(this.item.image)
        .width('100%')
        .height(300)
        .objectFit(ImageFit.Cover)
        .sharedTransition(this.item.id, { duration: 300 })

      Text(this.item.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
  }
}

interface Item {
  id: string
  title: string
  image: Resource
}
```

## 列表动画

### 1. 列表项插入删除动画

```typescript
@Entry
@Component
struct ListAnimationExample {
  @State items: string[] = ['项目 1', '项目 2', '项目 3']

  build() {
    Column() {
      List() {
        ForEach(this.items, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize(16)
                .layoutWeight(1)

              Button('删除')
                .onClick(() => {
                  animateTo({ duration: 300 }, () => {
                    this.items.splice(index, 1)
                  })
                })
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Color.White)
          }
          .transition({
            type: TransitionType.Delete,
            opacity: 0,
            translate: { x: -300 }
          })
          .transition({
            type: TransitionType.Insert,
            opacity: 0,
            translate: { x: -300 }
          })
        }, (item: string) => item)
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#F0F0F0' })

      Button('添加项目')
        .width('90%')
        .margin({ top: 16, bottom: 16 })
        .onClick(() => {
          animateTo({ duration: 300 }, () => {
            this.items.push(`项目 ${this.items.length + 1}`)
          })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
```

### 2. 下拉刷新动画

```typescript
@Entry
@Component
struct PullRefreshAnimation {
  @State items: string[] = []
  @State refreshing: boolean = false
  @State pullDistance: number = 0
  private startY: number = 0
  private threshold: number = 80

  aboutToAppear() {
    for (let i = 0; i < 10; i++) {
      this.items.push(`项目 ${i}`)
    }
  }

  build() {
    Column() {
      // 刷新指示器
      Row() {
        if (this.refreshing) {
          LoadingProgress()
            .width(30)
            .height(30)
          Text('刷新中...')
            .fontSize(14)
            .margin({ left: 8 })
        } else if (this.pullDistance > 0) {
          Image($r('app.media.ic_arrow_down'))
            .width(20)
            .height(20)
            .rotate({
              angle: this.pullDistance >= this.threshold ? 180 : 0
            })
            .animation({ duration: 200 })
          Text(this.pullDistance >= this.threshold ? '释放刷新' : '下拉刷新')
            .fontSize(14)
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .height(this.pullDistance)
      .justifyContent(FlexAlign.Center)

      // 列表
      List() {
        ForEach(this.items, (item: string) => {
          ListItem() {
            Text(item)
              .width('100%')
              .height(60)
              .textAlign(TextAlign.Center)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .onTouch((event: TouchEvent) => {
        this.handleTouch(event)
      })
    }
    .width('100%')
    .height('100%')
  }

  handleTouch(event: TouchEvent) {
    switch (event.type) {
      case TouchType.Down:
        this.startY = event.touches[0].y
        break
      case TouchType.Move:
        if (!this.refreshing) {
          const deltaY = event.touches[0].y - this.startY
          if (deltaY > 0) {
            this.pullDistance = Math.min(deltaY * 0.5, this.threshold * 1.5)
          }
        }
        break
      case TouchType.Up:
        if (this.pullDistance >= this.threshold && !this.refreshing) {
          this.refresh()
        } else {
          animateTo({ duration: 200 }, () => {
            this.pullDistance = 0
          })
        }
        break
    }
  }

  async refresh() {
    this.refreshing = true
    animateTo({ duration: 200 }, () => {
      this.pullDistance = this.threshold
    })

    // 模拟刷新
    await new Promise(resolve => setTimeout(resolve, 2000))

    this.refreshing = false
    animateTo({ duration: 200 }, () => {
      this.pullDistance = 0
    })
  }
}
```

## 路径动画

```typescript
@Entry
@Component
struct PathAnimationExample {
  @State progress: number = 0

  build() {
    Column() {
      Stack() {
        // 路径
        Path()
          .commands('M 50 200 Q 200 100 350 200')
          .stroke(Color.Gray)
          .strokeWidth(2)

        // 沿路径移动的小球
        Circle()
          .width(20)
          .height(20)
          .fill(Color.Red)
          .position(this.getPosition())
      }
      .width('100%')
      .height(300)

      Button('开始动画')
        .margin({ top: 30 })
        .onClick(() => {
          animateTo({
            duration: 2000,
            curve: Curve.Linear,
            iterations: -1,  // 无限循环
            playMode: PlayMode.Alternate
          }, () => {
            this.progress = 1
          })
        })
    }
    .width('100%')
    .height('100%')
  }

  getPosition(): Position {
    // 根据进度计算位置（贝塞尔曲线）
    const x = 50 + this.progress * 300
    const y = 200 - Math.sin(this.progress * Math.PI) * 100
    return { x: x, y: y }
  }
}
```

## 关键帧动画

```typescript
@Entry
@Component
struct KeyframeAnimationExample {
  @State rotateAngle: number = 0

  build() {
    Column({ space: 30 }) {
      Image($r('app.media.ic_logo'))
        .width(100)
        .height(100)
        .rotate({ angle: this.rotateAngle })

      Button('关键帧旋转')
        .onClick(() => {
          this.startKeyframeAnimation()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  startKeyframeAnimation() {
    // 第一阶段：旋转到 90 度
    animateTo({
      duration: 200,
      onFinish: () => {
        // 第二阶段：旋转到 180 度
        animateTo({
          duration: 200,
          onFinish: () => {
            // 第三阶段：旋转到 270 度
            animateTo({
              duration: 200,
              onFinish: () => {
                // 第四阶段：旋转到 360 度
                animateTo({
                  duration: 200
                }, () => {
                  this.rotateAngle = 360
                })
              }
            }, () => {
              this.rotateAngle = 270
            })
          }
        }, () => {
          this.rotateAngle = 180
        })
      }
    }, () => {
      this.rotateAngle = 90
    })
  }
}
```

## 粒子动画

```typescript
@Entry
@Component
struct ParticleAnimationExample {
  @State particles: Particle[] = []
  private timer: number = -1

  aboutToAppear() {
    this.createParticles()
    this.startAnimation()
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer)
    }
  }

  build() {
    Stack() {
      ForEach(this.particles, (particle: Particle) => {
        Circle()
          .width(particle.size)
          .height(particle.size)
          .fill(particle.color)
          .position({ x: particle.x, y: particle.y })
          .opacity(particle.opacity)
      }, (particle: Particle) => particle.id)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  createParticles() {
    for (let i = 0; i < 50; i++) {
      this.particles.push({
        id: i,
        x: Math.random() * 360,
        y: Math.random() * 640,
        size: Math.random() * 10 + 5,
        color: this.getRandomColor(),
        opacity: Math.random(),
        vx: (Math.random() - 0.5) * 2,
        vy: (Math.random() - 0.5) * 2
      })
    }
  }

  startAnimation() {
    this.timer = setInterval(() => {
      this.particles.forEach(particle => {
        particle.x += particle.vx
        particle.y += particle.vy

        // 边界检测
        if (particle.x < 0 || particle.x > 360) particle.vx = -particle.vx
        if (particle.y < 0 || particle.y > 640) particle.vy = -particle.vy
      })
    }, 16)
  }

  getRandomColor(): string {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8']
    return colors[Math.floor(Math.random() * colors.length)]
  }
}

interface Particle {
  id: number
  x: number
  y: number
  size: number
  color: string
  opacity: number
  vx: number
  vy: number
}
```

## 加载动画组件

```typescript
@Component
export struct LoadingAnimation {
  @State rotateAngle: number = 0
  private timer: number = -1

  aboutToAppear() {
    this.startRotation()
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearInterval(this.timer)
    }
  }

  build() {
    Column() {
      // 旋转加载
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#007DFF')

      // 或自定义加载动画
      Row({ space: 8 }) {
        Circle()
          .width(10)
          .height(10)
          .fill('#007DFF')
          .scale({ x: 1, y: 1 })
          .animation({
            duration: 600,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate
          })

        Circle()
          .width(10)
          .height(10)
          .fill('#007DFF')
          .scale({ x: 1, y: 1.5 })
          .animation({
            duration: 600,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate,
            delay: 200
          })

        Circle()
          .width(10)
          .height(10)
          .fill('#007DFF')
          .scale({ x: 1, y: 1 })
          .animation({
            duration: 600,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate,
            delay: 400
          })
      }
      .margin({ top: 20 })
    }
  }

  startRotation() {
    this.timer = setInterval(() => {
      animateTo({ duration: 1000, curve: Curve.Linear }, () => {
        this.rotateAngle += 360
      })
    }, 1000)
  }
}
```

## 性能优化建议

1. **使用 transform 而非 position**
   - `translate`、`scale`、`rotate` 性能更好
   - 避免频繁改变 `width`、`height`、`position`

2. **合理设置动画时长**
   - 快速交互：200-300ms
   - 一般动画：300-500ms
   - 复杂动画：500-1000ms

3. **避免过度动画**
   - 同时运行的动画不要太多
   - 避免嵌套太深的动画

4. **使用硬件加速**
   - 使用 `renderGroup` 属性
   - 合理使用 `opacity` 和 `transform`

## 下一步

继续学习 [完整应用示例](12-complete-examples.md)

