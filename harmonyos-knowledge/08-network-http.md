# 网络请求与 HTTP

## HTTP 网络请求基础

### 1. 基础 HTTP 请求

```typescript
import http from '@ohos.net.http'

class HttpClient {
  // GET 请求
  static async get(url: string): Promise<any> {
    try {
      // 创建 HTTP 请求对象
      const httpRequest = http.createHttp()

      // 发起 GET 请求
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        readTimeout: 60000,
        connectTimeout: 60000
      })

      // 检查响应状态
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string)
        return result
      } else {
        throw new Error(`请求失败，状态码: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('GET 请求失败:', error)
      throw error
    }
  }

  // POST 请求
  static async post(url: string, data: object): Promise<any> {
    try {
      const httpRequest = http.createHttp()

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(data),
        readTimeout: 60000,
        connectTimeout: 60000
      })

      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`请求失败，状态码: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('POST 请求失败:', error)
      throw error
    }
  }

  // PUT 请求
  static async put(url: string, data: object): Promise<any> {
    try {
      const httpRequest = http.createHttp()

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(data)
      })

      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`请求失败，状态码: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('PUT 请求失败:', error)
      throw error
    }
  }

  // DELETE 请求
  static async delete(url: string): Promise<any> {
    try {
      const httpRequest = http.createHttp()

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json'
        }
      })

      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`请求失败，状态码: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('DELETE 请求失败:', error)
      throw error
    }
  }
}
```

### 2. 带 Token 的请求

```typescript
class AuthHttpClient {
  private static token: string = ''

  // 设置 Token
  static setToken(token: string) {
    this.token = token
  }

  // 带 Token 的请求
  static async requestWithAuth(url: string, options?: http.HttpRequestOptions): Promise<any> {
    try {
      const httpRequest = http.createHttp()

      const defaultOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.token}`
        },
        ...options
      }

      const response = await httpRequest.request(url, defaultOptions)

      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else if (response.responseCode === 401) {
        // Token 过期，需要重新登录
        throw new Error('Token 已过期，请重新登录')
      } else {
        throw new Error(`请求失败，状态码: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('请求失败:', error)
      throw error
    }
  }
}
```

### 3. 文件上传

```typescript
import http from '@ohos.net.http'
import fs from '@ohos.file.fs'

class FileUploader {
  // 上传单个文件
  static async uploadFile(url: string, filePath: string, fieldName: string = 'file'): Promise<any> {
    try {
      // 读取文件
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY)
      const stat = fs.statSync(filePath)
      const buffer = new ArrayBuffer(stat.size)
      fs.readSync(file.fd, buffer)
      fs.closeSync(file)

      // 创建 FormData
      const boundary = '----WebKitFormBoundary' + Date.now()
      const httpRequest = http.createHttp()

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': `multipart/form-data; boundary=${boundary}`
        },
        extraData: buffer
      })

      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`上传失败，状态码: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('文件上传失败:', error)
      throw error
    }
  }

  // 上传图片并压缩
  static async uploadImage(url: string, imagePath: string): Promise<any> {
    try {
      // 这里可以添加图片压缩逻辑
      return await this.uploadFile(url, imagePath, 'image')
    } catch (error) {
      console.error('图片上传失败:', error)
      throw error
    }
  }
}
```

### 4. 下载文件

```typescript
import http from '@ohos.net.http'
import fs from '@ohos.file.fs'

class FileDownloader {
  // 下载文件
  static async downloadFile(
    url: string,
    savePath: string,
    onProgress?: (current: number, total: number) => void
  ): Promise<string> {
    try {
      const httpRequest = http.createHttp()

      // 监听下载进度
      httpRequest.on('headersReceive', (header) => {
        console.info('接收到响应头:', header)
      })

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER
      })

      if (response.responseCode === 200) {
        // 保存文件
        const file = fs.openSync(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        fs.writeSync(file.fd, response.result as ArrayBuffer)
        fs.closeSync(file)

        console.info(`文件下载成功: ${savePath}`)
        return savePath
      } else {
        throw new Error(`下载失败，状态码: ${response.responseCode}`)
      }
    } catch (error) {
      console.error('文件下载失败:', error)
      throw error
    }
  }

  // 下载图片
  static async downloadImage(url: string, savePath: string): Promise<string> {
    return await this.downloadFile(url, savePath)
  }
}
```

## 新闻应用示例（官方示例）

基于 HarmonyOS 官方的 **FluentNewsHomepage** 示例

### 新闻数据模型

```typescript
// 新闻分类
export enum NewsCategory {
  RECOMMEND = 'recommend',
  TECHNOLOGY = 'technology',
  ENTERTAINMENT = 'entertainment',
  SPORTS = 'sports',
  FINANCE = 'finance'
}

// 新闻项接口
export interface NewsItem {
  id: string
  title: string
  summary: string
  imageUrl: string
  source: string
  publishTime: string
  category: NewsCategory
  readCount: number
  commentCount: number
}

