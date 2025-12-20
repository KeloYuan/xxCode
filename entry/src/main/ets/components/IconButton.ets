/**
 * 图标按钮组件
 * 参考 HarmonyOS Design 规范设计
 */
import { curves } from '@kit.ArkUI';

@Component
export struct IconButton {
  @Prop icon: string; // 文字图标
  @Prop text: string = ''; // 按钮文字
  @Prop isActive: boolean = false; // 是否激活状态
  @Prop bgColor: ResourceColor = '#00000000';
  @Prop activeColor: ResourceColor = '#667eea';
  @Prop textColor: ResourceColor = '#FFFFFF';
  @Prop btnSize: number = 36;
  @Prop fontSize: number = 14;
  onButtonClick?: () => void;
  
  @State private isHover: boolean = false;
  @State private isPressed: boolean = false;
  private springCurve: ICurve = curves.springMotion(0.6, 0.8);

  build() {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 4 }) {
        if (this.icon) {
          Text(this.icon)
            .fontSize(this.fontSize + 2)
            .fontColor(this.isActive ? Color.White : this.textColor)
        }
        if (this.text) {
          Text(this.text)
            .fontSize(this.fontSize)
            .fontColor(this.isActive ? Color.White : this.textColor)
        }
      }
      .justifyContent(FlexAlign.Center)
    }
    .height(this.btnSize)
    .padding({ left: this.text ? 12 : 8, right: this.text ? 12 : 8 })
    .backgroundColor(this.isActive ? this.activeColor : this.bgColor)
    .borderRadius(this.btnSize / 2)
    .scale({ 
      x: this.isHover ? 1.05 : (this.isPressed ? 0.95 : 1), 
      y: this.isHover ? 1.05 : (this.isPressed ? 0.95 : 1) 
    })
    .shadow(this.isActive ? {
      radius: 8,
      color: this.activeColor,
      offsetX: 0,
      offsetY: 2
    } : undefined)
    .animation({ 
      duration: 200, 
      curve: this.springCurve 
    })
    .stateEffect(false)
    .onHover((isHover: boolean) => {
      animateTo({ 
        duration: 200, 
        curve: this.springCurve 
      }, () => {
        this.isHover = isHover;
      });
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        animateTo({ duration: 100 }, () => {
          this.isPressed = true;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        animateTo({ duration: 100 }, () => {
          this.isPressed = false;
        });
      }
    })
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
  }
}
