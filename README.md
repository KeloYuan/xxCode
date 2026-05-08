<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1b26,100:0d1117&height=200&section=header&text=xxCode&fontSize=50&fontColor=9ece6a&fontAlignY=40&desc=Native%20HarmonyOS%20Lightweight%20Code%20Editor&descSize=16&descAlignY=60&descAlign=50&animation=fadeIn" width="100%" />
</p>

<p align="center">
  <a href="https://github.com/KeloYuan/xxCode/stargazers"><img src="https://img.shields.io/github/stars/KeloYuan/xxCode?style=for-the-badge&color=e0af68" /></a>
  <a href="https://github.com/KeloYuan/xxCode/blob/main/LICENSE"><img src="https://img.shields.io/github/license/KeloYuan/xxCode?style=for-the-badge&color=9ece6a" /></a>
  <img src="https://img.shields.io/badge/HarmonyOS-5.0+-000?style=for-the-badge&logo=huawei&logoColor=white" />
  <img src="https://img.shields.io/badge/ArkTS-Powered-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Platform-Phone%20%7C%20Tablet%20%7C%202-in--1-brightgreen?style=for-the-badge" />
</p>

<p align="center">
  <b>原生鸿蒙开源轻量代码编辑器 — 为 HarmonyOS 5 深度定制</b><br/>
  <i>A native, lightweight code editor built from scratch for HarmonyOS 5.</i>
</p>

---

## 🎯 Why xxCode?

> HarmonyOS 生态缺少一款真正原生的代码编辑器。<br/>
> xxCode 用 ArkTS 从零构建，深度集成鸿蒙系统能力，给开发者一个在鸿蒙设备上写代码的选择。

---

## ✨ Features

### Core Editor
| Feature | Description |
|---------|-------------|
| 📑 **Multi-Tab** | 多标签页同时编辑多个文件 |
| 🌲 **File Tree** | 树状文件导航，支持展开/折叠 |
| 🎨 **Syntax Highlighting** | JS · TS · Python · Java · C++ · Go · Rust 等主流语言 |
| 📝 **Markdown Preview** | 智能检测 Markdown，实时预览 |
| 🔍 **Full-Text Search** | 搜索文件内容和文件名，带搜索建议 |
| ⚙️ **Code Formatting** | 智能代码格式化和缩进管理 |

### Experience
| Feature | Description |
|---------|-------------|
| 🎭 **3 Themes** | 浅色 · 深色 · 鸿蒙原生主题切换 |
| 🏗️ **Native HarmonyOS** | 深度集成鸿蒙系统能力，原生体验 |
| ⚡ **High Performance** | 基于原生技术栈，启动快、占用低 |
| 🧩 **Modular Architecture** | 清晰分层架构，易于扩展 |

---

## 📱 Supported Devices

<table>
  <tr>
    <td align="center"><img src="https://img.shields.io/badge/📱_Phone-000?style=for-the-badge&logo=huawei&logoColor=white" /></td>
    <td align="center"><img src="https://img.shields.io/badge/📟_Tablet-000?style=for-the-badge&logo=huawei&logoColor=white" /></td>
    <td align="center"><img src="https://img.shields.io/badge/💻_2-in-1-000?style=for-the-badge&logo=huawei&logoColor=white" /></td>
  </tr>
</table>

---

## 📦 Tech Stack

```
Framework   → ArkTS + eTS
Target OS   → HarmonyOS 5.0+
IDE         → DevEco Studio
Design      → Material You / HarmonyOS Design
Language    → TypeScript
```

---

## 🏗️ Project Structure

```
xxCode/
├── AppScope/          # 应用级配置
├── entry/             # 主模块
│   └── src/
│       └── main/
│           └── ets/   # ArkTS 源码
├── hvigor/            # 构建工具配置
├── build.sh           # 构建脚本
├── build-profile.json5 # 构建配置
├── oh-package.json5   # 包管理
└── code-linter.json5  # 代码规范
```

---

## 🚀 Getting Started

### Prerequisites
- **DevEco Studio** 5.0+
- **HarmonyOS** SDK 5.0+

### Build & Run

```bash
# 克隆项目
git clone https://github.com/KeloYuan/xxCode.git

# 用 DevEco Studio 打开项目
# 或使用命令行构建
./build.sh
```

### Development Phases

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1 | ✅ Done | 基础框架搭建 |
| Phase 2 | ✅ Done | 核心编辑功能 |
| Phase 3 | ✅ Done | 高级功能开发 |
| Phase 4 | ✅ Done | 代码优化 & 编译修复 |
| Phase 5 | ✅ Done | 构建测试通过 |

---

## 📸 Screenshots

<p align="center">
  <img src="元代码.png" width="80%" />
</p>

---

## 📊 Star History

<a href="https://star-history.com/#KeloYuan/xxCode&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=KeloYuan/xxCode&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=KeloYuan/xxCode&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=KeloYuan/xxCode&type=Date" width="100%" />
 </picture>
</a>

---

## 📄 License

[MIT](LICENSE) © [Niki / KeloYuan](https://github.com/KeloYuan)

---

<p align="center">
  <b>xxCode</b> — <i>Code on HarmonyOS, natively.</i><br/><br/>
  ⭐ Star this repo if you believe in the HarmonyOS developer ecosystem!
</p>
