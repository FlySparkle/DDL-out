<p align="center">
  <img src="assets/logo.png" width="120" alt="DDL out! Logo" />
</p>

<h1 align="center">DDL out!</h1>

<p align="center">
  <a href="README.md">中文</a> | <a href="README.en.md">English</a> | <b>日本語</b>
</p>

<p align="center">
  <a href="https://github.com/FlySparkle/DDL-out">
    <img src="https://img.shields.io/badge/GitHub-Repo-black?logo=github" />
  </a>
  <a href="https://github.com/FlySparkle/DDL-out/actions/workflows/ci.yml">
    <img src="https://github.com/FlySparkle/DDL-out/actions/workflows/ci.yml/badge.svg" />
  </a>
  <a href="https://github.com/FlySparkle/DDL-out/actions/workflows/release.yml">
    <img src="https://github.com/FlySparkle/DDL-out/actions/workflows/release.yml/badge.svg" />
  </a>
  <a href="./LICENSE">
    <img alt="GitHub License" src="https://img.shields.io/github/license/FlySparkle/DDL-out" />
  </a>
</p>

---

DDL out! は、締切ごとにタスクを整理するローカルファーストのボードです。ネットワーク
接続なしでも日常の操作を完結できます。Flutter、Riverpod、Drift、Material 3 で構築
されています。

## 機能

- カテゴリーとタスクの作成、編集、削除、折りたたみ、カテゴリー間のドラッグ移動。
- 締切順の並び替えと緊急度の表示。
- 相対時刻と絶対時刻による締切入力。
- 完了状態の管理と完了済みタスクの一括削除。
- 検証付き、バージョン付き JSON データベースバックアップの書き出しと復元。
- データはローカル SQLite に保存され、時刻は UTC で保存してローカルタイムゾーンで
  表示。

## プラットフォーム計画

| プラットフォームと配布形式 | 状態 | 自動化 |
| --- | --- | --- |
| Windows x64 portable | ビルド可能 | CI とタグリリース |
| Windows ARM64 portable | 予約済み | 手動の拡張プラットフォームワークフロー |
| Windows MSIX | 予約済み | アプリ ID と署名設定後に有効化 |
| Linux x64 bundle、DEB、RPM | 予約済み | 手動の拡張プラットフォームワークフロー |
| Android arm64-v8a APK | ビルド可能 | CI とタグリリース |
| iOS | 予約済み | macOS での未署名ビルド。配布には Apple 署名が必要 |
| macOS | 予約済み | ネイティブホスト作成済み。配布署名は未設定 |

予約済みはネイティブホストまたはワークフローの入口があることを示します。一般利用者
向けの配布パッケージが公開済みであることは意味しません。

## はじめに

Flutter Stable（Dart を含む）をインストールし、リポジトリのルートで実行します。

```powershell
flutter pub get
dart run build_runner build --force-jit
flutter gen-l10n
flutter run -d windows
```

Android 開発には JDK 21、Android SDK、承認済みライセンスも必要です。Windows ビルド
には Visual Studio の Desktop development with C++ ワークロードが必要です。
`flutter doctor -v` で環境を確認できます。

## 開発と検証

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release --target-platform android-arm64
```

パスに非 ASCII 文字が含まれる場合は、コード生成に `--force-jit` を使い続けてください。
署名、パッケージング、タグによるリリースは[リリースガイド](docs/RELEASE.md)を参照して
ください。

## 構成

```text
lib/        Flutter アプリケーションとドメインコード
test/       ユニットテストとウィジェットテスト
assets/     アプリケーションアセット
android/    Android ホスト
ios/        iOS ホスト
linux/      Linux ホスト
macos/      macOS ホスト
windows/    Windows ホスト
docs/       リリース、貢献、アーキテクチャの文書
tool/       ローカル検証とパッケージングのスクリプト
```

## 貢献

[貢献ガイド](docs/CONTRIBUTING.md)と[行動規範](docs/CODE_OF_CONDUCT.md)をお読みください。
公開の報告には GitHub Issue テンプレートを利用し、ローカルデータベース、バックアップ、
署名情報、その他の個人データは投稿しないでください。

## ライセンス

このプロジェクトは [GPL-v3](LICENSE) のライセンスで提供されます。
