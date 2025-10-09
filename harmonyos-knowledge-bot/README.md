# 🤖 HarmonyOS 知识库自动化学习机器人

这是一个自动化工具，可以持续从网络上学习最新的 HarmonyOS Next 开发知识，并自动更新知识库。

## 🎯 功能特性

- ✅ **自动搜索** - 定期搜索最新的鸿蒙开发资料
- ✅ **智能爬取** - 爬取官方文档、博客、示例代码
- ✅ **内容分析** - 使用 AI 分析和提取关键信息
- ✅ **自动生成** - 自动生成 Markdown 格式的知识文档
- ✅ **去重检测** - 避免重复内容
- ✅ **质量评估** - 只保留高质量的内容
- ✅ **定时更新** - 可设置定时任务自动运行

## 📦 安装依赖

```bash
pip install -r requirements.txt
```

## 🚀 使用方法

### 方式 1: 手动运行

```bash
# 搜索并学习新知识
python knowledge_bot.py --mode search --topic "HarmonyOS 动画"

# 爬取官方文档
python knowledge_bot.py --mode crawl --url "https://developer.harmonyos.com"

# 分析 Gitee 仓库
python knowledge_bot.py --mode analyze --repo "harmonyos_samples"
```

### 方式 2: 自动定时运行

```bash
# 启动自动学习（每天运行一次）
python knowledge_bot.py --mode auto --schedule daily

# 启动自动学习（每周运行一次）
python knowledge_bot.py --mode auto --schedule weekly
```

### 方式 3: 交互式运行

```bash
python knowledge_bot.py
```

## 📋 配置文件

编辑 `config.json` 配置学习参数：

```json
{
  "search_topics": [
    "HarmonyOS Next 新特性",
    "ArkTS 最佳实践",
    "鸿蒙组件开发",
    "HarmonyOS 性能优化",
    "鸿蒙动画技巧"
  ],
  "sources": {
    "official_docs": "https://developer.harmonyos.com",
    "gitee": "https://gitee.com/harmonyos_samples",
    "blogs": [
      "https://harmonyos.51cto.com",
      "https://blog.csdn.net"
    ]
  },
  "output_dir": "../harmonyos-knowledge",
  "schedule": {
    "enabled": true,
    "frequency": "daily",
    "time": "02:00"
  },
  "quality_threshold": 0.7,
  "max_documents_per_run": 5
}
```

## 🔧 工作流程

```
1. 搜索新内容
   ├─ 搜索引擎查询
   ├─ Gitee 仓库监控
   └─ 官方文档更新检测

2. 内容爬取
   ├─ 网页内容提取
   ├─ 代码示例提取
   └─ 图片资源下载

3. 内容分析
   ├─ 关键信息提取
   ├─ 代码格式化
   ├─ 结构化整理
   └─ 质量评分

4. 去重检测
   ├─ 标题相似度
   ├─ 内容相似度
   └─ 代码相似度

5. 生成文档
   ├─ Markdown 格式化
   ├─ 代码高亮
   ├─ 链接整理
   └─ 保存到知识库

6. 更新索引
   ├─ 更新 00-INDEX.md
   ├─ 更新 README.md
   └─ 生成变更日志
```

## 📊 输出示例

运行后会在知识库中自动创建新文档：

```
harmonyos-knowledge/
├── 15-arkui-advanced-tips.md          [新增] ArkUI 高级技巧
├── 16-performance-optimization.md     [新增] 性能优化实战
├── 17-harmonyos-design-patterns.md    [新增] 设计模式
└── changelog.md                       [更新] 变更日志
```

## 🎨 自定义学习主题

可以在配置文件中添加自定义学习主题：

```json
{
  "custom_topics": [
    {
      "name": "分布式能力",
      "keywords": ["分布式", "多端协同", "设备管理"],
      "priority": "high"
    },
    {
      "name": "UI 动效",
      "keywords": ["动画", "转场", "粒子效果"],
      "priority": "medium"
    }
  ]
}
```

## 📈 统计报告

每次运行后会生成统计报告：

```
=== 学习报告 ===
运行时间: 2025-10-09 14:30:00
搜索主题: 5 个
发现内容: 23 条
有效内容: 15 条
重复内容: 5 条
低质量: 3 条
新增文档: 3 个
更新文档: 2 个
代码示例: 12 个
```

## ⚠️ 注意事项

1. 请遵守网站的 robots.txt 和爬取规则
2. 建议设置合理的爬取间隔，避免对服务器造成压力
3. 生成的内容需要人工审核后再使用
4. 定期备份知识库
5. API 密钥需要保存在环境变量中

## 🛠️ 高级功能

### AI 辅助分析

启用 AI 分析功能（需要 OpenAI API Key）：

```bash
export OPENAI_API_KEY="your-api-key"
python knowledge_bot.py --mode ai-analyze
```

### 代码质量检测

对爬取的代码进行质量检测：

```bash
python knowledge_bot.py --mode check-code
```

### 知识图谱生成

生成知识点关系图：

```bash
python knowledge_bot.py --mode generate-graph
```

## 📝 开发计划

- [ ] 支持更多数据源（Stack Overflow, GitHub）
- [ ] AI 智能摘要和翻译
- [ ] 自动生成思维导图
- [ ] 知识点关联分析
- [ ] 学习进度追踪
- [ ] Web 管理界面

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

