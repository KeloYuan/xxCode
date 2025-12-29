/**
 * 底部控制台面板
 * 用于显示代码运行结果和日志
 */
import { ThemeService, Theme } from '../services/ThemeService';

@Component
export struct ConsolePanel {
  @Prop visible: boolean = false;
  @Prop logs: string[] = [];
  @Prop panelHeight: number = 300;
  @Prop isExecuting: boolean = false; // 是否正在执行代码
  onClose: () => void = () => {};
  onClear: () => void = () => {};
  
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  private themeService: ThemeService = ThemeService.getInstance();
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  build() {
    if (this.visible) {
      Column() {
        // 顶部工具栏
        Row() {
          Text('控制台 / Console')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTheme.colors.text)
          
          Blank()
          
          // 清空按钮
          Button({ type: ButtonType.Normal }) {
            Text('🗑️ 清空')
              .fontSize(12)
              .fontColor(this.currentTheme.colors.textSecondary)
          }
          .backgroundColor(Color.Transparent)
          .height(28)
          .onClick(() => this.onClear())
          
          // 关闭按钮
          Button({ type: ButtonType.Normal }) {
            Text('✕')
              .fontSize(14)
              .fontColor(this.currentTheme.colors.textSecondary)
          }
          .backgroundColor(Color.Transparent)
          .width(28)
          .height(28)
          .onClick(() => this.onClose())
        }
        .width('100%')
        .height(36)
        .padding({ left: 12, right: 8 })
        .backgroundColor(this.currentTheme.colors.surface)
        .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })
        
        // 日志显示区
        Scroll(this.scroller) {
          Column({ space: 4 }) {
            // 执行中状态
            if (this.isExecuting) {
              Row({ space: 8 }) {
                LoadingProgress()
                  .width(18)
                  .height(18)
                  .color(this.currentTheme.colors.primary)
                Text('正在执行代码，请稍候...')
                  .fontSize(13)
                  .fontColor(this.currentTheme.colors.textSecondary)
              }
              .width('100%')
              .padding(16)
              .justifyContent(FlexAlign.Center)
            } else if (this.logs.length === 0) {
              Text('点击运行按钮执行代码...')
                .fontSize(13)
                .fontColor(this.currentTheme.colors.textSecondary)
                .margin({ top: 16 })
                .width('100%')
                .textAlign(TextAlign.Center)
                .opacity(0.6)
            } else {
              ForEach(this.logs, (log: string, index: number) => {
                Text(log)
                  .fontSize(13)
                  .fontFamily('monospace')
                  .fontColor(log.startsWith('[Error]') ? '#FF6B6B' : this.currentTheme.colors.text)
                  .width('100%')
                  .padding({ left: 12, right: 12, top: 2, bottom: 2 })
                  .copyOption(CopyOptions.LocalDevice)
              })
            }
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .width('100%')
        .align(Alignment.TopStart)
        .backgroundColor(this.currentTheme.editor.background)
      }
      .width('100%')
      .height(this.panelHeight)
      .backgroundColor(this.currentTheme.colors.background)
      .border({ width: { top: 1 }, color: this.currentTheme.colors.border })
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.1)', offsetY: -2 })
      .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 300 }))
    }
  }
}
