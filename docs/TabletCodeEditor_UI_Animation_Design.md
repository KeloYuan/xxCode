# 鸿蒙6风格代码编辑器 - 精美UI与动画设计

## 🎨 设计理念

### HarmonyOS 6 设计语言核心特征

1. **光影质感** - 微妙的渐变、柔和阴影、玻璃拟态效果
2. **流体动画** - 基于物理的弹性动画、惯性运动
3. **空间层次** - 卡片化布局、清晰的Z轴层级
4. **触感反馈** - 按压缩放、涟漪扩散、状态过渡

---

## 🌟 视觉设计规范

### 1. 背景与玻璃拟态 (Glassmorphism)

```typescript
// 毛玻璃效果背景
@Component
struct GlassContainer {
  build() {
    Column() {
      // 内容
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(255, 255, 255, 0.72)')  // 浅色主题
    // .backgroundColor('rgba(30, 30, 30, 0.85)')  // 深色主题
    .backdropBlur(40)  // 背景模糊 (HarmonyOS 特有)
    .borderRadius(20)
    .border({
      width: 1,
      color: 'rgba(255, 255, 255, 0.18)'  // 微妙边框
    })
    .shadow({
      radius: 24,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 8
    })
  }
}
```

### 2. 多层阴影系统

```typescript
// 鸿蒙风格的层次化阴影
const ShadowStyles = {
  // 轻微悬浮 - 用于卡片、按钮
  elevation1: {
    radius: 8,
    color: 'rgba(0, 0, 0, 0.04)',
    offsetX: 0,
    offsetY: 2
  },
  
  // 中等悬浮 - 用于侧边栏、面板
  elevation2: {
    radius: 16,
    color: 'rgba(0, 0, 0, 0.08)',
    offsetX: 0,
    offsetY: 4
  },
  
  // 高悬浮 - 用于弹窗、浮层
  elevation3: {
    radius: 32,
    color: 'rgba(0, 0, 0, 0.12)',
    offsetX: 0,
    offsetY: 12
  },
  
  // 彩色光晕 - 用于重要按钮
  glowPrimary: {
    radius: 20,
    color: 'rgba(10, 89, 247, 0.25)',
    offsetX: 0,
    offsetY: 6
  }
}
```

### 3. 渐变色系统

```typescript
// 主题渐变色
const GradientColors = {
  // 主色调渐变
  primary: {
    colors: ['#3D7BFF', '#0A59F7'],
    direction: GradientDirection.LeftTop
  },
  
  // 侧边栏背景渐变
  sidebarBg: {
    colors: ['#F8FAFC', '#F1F5F9'],
    direction: GradientDirection.Top
  },
  
  // 深色模式渐变
  darkBg: {
    colors: ['#1E1E24', '#151518'],
    direction: GradientDirection.Top
  },
  
  // 高光渐变（用于按钮、选中态）
  highlight: {
    colors: ['rgba(255,255,255,0.15)', 'rgba(255,255,255,0)'],
    direction: GradientDirection.Top
  }
}
```

---

## ✨ 核心动画设计

### 1. 弹性曲线动画 (Spring Animation)

鸿蒙6使用物理弹簧动画，让交互更自然：

```typescript
// 定义弹性动画曲线
const SpringCurves = {
  // 轻柔弹性 - 用于小元素
  gentle: curves.springMotion(0.6, 0.9),
  
  // 标准弹性 - 用于大多数场景
  standard: curves.springMotion(0.5, 0.8),
  
  // 活泼弹性 - 用于强调效果
  bouncy: curves.springMotion(0.35, 0.7),
  
  // 响应式弹性 - 用于手势跟随
  responsive: curves.responsiveSpringMotion(0.5, 0.9)
}

// 使用示例
@Component
struct AnimatedButton {
  @State scale: number = 1
  @State isPressed: boolean = false
  
  build() {
    Button('保存')
      .scale({ x: this.scale, y: this.scale })
      .animation({
        duration: 350,
        curve: curves.springMotion(0.5, 0.8)  // 弹性曲线
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.scale = 0.95  // 按下缩小
        } else if (event.type === TouchType.Up) {
          this.scale = 1.0   // 释放弹回
        }
      })
  }
}
```

### 2. 侧边栏展开/收起动画

