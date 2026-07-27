# Repository Guide

## Mission

Build DDL out! as a local-first Flutter application using Material 3 and
Material 3 Expressive-inspired motion and component styling.

## Canonical workspace

- The default and canonical repository root is
  `C:\Users\27950\Desktop\Work\DDL-out`.
- Run all project inspection, editing, generation, testing, build, and Git
  commands from this directory unless the user explicitly names another path.
- The legacy repository copy at
  `C:\Users\27950\Desktop\Work\Python面向对象\DDL out！` is read-only history.
  Do not inspect it as the default workspace or continue development there.
- Before making changes, verify that `git rev-parse --show-toplevel` resolves
  to the canonical repository root above.

## Project handoff

- Before planning or implementing project changes, read
  [the project handoff](docs/PROJECT_HANDOFF.md) for the current product and
  development context.
- Consult [the legacy task index](docs/legacy/OLD_CODEX_TASKS.md) only when the
  provenance or detailed rationale of an older decision is needed.
- Resolve conflicting information in this order: current code and tests,
  accepted ADRs, this file and the project handoff, then legacy task records.
  Old conversations are historical evidence, not current requirements.
- The handoff documents must remain useful even if the legacy folder or local
  Codex task history is unavailable.

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
