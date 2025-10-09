# 状态管理完整指南

## @State - 组件内部状态

### 基本用法

```typescript
@Entry
@Component
struct StateExample {
  @State count: number = 0
  @State message: string = 'Hello'
  @State isVisible: boolean = true

  build() {
    Column({ space: 20 }) {
      Text(`计数: ${this.count}`)
        .fontSize(24)

      Button('增加')
        .onClick(() => {
          this.count++  // 自动触发UI更新
        })

      TextInput({ text: this.message })
        .onChange((value: string) => {
          this.message = value
        })

      if (this.isVisible) {
        Text('可见文本')
      }

      Toggle({ type: ToggleType.Switch, isOn: this.isVisible })
        .onChange((isOn: boolean) => {
          this.isVisible = isOn
        })
    }
    .width('100%')
    .padding(20)
  }
}
```

### 数组和对象状态

```typescript
@Entry
@Component
struct ArrayStateExample {
  @State items: string[] = ['项目1', '项目2', '项目3']
  @State user: UserInfo = {
    name: '张三',
    age: 25,
    email: 'zhangsan@example.com'
  }

  build() {
    Column({ space: 20 }) {
      // 数组操作
      List() {
        ForEach(this.items, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .layoutWeight(1)
              Button('删除')
                .onClick(() => {
                  this.items.splice(index, 1)  // 触发更新
                })
            }
            .width('100%')
            .padding(10)
          }
        })
      }
      .height(200)

      Button('添加项目')
        .onClick(() => {
          this.items.push(`项目${this.items.length + 1}`)
        })

      // 对象操作
      Column({ space: 10 }) {
        Text(`姓名: ${this.user.name}`)
        Text(`年龄: ${this.user.age}`)
        Text(`邮箱: ${this.user.email}`)

        Button('修改用户信息')
          .onClick(() => {
            // 需要创建新对象才能触发更新
            this.user = {
              ...this.user,
              age: this.user.age + 1
            }
          })
      }
    }
    .width('100%')
    .padding(20)
  }
}

interface UserInfo {
  name: string
  age: number
  email: string
}
```

## @Prop 和 @Link - 父子组件通信

### @Prop - 单向传递

```typescript
@Component
struct ChildComponent {
  @Prop title: string = ''
  @Prop count: number = 0

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Text(`子组件计数: ${this.count}`)

      Button('子组件修改（不影响父组件）')
        .onClick(() => {
          this.count++  // 只修改本地副本
        })
    }
    .padding(20)
    .backgroundColor('#F5F5F5')
    .borderRadius(12)
  }
}

@Entry
@Component
struct ParentComponent {
  @State parentCount: number = 0

  build() {
    Column({ space: 20 }) {
      Text(`父组件计数: ${this.parentCount}`)
        .fontSize(20)

      Button('父组件增加')
        .onClick(() => {
          this.parentCount++
        })

      // 传递给子组件
      ChildComponent({
        title: '子组件标题',
        count: this.parentCount
      })
    }
    .width('100%')
    .padding(20)
  }
}
```

### @Link - 双向绑定

```typescript
@Component
struct CounterComponent {
  @Link count: number  // 双向绑定，无默认值

  build() {
    Row({ space: 16 }) {
      Button('-')
        .onClick(() => {
          this.count--  // 会同步到父组件
        })

      Text(this.count.toString())
        .fontSize(24)
        .width(50)
        .textAlign(TextAlign.Center)

      Button('+')
        .onClick(() => {
          this.count++  // 会同步到父组件
        })
    }
    .padding(16)
    .backgroundColor('#E6F2FF')
    .borderRadius(8)
  }
}

@Entry
@Component
struct LinkExample {
  @State totalCount: number = 0

  build() {
    Column({ space: 30 }) {
      Text(`总计数: ${this.totalCount}`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)

      // 使用 $ 传递引用
      CounterComponent({ count: $totalCount })

      // 多个组件共享同一个状态
      CounterComponent({ count: $totalCount })

      Button('重置')
        .onClick(() => {
          this.totalCount = 0
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## @Provide 和 @Consume - 跨层级传递

```typescript
@Entry
@Component
struct GrandParent {
  @Provide('theme') theme: string = 'light'
  @Provide('fontSize') fontSize: number = 16

