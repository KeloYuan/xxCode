---
inclusion: always
---

# HarmonyOS 项目结构指南

## 项目架构概览
这是一个 HarmonyOS 应用项目，使用 ArkTS 开发语言。项目采用标准的 HarmonyOS 目录结构。

## 主要目录结构

### 应用配置
- [AppScope/app.json5](mdc:AppScope/app.json5) - 应用全局配置
- [build-profile.json5](mdc:build-profile.json5) - 构建配置文件
- [oh-package.json5](mdc:oh-package.json5) - 项目依赖管理

### 主模块入口
- [entry/](mdc:entry/) - 主模块目录
- [entry/src/main/ets/](mdc:entry/src/main/ets/) - ArkTS 源码目录

### 核心源码文件
- **页面** [pages/](mdc:entry/src/main/ets/pages/) - 应用页面，如 [Index.ets](mdc:entry/src/main/ets/pages/Index.ets), [CodeEditor.ets](mdc:entry/src/main/ets/pages/CodeEditor.ets)
- **组件** [components/](mdc:entry/src/main/ets/components/) - 可复用组件
- **服务** [services/](mdc:entry/src/main/ets/services/) - 业务逻辑服务
- **模型** [models/](mdc:entry/src/main/ets/models/) - 数据模型
- **能力** [entryability/](mdc:entry/src/main/ets/entryability/) - UIAbility 入口

### 资源文件
- [entry/src/main/resources/](mdc:entry/src/main/resources/) - 资源文件目录
- [entry/src/main/resources/base/element/](mdc:entry/src/main/resources/base/element/) - 基础资源（颜色、字符串、尺寸）
- [entry/src/main/resources/dark/element/](mdc:entry/src/main/resources/dark/element/) - 深色主题资源

### 模块配置
- [entry/src/main/module.json5](mdc:entry/src/main/module.json5) - 模块配置文件

## 文件命名规范
- 页面文件：使用 PascalCase，如 `Index.ets`, `CodeEditor.ets`
- 组件文件：使用 PascalCase，如 `HighlightedText.ets`
- 服务文件：使用 PascalCase + Service 后缀，如 `FileService.ets`
- 模型文件：使用 PascalCase + Model 后缀，如 `FileModel.ets`

## 依赖管理
- [oh_modules/](mdc:oh_modules/) - HarmonyOS 依赖包目录
- 当前项目依赖测试框架：@ohos/hamock, @ohos/hypium