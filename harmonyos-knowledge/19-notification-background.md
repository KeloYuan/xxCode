# 通知和后台任务指南

> 本文档详细介绍 HarmonyOS Next 中的通知系统和后台任务处理，包括本地通知、推送通知、后台任务等。

---

## 目录
- [本地通知](#本地通知)
- [通知样式](#通知样式)
- [通知操作](#通知操作)
- [通知管理](#通知管理)
- [后台任务](#后台任务)
- [定时任务](#定时任务)
- [数据同步](#数据同步)
- [完整应用示例](#完整应用示例)

---

## 本地通知

### 基础通知

```typescript
import notificationManager from '@ohos.notificationManager'
import wantAgent from '@ohos.app.ability.wantAgent'

export class NotificationService {
  // 发送简单通知
  static async sendBasicNotification(title: string, text: string): Promise<void> {
    try {
      // 构建通知内容
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: text
          }
        }
      }
      
      // 发布通知
      await notificationManager.publish(notificationRequest)
      console.info('Notification published successfully')
    } catch (err) {
      console.error(`Failed to publish notification: ${err}`)
    }
  }
  
  // 发送长文本通知
  static async sendLongTextNotification(title: string, text: string, longText: string): Promise<void> {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT,
          longText: {
            title: title,
            text: text,
            longText: longText,
            briefText: text
          }
        }
      }
      
      await notificationManager.publish(notificationRequest)
    } catch (err) {
      console.error(`Failed to publish long text notification: ${err}`)
    }
  }
}

// 使用示例
@Entry
@Component
struct NotificationExample {
  build() {
    Column() {
      Button('发送基础通知')
        .onClick(() => {
          NotificationService.sendBasicNotification(
            '新消息',
            '您有一条新消息'
          )
        })
        .margin({ bottom: 12 })
      
      Button('发送长文本通知')
        .onClick(() => {
          NotificationService.sendLongTextNotification(
            '文章更新',
            '您订阅的文章已更新',
            '这是一篇关于 HarmonyOS 开发的详细文章，包含了大量的代码示例和最佳实践...'
          )
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
}
```

---

## 通知样式

### 多行文本通知

```typescript
export class NotificationService {
  // 多行文本通知
  static async sendMultiLineNotification(title: string, lines: string[]): Promise<void> {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_MULTILINE,
          multiLine: {
            title: title,
            text: lines[0],
            briefText: `${lines.length} 条消息`,
            lines: lines
          }
        }
      }
      
      await notificationManager.publish(notificationRequest)
    } catch (err) {
      console.error(`Failed to publish multiline notification: ${err}`)
    }
  }
}

// 使用示例
Button('发送多行通知')
  .onClick(() => {
    NotificationService.sendMultiLineNotification(
      '未读消息',
      [
        '张三: 你好吗？',
        '李四: 明天见面吗？',
        '王五: 项目进度如何？'
      ]
    )
  })
```

### 图片通知

```typescript
export class NotificationService {
  // 图片通知
  static async sendPictureNotification(
    title: string,
    text: string,
    picture: image.PixelMap
  ): Promise<void> {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_PICTURE,
          picture: {
            title: title,
            text: text,
            briefText: text,
            picture: picture
          }
        }
      }
      
      await notificationManager.publish(notificationRequest)
    } catch (err) {
      console.error(`Failed to publish picture notification: ${err}`)
    }
  }
}
```

### 进度条通知

```typescript
export class NotificationService {
  private static progressNotificationId: number = 1001
  
  // 发送进度通知
  static async sendProgressNotification(
    title: string,
    progress: number,
    maxProgress: number = 100
  ): Promise<void> {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: this.progressNotificationId,
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: `${progress}%`
          }
        },
        // 添加进度条
        template: {
          name: 'downloadTemplate',
          data: {
            progressValue: progress,
            progressMaxValue: maxProgress
          }
        }
      }
      
      await notificationManager.publish(notificationRequest)
    } catch (err) {
      console.error(`Failed to publish progress notification: ${err}`)
    }
  }
  
  // 更新进度
  static async updateProgress(progress: number): Promise<void> {
    await this.sendProgressNotification('下载中', progress)
    
    // 下载完成时移除通知
    if (progress >= 100) {
      setTimeout(() => {
        this.cancelNotification(this.progressNotificationId)
      }, 2000)
    }
  }
  
  // 取消通知
  static async cancelNotification(id: number): Promise<void> {
    try {
      await notificationManager.cancel(id)
      console.info(`Notification ${id} cancelled`)
    } catch (err) {
      console.error(`Failed to cancel notification: ${err}`)
    }
  }
}

// 使用示例 - 模拟下载
@Entry
@Component
struct ProgressNotificationExample {
  private timer: number = -1
  @State progress: number = 0
  
  startDownload() {
    this.progress = 0
    this.timer = setInterval(() => {
      this.progress += 10
      NotificationService.updateProgress(this.progress)
      
      if (this.progress >= 100) {
        clearInterval(this.timer)
      }
    }, 500)
  }
  
  build() {
    Column() {
      Button('开始下载')
        .onClick(() => {
          this.startDownload()
        })
      
      Text(`进度: ${this.progress}%`)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## 通知操作

### 带点击操作的通知

```typescript
import wantAgent from '@ohos.app.ability.wantAgent'
import type Want from '@ohos.app.ability.Want'

export class NotificationService {
  // 发送可点击的通知
  static async sendClickableNotification(
    title: string,
    text: string,
    targetPage: string
  ): Promise<void> {
    try {
      // 创建 Want 对象
      const wantInfo: Want = {
        bundleName: 'com.example.myapp',
        abilityName: 'EntryAbility',
        parameters: {
          page: targetPage
        }
      }
      
      // 创建 WantAgent
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [wantInfo],
        requestCode: 0,
        operationType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      }
      
      const agent = await wantAgent.getWantAgent(wantAgentInfo)
      
      // 创建通知
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: text
          }
        },
        wantAgent: agent
      }
      
      await notificationManager.publish(notificationRequest)
    } catch (err) {
      console.error(`Failed to publish clickable notification: ${err}`)
    }
  }
}
```

### 带操作按钮的通知

```typescript
export class NotificationService {
  // 发送带操作按钮的通知
  static async sendActionNotification(
    title: string,
    text: string
  ): Promise<void> {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: text
          }
        },
        // 添加操作按钮
        actionButtons: [
          {
            title: '接受',
            wantAgent: await this.createActionWantAgent('accept')
          },
          {
            title: '拒绝',
            wantAgent: await this.createActionWantAgent('reject')
          }
        ]
      }
      
      await notificationManager.publish(notificationRequest)
    } catch (err) {
      console.error(`Failed to publish action notification: ${err}`)
    }
  }
  
  private static async createActionWantAgent(action: string): Promise<any> {
    const wantInfo: Want = {
      bundleName: 'com.example.myapp',
      abilityName: 'EntryAbility',
      parameters: {
        action: action
      }
    }
    
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [wantInfo],
      requestCode: 0,
      operationType: wantAgent.OperationType.START_ABILITY,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }
    
    return await wantAgent.getWantAgent(wantAgentInfo)
  }
}
```

---

## 通知管理

### 通知权限请求

```typescript
import notificationManager from '@ohos.notificationManager'
import abilityAccessCtrl from '@ohos.abilityAccessCtrl'

