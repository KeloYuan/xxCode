# 传感器和设备能力

> 本文档介绍 HarmonyOS Next 中的传感器使用、设备信息获取、振动、屏幕亮度等设备能力。

---

## 目录
- [传感器使用](#传感器使用)
- [设备信息](#设备信息)
- [振动反馈](#振动反馈)
- [屏幕亮度](#屏幕亮度)
- [电池信息](#电池信息)
- [网络状态](#网络状态)
- [定位服务](#定位服务)
- [完整应用示例](#完整应用示例)

---

## 传感器使用

### 加速度传感器

```typescript
import sensor from '@ohos.sensor'

@Entry
@Component
struct AccelerometerExample {
  @State accelX: number = 0
  @State accelY: number = 0
  @State accelZ: number = 0
  
  aboutToAppear() {
    // 订阅加速度传感器
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
        this.accelX = data.x
        this.accelY = data.y
        this.accelZ = data.z
      }, { interval: 100000000 }) // 100ms 间隔
      
      console.info('加速度传感器订阅成功')
    } catch (error) {
      console.error('加速度传感器订阅失败:', error)
    }
  }
  
  aboutToDisappear() {
    // 取消订阅
    try {
      sensor.off(sensor.SensorId.ACCELEROMETER)
      console.info('加速度传感器取消订阅')
    } catch (error) {
      console.error('取消订阅失败:', error)
    }
  }
  
  build() {
    Column() {
      Text('加速度传感器')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      Row() {
        Text(`X: ${this.accelX.toFixed(2)}`)
          .fontSize(16)
          .width('33%')
        
        Text(`Y: ${this.accelY.toFixed(2)}`)
          .fontSize(16)
          .width('33%')
        
        Text(`Z: ${this.accelZ.toFixed(2)}`)
          .fontSize(16)
          .width('33%')
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // 可视化显示
      this.AccelerometerVisual()
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
  
  @Builder
  AccelerometerVisual() {
    Stack() {
      // 背景圆
      Circle()
        .width(200)
        .height(200)
        .fill('#f0f0f0')
      
      // 中心点
      Circle()
        .width(20)
        .height(20)
        .fill('#1890ff')
      
      // 加速度指示器
      Circle()
        .width(30)
        .height(30)
        .fill('#ff4d4f')
        .translate({
          x: this.accelX * 20,
          y: this.accelY * 20
        })
    }
    .width(200)
    .height(200)
  }
}
```

### 陀螺仪传感器

```typescript
import sensor from '@ohos.sensor'

@Entry
@Component
struct GyroscopeExample {
  @State gyroX: number = 0
  @State gyroY: number = 0
  @State gyroZ: number = 0
  @State rotationX: number = 0
  @State rotationY: number = 0
  
  aboutToAppear() {
    try {
      sensor.on(sensor.SensorId.GYROSCOPE, (data: sensor.GyroscopeResponse) => {
        this.gyroX = data.x
        this.gyroY = data.y
        this.gyroZ = data.z
        
        // 累积旋转（简化版）
        this.rotationX += data.x * 0.01
        this.rotationY += data.y * 0.01
      }, { interval: 100000000 })
      
      console.info('陀螺仪订阅成功')
    } catch (error) {
      console.error('陀螺仪订阅失败:', error)
    }
  }
  
  aboutToDisappear() {
    try {
      sensor.off(sensor.SensorId.GYROSCOPE)
    } catch (error) {
      console.error('取消订阅失败:', error)
    }
  }
  
  build() {
    Column() {
      Text('陀螺仪传感器')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      // 3D 旋转效果演示
      Stack() {
        Column()
          .width(150)
          .height(150)
          .backgroundColor('#1890ff')
          .borderRadius(12)
          .rotate({
            x: this.rotationX,
            y: this.rotationY,
            z: 0,
            angle: Math.sqrt(this.rotationX * this.rotationX + this.rotationY * this.rotationY)
          })
          .shadow({
            radius: 20,
            color: '#0000004D',
            offsetX: 10,
            offsetY: 10
          })
      }
      .width(200)
      .height(200)
      .margin({ bottom: 20 })
      
      // 数据显示
      Column() {
        Text(`旋转 X: ${this.gyroX.toFixed(2)} rad/s`)
        Text(`旋转 Y: ${this.gyroY.toFixed(2)} rad/s`)
        Text(`旋转 Z: ${this.gyroZ.toFixed(2)} rad/s`)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

### 磁力计传感器

```typescript
import sensor from '@ohos.sensor'

@Entry
@Component
struct MagnetometerExample {
  @State magX: number = 0
  @State magY: number = 0
  @State magZ: number = 0
  @State compassAngle: number = 0
  
  aboutToAppear() {
    try {
      sensor.on(sensor.SensorId.MAGNETIC_FIELD, (data: sensor.MagneticFieldResponse) => {
        this.magX = data.x
        this.magY = data.y
        this.magZ = data.z
        
        // 计算指南针角度
        this.compassAngle = Math.atan2(data.y, data.x) * (180 / Math.PI)
      }, { interval: 200000000 })
      
      console.info('磁力计订阅成功')
    } catch (error) {
      console.error('磁力计订阅失败:', error)
    }
  }
  
  aboutToDisappear() {
    try {
      sensor.off(sensor.SensorId.MAGNETIC_FIELD)
    } catch (error) {
      console.error('取消订阅失败:', error)
    }
  }
  
  build() {
    Column() {
      Text('电子指南针')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 40 })
      
      // 指南针UI
      Stack() {
        // 背景圆盘
        Circle()
          .width(250)
          .height(250)
          .fill('#f5f5f5')
          .border({ width: 2, color: '#ccc' })
        
        // 刻度标记
        this.CompassMarks()
        
        // 指针
        Stack() {
          Column()
            .width(4)
            .height(100)
            .backgroundColor('#ff4d4f')
            .position({ y: -50 })
          
          Circle()
            .width(20)
            .height(20)
            .fill('#ff4d4f')
        }
        .rotate({ angle: this.compassAngle })
      }
      .width(250)
      .height(250)
      .margin({ bottom: 40 })
      
      Text(`方位角: ${this.compassAngle.toFixed(1)}°`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
  
  @Builder
  CompassMarks() {
    Stack() {
      // 北
      Text('N')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ff4d4f')
        .position({ y: -110 })
      
      // 东
      Text('E')
        .fontSize(20)
        .position({ x: 110 })
      
      // 南
      Text('S')
        .fontSize(20)
        .position({ y: 110 })
      
      // 西
      Text('W')
        .fontSize(20)
        .position({ x: -110 })
    }
  }
}
```

---

## 设备信息

### 获取设备基本信息

```typescript
import deviceInfo from '@ohos.deviceInfo'
import display from '@ohos.display'

@Entry
@Component
struct DeviceInfoExample {
  @State deviceBrand: string = ''
  @State deviceModel: string = ''
  @State osVersion: string = ''
  @State sdkVersion: number = 0
  @State screenWidth: number = 0
  @State screenHeight: number = 0
  @State screenDensity: number = 0
  
  aboutToAppear() {
    // 获取设备信息
    this.deviceBrand = deviceInfo.brand
    this.deviceModel = deviceInfo.productModel
    this.osVersion = deviceInfo.osFullName
    this.sdkVersion = deviceInfo.sdkApiVersion
    
    // 获取屏幕信息
    const displayClass = display.getDefaultDisplaySync()
    this.screenWidth = displayClass.width
    this.screenHeight = displayClass.height
    this.screenDensity = displayClass.densityDPI
  }
  
  build() {
    Scroll() {
      Column() {
        Text('设备信息')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        
        this.InfoCard('设备品牌', this.deviceBrand)
        this.InfoCard('设备型号', this.deviceModel)
        this.InfoCard('系统版本', this.osVersion)
        this.InfoCard('SDK 版本', `API ${this.sdkVersion}`)
        this.InfoCard('屏幕尺寸', `${this.screenWidth} x ${this.screenHeight}`)
        this.InfoCard('屏幕密度', `${this.screenDensity} DPI`)
      }
      .width('100%')
      .padding(20)
    }
  }
  
  @Builder
  InfoCard(label: string, value: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor('#666')
          .layoutWeight(1)
        
        Text(value)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }
}
```

---

## 振动反馈

### 基础振动

```typescript
import vibrator from '@ohos.vibrator'

@Entry
@Component
struct VibrationExample {
  // 短振动
  async vibrateShort() {
    try {
      await vibrator.startVibration({
        type: 'time',
        duration: 100
      }, {
        usage: 'touch'
      })
      console.info('短振动完成')
    } catch (error) {
      console.error('振动失败:', error)
    }
  }
  
  // 长振动
  async vibrateLong() {
    try {
      await vibrator.startVibration({
        type: 'time',
        duration: 500
      }, {
        usage: 'notification'
      })
      console.info('长振动完成')
    } catch (error) {
      console.error('振动失败:', error)
    }
  }
  
  // 预设效果振动
  async vibrateEffect() {
    try {
      await vibrator.startVibration({
        type: 'preset',
        effectId: 'haptic.clock.timer',
        count: 1
      }, {
        usage: 'alarm'
      })
      console.info('效果振动完成')
    } catch (error) {
      console.error('振动失败:', error)
    }
  }
  
  // 停止振动
  async stopVibration() {
    try {
      await vibrator.stopVibration()
      console.info('振动已停止')
    } catch (error) {
      console.error('停止振动失败:', error)
    }
  }
  
  build() {
    Column() {
      Text('振动反馈示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      Button('短振动 (100ms)')
        .width('80%')
        .onClick(() => {
          this.vibrateShort()
        })
        .margin({ bottom: 12 })
      
      Button('长振动 (500ms)')
        .width('80%')
        .onClick(() => {
          this.vibrateLong()
        })
        .margin({ bottom: 12 })
      
      Button('预设效果振动')
        .width('80%')
        .onClick(() => {
          this.vibrateEffect()
        })
        .margin({ bottom: 12 })
      
      Button('停止振动')
        .width('80%')
        .backgroundColor('#ff4d4f')
        .onClick(() => {
          this.stopVibration()
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

## 屏幕亮度

### 调节屏幕亮度

```typescript
import brightness from '@ohos.brightness'
import window from '@ohos.window'

@Entry
@Component
struct BrightnessExample {
  @State currentBrightness: number = 0.5
  private windowClass: window.Window | null = null
  
  async aboutToAppear() {
    try {
      // 获取当前窗口
      this.windowClass = await window.getLastWindow(getContext(this))
      
      // 获取当前亮度
      const brightness = await this.windowClass.getWindowBrightness()
      this.currentBrightness = brightness
    } catch (error) {
      console.error('获取亮度失败:', error)
    }
  }
  
  async setBrightness(value: number) {
    try {
      if (this.windowClass) {
        await this.windowClass.setWindowBrightness(value)
        this.currentBrightness = value
        console.info(`亮度已设置为: ${value}`)
      }
    } catch (error) {
      console.error('设置亮度失败:', error)
    }
  }
  
  build() {
    Column() {
      Text('屏幕亮度控制')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      // 亮度指示器
      Stack() {
        // 背景
        Column()
          .width(200)
          .height(200)
          .backgroundColor('#f0f0f0')
          .borderRadius(100)
        
        // 前景
        Column()
          .width(200)
          .height(200)
          .backgroundColor('#ffd700')
          .borderRadius(100)
          .opacity(this.currentBrightness)
        
        // 文字
        Text(`${Math.round(this.currentBrightness * 100)}%`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
      }
      .margin({ bottom: 40 })
      
      // 亮度滑块
      Row() {
        Text('☀️')
          .fontSize(20)
        
        Slider({
          value: this.currentBrightness * 100,
          min: 0,
          max: 100,
          step: 1
        })
          .layoutWeight(1)
          .margin({ left: 12, right: 12 })
          .onChange((value: number) => {
            this.setBrightness(value / 100)
          })
        
        Text('☀️')
          .fontSize(30)
      }
      .width('90%')
      .margin({ bottom: 20 })
      
      // 快捷按钮
      Row() {
        Button('25%')
          .onClick(() => {
            this.setBrightness(0.25)
          })
        
        Button('50%')
          .onClick(() => {
            this.setBrightness(0.5)
          })
          .margin({ left: 12 })
        
        Button('75%')
          .onClick(() => {
            this.setBrightness(0.75)
          })
          .margin({ left: 12 })
        
        Button('100%')
          .onClick(() => {
            this.setBrightness(1.0)
          })
          .margin({ left: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
}
```

---

## 电池信息

### 监听电池状态

```typescript
import batteryInfo from '@ohos.batteryInfo'
import commonEventManager from '@ohos.commonEventManager'

@Entry
@Component
struct BatteryInfoExample {
  @State batteryLevel: number = 0
  @State isCharging: boolean = false
  @State batteryTemp: number = 0
  
  aboutToAppear() {
    // 获取电池信息
    this.updateBatteryInfo()
    
    // 订阅电池变化事件
    this.subscribeBatteryChange()
  }
  
  updateBatteryInfo() {
    this.batteryLevel = batteryInfo.batterySOC
    this.isCharging = batteryInfo.chargingStatus === batteryInfo.BatteryChargeState.ENABLE
    this.batteryTemp = batteryInfo.batteryTemperature / 10 // 转换为摄氏度
  }
  
  async subscribeBatteryChange() {
    try {
      const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
        events: [commonEventManager.Support.COMMON_EVENT_BATTERY_CHANGED]
      }
      
      const subscriber = await commonEventManager.createSubscriber(subscribeInfo)
      
      commonEventManager.subscribe(subscriber, (err, data) => {
        if (err) {
          console.error('订阅电池事件失败:', err)
          return
        }
        this.updateBatteryInfo()
      })
    } catch (error) {
      console.error('创建订阅失败:', error)
    }
  }
  
  build() {
    Column() {
      Text('电池信息')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      // 电池图标
      Stack() {
        // 电池外壳
        Column()
          .width(150)
          .height(80)
          .border({ width: 4, color: '#333', radius: 8 })
        
        // 电池正极
        Column()
          .width(10)
          .height(30)
          .backgroundColor('#333')
          .borderRadius({ topRight: 4, bottomRight: 4 })
          .position({ x: 150 })
        
        // 电量
        Column()
          .width(this.batteryLevel * 1.4)
          .height(72)
          .backgroundColor(this.getBatteryColor())
          .borderRadius(4)
          .position({ x: -71 })
        
        // 电量文字
        Text(`${this.batteryLevel}%`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width(160)
      .height(80)
      .margin({ bottom: 40 })
      
      // 详细信息
      Column() {
        this.InfoRow('电量', `${this.batteryLevel}%`)
        this.InfoRow('充电状态', this.isCharging ? '充电中 ⚡' : '未充电')
        this.InfoRow('电池温度', `${this.batteryTemp.toFixed(1)}°C`)
      }
      .width('90%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
  
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#666')
      
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }
  
  getBatteryColor(): ResourceColor {
    if (this.batteryLevel > 50) {
      return '#52c41a' // 绿色
    } else if (this.batteryLevel > 20) {
      return '#faad14' // 黄色
    } else {
      return '#ff4d4f' // 红色
    }
  }
}
```

---

## 网络状态

### 监听网络变化

```typescript
import connection from '@ohos.net.connection'

@Entry
@Component
struct NetworkExample {
  @State networkType: string = '未知'
  @State isConnected: boolean = false
  
  async aboutToAppear() {
    await this.checkNetworkStatus()
    this.subscribeNetworkChange()
  }
  
  async checkNetworkStatus() {
    try {
      const netHandle = await connection.getDefaultNet()
      const capabilities = await connection.getNetCapabilities(netHandle)
      
      this.isConnected = true
      
      // 判断网络类型
      if (capabilities.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
        this.networkType = 'WiFi'
      } else if (capabilities.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
        this.networkType = '移动网络'
      } else if (capabilities.bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
        this.networkType = '以太网'
      } else {
        this.networkType = '其他'
      }
    } catch (error) {
      console.error('获取网络状态失败:', error)
      this.isConnected = false
      this.networkType = '未连接'
    }
  }
  
  subscribeNetworkChange() {
    try {
      connection.on('netAvailable', (data) => {
        console.info('网络可用:', data)
        this.checkNetworkStatus()
      })
      
      connection.on('netLost', (data) => {
        console.info('网络断开:', data)
        this.isConnected = false
        this.networkType = '未连接'
      })
    } catch (error) {
      console.error('订阅网络事件失败:', error)
    }
  }
  
  build() {
    Column() {
      Text('网络状态')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      // 网络图标
      Text(this.getNetworkIcon())
        .fontSize(80)
        .margin({ bottom: 20 })
      
      // 状态文字
      Text(this.isConnected ? '已连接' : '未连接')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isConnected ? '#52c41a' : '#ff4d4f')
        .margin({ bottom: 10 })
      
      Text(this.networkType)
        .fontSize(18)
        .fontColor('#666')
        .margin({ bottom: 30 })
      
      Button('刷新状态')
        .onClick(() => {
          this.checkNetworkStatus()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
  
  getNetworkIcon(): string {
    if (!this.isConnected) {
      return '📡'
    }
    
    switch (this.networkType) {
      case 'WiFi':
        return '📶'
      case '移动网络':
        return '📱'
      case '以太网':
        return '🔌'
      default:
        return '🌐'
    }
  }
}
```

---

## 定位服务

### 获取地理位置

```typescript
import geoLocationManager from '@ohos.geoLocationManager'

@Entry
@Component
struct LocationExample {
  @State latitude: number = 0
  @State longitude: number = 0
  @State accuracy: number = 0
  @State isLocating: boolean = false
  
  async getCurrentLocation() {
    this.isLocating = true
    
    try {
      const requestInfo: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        timeoutMs: 10000,
        maxAccuracy: 100
      }
      
      const location = await geoLocationManager.getCurrentLocation(requestInfo)
      
      this.latitude = location.latitude
      this.longitude = location.longitude
      this.accuracy = location.accuracy
      
      console.info('定位成功:', location)
    } catch (error) {
      console.error('定位失败:', error)
    } finally {
      this.isLocating = false
    }
  }
  
  build() {
    Column() {
      Text('地理定位')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      if (this.latitude !== 0) {
        Column() {
          Text(`纬度: ${this.latitude.toFixed(6)}°`)
            .fontSize(18)
            .margin({ bottom: 10 })
          
          Text(`经度: ${this.longitude.toFixed(6)}°`)
            .fontSize(18)
            .margin({ bottom: 10 })
          
          Text(`精度: ${this.accuracy.toFixed(2)} 米`)
            .fontSize(16)
            .fontColor('#666')
        }
        .margin({ bottom: 30 })
      }
      
      Button(this.isLocating ? '定位中...' : '获取位置')
        .width('80%')
        .enabled(!this.isLocating)
        .onClick(() => {
          this.getCurrentLocation()
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

## 完整应用示例

### 设备仪表盘应用

```typescript
import sensor from '@ohos.sensor'
import deviceInfo from '@ohos.deviceInfo'
import batteryInfo from '@ohos.batteryInfo'
import connection from '@ohos.net.connection'

@Entry
@Component
struct DeviceDashboard {
  @State batteryLevel: number = 0
  @State networkType: string = '未知'
  @State accelX: number = 0
  @State accelY: number = 0
  @State accelZ: number = 0
  @State currentTab: number = 0
  
  aboutToAppear() {
    this.initSensors()
    this.updateBatteryInfo()
    this.checkNetwork()
  }
  
  initSensors() {
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
        this.accelX = data.x
        this.accelY = data.y
        this.accelZ = data.z
      }, { interval: 100000000 })
    } catch (error) {
      console.error('传感器初始化失败:', error)
    }
  }
  
  updateBatteryInfo() {
    this.batteryLevel = batteryInfo.batterySOC
  }
  
  async checkNetwork() {
    try {
      const netHandle = await connection.getDefaultNet()
      const capabilities = await connection.getNetCapabilities(netHandle)
      
      if (capabilities.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
        this.networkType = 'WiFi'
      } else if (capabilities.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
        this.networkType = '移动网络'
      }
    } catch (error) {
      this.networkType = '未连接'
    }
  }
  
  aboutToDisappear() {
    try {
      sensor.off(sensor.SensorId.ACCELEROMETER)
    } catch (error) {
      console.error('取消订阅失败:', error)
    }
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('设备仪表盘')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        
        Text(`API ${deviceInfo.sdkApiVersion}`)
          .fontSize(14)
          .fontColor('#666')
          .margin({ left: 'auto' })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#f5f5f5')
      
      // 信息卡片
      Scroll() {
        Column() {
          this.StatusCard('🔋', '电池电量', `${this.batteryLevel}%`)
          this.StatusCard('📶', '网络状态', this.networkType)
          this.StatusCard('📱', '设备型号', deviceInfo.productModel)
          
          // 传感器数据
          Column() {
            Text('加速度传感器')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })
            
            Row() {
              this.SensorValue('X', this.accelX)
              this.SensorValue('Y', this.accelY)
              this.SensorValue('Z', this.accelZ)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#0000001A', offsetY: 2 })
        }
        .padding(20)
      }
      .layoutWeight(1)
    }
  }
  
  @Builder
  StatusCard(icon: string, label: string, value: string) {
    Row() {
      Text(icon)
        .fontSize(32)
        .margin({ right: 16 })
      
      Column() {
        Text(label)
          .fontSize(14)
          .fontColor('#666')
        
        Text(value)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#fff')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#0000001A', offsetY: 2 })
    .margin({ bottom: 12 })
  }
  
  @Builder
  SensorValue(label: string, value: number) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor('#666')
      
      Text(value.toFixed(2))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4 })
    }
  }
}
```

---

## 最佳实践

### 1. 传感器使用
- ✅ 使用完成后及时取消订阅
- ✅ 设置合适的采样间隔
- ✅ 处理传感器不可用的情况
- ✅ 注意传感器数据的精度和范围

### 2. 设备能力检查
- ✅ 使用前检查设备是否支持
- ✅ 处理权限拒绝情况
- ✅ 提供降级方案
- ✅ 优雅处理错误

### 3. 性能优化
- ✅ 避免高频率刷新
- ✅ 使用节流或防抖
- ✅ 及时释放资源
- ✅ 避免内存泄漏

### 4. 用户体验
- ✅ 提供加载状态提示
- ✅ 清晰的错误提示
- ✅ 合理的振动反馈
- ✅ 流畅的动画效果

---

**完整代码可直接复制使用！** 🚀






