# DDL out! Flutter Migration Roadmap

## Target

Deliver an offline Flutter 3.44.6 application for Windows and Android. Both
platforms share Riverpod state, Drift persistence, deadline services, and
versioned JSON backup/restore. The product does not depend on Python, Flask,
pywebview, a local HTTP server, or the legacy database.

## Product baseline

The legacy implementation was reviewed for category and task CRUD, deadline
sorting, completion, collapse state, urgency colors, relative progress, and
cross-category dragging. Version 0.1 deliberately starts from empty data and
does not import `DDL out/tasks.db`.

## Architecture

```text
Flutter widgets
    -> Riverpod Notifiers
        -> repository interfaces
            -> Drift / SQLite
```

UI preferences live in SharedPreferences. Business data lives only in SQLite.
Backup and restore use validated UTF-8 JSON and replace the database inside one
transaction.

## Milestones

### M0 - Toolchain and repository foundation

Status: complete (2026-07-12)

- Flutter 3.44.6, Dart 3.12.2, Visual Studio C++ desktop tools, JDK 21, Android
  SDK platforms 34-36, Build Tools 36.0.0, and NDK 28.2.13676358 installed.
- Repository guidance, UTF-8/editor rules, ignore rules, and environment checks
  added.

### M1 - Flutter shell and design system

Status: complete

- Windows and Android project created as `ddl_out`, application ID
  `com.flysparkle.ddlout`, version `0.1.0+1`.
- Material 3 light/dark themes, Android dynamic color, ARB localization,
  responsive shell, routes, native window constraints, and application icons
  implemented.

### M2 - Domain model and local persistence

Status: complete

- Drift schema, UTC timestamps, repository interfaces, Riverpod providers,
  SharedPreferences settings, transactions, and database tests implemented.
- Category deletion uses `ON DELETE SET NULL`; widgets do not access Drift.

### M3 - Core board workflow

Status: complete

- Category/task CRUD, stable deadline sorting, virtual uncategorized category,
  completion, collapse persistence, relative progress, and adaptive drag/drop
  implemented.

### M4 - Deadline editor and accessibility

Status: complete

- Relative and absolute inputs, overflow normalization, remembered values,
  urgency thresholds, minute refresh, adaptive desktop/mobile editors, keyboard
  semantics, touch targets, and scalable layouts implemented.

### M5 - Backup and release hardening

Status: complete

- Versioned JSON export/restore with full validation and transactional replace,
  clear-data actions, GitHub Actions, release naming, packaging scripts, and
  release documentation implemented.

### M6 - Android adaptation

Status: complete (2026-07-12)

- Android dynamic color, bottom sheets, long-press drag, back navigation, SAF
  file access, signing hooks, and Android release configuration implemented.
- Signing secrets remain local or in CI secrets and are excluded from Git.
- Android release APK and Windows x64 ZIP builds completed and verified.

## Quality gates

Each release must pass:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build windows --release
flutter build apk --release
```

Release artifacts are named `ddl-out-v<version>-windows-x64.zip` and
`ddl-out-v<version>-android.apk`.

## Definition of done

The rewrite is complete when both platforms can perform every category and task
workflow offline, persist across restarts, restore the same JSON backup across
platforms, and launch from release artifacts without Python or the legacy
database.
