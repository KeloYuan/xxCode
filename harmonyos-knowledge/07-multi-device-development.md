# 07 - 一次开发多端部署

## 概述

HarmonyOS 的"一次开发，多端部署"能力允许开发者编写一套代码，在手机、平板、折叠屏、智能穿戴等多种设备上运行，并能自动适配不同屏幕尺寸和设备特性。

### 核心能力

1. **响应式布局**：UI 元素随窗口尺寸变化自动调整
2. **自适应布局**：根据设备类型和屏幕尺寸切换不同的布局方案
3. **栅格系统**：基于断点的栅格布局
4. **资源限定词**：针对不同设备提供不同的资源文件

---

## 1. 响应式布局

响应式布局通过弹性布局和比例设置，使组件随窗口尺寸变化自动调整。

### 1.1 使用 LayoutWeight 实现弹性布局

```typescript
@Entry
@Component
struct ResponsiveLayout {
  build() {
    Row() {
      // 左侧固定宽度
      Column() {
        Text('侧边栏')
          .fontSize(16)
      }
      .width(200)
      .height('100%')
      .backgroundColor('#f0f0f0')

      // 右侧自适应填充剩余空间
      Column() {
        Text('主内容区')
          .fontSize(16)
      }
      .layoutWeight(1)  // 占据剩余空间
      .height('100%')
      .backgroundColor('#ffffff')
    }
    .width('100%')
    .height('100%')
  }
}
```

### 1.2 使用百分比布局

```typescript
@Entry
@Component
struct PercentageLayout {
  build() {
    Column() {
      Row() {
        Text('30%')
          .width('30%')
          .height(100)
          .backgroundColor('#409EFF')
          .textAlign(TextAlign.Center)

        Text('70%')
          .width('70%')
          .height(100)
          .backgroundColor('#67C23A')
          .textAlign(TextAlign.Center)
      }
      .width('100%')

      Row() {
        Text('25%')
          .width('25%')
          .height(100)
          .backgroundColor('#E6A23C')

        Text('25%')
          .width('25%')
          .height(100)
          .backgroundColor('#F56C6C')

        Text('50%')
          .width('50%')
          .height(100)
          .backgroundColor('#909399')
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding(20)
  }
}
```

### 1.3 弹性布局（Flex）

```typescript
@Entry
@Component
struct FlexLayout {
  build() {
    Column() {
      // 均分布局
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('Item 1')
          .width(100)
          .height(50)
          .backgroundColor('#409EFF')

        Text('Item 2')
          .width(100)
          .height(50)
          .backgroundColor('#67C23A')

        Text('Item 3')
          .width(100)
          .height(50)
          .backgroundColor('#E6A23C')
      }
      .width('100%')
      .padding(10)

      // 自适应换行
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach([1, 2, 3, 4, 5, 6], (item: number) => {
          Text(`Item ${item}`)
            .width(150)
            .height(50)
            .margin(5)
            .backgroundColor('#409EFF')
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .padding(10)
      .margin({ top: 20 })
    }
  }
}
```

---

## 2. 栅格系统（GridRow/GridCol）

栅格系统是实现多端适配的核心方案，将屏幕分为 12 列，通过断点自动调整布局。

### 2.1 基础栅格布局

```typescript
@Entry
@Component
struct GridLayoutExample {
  build() {
    GridRow({
      columns: 12,  // 12 列栅格
      gutter: 10    // 间距 10vp
    }) {
      // 手机上占 12 列（全宽），平板上占 6 列（半宽）
      GridCol({ span: { xs: 12, sm: 12, md: 6, lg: 6 } }) {
        Text('列 1')
          .width('100%')
          .height(100)
          .backgroundColor('#409EFF')
          .textAlign(TextAlign.Center)
      }

      GridCol({ span: { xs: 12, sm: 12, md: 6, lg: 6 } }) {
        Text('列 2')
          .width('100%')
          .height(100)
          .backgroundColor('#67C23A')
          .textAlign(TextAlign.Center)
      }

      // 手机上占 12 列，平板上占 4 列
      GridCol({ span: { xs: 12, sm: 6, md: 4, lg: 4 } }) {
        Text('列 3')
          .width('100%')
          .height(100)
          .backgroundColor('#E6A23C')
          .textAlign(TextAlign.Center)
      }

      GridCol({ span: { xs: 12, sm: 6, md: 4, lg: 4 } }) {
        Text('列 4')
          .width('100%')
          .height(100)
          .backgroundColor('#F56C6C')
          .textAlign(TextAlign.Center)
      }

      GridCol({ span: { xs: 12, sm: 12, md: 4, lg: 4 } }) {
        Text('列 5')
          .width('100%')
          .height(100)
          .backgroundColor('#909399')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding(10)
  }
}
```

