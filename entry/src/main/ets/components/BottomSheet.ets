/**
 * 底部面板组件
 * 简洁设计
 */

@Component
export struct BottomSheet {
  @Prop visible: boolean = false;
  @Prop sheetHeight: string | number = '50%';
  @Prop bgColor: ResourceColor = Color.White;
  @BuilderParam content: () => void;
  onClose: () => void = () => {};

  build() {
    if (this.visible) {
      Stack({ alignContent: Alignment.Bottom }) {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .hitTestBehavior(HitTestMode.Block)
          .onClick(() => {
            console.info('BottomSheet mask clicked, close');
            this.onClose();
          })
          .zIndex(0)

        // 底部面板内容
        Column() {
          if (this.content) {
            this.content();
          }
        }
        .width('100%')
        .height(this.sheetHeight)
        .backgroundColor(this.bgColor)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .zIndex(1)
      }
      .width('100%')
      .height('100%')
    }
  }
}
