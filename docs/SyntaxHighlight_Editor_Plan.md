# 实时语法高亮编辑器实现计划

## 项目概述

### 目标
为 xxCode 代码编辑器实现**编辑时的实时语法高亮**功能，目前只有预览模式支持语法高亮，需要在用户输入代码时也能看到高亮效果。

### 当前状态分析

| 模式 | 组件 | 语法高亮 |
|------|------|----------|
| 编辑模式 | `CodeEditorView` (TextArea) | ❌ 无 |
| 预览模式 | 自定义渲染 (Text + Span) | ✅ 有 |

**问题根因**: 鸿蒙系统的 `TextArea` 组件不支持内联样式/富文本格式。

---

## 技术方案对比

### 方案一：透明叠加法 (推荐)
```
┌─────────────────────────────────┐
│ 底层: 语法高亮文本层 (只读)      │
│ ┌─ function hello() { ─────┐   │
│ │   const x = "world";     │   │
│ └──────────────────────────┘   │
│ ┌──────────────────────────┐   │
│ │ 透明 TextArea (可编辑)    │   │
│ └──────────────────────────┘   │
└─────────────────────────────────┘
```

**优点**:
- 开发周期短 (2-3天)
- 利用系统输入法，兼容性好
- 代码结构清晰，易维护
- 性能表现良好

**缺点**:
- 复制粘贴需要特殊处理
- 滚动同步需要精确对齐

---

### 方案二：RichEditor 组件

使用鸿蒙 `RichEditor` 富文本编辑器组件。

**优点**:
- 原生支持富文本
- 开发量最小

**缺点**:
- 文档和示例较少
- API 稳定性未知
- 可能存在性能问题
- 功能受限

---

### 方案三：完全自定义编辑器

从零构建自定义代码编辑器组件。

**优点**:
- 完全控制所有行为
- 可实现任意高级功能
- 长期可扩展性最佳

**缺点**:
- 开发周期长 (2-4周)
- 需要处理大量边界情况
- 输入法兼容性复杂
- 维护成本高

---

## 推荐方案：透明叠加法

### 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                    RichCodeEditor 组件                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Row (编辑器容器)                                    │   │
│  │  ┌─────────┬────────────────────────────────────┐   │   │
│  │  │ 行号列   │  Stack (代码区域)                  │   │   │
│  │  │ Column  │  ┌──────────────────────────────┐  │   │   │
│  │  │         │  │ 1. 高亮文本层 (底部)          │  │   │   │
│  │  │ 1       │  │    - Text + forEach(Span)     │  │   │   │
│  │  │ 2       │  │    - 语法分词渲染             │  │   │   │
│  │  │ 3       │  └──────────────────────────────┘  │   │   │
│  │  │         │  ┌──────────────────────────────┐  │   │   │
│  │  │         │  │ 2. 透明输入层 (顶部)          │  │   │   │
│  │  │         │  │    - TextArea (透明文字/光标) │  │   │   │
│  │  │         │  │    - 捕获所有输入事件         │  │   │   │
│  │  │         │  └──────────────────────────────┘  │   │   │
│  │  │         │  ┌──────────────────────────────┐  │   │   │
│  │  │         │  │ 3. 滚动同步机制               │  │   │   │
│  │  │         │  │    - 统一 Scroller            │  │   │   │
│  │  │         │  └──────────────────────────────┘  │   │   │
│  │  │         │                                    │   │   │
│  │  └─────────┴────────────────────────────────────┘   │   │
│  │                                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  服务层:                                                    │
│  - SyntaxHighlightService: 语法分词                         │
│  - CursorManager: 光标位置计算                             │
│  - ScrollSyncManager: 滚动同步                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 实施计划

### Phase 1: 基础组件开发 (1-2天)

#### 1.1 创建 RichCodeEditor 组件
**文件**: `entry/src/main/ets/components/RichCodeEditor.ets`

```typescript
@Component
export struct RichCodeEditor {
  // 输入属性
  @Prop @Watch('onContentChange') content: string = '';
  @Prop language: string = 'javascript';
  @Prop fontSize: number = 14;

  // 主题属性
  @Prop bgColor: string = '#1E1E1E';
  @Prop textColor: string = '#D4D4D4';
  @Prop caretColor: string = '#0A59F7';
  @Prop lineNumberColor: string = '#858585';

  // 语法高亮颜色
  @Prop keywordColor: string = '#569CD6';
  @Prop stringColor: string = '#CE9178';
  @Prop commentColor: string = '#6A9955';
  @Prop numberColor: string = '#B5CEA8';
  @Prop functionColor: string = '#DCDCAA';

  // 内部状态
  @State private textContent: string = '';
  @State private scrollOffset: number = 0;

  // 服务
  private syntaxService: SyntaxHighlightService = SyntaxHighlightService.getInstance();
  private scroller: Scroller = new Scroller();

  onChange?: (value: string) => void;

  // ... 实现细节
}
```