```typescript
@Component
struct AnimatedSidebar {
  @State sidebarWidth: number = 280
  @State isExpanded: boolean = true
  @State sidebarOpacity: number = 1
  
  build() {
    Row() {
      // 侧边栏
      Column() {
        // 侧边栏内容...
      }
      .width(this.sidebarWidth)
      .opacity(this.sidebarOpacity)
      .clip(true)
      
      // 编辑器主区域
      Column() {
        // 编辑器内容...
      }
      .layoutWeight(1)
    }
  }
  
  toggleSidebar() {
    // 使用 animateTo 实现流畅过渡
    animateTo({
      duration: 400,
      curve: curves.springMotion(0.45, 0.85),  // 弹性曲线
      onFinish: () => {
        console.info('动画完成')
      }
    }, () => {
      if (this.isExpanded) {
        this.sidebarWidth = 0
        this.sidebarOpacity = 0
      } else {
        this.sidebarWidth = 280
        this.sidebarOpacity = 1
      }
      this.isExpanded = !this.isExpanded
    })
  }
}
```

### 3. 文件树展开/折叠动画

```typescript
@Component
struct AnimatedFileTree {
  @State folderHeight: number = 0
  @State isExpanded: boolean = false
  @State rotateAngle: number = 0
  
  private childrenCount: number = 5
  private itemHeight: number = 36
  
  build() {
    Column() {
      // 文件夹头部
      Row() {
        // 旋转箭头
        Text('▶')
          .fontSize(10)
          .rotate({ angle: this.rotateAngle })
          .animation({
            duration: 250,
            curve: curves.springMotion(0.6, 0.9)
          })
        
        Text('📁 src')
          .fontSize(14)
      }
      .onClick(() => this.toggleExpand())
      
      // 子项容器
      Column() {
        ForEach(this.getChildren(), (item: string) => {
          this.FileItem(item)
        })
      }
      .height(this.folderHeight)
      .opacity(this.isExpanded ? 1 : 0)
      .clip(true)
      .animation({
        duration: 300,
        curve: curves.springMotion(0.5, 0.85)
      })
    }
  }
  
  toggleExpand() {
    animateTo({
      duration: 300,
      curve: curves.springMotion(0.5, 0.85)
    }, () => {
      this.isExpanded = !this.isExpanded
      this.rotateAngle = this.isExpanded ? 90 : 0
      this.folderHeight = this.isExpanded ? this.childrenCount * this.itemHeight : 0
    })
  }
  
  @Builder
  FileItem(name: string) {
    Row() {
      Text('📄 ' + name)
        .fontSize(13)
    }
    .height(this.itemHeight)
    .padding({ left: 24 })
  }
}
```

### 4. 标签页切换动画

```typescript
@Component
struct AnimatedTabBar {
  @State tabs: TabInfo[] = []
  @State activeIndex: number = 0
  @State indicatorOffset: number = 0
  @State indicatorWidth: number = 80
  
  build() {
    Column() {
      // 标签栏
      Stack({ alignContent: Alignment.BottomStart }) {
        // 标签项
        Row() {
          ForEach(this.tabs, (tab: TabInfo, index: number) => {
            this.TabItem(tab, index)
          })
        }
        
        // 滑动指示器
        Row()
          .width(this.indicatorWidth)
          .height(3)
          .backgroundColor('#0A59F7')
          .borderRadius(1.5)
          .offset({ x: this.indicatorOffset, y: 0 })
          .animation({
            duration: 280,
            curve: curves.springMotion(0.4, 0.9)  // 流畅弹性
          })
      }
      .width('100%')
      .height(40)
    }
  }
  
  @Builder
  TabItem(tab: TabInfo, index: number) {
    Column() {
      Text(tab.name)
        .fontSize(13)
        .fontColor(index === this.activeIndex ? '#0A59F7' : '#666666')
        .fontWeight(index === this.activeIndex ? FontWeight.Medium : FontWeight.Normal)
        .animation({
          duration: 200,
          curve: Curve.EaseOut
        })
    }
    .padding({ left: 16, right: 16 })
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.switchTab(index)
    })
    .onAreaChange((_, newArea: Area) => {
      if (index === this.activeIndex) {
        // 更新指示器位置
        this.indicatorOffset = newArea.position.x as number
        this.indicatorWidth = newArea.width as number
      }
    })
  }
  
  switchTab(index: number) {
    this.activeIndex = index
    // 指示器位置会通过 onAreaChange 自动更新
  }
}
```

