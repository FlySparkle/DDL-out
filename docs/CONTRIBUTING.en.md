# Contributing Guide

Thank you for helping improve DDL out!. This is a local-first Flutter app for
desktop and mobile. Before submitting an issue or Pull Request, please read the
`AGENTS.md` at the repository root.

## Getting Started

You need Flutter 3.44.6 Stable (with bundled Dart), Visual Studio C++ desktop
workload on Windows, and JDK 21 with Android SDK command-line tools for Android.
See the root README for environment setup details.

```powershell
git clone https://github.com/FlySparkle/DDL-out.git
cd DDL-out
flutter pub get
dart run build_runner build
flutter gen-l10n
flutter run -d windows
```

> When the repository path contains non-ASCII characters, add `--force-jit` to
> `dart run build_runner build`.

## Pre-commit Checks

Run from the repository root:

```powershell
dart run build_runner build
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Add tests commensurate with risk when touching Drift schemas, deadline math,
backup/restore, or drag-and-drop. Commit generated code changes, but never commit
`.dart_tool/`, `build/`, keys, or local databases.

## Workflow

1. Create a single-purpose branch from the latest `main`, for example:
   - `feat/backup-preview`
   - `fix/android-export`
   - `docs/contributing`
2. Keep commits focused and use clear commit messages.
3. Push your branch and open a Pull Request. Describe user-visible behavior,
   test results, and related issues.
4. Wait for CI to pass and address review feedback before merging. Delete the
   branch after merge.

Do not incidentally refactor unrelated code, modify others' work in progress,
or commit real backups and Android signing material in a Pull Request.

## Reporting Issues

Use the GitHub issue templates to report defects and feature suggestions that
can be discussed publicly. Do not disclose keys, personal data, or other
sensitive information in public issues.

By participating in this project, you agree to abide by the
[Code of Conduct](CODE_OF_CONDUCT.md).
