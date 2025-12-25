# 元代码 - 移动端 UI 适配规范

## 项目概述
为元代码（MetaCode）编辑器实现移动端响应式布局，针对手机小屏幕优化界面，通过侧滑抽屉和底部面板最大化编辑区域。

## 用户故事

### US-1: 响应式断点检测
**作为** 用户  
**我想要** 应用能自动检测屏幕尺寸并切换布局模式  
**以便** 在不同设备上获得最佳体验

**验收标准：**
- [x] 小屏手机（< 360dp）：使用移动端布局，侧滑抽屉宽度 240dp
- [x] 中屏手机（360-480dp）：使用移动端布局，侧滑抽屉宽度 280dp
- [x] 大屏设备（> 480dp）：保持当前桌面布局，文件浏览器常驻左侧
- [x] 布局切换时有流畅的过渡动画（300ms）
- [x] 旋转屏幕时自动重新计算布局

### US-2: 移动端顶部导航栏
**作为** 移动端用户  
**我想要** 简化的顶部导航栏只显示核心功能  
**以便** 最大化编辑区域

**验收标准：**
- [x] 顶部导航栏高度固定 56dp
- [x] 左侧显示文件浏览器按钮 [☰]
- [x] 中间显示当前文件名和修改状态（如：未命名.js •）
- [x] 右侧显示功能菜单按钮 [⋮]
- [x] 点击文件名区域打开标签管理面板
- [x] 所有按钮热区至少 44x44 vp（符合 HarmonyOS 无障碍规范）

### US-3: 左侧文件浏览器抽屉
**作为** 移动端用户  
**我想要** 通过侧滑访问文件浏览器  
**以便** 快速切换文件而不占用编辑空间

**验收标准：**
- [ ] 点击左上角 [☰] 按钮打开文件浏览器
- [ ] 支持从左边缘向右滑动手势打开（滑动距离 > 50dp）
- [ ] 抽屉从左侧滑入，带弹性动画（300ms，springMotion）
- [x] 显示半透明遮罩层（opacity: 0.5）
- [x] 点击遮罩层或向左滑动关闭抽屉
- [ ] 抽屉内容包括：工作区文件列表、新建文件按钮
- [ ] 点击文件名打开文件并自动关闭抽屉
- [ ] 长按文件显示删除选项

### US-4: 右侧功能菜单抽屉
**作为** 移动端用户  
**我想要** 通过侧滑访问所有编辑功能  
**以便** 保持编辑区域整洁

**验收标准：**
- [x] 点击右上角 [⋮] 按钮打开功能菜单
- [x] 支持从右边缘向左滑动手势打开（滑动距离 > 50dp）
- [x] 抽屉从右侧滑入，带弹性动画（300ms，springMotion）
- [x] 显示半透明遮罩层（opacity: 0.5）
- [x] 点击遮罩层或向右滑动关闭抽屉
- [x] 菜单分组显示：
  - 编辑工具：模板、格式化、搜索、预览切换
  - 文件操作：保存、导出、打开外部文件、导入到工作区
  - 应用设置：主题切换、设置
- [x] 点击菜单项执行操作并自动关闭抽屉

### US-5: 标签管理底部面板
**作为** 移动端用户  
**我想要** 通过底部面板管理多个打开的文件标签  
**以便** 快速切换和关闭标签

**验收标准：**
- [x] 点击顶部文件名区域打开标签管理面板
- [ ] 面板从底部滑入，高度 60%，带弹性动画（350ms）
- [ ] 显示半透明遮罩层（opacity: 0.5）
- [ ] 向下滑动或点击遮罩关闭面板
- [ ] 每个标签显示为卡片，包含：
  - 文件图标和文件名
  - 语言类型和行数
  - 修改状态标识（•）
  - 关闭按钮 [×]
- [ ] 点击卡片切换到该标签并关闭面板
- [ ] 点击 [×] 关闭标签（如有未保存内容则提示）
- [ ] 底部显示"新建标签"按钮