### 5. 按钮涟漪效果 (Ripple Effect)

```typescript
@Component
struct RippleButton {
  @State rippleScale: number = 0
  @State rippleOpacity: number = 0.3
  @State rippleX: number = 0
  @State rippleY: number = 0
  @State showRipple: boolean = false
  @State buttonScale: number = 1
  
  private buttonWidth: number = 120
  private buttonHeight: number = 44
  
  build() {
    Stack() {
      // 涟漪层
      if (this.showRipple) {
        Circle()
          .width(200)
          .height(200)
          .fill('#0A59F7')
          .opacity(this.rippleOpacity)
          .scale({ x: this.rippleScale, y: this.rippleScale })
          .position({ x: this.rippleX - 100, y: this.rippleY - 100 })
      }
      
      // 按钮内容
      Row() {
        Text('💾')
          .fontSize(16)
          .margin({ right: 6 })
        Text('保存文件')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
      }
    }
    .width(this.buttonWidth)
    .height(this.buttonHeight)
    .borderRadius(22)
    .backgroundColor('#0A59F7')
    .clip(true)
    .scale({ x: this.buttonScale, y: this.buttonScale })
    .shadow({
      radius: 12,
      color: 'rgba(10, 89, 247, 0.3)',
      offsetY: 4
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        // 记录点击位置
        const touch = event.touches[0]
        this.rippleX = touch.x
        this.rippleY = touch.y
        
        // 启动涟漪动画
        this.showRipple = true
        this.rippleScale = 0
        this.rippleOpacity = 0.25
        
        animateTo({
          duration: 400,
          curve: Curve.EaseOut
        }, () => {
          this.rippleScale = 2
          this.rippleOpacity = 0
        })
        
        // 按钮缩小
        animateTo({
          duration: 120,
          curve: curves.springMotion(0.5, 0.9)
        }, () => {
          this.buttonScale = 0.96
        })
        
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        // 按钮弹回
        animateTo({
          duration: 250,
          curve: curves.springMotion(0.35, 0.8)
        }, () => {
          this.buttonScale = 1
        })
        
        // 隐藏涟漪
        setTimeout(() => {
          this.showRipple = false
        }, 400)
      }
    })
  }
}
```

### 6. 列表项悬浮效果

```typescript
@Component
struct HoverableListItem {
  @State isHovered: boolean = false
  @State bgColor: string = 'transparent'
  @State translateX: number = 0
  @State elevation: number = 0
  
  build() {
    Row() {
      Text('📄 main.ets')
        .fontSize(14)
    }
    .width('100%')
    .height(40)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.bgColor)
    .translate({ x: this.translateX })
    .shadow({
      radius: this.elevation,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetY: this.elevation / 4
    })
    .borderRadius(8)
    .animation({
      duration: 200,
      curve: curves.springMotion(0.6, 0.95)
    })
    .onHover((isHover: boolean) => {
      animateTo({
        duration: 200,
        curve: curves.springMotion(0.6, 0.95)
      }, () => {
        this.isHovered = isHover
        this.bgColor = isHover ? 'rgba(10, 89, 247, 0.06)' : 'transparent'
        this.translateX = isHover ? 4 : 0  // 轻微右移
        this.elevation = isHover ? 8 : 0
      })
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        animateTo({ duration: 100 }, () => {
          this.bgColor = 'rgba(10, 89, 247, 0.12)'
        })
      } else if (event.type === TouchType.Up) {
        animateTo({ duration: 150 }, () => {
          this.bgColor = this.isHovered ? 'rgba(10, 89, 247, 0.06)' : 'transparent'
        })
      }
    })
  }
}
```

---

## 🎭 主题切换动画

### 平滑主题过渡

