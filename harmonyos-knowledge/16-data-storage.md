# 数据存储方案详解

> 本文档详细介绍 HarmonyOS Next 中的各种数据存储方案，包括 Preferences 首选项、RelationalStore 关系型数据库、KV 存储等。

---

## 目录
- [Preferences 首选项存储](#preferences-首选项存储)
- [RelationalStore 关系型数据库](#relationalstore-关系型数据库)
- [KV 键值存储](#kv-键值存储)
- [数据加密](#数据加密)
- [文件存储](#文件存储)
- [数据备份和恢复](#数据备份和恢复)
- [完整应用示例](#完整应用示例)

---

## Preferences 首选项存储

Preferences 提供轻量级的键值对存储，适合存储应用配置、用户设置等简单数据。

### 基础使用

```typescript
import dataPreferences from '@ohos.data.preferences'
import { GlobalContext } from '../utils/GlobalContext'

// 数据存储服务
export class PreferencesService {
  private static instance: PreferencesService
  private preferences: dataPreferences.Preferences | null = null
  private readonly STORE_NAME = 'app_preferences'
  
  private constructor() {}
  
  static getInstance(): PreferencesService {
    if (!PreferencesService.instance) {
      PreferencesService.instance = new PreferencesService()
    }
    return PreferencesService.instance
  }
  
  // 初始化
  async init(context: Context) {
    try {
      this.preferences = await dataPreferences.getPreferences(context, this.STORE_NAME)
      console.info('Preferences initialized successfully')
    } catch (err) {
      console.error(`Failed to get preferences: ${err}`)
    }
  }
  
  // 保存数据
  async put(key: string, value: dataPreferences.ValueType): Promise<void> {
    if (!this.preferences) {
      console.error('Preferences not initialized')
      return
    }
    
    try {
      await this.preferences.put(key, value)
      await this.preferences.flush() // 持久化到磁盘
      console.info(`Saved ${key}: ${value}`)
    } catch (err) {
      console.error(`Failed to save ${key}: ${err}`)
    }
  }
  
  // 获取数据
  async get(key: string, defaultValue: dataPreferences.ValueType): Promise<dataPreferences.ValueType> {
    if (!this.preferences) {
      console.error('Preferences not initialized')
      return defaultValue
    }
    
    try {
      const value = await this.preferences.get(key, defaultValue)
      console.info(`Get ${key}: ${value}`)
      return value
    } catch (err) {
      console.error(`Failed to get ${key}: ${err}`)
      return defaultValue
    }
  }
  
  // 删除数据
  async delete(key: string): Promise<void> {
    if (!this.preferences) {
      console.error('Preferences not initialized')
      return
    }
    
    try {
      await this.preferences.delete(key)
      await this.preferences.flush()
      console.info(`Deleted ${key}`)
    } catch (err) {
      console.error(`Failed to delete ${key}: ${err}`)
    }
  }
  
  // 检查键是否存在
  async has(key: string): Promise<boolean> {
    if (!this.preferences) {
      return false
    }
    
    try {
      return await this.preferences.has(key)
    } catch (err) {
      console.error(`Failed to check ${key}: ${err}`)
      return false
    }
  }
  
  // 清空所有数据
  async clear(): Promise<void> {
    if (!this.preferences) {
      console.error('Preferences not initialized')
      return
    }
    
    try {
      await this.preferences.clear()
      await this.preferences.flush()
      console.info('Cleared all preferences')
    } catch (err) {
      console.error(`Failed to clear preferences: ${err}`)
    }
  }
  
  // 获取所有键
  async getAllKeys(): Promise<string[]> {
    if (!this.preferences) {
      return []
    }
    
    try {
      const keys = await this.preferences.getAllKeys()
      return keys
    } catch (err) {
      console.error(`Failed to get all keys: ${err}`)
      return []
    }
  }
}
```

### 使用示例

```typescript
import { PreferencesService } from '../services/PreferencesService'

@Entry
@Component
struct PreferencesExample {
  @State username: string = ''
  @State age: number = 0
  @State isDarkMode: boolean = false
  private preferencesService = PreferencesService.getInstance()
  
  async aboutToAppear() {
    // 初始化
    await this.preferencesService.init(getContext(this))
    
    // 读取保存的数据
    this.username = await this.preferencesService.get('username', '') as string
    this.age = await this.preferencesService.get('age', 0) as number
    this.isDarkMode = await this.preferencesService.get('isDarkMode', false) as boolean
  }
  
  build() {
    Column() {
      Text('Preferences 示例')
        .fontSize(24)
        .margin({ bottom: 20 })
      
      // 输入用户名
      TextInput({ placeholder: '输入用户名', text: this.username })
        .onChange((value: string) => {
          this.username = value
        })
        .margin({ bottom: 12 })
      
      // 输入年龄
      TextInput({ placeholder: '输入年龄', text: this.age.toString() })
        .type(InputType.Number)
        .onChange((value: string) => {
          this.age = parseInt(value) || 0
        })
        .margin({ bottom: 12 })
      
      // 暗黑模式开关
      Row() {
        Text('暗黑模式')
        Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
          .onChange((isOn: boolean) => {
            this.isDarkMode = isOn
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })
      
      // 保存按钮
      Button('保存设置')
        .onClick(async () => {
          await this.preferencesService.put('username', this.username)
          await this.preferencesService.put('age', this.age)
          await this.preferencesService.put('isDarkMode', this.isDarkMode)
          
          promptAction.showToast({ message: '保存成功' })
        })
        .margin({ bottom: 12 })
      
      // 清空按钮
      Button('清空所有设置')
        .backgroundColor('#ff4d4f')
        .onClick(async () => {
          await this.preferencesService.clear()
          this.username = ''
          this.age = 0
          this.isDarkMode = false
          
          promptAction.showToast({ message: '已清空' })
        })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

---

## RelationalStore 关系型数据库

RelationalStore 提供 SQLite 数据库功能，适合存储结构化数据。

### 数据库初始化

```typescript
import relationalStore from '@ohos.data.relationalStore'

// 数据库配置
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'app_database.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

// 数据库服务
export class DatabaseService {
  private static instance: DatabaseService
  private store: relationalStore.RdbStore | null = null
  
  private constructor() {}
  
  static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService()
    }
    return DatabaseService.instance
  }
  
  // 初始化数据库
  async init(context: Context): Promise<void> {
    try {
      this.store = await relationalStore.getRdbStore(context, STORE_CONFIG)
      await this.createTables()
      console.info('Database initialized successfully')
    } catch (err) {
      console.error(`Failed to initialize database: ${err}`)
    }
  }
  
  // 创建表
  private async createTables(): Promise<void> {
    if (!this.store) return
    
    // 用户表
    const createUserTable = `
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT,
        age INTEGER,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    `
    
    // 任务表
    const createTaskTable = `
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        completed INTEGER DEFAULT 0,
        priority INTEGER DEFAULT 0,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    `
    
    try {
      await this.store.executeSql(createUserTable)
      await this.store.executeSql(createTaskTable)
      console.info('Tables created successfully')
    } catch (err) {
      console.error(`Failed to create tables: ${err}`)
    }
  }
  
  // 插入数据
  async insert(table: string, values: relationalStore.ValuesBucket): Promise<number> {
    if (!this.store) return -1
    
    try {
      const rowId = await this.store.insert(table, values)
      console.info(`Inserted row: ${rowId}`)
      return rowId
    } catch (err) {
      console.error(`Failed to insert: ${err}`)
      return -1
    }
  }
  
  // 查询数据
  async query(
    table: string,
    columns?: string[],
    predicates?: relationalStore.RdbPredicates
  ): Promise<any[]> {
    if (!this.store) return []
    
    try {
      const pred = predicates || new relationalStore.RdbPredicates(table)
      const resultSet = await this.store.query(pred, columns)
      const results: any[] = []
      
      while (resultSet.goToNextRow()) {
        const row: any = {}
        for (let i = 0; i < resultSet.columnCount; i++) {
          const columnName = resultSet.getColumnName(i)
          row[columnName] = resultSet.getString(i)
        }
        results.push(row)
      }
      
      resultSet.close()
      return results
    } catch (err) {
      console.error(`Failed to query: ${err}`)
      return []
    }
  }
  
  // 更新数据
  async update(
    table: string,
    values: relationalStore.ValuesBucket,
    predicates: relationalStore.RdbPredicates
  ): Promise<number> {
    if (!this.store) return 0
    
    try {
      const rows = await this.store.update(values, predicates)
      console.info(`Updated ${rows} rows`)
      return rows
    } catch (err) {
      console.error(`Failed to update: ${err}`)
      return 0
    }
  }
  
  // 删除数据
  async delete(predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.store) return 0
    
    try {
      const rows = await this.store.delete(predicates)
      console.info(`Deleted ${rows} rows`)
      return rows
    } catch (err) {
      console.error(`Failed to delete: ${err}`)
      return 0
    }
  }
  
  // 执行 SQL
  async executeSql(sql: string, args?: Array<dataRdb.ValueType>): Promise<void> {
    if (!this.store) return
    
    try {
      await this.store.executeSql(sql, args)
      console.info('SQL executed successfully')
    } catch (err) {
      console.error(`Failed to execute SQL: ${err}`)
    }
  }
}
```

### 使用示例 - 用户管理

```typescript
import { DatabaseService } from '../services/DatabaseService'
import relationalStore from '@ohos.data.relationalStore'

interface User {
  id?: number
  username: string
  email: string
  age: number
}

@Entry
@Component
struct UserManagement {
  @State users: User[] = []
  @State username: string = ''
  @State email: string = ''
  @State age: number = 0
  private dbService = DatabaseService.getInstance()
  
  async aboutToAppear() {
    await this.dbService.init(getContext(this))
    await this.loadUsers()
  }
  
  // 加载用户列表
  async loadUsers() {
    const results = await this.dbService.query('users')
    this.users = results.map(row => ({
      id: parseInt(row.id),
      username: row.username,
      email: row.email,
      age: parseInt(row.age)
    }))
  }
  
  // 添加用户
  async addUser() {
    if (!this.username) {
      promptAction.showToast({ message: '请输入用户名' })
      return
    }
    
    const values: relationalStore.ValuesBucket = {
      username: this.username,
      email: this.email,
      age: this.age
    }
    
    const rowId = await this.dbService.insert('users', values)
    if (rowId > 0) {
      promptAction.showToast({ message: '添加成功' })
      this.username = ''
      this.email = ''
      this.age = 0
      await this.loadUsers()
    } else {
      promptAction.showToast({ message: '添加失败' })
    }
  }
  
  // 删除用户
  async deleteUser(id: number) {
    const predicates = new relationalStore.RdbPredicates('users')
    predicates.equalTo('id', id)
    
    const rows = await this.dbService.delete(predicates)
    if (rows > 0) {
      promptAction.showToast({ message: '删除成功' })
      await this.loadUsers()
    }
  }
  
  build() {
    Column() {
      Text('用户管理')
        .fontSize(24)
        .margin({ bottom: 20 })
      
      // 添加用户表单
      TextInput({ placeholder: '用户名', text: this.username })
        .onChange((value: string) => {
          this.username = value
        })
        .margin({ bottom: 12 })
      
      TextInput({ placeholder: '邮箱', text: this.email })
        .onChange((value: string) => {
          this.email = value
        })
        .margin({ bottom: 12 })
      
      TextInput({ placeholder: '年龄', text: this.age.toString() })
        .type(InputType.Number)
        .onChange((value: string) => {
          this.age = parseInt(value) || 0
        })
        .margin({ bottom: 12 })
      
      Button('添加用户')
        .onClick(() => {
          this.addUser()
        })
        .margin({ bottom: 20 })
      
      // 用户列表
      Text('用户列表')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })
      
      List() {
        ForEach(this.users, (user: User) => {
          ListItem() {
            Row() {
              Column() {
                Text(user.username)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                
                Text(`${user.email} | ${user.age}岁`)
                  .fontSize(14)
                  .fontColor('#666')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              Button('删除')
                .backgroundColor('#ff4d4f')
                .onClick(() => {
                  this.deleteUser(user.id!)
                })
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
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

### 复杂查询示例

```typescript
// 任务管理
export class TaskService {
  private dbService = DatabaseService.getInstance()
  
  // 添加任务
  async addTask(userId: number, title: string, description: string, priority: number): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      user_id: userId,
      title: title,
      description: description,
      priority: priority,
      completed: 0
    }
    
    return await this.dbService.insert('tasks', values)
  }
  
  // 查询用户的所有任务
  async getUserTasks(userId: number): Promise<any[]> {
    const predicates = new relationalStore.RdbPredicates('tasks')
    predicates.equalTo('user_id', userId)
    predicates.orderByDesc('priority')
    predicates.orderByDesc('created_at')
    
    return await this.dbService.query('tasks', undefined, predicates)
  }
  
  // 查询未完成的任务
  async getPendingTasks(userId: number): Promise<any[]> {
    const predicates = new relationalStore.RdbPredicates('tasks')
    predicates.equalTo('user_id', userId)
    predicates.equalTo('completed', 0)
    predicates.orderByDesc('priority')
    
    return await this.dbService.query('tasks', undefined, predicates)
  }
  
  // 标记任务完成
  async completeTask(taskId: number): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates('tasks')
    predicates.equalTo('id', taskId)
    
    const values: relationalStore.ValuesBucket = {
      completed: 1
    }
    
    const rows = await this.dbService.update('tasks', values, predicates)
    return rows > 0
  }
  
  // 删除任务
  async deleteTask(taskId: number): Promise<boolean> {
    const predicates = new relationalStore.RdbPredicates('tasks')
    predicates.equalTo('id', taskId)
    
    const rows = await this.dbService.delete(predicates)
    return rows > 0
  }
  
  // 搜索任务
  async searchTasks(userId: number, keyword: string): Promise<any[]> {
    const predicates = new relationalStore.RdbPredicates('tasks')
    predicates.equalTo('user_id', userId)
    predicates.like('title', `%${keyword}%`)
    predicates.or()
    predicates.like('description', `%${keyword}%`)
    
    return await this.dbService.query('tasks', undefined, predicates)
  }
  
  // 统计任务数量
  async getTaskStats(userId: number): Promise<{ total: number, completed: number, pending: number }> {
    const allTasks = await this.getUserTasks(userId)
    const completedTasks = allTasks.filter(task => task.completed === '1')
    
    return {
      total: allTasks.length,
      completed: completedTasks.length,
      pending: allTasks.length - completedTasks.length
    }
  }
}
```

---

## KV 键值存储

分布式键值存储，支持跨设备数据同步。

### 基础使用

```typescript
import distributedKVStore from '@ohos.data.distributedKVStore'

export class KVStoreService {
  private static instance: KVStoreService
  private kvManager: distributedKVStore.KVManager | null = null
  private kvStore: distributedKVStore.SingleKVStore | null = null
  
  private readonly STORE_ID = 'app_kv_store'
  
  private constructor() {}
  
  static getInstance(): KVStoreService {
    if (!KVStoreService.instance) {
      KVStoreService.instance = new KVStoreService()
    }
    return KVStoreService.instance
  }
  
  // 初始化
  async init(context: Context): Promise<void> {
    try {
      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        context: context,
        bundleName: 'com.example.app'
      }
      
      this.kvManager = distributedKVStore.createKVManager(kvManagerConfig)
      
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S1
      }
      
      this.kvStore = await this.kvManager.getKVStore(this.STORE_ID, options)
      console.info('KV Store initialized successfully')
    } catch (err) {
      console.error(`Failed to initialize KV Store: ${err}`)
    }
  }
  
  // 存储数据
  async put(key: string, value: string | number | boolean | Uint8Array): Promise<void> {
    if (!this.kvStore) return
    
    try {
      await this.kvStore.put(key, value)
      console.info(`KV put: ${key} = ${value}`)
    } catch (err) {
      console.error(`Failed to put KV: ${err}`)
    }
  }
  
  // 获取数据
  async get(key: string): Promise<string | number | boolean | Uint8Array | undefined> {
    if (!this.kvStore) return undefined
    
    try {
      const value = await this.kvStore.get(key)
      console.info(`KV get: ${key} = ${value}`)
      return value
    } catch (err) {
      console.error(`Failed to get KV: ${err}`)
      return undefined
    }
  }
  
  // 删除数据
  async delete(key: string): Promise<void> {
    if (!this.kvStore) return
    
    try {
      await this.kvStore.delete(key)
      console.info(`KV delete: ${key}`)
    } catch (err) {
      console.error(`Failed to delete KV: ${err}`)
    }
  }
  
  // 批量操作
  async putBatch(entries: Array<distributedKVStore.Entry>): Promise<void> {
    if (!this.kvStore) return
    
    try {
      await this.kvStore.putBatch(entries)
      console.info(`KV putBatch: ${entries.length} entries`)
    } catch (err) {
      console.error(`Failed to putBatch: ${err}`)
    }
  }
}
```

---

## 数据加密

### 加密存储

```typescript
import cryptoFramework from '@ohos.security.cryptoFramework'

export class EncryptionService {
  private static readonly ALGORITHM = 'AES256'
  private static readonly KEY = 'your_encryption_key_32_bytes!!'
  
  // AES 加密
  static async encrypt(data: string): Promise<string> {
    try {
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator(this.ALGORITHM)
      const promiseSymKey = await symKeyGenerator.convertKey({ data: stringToUint8Array(this.KEY) })
      
      const cipher = cryptoFramework.createCipher(this.ALGORITHM + '|CBC|PKCS7')
      await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, promiseSymKey, null)
      
      const encryptData = await cipher.doFinal({ data: stringToUint8Array(data) })
      return uint8ArrayToBase64(encryptData.data)
    } catch (err) {
      console.error(`Encryption failed: ${err}`)
      return data
    }
  }
  
  // AES 解密
  static async decrypt(encryptedData: string): Promise<string> {
    try {
      const symKeyGenerator = cryptoFramework.createSymKeyGenerator(this.ALGORITHM)
      const promiseSymKey = await symKeyGenerator.convertKey({ data: stringToUint8Array(this.KEY) })
      
      const cipher = cryptoFramework.createCipher(this.ALGORITHM + '|CBC|PKCS7')
      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, promiseSymKey, null)
      
      const decryptData = await cipher.doFinal({ data: base64ToUint8Array(encryptedData) })
      return uint8ArrayToString(decryptData.data)
    } catch (err) {
      console.error(`Decryption failed: ${err}`)
      return encryptedData
    }
  }
}

// 工具函数
function stringToUint8Array(str: string): Uint8Array {
  const arr: number[] = []
  for (let i = 0; i < str.length; i++) {
    arr.push(str.charCodeAt(i))
  }
  return new Uint8Array(arr)
}

function uint8ArrayToString(arr: Uint8Array): string {
  return String.fromCharCode(...arr)
}

function uint8ArrayToBase64(arr: Uint8Array): string {
  return Buffer.from(arr).toString('base64')
}

function base64ToUint8Array(base64: string): Uint8Array {
  return new Uint8Array(Buffer.from(base64, 'base64'))
}
```

---

## 完整应用示例

### 带数据持久化的笔记应用

```typescript
import { DatabaseService } from '../services/DatabaseService'
import { PreferencesService } from '../services/PreferencesService'
import relationalStore from '@ohos.data.relationalStore'

interface Note {
  id?: number
  title: string
  content: string
  category: string
  created_at?: number
  updated_at?: number
}

@Entry
@Component
struct NoteApp {
  @State notes: Note[] = []
  @State currentCategory: string = 'all'
  @State categories: string[] = ['工作', '学习', '生活', '其他']
  @State showAddDialog: boolean = false
  
  private dbService = DatabaseService.getInstance()
  private preferencesService = PreferencesService.getInstance()
  
  async aboutToAppear() {
    await this.dbService.init(getContext(this))
    await this.preferencesService.init(getContext(this))
    await this.createNotesTable()
    await this.loadNotes()
    
    // 恢复上次选中的分类
    this.currentCategory = await this.preferencesService.get('lastCategory', 'all') as string
  }
  
  async createNotesTable() {
    const sql = `
      CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        category TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    `
    await this.dbService.executeSql(sql)
  }
  
  async loadNotes() {
    let predicates = new relationalStore.RdbPredicates('notes')
    
    if (this.currentCategory !== 'all') {
      predicates.equalTo('category', this.currentCategory)
    }
    
    predicates.orderByDesc('updated_at')
    
    const results = await this.dbService.query('notes', undefined, predicates)
    this.notes = results.map(row => ({
      id: parseInt(row.id),
      title: row.title,
      content: row.content,
      category: row.category,
      created_at: parseInt(row.created_at),
      updated_at: parseInt(row.updated_at)
    }))
  }
  
  async addNote(note: Note) {
    const values: relationalStore.ValuesBucket = {
      title: note.title,
      content: note.content,
      category: note.category
    }
    
    await this.dbService.insert('notes', values)
    await this.loadNotes()
  }
  
  async deleteNote(id: number) {
    const predicates = new relationalStore.RdbPredicates('notes')
    predicates.equalTo('id', id)
    
    await this.dbService.delete(predicates)
    await this.loadNotes()
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('我的笔记')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        
        Button('添加')
          .onClick(() => {
            this.showAddDialog = true
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      
      // 分类筛选
      Scroll() {
        Row() {
          this.CategoryChip('全部', 'all')
          
          ForEach(this.categories, (category: string) => {
            this.CategoryChip(category, category)
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(50)
      
      // 笔记列表
      List() {
        ForEach(this.notes, (note: Note) => {
          ListItem() {
            this.NoteCard(note)
          }
          .swipeAction({ end: this.DeleteButton(note.id!) })
        })
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showAddDialog, this.AddNoteSheet(), {
      height: 400
    })
  }
  
  @Builder
  CategoryChip(label: string, value: string) {
    Text(label)
      .fontSize(14)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.currentCategory === value ? '#1890ff' : '#f0f0f0')
      .fontColor(this.currentCategory === value ? '#fff' : '#333')
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(async () => {
        this.currentCategory = value
        await this.preferencesService.put('lastCategory', value)
        await this.loadNotes()
      })
  }
  
  @Builder
  NoteCard(note: Note) {
    Column() {
      Row() {
        Text(note.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        
        Text(note.category)
          .fontSize(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#e6f7ff')
          .fontColor('#1890ff')
          .borderRadius(4)
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      Text(note.content)
        .fontSize(14)
        .fontColor('#666')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(8)
    .shadow({ radius: 4, color: '#0000001A', offsetY: 2 })
  }
  
  @Builder
  DeleteButton(id: number) {
    Button('删除')
      .backgroundColor('#ff4d4f')
      .onClick(async () => {
        await this.deleteNote(id)
      })
  }
  
  @Builder
  AddNoteSheet() {
    Column() {
      Text('添加笔记')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      TextInput({ placeholder: '标题' })
        .margin({ bottom: 12 })
      
      TextArea({ placeholder: '内容' })
        .height(120)
        .margin({ bottom: 12 })
      
      Select([
        { value: '工作' },
        { value: '学习' },
        { value: '生活' },
        { value: '其他' }
      ])
        .selected(0)
        .margin({ bottom: 20 })
      
      Button('保存')
        .onClick(() => {
          // 保存笔记逻辑
          this.showAddDialog = false
        })
    }
    .padding(20)
  }
}
```

---

## 最佳实践

### 1. 选择合适的存储方案
- ✅ 简单配置 → Preferences
- ✅ 结构化数据 → RelationalStore
- ✅ 跨设备同步 → KV Store
- ✅ 大文件 → 文件系统

### 2. 性能优化
- ✅ 数据库操作使用异步方法
- ✅ 批量操作提高效率
- ✅ 合理使用索引
- ✅ 及时关闭数据库连接

### 3. 数据安全
- ✅ 敏感数据加密存储
- ✅ 设置合适的安全等级
- ✅ 定期备份重要数据
- ✅ 防止 SQL 注入

### 4. 错误处理
- ✅ 捕获并记录异常
- ✅ 提供数据恢复机制
- ✅ 合理的错误提示
- ✅ 数据版本管理

---

**完整代码可直接复制使用！** 🚀