### US-6: 搜索栏展开式设计
**作为** 移动端用户  
**我想要** 搜索功能在需要时展开显示  
**以便** 不占用编辑空间

**验收标准：**
- [ ] 从右侧菜单点击"搜索"展开搜索栏
- [ ] 搜索栏在顶部导航栏下方展开（高度从 0 到 auto，200ms）
- [ ] 包含搜索输入框、替换输入框、导航按钮
- [ ] 显示匹配数量（如：1/3）
- [ ] 点击关闭按钮收起搜索栏
- [ ] 移动端优化：按钮更大（44x44 vp），输入框占满宽度

### US-7: 编辑区域全屏显示
**作为** 移动端用户  
**我想要** 编辑区域占据除顶部导航栏外的全部空间  
**以便** 获得最大的代码可视区域

**验收标准：**
- [ ] 编辑区域占据屏幕除顶部导航栏（56dp）外的全部空间
- [ ] 左侧行号列宽度 40dp（小屏 32dp）
- [ ] 右侧编辑区自适应剩余宽度
- [ ] 支持垂直滚动查看全部代码
- [ ] 编辑/预览模式切换保持流畅（300ms 动画）
- [ ] 字体大小根据屏幕尺寸自动调整（小屏 12sp，中屏 14sp）

### US-8: 手势支持
**作为** 移动端用户  
**我想要** 使用手势快速访问功能  
**以便** 提高操作效率

**验收标准：**
- [ ] 从左边缘向右滑动（> 50dp）打开文件浏览器
- [ ] 从右边缘向左滑动（> 50dp）打开功能菜单
- [ ] 在抽屉上向相反方向滑动关闭抽屉
- [ ] 在底部面板上向下滑动关闭面板
- [ ] 双指捏合/展开调整字体大小（可选，P2 优先级）
- [ ] 手势操作有视觉反馈（跟随手指移动）

## 技术实现方案

### 1. 响应式断点服务扩展

**文件：** `entry/src/main/ets/services/BreakpointService.ets`

**修改内容：**
```typescript
// 添加移动端断点判断
export type Breakpoint = 'xs' | 'sm' | 'md' | 'lg';

export class BreakpointService {
  isMobile(): boolean {
    const bp = this.getCurrentBreakpoint();
    return bp === 'xs' || bp === 'sm';
  }
  
  getDrawerWidth(): number {
    const bp = this.getCurrentBreakpoint();
    if (bp === 'xs') return 240;
    if (bp === 'sm') return 280;
    return 0; // 大屏不使用抽屉
  }
}
```

### 2. 移动端抽屉组件

**新建文件：** `entry/src/main/ets/components/DrawerPanel.ets`

**功能：**
- 通用侧滑抽屉组件
- 支持左侧/右侧滑入
- 支持手势拖拽
- 半透明遮罩层
- 弹性动画

**Props：**
- `visible: boolean` - 是否显示
- `position: 'left' | 'right'` - 滑入方向
- `width: number` - 抽屉宽度
- `bgColor: ResourceColor` - 背景色
- `onClose: () => void` - 关闭回调

### 3. 底部面板组件

**新建文件：** `entry/src/main/ets/components/BottomSheet.ets`

**功能：**
- 从底部滑入的面板
- 支持手势下拉关闭
- 半透明遮罩层
- 弹性动画

**Props：**
- `visible: boolean` - 是否显示
- `height: string | number` - 面板高度（如 '60%'）
- `bgColor: ResourceColor` - 背景色
- `onClose: () => void` - 关闭回调

### 4. 标签管理面板组件

**新建文件：** `entry/src/main/ets/components/TabManagerPanel.ets`

**功能：**
- 显示所有打开的标签
- 卡片式布局
- 显示文件信息（名称、语言、行数、修改状态）
- 支持切换和关闭标签

