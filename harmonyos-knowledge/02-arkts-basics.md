# ArkTS 基础语法

## 变量和类型

### 基本类型

```typescript
// 数字类型
let count: number = 100
let price: number = 99.99
let hex: number = 0xff

// 字符串类型
let name: string = "张三"
let message: string = `Hello, ${name}!` // 模板字符串

// 布尔类型
let isActive: boolean = true
let isCompleted: boolean = false

// 数组类型
let numbers: number[] = [1, 2, 3, 4, 5]
let names: Array<string> = ["张三", "李四"]

// 元组
let user: [string, number] = ["张三", 25]

// 枚举
enum Color {
  Red,
  Green,
  Blue
}
let selectedColor: Color = Color.Red

// Any 类型（尽量避免使用）
let data: any = "可以是任何类型"
data = 123
data = true
```

### 对象和接口

```typescript
// 接口定义
interface User {
  id: number
  name: string
  email: string
  age?: number        // 可选属性
  readonly createTime: Date  // 只读属性
}

// 使用接口
let user: User = {
  id: 1,
  name: "张三",
  email: "zhangsan@example.com",
  createTime: new Date()
}

// 类型别名
type ID = number | string

let userId: ID = 123
userId = "user_123"

// 联合类型
let value: string | number | boolean
value = "text"
value = 100
value = true

// 字面量类型
type Status = 'pending' | 'success' | 'error'
let currentStatus: Status = 'pending'
```

## 类和继承

### 基础类

```typescript
class Person {
  // 属性
  name: string
  private age: number
  protected gender: string
  readonly id: number

  // 构造函数
  constructor(name: string, age: number, gender: string) {
    this.name = name
    this.age = age
    this.gender = gender
    this.id = Date.now()
  }

  // 方法
  introduce(): string {
    return `我是${this.name}，今年${this.age}岁`
  }

  // Getter
  get info(): string {
    return `${this.name} (${this.age}岁)`
  }

  // Setter
  set updateAge(newAge: number) {
    if (newAge > 0 && newAge < 150) {
      this.age = newAge
    }
  }

  // 静态方法
  static create(name: string, age: number): Person {
    return new Person(name, age, '未知')
  }
}

// 使用类
let person = new Person("张三", 25, "男")
console.log(person.introduce())
console.log(person.info)
person.updateAge = 26
```

### 继承

```typescript
class Student extends Person {
  school: string
  grade: number

  constructor(name: string, age: number, gender: string, school: string, grade: number) {
    super(name, age, gender)  // 调用父类构造函数
    this.school = school
    this.grade = grade
  }

  // 重写方法
  introduce(): string {
    return `${super.introduce()}，就读于${this.school}${this.grade}年级`
  }

  // 新方法
  study(subject: string): void {
    console.log(`${this.name}正在学习${subject}`)
  }
}

let student = new Student("李四", 18, "女", "北京大学", 1)
console.log(student.introduce())
student.study("数学")
```

### 抽象类

```typescript
abstract class Shape {
  abstract area(): number
  abstract perimeter(): number

  describe(): string {
    return `面积: ${this.area()}, 周长: ${this.perimeter()}`
  }
}

class Rectangle extends Shape {
  constructor(private width: number, private height: number) {
    super()
  }

  area(): number {
    return this.width * this.height
  }

  perimeter(): number {
    return 2 * (this.width + this.height)
  }
}

let rect = new Rectangle(10, 20)
console.log(rect.describe())
```

## 函数

### 函数定义

```typescript
// 普通函数
function add(a: number, b: number): number {
  return a + b
}

// 箭头函数
const multiply = (a: number, b: number): number => {
  return a * b
}

// 简写箭头函数
const square = (n: number): number => n * n

// 可选参数
function greet(name: string, greeting?: string): string {
  return greeting ? `${greeting}, ${name}!` : `Hello, ${name}!`
}

// 默认参数
function createUser(name: string, age: number = 18): User {
  return { id: Date.now(), name, age }
}

// 剩余参数
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0)
}

console.log(sum(1, 2, 3, 4, 5)) // 15

// 函数重载
function format(value: string): string
function format(value: number): string
function format(value: boolean): string
function format(value: any): string {
  if (typeof value === 'string') {
    return value.toUpperCase()
  } else if (typeof value === 'number') {
    return value.toFixed(2)
  } else {
    return value ? 'YES' : 'NO'
  }
}
```

### 高阶函数

