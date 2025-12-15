/**
 * 设置页面
 * 包含字体大小调整、版本信息、反馈入口
 */
import { router } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { ThemeService, Theme } from '../services/ThemeService';

@Entry
@Component
struct Settings {
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  @State fontSize: number = 14;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  
  private context: common.UIAbilityContext | null = null;
  private themeService: ThemeService = ThemeService.getInstance();
  
  private readonly appVersion: string = '1.0.0';
  private readonly buildNumber: string = '1';
  
  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
    this.loadFontSize();
  }
  
  private async loadFontSize() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'settings' });
      this.fontSize = store.getSync('fontSize', 14) as number;
    } catch (e) {
      console.error('加载字体大小失败:', JSON.stringify(e));
    }
  }
  
  private async saveFontSize(size: number) {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'settings' });
      store.putSync('fontSize', size);
      store.flush();
      this.fontSize = size;
    } catch (e) {
      console.error('保存字体大小失败:', JSON.stringify(e));
    }
  }
  
  private openFeedback() {
    try {
      if (!this.context) return;
      const want: Want = {
        action: 'ohos.want.action.sendToData',
        uri: 'mailto:feedback@example.com?subject=元代码反馈&body=请描述您的问题或建议：'
      };
      this.context.startAbility(want).catch(() => {
        this.showFeedbackDialog();
      });
    } catch (e) {
      this.showFeedbackDialog();
    }
  }
  
  private showFeedbackDialog() {
    AlertDialog.show({
      title: '反馈方式',
      message: '请发送邮件至：1271791804@qq.com',
      confirm: { value: '确定', action: () => {} }
    });
  }
  
  private goBack() {
    router.back();
  }

  build() {
    Column() {
      Row().width('100%').height(px2vp(this.topRectHeight)).backgroundColor(this.currentTheme.colors.surface)
      
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('← 返回').fontSize(15).fontColor(this.currentTheme.colors.primary)
        }
        .height(36).padding({ left: 12, right: 12 }).backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
        Text('设置').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.currentTheme.colors.text)
          .layoutWeight(1).textAlign(TextAlign.Center)
        
        Row().width(60)
      }
      .width('100%').height(56).padding({ left: 8, right: 8 })
      .backgroundColor(this.currentTheme.colors.surface)
      .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })
      
      // 设置内容
      Scroll() {
        Column({ space: 16 }) {
          // 编辑器设置
          this.buildEditorSection()
          // 关于
          this.buildAboutSection()
          // 反馈
          this.buildFeedbackSection()
        }
        .width('100%').padding(16)
      }
      .layoutWeight(1).width('100%').backgroundColor(this.currentTheme.colors.background)
      
      Row().width('100%').height(px2vp(this.bottomRectHeight)).backgroundColor(this.currentTheme.colors.background)
    }
    .width('100%').height('100%').backgroundColor(this.currentTheme.colors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  
  @Builder
  buildEditorSection() {
    Column() {
      Text('编辑器').fontSize(13).fontColor(this.currentTheme.colors.textSecondary)
        .width('100%').padding({ left: 4, bottom: 8 })
      
      Column() {
        Row() {
          Text('字体大小').fontSize(16).fontColor(this.currentTheme.colors.text)
          Blank()
          Text(`${this.fontSize}px`).fontSize(14).fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%').padding({ left: 12, right: 12, top: 12, bottom: 8 })
        
        Row({ space: 12 }) {
          Text('A').fontSize(12).fontColor(this.currentTheme.colors.textSecondary)
          Slider({ value: this.fontSize, min: 10, max: 24, step: 1 })
            .layoutWeight(1)
            .blockColor(this.currentTheme.colors.primary)
            .trackColor(this.currentTheme.colors.border)
            .selectedColor(this.currentTheme.colors.primary)
            .onChange((value: number) => { this.saveFontSize(value); })
          Text('A').fontSize(20).fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%').padding({ left: 12, right: 12, bottom: 12 })
        
        Row() {
          Text('预览：Hello World 你好世界').fontSize(this.fontSize)
            .fontColor(this.currentTheme.colors.text).fontFamily('monospace')
        }
        .width('100%').padding(12).backgroundColor(this.currentTheme.editor.background)
        .borderRadius(8).margin({ left: 12, right: 12, bottom: 12 })
      }
      .width('100%').backgroundColor(this.currentTheme.colors.surface).borderRadius(12).padding(4)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  buildAboutSection() {
    Column() {
      Text('关于').fontSize(13).fontColor(this.currentTheme.colors.textSecondary)
        .width('100%').padding({ left: 4, bottom: 8 })
      
      Column() {
        this.buildItem('版本', `${this.appVersion} (${this.buildNumber})`, false)
        Divider().color(this.currentTheme.colors.border).margin({ left: 12, right: 12 })
        this.buildItem('应用名称', '元代码', false)
        Divider().color(this.currentTheme.colors.border).margin({ left: 12, right: 12 })
        this.buildItem('开发者', '小元Niki', false)
        
      }
      .width('100%').backgroundColor(this.currentTheme.colors.surface).borderRadius(12).padding(4)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  buildFeedbackSection() {
    Column() {
      Text('帮助与反馈').fontSize(13).fontColor(this.currentTheme.colors.textSecondary)
        .width('100%').padding({ left: 4, bottom: 8 })
      
      Column() {
        Row() {
          Text('问题反馈').fontSize(16).fontColor(this.currentTheme.colors.text)
          Blank()
          Text('发送邮件 >').fontSize(14).fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%').height(52).padding({ left: 12, right: 12 })
        .onClick(() => { this.openFeedback(); })
        
        Divider().color(this.currentTheme.colors.border).margin({ left: 12, right: 12 })
        
        Row() {
          Text('给个好评').fontSize(16).fontColor(this.currentTheme.colors.text)
          Blank()
          Text('前往应用市场 >').fontSize(14).fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%').height(52).padding({ left: 12, right: 12 })
        .onClick(() => {
          AlertDialog.show({
            title: '感谢支持',
            message: '请在华为应用市场搜索"元代码"进行评价',
            confirm: { value: '好的', action: () => {} }
          });
        })
      }
      .width('100%').backgroundColor(this.currentTheme.colors.surface).borderRadius(12).padding(4)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  buildItem(label: string, value: string, showArrow: boolean) {
    Row() {
      Text(label).fontSize(16).fontColor(this.currentTheme.colors.text)
      Blank()
      Text(value + (showArrow ? ' >' : '')).fontSize(14).fontColor(this.currentTheme.colors.textSecondary)
    }
    .width('100%').height(52).padding({ left: 12, right: 12 })
  }
}
