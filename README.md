# DDL out! Flutter Rewrite

This repository contains the legacy desktop application and its Flutter rewrite.
The Flutter application targets Windows and Android with shared domain, Riverpod,
and Drift layers.

[![CI](https://github.com/FlySparkle/DDL-out/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/FlySparkle/DDL-out/actions/workflows/ci.yml)

## Layout

- `DDL out/` - legacy Python + Flask + SQLite + pywebview application
- `ddl_out_flutter/` - Flutter application
- `docs/MIGRATION_ROADMAP.md` - implementation sequence and acceptance gates
- `tool/check_environment.ps1` - local toolchain check

## Local environment

The expected Windows development environment is:

- Git
- Flutter Stable (Dart is bundled)
- VS Code with Dart and Flutter extensions
- Visual Studio 2022 with Desktop development with C++
- JDK 21 and Android SDK command-line tools

Open a new terminal after installing or changing `PATH`, then run:

```powershell
.\tool\check_environment.ps1
flutter doctor -v
```

Keep SDK paths machine-local. Do not commit an SDK, IDE cache, generated build
output, or local SQLite data into this repository.

Verified on 2026-07-12:

- Flutter 3.44.6 Stable, Dart 3.12.2, and DevTools 2.57.0
- Visual Studio Community 2022 17.11.2 with the C++ desktop workload
- Windows SDK 10.0.22621.0 and Windows desktop engine caches
- VS Code Flutter 3.138.0 and Dart 3.138.0 extensions
- JDK 21 configured for Flutter
- Android SDK platforms 34, 35, and 36; Build Tools 36.0.0; NDK 28.2.13676358
- Android licenses accepted and the release APK toolchain available

## Migration principle

The legacy app is a behavior reference, not a migration source or target
architecture. Flutter owns UI, application state, and SQLite persistence
directly; a local Flask server is not part of the target design. Version 0.1
starts with an empty database and uses versioned JSON for backup and restore.

Read [the migration roadmap](docs/MIGRATION_ROADMAP.md) for implementation and
release status.

## Community and delivery

- [Contributing guide](CONTRIBUTING.md) covers the branch, test, and pull
  request workflow.
- [Code of conduct](CODE_OF_CONDUCT.md) defines the expectations for project
  spaces.
- [Security policy](SECURITY.md) explains how to report a vulnerability without
  disclosing it publicly.
- [Release guide](docs/RELEASE.md) documents local signing and the tag-driven
  GitHub release process.
