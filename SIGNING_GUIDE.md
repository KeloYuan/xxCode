# HarmonyOS 应用签名配置指南

## 问题说明

错误信息：
```
Install Failed: error: failed to install bundle.
code:9568320
error: no signature file.
```

这是因为 HarmonyOS 应用必须经过签名才能安装到设备上。

## 解决方案

### 方案一：使用 DevEco Studio 自动签名（推荐）

#### 1. 配置自动签名

1. **打开 DevEco Studio**
2. **打开项目** `/Users/xiaoyuan/xxCode`
3. **进入签名配置**：
   - 点击菜单：`File` → `Project Structure`
   - 或使用快捷键：`⌘;` (Mac) / `Ctrl+Alt+Shift+S` (Windows)
4. **配置签名**：
   - 在左侧面板选择 `Signing Configs`
   - 在 `Modules` 列表中选择 `entry`
   - 勾选 ✅ `Automatically generate signature`
   - 如果提示登录华为开发者账号，请完成登录
   - 点击 `Apply` 然后 `OK`

#### 2. 签名文件位置

DevEco Studio 会自动生成以下文件到：
```
~/.ohos/config/auto_debug_xxcode.cer
~/.ohos/config/auto_debug_xxcode.p7b  
~/.ohos/config/auto_debug_xxcode.p12
```

#### 3. 重新构建项目

- **清理项目**：`Build` → `Clean Project`
- **重新构建**：`Build` → `Rebuild Project`
- **运行应用**：点击 ▶️ 运行按钮或 `Run` → `Run 'entry'`

### 方案二：手动配置签名

如果您已经有签名文件，可以手动配置：

1. **准备签名文件**：
   - `.p12` 文件（密钥库）
   - `.cer` 文件（证书）
   - `.p7b` 文件（Profile 文件）

2. **修改 build-profile.json5**：

已为您配置好签名配置，只需要确保签名文件存在即可。

当前配置：
```json5
"signingConfigs": [
  {
    "name": "default",
    "type": "HarmonyOS",
    "material": {
      "certpath": "~/.ohos/config/auto_debug_xxcode.cer",
      "storePassword": "...",
      "keyAlias": "debugKey",
      "keyPassword": "...",
      "profile": "~/.ohos/config/auto_debug_xxcode.p7b",
      "signAlg": "SHA256withECDSA",
      "storeFile": "~/.ohos/config/auto_debug_xxcode.p12"
    }
  }
]
```

## 常见问题

### Q1: 没有华为开发者账号怎么办？

**答**：您需要注册华为开发者账号才能获取签名证书。

1. 访问：https://developer.huawei.com
2. 注册账号（个人或企业）
3. 完成实名认证
4. 在 DevEco Studio 中登录该账号

### Q2: 自动签名失败怎么办？

**答**：检查以下几点：

1. **检查网络连接**：确保能访问华为开发者服务器
2. **检查账号状态**：确保已完成实名认证
3. **检查应用包名**：在 `AppScope/app.json5` 中检查 `bundleName` 是否合法
4. **重新登录**：在 DevEco Studio 中退出并重新登录华为账号

### Q3: 如何验证签名是否配置成功？

**答**：构建项目后检查：

```bash
# 检查签名文件是否存在
ls -la ~/.ohos/config/auto_debug_xxcode.*

# 应该看到以下文件：
# auto_debug_xxcode.cer
# auto_debug_xxcode.p12
# auto_debug_xxcode.p7b
```

### Q4: 命令行如何配置签名？

**答**：命令行构建需要确保签名文件存在。建议：

1. 先在 DevEco Studio 中配置自动签名（生成签名文件）
2. 之后可以使用命令行工具构建

## 配置 HDC 工具（可选）

如果您想使用命令行部署，需要配置 `hdc` 工具：

### macOS 配置

1. **找到 HDC 工具路径**（通常在 DevEco Studio 安装目录）：
   ```bash
   # 常见路径
   ~/Library/Huawei/sdk/HarmonyOS-NEXT-*/openharmony/toolchains
   ```

2. **添加到 PATH**：
   
   编辑 `~/.zshrc`（如果使用 bash，则编辑 `~/.bash_profile`）：
   ```bash
   export PATH="$PATH:~/Library/Huawei/sdk/HarmonyOS-NEXT-*/openharmony/toolchains"
   ```

3. **生效配置**：
   ```bash
   source ~/.zshrc
   ```

4. **验证安装**：
   ```bash
   hdc -v
   ```

## 下一步

配置完签名后，您可以：

1. ✅ 使用 DevEco Studio 直接运行应用
2. ✅ 使用 `./run.sh` 脚本构建和部署（需要配置 hdc）
3. ✅ 使用 DevEco Studio 的命令行工具构建

---

**注意**：调试签名（Debug Signature）仅用于开发测试，正式发布应用需要使用发布签名（Release Signature）。
