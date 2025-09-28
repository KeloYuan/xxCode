import { MarkdownService, MarkdownElement } from '../services/MarkdownService';

@Component
export struct MarkdownPreview {
  @Prop markdown: string = '';
  @Prop fontSize: number = 14;

  private markdownService: MarkdownService = new MarkdownService();
  @State elements: MarkdownElement[] = [];

  aboutToAppear() {
    this.updatePreview();
  }

  build() {
    Scroll() {
      Column() {
        ForEach(this.elements, (element: MarkdownElement, index: number) => {
          this.renderElement(element)
        })
      }
      .padding(16)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White)
    // scrollable property not available in this ArkTS version
  }

  @Builder
  renderElement(element: MarkdownElement) {
    Column() {
      if (element.type === 'heading') {
        this.renderHeading(element)
      } else if (element.type === 'paragraph') {
        this.renderParagraph(element)
      } else if (element.type === 'code') {
        this.renderCodeBlock(element)
      } else if (element.type === 'list') {
        this.renderList(element)
      } else if (element.type === 'blockquote') {
        this.renderBlockquote(element)
      } else {
        this.renderParagraph(element)
      }
    }
    .margin({ bottom: 12 })
  }

  @Builder
  renderHeading(element: MarkdownElement) {
    Text(element.content)
      .fontSize(this.getHeadingFontSize(element.level || 1))
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Start)
      .margin({ bottom: 8 })
  }

  @Builder
  renderParagraph(element: MarkdownElement) {
    Text(element.content)
      .fontSize(this.fontSize)
      .textAlign(TextAlign.Start)
      .lineHeight(1.6)
  }

  @Builder
  renderCodeBlock(element: MarkdownElement) {
    Column() {
      // 代码块标题（如果有语言）
      if (element.language && element.language !== 'text') {
        Row() {
          Text(element.language)
            .fontSize(12)
            .fontColor(Color.Gray)
            .padding(8)
        }
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 8, topRight: 8 })
      }

      // 代码内容
      Text(element.content)
        .fontSize(this.fontSize - 2)
        .fontFamily('monospace')
        .textAlign(TextAlign.Start)
        .backgroundColor(Color.White)
        .padding(16)
        .borderRadius(element.language && element.language !== 'text' ? { bottomLeft: 8, bottomRight: 8 } : 8)
        .lineHeight(1.4)
    }
    .borderRadius(8)
    .margin({ bottom: 8 })
  }

  @Builder
  renderList(element: MarkdownElement) {
    Column() {
      ForEach(element.items || [], (item: string, index: number) => {
        Row() {
          Text('•')
            .fontSize(this.fontSize)
            .margin({ right: 8 })
            .width(16)
            .textAlign(TextAlign.Center)

          Text(item)
            .fontSize(this.fontSize)
            .textAlign(TextAlign.Start)
            .layoutWeight(1)
        }
        .padding(4)
      })
    }
  }

  @Builder
  renderBlockquote(element: MarkdownElement) {
    Column() {
      ForEach(element.items || [], (item: string, index: number) => {
        Row() {
          Text('|')
            .fontSize(this.fontSize)
            .fontColor(Color.Blue)
            .margin({ right: 12 })
            .width(4)

          Text(item)
            .fontSize(this.fontSize)
            .textAlign(TextAlign.Start)
            .layoutWeight(1)
            .fontStyle(FontStyle.Italic)
        }
        .padding(8)
        .backgroundColor(Color.Gray)
        .borderRadius(4)
      })
    }
  }

  private getHeadingFontSize(level: number): number {
    const baseSize = this.fontSize + 8;
    return Math.max(baseSize - (level - 1) * 2, 12);
  }

  private updatePreview() {
    if (this.markdown.trim()) {
      this.elements = this.markdownService.parseMarkdown(this.markdown);
    } else {
      this.elements = [];
    }
  }

  // 公共方法供父组件调用
  public refreshPreview() {
    this.updatePreview();
  }

  public setMarkdown(markdown: string) {
    this.markdown = markdown;
    this.updatePreview();
  }
}
