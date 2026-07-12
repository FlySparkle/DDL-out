# DDL out!

<p align="center">
  <img src="assets/logo.png" alt="DDL out! logo" />
</p>

**中文** | [English](README.en.md) | [日本語](README.ja.md)

[![CI](https://github.com/FlySparkle/DDL-out/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/FlySparkle/DDL-out/actions/workflows/ci.yml)

DDL out! 是一个本地优先的截止事项看板。它帮助你按截止时间组织任务，在不联网的情况下
也能完成所有日常操作。应用使用 Flutter、Riverpod、Drift 与 Material 3 构建。

## 功能

- 分类与事项的创建、编辑、删除、折叠和跨分类拖放。
- 按截止时间排序，并以紧急程度呈现任务状态。
- 相对时间和绝对时间两种截止时间输入方式。
- 完成状态与一键清理已完成事项。
- 经过校验、带版本的 JSON 全量备份与恢复。
- 所有数据保存在本机 SQLite 数据库；时间以 UTC 存储并按本地时区显示。

## 平台计划

| 平台与分发方式 | 状态 | 自动化 |
| --- | --- | --- |
| Windows x64 portable | 可构建 | CI 与标签发布 |
| Windows ARM64 portable | 预留 | 手动扩展平台工作流 |
| Windows MSIX | 预留 | 需要应用身份和签名证书后启用 |
| Linux x64 bundle、DEB、RPM | 预留 | 手动扩展平台工作流 |
| Android arm64-v8a APK | 可构建 | CI 与标签发布 |
| iOS | 预留 | macOS 工作流执行无签名构建；发布需要 Apple 签名 |
| macOS | 预留 | 已生成原生宿主，待发布签名配置 |

预留表示原生宿主或工作流入口已经存在，但不代表已经发布可供最终用户安装的正式包。

## 快速开始

安装 Flutter Stable（Dart 已包含），然后从仓库根目录运行：

```powershell
flutter pub get
dart run build_runner build --force-jit
flutter gen-l10n
flutter run -d windows
```

Android 开发还需要 JDK 21、Android SDK 和已接受的许可证。Windows 构建需要 Visual
Studio 的 Desktop development with C++ 工作负载。运行 `flutter doctor -v` 可检查环境。

## 开发与验证

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release --target-platform android-arm64
```

在包含非 ASCII 字符的路径中运行代码生成时，保留 `--force-jit`。完整的签名、打包与
标签发布说明见 [发布指南](docs/RELEASE.md)。

## 项目结构

```text
lib/        Flutter 应用与业务逻辑
test/       单元与组件测试
assets/     应用资源
android/    Android 原生宿主
ios/        iOS 原生宿主
linux/      Linux 原生宿主
macos/      macOS 原生宿主
windows/    Windows 原生宿主
docs/       发布、贡献与架构文档
tool/       本地验证与打包脚本
```

## 参与贡献

请阅读[贡献指南](docs/CONTRIBUTING.md)和[行为准则](docs/CODE_OF_CONDUCT.md)。公开问题请
使用 GitHub Issue 模板；请勿提交本地数据库、备份、签名材料或其他个人数据。

## 许可证

本项目采用 [GPL-v3](LICENSE) 许可证。