### 2.2 断点说明

| 断点名称 | 屏幕宽度范围 | 典型设备 |
|---------|------------|---------|
| xs      | [0, 320vp) | 超小屏幕 |
| sm      | [320vp, 600vp) | 手机竖屏 |
| md      | [600vp, 840vp) | 手机横屏/小平板 |
| lg      | [840vp, +∞) | 平板/PC |

### 2.3 栅格偏移和排序

```typescript
@Entry
@Component
struct GridOffsetExample {
  build() {
    GridRow({ columns: 12, gutter: 10 }) {
      // 占 4 列，偏移 2 列
      GridCol({ span: 4, offset: 2 }) {
        Text('偏移 2 列')
          .width('100%')
          .height(80)
          .backgroundColor('#409EFF')
          .textAlign(TextAlign.Center)
      }

      // 占 4 列
      GridCol({ span: 4 }) {
        Text('正常')
          .width('100%')
          .height(80)
          .backgroundColor('#67C23A')
          .textAlign(TextAlign.Center)
      }

      // 排序：order 越小越靠前
      GridCol({ span: 4, order: 2 }) {
        Text('Order 2')
          .width('100%')
          .height(80)
          .backgroundColor('#E6A23C')
          .textAlign(TextAlign.Center)
      }

      GridCol({ span: 4, order: 1 }) {
        Text('Order 1')
          .width('100%')
          .height(80)
          .backgroundColor('#F56C6C')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding(10)
  }
}
```

---

## 3. 自适应布局

根据设备类型和屏幕尺寸，动态切换不同的布局方案。

### 3.1 使用 @ohos.mediaquery 实现媒体查询

```typescript
import mediaquery from '@ohos.mediaquery';

@Entry
@Component
struct AdaptiveLayout {
  @State isTablet: boolean = false;
  private listener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(min-width: 600vp)');

  aboutToAppear() {
    // 监听屏幕宽度变化
    this.listener.on('change', (result: mediaquery.MediaQueryResult) => {
      this.isTablet = result.matches;
    });
    this.isTablet = this.listener.matches;
  }

  aboutToDisappear() {
    this.listener.off('change');
  }

  build() {
    Column() {
      if (this.isTablet) {
        // 平板布局：双列
        this.TabletLayout();
      } else {
        // 手机布局：单列
        this.PhoneLayout();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PhoneLayout() {
    List() {
      ForEach([1, 2, 3, 4, 5, 6], (item: number) => {
        ListItem() {
          Row() {
            Text(`Item ${item}`)
              .fontSize(18)
              .width('100%')
              .padding(20)
          }
          .width('100%')
          .backgroundColor('#ffffff')
          .borderRadius(8)
        }
        .margin({ bottom: 10 })
      })
    }
    .width('100%')
    .height('100%')
    .padding(10)
  }

  @Builder
  TabletLayout() {
    Row() {
      // 左侧导航
      Column() {
        Text('导航栏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .padding(20)

        List() {
          ForEach(['首页', '消息', '设置'], (item: string) => {
            ListItem() {
              Text(item)
                .fontSize(16)
                .padding(15)
            }
          })
        }
      }
      .width(250)
      .height('100%')
      .backgroundColor('#f0f0f0')

      // 右侧内容
      Column() {
        Grid() {
          ForEach([1, 2, 3, 4, 5, 6], (item: number) => {
            GridItem() {
              Column() {
                Text(`Item ${item}`)
                  .fontSize(18)
                  .width('100%')
                  .padding(20)
              }
              .width('100%')
              .height(120)
              .backgroundColor('#ffffff')
              .borderRadius(8)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(10)
        .columnsGap(10)
        .padding(10)
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
```

