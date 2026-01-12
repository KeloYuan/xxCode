/**
 * 元代码 用户协议页面
 * 首次启动时显示，同意后不再显示 - 液态玻璃设计
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
    Stack() {
      // 渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 145,
          colors: [
            ['#e0e7ff', 0.0],
            ['#f3e8ff', 0.5],
            ['#fce7f3', 1.0]
          ]
        })

      // 装饰性光晕
      Circle()
        .width(300)
        .height(300)
        .fill('rgba(99, 102, 241, 0.08)')
        .position({ x: '80%', y: '10%' })
        .blur(80)

      Circle()
        .width(250)
        .height(250)
        .fill('rgba(236, 72, 153, 0.06)')
        .position({ x: '10%', y: '70%' })
        .blur(60)

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
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildContent(): void {
    Scroll() {
      Column() {
        // 液态玻璃卡片容器
        Column() {
          // 标题区
          Column({ space: 12 }) {
            Stack() {
              // 图标背景光晕
              Circle()
                .width(90)
                .height(90)
                .fill('rgba(99, 102, 241, 0.12)')
                .blur(20)

              Text('📜')
                .fontSize(42)
            }

            Text('用户协议与隐私政策')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a2e')

            Text('请仔细阅读以下条款')
              .fontSize(13)
              .fontColor('rgba(26, 26, 46, 0.6)')
          }
          .margin({ top: 20, bottom: 24 })
          .alignItems(HorizontalAlign.Center)

          // 协议内容区 - 液态玻璃卡片
          Column() {
            Scroll() {
              Text(this.getAgreementText())
                .fontSize(14)
                .fontColor('#334155')
                .lineHeight(26)
                .padding(20)
            }
            .width('100%')
            .layoutWeight(1)
            .scrollBar(BarState.Auto)
          }
          .width('100%')
          .height(320)
          .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
          .backgroundColor('rgba(255, 255, 255, 0.65)')
          .backdropBlur(20)
          .borderRadius(20)
          .border({
            width: 1,
            color: 'rgba(255, 255, 255, 0.8)'
          })
          .shadow({
            radius: 24,
            color: 'rgba(99, 102, 241, 0.15)',
            offsetX: 0,
            offsetY: 8
          })
          .margin({ bottom: 20 })

          // 同意勾选区 - 液态玻璃
          Row({ space: 12 }) {
            Stack() {
              Column()
                .width(44)
                .height(44)
                .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
                .backgroundColor('rgba(255, 255, 255, 0.5)')
                .backdropBlur(15)
                .borderRadius(12)
                .border({
                  width: 1,
                  color: 'rgba(255, 255, 255, 0.6)'
                })

              Checkbox()
                .width(24)
                .height(24)
                .select(this.isAgreed)
                .selectedColor('#667eea')
                .onChange((value: boolean) => {
                  this.isAgreed = value;
                })
            }

            Text('我已阅读并同意以上协议')
              .fontSize(14)
              .fontColor('#334155')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding({ left: 12, right: 12 })
          .margin({ bottom: 20 })

          // 同意按钮 - 液态玻璃
          Stack() {
            Button('同意并继续')
              .width('100%')
              .height('100%')
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(this.isAgreed ? '#667eea' : 'rgba(203, 213, 225, 0.8)')
              .fontColor(this.isAgreed ? '#FFFFFF' : 'rgba(148, 163, 184, 0.8)')
              .borderRadius(26)
              .enabled(this.isAgreed)
              .opacity(this.isAgreed ? 1 : 0.7)
              .shadow({
                radius: this.isAgreed ? 20 : 0,
                color: 'rgba(99, 102, 241, 0.4)',
                offsetX: 0,
                offsetY: this.isAgreed ? 6 : 0
              })
              .onClick(() => {
                this.acceptAgreement();
              })

            // 按钮高光层
            if (this.isAgreed) {
              Column()
                .width('100%')
                .height('100%')
                .borderRadius(26)
                .linearGradient({
                  angle: 135,
                  colors: [
                    ['rgba(255, 255, 255, 0.3)', 0.0],
                    ['rgba(255, 255, 255, 0.05)', 0.5],
                    ['rgba(255, 255, 255, 0)', 1.0]
                  ]
                })
                .hitTestBehavior(HitTestMode.None)
            }
          }
          .width('85%')
          .height(52)

          // 底部提示 - 液态玻璃标签
          Text('点击"同意并继续"即表示您同意上述条款')
            .fontSize(12)
            .fontColor('rgba(99, 102, 241, 0.7)')
            .margin({ top: 16, bottom: 40 })
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
            .backgroundColor('rgba(255, 255, 255, 0.4)')
            .backdropBlur(10)
            .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: this.topRectHeight / 3 + 20, bottom: this.bottomRectHeight / 3 + 20 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
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