```typescript
@Entry
@Component
struct ThemedEditor {
  @State isDarkMode: boolean = false
  @State themeTransition: number = 0  // 0=浅色, 1=深色
  
  // 动态计算颜色
  get bgColor(): string {
    return this.interpolateColor(
      '#F1F5F9',  // 浅色背景
      '#1A1A1F',  // 深色背景
      this.themeTransition
    )
  }
  
  get textColor(): string {
    return this.interpolateColor(
      '#1F2937',  // 浅色文字
      '#E5E7EB',  // 深色文字
      this.themeTransition
    )
  }
  
  get surfaceColor(): string {
    return this.interpolateColor(
      '#FFFFFF',
      '#262630',
      this.themeTransition
    )
  }
  
  build() {
    Column() {
      // 主题切换按钮
      Button() {
        Row() {
          Text(this.isDarkMode ? '☀️' : '🌙')
            .fontSize(18)
            .rotate({ angle: this.isDarkMode ? 180 : 0 })
            .animation({
              duration: 500,
              curve: curves.springMotion(0.4, 0.8)
            })
        }
      }
      .onClick(() => this.toggleTheme())
      
      // 编辑器内容
      Column() {
        // ...
      }
      .backgroundColor(this.surfaceColor)
    }
    .backgroundColor(this.bgColor)
  }
  
  toggleTheme() {
    this.isDarkMode = !this.isDarkMode
    
    animateTo({
      duration: 400,
      curve: Curve.EaseInOut
    }, () => {
      this.themeTransition = this.isDarkMode ? 1 : 0
    })
  }
  
  // 颜色插值函数
  private interpolateColor(color1: string, color2: string, t: number): string {
    const r1 = parseInt(color1.slice(1, 3), 16)
    const g1 = parseInt(color1.slice(3, 5), 16)
    const b1 = parseInt(color1.slice(5, 7), 16)
    
    const r2 = parseInt(color2.slice(1, 3), 16)
    const g2 = parseInt(color2.slice(3, 5), 16)
    const b2 = parseInt(color2.slice(5, 7), 16)
    
    const r = Math.round(r1 + (r2 - r1) * t)
    const g = Math.round(g1 + (g2 - g1) * t)
    const b = Math.round(b1 + (b2 - b1) * t)
    
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`
  }
}
```

---

## 🖱️ 手势交互动画

### 侧边栏拖拽调整宽度

```typescript
@Component
struct ResizableSidebar {
  @State sidebarWidth: number = 280
  @State isDragging: boolean = false
  @State dividerColor: string = '#E5E8EB'
  
  private minWidth: number = 200
  private maxWidth: number = 400
  private startX: number = 0
  private startWidth: number = 280
  
  build() {
    Row() {
      // 侧边栏
      Column() {
        // 内容...
      }
      .width(this.sidebarWidth)
      .backgroundColor('#FAFBFC')
      
      // 可拖拽分割线
      Column()
        .width(6)
        .height('100%')
        .backgroundColor(this.dividerColor)
        .border({
          width: { left: 1, right: 1 },
          color: 'rgba(0,0,0,0.06)'
        })
        .animation({
          duration: 150,
          curve: Curve.EaseOut
        })
        .onHover((isHover: boolean) => {
          this.dividerColor = isHover ? '#0A59F7' : '#E5E8EB'
        })
        .gesture(
          PanGesture({ direction: PanDirection.Horizontal })
            .onActionStart((event: GestureEvent) => {
              this.isDragging = true
              this.startX = event.offsetX
              this.startWidth = this.sidebarWidth
              this.dividerColor = '#0A59F7'
            })
            .onActionUpdate((event: GestureEvent) => {
              const delta = event.offsetX - this.startX
              let newWidth = this.startWidth + delta
              
              // 限制范围
              newWidth = Math.max(this.minWidth, Math.min(this.maxWidth, newWidth))
              this.sidebarWidth = newWidth
            })
            .onActionEnd(() => {
              this.isDragging = false
              
              // 释放时的弹性效果
              animateTo({
                duration: 300,
                curve: curves.springMotion(0.5, 0.9)
              }, () => {
                // 吸附到合适的宽度
                if (this.sidebarWidth < 220) {
                  this.sidebarWidth = 200
                } else if (this.sidebarWidth > 380) {
                  this.sidebarWidth = 400
                }
                this.dividerColor = '#E5E8EB'
              })
            })
        )
      
      // 编辑器区域
      Column() {
        // ...
      }
      .layoutWeight(1)
    }
  }
}
```

### 代码区滚动惯性与边缘回弹

```typescript
@Component
struct SmoothScrollEditor {
  private scroller: Scroller = new Scroller()
  
