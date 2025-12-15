---
inclusion: manual
---

# HarmonyOS 项目 Cursor Rules 指南

## 规则文件概览

本项目包含完整的 HarmonyOS 开发 Cursor Rules，确保代码质量和开发规范：

### 🏗️ 项目结构
- [project-structure.mdc](mdc:.cursor/rules/project-structure.mdc) - 项目整体架构和目录结构指南

### 🎨 UI 开发规范  
- [harmonyos-development.mdc](mdc:.cursor/rules/harmonyos-development.mdc) - HarmonyOS ArkTS 核心开发规范
- [component-development.mdc](mdc:.cursor/rules/component-development.mdc) - 组件开发最佳实践
- [page-development.mdc](mdc:.cursor/rules/page-development.mdc) - 页面开发和路由管理

### 🔧 后端架构
- [services-models.mdc](mdc:.cursor/rules/services-models.mdc) - 服务层和数据模型开发规范

### 🧪 测试规范
- [testing-standards.mdc](mdc:.cursor/rules/testing-standards.mdc) - 测试开发规范和最佳实践

## 规则应用策略

### 自动应用规则
- **项目结构指南** - 适用于所有文件，提供项目架构概览

### 文件类型特定规则
- **ArkTS 文件 (*.ets)** - 自动应用 HarmonyOS 开发规范
- **组件文件** - 自动应用组件开发最佳实践  
- **页面文件** - 自动应用页面开发规范
- **服务和模型文件** - 自动应用后端架构规范
- **测试文件** - 自动应用测试开发规范

### 手动引用规则
- **README 指南** - 需要手动引用时查看

## 核心开发原则

### ✅ 推荐做法
- 使用最新的 HarmonyOS Design 设计语言
- 优先使用官方 ArkUI 组件
- 遵循现代化 UI/UX 设计原则
- 实现响应式布局和主题适配
- 编写可测试、可维护的代码

### ❌ 禁止事项
- 使用已弃用或非官方组件
- 创建简陋的基础布局界面
- 在不确定时臆造 API
- 忽略错误处理和性能优化

## 开发工作流

1. **开始开发** - 查看项目结构规则了解架构
2. **创建页面** - 参考页面开发规范
3. **编写组件** - 遵循组件开发最佳实践  
4. **实现服务** - 按照服务层规范设计
5. **编写测试** - 使用测试标准确保质量

这些规则将帮助您构建高质量、符合 HarmonyOS 标准的应用程序。