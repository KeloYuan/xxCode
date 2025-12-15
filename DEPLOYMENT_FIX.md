# HarmonyOS 部署问题解决方案

## 问题描述
```
Error: Read-only file system
ErrorCode: 00404039
ErrorDescription: Failed to create temporary directory during hap push operation.
```

## 原因分析
设备的 `/data/local/tmp/` 目录是只读的，导致无法创建临时目录来推送 HAP 包。

## 解决方案

### 方案 1：重启设备（推荐）
最简单有效的方法：

1. **重启 HarmonyOS 设备**
   - 长按电源键
   - 选择"重启"
   - 等待设备重启完成

2. **重新连接设备**
   ```bash
   # 检查设备连接
   hdc list targets
   
   # 如果没有设备，重新连接
   hdc kill
   hdc start
   ```

3. **重新部署应用**
   - 在 DevEco Studio 中点击运行按钮
   - 或使用命令：`hvigorw assembleHap --mode module -p module=entry@default -p product=default`

### 方案 2：清理临时目录
如果重启不方便，尝试清理临时目录：

```bash
# 停止应用
hdc shell aa force-stop com.niki.xxcode

# 清理临时目录（需要 root 权限）
hdc shell rm -rf /data/local/tmp/*

# 重新部署
```

### 方案 3：使用模拟器
如果是真机问题，可以先在模拟器上测试：

1. 打开 DevEco Studio
2. 工具栏 → Device Manager
3. 创建或启动 HarmonyOS 模拟器
4. 选择模拟器作为部署目标

### 方案 4：检查设备权限
确保设备处于开发者模式：

1. **进入开发者选项**
   - 设置 → 关于手机
   - 连续点击"版本号" 7 次
   - 返回设置，找到"开发者选项"

2. **启用必要权限**
   - ✅ USB 调试
   - ✅ 允许通过 USB 安装应用
   - ✅ USB 调试（安全设置）

3. **重新授权**
   ```bash
   hdc kill
   hdc start
   # 设备上会弹出授权提示，点击"允许"
   ```

### 方案 5：使用无线调试
如果 USB 连接有问题，可以使用无线调试：

1. **设备和电脑连接同一 WiFi**

2. **获取设备 IP 地址**
   - 设置 → WLAN → 点击已连接的网络
   - 查看 IP 地址（如：192.168.1.100）

3. **连接设备**
   ```bash
   hdc tconn 192.168.1.100:5555
   hdc list targets
   ```

4. **部署应用**

## 验证解决方案

部署成功的标志：
```
✅ BUILD SUCCESSFUL
✅ Install Hap to device success
✅ Launch com.niki.xxcode success
```

## 常见问题

### Q1: hdc 命令找不到
**解决方法：**
- 确保 HarmonyOS SDK 已正确安装
- 将 SDK 的 `toolchains` 目录添加到系统 PATH
- 路径示例：`C:\Users\YourName\AppData\Local\Huawei\Sdk\openharmony\[version]\toolchains`

### Q2: 设备列表为空
**解决方法：**
```bash
# 重启 hdc 服务
hdc kill
hdc start

# 检查设备连接
hdc list targets

# 如果还是空的，检查 USB 线和驱动
```

### Q3: 授权失败
**解决方法：**
- 拔掉 USB 线重新插入
- 在设备上撤销之前的授权（开发者选项 → 撤销 USB 调试授权）
- 重新连接并授权

### Q4: 应用安装失败
**解决方法：**
```bash
# 卸载旧版本
hdc shell bm uninstall -n com.niki.xxcode

# 清理缓存
hdc shell rm -rf /data/app/el1/bundle/public/com.niki.xxcode

# 重新安装
```

## 最佳实践

1. **定期重启设备**：开发过程中定期重启设备可以避免很多问题

2. **使用模拟器开发**：初期开发使用模拟器，稳定后再真机测试

3. **保持 SDK 更新**：定期更新 HarmonyOS SDK 和 DevEco Studio

4. **检查磁盘空间**：确保设备有足够的存储空间（至少 500MB）

5. **使用稳定的 USB 线**：劣质 USB 线可能导致连接不稳定

## 项目编译状态

✅ **代码编译成功**
```
BUILD SUCCESSFUL in 305 ms
0 错误，8 警告
```

✅ **所有功能组件正常**
- CodeEditor.ets - 文件侧栏完善
- FileTreeItem.ets - 文件树项组件
- FileContextMenu.ets - 右键菜单
- InputDialog.ets - 输入对话框
- TabletCodeEditor.ets - 平板编辑器
- EditorStatusBar.ets - 状态栏

## 下一步

1. 按照上述方案解决部署问题
2. 成功部署后测试文件侧栏功能
3. 验证右键菜单、新建、重命名、删除等操作

---
**更新时间**: 2024-12-10
**状态**: 代码完成，等待部署测试