  build() {
    Scroll(this.scroller) {
      Column() {
        // 代码行...
      }
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .scrollBarColor('rgba(0, 0, 0, 0.2)')
    .scrollBarWidth(6)
    .edgeEffect(EdgeEffect.Spring)  // 边缘弹性回弹
    .friction(0.8)  // 滚动摩擦力（惯性）
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }
}
```

---

## 🔲 微交互细节

### 1. 文件保存状态指示

```typescript
@Component
struct SaveIndicator {
  @State isDirty: boolean = true
  @State dotScale: number = 1
  @State dotOpacity: number = 1
  
  aboutToAppear() {
    // 脉冲动画
    if (this.isDirty) {
      this.startPulseAnimation()
    }
  }
  
  startPulseAnimation() {
    // 循环脉冲
    setInterval(() => {
      animateTo({
        duration: 800,
        curve: Curve.EaseInOut
      }, () => {
        this.dotScale = this.dotScale === 1 ? 1.2 : 1
        this.dotOpacity = this.dotOpacity === 1 ? 0.6 : 1
      })
    }, 800)
  }
  
  build() {
    if (this.isDirty) {
      Circle()
        .width(8)
        .height(8)
        .fill('#F59E0B')  // 警告黄色
        .scale({ x: this.dotScale, y: this.dotScale })
        .opacity(this.dotOpacity)
    }
  }
}
```

### 2. 加载骨架屏

```typescript
@Component
struct SkeletonLoader {
  @State shimmerOffset: number = -200
  
  aboutToAppear() {
    // 循环闪烁动画
    this.startShimmer()
  }
  
  startShimmer() {
    animateTo({
      duration: 1200,
      curve: Curve.EaseInOut,
      iterations: -1  // 无限循环
    }, () => {
      this.shimmerOffset = 400
    })
  }
  
  build() {
    Column({ space: 12 }) {
      ForEach([1, 2, 3, 4, 5], () => {
        Row() {
          // 行号骨架
          this.SkeletonBlock(30, 16)
          
          // 代码骨架
          this.SkeletonBlock(Math.random() * 200 + 100, 16)
        }
        .width('100%')
        .padding({ left: 16 })
      })
    }
  }
  
  @Builder
  SkeletonBlock(width: number, height: number) {
    Stack() {
      // 基础色
      Row()
        .width(width)
        .height(height)
        .backgroundColor('#E5E8EB')
        .borderRadius(4)
      
      // 闪烁高光
      Row()
        .width(60)
        .height(height)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [
            ['rgba(255,255,255,0)', 0],
            ['rgba(255,255,255,0.5)', 0.5],
            ['rgba(255,255,255,0)', 1]
          ]
        })
        .offset({ x: this.shimmerOffset })
        .animation({
          duration: 1200,
          curve: Curve.EaseInOut,
          iterations: -1
        })
    }
    .clip(true)
    .borderRadius(4)
  }
}
```

---

## 📐 完整组件示例：精美文件树节点

```typescript
@Component
struct PremiumFileTreeNode {
  @Prop node: FileNode
  @Prop level: number = 0
  @Prop isExpanded: boolean = false
  @Prop isSelected: boolean = false
  
  @State hoverState: boolean = false
  @State pressState: boolean = false
  @State arrowRotation: number = 0
  @State itemScale: number = 1
  @State bgOpacity: number = 0
  @State iconBounce: number = 0
  
  onSelect: (node: FileNode) => void = () => {}
  onToggle: (node: FileNode) => void = () => {}
  
