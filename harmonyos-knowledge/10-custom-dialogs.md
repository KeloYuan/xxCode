# 自定义弹窗完整指南

基于 HarmonyOS 官方的 **CustomDialogGathers** 示例

## CustomDialog 自定义弹窗

### 1. 基础自定义弹窗

```typescript
@CustomDialog
struct BasicDialog {
  controller: CustomDialogController
  title: string = '提示'
  message: string = ''
  onConfirm?: () => void

  build() {
    Column({ space: 20 }) {
      // 标题
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      // 内容
      Text(this.message)
        .fontSize(16)
        .fontColor('#666666')

      // 按钮组
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .onClick(() => {
            this.controller.close()
          })

        Button('确定')
          .layoutWeight(1)
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm()
            }
            this.controller.close()
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}

// 使用示例
@Entry
@Component
struct DialogExample {
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: BasicDialog({
      title: '删除确认',
      message: '确定要删除这条记录吗？',
      onConfirm: () => {
        console.info('确认删除')
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  build() {
    Column() {
      Button('打开弹窗')
        .onClick(() => {
          this.dialogController.open()
        })
    }
  }
}
```

### 2. 输入框弹窗

```typescript
@CustomDialog
struct InputDialog {
  controller: CustomDialogController
  title: string = '输入'
  placeholder: string = '请输入内容'
  defaultValue: string = ''
  @State inputValue: string = ''
  onConfirm?: (value: string) => void

  aboutToAppear() {
    this.inputValue = this.defaultValue
  }

  build() {
    Column({ space: 20 }) {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: this.placeholder, text: this.inputValue })
        .width('100%')
        .onChange((value: string) => {
          this.inputValue = value
        })

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .onClick(() => {
            this.controller.close()
          })

        Button('确定')
          .layoutWeight(1)
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm(this.inputValue)
            }
            this.controller.close()
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}
```

### 3. 列表选择弹窗

```typescript
@CustomDialog
struct ListSelectDialog {
  controller: CustomDialogController
  title: string = '请选择'
  options: string[] = []
  @State selectedIndex: number = -1
  onSelect?: (index: number, value: string) => void

  build() {
    Column() {
      // 标题
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding(20)
        .width('100%')

      // 选项列表
      List() {
        ForEach(this.options, (option: string, index: number) => {
          ListItem() {
            Row() {
              Text(option)
                .fontSize(16)
                .layoutWeight(1)

              if (this.selectedIndex === index) {
                Image($r('app.media.ic_check'))
                  .width(20)
                  .height(20)
              }
            }
            .width('100%')
            .height(50)
            .padding({ left: 20, right: 20 })
            .onClick(() => {
              this.selectedIndex = index
              if (this.onSelect) {
                this.onSelect(index, option)
              }
              this.controller.close()
            })
          }
        })
      }
      .width('100%')
      .maxHeight(300)
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}

// 使用示例
@Entry
@Component
struct ListSelectExample {
  @State selectedCity: string = ''
  private cities: string[] = ['北京', '上海', '广州', '深圳', '杭州']
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ListSelectDialog({
      title: '选择城市',
      options: this.cities,
      onSelect: (index: number, value: string) => {
        this.selectedCity = value
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })

  build() {
    Column() {
      Button(`选择城市: ${this.selectedCity || '未选择'}`)
        .onClick(() => {
          this.dialogController.open()
        })
    }
  }
}
```

### 4. 日期选择弹窗

```typescript
@CustomDialog
struct DatePickerDialog {
  controller: CustomDialogController
  title: string = '选择日期'
  @State selectedDate: Date = new Date()
  onConfirm?: (date: Date) => void

  build() {
    Column() {
      // 标题
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding(20)

      // 日期选择器
      DatePicker({
        start: new Date('1900-1-1'),
        end: new Date('2100-12-31'),
        selected: this.selectedDate
      })
        .onChange((value: DatePickerResult) => {
          this.selectedDate = new Date(value.year, value.month, value.day)
        })

      // 按钮
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .onClick(() => {
            this.controller.close()
          })

        Button('确定')
          .layoutWeight(1)
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm(this.selectedDate)
            }
            this.controller.close()
          })
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}
```

### 5. 加载中弹窗

