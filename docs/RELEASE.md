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

CI 在对 `main` 的推送和 Pull Request 上运行依赖解析、代码生成检查、格式化、
静态分析、测试、Windows 构建和 Android 构建。只有这些检查通过的改动才应合并。

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

请将密钥与 `key.properties` 保存在仓库外的安全位置，并进行离线备份。丢失密钥后
无法使用同一应用身份发布升级包。

GitHub Actions 正式签名使用以下 Secrets：

- `ANDROID_KEYSTORE_BASE64`：JKS 文件的 Base64 内容
- `ANDROID_STORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

推送与 `pubspec.yaml` 中应用版本一致的标签会触发正式发布。例如版本为
`0.1.0+1` 时：

```powershell
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0
```

发布工作流要求上述 Android 签名 Secrets，并会创建 GitHub Release，附带
Windows x64 ZIP 和已签名 APK。标签中包含连字符的版本会作为预发布版本创建。

`file_picker` 当前固定在 10.x：11.x 要求 AGP 9 的 Built-in Kotlin 模式，
而 `dynamic_color 1.8.1` 仍要求 Flutter 的 Kotlin 兼容模式。只有两个插件均支持
Built-in Kotlin 后，才能一起升级并切换 Android 构建模式。

APK 位于 `build/app/outputs/flutter-apk/app-release.apk`，发布命名为
`ddl-out-v<version>-android.apk`。

## 数据兼容

升级前可从设置页导出 JSON。恢复会校验格式后整库替换，不会修改备份文件；
高于当前 `schemaVersion` 的备份会被拒绝。