  build() {
    Column({ space: 20 }) {
      Text('主题设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Row({ space: 16 }) {
        Button('浅色主题')
          .onClick(() => {
            this.theme = 'light'
          })
          .backgroundColor(this.theme === 'light' ? '#007DFF' : '#CCCCCC')

        Button('深色主题')
          .onClick(() => {
            this.theme = 'dark'
          })
          .backgroundColor(this.theme === 'dark' ? '#007DFF' : '#CCCCCC')
      }

      Slider({
        value: this.fontSize,
        min: 12,
        max: 24,
        step: 2
      })
        .width('80%')
        .onChange((value: number) => {
          this.fontSize = value
        })

      Text(`字体大小: ${this.fontSize}`)

      // 中间层组件
      Parent()
    }
    .width('100%')
    .padding(20)
  }
}

@Component
struct Parent {
  build() {
    Column() {
      Text('中间组件（不需要接收数据）')
        .fontSize(18)
        .margin({ top: 30, bottom: 10 })

      // 深层子组件
      Child()
    }
  }
}

@Component
struct Child {
  @Consume('theme') theme: string
  @Consume('fontSize') fontSize: number

  build() {
    Column({ space: 16 }) {
      Text('深层子组件')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Text(`当前主题: ${this.theme}`)
        .fontSize(this.fontSize)

      Text(`当前字号: ${this.fontSize}`)
        .fontSize(this.fontSize)

      Button('修改主题（影响所有层级）')
        .onClick(() => {
          this.theme = this.theme === 'light' ? 'dark' : 'light'
        })
    }
    .padding(20)
    .backgroundColor(this.theme === 'light' ? '#FFFFFF' : '#333333')
    .borderRadius(12)
  }
}
```

## @Observed 和 @ObjectLink - 复杂对象管理

```typescript
// 定义可观察的类
@Observed
class Task {
  id: number
  title: string
  completed: boolean

  constructor(id: number, title: string) {
    this.id = id
    this.title = title
    this.completed = false
  }

  toggle() {
    this.completed = !this.completed
  }
}

@Component
struct TaskItem {
  @ObjectLink task: Task

  build() {
    Row({ space: 12 }) {
      Checkbox()
        .select(this.task.completed)
        .onChange((isChecked: boolean) => {
          this.task.toggle()  // 触发UI更新
        })

      Text(this.task.title)
        .fontSize(16)
        .decoration({
          type: this.task.completed ? TextDecorationType.LineThrough : TextDecorationType.None
        })
        .layoutWeight(1)
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
  }
}

@Entry
@Component
struct TaskList {
  @State tasks: Task[] = []

  aboutToAppear() {
    this.tasks = [
      new Task(1, '完成项目报告'),
      new Task(2, '参加团队会议'),
      new Task(3, '代码审查')
    ]
  }

  build() {
    Column() {
      Text('任务列表')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      List() {
        ForEach(this.tasks, (task: Task) => {
          ListItem() {
            TaskItem({ task: task })
          }
        }, (task: Task) => task.id.toString())
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#F0F0F0' })

      Button('添加任务')
        .width('90%')
        .margin({ top: 16, bottom: 16 })
        .onClick(() => {
          this.tasks.push(new Task(
            Date.now(),
            `新任务 ${this.tasks.length + 1}`
          ))
        })
    }
    .width('100%')
    .height('100%')
  }
}
```

## @Watch - 状态监听

```typescript
@Entry
@Component
struct WatchExample {
  @State @Watch('onCountChange') count: number = 0
  @State @Watch('onNameChange') name: string = ''
  @State log: string[] = []