### 3.2 使用断点系统

```typescript
class BreakpointSystem {
  private currentBreakpoint: string = 'sm';
  private listeners: ((breakpoint: string) => void)[] = [];

  private smListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(320vp <= width < 600vp)');
  private mdListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(600vp <= width < 840vp)');
  private lgListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(width >= 840vp)');

  register() {
    this.smListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint('sm');
      }
    });

    this.mdListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint('md');
      }
    });

    this.lgListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.updateBreakpoint('lg');
      }
    });

    // 初始化当前断点
    if (this.smListener.matches) {
      this.currentBreakpoint = 'sm';
    } else if (this.mdListener.matches) {
      this.currentBreakpoint = 'md';
    } else if (this.lgListener.matches) {
      this.currentBreakpoint = 'lg';
    }
  }

  unregister() {
    this.smListener.off('change');
    this.mdListener.off('change');
    this.lgListener.off('change');
  }

  onChange(callback: (breakpoint: string) => void) {
    this.listeners.push(callback);
  }

  private updateBreakpoint(breakpoint: string) {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint;
      this.listeners.forEach(listener => listener(breakpoint));
    }
  }

  getCurrentBreakpoint(): string {
    return this.currentBreakpoint;
  }
}

@Entry
@Component
struct BreakpointExample {
  @State currentBreakpoint: string = 'sm';
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  aboutToAppear() {
    this.breakpointSystem.register();
    this.currentBreakpoint = this.breakpointSystem.getCurrentBreakpoint();

    this.breakpointSystem.onChange((breakpoint: string) => {
      this.currentBreakpoint = breakpoint;
    });
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  build() {
    Column() {
      Text(`当前断点: ${this.currentBreakpoint}`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      if (this.currentBreakpoint === 'sm') {
        this.SmallScreenLayout();
      } else if (this.currentBreakpoint === 'md') {
        this.MediumScreenLayout();
      } else {
        this.LargeScreenLayout();
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }

  @Builder
  SmallScreenLayout() {
    Column() {
      Text('手机布局')
        .fontSize(18)
        .fontColor('#409EFF')
    }
  }

  @Builder
  MediumScreenLayout() {
    Column() {
      Text('平板竖屏布局')
        .fontSize(18)
        .fontColor('#67C23A')
    }
  }

  @Builder
  LargeScreenLayout() {
    Row() {
      Text('平板横屏/PC 布局')
        .fontSize(18)
        .fontColor('#E6A23C')
    }
  }
}
```

---

## 4. 资源限定词

通过资源限定词为不同设备提供不同的资源文件。

### 4.1 目录结构

```
resources/
├── base/                    # 默认资源
│   ├── element/
│   │   ├── color.json       # 颜色
│   │   ├── string.json      # 字符串
│   │   └── float.json       # 尺寸
│   └── media/
│       └── icon.png
├── phone/                   # 手机专用资源
│   └── element/
│       └── float.json
├── tablet/                  # 平板专用资源
│   └── element/
│       └── float.json
├── dark/                    # 深色模式资源
│   └── element/
│       └── color.json
└── en_US/                   # 英文资源
    └── element/
        └── string.json
```

### 4.2 资源文件示例

**base/element/float.json**
```json
{
  "float": [
    {
      "name": "page_padding",
      "value": "16vp"
    },
    {
      "name": "card_height",
      "value": "120vp"
    },
    {
      "name": "font_size_title",
      "value": "18fp"
    }
  ]
}
```

**tablet/element/float.json**
```json
{
  "float": [
    {
      "name": "page_padding",
      "value": "32vp"
    },
    {
      "name": "card_height",
      "value": "150vp"
    },
    {
      "name": "font_size_title",
      "value": "22fp"
    }
  ]
}
```