```typescript
@CustomDialog
struct LoadingDialog {
  controller: CustomDialogController
  message: string = '加载中...'

  build() {
    Column({ space: 16 }) {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#007DFF')

      Text(this.message)
        .fontSize(16)
        .fontColor('#666666')
    }
    .width(150)
    .height(150)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
  }
}

// 使用示例
@Entry
@Component
struct LoadingExample {
  private loadingDialog: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '正在加载...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  async loadData() {
    this.loadingDialog.open()

    try {
      // 模拟异步请求
      await new Promise(resolve => setTimeout(resolve, 2000))
      console.info('数据加载完成')
    } finally {
      this.loadingDialog.close()
    }
  }

  build() {
    Column() {
      Button('加载数据')
        .onClick(() => {
          this.loadData()
        })
    }
  }
}
```

## bindContentCover 全屏模态

### 1. 基础全屏模态

```typescript
@Entry
@Component
struct FullScreenModalExample {
  @State isShowModal: boolean = false

  build() {
    Column() {
      Button('打开全屏模态')
        .onClick(() => {
          this.isShowModal = true
        })
    }
    .width('100%')
    .height('100%')
    .bindContentCover(this.isShowModal, this.buildModalContent(), {
      modalTransition: ModalTransition.DEFAULT,
      onAppear: () => {
        console.info('模态框显示')
      },
      onDisappear: () => {
        console.info('模态框关闭')
      }
    })
  }

  @Builder
  buildModalContent() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.ic_close'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.isShowModal = false
          })

        Text('详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Row().width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 内容区域
      Column() {
        Text('这里是全屏模态的内容')
          .fontSize(16)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
```

### 2. 图片预览模态

```typescript
@Entry
@Component
struct ImagePreviewModal {
  @State isShowPreview: boolean = false
  @State currentImage: string = ''
  private images: string[] = [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
    'https://example.com/image3.jpg'
  ]

  build() {
    Column() {
      Grid() {
        ForEach(this.images, (image: string) => {
          GridItem() {
            Image(image)
              .width('100%')
              .aspectRatio(1)
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                this.currentImage = image
                this.isShowPreview = true
              })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .bindContentCover(this.isShowPreview, this.buildPreview(), {
      modalTransition: ModalTransition.DEFAULT
    })
  }

  @Builder
  buildPreview() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)

      // 图片
      Image(this.currentImage)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)

      // 关闭按钮
      Row() {
        Image($r('app.media.ic_close_white'))
          .width(32)
          .height(32)
          .onClick(() => {
            this.isShowPreview = false
          })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height('100%')
  }
}
```

## bindSheet 半模态

### 1. 基础半模态

```typescript
@Entry
@Component
struct BottomSheetExample {
  @State isShowSheet: boolean = false

  build() {
    Column() {
      Button('打开底部菜单')
        .onClick(() => {
          this.isShowSheet = true
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .bindSheet(this.isShowSheet, this.buildSheet(), {
      height: 300,
      showClose: false,
      onAppear: () => {
        console.info('底部菜单显示')
      },
      onDisappear: () => {
        console.info('底部菜单关闭')
      }
    })
  }

  @Builder
  buildSheet() {
    Column() {
      // 标题
      Row() {
        Text('选择操作')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Image($r('app.media.ic_close'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.isShowSheet = false
          })
      }
      .width('100%')
      .padding(16)

      Divider()

      // 菜单项
      List() {
        ListItem() {
          this.buildMenuItem('分享', $r('app.media.ic_share'))
        }
        .onClick(() => {
          this.isShowSheet = false
          console.info('分享')
        })

        ListItem() {
          this.buildMenuItem('收藏', $r('app.media.ic_favorite'))
        }
        .onClick(() => {
          this.isShowSheet = false
          console.info('收藏')
        })

        ListItem() {
          this.buildMenuItem('下载', $r('app.media.ic_download'))
        }
        .onClick(() => {
          this.isShowSheet = false
          console.info('下载')
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  buildMenuItem(title: string, icon: Resource) {
    Row({ space: 16 }) {
      Image(icon)
        .width(24)
        .height(24)

      Text(title)
        .fontSize(16)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }
}
```

### 2. 筛选器半模态

