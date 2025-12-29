/**
 * 设置页面
 * 包含字体大小调整、语言切换、版本信息、反馈入口
 */
import { router, window } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { ThemeService, Theme } from '../services/ThemeService';
import pasteboard from '@ohos.pasteboard';

interface WindowBackgroundSetter {
  setWindowBackgroundColor?: (color: string) => void;
}

interface DialogResult {
  index: number;
}

@Entry
@Component
struct Settings {
  // 页面转场动画 - 返回时滑动
  pageTransition() {
    PageTransitionEnter({ duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
  
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  @State fontSize: number = 14;
  @State lineHeight: number = 22;
  @State showLineNumbers: boolean = true;
  @State themes: Theme[] = [];
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  
  private context: common.UIAbilityContext | null = null;
  private themeService: ThemeService = ThemeService.getInstance();
  
  private readonly appVersion: string = '4.0.0';
  private readonly buildNumber: string = '1';
  private readonly gitCodeUrl: string = 'https://gitcode.com/KeloYuan/xxCode';
  
  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
      this.updateWindowBackground(theme);
    });
    this.themes = this.themeService.getAllThemes();
    this.loadEditorPrefs();
    this.updateWindowBackground(this.currentTheme);
  }

  private updateWindowBackground(theme: Theme) {
    try {
      if (!this.context) return;
      window.getLastWindow(this.context).then((windowClass) => {
        const windowRef = windowClass as WindowBackgroundSetter;
        windowRef.setWindowBackgroundColor?.(theme.colors.background);
      }).catch((err: Error) => {
        console.error('Failed to get window:', err.message);
      });
    } catch (e) {
      console.error('更新窗口背景失败:', JSON.stringify(e));
    }
  }
  