#### 1.2 核心功能清单

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 双层布局结构 | P0 | 高亮层 + 透明输入层 |
| 语法分词渲染 | P0 | 使用现有 SyntaxHighlightService |
| 滚动同步 | P0 | 两个层级同步滚动 |
| 行号显示 | P0 | 左侧行号列 |
| 内容同步 | P0 | 输入内容实时更新到高亮层 |

---

### Phase 2: 高级功能开发 (1-2天)

#### 2.1 输入增强

```typescript
// 自动缩进
private handleAutoIndent(): void {
  const currentLine = this.getCurrentLine();
  const indent = this.extractIndent(currentLine);
  this.insertText('\n' + indent);
}

// 自动闭合括号
private handleAutoCloseBracket(openBracket: string, closeBracket: string): void {
  this.insertText(openBracket + closeBracket);
  this.moveCursor(-1);
}

// Tab 键处理
private handleTab(): void {
  // 插入 2 个空格
  this.insertText('  ');
}
```

#### 2.2 剪贴板支持

```typescript
// 覆盖默认的复制/粘贴行为
private handleCopy(): void {
  const selectedText = this.getSelectedText();
  clipboard.setData(selectedText);
}

private handlePaste(): void {
  clipboard.getData().then((text: string) => {
    this.insertText(text);
  });
}
```

#### 2.3 撤销/重做

```typescript
interface EditAction {
  type: 'insert' | 'delete' | 'replace';
  content: string;
  cursorPosition: number;
  timestamp: number;
}

class HistoryManager {
  private undoStack: EditAction[] = [];
  private redoStack: EditAction[] = [];

  push(action: EditAction): void { ... }
  undo(): void { ... }
  redo(): void { ... }
  canUndo(): boolean { ... }
  canRedo(): boolean { ... }
}
```

---

### Phase 3: 优化与完善 (1天)

#### 3.1 性能优化

| 优化项 | 方法 | 预期效果 |
|--------|------|----------|
| 大文件处理 | 虚拟滚动 | 只渲染可见行 |
| 语法分词 | 增量更新 | 只重新分词变化的行 |
| 渲染优化 | LazyForEach | 减少组件重建 |

#### 3.2 用户体验优化

```typescript
// 平滑滚动
this.scroller.scrollTo({
  xOffset: 0,
  yOffset: targetOffset,
  animation: {
    duration: 150,
    curve: Curve.EaseInOut
  }
});

// 光标闪烁动画
Row()
  .width(2)
  .height(this.fontSize)
  .backgroundColor(this.caretColor)
  .animation({
    duration: 1000,
    curve: Curve.Linear,
    iterations: -1,
    playMode: PlayMode.Alternate
  })
  .opacity([1, 0.3, 1]);
```

---

## 详细实现步骤

### Step 1: 创建基础组件结构

```bash
# 创建新组件
touch entry/src/main/ets/components/RichCodeEditor.ets
touch entry/src/main/ets/services/CursorManager.ets
touch entry/src/main/ets/services/ScrollSyncManager.ets
```

### Step 2: 实现双层层级布局

```typescript
build() {
  Row() {
    // 行号列
    Column() {
      ForEach(this.getLineNumbers(), (num: number) => {
        Text(`${num}`)
          .fontSize(this.fontSize)
          .fontColor(this.lineNumberColor)
          .height(this.lineHeight)
      })
    }
    .width(40)
    .backgroundColor(this.bgColor)

    // 编辑区域
    Stack({ alignContent: Alignment.TopStart }) {
      // 底层: 高亮文本
      Scroll(this.scroller) {
        Column() {
          ForEach(this.getCodeLines(), (line: string) => {
            this.buildHighlightedLine(line)
          })
        }
      }
      .scrollBar(BarState.On)
      .width('100%')
      .height('100%')
      .onScroll((xOffset: number, yOffset: number) => {
        this.scrollOffset = yOffset;
      })

      // 顶层: 透明输入
      TextArea({
        text: this.content,
        placeholder: 'Start coding...'
      })
        .fontSize(this.fontSize)
        .fontColor(Color.Transparent)  // 文字透明
        .caretColor(this.caretColor)    // 光标可见
        .backgroundColor(Color.Transparent)
        .border({ width: 0 })
        .padding({ left: 8, right: 8 })
        .onChange((value: string) => {
          this.onContentChange(value);
        })
        .onTextAreaCursorPosition((index: number) => {
          this.cursorPosition = index;
        })
    }
    .layoutWeight(1)
    .backgroundColor(this.bgColor)
  }
}
```

### Step 3: 语法高亮渲染

