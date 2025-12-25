/**
 * 图标按钮组件 - 鸿蒙设计风格
 * 纯文字按钮、流畅动效、圆润设计、层次感
 */
import { curves } from '@kit.ArkUI';

@Component
export struct IconButton {
  @Prop text: ResourceStr = ''; // 按钮文字（支持资源引用）
  @Prop isActive: boolean = false; // 是否激活状态
  @Prop bgColor: ResourceColor = '#00000000';
  @Prop activeColor: ResourceColor = '#0A59F7'; // 鸿蒙蓝
  @Prop textColor: ResourceColor = '#FFFFFF';
  @Prop btnSize: number = 40;
  @Prop fontSize: number = 15;
  @Prop isMobile: boolean = false; // 移动端按钮更大
  onButtonClick?: () => void;

  @State private isHover: boolean = false;
  @State private isPressed: boolean = false;
  private springCurve: ICurve = curves.springMotion(0.6, 0.9);

  // 鸿蒙动效时长
  private readonly MICRO_DURATION: number = 150; // 微交互
  private readonly STANDARD_DURATION: number = 250; // 标准

  build() {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      Text(this.text)
        .fontSize(this.isMobile ? this.fontSize - 1 : this.fontSize - 2)
        .fontColor(this.isActive ? Color.White : this.textColor)
        .fontWeight(FontWeight.Medium)
    }
    .height(this.isMobile ? 44 : this.btnSize)
    .width('auto')
    .padding({ left: 14, right: 14 })
    .backgroundColor(this.isActive ? this.activeColor : this.bgColor)
    .borderRadius(this.isMobile ? 12 : this.btnSize / 2)
    .scale({
      x: this.isHover ? 1.03 : (this.isPressed ? 0.96 : 1),
      y: this.isHover ? 1.03 : (this.isPressed ? 0.96 : 1)
    })
    .shadow(this.isActive ? {
      radius: 12,
      color: `${this.activeColor}40`,
      offsetX: 0,
      offsetY: 4
    } : (this.isHover ? {
      radius: 8,
      color: 'rgba(0, 0, 0, 0.12)',
      offsetX: 0,
      offsetY: 3
    } : undefined))
    .animation({
      duration: this.STANDARD_DURATION,
      curve: this.springCurve
    })
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
    .onHover((isHover: boolean) => {
      animateTo({
        duration: this.STANDARD_DURATION,
        curve: this.springCurve
      }, () => {
        this.isHover = isHover;
      });
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        animateTo({ duration: this.MICRO_DURATION, curve: Curve.Sharp }, () => {
          this.isPressed = true;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        animateTo({ duration: this.MICRO_DURATION + 50, curve: this.springCurve }, () => {
          this.isPressed = false;
        });
      }
    })
  }
}
