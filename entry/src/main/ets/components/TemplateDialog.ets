/**
 * 代码模板选择对话框
 */
import { CodeTemplate, CodeTemplateData } from '../models/CodeTemplateModel';

@CustomDialog
export struct TemplateDialog {
  controller: CustomDialogController;
  @State selectedCategory: string = 'JavaScript';
  @State templates: CodeTemplate[] = [];
  @Prop bgColor: ResourceColor = '#1E1E1E';
  @Prop textColor: ResourceColor = '#FFFFFF';
  @Prop primaryColor: ResourceColor = '#0A59F7';
  onConfirm?: (template: CodeTemplate) => void;
  
  aboutToAppear() {
    this.loadTemplates();
  }
  
  private loadTemplates() {
    this.templates = CodeTemplateData.getTemplatesByCategory(this.selectedCategory);
  }
  
  build() {
    Column() {
      // 标题
      Row() {
        Text($r('app.string.template_dialog_title'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textColor)
          .layoutWeight(1)
        
        Button({ type: ButtonType.Circle }) {
          Text('×')
            .fontSize(24)
            .fontColor(this.textColor)
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.controller.close();
        })
      }
      .width('100%')
      .padding({ left: 20, right: 12, top: 16, bottom: 12 })
      
      Divider().color('rgba(255, 255, 255, 0.1)')
      
      // 分类标签
      Scroll() {
        Row({ space: 8 }) {
          ForEach(CodeTemplateData.getCategories(), (category: string) => {
            Button(category)
              .fontSize(14)
              .fontColor(this.selectedCategory === category ? Color.White : this.textColor)
              .backgroundColor(this.selectedCategory === category ? this.primaryColor : 'rgba(255, 255, 255, 0.1)')
              .borderRadius(16)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .onClick(() => {
                this.selectedCategory = category;
                this.loadTemplates();
              })
          }, (category: string) => category)
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      
      Divider().color('rgba(255, 255, 255, 0.1)')
      
      // 模板列表
      List({ space: 8 }) {
        ForEach(this.templates, (template: CodeTemplate) => {
          ListItem() {
            Column() {
              Row() {
                Column({ space: 4 }) {
                  Text(template.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.textColor)
                  
                  Text(template.description)
                    .fontSize(13)
                    .fontColor(this.textColor)
                    .opacity(0.6)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                
                Text('>')
                  .fontSize(18)
                  .fontColor(this.textColor)
                  .opacity(0.4)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('rgba(255, 255, 255, 0.05)')
              .borderRadius(12)
              .onClick(() => {
                if (this.onConfirm) {
                  this.onConfirm(template);
                }
                this.controller.close();
              })
            }
          }
        }, (template: CodeTemplate) => template.id)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      
      // 底部按钮
      Row({ space: 12 }) {
        Button($r('app.string.template_dialog_cancel'))
          .fontSize(16)
          .fontColor(this.textColor)
          .backgroundColor('rgba(255, 255, 255, 0.1)')
          .borderRadius(12)
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
    }
    .width('90%')
    .constraintSize({ maxHeight: '80%' })
    .backgroundColor(this.bgColor)
    .borderRadius(16)
  }
}
