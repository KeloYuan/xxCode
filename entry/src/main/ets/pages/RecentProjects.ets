/**
 * 最近项目页
 * 展示最近打开的文件列表（离线）
 */
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { ThemeService, Theme } from '../services/ThemeService';

interface RecentFile {
  name: string;
  path: string;
  lastOpened: number;
}

@Entry
@Component
struct RecentProjects {
  pageTransition() {
    PageTransitionEnter({ duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  @State recentFiles: RecentFile[] = [];
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;

  private context: common.UIAbilityContext | null = null;
  private themeService: ThemeService = ThemeService.getInstance();

  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
    this.loadRecentFiles();
  }

  private loadRecentFiles() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'recent' });
      const raw = store.getSync('recentFiles', '') as string;
      this.recentFiles = raw ? (JSON.parse(raw) as RecentFile[]) : [];
    } catch (e) {
      console.error('加载最近项目失败:', JSON.stringify(e));
      this.recentFiles = [];
    }
  }

  private clearRecentFiles() {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'recent' });
      store.putSync('recentFiles', '[]');
      store.flush();
      this.recentFiles = [];
    } catch (e) {
      console.error('清空最近项目失败:', JSON.stringify(e));
    }
  }

  private openRecentFile(file: RecentFile) {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'recent' });
      store.putSync('pendingOpenFilePath', file.path);
      store.flush();
      router.pushUrl({ url: 'pages/CodeEditor' });
    } catch (e) {
      console.error('打开最近文件失败:', JSON.stringify(e));
    }
  }

  private goBack() {
    try {
      router.back();
    } catch (e) {
      console.error('router.back error:', JSON.stringify(e));
    }
  }

  private formatTime(timestamp: number): string {
    try {
      const date = new Date(timestamp);
      return `${date.toLocaleDateString()} ${date.toLocaleTimeString()}`;
    } catch (e) {
      return '';
    }
  }

  build() {
    Column() {
      Row()
        .width('100%')
        .height(this.topRectHeight > 0 ? this.topRectHeight / 3 : 0)
        .backgroundColor(this.currentTheme.colors.surface)

      Row() {
        Button({ type: ButtonType.Normal }) {
          Row({ space: 6 }) {
            Text('←').fontSize(16).fontColor(this.currentTheme.colors.primary)
            Text($r('app.string.settings_back')).fontSize(15).fontColor(this.currentTheme.colors.primary)
          }
        }
        .height(36)
        .padding({ left: 12, right: 12 })
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())

        Text($r('app.string.recent_projects_title'))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTheme.colors.text)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button($r('app.string.recent_projects_clear'))
          .height(32)
          .fontSize(12)
          .backgroundColor(this.currentTheme.colors.surface)
          .fontColor(this.currentTheme.colors.textSecondary)
          .borderRadius(10)
          .padding({ left: 10, right: 10 })
          .onClick(() => this.clearRecentFiles())
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor(this.currentTheme.colors.surface)
      .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })

      Scroll() {
        Column({ space: 12 }) {
          if (this.recentFiles.length === 0) {
            Column({ space: 8 }) {
              Text('🗂️')
                .fontSize(28)
              Text($r('app.string.recent_projects_empty'))
                .fontSize(13)
                .fontColor(this.currentTheme.colors.textSecondary)
            }
            .width('100%')
            .padding(24)
            .alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.recentFiles, (item: RecentFile) => {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(item.name)
                    .fontSize(15)
                    .fontColor(this.currentTheme.colors.text)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(item.path)
                    .fontSize(11)
                    .fontColor(this.currentTheme.colors.textSecondary)
                    .opacity(0.7)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(this.formatTime(item.lastOpened))
                    .fontSize(10)
                    .fontColor(this.currentTheme.colors.textSecondary)
                    .opacity(0.6)
                }
                .layoutWeight(1)

                Button($r('app.string.btn_open'))
                  .height(32)
                  .fontSize(12)
                  .backgroundColor(this.currentTheme.colors.primary)
                  .fontColor(Color.White)
                  .borderRadius(10)
                  .padding({ left: 10, right: 10 })
                  .onClick(() => this.openRecentFile(item))
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.currentTheme.colors.surface)
              .borderRadius(12)
              .border({ width: 1, color: this.currentTheme.colors.border })
            }, (item: RecentFile) => item.path)
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(this.currentTheme.colors.background)

      Row()
        .width('100%')
        .height(this.bottomRectHeight > 0 ? this.bottomRectHeight / 3 : 0)
        .backgroundColor(this.currentTheme.colors.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.colors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