export class NotificationPermission {
  // 检查通知权限
  static async checkPermission(context: Context): Promise<boolean> {
    try {
      const isEnabled = await notificationManager.isNotificationEnabled()
      return isEnabled
    } catch (err) {
      console.error(`Failed to check notification permission: ${err}`)
      return false
    }
  }
  
  // 请求通知权限
  static async requestPermission(context: Context): Promise<boolean> {
    try {
      // 先检查是否已授权
      const isEnabled = await this.checkPermission(context)
      if (isEnabled) {
        return true
      }
      
      // 请求权限
      const atManager = abilityAccessCtrl.createAtManager()
      const result = await atManager.requestPermissionsFromUser(
        context,
        ['ohos.permission.NOTIFICATION_CONTROLLER']
      )
      
      return result.authResults[0] === 0
    } catch (err) {
      console.error(`Failed to request notification permission: ${err}`)
      return false
    }
  }
  
  // 打开通知设置页面
  static async openNotificationSettings(context: Context): Promise<void> {
    try {
      await notificationManager.requestEnableNotification(context)
    } catch (err) {
      console.error(`Failed to open notification settings: ${err}`)
    }
  }
}

// 使用示例
@Entry
@Component
struct NotificationPermissionExample {
  @State hasPermission: boolean = false
  
  async aboutToAppear() {
    this.hasPermission = await NotificationPermission.checkPermission(getContext(this))
  }
  