```typescript
@Builder
buildHighlightedLine(line: string) {
  Row() {
    Text() {
      ForEach(this.syntaxService.tokenize(line, this.language),
        (token: Token, index: number) => {
          Span(token.value.replace(/ /g, '\u00A0'))
            .fontSize(this.fontSize)
            .fontColor(this.getTokenColor(token.type))
            .fontFamily('monospace')
        },
        (token: Token, index: number) => `${index}_${token.start}`
      )
    }
    .fontSize(this.fontSize)
    .fontFamily('monospace')
    .lineHeight(this.lineHeight)
    .textOverflow({ overflow: TextOverflow.Clip })
    .maxLines(1)
  }
  .width('100%')
  .height(this.lineHeight)
}
```

### Step 4: 集成到现有页面

修改 `CodeEditor.ets` 的 `buildEditor()` 方法：

```typescript
@Builder
buildEditor(): void {
  // 移除 isPreviewMode 分支，统一使用新组件
  RichCodeEditor({
    content: this.content,
    language: this.language,
    fontSize: this.fontSize,
    bgColor: this.currentTheme.editor.background,
    textColor: this.currentTheme.editor.text,
    caretColor: this.currentTheme.colors.primary,
    lineNumberColor: this.currentTheme.editor.lineNumber,
    keywordColor: this.currentTheme.syntax.keyword,
    stringColor: this.currentTheme.syntax.string,
    commentColor: this.currentTheme.syntax.comment,
    numberColor: this.currentTheme.syntax.number,
    functionColor: this.currentTheme.syntax.function,
    onChange: (value: string) => {
      this.onContentChange(value);
    }
  })
}
```

---

## 测试计划

### 功能测试

| 测试项 | 测试方法 | 预期结果 |
|--------|----------|----------|
| 基本输入 | 输入代码 | 实时显示高亮 |
| 关键字高亮 | 输入 `function` | 蓝色显示 |
| 字符串高亮 | 输入 `"hello"` | 橙色显示 |
| 注释高亮 | 输入 `// comment` | 绿色显示 |
| 滚动同步 | 滚动编辑器 | 行号和内容同步 |
| 多行编辑 | 输入换行 | 正确缩进 |

### 兼容性测试

| 设备类型 | 测试重点 |
|----------|----------|
| 手机 | 软键盘兼容、触摸滚动 |
| 平板 | 横竖屏切换、外接键盘 |
| 折叠屏 | 多窗口适配 |

### 性能测试

| 场景 | 指标 | 目标 |
|------|------|------|
| 100 行文件 | 输入延迟 | < 50ms |
| 1000 行文件 | 滚动帧率 | > 55fps |
| 语法分词 | 单行处理 | < 5ms |

---

## 风险与应对

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| TextArea 透明度兼容性 | 高 | 提前测试不同 API 版本 |
| 滚动位置偏移 | 中 | 使用像素级精确计算 |
| 输入法冲突 | 中 | 保留原有编辑模式作为备选 |
| 大文件性能 | 低 | 添加虚拟滚动机制 |

---

## 里程碑

| 阶段 | 时间 | 交付物 |
|------|------|--------|
| Phase 1 | Day 1-2 | 基础组件，可编辑高亮 |
| Phase 2 | Day 3-4 | 高级功能，完整体验 |
| Phase 3 | Day 5 | 优化完成，上线就绪 |

---

## 长期演进

### V2.0 计划

- [ ] 代码折叠
- [ ] 小地图 (minimap)
- [ ] 多光标编辑
- [ ] 代码提示 (IntelliSense)
- [ ] 错误提示波浪线
- [ ] 搜索高亮
- [ ] 快捷键绑定

### V3.0 计划

- [ ] 协同编辑
- [ ] Git 差异可视化
- [ ] 代码重构工具
- [ ] LSP (Language Server Protocol) 集成

---

## 附录

### 相关文件

```
entry/src/main/ets/
├── components/
│   ├── RichCodeEditor.ets          # 新建：主编辑器组件
│   └── CodeEditorView.ets          # 保留：向后兼容
├── services/
│   ├── SyntaxHighlightService.ets  # 现有：语法高亮
│   ├── CursorManager.ets           # 新建：光标管理
│   └── ScrollSyncManager.ets       # 新建：滚动同步
└── pages/
    └── CodeEditor.ets              # 修改：集成新组件
```

### 参考资料

- [鸿蒙 RichEditor 文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-container-richeditor-V5)
- [鸿蒙 TextArea 文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-basic-components-textarea-V5)
- [VS Code 编辑器实现](https://github.com/microsoft/vscode)
- [Monaco Editor](https://github.com/microsoft/monaco-editor)

---

*文档版本: 1.0*
*创建日期: 2024-12-23*
*最后更新: 2024-12-23*
