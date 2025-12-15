# PowerShell 终端错误修复指南

## 错误信息
```
Exit code: -2147023895 (0x80070005)
错误含义: 拒绝访问 (Access Denied)
```

## 解决方案

### 方案 1：修改 PowerShell 执行策略（推荐）

1. **以管理员身份运行 PowerShell**
   - 按 `Win + X`
   - 选择"Windows PowerShell (管理员)"或"终端 (管理员)"

2. **检查当前执行策略**
   ```powershell
   Get-ExecutionPolicy
   ```

3. **设置执行策略为 RemoteSigned**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
   
   当提示确认时，输入 `Y` 并回车

4. **验证设置**
   ```powershell
   Get-ExecutionPolicy
   # 应该显示: RemoteSigned
   ```

### 方案 2：临时绕过执行策略

在 VS Code 或 DevEco Studio 的终端中运行：

```powershell
powershell -ExecutionPolicy Bypass -File "your_script.ps1"
```

### 方案 3：修改 VS Code/DevEco Studio 终端配置

1. **打开设置**
   - 按 `Ctrl + ,` 打开设置
   - 搜索 "terminal.integrated.shellArgs"

2. **添加 PowerShell 参数**
   
   在 `settings.json` 中添加：
   ```json
   {
     "terminal.integrated.profiles.windows": {
       "PowerShell": {
         "source": "PowerShell",
         "args": ["-ExecutionPolicy", "Bypass"]
       }
     },
     "terminal.integrated.defaultProfile.windows": "PowerShell"
   }
   ```

### 方案 4：使用 CMD 代替 PowerShell

1. **修改默认终端为 CMD**
   
   在 `settings.json` 中：
   ```json
   {
     "terminal.integrated.defaultProfile.windows": "Command Prompt"
   }
   ```

2. **或者手动切换**
   - 点击终端右上角的 `+` 旁边的下拉箭头
   - 选择 "Command Prompt"

### 方案 5：检查防病毒软件

某些防病毒软件会阻止 PowerShell 脚本执行：

1. **临时禁用防病毒软件**
2. **将项目目录添加到白名单**
3. **将 PowerShell 添加到信任列表**

## HarmonyOS 开发特定解决方案

### 使用 hvigorw.bat 代替 PowerShell

在项目根目录，直接使用批处理文件：

```cmd
# 编译项目
hvigorw.bat assembleHap --mode module -p module=entry@default -p product=default

# 清理项目
hvigorw.bat clean
```

### 配置 DevEco Studio 使用 CMD

1. **打开 DevEco Studio 设置**
   - File → Settings → Tools → Terminal

2. **修改 Shell path**
   ```
   C:\Windows\System32\cmd.exe
   ```

3. **重启终端**

## 验证解决方案

运行以下命令测试：

```powershell
# 测试 PowerShell 执行
Write-Host "PowerShell 工作正常"

# 测试 hvigorw
hvigorw --version

# 测试编译
hvigorw assembleHap --mode module -p module=entry@default -p product=default
```

## 常见问题

### Q1: 没有管理员权限怎么办？

**解决方法：**
使用方案 2 或方案 4，不需要管理员权限

### Q2: 设置后仍然报错

**解决方法：**
1. 完全关闭 VS Code/DevEco Studio
2. 重新打开
3. 打开新的终端窗口

### Q3: 公司电脑有组策略限制

**解决方法：**
- 使用 CMD 代替 PowerShell（方案 4）
- 或联系 IT 管理员申请权限

### Q4: 每次都要重新设置

**解决方法：**
确保使用 `-Scope CurrentUser` 参数，这样设置会永久生效

## 推荐配置

### DevEco Studio 终端配置

在项目根目录创建 `.vscode/settings.json`（如果使用 VS Code）：

```json
{
  "terminal.integrated.profiles.windows": {
    "PowerShell": {
      "source": "PowerShell",
      "args": ["-NoProfile", "-ExecutionPolicy", "Bypass"]
    },
    "Command Prompt": {
      "path": "C:\\Windows\\System32\\cmd.exe",
      "args": []
    }
  },
  "terminal.integrated.defaultProfile.windows": "Command Prompt"
}
```

### 项目脚本快捷方式

创建 `build.bat` 文件：

```batch
@echo off
echo 正在编译 HarmonyOS 项目...
call hvigorw.bat assembleHap --mode module -p module=entry@default -p product=default
if %ERRORLEVEL% EQU 0 (
    echo 编译成功！
) else (
    echo 编译失败，错误码: %ERRORLEVEL%
)
pause
```

创建 `clean.bat` 文件：

```batch
@echo off
echo 正在清理项目...
call hvigorw.bat clean
echo 清理完成！
pause
```

## 快速解决步骤

**最快的解决方法（3 步）：**

1. **以管理员身份打开 PowerShell**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **重启 DevEco Studio**

3. **重新打开终端并测试**
   ```cmd
   hvigorw --version
   ```

## 项目状态

✅ **代码已完成**
- 所有文件编译通过
- 功能实现完整
- 文档齐全

✅ **编译成功**
```
BUILD SUCCESSFUL in 305 ms
```

⚠️ **待解决**
- PowerShell 权限问题（按上述方案解决）
- 设备部署问题（参考 DEPLOYMENT_FIX.md）

---
**更新时间**: 2024-12-10
**状态**: 等待权限配置