**Props：**
- `tabs: FileTab[]` - 标签列表
- `currentTabId: string` - 当前标签 ID
- `bgColor: ResourceColor` - 背景色
- `textColor: ResourceColor` - 文字颜色
- `onTabClick: (tabId: string) => void` - 点击标签回调
- `onTabClose: (tabId: string) => void` - 关闭标签回调
- `onNewTab: () => void` - 新建标签回调

### 5. 移动端菜单组件

**新建文件：** `entry/src/main/ets/components/MobileMenu.ets`

**功能：**
- 显示分组的功能菜单
- 图标 + 文字布局
- 点击执行操作

**Props：**
- `bgColor: ResourceColor` - 背景色
- `textColor: ResourceColor` - 文字颜色
- `onMenuClick: (action: string) => void` - 菜单点击回调

### 6. CodeEditor 页面适配

**修改文件：** `entry/src/main/ets/pages/CodeEditor.ets`

**修改内容：**

#### 6.1 添加移动端状态
```typescript
@State isMobileMode: boolean = false;
@State showLeftDrawer: boolean = false;
@State showRightDrawer: boolean = false;
@State showTabManager: boolean = false;
```

#### 6.2 监听断点变化
```typescript
aboutToAppear() {
  // ...existing code...
  
  // 监听断点变化
  this.breakpointService.onChange((breakpoint: Breakpoint) => {
    this.currentBreakpoint = breakpoint;
    this.isMobileMode = this.breakpointService.isMobile();
  });
  
  // 初始化移动端模式
  this.isMobileMode = this.breakpointService.isMobile();
}
```

#### 6.3 构建移动端工具栏
```typescript
@Builder
buildMobileToolbar(): void {
  Row() {
    // 左侧：文件浏览器按钮
    IconButton({
      icon: '☰',
      text: '',
      btnSize: 44,
      onButtonClick: () => {
        this.showLeftDrawer = true;
      }
    })
    
    // 中间：文件名（可点击）
    Text(this.fileName + (this.isModified ? ' •' : ''))
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.currentTheme.colors.text)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .onClick(() => {
        this.showTabManager = true;
      })
    
    // 右侧：功能菜单按钮
    IconButton({
      icon: '⋮',
      text: '',
      btnSize: 44,
      onButtonClick: () => {
        this.showRightDrawer = true;
      }
    })
  }
  .width('100%')
  .height(56)
  .padding({ left: 8, right: 8 })
  .backgroundColor(this.currentTheme.colors.surface)
}
```

#### 6.4 构建移动端布局
```typescript
build() {
  Stack() {
    // 主内容
    Column() {
      // 状态栏占位
      Row().height(this.topRectHeight / 3)
      
      // 工具栏（根据模式切换）
      if (this.isMobileMode) {
        this.buildMobileToolbar()
      } else {
        this.buildToolbar()
      }
      
      // 编辑区域
      if (this.isMobileMode) {
        // 移动端：全屏编辑器
        this.buildEditor()
      } else {
        // 桌面端：带侧边栏
        Row() {
          if (this.showFileBrowser) {
            FileBrowser({ /* ... */ })
          }
          Column() {
            TabBar({ /* ... */ })
            this.buildEditor()
          }
        }
      }
    }
    
    // 左侧抽屉（文件浏览器）
    if (this.isMobileMode) {
      DrawerPanel({
        visible: this.showLeftDrawer,
        position: 'left',
        width: this.breakpointService.getDrawerWidth(),
        bgColor: this.currentTheme.colors.surface,
        onClose: () => {
          this.showLeftDrawer = false;
        }
      }) {
        FileBrowser({ /* ... */ })
      }
    }
    
    // 右侧抽屉（功能菜单）
    if (this.isMobileMode) {
      DrawerPanel({
        visible: this.showRightDrawer,
        position: 'right',
        width: this.breakpointService.getDrawerWidth(),
        bgColor: this.currentTheme.colors.surface,
        onClose: () => {
          this.showRightDrawer = false;
        }
      }) {
        MobileMenu({
          bgColor: this.currentTheme.colors.surface,
          textColor: this.currentTheme.colors.text,
          onMenuClick: (action: string) => {
            this.handleMenuAction(action);
            this.showRightDrawer = false;
          }
        })
      }
    }
    
    // 底部面板（标签管理）
    if (this.isMobileMode) {
      BottomSheet({
        visible: this.showTabManager,
        height: '60%',
        bgColor: this.currentTheme.colors.surface,
        onClose: () => {
          this.showTabManager = false;
        }
      }) {
        TabManagerPanel({
          tabs: this.tabs,
          currentTabId: this.currentTabId,
          bgColor: this.currentTheme.colors.surface,
          textColor: this.currentTheme.colors.text,
          onTabClick: (tabId: string) => {
            this.switchToTab(tabId);
            this.showTabManager = false;
          },
          onTabClose: (tabId: string) => {
            this.closeTab(tabId);
          },
          onNewTab: () => {
            this.createNewTab();
            this.showTabManager = false;
          }
        })
      }
    }
  }
}
```

