/**
 * 抽屉面板组件
 * 简洁设计，确保点击事件正常工作
 */

@Component
export struct DrawerPanel {
  @Prop drawerPosition: 'left' | 'right' = 'left';
  @Prop visible: boolean = false;
  @Prop bgColor: ResourceColor = Color.White;
  @Prop drawerWidth: number = 280;
  @BuilderParam content: () => void;
  onClose: () => void = () => {};

  build() {
    if (this.visible) {
      Stack({ alignContent: this.drawerPosition === 'left' ? Alignment.Start : Alignment.End }) {
        // 遮罩层 - 铺满整个屏幕
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.45)')
          .hitTestBehavior(HitTestMode.Transparent)
          .onClick(() => {
            console.info('Mask clicked, close drawer');
            this.onClose();
          })
          .transition(TransitionEffect.OPACITY.animation({ duration: 180, curve: Curve.EaseInOut }))
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
          .hitTestBehavior(HitTestMode.Block)
          .transition(
            TransitionEffect.OPACITY.animation({ duration: 220, curve: Curve.EaseOut })
              .combine(TransitionEffect.translate({ x: -48 }))
          )
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
          .hitTestBehavior(HitTestMode.Block)
          .transition(
            TransitionEffect.OPACITY.animation({ duration: 220, curve: Curve.EaseOut })
              .combine(TransitionEffect.translate({ x: 48 }))
          )
          .zIndex(1)
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