  build() {
    Row() {
      // 缩进
      Blank().width(this.level * 20 + 12)
      
      // 展开箭头（仅文件夹）
      if (this.node.type === 'folder') {
        Text('▶')
          .fontSize(9)
          .fontColor(this.isSelected ? '#0A59F7' : '#9CA3AF')
          .rotate({ angle: this.arrowRotation })
          .width(16)
          .textAlign(TextAlign.Center)
      } else {
        Blank().width(16)
      }
      
      // 文件图标（带弹跳效果）
      Text(this.getFileIcon())
        .fontSize(16)
        .margin({ left: 4, right: 10 })
        .translate({ y: this.iconBounce })
      
      // 文件名
      Text(this.node.name)
        .fontSize(13)
        .fontColor(this.isSelected ? '#0A59F7' : '#374151')
        .fontWeight(this.isSelected ? FontWeight.Medium : FontWeight.Normal)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      
      // 文件大小或子项数量
      if (!this.node.isDirectory) {
        Text(this.formatSize(this.node.size))
          .fontSize(11)
          .fontColor('#9CA3AF')
          .margin({ right: 8 })
      }
    }
    .width('100%')
    .height(36)
    .padding({ right: 12 })
    .scale({ x: this.itemScale, y: this.itemScale })
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(8)
    .margin({ left: 4, right: 4, top: 1, bottom: 1 })
    // 所有动画统一配置
    .animation({
      duration: 200,
      curve: curves.springMotion(0.6, 0.95)
    })
    // 交互事件
    .onHover((isHover: boolean) => {
      this.hoverState = isHover
      if (isHover) {
        // 图标弹跳
        animateTo({
          duration: 300,
          curve: curves.springMotion(0.3, 0.6)
        }, () => {
          this.iconBounce = -3
        })
        setTimeout(() => {
          animateTo({
            duration: 300,
            curve: curves.springMotion(0.4, 0.8)
          }, () => {
            this.iconBounce = 0
          })
        }, 150)
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressState = true
        animateTo({
          duration: 100,
          curve: Curve.EaseOut
        }, () => {
          this.itemScale = 0.98
        })
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressState = false
        animateTo({
          duration: 250,
          curve: curves.springMotion(0.35, 0.8)
        }, () => {
          this.itemScale = 1
        })
      }
    })
    .onClick(() => {
      if (this.node.type === 'folder') {
        // 展开/折叠动画
        animateTo({
          duration: 250,
          curve: curves.springMotion(0.5, 0.85)
        }, () => {
          this.arrowRotation = this.isExpanded ? 0 : 90
        })
        this.onToggle(this.node)
      } else {
        this.onSelect(this.node)
      }
    })
  }
  
  getBackgroundColor(): ResourceColor {
    if (this.isSelected) {
      return 'rgba(10, 89, 247, 0.12)'
    } else if (this.pressState) {
      return 'rgba(10, 89, 247, 0.08)'
    } else if (this.hoverState) {
      return 'rgba(0, 0, 0, 0.04)'
    }
    return Color.Transparent
  }
  
  getFileIcon(): string {
    if (this.node.type === 'folder') {
      return this.isExpanded ? '📂' : '📁'
    }
    const iconMap: Record<string, string> = {
      'ts': '🔷', 'ets': '🔶', 'js': '🟨',
      'json': '📋', 'md': '📝', 'html': '🌐',
      'css': '🎨', 'py': '🐍'
    }
    return iconMap[this.node.extension || ''] || '📄'
  }
  
  formatSize(size: number): string {
    if (size < 1024) return `${size} B`
    if (size < 1024 * 1024) return `${(size / 1024).toFixed(1)} KB`
    return `${(size / (1024 * 1024)).toFixed(1)} MB`
  }
}
```

---

## 🎯 动画性能优化原则

1. **使用 `animateTo` 而非 `animation` 属性**：对于复杂状态变化，`animateTo` 更高效
2. **避免在动画中频繁创建/销毁组件**：使用 `opacity` 和 `scale` 代替 `if` 条件渲染
3. **使用 `clip(true)`**：限制动画区域，减少重绘范围
4. **弹性曲线代替线性动画**：`springMotion` 让动画更自然且GPU友好
5. **动画时长控制**：
   - 微交互：100-200ms
   - 状态切换：250-400ms  
   - 页面过渡：400-600ms

---

## 📱 设计成果预览

实现以上设计后，代码编辑器将具备：

- ✅ **玻璃拟态背景** - 半透明毛玻璃效果
- ✅ **弹性动画** - 所有交互都有物理反馈
- ✅ **悬浮高亮** - 鼠标/手指悬停时的视觉反馈
- ✅ **流畅的展开/折叠** - 文件树平滑展开
- ✅ **涟漪点击效果** - 按钮点击涟漪扩散
- ✅ **丝滑主题切换** - 深浅色平滑过渡
- ✅ **惯性滚动** - 代码区自然滚动体验
- ✅ **微交互细节** - 图标弹跳、状态脉冲等

这就是鸿蒙6系统级别的UI品质！需要我开始实现具体代码吗？
