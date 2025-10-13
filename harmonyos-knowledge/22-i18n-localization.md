# 国际化与本地化 (i18n)

> 本文档介绍 HarmonyOS Next 中的国际化和本地化最佳实践，包括多语言支持、资源管理、日期时间格式化等。

---

## 目录
- [资源文件配置](#资源文件配置)
- [多语言字符串](#多语言字符串)
- [动态语言切换](#动态语言切换)
- [日期时间格式化](#日期时间格式化)
- [数字货币格式化](#数字货币格式化)
- [RTL 布局支持](#rtl-布局支持)
- [完整应用示例](#完整应用示例)

---

## 资源文件配置

### 目录结构

```
entry/src/main/resources/
├── base/                    # 默认资源（通常是英文）
│   └── element/
│       ├── string.json
│       ├── color.json
│       └── float.json
├── zh_CN/                   # 简体中文
│   └── element/
│       └── string.json
├── zh_TW/                   # 繁体中文
│   └── element/
│       └── string.json
├── en_US/                   # 美式英语
│   └── element/
│       └── string.json
├── ja_JP/                   # 日语
│   └── element/
│       └── string.json
└── ko_KR/                   # 韩语
    └── element/
        └── string.json
```

### base/element/string.json

```json
{
  "string": [
    {
      "name": "app_name",
      "value": "My App"
    },
    {
      "name": "welcome_message",
      "value": "Welcome to HarmonyOS"
    },
    {
      "name": "settings",
      "value": "Settings"
    },
    {
      "name": "language",
      "value": "Language"
    },
    {
      "name": "save",
      "value": "Save"
    },
    {
      "name": "cancel",
      "value": "Cancel"
    },
    {
      "name": "confirm",
      "value": "Confirm"
    },
    {
      "name": "user_greeting",
      "value": "Hello, %s!"
    },
    {
      "name": "item_count",
      "value": "You have %d items"
    }
  ]
}
```

### zh_CN/element/string.json

```json
{
  "string": [
    {
      "name": "app_name",
      "value": "我的应用"
    },
    {
      "name": "welcome_message",
      "value": "欢迎使用鸿蒙系统"
    },
    {
      "name": "settings",
      "value": "设置"
    },
    {
      "name": "language",
      "value": "语言"
    },
    {
      "name": "save",
      "value": "保存"
    },
    {
      "name": "cancel",
      "value": "取消"
    },
    {
      "name": "confirm",
      "value": "确认"
    },
    {
      "name": "user_greeting",
      "value": "你好，%s！"
    },
    {
      "name": "item_count",
      "value": "您有 %d 个项目"
    }
  ]
}
```

---

## 多语言字符串

### 基础使用

```typescript
@Entry
@Component
struct I18nBasicExample {
  build() {
    Column() {
      // 直接引用资源
      Text($r('app.string.app_name'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
      
      Text($r('app.string.welcome_message'))
        .fontSize(18)
        .margin({ bottom: 20 })
      
      // 按钮文字
      Row() {
        Button($r('app.string.save'))
          .margin({ right: 12 })
        
        Button($r('app.string.cancel'))
          .backgroundColor('#ccc')
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

### 带参数的字符串

```typescript
import resourceManager from '@ohos.resourceManager'

@Entry
@Component
struct I18nParametersExample {
  @State userName: string = '张三'
  @State itemCount: number = 5
  @State greetingText: string = ''
  @State countText: string = ''
  
  async aboutToAppear() {
    await this.loadLocalizedStrings()
  }
  
  async loadLocalizedStrings() {
    try {
      const resMgr = getContext(this).resourceManager
      
      // 加载带参数的字符串
      const greetingFormat = await resMgr.getStringValue($r('app.string.user_greeting'))
      this.greetingText = greetingFormat.replace('%s', this.userName)
      
      const countFormat = await resMgr.getStringValue($r('app.string.item_count'))
      this.countText = countFormat.replace('%d', this.itemCount.toString())
    } catch (error) {
      console.error('加载本地化字符串失败:', error)
    }
  }
  
  build() {
    Column() {
      Text(this.greetingText)
        .fontSize(20)
        .margin({ bottom: 12 })
      
      Text(this.countText)
        .fontSize(16)
        .fontColor('#666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
}
```

---

## 动态语言切换

### 语言切换服务

```typescript
import resourceManager from '@ohos.resourceManager'
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant'

export class LocaleService {
  private static instance: LocaleService | null = null
  private resMgr: resourceManager.ResourceManager
  
  private constructor(context: Context) {
    this.resMgr = context.resourceManager
  }
  
  public static getInstance(context: Context): LocaleService {
    if (!LocaleService.instance) {
      LocaleService.instance = new LocaleService(context)
    }
    return LocaleService.instance
  }
  
  /**
   * 获取当前语言
   */
  getCurrentLanguage(): string {
    const config = this.resMgr.getConfiguration()
    return config.direction === ConfigurationConstant.Direction.DIRECTION_VERTICAL 
      ? 'zh_CN' : 'en_US'
  }
  
  /**
   * 切换语言
   */
  async switchLanguage(locale: string): Promise<void> {
    try {
      // 注意：实际切换语言需要系统级权限
      // 这里只是示例，实际应用中应该引导用户到系统设置
      console.info(`切换语言到: ${locale}`)
    } catch (error) {
      console.error('切换语言失败:', error)
    }
  }
  
  /**
   * 获取本地化字符串
   */
  async getString(resId: Resource): Promise<string> {
    try {
      return await this.resMgr.getStringValue(resId)
    } catch (error) {
      console.error('获取字符串失败:', error)
      return ''
    }
  }
  
  /**
   * 获取格式化字符串
   */
  async getFormattedString(resId: Resource, ...args: (string | number)[]): Promise<string> {
    try {
      const format = await this.resMgr.getStringValue(resId)
      let result = format
      
      args.forEach((arg, index) => {
        const placeholder = typeof arg === 'string' ? '%s' : '%d'
        result = result.replace(placeholder, arg.toString())
      })
      
      return result
    } catch (error) {
      console.error('获取格式化字符串失败:', error)
      return ''
    }
  }
}
```

### 语言选择界面

```typescript
import { LocaleService } from '../services/LocaleService'

interface LanguageOption {
  code: string
  name: string
  nativeName: string
}

@Entry
@Component
struct LanguageSettingsPage {
  @State selectedLanguage: string = 'zh_CN'
  
  private languages: LanguageOption[] = [
    { code: 'zh_CN', name: 'Chinese (Simplified)', nativeName: '简体中文' },
    { code: 'zh_TW', name: 'Chinese (Traditional)', nativeName: '繁體中文' },
    { code: 'en_US', name: 'English (US)', nativeName: 'English' },
    { code: 'ja_JP', name: 'Japanese', nativeName: '日本語' },
    { code: 'ko_KR', name: 'Korean', nativeName: '한국어' },
    { code: 'fr_FR', name: 'French', nativeName: 'Français' },
    { code: 'de_DE', name: 'German', nativeName: 'Deutsch' },
    { code: 'es_ES', name: 'Spanish', nativeName: 'Español' }
  ]
  
  private localeService: LocaleService = LocaleService.getInstance(getContext(this))
  
  aboutToAppear() {
    this.selectedLanguage = this.localeService.getCurrentLanguage()
  }
  
  build() {
    Navigation() {
      Column() {
        Text($r('app.string.language'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        
        List() {
          ForEach(this.languages, (lang: LanguageOption) => {
            ListItem() {
              this.LanguageItem(lang)
            }
          })
        }
        .divider({ strokeWidth: 1, color: '#f0f0f0' })
      }
      .width('100%')
      .height('100%')
      .padding(20)
    }
    .title($r('app.string.language'))
    .titleMode(NavigationTitleMode.Mini)
  }
  
  @Builder
  LanguageItem(lang: LanguageOption) {
    Row() {
      Column({ space: 4 }) {
        Text(lang.nativeName)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
        
        Text(lang.name)
          .fontSize(14)
          .fontColor('#666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      if (this.selectedLanguage === lang.code) {
        Text('✓')
          .fontSize(24)
          .fontColor('#1890ff')
      }
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .onClick(() => {
      this.selectedLanguage = lang.code
      this.localeService.switchLanguage(lang.code)
    })
  }
}
```

---

## 日期时间格式化

### 使用 Intl API

```typescript
import intl from '@ohos.intl'

@Entry
@Component
struct DateTimeFormatExample {
  @State currentDate: Date = new Date()
  @State formattedDate: string = ''
  @State formattedTime: string = ''
  @State formattedDateTime: string = ''
  @State relativeTime: string = ''
  
  aboutToAppear() {
    this.formatDateTime()
  }
  
  formatDateTime() {
    // 日期格式化
    const dateFormat = new intl.DateTimeFormat('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
    this.formattedDate = dateFormat.format(this.currentDate)
    
    // 时间格式化
    const timeFormat = new intl.DateTimeFormat('zh-CN', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false
    })
    this.formattedTime = timeFormat.format(this.currentDate)
    
    // 完整日期时间
    const dateTimeFormat = new intl.DateTimeFormat('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      weekday: 'long'
    })
    this.formattedDateTime = dateTimeFormat.format(this.currentDate)
  }
  
  build() {
    Column() {
      Text('日期时间格式化')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      this.InfoRow('原始时间', this.currentDate.toString())
      this.InfoRow('日期', this.formattedDate)
      this.InfoRow('时间', this.formattedTime)
      this.InfoRow('完整格式', this.formattedDateTime)
      
      Button('刷新')
        .margin({ top: 20 })
        .onClick(() => {
          this.currentDate = new Date()
          this.formatDateTime()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
  
  @Builder
  InfoRow(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#666')
      
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }
}
```

### 相对时间格式化

```typescript
import intl from '@ohos.intl'

@Entry
@Component
struct RelativeTimeExample {
  @State relativeTimeText: string = ''
  
  aboutToAppear() {
    this.formatRelativeTime()
  }
  
  formatRelativeTime() {
    const rtf = new intl.RelativeTimeFormat('zh-CN', { numeric: 'auto' })
    
    // 各种相对时间示例
    const examples = [
      rtf.format(-1, 'day'),      // 昨天
      rtf.format(0, 'day'),       // 今天
      rtf.format(1, 'day'),       // 明天
      rtf.format(-2, 'week'),     // 2周前
      rtf.format(3, 'month'),     // 3个月后
      rtf.format(-1, 'year')      // 去年
    ]
    
    this.relativeTimeText = examples.join('\n')
  }
  
  build() {
    Column() {
      Text('相对时间')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      Text(this.relativeTimeText)
        .fontSize(16)
        .lineHeight(28)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
}
```

---

## 数字货币格式化

### 数字格式化

```typescript
import intl from '@ohos.intl'

@Entry
@Component
struct NumberFormatExample {
  @State number: number = 1234567.89
  @State formattedNumber: string = ''
  @State formattedPercent: string = ''
  @State formattedCurrency: string = ''
  
  aboutToAppear() {
    this.formatNumbers()
  }
  
  formatNumbers() {
    // 普通数字格式化
    const numberFormat = new intl.NumberFormat('zh-CN')
    this.formattedNumber = numberFormat.format(this.number)
    
    // 百分比格式化
    const percentFormat = new intl.NumberFormat('zh-CN', { style: 'percent' })
    this.formattedPercent = percentFormat.format(0.856)
    
    // 货币格式化
    const currencyFormat = new intl.NumberFormat('zh-CN', {
      style: 'currency',
      currency: 'CNY'
    })
    this.formattedCurrency = currencyFormat.format(this.number)
  }
  
  build() {
    Column() {
      Text('数字格式化')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      this.FormatExample('原始数字', this.number.toString())
      this.FormatExample('标准格式', this.formattedNumber)
      this.FormatExample('百分比', this.formattedPercent)
      this.FormatExample('货币 (CNY)', this.formattedCurrency)
      
      Divider()
        .margin({ top: 20, bottom: 20 })
      
      // 多币种示例
      this.CurrencyExamples()
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
  
  @Builder
  FormatExample(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666')
        .width('40%')
      
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }
  
  @Builder
  CurrencyExamples() {
    Column() {
      Text('多币种格式')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
      
      const amount = 9999.99
      
      this.CurrencyRow('人民币', amount, 'CNY', 'zh-CN')
      this.CurrencyRow('美元', amount, 'USD', 'en-US')
      this.CurrencyRow('欧元', amount, 'EUR', 'de-DE')
      this.CurrencyRow('日元', amount, 'JPY', 'ja-JP')
      this.CurrencyRow('韩元', amount, 'KRW', 'ko-KR')
    }
    .width('100%')
  }
  
  @Builder
  CurrencyRow(label: string, amount: number, currency: string, locale: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .width('30%')
      
      Text(new intl.NumberFormat(locale, {
        style: 'currency',
        currency: currency
      }).format(amount))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#fafafa')
    .borderRadius(6)
    .margin({ bottom: 8 })
  }
}
```

---

## RTL 布局支持

### 响应式 RTL 布局

```typescript
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant'

@Entry
@Component
struct RTLLayoutExample {
  @State isRTL: boolean = false
  
  aboutToAppear() {
    // 检测是否是 RTL 语言
    const config = getContext(this).resourceManager.getConfiguration()
    this.isRTL = config.direction === ConfigurationConstant.Direction.DIRECTION_HORIZONTAL
  }
  
  build() {
    Column() {
      Text('RTL 布局示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      // 自动适配 RTL 的布局
      Row() {
        Image($r('app.media.icon'))
          .width(50)
          .height(50)
          .margin({ end: 16 })  // 使用 end 而不是 right
        
        Column({ space: 4 }) {
          Text('用户名称')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          
          Text('这是一段描述文字')
            .fontSize(14)
            .fontColor('#666')
        }
        .alignItems(this.isRTL ? HorizontalAlign.End : HorizontalAlign.Start)
        .layoutWeight(1)
        
        Text('→')
          .fontSize(24)
          .rotate({ angle: this.isRTL ? 180 : 0 })  // RTL 时翻转箭头
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#f5f5f5')
      .borderRadius(8)
      .direction(this.isRTL ? Direction.Rtl : Direction.Ltr)
      
      Divider()
        .margin({ top: 20, bottom: 20 })
      
      // 列表项示例
      List() {
        ForEach([1, 2, 3], (item: number) => {
          ListItem() {
            this.ListItemContent(`项目 ${item}`)
          }
        })
      }
      .divider({ strokeWidth: 1, color: '#f0f0f0' })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
  
  @Builder
  ListItemContent(title: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .layoutWeight(1)
      
      Text('>')
        .fontSize(20)
        .fontColor('#999')
        .rotate({ angle: this.isRTL ? 180 : 0 })
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .direction(this.isRTL ? Direction.Rtl : Direction.Ltr)
  }
}
```

---

## 完整应用示例

### 多语言博客应用

```typescript
import intl from '@ohos.intl'
import { LocaleService } from '../services/LocaleService'

interface Article {
  id: number
  titleKey: string
  contentKey: string
  author: string
  publishDate: Date
  views: number
}

@Entry
@Component
struct MultilanguageBlog {
  @State currentLocale: string = 'zh-CN'
  @State articles: Article[] = []
  
  private localeService: LocaleService = LocaleService.getInstance(getContext(this))
  
  aboutToAppear() {
    this.loadArticles()
  }
  
  loadArticles() {
    this.articles = [
      {
        id: 1,
        titleKey: 'article_1_title',
        contentKey: 'article_1_content',
        author: 'Zhang San',
        publishDate: new Date('2024-10-01'),
        views: 1234
      },
      {
        id: 2,
        titleKey: 'article_2_title',
        contentKey: 'article_2_content',
        author: 'Li Si',
        publishDate: new Date('2024-10-05'),
        views: 5678
      }
    ]
  }
  
  build() {
    Navigation() {
      Column() {
        // 语言切换器
        Row() {
          Button('中文')
            .fontSize(14)
            .backgroundColor(this.currentLocale === 'zh-CN' ? '#1890ff' : '#f0f0f0')
            .fontColor(this.currentLocale === 'zh-CN' ? '#fff' : '#333')
            .onClick(() => {
              this.currentLocale = 'zh-CN'
            })
          
          Button('English')
            .fontSize(14)
            .backgroundColor(this.currentLocale === 'en-US' ? '#1890ff' : '#f0f0f0')
            .fontColor(this.currentLocale === 'en-US' ? '#fff' : '#333')
            .margin({ left: 12 })
            .onClick(() => {
              this.currentLocale = 'en-US'
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ bottom: 20 })
        
        // 文章列表
        List({ space: 16 }) {
          ForEach(this.articles, (article: Article) => {
            ListItem() {
              this.ArticleCard(article)
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding(20)
    }
    .title('博客')
    .titleMode(NavigationTitleMode.Mini)
  }
  
  @Builder
  ArticleCard(article: Article) {
    Column({ space: 12 }) {
      // 标题（实际项目中从资源文件加载）
      Text(article.titleKey)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      // 元信息
      Row() {
        Text(article.author)
          .fontSize(14)
          .fontColor('#666')
        
        Text('·')
          .fontSize(14)
          .fontColor('#ccc')
          .margin({ left: 8, right: 8 })
        
        Text(this.formatDate(article.publishDate))
          .fontSize(14)
          .fontColor('#666')
        
        Text('·')
          .fontSize(14)
          .fontColor('#ccc')
          .margin({ left: 8, right: 8 })
        
        Text(`${this.formatNumber(article.views)} 阅读`)
          .fontSize(14)
          .fontColor('#666')
      }
      
      // 摘要（实际项目中从资源文件加载）
      Text(article.contentKey)
        .fontSize(14)
        .fontColor('#666')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#0000001A', offsetY: 2 })
    .alignItems(HorizontalAlign.Start)
  }
  
  formatDate(date: Date): string {
    const dateFormat = new intl.DateTimeFormat(this.currentLocale, {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
    return dateFormat.format(date)
  }
  
  formatNumber(num: number): string {
    const numberFormat = new intl.NumberFormat(this.currentLocale)
    return numberFormat.format(num)
  }
}
```

---

## 最佳实践

### 1. 资源组织
- ✅ 所有可见文本都使用资源文件
- ✅ 资源文件按语言分类管理
- ✅ 使用语义化的资源名称
- ✅ 提供默认 base 资源作为后备

### 2. 代码规范
- ✅ 使用 `$r()` 引用资源
- ✅ 避免硬编码文本
- ✅ 使用 Intl API 格式化日期、数字
- ✅ 考虑文本长度变化对布局的影响

### 3. 布局适配
- ✅ 使用 `start/end` 代替 `left/right`
- ✅ 支持 RTL 布局
- ✅ 测试不同语言下的UI表现
- ✅ 预留足够的空间容纳长文本

### 4. 性能优化
- ✅ 缓存常用的格式化对象
- ✅ 避免频繁创建 Intl 对象
- ✅ 异步加载大量本地化资源
- ✅ 按需加载语言包

### 5. 测试检查
- ✅ 测试所有支持的语言
- ✅ 检查文本截断和换行
- ✅ 验证日期时间格式
- ✅ 测试 RTL 布局

---

**完整代码可直接复制使用！** 🌍


