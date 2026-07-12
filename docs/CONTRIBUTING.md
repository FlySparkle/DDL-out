# 贡献指南

感谢你帮助改进 DDL out!。本项目正在将旧版桌面应用重写为 Windows 与 Android
共用的本地优先 Flutter 应用。提交 issue 或 Pull Request 前，请先阅读
[迁移路线图](docs/MIGRATION_ROADMAP.md) 和仓库根目录的 `AGENTS.md`。

## 开始开发

需要 Flutter 3.44.6 Stable（自带 Dart）、Windows 的 Visual Studio C++ 桌面工作负载，
以及 Android 的 JDK 21 和 SDK 命令行工具。具体环境检查见根目录 README。

```powershell
git clone https://github.com/FlySparkle/DDL-out.git
cd DDL-out\ddl_out_flutter
flutter pub get
dart run build_runner build --force-jit
flutter gen-l10n
flutter run -d windows
```

仓库路径含非 ASCII 字符时，`build_runner` 需要使用 `--force-jit`。

## 提交前检查

从 `ddl_out_flutter/` 运行：

```powershell
dart run build_runner build --force-jit
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release
```

涉及 Drift schema、截止时间计算、备份恢复或拖放时，请补充与风险相称的测试。
提交代码生成输出的变更，不要提交 `.dart_tool/`、`build/`、密钥或本地数据库。

## 工作流

1. 从最新的 `main` 创建单一目的分支，例如 `feat/backup-preview`、
   `fix/android-export` 或 `docs/contributing`。
2. 保持提交聚焦，并使用清晰的提交说明。
3. 推送分支后创建 Pull Request。说明用户可见行为、测试结果和关联 issue。
4. 等待 CI 通过并处理评审意见后再合并。合并后删除分支。

不要在 Pull Request 中顺带重构无关代码、修改他人的未完成工作，或提交真实备份与
Android 签名材料。

## 问题与安全报告

使用 GitHub issue 模板报告可公开讨论的缺陷和功能建议。安全漏洞请遵循
[安全政策](SECURITY.md)，不要在公开 issue 中披露可利用细节。

参与项目即表示你同意遵守[行为准则](CODE_OF_CONDUCT.md)。