```typescript
@Entry
@Component
struct FilterSheetExample {
  @State isShowFilter: boolean = false
  @State selectedCategory: string = '全部'
  @State selectedSort: string = '默认排序'
  @State priceRange: number[] = [0, 1000]

  private categories: string[] = ['全部', '电子产品', '服装', '食品', '图书']
  private sortOptions: string[] = ['默认排序', '价格从低到高', '价格从高到低', '销量最高']

  build() {
    Column() {
      Button('筛选')
        .onClick(() => {
          this.isShowFilter = true
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .bindSheet(this.isShowFilter, this.buildFilterSheet(), {
      height: 500,
      showClose: false
    })
  }

  @Builder
  buildFilterSheet() {
    Column() {
      // 标题栏
      Row() {
        Text('筛选')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Text('重置')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            this.resetFilters()
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Divider()

      // 筛选内容
      Column({ space: 24 }) {
        // 分类
        Column({ space: 12 }) {
          Text('分类')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)

          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.categories, (category: string) => {
                Text(category)
                  .fontSize(14)
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor(this.selectedCategory === category ? '#007DFF' : '#F5F5F5')
                  .fontColor(this.selectedCategory === category ? Color.White : '#333333')
                  .borderRadius(16)
                  .onClick(() => {
                    this.selectedCategory = category
                  })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        // 排序
        Column({ space: 12 }) {
          Text('排序')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)

          Column() {
            ForEach(this.sortOptions, (option: string) => {
              Row() {
                Text(option)
                  .fontSize(14)
                  .layoutWeight(1)

                if (this.selectedSort === option) {
                  Image($r('app.media.ic_check'))
                    .width(20)
                    .height(20)
                }
              }
              .width('100%')
              .height(44)
              .onClick(() => {
                this.selectedSort = option
              })
            })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .padding(16)

      // 底部按钮
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .onClick(() => {
            this.isShowFilter = false
          })

        Button('确定')
          .layoutWeight(1)
          .onClick(() => {
            this.isShowFilter = false
            this.applyFilters()
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  resetFilters() {
    this.selectedCategory = '全部'
    this.selectedSort = '默认排序'
    this.priceRange = [0, 1000]
  }

  applyFilters() {
    console.info(`应用筛选: ${this.selectedCategory}, ${this.selectedSort}`)
  }
}
```

## ActionSheet 操作列表

```typescript
@Entry
@Component
struct ActionSheetExample {
  build() {
    Column() {
      Button('打开操作列表')
        .onClick(() => {
          this.showActionSheet()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  showActionSheet() {
    ActionSheet.show({
      title: '选择操作',
      message: '请选择要执行的操作',
      confirm: {
        value: '确定',
        action: () => {
          console.info('确定')
        }
      },
      cancel: () => {
        console.info('取消')
      },
      sheets: [
        {
          title: '拍照',
          icon: $r('app.media.ic_camera'),
          action: () => {
            console.info('拍照')
          }
        },
        {
          title: '从相册选择',
          icon: $r('app.media.ic_gallery'),
          action: () => {
            console.info('从相册选择')
          }
        },
        {
          title: '删除',
          icon: $r('app.media.ic_delete'),
          action: () => {
            console.info('删除')
          }
        }
      ]
    })
  }
}
```

## AlertDialog 系统弹窗

```typescript
@Entry
@Component
struct AlertDialogExample {
  build() {
    Column({ space: 16 }) {
      Button('确认弹窗')
        .onClick(() => {
          AlertDialog.show({
            title: '删除确认',
            message: '确定要删除这条记录吗？',
            confirm: {
              value: '确定',
              fontColor: Color.Red,
              action: () => {
                console.info('确认删除')
              }
            },
            cancel: () => {
              console.info('取消删除')
            }
          })
        })

      Button('单按钮弹窗')
        .onClick(() => {
          AlertDialog.show({
            title: '提示',
            message: '操作成功',
            confirm: {
              value: '知道了',
              action: () => {
                console.info('关闭')
              }
            }
          })
        })

      Button('三按钮弹窗')
        .onClick(() => {
          AlertDialog.show({
            title: '保存提示',
            message: '是否保存当前修改？',
            primaryButton: {
              value: '不保存',
              action: () => {
                console.info('不保存')
              }
            },
            secondaryButton: {
              value: '取消',
              action: () => {
                console.info('取消')
              }
            },
            confirm: {
              value: '保存',
              action: () => {
                console.info('保存')
              }
            }
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 提示消息

### Toast 提示

```typescript
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct ToastExample {
  build() {
    Column({ space: 16 }) {
      Button('普通提示')
        .onClick(() => {
          promptAction.showToast({
            message: '操作成功',
            duration: 2000
          })
        })

      Button('底部提示')
        .onClick(() => {
          promptAction.showToast({
            message: '这是底部提示',
            duration: 2000,
            bottom: 100
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 下一步

继续学习 [动画效果实战](11-animations.md)