### 4.3 使用资源

```typescript
@Entry
@Component
struct ResourceExample {
  build() {
    Column() {
      Text($r('app.string.app_name'))
        .fontSize($r('app.float.font_size_title'))
        .fontColor($r('app.color.primary'))
        .padding($r('app.float.page_padding'))

      Row()
        .width('100%')
        .height($r('app.float.card_height'))
        .backgroundColor($r('app.color.card_background'))
    }
    .width('100%')
    .height('100%')
  }
}
```

---

## 5. 实战案例：自适应卡片列表

综合运用多种技术实现自适应卡片布局。

```typescript
import mediaquery from '@ohos.mediaquery';

interface CardData {
  id: number;
  title: string;
  description: string;
  image: string;
}

@Entry
@Component
struct AdaptiveCardList {
  @State currentBreakpoint: string = 'sm';
  @State cardList: CardData[] = [
    { id: 1, title: '卡片 1', description: '这是卡片 1 的描述', image: '' },
    { id: 2, title: '卡片 2', description: '这是卡片 2 的描述', image: '' },
    { id: 3, title: '卡片 3', description: '这是卡片 3 的描述', image: '' },
    { id: 4, title: '卡片 4', description: '这是卡片 4 的描述', image: '' },
    { id: 5, title: '卡片 5', description: '这是卡片 5 的描述', image: '' },
    { id: 6, title: '卡片 6', description: '这是卡片 6 的描述', image: '' },
  ];

  private smListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(320vp <= width < 600vp)');
  private mdListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(600vp <= width < 840vp)');
  private lgListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(width >= 840vp)');

  aboutToAppear() {
    this.smListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) this.currentBreakpoint = 'sm';
    });

    this.mdListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) this.currentBreakpoint = 'md';
    });

    this.lgListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) this.currentBreakpoint = 'lg';
    });

    // 初始化
    if (this.smListener.matches) {
      this.currentBreakpoint = 'sm';
    } else if (this.mdListener.matches) {
      this.currentBreakpoint = 'md';
    } else if (this.lgListener.matches) {
      this.currentBreakpoint = 'lg';
    }
  }

  aboutToDisappear() {
    this.smListener.off('change');
    this.mdListener.off('change');
    this.lgListener.off('change');
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('自适应卡片列表')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text(`断点: ${this.currentBreakpoint}`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .padding(20)

      // 使用栅格系统实现自适应布局
      GridRow({
        columns: 12,
        gutter: { x: 16, y: 16 }
      }) {
        ForEach(this.cardList, (item: CardData) => {
          GridCol({
            span: {
              sm: 12,  // 手机：1 列
              md: 6,   // 小平板：2 列
              lg: 4    // 大平板/PC：3 列
            }
          }) {
            this.CardItem(item);
          }
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  CardItem(item: CardData) {
    Column() {
      // 卡片图片
      Row()
        .width('100%')
        .height(150)
        .backgroundColor('#e0e0e0')
        .borderRadius({ topLeft: 12, topRight: 12 })

      // 卡片内容
      Column() {
        Text(item.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })

        Text(item.description)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#1f000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}
```

---

## 6. 设备类型判断

### 6.1 获取设备类型

```typescript
import deviceInfo from '@ohos.deviceInfo';

@Entry
@Component
struct DeviceTypeExample {
  @State deviceType: string = '';

  aboutToAppear() {
    // 获取设备类型
    // deviceInfo.deviceType: 'phone', 'tablet', 'wearable', 'tv', 'car'
    this.deviceType = deviceInfo.deviceType;
  }

  build() {
    Column() {
      Text(`设备类型: ${this.deviceType}`)
        .fontSize(20)
        .margin({ bottom: 20 })

      if (this.deviceType === 'phone') {
        Text('这是手机')
          .fontSize(18)
          .fontColor('#409EFF')
      } else if (this.deviceType === 'tablet') {
        Text('这是平板')
          .fontSize(18)
          .fontColor('#67C23A')
      } else {
        Text('其他设备')
          .fontSize(18)
          .fontColor('#909399')
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

### 6.2 获取窗口信息

```typescript
import window from '@ohos.window';

