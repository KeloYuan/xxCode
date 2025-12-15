---
inclusion: fileMatch
fileMatchPattern: ['entry/src/main/ets/components/*.ets']
---

# HarmonyOS 组件开发规范

## 组件设计原则

### 可复用性
- 组件应当高度可复用，避免硬编码业务逻辑
- 通过 `@Prop` 接收外部参数，提高组件灵活性
- 使用 `@State` 管理组件内部状态

### 性能优化
- 合理使用 `@Builder` 装饰器构建复杂 UI
- 避免在 `build` 方法中进行复杂计算
- 使用 `@Observed` 和 `@ObjectLink` 管理复杂对象状态

## 现有组件参考

### 高亮文本组件
参考 [HighlightedText.ets](mdc:entry/src/main/ets/components/HighlightedText.ets) 了解文本高亮处理

### Markdown 预览组件  
参考 [MarkdownPreview.ets](mdc:entry/src/main/ets/components/MarkdownPreview.ets) 了解内容预览实现

### 搜索对话框组件
参考 [SearchDialog.ets](mdc:entry/src/main/ets/components/SearchDialog.ets) 了解对话框组件设计

## 组件模板结构

```arkts
@Component
export struct CustomComponent {
  // Props - 外部传入参数
  @Prop title: string = ''
  @Prop @Watch('onDataChange') data: Array<string> = []
  
  // State - 内部状态
  @State isVisible: boolean = false
  
  // 监听器
  onDataChange() {
    // 数据变化处理逻辑
  }
  
  // 构建器方法
  @Builder
  buildHeader() {
    // 头部构建逻辑
  }
  
  build() {
    Column() {
      // 组件主体内容
      this.buildHeader()
      
      // 其他内容
    }
    .width('100%')
    .height('100%')
  }
}
```

## 组件交互规范

### 事件处理
- 使用明确的事件回调命名：`onTap`, `onChange`, `onConfirm` 等
- 事件参数应当类型明确，便于调试和维护

### 动画效果
- 优先使用 HarmonyOS 提供的预设动画效果
- 动画时长遵循系统建议：快速交互 200ms，一般交互 300ms，复杂动画 500ms

### 无障碍支持
- 为交互元素添加 `accessibilityText` 描述
- 确保组件支持键盘导航和屏幕阅读器