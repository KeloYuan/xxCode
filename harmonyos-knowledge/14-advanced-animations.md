# 高级动画技巧

## 弹簧动画和曲线

### 内置动画曲线

```typescript
@Entry
@Component
struct CurveComparison {
  @State offsetY: number = 0
  private curves: AnimationCurve[] = [
    Curve.Linear,
    Curve.Ease,
    Curve.EaseIn,
    Curve.EaseOut,
    Curve.EaseInOut,
    Curve.FastOutSlowIn,
    Curve.LinearOutSlowIn,
    Curve.FastOutLinearIn,
    Curve.ExtremeDeceleration,
    Curve.Sharp,
    Curve.Rhythm,
    Curve.Smooth,
    Curve.Friction
  ]
  private curveNames: string[] = [
    'Linear', 'Ease', 'EaseIn', 'EaseOut', 'EaseInOut',
    'FastOutSlowIn', 'LinearOutSlowIn', 'FastOutLinearIn',
    'ExtremeDeceleration', 'Sharp', 'Rhythm', 'Smooth', 'Friction'
  ]
  @State selectedCurve: number = 0

  build() {
    Column() {
      // 动画演示球
      Circle()
        .width(30)
        .height(30)
        .fill('#007DFF')
        .translate({ y: this.offsetY })
        .margin({ top: 50 })

      // 曲线选择
      Scroll() {
        Column({ space: 8 }) {
          ForEach(this.curveNames, (name: string, index: number) => {
            Button(name)
              .width('80%')
              .backgroundColor(this.selectedCurve === index ? '#007DFF' : '#F5F5F5')
              .fontColor(this.selectedCurve === index ? Color.White : '#333333')
              .onClick(() => {
                this.selectedCurve = index
              })
          })
        }
      }
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 30 })

      Button('播放动画')
        .width('80%')
        .margin({ top: 20, bottom: 20 })
        .onClick(() => {
          this.playAnimation()
        })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }

  playAnimation() {
    animateTo({
      duration: 1000,
      curve: this.curves[this.selectedCurve],
      iterations: 1,
      playMode: PlayMode.Alternate
    }, () => {
      this.offsetY = 300
    })

    setTimeout(() => {
      animateTo({ duration: 500 }, () => {
        this.offsetY = 0
      })
    }, 1500)
  }
}
```

### 自定义弹簧曲线

```typescript
import curves from '@ohos.curves'

@Entry
@Component
struct SpringCurveExample {
  @State translateY: number = 0

  build() {
    Column({ space: 30 }) {
      // 标准弹簧动画
      Circle()
        .width(50)
        .height(50)
        .fill('#FF6B6B')
        .translate({ y: this.translateY })

      Button('弹簧动画')
        .onClick(() => {
          animateTo({
            duration: 1000,
            curve: curves.springCurve(100, 10, 80, 10)
            // velocity: 初速度
            // mass: 质量
            // stiffness: 刚度
            // damping: 阻尼
          }, () => {
            this.translateY = this.translateY === 0 ? 200 : 0
          })
        })

      Button('响应式弹簧')
        .onClick(() => {
          animateTo({
            duration: 1000,
            curve: curves.responsiveSpringMotion(0.5, 0.8, 0)
            // response: 响应时间
            // dampingFraction: 阻尼系数
            // overlapDuration: 重叠时间
          }, () => {
            this.translateY = this.translateY === 0 ? 200 : 0
          })
        })

      Button('插值弹簧')
        .onClick(() => {
          animateTo({
            duration: 2000,
            curve: curves.interpolatingSpring(10, 1, 228, 30)
            // velocity: 初速度
            // mass: 质量
            // stiffness: 刚度
            // damping: 阻尼
          }, () => {
            this.translateY = this.translateY === 0 ? 200 : 0
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 贝塞尔曲线

```typescript
import curves from '@ohos.curves'

@Entry
@Component
struct BezierCurveExample {
  @State progress: number = 0