```typescript
// 函数作为参数
function processArray(arr: number[], callback: (n: number) => number): number[] {
  return arr.map(callback)
}

let numbers = [1, 2, 3, 4, 5]
let doubled = processArray(numbers, n => n * 2)

// 函数作为返回值
function multiplier(factor: number): (n: number) => number {
  return (n: number) => n * factor
}

let double = multiplier(2)
let triple = multiplier(3)

console.log(double(5))  // 10
console.log(triple(5))  // 15

// 闭包
function createCounter() {
  let count = 0
  return {
    increment: () => ++count,
    decrement: () => --count,
    getCount: () => count
  }
}

let counter = createCounter()
counter.increment()
counter.increment()
console.log(counter.getCount())  // 2
```

## 异步编程

### Promise

```typescript
// 创建 Promise
function fetchData(url: string): Promise<string> {
  return new Promise((resolve, reject) => {
    // 模拟异步操作
    setTimeout(() => {
      if (url) {
        resolve(`数据来自: ${url}`)
      } else {
        reject(new Error('URL 不能为空'))
      }
    }, 1000)
  })
}

// 使用 Promise
fetchData('https://api.example.com/data')
  .then(data => {
    console.log('成功:', data)
    return data.toUpperCase()
  })
  .then(upperData => {
    console.log('转换后:', upperData)
  })
  .catch(error => {
    console.error('错误:', error.message)
  })
  .finally(() => {
    console.log('请求完成')
  })

// Promise.all - 并行执行
Promise.all([
  fetchData('url1'),
  fetchData('url2'),
  fetchData('url3')
]).then(results => {
  console.log('所有请求完成:', results)
})

// Promise.race - 竞速
Promise.race([
  fetchData('url1'),
  fetchData('url2')
]).then(result => {
  console.log('最快的结果:', result)
})
```

### Async/Await

```typescript
// 异步函数
async function loadUserData(userId: number): Promise<User> {
  try {
    // 串行执行
    const user = await fetchUser(userId)
    const profile = await fetchProfile(user.id)
    const posts = await fetchPosts(user.id)
    
    return {
      ...user,
      profile,
      posts
    }
  } catch (error) {
    console.error('加载用户数据失败:', error)
    throw error
  }
}

// 并行执行
async function loadMultipleUsers(userIds: number[]): Promise<User[]> {
  const promises = userIds.map(id => fetchUser(id))
  return await Promise.all(promises)
}

// 使用 async 函数
async function main() {
  try {
    const user = await loadUserData(123)
    console.log('用户数据:', user)
    
    const users = await loadMultipleUsers([1, 2, 3])
    console.log('多个用户:', users)
  } catch (error) {
    console.error('错误:', error)
  }
}

// 错误处理
async function safeRequest<T>(request: () => Promise<T>): Promise<T | null> {
  try {
    return await request()
  } catch (error) {
    console.error('请求失败:', error)
    return null
  }
}
```

## 泛型

### 泛型函数

```typescript
// 基础泛型
function identity<T>(value: T): T {
  return value
}

let num = identity<number>(123)
let str = identity<string>("hello")

// 泛型数组
function getFirstElement<T>(arr: T[]): T | undefined {
  return arr[0]
}

let firstNumber = getFirstElement([1, 2, 3])
let firstName = getFirstElement(["张三", "李四"])

// 多个泛型参数
function pair<K, V>(key: K, value: V): [K, V] {
  return [key, value]
}

let userPair = pair<string, number>("age", 25)

// 泛型约束
interface HasLength {
  length: number
}

function logLength<T extends HasLength>(item: T): void {
  console.log(`长度: ${item.length}`)
}

logLength("hello")      // OK
logLength([1, 2, 3])    // OK
logLength({ length: 5 }) // OK
// logLength(123)       // Error: number 没有 length 属性
```

### 泛型类

```typescript
class Stack<T> {
  private items: T[] = []

  push(item: T): void {
    this.items.push(item)
  }

  pop(): T | undefined {
    return this.items.pop()
  }

  peek(): T | undefined {
    return this.items[this.items.length - 1]
  }

  isEmpty(): boolean {
    return this.items.length === 0
  }

  size(): number {
    return this.items.length
  }

  clear(): void {
    this.items = []
  }
}

// 使用泛型类
let numberStack = new Stack<number>()
numberStack.push(1)
numberStack.push(2)
numberStack.push(3)
console.log(numberStack.pop()) // 3

let stringStack = new Stack<string>()
stringStack.push("a")
stringStack.push("b")
console.log(stringStack.pop()) // "b"
```