  // 监听count变化
  onCountChange() {
    this.log.push(`count变化为: ${this.count}`)
    if (this.count > 10) {
      console.warn('count超过10了！')
    }
  }

  // 监听name变化
  onNameChange() {
    this.log.push(`name变化为: ${this.name}`)
  }

  build() {
    Column({ space: 20 }) {
      // 计数器
      Row({ space: 16 }) {
        Button('-')
          .onClick(() => this.count--)
        Text(this.count.toString())
          .fontSize(24)
          .width(50)
          .textAlign(TextAlign.Center)
        Button('+')
          .onClick(() => this.count++)
      }

      // 输入框
      TextInput({ placeholder: '请输入姓名', text: this.name })
        .onChange((value: string) => {
          this.name = value
        })

      // 日志
      Text('变化日志:')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)

      List() {
        ForEach(this.log, (item: string) => {
          ListItem() {
            Text(item)
              .fontSize(14)
              .padding(8)
          }
        })
      }
      .height(200)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)

      Button('清空日志')
        .onClick(() => {
          this.log = []
        })
    }
    .width('100%')
    .padding(20)
  }
}
```

## AppStorage - 应用级状态

```typescript
// 初始化应用级状态
AppStorage.SetOrCreate('userName', '游客')
AppStorage.SetOrCreate('isLogin', false)
AppStorage.SetOrCreate('themeMode', 'light')

@Entry
@Component
struct LoginPage {
  @StorageLink('userName') userName: string = ''
  @StorageLink('isLogin') isLogin: boolean = false
  @State inputName: string = ''

  build() {
    Column({ space: 20 }) {
      Text('登录页面')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      if (!this.isLogin) {
        TextInput({ placeholder: '请输入用户名', text: this.inputName })
          .onChange((value: string) => {
            this.inputName = value
          })

        Button('登录')
          .width('100%')
          .onClick(() => {
            this.userName = this.inputName
            this.isLogin = true
          })
      } else {
        Text(`欢迎, ${this.userName}!`)
          .fontSize(20)

        Button('退出登录')
          .onClick(() => {
            this.userName = '游客'
            this.isLogin = false
            this.inputName = ''
          })
      }
    }
    .width('100%')
    .padding(20)
  }
}

// 其他页面可以访问相同的状态
@Entry
@Component
struct ProfilePage {
  @StorageLink('userName') userName: string = ''
  @StorageLink('isLogin') isLogin: boolean = false

  build() {
    Column({ space: 20 }) {
      Text('个人中心')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      if (this.isLogin) {
        Text(`用户: ${this.userName}`)
          .fontSize(18)
      } else {
        Text('请先登录')
          .fontSize(18)
      }
    }
    .width('100%')
    .padding(20)
  }
}
```

## LocalStorage - 页面级状态

```typescript
// 创建LocalStorage实例
let storage = new LocalStorage({
  'currentPage': 1,
  'pageSize': 20,
  'sortBy': 'date'
})

@Entry(storage)
@Component
struct PageA {
  @LocalStorageLink('currentPage') currentPage: number = 1
  @LocalStorageLink('sortBy') sortBy: string = 'date'

  build() {
    Column({ space: 20 }) {
      Text(`当前页: ${this.currentPage}`)
        .fontSize(20)

      Text(`排序方式: ${this.sortBy}`)
        .fontSize(18)

      Button('下一页')
        .onClick(() => {
          this.currentPage++
        })

      Button('切换排序')
        .onClick(() => {
          this.sortBy = this.sortBy === 'date' ? 'name' : 'date'
        })

      Button('跳转到PageB')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/PageB'
          })
        })
    }
    .width('100%')
    .padding(20)
  }
}

@Entry(storage)
@Component
struct PageB {
  @LocalStorageLink('currentPage') currentPage: number = 1
  @LocalStorageLink('sortBy') sortBy: string = 'date'