  build() {
    Column({ space: 30 }) {
      // 进度条
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(10)
          .backgroundColor('#F0F0F0')
          .borderRadius(5)

        Row()
          .width(`${this.progress * 100}%`)
          .height(10)
          .backgroundColor('#007DFF')
          .borderRadius(5)
      }
      .width('80%')

      Text(`进度: ${(this.progress * 100).toFixed(0)}%`)
        .fontSize(18)

      Button('线性动画')
        .onClick(() => {
          animateTo({
            duration: 2000,
            curve: Curve.Linear
          }, () => {
            this.progress = this.progress === 0 ? 1 : 0
          })
        })

      Button('三次贝塞尔曲线')
        .onClick(() => {
          animateTo({
            duration: 2000,
            curve: curves.cubicBezierCurve(0.25, 0.1, 0.25, 1)
            // (x1, y1, x2, y2) - 控制点坐标
          }, () => {
            this.progress = this.progress === 0 ? 1 : 0
          })
        })

      Button('缓入缓出（自定义）')
        .onClick(() => {
          animateTo({
            duration: 2000,
            curve: curves.cubicBezierCurve(0.42, 0, 0.58, 1)
          }, () => {
            this.progress = this.progress === 0 ? 1 : 0
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 关键帧动画

```typescript
@Entry
@Component
struct KeyframeAnimation {
  @State scale: number = 1
  @State opacity: number = 1
  @State rotateAngle: number = 0

  build() {
    Column({ space: 30 }) {
      // 动画目标
      Image($r('app.media.ic_star'))
        .width(100)
        .height(100)
        .scale({ x: this.scale, y: this.scale })
        .opacity(this.opacity)
        .rotate({ angle: this.rotateAngle })

      Button('播放关键帧动画')
        .onClick(() => {
          this.playKeyframeAnimation()
        })

      Button('心跳动画')
        .onClick(() => {
          this.heartbeatAnimation()
        })

      Button('摇摆动画')
        .onClick(() => {
          this.shakeAnimation()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 复杂关键帧动画
  playKeyframeAnimation() {
    // 第一阶段：放大 + 旋转
    animateTo({
      duration: 300,
      onFinish: () => {
        // 第二阶段：缩小 + 淡出
        animateTo({
          duration: 300,
          onFinish: () => {
            // 第三阶段：恢复
            animateTo({
              duration: 400
            }, () => {
              this.scale = 1
              this.opacity = 1
              this.rotateAngle = 0
            })
          }
        }, () => {
          this.scale = 0.5
          this.opacity = 0.3
          this.rotateAngle = 360
        })
      }
    }, () => {
      this.scale = 1.5
      this.opacity = 1
      this.rotateAngle = 180
    })
  }

  // 心跳动画
  heartbeatAnimation() {
    const beat = () => {
      animateTo({
        duration: 100,
        onFinish: () => {
          animateTo({
            duration: 100,
            onFinish: () => {
              setTimeout(beat, 500)  // 间隔后再次跳动
            }
          }, () => {
            this.scale = 1
          })
        }
      }, () => {
        this.scale = 1.2
      })
    }
    beat()
  }

  // 摇摆动画
  shakeAnimation() {
    const angles = [10, -10, 8, -8, 6, -6, 4, -4, 2, -2, 0]
    let index = 0

    const shake = () => {
      if (index < angles.length) {
        animateTo({
          duration: 100,
          onFinish: () => {
            index++
            shake()
          }
        }, () => {
          this.rotateAngle = angles[index]
        })
      }
    }

    shake()
  }
}
```

## 动画链和并行

```typescript
@Entry
@Component
struct AnimationChain {
  @State ball1Y: number = 0
  @State ball2Y: number = 0
  @State ball3Y: number = 0

  build() {
    Column() {
      // 三个球
      Row({ space: 40 }) {
        Circle()
          .width(30)
          .height(30)
          .fill('#FF6B6B')
          .translate({ y: this.ball1Y })

        Circle()
          .width(30)
          .height(30)
          .fill('#4ECDC4')
          .translate({ y: this.ball2Y })

        Circle()
          .width(30)
          .height(30)
          .fill('#45B7D1')
          .translate({ y: this.ball3Y })
      }
      .margin({ top: 100 })

      Column({ space: 16 }) {
        Button('串行动画')
          .onClick(() => {
            this.sequentialAnimation()
          })

        Button('并行动画')
          .onClick(() => {
            this.parallelAnimation()
          })

        Button('波浪动画')
          .onClick(() => {
            this.waveAnimation()
          })
      }
      .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
  }

  // 串行动画 - 一个接一个
  sequentialAnimation() {
    animateTo({
      duration: 300,
      onFinish: () => {
        animateTo({
          duration: 300,
          onFinish: () => {
            animateTo({
              duration: 300,
              onFinish: () => {
                this.resetBalls()
              }
            }, () => {
              this.ball3Y = 100
            })
          }
        }, () => {
          this.ball2Y = 100
        })
      }
    }, () => {
      this.ball1Y = 100
    })
  }

  // 并行动画 - 同时进行
  parallelAnimation() {
    animateTo({ duration: 500 }, () => {
      this.ball1Y = 100
      this.ball2Y = 100
      this.ball3Y = 100
    })

    setTimeout(() => {
      this.resetBalls()
    }, 1000)
  }

  // 波浪动画 - 延迟启动
  waveAnimation() {
    animateTo({ duration: 500 }, () => {
      this.ball1Y = 100
    })

    setTimeout(() => {
      animateTo({ duration: 500 }, () => {
        this.ball2Y = 100
      })
    }, 200)

    setTimeout(() => {
      animateTo({ duration: 500 }, () => {
        this.ball3Y = 100
      })
    }, 400)

    setTimeout(() => {
      this.resetBalls()
    }, 1400)
  }

  resetBalls() {
    animateTo({ duration: 300 }, () => {
      this.ball1Y = 0
      this.ball2Y = 0
      this.ball3Y = 0
    })
  }
}
```

## 自定义动画控制器

```typescript
class AnimationController {
  private isPlaying: boolean = false
  private isPaused: boolean = false
  private startTime: number = 0
  private pausedTime: number = 0
  private duration: number = 1000
  private progress: number = 0
  private timerId: number = -1
  private updateCallback?: (progress: number) => void
  private finishCallback?: () => void

  constructor(duration: number) {
    this.duration = duration
  }

  onUpdate(callback: (progress: number) => void) {
    this.updateCallback = callback
  }

  onFinish(callback: () => void) {
    this.finishCallback = callback
  }

  start() {
    if (this.isPlaying) return

    this.isPlaying = true
    this.isPaused = false
    this.startTime = Date.now() - this.pausedTime

    this.animate()
  }

  pause() {
    if (!this.isPlaying || this.isPaused) return

    this.isPaused = true
    this.pausedTime = Date.now() - this.startTime
    clearInterval(this.timerId)
  }

  resume() {
    if (!this.isPaused) return

    this.isPaused = false
    this.startTime = Date.now() - this.pausedTime
    this.animate()
  }

  stop() {
    this.isPlaying = false
    this.isPaused = false
    this.pausedTime = 0
    this.progress = 0
    clearInterval(this.timerId)
    if (this.updateCallback) {
      this.updateCallback(0)
    }
  }

  private animate() {
    this.timerId = setInterval(() => {
      const elapsed = Date.now() - this.startTime
      this.progress = Math.min(elapsed / this.duration, 1)

      if (this.updateCallback) {
        this.updateCallback(this.progress)
      }

      if (this.progress >= 1) {
        this.isPlaying = false
        clearInterval(this.timerId)
        if (this.finishCallback) {
          this.finishCallback()
        }
      }
    }, 16)  // 约60fps
  }
}

@Entry
@Component
struct CustomAnimationController {
  @State progress: number = 0
  @State ballY: number = 0
  private controller: AnimationController = new AnimationController(2000)

  aboutToAppear() {
    this.controller.onUpdate((progress: number) => {
      this.progress = progress
      this.ballY = progress * 300
    })

    this.controller.onFinish(() => {
      console.info('动画完成')
    })
  }

  build() {
    Column({ space: 30 }) {
      // 进度显示
      Text(`进度: ${(this.progress * 100).toFixed(1)}%`)
        .fontSize(18)

      // 动画球
      Circle()
        .width(50)
        .height(50)
        .fill('#007DFF')
        .translate({ y: this.ballY })

      // 控制按钮
      Row({ space: 16 }) {
        Button('开始')
          .onClick(() => {
            this.controller.start()
          })

        Button('暂停')
          .onClick(() => {
            this.controller.pause()
          })

        Button('继续')
          .onClick(() => {
            this.controller.resume()
          })

        Button('停止')
          .onClick(() => {
            this.controller.stop()
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 动画性能优化

### 使用 renderFit 优化渲染

```typescript
@Entry
@Component
struct RenderOptimization {
  @State items: number[] = Array.from({ length: 100 }, (_, i) => i)

  build() {
    List() {
      ForEach(this.items, (item: number) => {
        ListItem() {
          AnimatedListItem({ index: item })
        }
      })
    }
    .width('100%')
    .height('100%')
    .cachedCount(5)  // 缓存屏幕外的项
  }
}

@Reusable
@Component
struct AnimatedListItem {
  @Prop index: number
  @State opacity: number = 0

  aboutToAppear() {
    // 延迟出现动画
    setTimeout(() => {
      animateTo({ duration: 300 }, () => {
        this.opacity = 1
      })
    }, this.index * 20)  // 错开时间
  }

  build() {
    Row() {
      Text(`Item ${this.index}`)
        .fontSize(16)
    }
    .width('100%')
    .height(60)
    .padding({ left: 16 })
    .opacity(this.opacity)
    .backgroundColor(Color.White)
  }
}
```

### 减少重绘区域

```typescript
@Entry
@Component
struct ReduceRepaint {
  @State count: number = 0

  build() {
    Column() {
      // 静态内容 - 不会重新渲染
      Text('静态标题')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      // 动态内容 - 独立组件
      CounterDisplay({ count: this.count })

      // 静态按钮 - 不受count影响
      Button('增加')
        .onClick(() => {
          this.count++
        })
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

// 独立组件，只在count变化时重新渲染
@Component
struct CounterDisplay {
  @Prop count: number

  build() {
    Text(`计数: ${this.count}`)
      .fontSize(48)
      .fontColor('#007DFF')
  }
}
```

## 下一步

恭喜你完成了 HarmonyOS Next 的 UI 和动画学习！现在你可以：

1. 返回 [README](README.md) 查看完整知识库
2. 查看 [完整应用示例](12-complete-examples.md) 进行实战
3. 参考 [性能优化](11-performance-optimization.md) 提升应用性能