  private async loadEditorPrefs() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'settings' });
      this.fontSize = store.getSync('fontSize', 14) as number;
      const storedLineHeight = store.getSync('lineHeight', this.fontSize + 8) as number;
      this.lineHeight = Math.max(this.fontSize + 4, storedLineHeight);
      this.showLineNumbers = store.getSync('showLineNumbers', true) as boolean;
    } catch (e) {
      console.error('加载编辑器设置失败:', JSON.stringify(e));
    }
  }
  
  private async saveFontSize(size: number) {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'settings' });
      store.putSync('fontSize', size);
      if (this.lineHeight < size + 4) {
        this.lineHeight = size + 4;
        store.putSync('lineHeight', this.lineHeight);
      }
      store.flush();
      this.fontSize = size;
    } catch (e) {
      console.error('保存字体大小失败:', JSON.stringify(e));
    }
  }

  private async saveLineHeight(height: number) {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'settings' });
      store.putSync('lineHeight', height);
      store.flush();
      this.lineHeight = height;
    } catch (e) {
      console.error('保存行高失败:', JSON.stringify(e));
    }
  }

  private async saveShowLineNumbers(isOn: boolean) {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'settings' });
      store.putSync('showLineNumbers', isOn);
      store.flush();
      this.showLineNumbers = isOn;
    } catch (e) {
      console.error('保存行号设置失败:', JSON.stringify(e));
    }
  }

  private selectTheme(themeId: string) {
    const switched = this.themeService.switchTheme(themeId);
    if (switched) {
      this.themeService.saveThemePreference(themeId);
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
    this.getUIContext().showAlertDialog({
      title: '反馈方式',
      message: '请发送邮件至：1271791804@qq.com',
      confirm: { value: '确定', action: () => {} }
    });
  }
  
  private goBack() {
    try {
      router.back();
    } catch (e) {
      console.error('router.back error:', JSON.stringify(e));
    }
  }

  build() {
    Column() {
      // 状态栏占位（topRectHeight 已经是 px 值，需要转换为 vp）
      Row().width('100%').height(this.topRectHeight > 0 ? this.topRectHeight / 3 : 0).backgroundColor(this.currentTheme.colors.surface)
      
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Normal }) {
          Row({ space: 6 }) {
            Text('←').fontSize(16).fontColor(this.currentTheme.colors.primary)
            Text($r('app.string.settings_back')).fontSize(15).fontColor(this.currentTheme.colors.primary)
          }
        }
        .height(36).padding({ left: 12, right: 12 }).backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())
        
        Text($r('app.string.settings_title')).fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.currentTheme.colors.text)
          .layoutWeight(1).textAlign(TextAlign.Center)
        
        Row().width(60)
      }
      .width('100%').height(56).padding({ left: 8, right: 8 })
      .backgroundColor(this.currentTheme.colors.surface)
      .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })
      
      // 设置内容
      Scroll() {
        Column({ space: 16 }) {
          // 主题与外观
          this.buildThemeSection()
          // 编辑器设置
          this.buildEditorSection()
          // 最近项目
          this.buildNavigationSection()
          // 语言设置
          this.buildLanguageSection()
          // 关于
          this.buildAboutSection()
          // 反馈
          this.buildFeedbackSection()
        }
        .width('100%').padding(16)
      }
      .layoutWeight(1).width('100%').backgroundColor(this.currentTheme.colors.background)
      
      // 底部导航栏占位
      Row().width('100%').height(this.bottomRectHeight > 0 ? this.bottomRectHeight / 3 : 0).backgroundColor(this.currentTheme.colors.background)
    }
    .width('100%').height('100%').backgroundColor(this.currentTheme.colors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  
  @Builder
  buildEditorSection() {
    Column() {
      Text($r('app.string.settings_editor')).fontSize(13).fontColor(this.currentTheme.colors.textSecondary)
        .width('100%').padding({ left: 4, bottom: 8 })
      
      Column() {
        Row() {
          Text($r('app.string.settings_font_size')).fontSize(16).fontColor(this.currentTheme.colors.text)
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
          Text($r('app.string.settings_line_height')).fontSize(16).fontColor(this.currentTheme.colors.text)
          Blank()
          Text(`${this.lineHeight}px`).fontSize(14).fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%').padding({ left: 12, right: 12, top: 4, bottom: 8 })

        Row({ space: 12 }) {
          Text('↕').fontSize(12).fontColor(this.currentTheme.colors.textSecondary)
          Slider({ value: this.lineHeight, min: 16, max: 36, step: 1 })
            .layoutWeight(1)
            .blockColor(this.currentTheme.colors.primary)
            .trackColor(this.currentTheme.colors.border)
            .selectedColor(this.currentTheme.colors.primary)
            .onChange((value: number) => { this.saveLineHeight(value); })
          Text('↕').fontSize(18).fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%').padding({ left: 12, right: 12, bottom: 12 })

        Row() {
          Text($r('app.string.settings_line_numbers')).fontSize(16).fontColor(this.currentTheme.colors.text)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.showLineNumbers })
            .selectedColor(this.currentTheme.colors.primary)
            .onChange((isOn: boolean) => { this.saveShowLineNumbers(isOn); })
        }
        .width('100%').padding({ left: 12, right: 12, bottom: 12 })
        
        Row() {
          Text($r('app.string.settings_preview')).fontSize(this.fontSize)
            .fontColor(this.currentTheme.colors.text).fontFamily('monospace')
        }
        .width('100%')
        .padding(12)
        .height(this.lineHeight + 16)
        .backgroundColor(this.currentTheme.editor.background)
        .borderRadius(8).margin({ left: 12, right: 12, bottom: 12 })
      }
      .width('100%').backgroundColor(this.currentTheme.colors.surface).borderRadius(12).padding(4)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildThemeSection() {
    Column() {
      Text($r('app.string.settings_theme')).fontSize(13).fontColor(this.currentTheme.colors.textSecondary)
        .width('100%').padding({ left: 4, bottom: 8 })

      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.themes, (theme: Theme) => {
            Column({ space: 6 }) {
              Row() {
                Text(theme.name)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.currentTheme.colors.text)
                  .layoutWeight(1)
                if (theme.id === this.currentTheme.id) {
                  Text('✓')
                    .fontSize(11)
                    .fontColor(Color.White)
                    .width(18)
                    .height(18)
                    .textAlign(TextAlign.Center)
                    .borderRadius(9)
                    .backgroundColor(this.currentTheme.colors.primary)
                }
              }
              .width('100%')

              Row({ space: 6 }) {
                Circle().width(10).height(10).fill(theme.colors.background)
                Circle().width(10).height(10).fill(theme.colors.surface)
                Circle().width(10).height(10).fill(theme.colors.primary)
              }
            }
            .width(140)
            .height(68)
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .backgroundColor(theme.id === this.currentTheme.id ? `${this.currentTheme.colors.primary}12` : this.currentTheme.colors.surface)
            .borderRadius(12)
            .border({ width: 1, color: this.currentTheme.colors.border })
            .onClick(() => {
              this.selectTheme(theme.id);
            })
          }, (theme: Theme) => theme.id)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .backgroundColor(this.currentTheme.colors.surface)
      .borderRadius(12)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  buildLanguageSection() {
    Column() {
      Text($r('app.string.settings_language')).fontSize(13).fontColor(this.currentTheme.colors.textSecondary)
        .width('100%').padding({ left: 4, bottom: 8 })
      
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text($r('app.string.settings_language')).fontSize(16).fontColor(this.currentTheme.colors.text)
            Text('请在系统设置中切换语言\nPlease change language in system settings')
              .fontSize(12)
              .fontColor(this.currentTheme.colors.textSecondary)
              .opacity(0.7)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%').padding({ left: 12, right: 12, top: 12, bottom: 12 })
      }
      .width('100%').backgroundColor(this.currentTheme.colors.surface).borderRadius(12).padding(4)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildNavigationSection() {
    Column() {
      Text('快捷入口')
        .fontSize(13)
        .fontColor(this.currentTheme.colors.textSecondary)
        .width('100%')
        .padding({ left: 4, bottom: 8 })

      Column() {
        Row() {
          Text($r('app.string.recent_projects_title'))
            .fontSize(16)
            .fontColor(this.currentTheme.colors.text)
          Blank()
          Text('›')
            .fontSize(18)
            .fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 12 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/RecentProjects' });
        })

        Row() {
          Text($r('app.string.templates_title'))
            .fontSize(16)
            .fontColor(this.currentTheme.colors.text)
          Blank()
          Text('›')
            .fontSize(18)
            .fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 12 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Templates' });
        })

        Row() {
          Text($r('app.string.help_title'))
            .fontSize(16)
            .fontColor(this.currentTheme.colors.text)
          Blank()
          Text('›')
            .fontSize(18)
            .fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 12 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Help' });
        })

        Row() {
          Text($r('app.string.learning_title'))
            .fontSize(16)
            .fontColor(this.currentTheme.colors.text)
          Blank()
          Text('›')
            .fontSize(18)
            .fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 12 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Learning' });
        })

        Row() {
          Text($r('app.string.changelog_title'))
            .fontSize(16)
            .fontColor(this.currentTheme.colors.text)
          Blank()
          Text('›')
            .fontSize(18)
            .fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 12 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Changelog' });
        })
      }
      .width('100%')
      .backgroundColor(this.currentTheme.colors.surface)
      .borderRadius(12)
      .padding(4)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  buildAboutSection() {
    Column() {
      Text($r('app.string.settings_about')).fontSize(13).fontColor(this.currentTheme.colors.textSecondary)
        .width('100%').padding({ left: 4, bottom: 8 })
      
      Column() {
        this.buildItem($r('app.string.settings_version'), `${this.appVersion} (${this.buildNumber})`, false)
        Divider().color(this.currentTheme.colors.border).margin({ left: 12, right: 12 })
        this.buildItem($r('app.string.settings_app_name'), '元代码', false)
        Divider().color(this.currentTheme.colors.border).margin({ left: 12, right: 12 })
        this.buildItem($r('app.string.settings_developer'), '谢旺涛，张思怡', false)
        Divider().color(this.currentTheme.colors.border).margin({ left: 12, right: 12 })
        this.buildItem('运营', '张思怡', false)
        Divider().color(this.currentTheme.colors.border).margin({ left: 12, right: 12 })
        this.buildLinkItem('开源地址', 'GitCode', $r('app.media.gitcode'), () => {
          this.showOpenSourceDialog();
        })
        
      }
      .width('100%').backgroundColor(this.currentTheme.colors.surface).borderRadius(12).padding(4)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  buildFeedbackSection() {
    Column() {
      Text($r('app.string.settings_feedback')).fontSize(13).fontColor(this.currentTheme.colors.textSecondary)
        .width('100%').padding({ left: 4, bottom: 8 })
      
      Column() {
        Row() {
          Text($r('app.string.settings_feedback_title')).fontSize(16).fontColor(this.currentTheme.colors.text)
          Blank()
          Text($r('app.string.settings_feedback_action')).fontSize(14).fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%').height(52).padding({ left: 12, right: 12 })
        .onClick(() => { this.openFeedback(); })
        
        Divider().color(this.currentTheme.colors.border).margin({ left: 12, right: 12 })
        
        Row() {
          Text($r('app.string.settings_rate')).fontSize(16).fontColor(this.currentTheme.colors.text)
          Blank()
          Text($r('app.string.settings_rate_action')).fontSize(14).fontColor(this.currentTheme.colors.textSecondary)
        }
        .width('100%').height(52).padding({ left: 12, right: 12 })
        .onClick(() => {
          this.getUIContext().getPromptAction().showDialog({
            title: '感谢支持',
            message: '请在华为应用市场搜索"元代码"进行评价',
            buttons: [
              { text: '好的', color: this.currentTheme.colors.primary }
            ]
          }).catch((err: Error) => {
            console.error('showDialog error:', err.message);
          });
        })
      }
      .width('100%').backgroundColor(this.currentTheme.colors.surface).borderRadius(12).padding(4)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  buildItem(label: ResourceStr, value: ResourceStr | string, showArrow: boolean) {
    Row() {
      Text(label).fontSize(16).fontColor(this.currentTheme.colors.text)
      Blank()
      Text(value + (showArrow ? ' >' : '')).fontSize(14).fontColor(this.currentTheme.colors.textSecondary)
    }
    .width('100%').height(52).padding({ left: 12, right: 12 })
  }

  @Builder
  buildLinkItem(label: ResourceStr | string, value: string, icon: Resource, onClick?: () => void) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.currentTheme.colors.text)
      Blank()
      Row({ space: 6 }) {
        Image(icon)
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
        Text(value)
          .fontSize(14)
          .fontColor(this.currentTheme.colors.textSecondary)
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: 12, right: 12 })
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }

  private showOpenSourceDialog(): void {
    this.getUIContext().getPromptAction().showDialog({
      title: '开源地址',
      message: `这是 GitCode 上的开源地址，欢迎大家共创：\n${this.gitCodeUrl}`,
      buttons: [
        { text: '复制链接', color: this.currentTheme.colors.primary },
        { text: '关闭', color: this.currentTheme.colors.textSecondary }
      ]
    }).then((result: DialogResult) => {
      if (result.index === 0) {
        this.copyGitCodeUrl();
      }
    }).catch((err: Error) => {
      console.error('showDialog error:', err.message);
    });
  }

  private copyGitCodeUrl(): void {
    try {
      const pasteboardInstance = pasteboard.getSystemPasteboard();
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.gitCodeUrl);
      pasteboardInstance.setData(pasteData).then(() => {
        this.getUIContext().getPromptAction().showToast({ message: '链接已复制' });
      }).catch((err: Error) => {
        console.error('copy link error:', err.message);
        this.getUIContext().getPromptAction().showToast({ message: '复制失败' });
      });
    } catch (e) {
      console.error('copy link error:', JSON.stringify(e));
      this.getUIContext().getPromptAction().showToast({ message: '复制失败' });
    }
  }
}
