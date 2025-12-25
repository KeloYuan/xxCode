import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 确定启动页面（使用 Promise 链式调用，因为 onWindowStageCreate 不能是 async）
    this.determineStartPage().then((startPage: string) => {
      hilog.info(DOMAIN, 'testTag', `Starting page: ${startPage}`);

      windowStage.loadContent(startPage, (err: BusinessError) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', err.message || 'Unknown error');
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

        // 配置沉浸式效果
        this.configureImmersiveMode(windowStage);
      });
    });
  }

  /**
   * 根据用户状态确定启动页面
   * 避免启动时的页面跳转闪烁
   */
  private async determineStartPage(): Promise<string> {
    try {
      const dataPreferences = await preferences.getPreferences(this.context, 'user_settings');
      const agreed: boolean = await dataPreferences.get('agreement_accepted', false) as boolean;
      const welcomed: boolean = await dataPreferences.get('welcome_shown', false) as boolean;

      // 根据状态返回正确的启动页面
      if (!agreed) {
        return 'pages/Agreement'; // 未同意协议
      } else if (!welcomed) {
        return 'pages/Index'; // 已同意但未看过欢迎页
      } else {
        return 'pages/CodeEditor'; // 已完成引导，直接进入编辑器
      }
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, 'testTag', 'Failed to read preferences. Cause: %{public}s', error.message || 'Unknown error');
      // 发生错误时，默认显示协议页
      return 'pages/Agreement';
    }
  }

  /**
   * 配置沉浸式效果（窗口全屏布局方案）
   * 让应用内容延伸到状态栏和导航栏区域，实现无缝融合
   */
  private async configureImmersiveMode(windowStage: window.WindowStage): Promise<void> {
    try {
      const mainWindow = windowStage.getMainWindowSync();
      if (!mainWindow) {
        hilog.warn(DOMAIN, 'testTag', 'mainWindow is null');
        return;
      }

      // 1. 设置窗口全屏布局，让内容延伸到状态栏和导航栏区域
      await mainWindow.setWindowLayoutFullScreen(true);
      hilog.info(DOMAIN, 'testTag', 'Window layout set to full-screen mode.');

      // 2. 设置状态栏和导航栏透明（颜色由页面控制）
      const systemBarProperties: window.SystemBarProperties = {
        statusBarColor: '#00000000',           // 状态栏背景透明
        navigationBarColor: '#00000000'        // 导航栏背景透明
      };

      await mainWindow.setWindowSystemBarProperties(systemBarProperties);
      hilog.info(DOMAIN, 'testTag', 'System bar properties configured successfully.');

      // 3. 获取避让区域高度并存储到 AppStorage，供页面使用
      const statusBarArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const navigationArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);

      AppStorage.setOrCreate('topRectHeight', statusBarArea.topRect.height);
      AppStorage.setOrCreate('bottomRectHeight', navigationArea.bottomRect.height);

      hilog.info(DOMAIN, 'testTag', `Avoid areas - Top: ${statusBarArea.topRect.height}, Bottom: ${navigationArea.bottomRect.height}`);

      // 4. 监听避让区域变化（屏幕旋转、折叠等场景）
      mainWindow.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          AppStorage.setOrCreate('topRectHeight', data.area.topRect.height);
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          AppStorage.setOrCreate('bottomRectHeight', data.area.bottomRect.height);
        }
      });

    } catch (error) {
      const err = error as BusinessError;
      hilog.error(DOMAIN, 'testTag', `Failed to configure immersive mode. Code: ${err.code}, Message: ${err.message}`);
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}