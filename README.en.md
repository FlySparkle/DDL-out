<p align="center">
  <img src="assets/logo.png" width="120" alt="DDL out! Logo" />
</p>

<h1 align="center">DDL out!</h1>

<p align="center">
  <a href="README.md">中文</a> | <b>English</b> | <a href="README.ja.md">日本語</a>
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

DDL out! is a local-first deadline board. Organize tasks by their deadlines and
work without a network connection. It is built with Flutter, Riverpod, Drift,
and Material 3.

## Features

- Create, edit, delete, collapse, and move categories and tasks across categories.
- Sort tasks by deadline and show their urgency.
- Enter deadlines as relative or absolute time.
- Track completion and clear completed tasks.
- Export and restore validated, versioned JSON database backups.
- Keep data in a local SQLite database; timestamps are stored in UTC and shown
  in the local time zone.

## Quick Start

Install Flutter Stable, which includes Dart, then run these commands from the
repository root:

```powershell
flutter pub get
dart run build_runner build
flutter gen-l10n
flutter run -d windows
```

Android development also requires JDK 21, the Android SDK, and accepted
licenses. Windows builds require Visual Studio with the Desktop development
with C++ workload. Run `flutter doctor -v` to check the environment.

## Development and Validation

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release --target-platform android-arm64
```

Keep `--force-jit` for code generation on paths containing non-ASCII
characters. See the [release guide](docs/RELEASE.md) for signing, packaging,
and tag-driven releases.

## Layout

```text
lib/        Flutter application and domain code
test/       Unit and widget tests
assets/     Application assets
android/    Android host
ios/        iOS host
linux/      Linux host
macos/      macOS host
windows/    Windows host
docs/       Release, contribution, and architecture documentation
tool/       Local verification and packaging scripts
```

## Contributing

Read the [contributing guide](docs/CONTRIBUTING.md) and [code of conduct](docs/CODE_OF_CONDUCT.md).
Use the GitHub issue templates for public reports. Do not submit local
databases, backups, signing materials, or other personal data.

## License

This project is licensed under [GPL-v3](LICENSE).