### 泛型接口

```typescript
interface Repository<T> {
  getAll(): Promise<T[]>
  getById(id: number): Promise<T | null>
  create(item: T): Promise<T>
  update(id: number, item: T): Promise<T>
  delete(id: number): Promise<boolean>
}

class UserRepository implements Repository<User> {
  async getAll(): Promise<User[]> {
    // 实现逻辑
    return []
  }

  async getById(id: number): Promise<User | null> {
    // 实现逻辑
    return null
  }

  async create(user: User): Promise<User> {
    // 实现逻辑
    return user
  }

  async update(id: number, user: User): Promise<User> {
    // 实现逻辑
    return user
  }

  async delete(id: number): Promise<boolean> {
    // 实现逻辑
    return true
  }
}
```

## 模块化

### 导出

```typescript
// named-exports.ets

// 导出变量
export const API_URL = 'https://api.example.com'

// 导出接口
export interface Product {
  id: number
  name: string
  price: number
}

// 导出类
export class ProductService {
  getAll(): Product[] {
    return []
  }
}

// 导出函数
export function formatPrice(price: number): string {
  return `¥${price.toFixed(2)}`
}

// 默认导出
export default class ShoppingCart {
  private items: Product[] = []

  addItem(product: Product): void {
    this.items.push(product)
  }

  getTotal(): number {
    return this.items.reduce((total, item) => total + item.price, 0)
  }
}
```

### 导入

```typescript
// 导入命名导出
import { Product, ProductService, formatPrice, API_URL } from './named-exports'

// 导入默认导出
import ShoppingCart from './named-exports'

// 导入全部
import * as ProductModule from './named-exports'

// 使用
let service = new ProductService()
let cart = new ShoppingCart()
let price = formatPrice(99.99)
console.log(ProductModule.API_URL)

// 重命名导入
import { ProductService as PS } from './named-exports'
let productService = new PS()
```

## 装饰器

### 类装饰器

```typescript
// 装饰器工厂
function Component(name: string) {
  return function(target: any) {
    target.prototype.componentName = name
    console.log(`组件 ${name} 已注册`)
  }
}

@Component('MyCard')
class CardComponent {
  render() {
    return 'Card content'
  }
}

let card = new CardComponent()
console.log(card.componentName) // 'MyCard'
```

### 方法装饰器

```typescript
function Log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value

  descriptor.value = function(...args: any[]) {
    console.log(`调用方法 ${propertyKey}，参数:`, args)
    const result = originalMethod.apply(this, args)
    console.log(`方法 ${propertyKey} 返回:`, result)
    return result
  }

  return descriptor
}

class Calculator {
  @Log
  add(a: number, b: number): number {
    return a + b
  }
}

let calc = new Calculator()
calc.add(5, 3)
// 输出:
// 调用方法 add，参数: [5, 3]
// 方法 add 返回: 8
```

### 属性装饰器

```typescript
function MinValue(min: number) {
  return function(target: any, propertyKey: string) {
    let value = target[propertyKey]

    const getter = () => value
    const setter = (newVal: number) => {
      if (newVal < min) {
        throw new Error(`${propertyKey} 不能小于 ${min}`)
      }
      value = newVal
    }

    Object.defineProperty(target, propertyKey, {
      get: getter,
      set: setter,
      enumerable: true,
      configurable: true
    })
  }
}

class Product {
  @MinValue(0)
  price: number = 0

  @MinValue(1)
  quantity: number = 1
}

let product = new Product()
product.price = 99   // OK
// product.price = -10  // Error: price 不能小于 0
```

## 实用工具类型

```typescript
// Partial - 所有属性可选
interface User {
  id: number
  name: string
  email: string
}

type PartialUser = Partial<User>
// 等价于:
// {
//   id?: number
//   name?: string
//   email?: string
// }

// Required - 所有属性必选
type RequiredUser = Required<PartialUser>

// Readonly - 所有属性只读
type ReadonlyUser = Readonly<User>

// Pick - 选取部分属性
type UserPreview = Pick<User, 'id' | 'name'>
// { id: number, name: string }

// Omit - 排除部分属性
type UserWithoutEmail = Omit<User, 'email'>
// { id: number, name: string }

// Record - 创建对象类型
type UserRoles = Record<string, string[]>
// { [key: string]: string[] }

let roles: UserRoles = {
  'admin': ['read', 'write', 'delete'],
  'user': ['read']
}
```

## 下一步

继续学习 [组件库完整参考](03-component-library.md)

