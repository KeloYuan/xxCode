/**
 * 元代码 用户协议页面
 * 首次启动时显示，同意后不再显示
 */
import { router, window, curves } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Agreement {
  // 页面转场动画 - 统一的滑动效果
  pageTransition() {
    PageTransitionEnter({ duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
  
  @State isAgreed: boolean = false;
  @State isLoading: boolean = true;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  
  private context: common.UIAbilityContext | null = null;
  private dataPreferences: preferences.Preferences | null = null;

  async aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    
    // 设置状态栏文字为深色（因为背景是浅色）
    this.setStatusBarStyle(false);
    
    try {
      // 获取首选项存储
      this.dataPreferences = await preferences.getPreferences(this.context, 'user_settings');
      // 检查是否已同意协议
      const agreed = await this.dataPreferences.get('agreement_accepted', false);
      
      if (agreed) {
        // 已同意，直接跳转到首页
        router.pushUrl({ url: 'pages/Index' }, router.RouterMode.Single);
        return;
      }
    } catch (err) {
      console.error('读取首选项失败:', JSON.stringify(err));
    }
    
    this.isLoading = false;
  }

  private async acceptAgreement() {
    try {
      if (this.dataPreferences) {
        await this.dataPreferences.put('agreement_accepted', true);
        await this.dataPreferences.flush();
      }
      // 跳转到首页（使用pushUrl触发转场动画）
      router.pushUrl({ url: 'pages/Index' }, router.RouterMode.Single);
    } catch (err) {
      console.error('保存首选项失败:', JSON.stringify(err));
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#667eea')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 协议内容
        this.buildContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .padding({ top: this.topRectHeight / 3, bottom: this.bottomRectHeight / 3 })
  }

  @Builder
  buildContent(): void {
    Column() {
      // 标题
      Column({ space: 8 }) {
        Text('📜')
          .fontSize(48)
        Text('用户协议与隐私政策')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .margin({ top: 40, bottom: 24 })

      // 协议内容滚动区
      Scroll() {
        Column() {
          Text(this.getAgreementText())
            .fontSize(14)
            .fontColor('#666666')
            .lineHeight(24)
            .padding(20)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ bottom: 20 })

      // 同意勾选
      Row() {
        Checkbox()
          .select(this.isAgreed)
          .selectedColor('#667eea')
          .onChange((value: boolean) => {
            this.isAgreed = value;
          })
        
        Text('我已阅读并同意以上协议')
          .fontSize(14)
          .fontColor('#333333')
          .margin({ left: 8 })
      }
      .margin({ bottom: 20 })

      // 同意按钮
      Button('同意并继续')
        .width('80%')
        .height(50)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.isAgreed ? '#667eea' : '#CCCCCC')
        .borderRadius(25)
        .enabled(this.isAgreed)
        .onClick(() => {
          this.acceptAgreement();
        })
      
      // 底部提示
      Text('点击"同意并继续"即表示您同意上述条款')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 12, bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 设置状态栏样式
   * @param isDark true=白色文字(深色背景), false=黑色文字(浅色背景)
   */
  private setStatusBarStyle(isDark: boolean) {
    try {
      if (!this.context) return;
      window.getLastWindow(this.context).then((win) => {
        win.setWindowSystemBarProperties({
          statusBarContentColor: isDark ? '#FFFFFF' : '#000000',
          navigationBarContentColor: isDark ? '#FFFFFF' : '#000000'
        });
      });
    } catch (e) {
      console.error('设置状态栏样式失败:', JSON.stringify(e));
    }
  }

  private getAgreementText(): string {
    return `元代码 用户协议与隐私政策

更新日期：2025年12月

欢迎使用元代码！在使用本应用之前，请您仔细阅读以下条款。

一、服务说明

元代码是一款运行在 HarmonyOS 系统上的代码编辑器应用，为用户提供代码编写、文件管理、预览与运行等功能。

二、用户权利与义务

1. 您有权免费使用本应用的功能。
2. 您应当合法使用本应用，不得利用本应用从事任何违法活动。
3. 您对使用本应用编写与运行的内容负全部责任。

三、隐私与数据处理

1. 本应用不会收集或存储您的任何个人数据。
2. 本应用默认在本地处理您的编辑内容与文件。
3. 当您使用 Python 运行功能时，应用会通过网络调用第三方 API 来执行运行请求；仅会传输运行所需的代码与参数，不会收集任何个人数据。
4. 本应用不会在未征得您同意的情况下上传项目文件或其他本地数据。
5. 本应用需要访问设备存储权限，仅用于读取和保存您的代码文件。

四、免责声明

1. 本应用按"现状"提供，不提供任何明示或暗示的保证。
2. 对于因使用本应用而导致的任何直接或间接损失，开发者不承担责任。
3. 本应用可能会不定期更新，届时可能会修改部分功能。

五、知识产权

1. 本应用的所有权利归开发者所有。
2. 您使用本应用编写的代码归您所有。

六、协议修改

开发者保留随时修改本协议的权利。修改后的协议将在应用内公布，继续使用本应用即表示您接受修改后的协议。

七、联系方式

如有任何问题或建议，欢迎通过应用内反馈功能联系我们。

感谢您选择元代码！`;
  }
}
