/**
 * 抽屉面板组件
 * 简洁设计，确保点击事件正常工作
 */

@Component
export struct DrawerPanel {
  @Prop drawerPosition: 'left' | 'right' = 'left';
  @Prop @Watch('onVisibleChange') visible: boolean = false;
  @Prop bgColor: ResourceColor = Color.White;
  @Prop drawerWidth: number = 280;
  @BuilderParam content: () => void;
  onClose: () => void = () => {};

  @State private isRendered: boolean = false;
  @State private maskOpacity: number = 0;
  @State private drawerOpacity: number = 0;
  @State private drawerTranslateX: number = 0;

  aboutToAppear() {
    if (this.visible) {
      this.openDrawer();
    }
  }

  private onVisibleChange(): void {
    if (this.visible) {
      this.openDrawer();
    } else {
      this.closeDrawer();
    }
  }

  private getHiddenOffset(): number {
    return this.drawerPosition === 'left' ? -48 : 48;
  }

  private openDrawer(): void {
    this.isRendered = true;
    this.maskOpacity = 0;
    this.drawerOpacity = 0;
    this.drawerTranslateX = this.getHiddenOffset();
    animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.maskOpacity = 1;
      this.drawerOpacity = 1;
      this.drawerTranslateX = 0;
    });
  }

  private closeDrawer(): void {
    animateTo({ duration: 180, curve: Curve.EaseInOut }, () => {
      this.maskOpacity = 0;
      this.drawerOpacity = 0;
      this.drawerTranslateX = this.getHiddenOffset();
    });
    setTimeout(() => {
      this.isRendered = false;
    }, 200);
  }

  build() {
    if (this.isRendered) {
      Stack({ alignContent: this.drawerPosition === 'left' ? Alignment.Start : Alignment.End }) {
        // 遮罩层 - 铺满整个屏幕
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.45)')
          .hitTestBehavior(HitTestMode.Block)
          .opacity(this.maskOpacity)
          .onClick(() => {
            console.info('Mask clicked, close drawer');
            this.onClose();
          })
          .zIndex(0)

        // 抽屉内容 - 不覆盖遮罩区域
        if (this.drawerPosition === 'left') {
          Column() {
            if (this.content) {
              this.content();
            }
          }
          .width(this.drawerWidth)
          .height('100%')
          .backgroundColor(this.bgColor)
          .borderRadius({ topRight: 16, bottomRight: 16 })
          .shadow({
            radius: 24,
            color: 'rgba(0, 0, 0, 0.18)',
            offsetX: 6,
            offsetY: 0
          })
          .opacity(this.drawerOpacity)
          .translate({ x: this.drawerTranslateX })
          .zIndex(1)
        } else {
          Column() {
            if (this.content) {
              this.content();
            }
          }
          .width(this.drawerWidth)
          .height('100%')
          .backgroundColor(this.bgColor)
          .borderRadius({ topLeft: 16, bottomLeft: 16 })
          .shadow({
            radius: 24,
            color: 'rgba(0, 0, 0, 0.18)',
            offsetX: -6,
            offsetY: 0
          })
          .opacity(this.drawerOpacity)
          .translate({ x: this.drawerTranslateX })
          .zIndex(1)
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