@Entry
@Component
struct WindowInfoExample {
  @State windowWidth: number = 0;
  @State windowHeight: number = 0;
  @State isPortrait: boolean = true;

  async aboutToAppear() {
    try {
      // 获取当前窗口
      const win = await window.getLastWindow(getContext(this));
      
      // 获取窗口尺寸
      const properties = win.getWindowProperties();
      this.windowWidth = properties.windowRect.width;
      this.windowHeight = properties.windowRect.height;
      this.isPortrait = this.windowHeight > this.windowWidth;

      // 监听窗口尺寸变化
      win.on('windowSizeChange', (size) => {
        this.windowWidth = size.width;
        this.windowHeight = size.height;
        this.isPortrait = this.windowHeight > this.windowWidth;
      });
    } catch (err) {
      console.error('Failed to get window info: ' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      Text(`窗口宽度: ${this.windowWidth}px`)
        .fontSize(16)
        .margin({ bottom: 10 })

      Text(`窗口高度: ${this.windowHeight}px`)
        .fontSize(16)
        .margin({ bottom: 10 })

      Text(`屏幕方向: ${this.isPortrait ? '竖屏' : '横屏'}`)
        .fontSize(16)
        .fontColor(this.isPortrait ? '#409EFF' : '#67C23A')
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

---

## 7. 最佳实践

### 7.1 布局选择建议

| 场景 | 推荐方案 | 说明 |
|------|---------|------|
| 简单比例布局 | LayoutWeight / 百分比 | 性能好，适合简单场景 |
| 标准网格布局 | GridRow/GridCol | 标准化，易维护 |
| 复杂自适应 | MediaQuery + 自定义布局 | 灵活，可控性强 |
| 列表/网格 | List/Grid + 响应式列数 | 内置优化，性能好 |

### 7.2 开发流程

1. **设计阶段**：确定各断点的布局方案
2. **开发阶段**：优先使用栅格系统，必要时使用媒体查询
3. **测试阶段**：在多种设备和屏幕尺寸下测试
4. **优化阶段**：根据实际效果调整断点和布局

### 7.3 注意事项

1. **性能优化**
   - 避免频繁的布局切换
   - 合理使用 @Builder 和 @BuilderParam
   - 大列表使用 LazyForEach

2. **兼容性**
   - 提供默认布局方案
   - 使用资源限定词提供降级资源
   - 测试边界情况

3. **用户体验**
   - 保持操作一致性
   - 合理利用大屏空间
   - 避免过度动画

---

## 8. 完整示例：新闻应用

```typescript
import mediaquery from '@ohos.mediaquery';

interface NewsItem {
  id: number;
  title: string;
  summary: string;
  image: string;
  category: string;
  publishTime: string;
}

@Entry
@Component
struct NewsApp {
  @State currentBreakpoint: string = 'sm';
  @State selectedCategory: string = '推荐';
  @State newsList: NewsItem[] = [
    {
      id: 1,
      title: '鸿蒙 HarmonyOS NEXT 正式发布',
      summary: '华为正式发布鸿蒙 HarmonyOS NEXT，支持纯鸿蒙应用生态',
      image: '',
      category: '科技',
      publishTime: '2小时前'
    },
    {
      id: 2,
      title: 'ArkTS 4.0 新特性解析',
      summary: 'ArkTS 4.0 带来更强大的类型系统和性能优化',
      image: '',
      category: '科技',
      publishTime: '5小时前'
    },
    // 更多新闻项...
  ];

  private categories: string[] = ['推荐', '科技', '财经', '体育', '娱乐'];
  private smListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(320vp <= width < 600vp)');
  private mdListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(600vp <= width < 840vp)');
  private lgListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(width >= 840vp)');

  aboutToAppear() {
    this.smListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) this.currentBreakpoint = 'sm';
    });

    this.mdListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) this.currentBreakpoint = 'md';
    });

    this.lgListener.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) this.currentBreakpoint = 'lg';
    });

    if (this.smListener.matches) {
      this.currentBreakpoint = 'sm';
    } else if (this.mdListener.matches) {
      this.currentBreakpoint = 'md';
    } else if (this.lgListener.matches) {
      this.currentBreakpoint = 'lg';
    }
  }

  aboutToDisappear() {
    this.smListener.off('change');
    this.mdListener.off('change');
    this.lgListener.off('change');
  }

  build() {
    Column() {
      // 顶部标题栏
      this.TitleBar();

      if (this.currentBreakpoint === 'sm') {
        // 手机布局：单列 + 顶部分类
        this.PhoneLayout();
      } else if (this.currentBreakpoint === 'md') {
        // 平板布局：双列 + 顶部分类
        this.TabletLayout();
      } else {
        // 大屏布局：三列 + 侧边分类
        this.LargeScreenLayout();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  TitleBar() {
    Row() {
      Text('新闻')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Blank()

      Row() {
        Image($r('app.media.search_icon'))
          .width(24)
          .height(24)
          .margin({ right: 16 })

        Image($r('app.media.user_icon'))
          .width(24)
          .height(24)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#ffffff')
  }

  @Builder
  PhoneLayout() {
    Column() {
      // 分类标签
      this.CategoryTabs();

      // 新闻列表
      List({ space: 12 }) {
        ForEach(this.newsList, (item: NewsItem) => {
          ListItem() {
            this.NewsCardVertical(item);
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  TabletLayout() {
    Column() {
      // 分类标签
      this.CategoryTabs();

      // 新闻网格（2列）
      GridRow({ columns: 12, gutter: 16 }) {
        ForEach(this.newsList, (item: NewsItem) => {
          GridCol({ span: 6 }) {
            this.NewsCardVertical(item);
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  LargeScreenLayout() {
    Row() {
      // 左侧分类导航
      Column() {
        Text('分类')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        List() {
          ForEach(this.categories, (category: string) => {
            ListItem() {
              Text(category)
                .fontSize(16)
                .fontColor(this.selectedCategory === category ? '#409EFF' : '#333333')
                .padding(12)
            }
            .onClick(() => {
              this.selectedCategory = category;
            })
          })
        }
      }
      .width(200)
      .height('100%')
      .padding(16)
      .backgroundColor('#ffffff')

      // 右侧新闻内容（3列）
      GridRow({ columns: 12, gutter: 16 }) {
        ForEach(this.newsList, (item: NewsItem) => {
          GridCol({ span: 4 }) {
            this.NewsCardVertical(item);
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  CategoryTabs() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(16)
            .fontColor(this.selectedCategory === category ? '#409EFF' : '#666666')
            .fontWeight(this.selectedCategory === category ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .onClick(() => {
              this.selectedCategory = category;
            })
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .backgroundColor('#ffffff')
  }

  @Builder
  NewsCardVertical(item: NewsItem) {
    Column() {
      // 图片
      Row()
        .width('100%')
        .height(180)
        .backgroundColor('#e0e0e0')
        .borderRadius({ topLeft: 8, topRight: 8 })

      // 内容
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })

        Text(item.summary)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 12 })

        Row() {
          Text(item.category)
            .fontSize(12)
            .fontColor('#999999')

          Blank()

          Text(item.publishTime)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(8)
  }
}
```

---

## 总结

HarmonyOS 的一次开发多端部署能力通过以下技术实现：

1. **响应式布局**：使用 LayoutWeight、百分比、Flex 等实现弹性布局
2. **栅格系统**：通过 GridRow/GridCol 和断点系统实现标准化适配
3. **媒体查询**：使用 MediaQuery 动态切换布局方案
4. **资源限定词**：为不同设备提供定制化资源
5. **设备判断**：根据设备类型和窗口信息优化体验

合理运用这些技术，可以实现一套代码在多种设备上完美运行。