  build() {
    Column({ space: 20 }) {
      Text('Page B')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      Text(`从PageA共享的状态:`)
        .fontSize(18)

      Text(`当前页: ${this.currentPage}`)
      Text(`排序: ${this.sortBy}`)

      Button('修改页码')
        .onClick(() => {
          this.currentPage += 10
        })
    }
    .width('100%')
    .padding(20)
  }
}
```

## PersistentStorage - 持久化存储

```typescript
// 持久化到本地
PersistentStorage.PersistProp('token', '')
PersistentStorage.PersistProp('userPreferences', {})

@Entry
@Component
struct SettingsPage {
  @StorageLink('token') token: string = ''
  @State notificationEnabled: boolean = true
  @State language: string = 'zh-CN'

  aboutToAppear() {
    // 从持久化存储读取
    const prefs = AppStorage.Get('userPreferences') as any
    if (prefs) {
      this.notificationEnabled = prefs.notificationEnabled ?? true
      this.language = prefs.language ?? 'zh-CN'
    }
  }

  build() {
    Column({ space: 20 }) {
      Text('设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      // Token显示
      if (this.token) {
        Text(`Token: ${this.token.substring(0, 10)}...`)
          .fontSize(14)
      }

      // 通知开关
      Row() {
        Text('推送通知')
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.notificationEnabled })
          .onChange((isOn: boolean) => {
            this.notificationEnabled = isOn
            this.savePreferences()
          })
      }
      .width('100%')

      // 语言选择
      Row() {
        Text('语言')
          .layoutWeight(1)
        Select([
          { value: '中文' },
          { value: 'English' }
        ])
          .selected(this.language === 'zh-CN' ? 0 : 1)
          .onSelect((index: number) => {
            this.language = index === 0 ? 'zh-CN' : 'en-US'
            this.savePreferences()
          })
      }
      .width('100%')

      Button('保存设置')
        .onClick(() => {
          this.savePreferences()
        })
    }
    .width('100%')
    .padding(20)
  }

  savePreferences() {
    AppStorage.Set('userPreferences', {
      notificationEnabled: this.notificationEnabled,
      language: this.language
    })
    PersistentStorage.PersistProp('userPreferences', {
      notificationEnabled: this.notificationEnabled,
      language: this.language
    })
  }
}
```

## 状态管理最佳实践

### 1. 状态最小化原则

```typescript
// ❌ 不好的做法 - 冗余状态
@State items: Item[] = []
@State itemCount: number = 0  // 可以从items.length计算得出
@State hasItems: boolean = false  // 可以从items.length > 0计算得出

// ✅ 好的做法 - 最小化状态
@State items: Item[] = []

get itemCount(): number {
  return this.items.length
}

get hasItems(): boolean {
  return this.items.length > 0
}
```

### 2. 合理拆分组件

```typescript
// ✅ 好的做法 - 将频繁变化的部分独立成组件
@Component
struct CounterDisplay {
  @Prop count: number

  build() {
    Text(`计数: ${this.count}`)
      .fontSize(24)
  }
}

@Entry
@Component
struct App {
  @State count: number = 0
  @State otherData: string = 'static'

  build() {
    Column() {
      // 只有CounterDisplay会在count变化时重新渲染
      CounterDisplay({ count: this.count })

      Text(this.otherData)

      Button('增加')
        .onClick(() => this.count++)
    }
  }
}
```

### 3. 使用@ObjectLink处理复杂对象

```typescript
// ✅ 好的做法 - 使用@Observed和@ObjectLink
@Observed
class UserProfile {
  name: string
  avatar: string
  followers: number

  constructor(name: string, avatar: string, followers: number) {
    this.name = name
    this.avatar = avatar
    this.followers = followers
  }
}

@Component
struct ProfileCard {
  @ObjectLink profile: UserProfile

  build() {
    Column() {
      Text(this.profile.name)
      Image(this.profile.avatar)
      Text(`粉丝: ${this.profile.followers}`)
      Button('关注')
        .onClick(() => {
          this.profile.followers++  // 自动触发更新
        })
    }
  }
}
```

## 下一步

继续学习 [手势交互](13-gestures.md)

