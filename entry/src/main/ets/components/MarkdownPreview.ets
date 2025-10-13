/**
 * Markdown 预览组件
 * 用于显示 Markdown 渲染后的 HTML 内容
 */
import { MarkdownService } from '../services/MarkdownService';
import { ThemeService, Theme } from '../services/ThemeService';
import webview from '@ohos.web.webview';

@Component
export struct MarkdownPreview {
  @Prop markdown: string = '';
  @State private html: string = '';
  @State private currentTheme: Theme = ThemeService.getInstance().getCurrentTheme();
  
  private markdownService: MarkdownService = MarkdownService.getInstance();
  private themeService: ThemeService = ThemeService.getInstance();

  aboutToAppear() {
    this.updatePreview();
    
    this.themeService.onThemeChange((theme: Theme) => {
      this.currentTheme = theme;
      this.updatePreview();
    });
  }

  private updatePreview() {
    const contentHtml = this.markdownService.convertToHtml(this.markdown);
    this.html = this.wrapHtml(contentHtml);
  }

  private wrapHtml(content: string): string {
    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
      font-size: 16px;
      line-height: 1.6;
      color: ${this.currentTheme.colors.text};
      background-color: ${this.currentTheme.colors.background};
      padding: 20px;
    }
    h1, h2, h3, h4, h5, h6 {
      margin-top: 24px;
      margin-bottom: 16px;
      font-weight: 600;
      line-height: 1.25;
      color: ${this.currentTheme.colors.text};
    }
    h1 { font-size: 2em; border-bottom: 1px solid ${this.currentTheme.colors.border}; padding-bottom: 0.3em; }
    h2 { font-size: 1.5em; border-bottom: 1px solid ${this.currentTheme.colors.border}; padding-bottom: 0.3em; }
    h3 { font-size: 1.25em; }
    p {
      margin-bottom: 16px;
    }
    a {
      color: ${this.currentTheme.colors.primary};
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    code {
      padding: 2px 6px;
      font-size: 85%;
      background-color: ${this.currentTheme.colors.surface};
      border-radius: 3px;
      font-family: "SF Mono", Monaco, Consolas, monospace;
    }
    pre {
      padding: 16px;
      overflow: auto;
      font-size: 85%;
      line-height: 1.45;
      background-color: ${this.currentTheme.editor.background};
      border-radius: 6px;
      margin-bottom: 16px;
    }
    pre code {
      padding: 0;
      background-color: transparent;
      color: ${this.currentTheme.editor.text};
    }
    ul, ol {
      padding-left: 2em;
      margin-bottom: 16px;
    }
    li {
      margin-bottom: 4px;
    }
    blockquote {
      padding: 0 1em;
      color: ${this.currentTheme.colors.textSecondary};
      border-left: 4px solid ${this.currentTheme.colors.border};
      margin-bottom: 16px;
    }
    img {
      max-width: 100%;
      height: auto;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      margin-bottom: 16px;
    }
    table th, table td {
      padding: 8px 12px;
      border: 1px solid ${this.currentTheme.colors.border};
    }
    table th {
      background-color: ${this.currentTheme.colors.surface};
      font-weight: 600;
    }
    strong {
      font-weight: 600;
    }
    em {
      font-style: italic;
    }
  </style>
</head>
<body>
  ${content}
</body>
</html>
    `;
  }

  build() {
    Column() {
      // 使用 Web 组件显示 HTML
      Web({ src: 'about:blank' })
        .width('100%')
        .height('100%')
        .onPageEnd(() => {
          // 页面加载完成后，注入 HTML 内容
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme.colors.background)
  }
}

