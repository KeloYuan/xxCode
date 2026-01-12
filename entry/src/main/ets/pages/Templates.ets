/**
 * 模板库页 - 液态玻璃设计
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
    Stack() {
      // 渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 145,
          colors: [
            [this.currentTheme.colors.background, 0.0],
            [this.currentTheme.colors.surface, 0.5],
            [this.currentTheme.colors.background, 1.0]
          ]
        })

      // 装饰性光晕
      Circle()
        .width(280)
        .height(280)
        .fill(`${this.currentTheme.colors.primary}15`)
        .position({ x: '85%', y: '10%' })
        .blur(70)

      Circle()
        .width(220)
        .height(220)
        .fill(`${this.currentTheme.colors.primary}10`)
        .position({ x: '5%', y: '80%' })
        .blur(60)

      Column() {
        // 顶部占位
        Row()
          .width('100%')
          .height(this.topRectHeight > 0 ? this.topRectHeight / 3 : 0)

        // 液态玻璃导航栏
        Stack() {
          Row() {
            Button({ type: ButtonType.Normal }) {
              Row({ space: 6 }) {
                Text('←')
                  .fontSize(16)
                  .fontColor(this.currentTheme.colors.primary)
                Text($r('app.string.settings_back'))
                  .fontSize(15)
                  .fontColor(this.currentTheme.colors.primary)
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
        }
        .width('100%')
        .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
        .backgroundColor(`${this.currentTheme.colors.surface}CC`)
        .backdropBlur(20)
        .border({ width: { bottom: 0.5 }, color: `${this.currentTheme.colors.border}80` })

        // 分类选择器 - 液态玻璃
        Column() {
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.categories, (category: string) => {
                Stack() {
                  Button(category === 'ALL' ? $r('app.string.templates_category_all') : category)
                    .height(30)
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .backgroundColor(this.activeCategory === category ? this.currentTheme.colors.primary : `${this.currentTheme.colors.surface}80`)
                    .fontColor(this.activeCategory === category ? Color.White : this.currentTheme.colors.text)
                    .borderRadius(15)
                    .padding({ left: 12, right: 12 })
                    .border({ width: this.activeCategory === category ? 0 : 1, color: `${this.currentTheme.colors.border}80` })
                    .onClick(() => this.selectCategory(category))

                  // 激活状态高光
                  if (this.activeCategory === category) {
                    Column()
                      .width('100%')
                      .height('100%')
                      .borderRadius(15)
                      .linearGradient({
                        angle: 135,
                        colors: [
                          ['rgba(255, 255, 255, 0.3)', 0.0],
                          ['rgba(255, 255, 255, 0.1)', 0.5],
                          ['rgba(255, 255, 255, 0)', 1.0]
                        ]
                      })
                      .hitTestBehavior(HitTestMode.None)
                  }
                }
              }, (category: string) => category)
            }
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
        .backgroundColor(`${this.currentTheme.colors.surface}60`)
        .backdropBlur(15)

        // 主内容区
        Row() {
          // 左侧模板列表
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
                  Stack() {
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
                        .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
                        .backgroundColor(`${this.currentTheme.colors.primary}25`)
                        .backdropBlur(10)
                        .borderRadius(6)
                        .border({ width: 1, color: `${this.currentTheme.colors.primary}40` })
                    }
                    .width('100%')
                    .padding({ left: 12, right: 12, top: 10, bottom: 10 })

                    // 选中高光
                    if (this.selectedTemplateId === item.id) {
                      Column()
                        .width('100%')
                        .height('100%')
                        .borderRadius(10)
                        .linearGradient({
                          angle: 135,
                          colors: [
                            [`rgba(255, 255, 255, 0.15)`, 0.0],
                            [`rgba(255, 255, 255, 0.05)`, 1.0]
                          ]
                        })
                        .hitTestBehavior(HitTestMode.None)
                    }
                  }
                  .width('100%')
                  .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
                  .backgroundColor(this.selectedTemplateId === item.id ? `${this.currentTheme.colors.primary}25` : `${this.currentTheme.colors.surface}DD`)
                  .backdropBlur(20)
                  .borderRadius(10)
                  .border({
                    width: this.selectedTemplateId === item.id ? 1.5 : 1,
                    color: this.selectedTemplateId === item.id ? this.currentTheme.colors.primary : `${this.currentTheme.colors.border}60`
                  })
                  .shadow({
                    radius: this.selectedTemplateId === item.id ? 16 : 0,
                    color: this.selectedTemplateId === item.id ? `${this.currentTheme.colors.primary}30` : 'transparent',
                    offsetX: 0,
                    offsetY: this.selectedTemplateId === item.id ? 4 : 0
                  })
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

          // 右侧预览区 - 液态玻璃
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

              // 代码预览 - 液态玻璃
              Column() {
                Scroll() {
                  Text(this.getSelectedTemplate()!.code)
                    .fontSize(12)
                    .fontFamily('monospace')
                    .fontColor(this.currentTheme.editor.text)
                    .lineHeight(18)
                }
                .width('100%')
                .height('100%')
              }
              .width('100%')
              .height(180)
              .padding(12)
              .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
              .backgroundColor(this.currentTheme.editor.background)
              .backdropBlur(15)
              .borderRadius(12)
              .border({ width: 1, color: this.currentTheme.colors.border })
              .shadow({
                radius: 12,
                color: `${this.currentTheme.colors.primary}15`,
                offsetX: 0,
                offsetY: 4
              })

              // 插入按钮 - 液态玻璃
              Stack() {
                Button($r('app.string.templates_insert'))
                  .width('100%')
                  .height('100%')
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor(this.currentTheme.colors.primary)
                  .fontColor(Color.White)
                  .borderRadius(10)
                  .onClick(() => this.insertTemplateToEditor())

                // 按钮高光
                Column()
                  .width('100%')
                  .height('100%')
                  .borderRadius(10)
                  .linearGradient({
                    angle: 135,
                    colors: [
                      ['rgba(255, 255, 255, 0.3)', 0.0],
                      ['rgba(255, 255, 255, 0.1)', 0.5],
                      ['rgba(255, 255, 255, 0)', 1.0]
                    ]
                  })
                  .hitTestBehavior(HitTestMode.None)
              }
              .height(36)
              .width('100%')
              .shadow({
                radius: 16,
                color: `${this.currentTheme.colors.primary}40`,
                offsetX: 0,
                offsetY: 4
              })
            }
            .width('100%')
            .padding({ top: 12, right: 16, left: 12 })
            .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
            .backgroundColor(`${this.currentTheme.colors.surface}CC`)
            .backdropBlur(20)
            .borderRadius(16)
            .border({ width: 1, color: `${this.currentTheme.colors.border}60` })
            .margin({ top: 12, right: 16, bottom: 12 })
          }
        }
        .layoutWeight(1)
        .width('100%')

        // 底部占位
        Row()
          .width('100%')
          .height(this.bottomRectHeight > 0 ? this.bottomRectHeight / 3 : 0)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
