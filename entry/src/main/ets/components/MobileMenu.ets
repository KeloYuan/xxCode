/**
 * 移动端功能菜单组件 - 鸿蒙设计风格
 * 简洁设计、流畅动效、纯文字交互
 */
import { curves } from '@kit.ArkUI';

@Component
export struct MobileMenu {
  @Prop bgColor: ResourceColor = Color.White;
  @Prop textColor: ResourceColor = Color.Black;
  @Prop primaryColor: ResourceColor = '#0A59F7';
  onMenuClick?: (action: string) => void;

  @State private pressedItem: string = '';
  private springCurve: ICurve = curves.springMotion(0.6, 0.9);
  private readonly MICRO_DURATION: number = 150;
  private readonly STANDARD_DURATION: number = 250;

  build() {
    Column() {
      // 菜单标题
      Text('菜单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textColor)
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 16 })

      // 菜单列表
      Column() {
        this.buildMenuItem('运行代码', 'run')
        Divider().color(`${this.textColor}15`).strokeWidth(0.5).margin({ left: 20, right: 20 })
        this.buildMenuItem('代码模板', 'template')
        Divider().color(`${this.textColor}15`).strokeWidth(0.5).margin({ left: 20, right: 20 })
        this.buildMenuItem('格式化代码', 'format')
        Divider().color(`${this.textColor}15`).strokeWidth(0.5).margin({ left: 20, right: 20 })
        this.buildMenuItem('查找替换', 'search')
        Divider().color(`${this.textColor}15`).strokeWidth(0.5).margin({ left: 20, right: 20 })
        this.buildMenuItem('预览模式', 'preview')

        // 分组标题
        Text('文件')
          .fontSize(13)
          .fontColor(this.textColor)
          .opacity(0.5)
          .width('100%')
          .padding({ left: 20, top: 20, bottom: 8 })

        this.buildMenuItem('保存文件', 'save')
        Divider().color(`${this.textColor}15`).strokeWidth(0.5).margin({ left: 20, right: 20 })
        this.buildMenuItem('打开文件', 'open')
        Divider().color(`${this.textColor}15`).strokeWidth(0.5).margin({ left: 20, right: 20 })
        this.buildMenuItem('导入文件', 'import')
        Divider().color(`${this.textColor}15`).strokeWidth(0.5).margin({ left: 20, right: 20 })
        this.buildMenuItem('导出文件', 'export')

        // 分组标题
        Text('设置')
          .fontSize(13)
          .fontColor(this.textColor)
          .opacity(0.5)
          .width('100%')
          .padding({ left: 20, top: 20, bottom: 8 })

        this.buildMenuItem('设置', 'settings')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
  }

  @Builder
  buildMenuItem(label: string, action: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.textColor)
        .layoutWeight(1)
    }
    .width('100%')
    .height(52)
    .padding({ left: 20, right: 20 })
    .backgroundColor(this.pressedItem === action ? `${this.primaryColor}15` : Color.Transparent)
    .borderRadius(12)
    .scale({
      x: this.pressedItem === action ? 0.98 : 1,
      y: this.pressedItem === action ? 0.98 : 1
    })
    .animation({
      duration: this.MICRO_DURATION,
      curve: Curve.Sharp
    })
    .onClick(() => {
      if (this.onMenuClick) {
        this.onMenuClick(action);
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        animateTo({ duration: this.MICRO_DURATION, curve: Curve.Sharp }, () => {
          this.pressedItem = action;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        animateTo({ duration: this.MICRO_DURATION, curve: this.springCurve }, () => {
          this.pressedItem = '';
        });
      }
    })
  }
}
