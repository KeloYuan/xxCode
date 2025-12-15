import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

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

    windowStage.loadContent('pages/Agreement', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      // 配置沉浸式效果
      this.configureImmersiveMode(windowStage);
    });
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

      // 2. 设置状态栏和导航栏透明，并设置内容颜色为白色
      const systemBarProperties: window.SystemBarProperties = {
        statusBarContentColor: '#FFFFFF',      // 状态栏文字/图标颜色（白色）
        navigationBarContentColor: '#FFFFFF',  // 导航栏文字/图标颜色（白色）
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