// 新闻列表响应
export interface NewsListResponse {
  code: number
  message: string
  data: {
    list: NewsItem[]
    hasMore: boolean
  }
}
```

### 新闻 API 服务

```typescript
class NewsService {
  private static readonly BASE_URL = 'https://api.example.com'

  // 获取新闻列表
  static async getNewsList(
    category: NewsCategory,
    page: number = 1,
    pageSize: number = 20
  ): Promise<NewsListResponse> {
    try {
      const url = `${this.BASE_URL}/news/list?category=${category}&page=${page}&pageSize=${pageSize}`
      const response = await HttpClient.get(url)
      return response as NewsListResponse
    } catch (error) {
      console.error('获取新闻列表失败:', error)
      throw error
    }
  }

  // 获取新闻详情
  static async getNewsDetail(newsId: string): Promise<NewsItem> {
    try {
      const url = `${this.BASE_URL}/news/detail/${newsId}`
      const response = await HttpClient.get(url)
      return response.data as NewsItem
    } catch (error) {
      console.error('获取新闻详情失败:', error)
      throw error
    }
  }

  // 搜索新闻
  static async searchNews(keyword: string, page: number = 1): Promise<NewsListResponse> {
    try {
      const url = `${this.BASE_URL}/news/search`
      const response = await HttpClient.post(url, {
        keyword,
        page
      })
      return response as NewsListResponse
    } catch (error) {
      console.error('搜索新闻失败:', error)
      throw error
    }
  }
}
```

### 新闻首页实现

```typescript
@Entry
@Component
struct NewsHomePage {
  @State currentCategory: NewsCategory = NewsCategory.RECOMMEND
  @State newsList: NewsItem[] = []
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State hasMore: boolean = true
  private page: number = 1
  private scroller: Scroller = new Scroller()

