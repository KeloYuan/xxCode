/**
 * 搜索对话框组件
 * 提供搜索和替换功能的UI界面
 */
import { SearchService, SearchOptions, SearchResult } from '../services/SearchService';
import { ThemeService, Theme } from '../services/ThemeService';
import { CommonConstants } from '../common/CommonConstants';

@CustomDialog
export struct SearchDialog {
  @State searchText: string = '';
  @State replaceText: string = '';
  @State caseSensitive: boolean = false;
  @State wholeWord: boolean = false;
  @State useRegex: boolean = false;
  @State searchResults: SearchResult[] = [];
  @State currentResultIndex: number = 0;
  @State showReplaceOptions: boolean = false;
  
  @State private currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  
  controller: CustomDialogController = new CustomDialogController({
    builder: SearchDialog()
  });
  
  content: string = '';
  onSearch?: (results: SearchResult[]) => void;
  onReplace?: (newContent: string) => void;
  onClose?: () => void;
  
  private searchService: SearchService = SearchService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();

  aboutToAppear() {
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
    });
  }

  private performSearch() {
    if (!this.searchText) {
      return;
    }

    const options: SearchOptions = {
      caseSensitive: this.caseSensitive,
      wholeWord: this.wholeWord,
      useRegex: this.useRegex
    };

    this.searchResults = this.searchService.search(this.content, this.searchText, options);
    this.currentResultIndex = 0;

    if (this.onSearch) {
      this.onSearch(this.searchResults);
    }
  }

  private performReplace() {
    if (!this.searchText || !this.onReplace) {
      return;
    }

    const options: SearchOptions = {
      caseSensitive: this.caseSensitive,
      wholeWord: this.wholeWord,
      useRegex: this.useRegex
    };

    const result = this.searchService.replaceAll(this.content, this.searchText, this.replaceText, options);
    this.onReplace(result.text);
    
    // 更新搜索结果
    this.performSearch();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('搜索和替换')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme.colors.text)
          .layoutWeight(1)

        Button({ type: ButtonType.Circle }) {
          Text('×')
            .fontSize(20)
            .fontColor(this.currentTheme.colors.textSecondary)
        }
        .width(32)
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.onClose) {
            this.onClose();
          }
          this.controller.close();
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.currentTheme.colors.surface)

      Divider().color(this.currentTheme.colors.border)

      // 搜索区域
      Column({ space: 12 }) {
        // 搜索输入
        Row({ space: 8 }) {
          TextInput({ placeholder: '搜索', text: this.searchText })
            .layoutWeight(1)
            .fontSize(14)
            .backgroundColor(this.currentTheme.colors.surface)
            .onChange((value: string) => {
              this.searchText = value;
            })
            .onSubmit(() => {
              this.performSearch();
            })

          Text(`${this.searchResults.length > 0 ? this.currentResultIndex + 1 : 0}/${this.searchResults.length}`)
            .fontSize(12)
            .fontColor(this.currentTheme.colors.textSecondary)
            .width(60)
            .textAlign(TextAlign.Center)
        }

        // 替换输入
        if (this.showReplaceOptions) {
          TextInput({ placeholder: '替换为', text: this.replaceText })
            .fontSize(14)
            .backgroundColor(this.currentTheme.colors.surface)
            .onChange((value: string) => {
              this.replaceText = value;
            })
        }

        // 选项
        Row({ space: 16 }) {
          Row({ space: 4 }) {
            Checkbox()
              .select(this.caseSensitive)
              .onChange((value: boolean) => {
                this.caseSensitive = value;
              })
            Text('区分大小写')
              .fontSize(12)
              .fontColor(this.currentTheme.colors.text)
          }

          Row({ space: 4 }) {
            Checkbox()
              .select(this.wholeWord)
              .onChange((value: boolean) => {
                this.wholeWord = value;
              })
            Text('全词匹配')
              .fontSize(12)
              .fontColor(this.currentTheme.colors.text)
          }

          Row({ space: 4 }) {
            Checkbox()
              .select(this.useRegex)
              .onChange((value: boolean) => {
                this.useRegex = value;
              })
            Text('正则')
              .fontSize(12)
              .fontColor(this.currentTheme.colors.text)
          }
        }

        // 按钮组
        Row({ space: 12 }) {
          Button('搜索')
            .fontSize(14)
            .backgroundColor(this.currentTheme.colors.primary)
            .onClick(() => {
              this.performSearch();
            })

          Button(this.showReplaceOptions ? '隐藏替换' : '显示替换')
            .fontSize(14)
            .backgroundColor(this.currentTheme.colors.surface)
            .fontColor(this.currentTheme.colors.text)
            .onClick(() => {
              this.showReplaceOptions = !this.showReplaceOptions;
            })

          if (this.showReplaceOptions) {
            Button('全部替换')
              .fontSize(14)
              .backgroundColor(this.currentTheme.colors.warning)
              .onClick(() => {
                this.performReplace();
              })
          }
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('90%')
    .constraintSize({ maxWidth: 500 })
    .backgroundColor(this.currentTheme.colors.background)
    .borderRadius(12)
    .shadow({
      radius: 20,
      color: 'rgba(0, 0, 0, 0.2)',
      offsetX: 0,
      offsetY: 10
    })
  }
}

