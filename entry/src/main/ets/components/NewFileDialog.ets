/**
 * 新建文件对话框组件
 */
import { curves } from '@kit.ArkUI';

@CustomDialog
export struct NewFileDialog {
  controller: CustomDialogController;
  @State fileName: string = '';
  @Prop bgColor: ResourceColor = '#2D2D30';
  @Prop textColor: ResourceColor = '#FFFFFF';
  @Prop primaryColor: ResourceColor = '#667eea';
  @Prop titleText: string = '新建文件';
  @Prop confirmText: string = '创建';
  @Prop initialName: string = '';
  @Prop placeholderText: string = '例如: test.js';
  onConfirm?: (fileName: string) => void;
  
  private springCurve: ICurve = curves.springMotion(0.6, 0.8);

  aboutToAppear() {
    this.fileName = this.initialName;
  }

  build() {
    Column({ space: 16 }) {
      // 标题
      Text(this.titleText)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textColor)
        .width('100%')
      
      // 输入框
      Column({ space: 8 }) {
        Text('文件名')
          .fontSize(14)
          .fontColor(this.textColor)
          .opacity(0.7)
          .width('100%')
        
        TextInput({ placeholder: this.placeholderText, text: this.fileName })
          .width('100%')
          .height(40)
          .fontSize(14)
          .backgroundColor('#1E1E1E')
          .fontColor(this.textColor)
          .placeholderColor(this.textColor)
          .onChange((value: string) => {
            this.fileName = value;
          })
          .onSubmit(() => {
            this.handleConfirm();
          })
      }
      .alignItems(HorizontalAlign.Start)
      
      // 按钮组
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#3E3E42')
          .fontColor(this.textColor)
          .stateEffect(true)
          .onClick(() => {
            this.safeClose();
          })
        
        Button(this.confirmText)
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor(this.primaryColor)
          .fontColor(Color.White)
          .stateEffect(true)
          .enabled(this.fileName.trim().length > 0)
          .opacity(this.fileName.trim().length > 0 ? 1.0 : 0.5)
          .onClick(() => {
            this.handleConfirm();
          })
      }
      .width('100%')
    }
    .width(360)
    .padding(20)
    .backgroundColor(this.bgColor)
    .borderRadius(12)
  }

  private handleConfirm() {
    const trimmedName = this.fileName.trim();
    if (trimmedName.length > 0) {
      if (this.onConfirm) {
        this.onConfirm(trimmedName);
      }
      this.safeClose();
    }
  }

  private safeClose() {
    try {
      this.controller.close();
    } catch (e) {
      console.error('dialog close error:', JSON.stringify(e));
    }
  }
}
