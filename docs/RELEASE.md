# DDL out! 发布说明

## 质量门槛

从 `ddl_out_flutter/` 运行：

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release
```

## Windows

Windows 构建依赖 Visual Studio 2022 C++ 桌面工作负载和 Windows 开发者模式。
发布时压缩 `build/windows/x64/runner/Release/` 的全部内容，产物命名为
`ddl-out-v<version>-windows-x64.zip`，不能只分发 exe。

## Android 签名

生成上传密钥并妥善离线备份：

```powershell
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 4096 -validity 10000 -alias upload
```

在 `ddl_out_flutter/android/key.properties` 写入：

```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=upload
storeFile=<absolute path to upload-keystore.jks>
```

密钥、密码和 `key.properties` 已被 Git 忽略。缺少该文件时本地及 CI 会使用
调试密钥生成可安装的验证包；对外正式发布必须提供 release 密钥。

本机首发密钥已生成在
`C:\Users\27950\.ddl-out-signing\ddl-out-release.jks`，凭据保存在被 Git
忽略的 `ddl_out_flutter/android/key.properties`。发布前必须将这两个文件
一起离线备份；丢失密钥后无法用同一应用身份发布升级包。

GitHub Actions 正式签名使用以下 Secrets：

- `ANDROID_KEYSTORE_BASE64`：JKS 文件的 Base64 内容
- `ANDROID_STORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

APK 位于 `build/app/outputs/flutter-apk/app-release.apk`，发布命名为
`ddl-out-v<version>-android.apk`。

Flutter 3.44.6 使用 AGP 9 兼容模式时，`dynamic_color 1.8.1` 与
`file_picker 10.3.10` 共用旧 Kotlin Gradle Plugin。升级到 `file_picker 11`
前，应先确认 `dynamic_color` 已迁移到 AGP 内建 Kotlin。

## 数据兼容

升级前可从设置页导出 JSON。恢复会校验格式后整库替换，不会修改备份文件；
高于当前 `schemaVersion` 的备份会被拒绝。
