import { SearchService, SearchOptions, SearchResult } from '../services/SearchService';

@Component
export struct SearchDialog {
  @Prop visible: boolean = false;
  @Prop onClose: () => void = () => {};
  @Prop onResultSelect: (result: SearchResult) => void = () => {};

  @State searchQuery: string = '';
  @State searchResults: SearchResult[] = [];
  @State isSearching: boolean = false;
  @State showOptions: boolean = false;
  @State searchOptions: SearchOptions = {
    query: '',
    caseSensitive: false,
    useRegex: false,
    searchInContent: true,
    searchInFileNames: true,
    fileExtensions: []
  };

  private searchService: SearchService = new SearchService();

  build() {
    Column() {
      if (this.visible) {
        // 搜索头部
        this.buildSearchHeader()

        // 搜索选项
        if (this.showOptions) {
          this.buildSearchOptions()
        }

        // 搜索结果
        this.buildSearchResults()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  buildSearchHeader() {
    Column() {
      // 搜索输入框
      Row() {
        TextInput({
          placeholder: '搜索文件内容或文件名...',
          text: this.searchQuery
        })
        .layoutWeight(1)
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding(12)
        .fontSize(14)
        .onChange((value: string) => {
          this.searchQuery = value;
          this.searchOptions.query = value;
          this.debounceSearch();
        })

        // 选项按钮
        Button(this.showOptions ? '收起' : '选项')
          .width(60)
          .height(40)
          .backgroundColor(Color.White)
          .fontColor(Color.Black)
          .margin({ left: 8 })
          .onClick(() => {
            this.showOptions = !this.showOptions;
          })

        // 关闭按钮
        Button('×')
          .width(40)
          .height(40)
          .backgroundColor(Color.White)
          .fontColor(Color.Black)
          .margin({ left: 4 })
          .onClick(() => {
            this.closeDialog();
          })
      }
      .padding(16)

      // 搜索建议（如果没有输入）
      if (!this.searchQuery.trim()) {
        this.buildSearchSuggestions()
      }
    }
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: Color.Gray })
  }

  @Builder
  buildSearchOptions() {
    Column() {
      // 大小写敏感
      Row() {
        Checkbox()
          .select(this.searchOptions.caseSensitive)
          .onChange((value: boolean) => {
            this.searchOptions.caseSensitive = value;
          })

        Text('大小写敏感')
          .fontSize(14)
          .margin({ left: 8 })
      }

      // 正则表达式
      Row() {
        Checkbox()
          .select(this.searchOptions.useRegex)
          .onChange((value: boolean) => {
            this.searchOptions.useRegex = value;
          })

        Text('正则表达式')
          .fontSize(14)
          .margin({ left: 8 })
      }

      // 搜索范围
      Row() {
        Checkbox()
          .select(this.searchOptions.searchInContent)
          .onChange((value: boolean) => {
            this.searchOptions.searchInContent = value;
          })

        Text('搜索内容')
          .fontSize(14)
          .margin({ left: 8 })
      }

      Row() {
        Checkbox()
          .select(this.searchOptions.searchInFileNames)
          .onChange((value: boolean) => {
            this.searchOptions.searchInFileNames = value;
          })

        Text('搜索文件名')
          .fontSize(14)
          .margin({ left: 8 })
      }
    }
    .padding(16)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: Color.Gray })
  }

  @Builder
  buildSearchSuggestions() {
    Column() {
      Text('搜索建议')
        .fontSize(12)
        .fontColor(Color.Gray)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      // 搜索建议列表
      this.buildSuggestionsList()
    }
    .padding(16)
  }

  @Builder
  buildSuggestionsList() {
    Column() {
      ForEach(this.searchService.getSearchSuggestions(), (suggestion: string) => {
        Row() {
          Text(suggestion)
            .fontSize(14)
            .layoutWeight(1)
            .onClick(() => {
              this.searchQuery = suggestion;
              this.searchOptions.query = suggestion;
              this.performSearch();
            })
        }
        .padding(4)
        .onClick(() => {
          this.searchQuery = suggestion;
          this.searchOptions.query = suggestion;
          this.performSearch();
        })
      })
    }
  }

  @Builder
  buildSearchResults() {
    Scroll() {
      Column() {
        if (this.isSearching) {
          Text('搜索中...')
            .fontSize(14)
            .fontColor(Color.Gray)
            .textAlign(TextAlign.Center)
            .padding(20)
        } else if (this.searchResults.length === 0) {
          Text(this.searchQuery.trim() ? '未找到结果' : '请输入搜索关键词')
            .fontSize(14)
            .fontColor(Color.Gray)
            .textAlign(TextAlign.Center)
            .padding(20)
        } else {
          ForEach(this.searchResults, (result: SearchResult, index: number) => {
            this.buildSearchResultItem(result)
          })
        }
      }
      .padding(16)
    }
    .layoutWeight(1)
    // scrollable property not available in this ArkTS version
  }

  @Builder
  buildSearchResultItem(result: SearchResult) {
    Column() {
      // 文件路径和行号
      Row() {
        Text(result.fileName)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Blue)

        Text(`${result.lineNumber}:${result.columnNumber}`)
          .fontSize(10)
          .fontColor(Color.Gray)
          .margin({ left: 8 })
      }

      // 匹配的行内容
      Text(result.lineContent)
        .fontSize(12)
        .fontFamily('monospace')
        .lineHeight(1.4)
        .margin({ top: 4 })
        .onClick(() => {
          this.selectResult(result);
        })
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      this.selectResult(result);
    })
  }

  private debounceSearch() {
    clearTimeout(this.searchTimer);
    this.searchTimer = setTimeout(() => {
      this.performSearch();
    }, 300);
  }

  private searchTimer: number = 0;

  private async performSearch() {
    if (!this.searchQuery.trim()) {
      this.searchResults = [];
      return;
    }

    this.isSearching = true;

    try {
      const results = await this.searchService.search(this.searchOptions);
      this.searchResults = results;
    } catch (error) {
      console.error('搜索失败:', error);
      this.searchResults = [];
    } finally {
      this.isSearching = false;
    }
  }

  private selectResult(result: SearchResult) {
    if (this.onResultSelect) {
      this.onResultSelect(result);
    }
    this.closeDialog();
  }

  private closeDialog() {
    this.visible = false;
    if (this.onClose) {
      this.onClose();
    }
  }

  // 公共方法
  public show() {
    this.visible = true;
  }

  public hide() {
    this.closeDialog();
  }

  public setQuery(query: string) {
    this.searchQuery = query;
    this.searchOptions.query = query;
  }
}
