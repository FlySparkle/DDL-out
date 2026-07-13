# Repository Guide

## Mission

Build DDL out! as a local-first Flutter application using Material 3 and
Material 3 Expressive-inspired motion and component styling.

## Repository layout

- `lib/`: Flutter application source code.
- `android/`, `ios/`, `linux/`, `macos/`, and `windows/`: native platform hosts.
- `docs/`: architecture decisions, release, contribution, and platform notes.
- `tool/`: repository-level setup and verification scripts.

## Product invariants

- The app is local-first and must work without a network connection.
- Preserve category CRUD, task CRUD, completion state, deadline-based sorting,
  category collapse, cross-category drag and drop, and clear-completed behavior.
- Support both relative and absolute deadline entry.
- Keep the compact 9:20 desktop experience, but make layouts responsive rather
  than forcibly resizing the native window.
- Version 0.1 starts from empty data.
- Cross-platform transfer uses validated, versioned JSON whole-database backups.
- Store timestamps in UTC and render them in the user's local time zone.
- All source files and user-facing Chinese text must be UTF-8.

## Flutter conventions

- Use the current Flutter stable channel and Dart bundled with Flutter.
- Use Material 3 as the base. Expressive styling belongs in app theme tokens and
  reusable components, not scattered one-off values.
- Preferred stack: Riverpod for state, Drift for SQLite, `go_router` only when a
  second full-screen route exists, and `window_manager` for desktop window setup.
- Keep feature code under `lib/features/<feature>/` and shared infrastructure
  under `lib/core/` and `lib/data/`.
- Keep widgets small and presentation-focused. Put deadline math, sorting, and
  persistence outside widgets.
- Prefer immutable models and explicit repository interfaces.
- Avoid generated abstractions until they remove real duplication.

## Quality gates

Run from the repository root:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows
```

Add tests in proportion to risk:

- Unit tests for deadline normalization, urgency colors, sorting, and backup conversion.
- Database tests for CRUD, cascades, transactions, and schema upgrades.
- Widget tests for task/category editing and empty/error states.
- Integration tests for drag and drop and restoring a JSON backup.

## Change discipline

- Do not edit or delete the user's local `*.db` files.
- Keep commits scoped to one milestone or one cohesive fix.
- Record durable architecture decisions in `docs/decisions/` as short ADRs.