  aboutToAppear() {
    this.loadNews()
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // 分类标签
      this.buildCategoryTabs()

      // 新闻列表
      this.buildNewsList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildHeader() {
    Row() {
      Text('新闻')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

      Image($r('app.media.ic_search'))
        .width(24)
        .height(24)
        .onClick(() => {
          // 跳转到搜索页面
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildCategoryTabs() {
    Scroll() {
      Row({ space: 16 }) {
        this.buildTabItem('推荐', NewsCategory.RECOMMEND)
        this.buildTabItem('科技', NewsCategory.TECHNOLOGY)
        this.buildTabItem('娱乐', NewsCategory.ENTERTAINMENT)
        this.buildTabItem('体育', NewsCategory.SPORTS)
        this.buildTabItem('财经', NewsCategory.FINANCE)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(50)
    .backgroundColor(Color.White)
  }

  @Builder
  buildTabItem(title: string, category: NewsCategory) {
    Text(title)
      .fontSize(16)
      .fontColor(this.currentCategory === category ? '#007DFF' : '#333333')
      .fontWeight(this.currentCategory === category ? FontWeight.Bold : FontWeight.Normal)
      .padding({ top: 8, bottom: 8 })
      .border({
        width: { bottom: this.currentCategory === category ? 2 : 0 },
        color: '#007DFF'
      })
      .onClick(() => {
        this.currentCategory = category
        this.page = 1
        this.loadNews(true)
      })
  }

  @Builder
  buildNewsList() {
    if (this.isLoading && this.newsList.length === 0) {
      // 加载中
      Column() {
        LoadingProgress()
          .width(50)
          .height(50)
        Text('加载中...')
          .fontSize(14)
          .margin({ top: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ scroller: this.scroller }) {
        // 下拉刷新提示
        if (this.isRefreshing) {
          ListItem() {
            Row() {
              LoadingProgress()
                .width(20)
                .height(20)
              Text('刷新中...')
                .fontSize(14)
                .margin({ left: 8 })
            }
            .width('100%')
            .height(50)
            .justifyContent(FlexAlign.Center)
          }
        }

        // 新闻列表项
        ForEach(this.newsList, (news: NewsItem) => {
          ListItem() {
            this.buildNewsItem(news)
          }
        })

        // 加载更多提示
        if (this.hasMore && this.newsList.length > 0) {
          ListItem() {
            Row() {
              LoadingProgress()
                .width(20)
                .height(20)
              Text('加载更多...')
                .fontSize(14)
                .margin({ left: 8 })
            }
            .width('100%')
            .height(50)
            .justifyContent(FlexAlign.Center)
          }
        } else if (!this.hasMore && this.newsList.length > 0) {
          ListItem() {
            Text('没有更多了')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .height(50)
              .textAlign(TextAlign.Center)
          }
        }
      }
      .layoutWeight(1)
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)
      .onScrollIndex((start: number, end: number) => {
        // 滚动到底部时加载更多
        if (end >= this.newsList.length - 1 && this.hasMore && !this.isLoading) {
          this.loadMore()
        }
      })
      .onTouch((event: TouchEvent) => {
        // 实现下拉刷新手势
      })
    }
  }

  @Builder
  buildNewsItem(news: NewsItem) {
    Row({ space: 12 }) {
      // 新闻图片
      Image(news.imageUrl)
        .width(120)
        .height(90)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .alt($r('app.media.ic_placeholder'))

      // 新闻信息
      Column({ space: 8 }) {
        // 标题
        Text(news.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 摘要
        Text(news.summary)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 底部信息
        Row({ space: 16 }) {
          Text(news.source)
            .fontSize(12)
            .fontColor('#999999')

          Text(`${news.readCount}阅读`)
            .fontSize(12)
            .fontColor('#999999')

          Text(news.publishTime)
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ top: 8 })
    .onClick(() => {
      // 跳转到新闻详情
      router.pushUrl({
        url: 'pages/NewsDetailPage',
        params: { newsId: news.id }
      })
    })
  }

  // 加载新闻
  async loadNews(refresh: boolean = false) {
    if (this.isLoading) return

    this.isLoading = true
    if (refresh) {
      this.isRefreshing = true
      this.page = 1
    }

    try {
      const response = await NewsService.getNewsList(this.currentCategory, this.page)

      if (response.code === 200) {
        if (refresh) {
          this.newsList = response.data.list
        } else {
          this.newsList = [...this.newsList, ...response.data.list]
        }
        this.hasMore = response.data.hasMore
      }
    } catch (error) {
      console.error('加载新闻失败:', error)
    } finally {
      this.isLoading = false
      this.isRefreshing = false
    }
  }

  // 加载更多
  async loadMore() {
    this.page++
    await this.loadNews()
  }
}
```

## 请求拦截器

```typescript
class HttpInterceptor {
  private static requestInterceptors: ((config: http.HttpRequestOptions) => http.HttpRequestOptions)[] = []
  private static responseInterceptors: ((response: http.HttpResponse) => http.HttpResponse)[] = []

  // 添加请求拦截器
  static addRequestInterceptor(interceptor: (config: http.HttpRequestOptions) => http.HttpRequestOptions) {
    this.requestInterceptors.push(interceptor)
  }

  // 添加响应拦截器
  static addResponseInterceptor(interceptor: (response: http.HttpResponse) => http.HttpResponse) {
    this.responseInterceptors.push(interceptor)
  }

  // 执行请求拦截器
  static executeRequestInterceptors(config: http.HttpRequestOptions): http.HttpRequestOptions {
    let processedConfig = config
    for (const interceptor of this.requestInterceptors) {
      processedConfig = interceptor(processedConfig)
    }
    return processedConfig
  }

  // 执行响应拦截器
  static executeResponseInterceptors(response: http.HttpResponse): http.HttpResponse {
    let processedResponse = response
    for (const interceptor of this.responseInterceptors) {
      processedResponse = interceptor(processedResponse)
    }
    return processedResponse
  }
}

// 使用示例
HttpInterceptor.addRequestInterceptor((config) => {
  console.info('请求拦截:', config)
  // 添加通用请求头
  config.header = {
    ...config.header,
    'X-Request-Time': Date.now().toString()
  }
  return config
})

HttpInterceptor.addResponseInterceptor((response) => {
  console.info('响应拦截:', response.responseCode)
  return response
})
```

## 错误处理

```typescript
enum HttpErrorCode {
  NETWORK_ERROR = 'NETWORK_ERROR',
  TIMEOUT = 'TIMEOUT',
  SERVER_ERROR = 'SERVER_ERROR',
  UNAUTHORIZED = 'UNAUTHORIZED',
  NOT_FOUND = 'NOT_FOUND'
}

class HttpError extends Error {
  code: HttpErrorCode
  statusCode?: number

  constructor(message: string, code: HttpErrorCode, statusCode?: number) {
    super(message)
    this.code = code
    this.statusCode = statusCode
    this.name = 'HttpError'
  }
}

class HttpErrorHandler {
  static handleError(error: any): HttpError {
    if (error.code === 'TIMEOUT') {
      return new HttpError('请求超时', HttpErrorCode.TIMEOUT)
    } else if (error.code === 'NETWORK_ERROR') {
      return new HttpError('网络连接失败', HttpErrorCode.NETWORK_ERROR)
    } else if (error.statusCode === 401) {
      return new HttpError('未授权，请登录', HttpErrorCode.UNAUTHORIZED, 401)
    } else if (error.statusCode === 404) {
      return new HttpError('资源不存在', HttpErrorCode.NOT_FOUND, 404)
    } else if (error.statusCode >= 500) {
      return new HttpError('服务器错误', HttpErrorCode.SERVER_ERROR, error.statusCode)
    } else {
      return new HttpError('未知错误', HttpErrorCode.NETWORK_ERROR)
    }
  }
}
```

## 下一步

继续学习 [数据存储方案](10-data-storage.md)

