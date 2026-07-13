# コントリビューションガイド

DDL out! の改善にご協力いただきありがとうございます。本アプリはデスクトップと
モバイル向けのローカルファースト Flutter アプリです。Issue や Pull Request を
送信する前に、リポジトリルートの `AGENTS.md` をお読みください。

## 開発を始める

Flutter 3.44.6 Stable（Dart 同梱）、Windows の Visual Studio C++ デスクトップ
ワークロード、Android の JDK 21 と Android SDK コマンドラインツールが必要です。
環境の詳細はルートの README を参照してください。

```powershell
git clone https://github.com/FlySparkle/DDL-out.git
cd DDL-out
flutter pub get
dart run build_runner build
flutter gen-l10n
flutter run -d windows
```

> リポジトリのパスに非 ASCII 文字が含まれる場合、`dart run build_runner build` に
> `--force-jit` を追加してください。

## コミット前のチェック

リポジトリルートから実行してください：

```powershell
dart run build_runner build
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Drift スキーマ、締切計算、バックアップ/リストア、ドラッグ＆ドロップに関わる変更
には、リスクに応じたテストを追加してください。生成されたコードの変更はコミット
してください。`.dart_tool/`、`build/`、キー、ローカルデータベースはコミットしない
でください。

## ワークフロー

1. 最新の `main` から単一目的のブランチを作成してください。例：
   - `feat/backup-preview`
   - `fix/android-export`
   - `docs/contributing`
2. コミットは焦点を絞り、明確なコミットメッセージを使用してください。
3. ブランチをプッシュして Pull Request を作成してください。ユーザーに見える挙動、
   テスト結果、関連 Issue を説明してください。
4. CI が通過し、レビュー指摘に対応してからマージしてください。マージ後はブランチ
   を削除してください。

Pull Request 内で無関係なコードのリファクタリング、他者の進行中の作業の変更、
実際のバックアップや Android 署名素材のコミットは行わないでください。

## 問題の報告

GitHub Issue テンプレートを使用して、公開可能な不具合や機能提案を報告してください。
公開 Issue にキー、個人データ、その他の機密情報を開示しないでください。

本プロジェクトへの参加により、[行動規範](CODE_OF_CONDUCT.md)に従うことに同意した
ものとみなします。
