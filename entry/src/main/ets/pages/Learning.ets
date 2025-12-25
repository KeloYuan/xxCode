/**
 * 学习模式页
 * 提供带注释的样本文件，引导学习
 */
import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { ThemeService, Theme } from '../services/ThemeService';
import { FileManagerService } from '../services/FileManagerService';

class SampleFile {
  name: string = '';
  description: string = '';
  path: string = '';
  points: string[] = [];
  highlights: string[] = [];
}

class SampleDef {
  name: string = '';
  description: string = '';
  content: string = '';
  points: string[] = [];
  highlights: string[] = [];

  constructor(name: string, description: string, content: string, points: string[], highlights: string[]) {
    this.name = name;
    this.description = description;
    this.content = content;
    this.points = points;
    this.highlights = highlights;
  }
}

@Entry
@Component
struct Learning {
  pageTransition() {
    PageTransitionEnter({ duration: 240, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 240, curve: Curve.EaseIn })
      .slide(SlideEffect.Right)
  }
  @State currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  @State samples: SampleFile[] = [];
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;

  private themeService: ThemeService = ThemeService.getInstance();
  private fileManager: FileManagerService = FileManagerService.getInstance();
  private context: common.UIAbilityContext | null = null;

  async aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });

    if (this.context) {
      await this.fileManager.init(this.context);
      this.prepareSamples();
    }
  }

  private prepareSamples() {
    const baseDir = this.fileManager.getCodesDir();
    const sampleDefs: SampleDef[] = [
      new SampleDef(
        'hello.js',
        'JavaScript 入门：变量、函数、注释',
        [
          '// 学习目标：认识变量与函数',
          'const message = "Hello, xxCode!";',
          '',
          '// 函数声明',
          'function greet(name) {',
          '  return `Hi, ${name}`;',
          '}',
          '',
          '// 调用函数',
          'console.log(greet(message));'
        ].join('\n'),
        ['变量声明', '函数定义', '模板字符串'],
        ['第 1 行：注释说明', '第 2 行：变量声明', '第 5 行：函数定义']
      ),
      new SampleDef(
        'layout.html',
        'HTML 基础结构 + 语义标签',
        [
          '<!DOCTYPE html>',
          '<html lang="zh-CN">',
          '<head>',
          '  <meta charset="UTF-8" />',
          '  <meta name="viewport" content="width=device-width, initial-scale=1.0" />',
          '  <title>Learning</title>',
          '</head>',
          '<body>',
          '  <!-- 语义化布局 -->',
          '  <header>Header</header>',
          '  <main>',
          '    <section>',
          '      <h1>标题</h1>',
          '      <p>段落内容</p>',
          '    </section>',
          '  </main>',
          '  <footer>Footer</footer>',
          '</body>',
          '</html>'
        ].join('\n'),
        ['HTML 基础结构', '语义标签', 'SEO 友好'],
        ['第 1 行：DOCTYPE', '第 8 行：header 标签', '第 9 行：main 标签']
      ),
      new SampleDef(
        'notes.md',
        'Markdown：标题、列表、代码块',
        [
          '# 学习笔记',
          '',
          '## 今日目标',
          '- 了解 Markdown 语法',
          '- 学会列表与代码块',
          '',
          '```js',
          'const x = 42;',
          'console.log(x);',
          '```'
        ].join('\n'),
        ['标题层级', '无序列表', '代码块'],
        ['第 1 行：一级标题', '第 4 行：列表项', '第 7 行：代码块']
      ),
      new SampleDef(
        'style.css',
        'CSS：布局与视觉样式',
        [
          '.card {',
          '  display: flex;',
          '  align-items: center;',
          '  padding: 16px;',
          '  border-radius: 12px;',
          '  gap: 12px;',
          '  background: #ffffff;',
          '  color: #333333;',
          '  box-shadow: 0 6px 16px rgba(0,0,0,0.12);',
          '}'
        ].join('\n'),
        ['Flex 布局', '间距与颜色', '圆角与阴影'],
        ['第 2 行：display flex', '第 6 行：gap', '第 9 行：box-shadow']
      ),
      new SampleDef(
        'config.json',
        'JSON：结构化数据',
        [
          '{',
          '  "name": "xxCode",',
          '  "version": "3.0.0",',
          '  "features": ["template", "preview", "learning"],',
          '  "author": {',
          '    "name": "Niki"',
          '  },',
          '  "enabled": true',
          '}'
        ].join('\n'),
        ['对象结构', '数组字段', '布尔值'],
        ['第 2 行：name 字段', '第 4 行：features 数组', '第 7 行：enabled']
      ),
      new SampleDef(
        'types.ts',
        'TypeScript：类型与接口',
        [
          'type Theme = {',
          '  id: string;',
          '  name: string;',
          '};',
          '',
          'interface EditorConfig {',
          '  fontSize: number;',
          '  lineHeight?: number;',
          '}'
        ].join('\n'),
        ['类型别名', '接口', '可选字段'],
        ['第 1 行：类型别名', '第 5 行：interface', '第 7 行：可选字段']
      )
    ];

    const list: SampleFile[] = [];
    sampleDefs.forEach((item) => {
      const fullPath = `${baseDir}/${item.name}`;
      if (!this.fileManager.fileExists(fullPath)) {
        try {
          this.fileManager.createFile(item.name, item.content);
        } catch (e) {
          console.error('创建样本失败:', JSON.stringify(e));
        }
      }
      list.push({
        name: item.name,
        description: item.description,
        path: fullPath,
        points: item.points,
        highlights: item.highlights
      });
    });

    this.samples = list;
  }

  private openSample(file: SampleFile) {
    try {
      if (!this.context) return;
      const store = preferences.getPreferencesSync(this.context, { name: 'recent' });
      store.putSync('pendingOpenFilePath', file.path);
      store.flush();
      router.pushUrl({ url: 'pages/CodeEditor' });
    } catch (e) {
      console.error('打开样本失败:', JSON.stringify(e));
    }
  }

  private goBack() {
    try {
      router.back();
    } catch (e) {
      console.error('router.back error:', JSON.stringify(e));
    }
  }

  @Builder
  buildTag(text: string) {
    Text(text)
      .fontSize(10)
      .fontColor(this.currentTheme.colors.primary)
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      .backgroundColor(`${this.currentTheme.colors.primary}15`)
      .borderRadius(6)
  }

  @Builder
  buildBullet(text: string) {
    Row({ space: 6 }) {
      Text('•')
        .fontSize(12)
        .fontColor(this.currentTheme.colors.textSecondary)
      Text(text)
        .fontSize(12)
        .fontColor(this.currentTheme.colors.textSecondary)
        .layoutWeight(1)
    }
    .width('100%')
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

        Text($r('app.string.learning_title'))
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

      Scroll() {
        Column({ space: 12 }) {
          Text($r('app.string.learning_intro'))
            .fontSize(13)
            .fontColor(this.currentTheme.colors.textSecondary)
            .width('100%')
            .padding({ left: 4, bottom: 6 })

          ForEach(this.samples, (sample: SampleFile) => {
            Column({ space: 10 }) {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(sample.name)
                    .fontSize(15)
                    .fontColor(this.currentTheme.colors.text)
                  Text(sample.description)
                    .fontSize(12)
                    .fontColor(this.currentTheme.colors.textSecondary)
                    .opacity(0.7)
                }
                .layoutWeight(1)

                Button($r('app.string.learning_open'))
                  .height(32)
                  .fontSize(12)
                  .backgroundColor(this.currentTheme.colors.primary)
                  .fontColor(Color.White)
                  .borderRadius(10)
                  .padding({ left: 10, right: 10 })
                  .onClick(() => this.openSample(sample))
              }

              Row({ space: 6 }) {
                ForEach(sample.points, (point: string) => {
                  this.buildTag(point)
                }, (point: string) => point)
              }

              Column({ space: 4 }) {
                Text('重点提示')
                  .fontSize(12)
                  .fontColor(this.currentTheme.colors.text)
                  .fontWeight(FontWeight.Medium)
                ForEach(sample.highlights, (line: string) => {
                  this.buildBullet(line)
                }, (line: string) => line)
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor(this.currentTheme.colors.surface)
            .borderRadius(12)
            .border({ width: 1, color: this.currentTheme.colors.border })
          }, (sample: SampleFile) => sample.path)
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
