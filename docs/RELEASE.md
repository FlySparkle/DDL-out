# DDL out! 发布说明

## 质量门槛

从仓库根目录运行：

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release --target-platform android-arm64
```

CI 在对 `main` 的推送和 Pull Request 上运行依赖解析、代码生成检查、格式化、
静态分析、测试、Windows x64 构建和 Android arm64-v8a 构建。只有这些检查通过的
改动才应合并。

## Windows

Windows 构建依赖 Visual Studio 2022 C++ 桌面工作负载和 Windows 开发者模式。
发布时压缩 `build/windows/x64/runner/Release/` 的全部内容，产物命名为
`DDL_out_v<version>-windows-x64-portable.zip`，不能只分发 exe。

## Android 签名

生成上传密钥并妥善离线备份：

```powershell
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 4096 -validity 10000 -alias upload
```

在 `android/key.properties` 写入：

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

发布工作流要求上述 Android 签名 Secrets，并会创建 GitHub Release，附带 Windows x64
与 ARM64 portable ZIP、已签名 Android arm64-v8a 与 x64 APK，以及 Linux DEB、RPM 与 tar.gz。
标签中包含连字符的版本会作为预发布版本创建。

`file_picker` 当前固定在 10.x：11.x 要求 AGP 9 的 Built-in Kotlin 模式，
而 `dynamic_color 1.8.1` 仍要求 Flutter 的 Kotlin 兼容模式。只有两个插件均支持
Built-in Kotlin 后，才能一起升级并切换 Android 构建模式。

## 产物命名

所有发布文件均使用不含 Flutter build number 的应用版本：

```text
DDL_out_v<version>-windows-x64-portable.zip
DDL_out_v<version>-windows-arm64-portable.zip
DDL_out_v<version>-android-arm64-v8a.apk
DDL_out_v<version>-android-x64.apk
DDL_out_v<version>-linux-amd64.deb
DDL_out_v<version>-linux-amd64.rpm
DDL_out_v<version>-linux-amd64.tar.gz
DDL_out_v<version>-ios.ipa
DDL_out_v<version>-macos.dmg
```

## 扩展平台

Windows ARM64 portable、Linux DEB/RPM/tar.gz 已加入标签发布流程。
`.github/workflows/extended-platforms.yml` 仅保留通过 GitHub Actions 手动触发的 Apple
平台验证：已签名 iOS IPA 和未签名 macOS DMG。它们不会自动附加到标签发布，直到完成
目标设备验证与签名配置。

Windows MSIX 需要先确定稳定的 Package/Publisher Identity 并配置签名证书。完成后应在
扩展平台工作流中新增 MSIX job，而不是将未签名包作为正式发布产物。

iOS 与 macOS 的正式分发需要 Apple Developer 签名、provisioning profile 与 notarization
配置；这些凭据不得提交到仓库。

iOS IPA 工作流需要以下 GitHub Secrets：

- `IOS_CERTIFICATE_BASE64`：发布证书 P12 的 Base64 内容。
- `IOS_CERTIFICATE_PASSWORD`：P12 密码。
- `IOS_PROVISION_PROFILE_BASE64`：provisioning profile 的 Base64 内容。
- `IOS_EXPORT_OPTIONS_PLIST_BASE64`：与应用标识和 profile 匹配的 `ExportOptions.plist` 的 Base64 内容。
- `IOS_KEYCHAIN_PASSWORD`：GitHub Runner 临时 keychain 的随机密码。

## 数据兼容

升级前可从设置页导出 JSON。恢复会校验格式后整库替换，不会修改备份文件；
高于当前 `schemaVersion` 的备份会被拒绝。