#### 6.5 处理菜单操作
```typescript
private handleMenuAction(action: string) {
  switch (action) {
    case 'template':
      this.openTemplateDialog();
      break;
    case 'format':
      this.formatCode();
      break;
    case 'search':
      this.showSearchBar = true;
      break;
    case 'preview':
      this.isPreviewMode = !this.isPreviewMode;
      break;
    case 'theme':
      this.cycleTheme();
      break;
    case 'save':
      this.saveFile();
      break;
    case 'export':
      this.saveFileAs();
      break;
    case 'open':
      this.openFile();
      break;
    case 'import':
      this.importFileToWorkspace();
      break;
    case 'settings':
      this.openSettings();
      break;
  }
}
```

### 7. 手势支持

**修改文件：** `entry/src/main/ets/components/DrawerPanel.ets`

**添加手势识别：**
```typescript
// 边缘滑动手势
.gesture(
  PanGesture({ direction: PanDirection.Horizontal })
    .onActionStart((event: GestureEvent) => {
      // 检测边缘滑动
      if (this.position === 'left' && event.offsetX > 50) {
        this.visible = true;
      } else if (this.position === 'right' && event.offsetX < -50) {
        this.visible = true;
      }
    })
    .onActionUpdate((event: GestureEvent) => {
      // 跟随手指移动
      this.dragOffset = event.offsetX;
    })
    .onActionEnd((event: GestureEvent) => {
      // 判断是否关闭
      if (Math.abs(event.offsetX) > this.width / 2) {
        this.visible = false;
      }
      this.dragOffset = 0;
    })
)
```

## 国际化字符串

**文件：** `entry/src/main/resources/base/element/string.json`

**添加字符串：**
```json
{
  "string": [
    {
      "name": "menu_edit_tools",
      "value": "编辑工具"
    },
    {
      "name": "menu_file_operations",
      "value": "文件操作"
    },
    {
      "name": "menu_app_settings",
      "value": "应用设置"
    },
    {
      "name": "tab_manager_title",
      "value": "打开的标签"
    },
    {
      "name": "btn_new_tab",
      "value": "新建标签"
    },
    {
      "name": "text_lines",
      "value": "行"
    },
    {
      "name": "text_modified",
      "value": "已修改"
    }
  ]
}
```

## 实现优先级

### P0 - 必须实现（第一阶段）
1. 响应式断点检测和移动端模式切换
2. 移动端简化工具栏（三个按钮）
3. DrawerPanel 通用抽屉组件
4. 左侧文件浏览器抽屉
5. 右侧功能菜单抽屉
6. 编辑区域全屏显示

### P1 - 重要功能（第二阶段）
7. BottomSheet 底部面板组件
8. TabManagerPanel 标签管理面板
9. 搜索栏移动端优化
10. 基础手势支持（边缘滑动）

