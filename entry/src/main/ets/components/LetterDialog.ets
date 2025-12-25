/**
 * 致用户的一封信弹窗
 */
import { curves } from '@kit.ArkUI';

@CustomDialog
export struct LetterDialog {
  controller: CustomDialogController;
  @Prop bgColor: ResourceColor = '#1E1E1E';
  @Prop textColor: ResourceColor = '#FFFFFF';
  @Prop accentColor: ResourceColor = '#0A59F7';
  onConfirm?: () => void;

  @State private isVisible: boolean = false;
  private springCurve: ICurve = curves.springMotion(0.6, 0.8);

  aboutToAppear() {
    this.getUIContext().animateTo({
      duration: 350,
      curve: this.springCurve
    }, () => {
      this.isVisible = true;
    });
  }

  build() {
    Column({ space: 12 }) {
      Text('致用户的一封信')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2F2623')
        .width('100%')
        .textAlign(TextAlign.Center)

      Row()
        .width('100%')
        .height(1)
        .backgroundColor('rgba(0, 0, 0, 0.15)')

      Scroll() {
        Column({ space: 10 }) {
          Text('亲爱的用户：')
            .fontSize(16)
            .fontColor('#2F2623')
            .fontFamily('STKaiti, KaiTi, FangSong, serif')

          Text([
            '    您好，非常感谢您的下载。',
            '    我是一名大学学生，这是我的第一个鸿蒙应用。',
            '    高中时期，听闻 Mate60 系列发布的我沸腾不已，自那时，我便觉得，鸿蒙是新的起点，是新的天地，这与我常用名“元”有着近似的意思。',
            '    我很看好鸿蒙的未来，鸿蒙的微内核在我看来，更是面向未来的神来之笔，因此，我很早便有了成为一名鸿蒙开发者的想法，但受制于环境与资源，我迟迟无法实现。',
            '    如今，我的第一款 APP 已经送到了您手上。我会持续不断地学习、更新，这款 APP 也会不断壮大，并且会永久免费。',
            '    日后，这个 APP 会开源，我会吸引更多社区开发者来共同维护此 APP。',
            '    如果您看好这个 APP，或觉得对你有所帮助，请您点赞支持！谢谢您！'
          ].join('\n'))
            .fontSize(15)
            .fontColor('#2F2623')
            .lineHeight(24)
            .fontFamily('STKaiti, KaiTi, FangSong, serif')

          Row() {
            Column() {
              Text('小元 Niki')
                .fontSize(15)
                .fontColor('#2F2623')
                .fontFamily('STKaiti, KaiTi, FangSong, serif')
              Text('敬上')
                .fontSize(13)
                .fontColor('#2F2623')
                .opacity(0.8)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .margin({ top: 6 })
        }
        .opacity(this.isVisible ? 1 : 0)
        .animation({
          duration: 450,
          curve: Curve.EaseInOut
        })
      }
      .height(300)
      .scrollBar(BarState.Auto)

      Button('我知道了')
        .height(40)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.accentColor)
        .fontColor(Color.White)
        .borderRadius(10)
        .onClick(() => {
          if (this.onConfirm) {
            this.onConfirm();
          }
          this.controller.close();
        })
    }
    .width(330)
    .height(440)
    .padding(20)
    .backgroundColor('#F6F0E7')
    .linearGradient({
      angle: 135,
      colors: [
        ['#F8F2EA', 0.0],
        ['#F1E6D6', 0.55],
        ['#FBF6EE', 1.0]
      ]
    })
    .borderRadius(18)
    .border({ width: 1, color: 'rgba(0, 0, 0, 0.08)' })
    .shadow({
      radius: 18,
      color: 'rgba(0, 0, 0, 0.18)',
      offsetX: 0,
      offsetY: 6
    })
    .scale({ x: this.isVisible ? 1 : 0.92, y: this.isVisible ? 1 : 0.92 })
    .opacity(this.isVisible ? 1 : 0)
    .animation({
      duration: 350,
      curve: this.springCurve
    })
  }
}