  build() {
    Column() {
      Text(this.hasPermission ? '已授权通知权限' : '未授权通知权限')
        .fontSize(16)
        .margin({ bottom: 20 })
      
      if (!this.hasPermission) {
        Button('请求通知权限')
          .onClick(async () => {
            const granted = await NotificationPermission.requestPermission(getContext(this))
            this.hasPermission = granted
          })
          .margin({ bottom: 12 })
        
        Button('打开设置')
          .onClick(() => {
            NotificationPermission.openNotificationSettings(getContext(this))
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
}
```

### 取消和管理通知

```typescript
export class NotificationService {
  // 取消指定通知
  static async cancelNotification(id: number): Promise<void> {
    try {
      await notificationManager.cancel(id)
      console.info(`Notification ${id} cancelled`)
    } catch (err) {
      console.error(`Failed to cancel notification: ${err}`)
    }
  }
  
  // 取消所有通知
  static async cancelAllNotifications(): Promise<void> {
    try {
      await notificationManager.cancelAll()
      console.info('All notifications cancelled')
    } catch (err) {
      console.error(`Failed to cancel all notifications: ${err}`)
    }
  }
  
  // 获取活动通知
  static async getActiveNotifications(): Promise<notificationManager.NotificationRequest[]> {
    try {
      const notifications = await notificationManager.getActiveNotifications()
      console.info(`Active notifications: ${notifications.length}`)
      return notifications
    } catch (err) {
      console.error(`Failed to get active notifications: ${err}`)
      return []
    }
  }
}
```

---

## 后台任务

### 短时任务

```typescript
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'

export class BackgroundTaskService {
  private static requestId: number = 0
  
  // 申请短时任务
  static async requestBackgroundTask(context: Context, reason: string): Promise<void> {
    try {
      const bgMode = backgroundTaskManager.BackgroundMode.DATA_TRANSFER
      
      await backgroundTaskManager.requestSuspendDelay(reason, () => {
        // 任务即将超时的回调
        console.warn('Background task is about to expire')
        this.cancelBackgroundTask()
      })
      
      console.info('Background task requested')
    } catch (err) {
      console.error(`Failed to request background task: ${err}`)
    }
  }
  
  // 取消短时任务
  static cancelBackgroundTask(): void {
    try {
      backgroundTaskManager.cancelSuspendDelay(this.requestId)
      console.info('Background task cancelled')
    } catch (err) {
      console.error(`Failed to cancel background task: ${err}`)
    }
  }
}

// 使用示例
@Entry
@Component
struct BackgroundTaskExample {
  async performBackgroundWork() {
    // 申请后台任务
    await BackgroundTaskService.requestBackgroundTask(
      getContext(this),
      '数据同步'
    )
    
    try {
      // 执行耗时操作
      await this.syncData()
    } finally {
      // 完成后取消后台任务
      BackgroundTaskService.cancelBackgroundTask()
    }
  }
  
  async syncData(): Promise<void> {
    // 模拟数据同步
    return new Promise((resolve) => {
      setTimeout(() => {
        console.info('Data synced')
        resolve()
      }, 5000)
    })
  }
  
  build() {
    Column() {
      Button('开始后台任务')
        .onClick(() => {
          this.performBackgroundWork()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 长时任务

```typescript
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import wantAgent from '@ohos.app.ability.wantAgent'

export class LongRunningTaskService {
  // 开始长时任务
  static async startLongRunningTask(
    context: Context,
    type: backgroundTaskManager.BackgroundMode
  ): Promise<void> {
    try {
      // 创建 WantAgent 用于前台通知
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [{
          bundleName: 'com.example.myapp',
          abilityName: 'EntryAbility'
        }],
        requestCode: 0,
        operationType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      }
      
      const agent = await wantAgent.getWantAgent(wantAgentInfo)
      
      // 开始长时任务
      await backgroundTaskManager.startBackgroundRunning(context, type, agent)
      console.info('Long running task started')
    } catch (err) {
      console.error(`Failed to start long running task: ${err}`)
    }
  }
  
  // 停止长时任务
  static async stopLongRunningTask(context: Context): Promise<void> {
    try {
      await backgroundTaskManager.stopBackgroundRunning(context)
      console.info('Long running task stopped')
    } catch (err) {
      console.error(`Failed to stop long running task: ${err}`)
    }
  }
}

// 使用示例 - 音乐播放器
@Entry
@Component
struct MusicPlayerExample {
  @State isPlaying: boolean = false
  
  async startPlaying() {
    // 开始音乐播放长时任务
    await LongRunningTaskService.startLongRunningTask(
      getContext(this),
      backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK
    )
    
    this.isPlaying = true
    // 开始播放音乐...
  }
  
  async stopPlaying() {
    // 停止长时任务
    await LongRunningTaskService.stopLongRunningTask(getContext(this))
    
    this.isPlaying = false
    // 停止播放音乐...
  }
  
  build() {
    Column() {
      Button(this.isPlaying ? '停止播放' : '开始播放')
        .onClick(() => {
          if (this.isPlaying) {
            this.stopPlaying()
          } else {
            this.startPlaying()
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

---

## 定时任务

### WorkScheduler 定时任务

```typescript
import workScheduler from '@ohos.resourceschedule.workScheduler'

export class ScheduledTaskService {
  // 注册定时任务
  static registerTask(taskId: number, interval: number): void {
    try {
      const workInfo: workScheduler.WorkInfo = {
        workId: taskId,
        networkType: workScheduler.NetworkType.NETWORK_TYPE_ANY,
        chargerType: workScheduler.ChargingType.CHARGING_PLUGGED_ANY,
        batteryLevel: 20,
        batteryStatus: workScheduler.BatteryStatus.BATTERY_STATUS_LOW,
        storageLevel: workScheduler.StorageLevel.STORAGE_LEVEL_LOW,
        isRepeat: true,
        repeatCycleTime: interval,
        isPersisted: true
      }
      
      workScheduler.startWork(workInfo)
      console.info(`Scheduled task ${taskId} registered`)
    } catch (err) {
      console.error(`Failed to register scheduled task: ${err}`)
    }
  }
  
  // 取消定时任务
  static cancelTask(taskId: number): void {
    try {
      workScheduler.stopWork(workInfo, false)
      console.info(`Scheduled task ${taskId} cancelled`)
    } catch (err) {
      console.error(`Failed to cancel scheduled task: ${err}`)
    }
  }
}
```

---

## 完整应用示例

### 带通知的待办事项应用

```typescript
import notificationManager from '@ohos.notificationManager'
import dataPreferences from '@ohos.data.preferences'

interface TodoItem {
  id: number
  title: string
  description: string
  dueTime: number
  notified: boolean
}

@Entry
@Component
struct TodoWithNotification {
  @State todos: TodoItem[] = []
  private preferences: dataPreferences.Preferences | null = null
  private checkTimer: number = -1
  
  async aboutToAppear() {
    // 初始化
    this.preferences = await dataPreferences.getPreferences(getContext(this), 'todo_prefs')
    await this.loadTodos()
    
    // 请求通知权限
    await NotificationPermission.requestPermission(getContext(this))
    
    // 开始检查待办事项
    this.startCheckingTodos()
  }
  
  aboutToDisappear() {
    if (this.checkTimer !== -1) {
      clearInterval(this.checkTimer)
    }
  }
  
  async loadTodos() {
    const data = await this.preferences?.get('todos', '[]')
    this.todos = JSON.parse(data as string)
  }
  
  async saveTodos() {
    await this.preferences?.put('todos', JSON.stringify(this.todos))
    await this.preferences?.flush()
  }
  
  startCheckingTodos() {
    // 每分钟检查一次
    this.checkTimer = setInterval(() => {
      this.checkDueTodos()
    }, 60000)
  }
  
  checkDueTodos() {
    const now = Date.now()
    
    this.todos.forEach(todo => {
      if (!todo.notified && todo.dueTime <= now) {
        // 发送通知
        NotificationService.sendBasicNotification(
          '待办提醒',
          todo.title
        )
        
        // 标记为已通知
        todo.notified = true
      }
    })
    
    this.saveTodos()
  }
  
  addTodo(title: string, description: string, dueTime: number) {
    const newTodo: TodoItem = {
      id: Date.now(),
      title: title,
      description: description,
      dueTime: dueTime,
      notified: false
    }
    
    this.todos.push(newTodo)
    this.saveTodos()
  }
  
  build() {
    Column() {
      Text('待办事项')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      List() {
        ForEach(this.todos, (todo: TodoItem) => {
          ListItem() {
            Row() {
              Column() {
                Text(todo.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                
                Text(todo.description)
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
                
                Text(new Date(todo.dueTime).toLocaleString())
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              if (todo.notified) {
                Text('已提醒')
                  .fontSize(12)
                  .fontColor('#52c41a')
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
          }
          .margin({ bottom: 8 })
        })
      }
      .layoutWeight(1)
      
      Button('添加待办')
        .onClick(() => {
          // 添加一个1分钟后到期的待办
          const dueTime = Date.now() + 60000
          this.addTodo('测试待办', '这是一个测试待办事项', dueTime)
        })
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

---

## 最佳实践

### 1. 通知使用
- ✅ 请求通知权限前说明用途
- ✅ 合理使用通知，避免过度打扰
- ✅ 提供通知管理选项
- ✅ 使用合适的通知样式

### 2. 后台任务
- ✅ 合理使用短时任务和长时任务
- ✅ 任务完成后及时取消
- ✅ 处理任务超时情况
- ✅ 避免后台长时间占用资源

### 3. 定时任务
- ✅ 设置合理的触发条件
- ✅ 避免频繁的定时任务
- ✅ 使用持久化任务确保可靠性
- ✅ 及时取消不需要的任务

### 4. 性能考虑
- ✅ 减少通知频率
- ✅ 批量处理通知
- ✅ 优化后台任务逻辑
- ✅ 监控任务执行状态

---

**完整代码可直接复制使用！** 🚀

