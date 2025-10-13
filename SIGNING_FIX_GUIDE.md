# HarmonyOS 签名配置修复指南

## 问题现象
```
Install Failed: error: failed to install bundle.
code:9568320
error: no signature file.
```

## 解决方案

### ✅ 方法 1: 自动签名（推荐）

#### 步骤 1: 打开签名配置
1. 在 DevEco Studio 中打开项目
2. 点击菜单 `File` → `Project Structure`
3. 或点击错误提示中的 **"Open signing configs"**

#### 步骤 2: 启用自动签名
1. 在左侧选择 `Project` → `Signing Configs`
2. 勾选 ✅ **"Automatically generate signature"**
3. 选择 **Support HarmonyOS**
4. 点击 **Sign In** 按钮

#### 步骤 3: 登录华为账号
1. 使用您的华为账号登录
2. 如果没有账号，先注册一个
3. 登录成功后，系统会自动生成签名文件

#### 步骤 4: 应用配置
1. 点击 **Apply**
2. 点击 **OK**
3. 等待签名文件生成

#### 步骤 5: 重新构建
1. 清理项目：`Build` → `Clean Project`
2. 重新构建：`Build` → `Rebuild Project`
3. 运行应用：点击运行按钮 ▶️

---

### ✅ 方法 2: 手动配置签名

如果自动签名失败，可以手动配置：

#### 步骤 1: 生成签名文件

在 DevEco Studio 中：
1. `Build` → `Generate Key and CSR`
2. 填写信息：
   - Key Alias: `debugKey`
   - Password: `123456` (或自定义)
   - Validity: `25` (年)
   - First and Last Name: 您的名字
   - Organization: `Debug`
   - City: `Beijing`
   - State: `Beijing`
   - Country Code: `CN`
3. 保存到：`C:\Users\YourName\.ohos\config\`

#### 步骤 2: 申请调试证书

1. 访问 [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)
2. 创建项目（如果没有）
3. 在 `应用服务` → `证书管理` 中申请调试证书
4. 下载证书文件（.cer 和 .p7b）

#### 步骤 3: 更新配置文件

修改 `build-profile.json5`，将路径更新为您的文件路径：

```json5
{
  "app": {
    "signingConfigs": [
      {
        "name": "default",
        "type": "HarmonyOS",
        "material": {
          "certpath": "C:/Users/YourName/.ohos/config/debugCert.cer",
          "keyAlias": "debugKey",
          "keyPassword": "00000019...",  // 加密后的密码
          "profile": "C:/Users/YourName/.ohos/config/debugProfile.p7b",
          "signAlg": "SHA256withECDSA",
          "storeFile": "C:/Users/YourName/.ohos/config/debugKey.p12",
          "storePassword": "00000019..."  // 加密后的密码
        }
      }
    ]
  }
}
```

**注意**: 使用正斜杠 `/` 而不是反斜杠 `\`

---

### ✅ 方法 3: 使用临时签名（最快）

对于快速测试，可以使用 DevEco Studio 的临时签名：

1. **移除签名配置**
   ```json5
   {
     "name": "default",
     // "signingConfig": "default",  // 注释掉
   }
   ```

2. **使用模拟器**
   - DevEco Studio 的模拟器可以运行未签名的应用
   - 但真机必须签名

3. **或者临时签名**
   - 右键项目 → `Build` → `Build Hap(s)/APP(s)`
   - 选择 `Build Debug Hap(s)`
   - DevEco 会自动使用临时签名

---

## 常见问题

### Q1: 提示"签名文件不存在"
**A**: 签名文件路径错误或文件不存在
- 检查路径是否正确
- 确保使用正斜杠 `/`
- 使用绝对路径

### Q2: 提示"签名验证失败"
**A**: 签名配置不匹配
- 确保证书和 profile 匹配
- 重新生成签名文件
- 检查密码是否正确

### Q3: 自动签名失败
**A**: 网络或账号问题
- 检查网络连接
- 确保华为账号已实名认证
- 尝试退出重新登录

### Q4: 真机安装失败
**A**: 设备未授权
- 在 AppGallery Connect 添加设备 UDID
- 重新下载 profile 文件
- 确保 profile 包含该设备

---

## 推荐配置

### 开发环境配置

**Windows 路径示例**:
```
C:/Users/YourName/.ohos/config/
├── debugKey.p12          # 密钥文件
├── debugCert.cer         # 证书文件
└── debugProfile.p7b      # Profile 文件
```

**建议**:
- ✅ 使用自动签名（最简单）
- ✅ 开发阶段使用调试证书
- ✅ 发布时使用发布证书
- ✅ 妥善保管签名文件

---

## 验证签名配置

运行以下命令验证签名是否正确：

```bash
# 查看 HAP 签名信息
hdc shell bm dump -n com.niki.xxcode
```

成功输出应包含签名信息。

---

## 参考资源

- [HarmonyOS 签名指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/ohos-signing-tool-0000001060684880)
- [AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)
- [证书申请流程](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/ohos-auto-configuring-signature-information-0000001271659465)

---

**完成以上配置后，应用应该可以正常安装运行！** ✅