### P2 - 优化功能（第三阶段）
11. 手势拖拽跟随
12. 双指缩放字体
13. 动画细节优化
14. 性能优化

## 测试计划

### 单元测试
- [ ] BreakpointService.isMobile() 正确判断移动端
- [ ] BreakpointService.getDrawerWidth() 返回正确宽度
- [ ] DrawerPanel 组件正确渲染和关闭
- [ ] BottomSheet 组件正确渲染和关闭

### 集成测试
- [ ] 点击按钮打开/关闭抽屉
- [ ] 点击遮罩层关闭抽屉
- [ ] 点击文件名打开标签管理面板
- [ ] 切换标签后编辑器内容正确更新
- [ ] 旋转屏幕后布局正确切换

### 用户体验测试
- [ ] 在小屏手机（< 360dp）上测试
- [ ] 在中屏手机（360-480dp）上测试
- [ ] 在大屏设备（> 480dp）上测试
- [ ] 测试所有手势操作
- [ ] 测试动画流畅度

## 设计决策记录

### 决策 1：标签管理位置
**问题：** 标签管理用底部面板还是放在文件浏览器顶部？  
**决策：** 使用底部面板  
**理由：**
- 底部面板更符合移动端习惯（如微信、支付宝的底部弹窗）
- 独立于文件浏览器，功能更清晰
- 可以显示更多标签信息（卡片式布局）
- 不占用文件浏览器空间

### 决策 2：搜索栏位置
**问题：** 搜索栏展开在顶部还是用底部面板？  
**决策：** 展开在顶部导航栏下方  
**理由：**
- 搜索结果在编辑区域，顶部展开更接近内容
- 底部面板更适合列表选择，不适合输入操作
- 顶部展开不遮挡编辑区域
- 符合桌面端习惯，保持一致性

### 决策 3：预览切换位置
**问题：** 预览/编辑切换放在右侧菜单还是顶部快捷按钮？  
**决策：** 放在右侧菜单  
**理由：**
- 顶部只保留三个核心按钮，避免拥挤
- 预览切换不是高频操作
- 右侧菜单有足够空间展示所有功能
- 保持顶部导航栏简洁

### 决策 4：文件操作分布
**问题：** 是否需要专门的"文件"菜单？  
**决策：** 不需要，分散在各处  
**理由：**
- 新建文件：在文件浏览器底部
- 打开/导入：在右侧菜单
- 保存/导出：在右侧菜单
- 功能分布更符合使用场景
- 避免多级菜单，减少点击次数

## 风险和挑战

### 风险 1：手势冲突
**描述：** 边缘滑动手势可能与系统手势冲突  
**缓解措施：**
- 设置滑动阈值（> 50dp）
- 提供按钮作为备选操作方式
- 在设置中允许禁用手势

### 风险 2：性能问题
**描述：** 抽屉动画可能在低端设备上卡顿  
**缓解措施：**
- 使用 HarmonyOS 原生动画
- 避免在动画期间进行复杂计算
- 使用 GPU 加速（translate3d）

### 风险 3：兼容性问题
**描述：** 不同 HarmonyOS 版本可能有差异  
**缓解措施：**
- 使用稳定的 API
- 添加版本检测和降级方案
- 充分测试不同设备

## 参考资料

- [HarmonyOS 响应式布局](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-layout-development-responsive-0000001454445606-V3)
- [HarmonyOS 手势处理](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-gesture-events-binding-0000001455502044-V3)
- [HarmonyOS 动画](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-animation-0000001450116690-V3)
- [Material Design - Navigation Drawer](https://m3.material.io/components/navigation-drawer/overview)
- [Material Design - Bottom Sheet](https://m3.material.io/components/bottom-sheets/overview)

## 更新日志

- 2024-12-22: 创建规范文档，定义用户故事和技术方案
