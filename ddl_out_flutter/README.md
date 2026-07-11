# DDL out!

Windows 与 Android 共用的本地优先截止事项看板，使用 Flutter、Riverpod、
Drift 和 Material 3 构建。

## 开发

```powershell
flutter pub get
dart run build_runner build --force-jit
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run -d windows
```

仓库所在路径包含中文字符，当前 Dart 版本下运行 `build_runner` 必须使用
`--force-jit`。Windows 插件构建还需要启用 Windows 开发者模式。

## 发布

```powershell
flutter build windows --release
flutter build apk --release
```

Android 正式签名配置位于未跟踪的 `android/key.properties`。完整流程见
根目录的 `docs/RELEASE.md`。
