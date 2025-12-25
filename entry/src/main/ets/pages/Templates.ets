/**
 * 模板库页
 * 浏览与插入代码模板（离线）
 */
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { ThemeService, Theme } from '../services/ThemeService';
import { CodeTemplate, CodeTemplateData } from '../models/CodeTemplateModel';

@Entry
@Component
struct Templates {
  pageTransition() {
    PageTransitionEnter({ duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  @State categories: string[] = [];
  @State activeCategory: string = 'ALL';
  @State selectedTemplateId: string = '';
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;

  private context: common.UIAbilityContext | null = null;
  private themeService: ThemeService = ThemeService.getInstance();

  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
    this.categories = ['ALL', ...CodeTemplateData.getCategories()];
    const templates = CodeTemplateData.getAllTemplates();
    if (templates.length > 0) {
      this.selectedTemplateId = templates[0].id;
    }
  }

  private getFilteredTemplates(): CodeTemplate[] {
    if (this.activeCategory === 'ALL') {
      return CodeTemplateData.getAllTemplates();
    }
    return CodeTemplateData.getTemplatesByCategory(this.activeCategory);
  }

  private getSelectedTemplate(): CodeTemplate | undefined {
    return CodeTemplateData.getTemplateById(this.selectedTemplateId);
  }

  private selectCategory(category: string) {
    this.activeCategory = category;
    const list = this.getFilteredTemplates();
    if (list.length > 0) {
      this.selectedTemplateId = list[0].id;
    }
  }

  private insertTemplateToEditor() {
    try {
      if (!this.context) return;
      const selected = this.getSelectedTemplate();
      if (!selected) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'templates' });
      store.putSync('pendingTemplateId', selected.id);
      store.flush();
      try {
        router.back();
      } catch (e) {
        router.pushUrl({ url: 'pages/CodeEditor' });
      }
    } catch (e) {
      console.error('插入模板失败:', JSON.stringify(e));
    }
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

        Text($r('app.string.templates_title'))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTheme.colors.text)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Row().width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor(this.currentTheme.colors.surface)
      .border({ width: { bottom: 1 }, color: this.currentTheme.colors.border })

      Column() {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.categories, (category: string) => {
              Button(category === 'ALL' ? $r('app.string.templates_category_all') : category)
                .height(30)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(this.activeCategory === category ? this.currentTheme.colors.primary : this.currentTheme.colors.surface)
                .fontColor(this.activeCategory === category ? Color.White : this.currentTheme.colors.text)
                .borderRadius(12)
                .padding({ left: 12, right: 12 })
                .border({ width: this.activeCategory === category ? 0 : 1, color: this.currentTheme.colors.border })
                .onClick(() => this.selectCategory(category))
            }, (category: string) => category)
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .backgroundColor(this.currentTheme.colors.surface)

      Row() {
        Scroll() {
          Column({ space: 8 }) {
            if (this.getFilteredTemplates().length === 0) {
              Column({ space: 8 }) {
                Text('📦').fontSize(28)
                Text($r('app.string.templates_empty'))
                  .fontSize(13)
                  .fontColor(this.currentTheme.colors.textSecondary)
              }
              .width('100%')
              .padding(24)
              .alignItems(HorizontalAlign.Center)
            } else {
              ForEach(this.getFilteredTemplates(), (item: CodeTemplate) => {
                Row({ space: 8 }) {
                  Column({ space: 4 }) {
                    Text(item.name)
                      .fontSize(14)
                      .fontColor(this.currentTheme.colors.text)
                    Text(item.description)
                      .fontSize(11)
                      .fontColor(this.currentTheme.colors.textSecondary)
                      .opacity(0.7)
                  }
                  .layoutWeight(1)

                  Text(item.language.toUpperCase())
                    .fontSize(10)
                    .fontColor(this.currentTheme.colors.primary)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor(`${this.currentTheme.colors.primary}15`)
                    .borderRadius(6)
                }
                .width('100%')
                .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                .backgroundColor(this.selectedTemplateId === item.id ? `${this.currentTheme.colors.primary}15` : this.currentTheme.colors.surface)
                .borderRadius(10)
                .border({ width: 1, color: this.currentTheme.colors.border })
                .onClick(() => {
                  this.selectedTemplateId = item.id;
                })
              }, (item: CodeTemplate) => item.id)
            }
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .width('100%')

        Column() {
          if (this.getSelectedTemplate()) {
            Column({ space: 10 }) {
              Text(this.getSelectedTemplate()!.name)
                .fontSize(16)
                .fontColor(this.currentTheme.colors.text)
                .fontWeight(FontWeight.Medium)
              Text(this.getSelectedTemplate()!.description)
                .fontSize(12)
                .fontColor(this.currentTheme.colors.textSecondary)
                .opacity(0.7)

              Column() {
                Text(this.getSelectedTemplate()!.code)
                  .fontSize(12)
                  .fontFamily('monospace')
                  .fontColor(this.currentTheme.editor.text)
                  .lineHeight(18)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.currentTheme.editor.background)
              .borderRadius(10)
              .border({ width: 1, color: this.currentTheme.colors.border })

              Button($r('app.string.templates_insert'))
                .height(36)
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(this.currentTheme.colors.primary)
                .fontColor(Color.White)
                .borderRadius(10)
                .padding({ left: 14, right: 14 })
                .onClick(() => this.insertTemplateToEditor())
            }
          }
        }
        .width('44%')
        .padding({ top: 12, right: 16 })
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
