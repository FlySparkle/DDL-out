## Summary

Describe the user-visible change and why it is needed.

## Validation

- [ ] `dart run build_runner build --force-jit` (when generated code can change)
- [ ] `flutter gen-l10n` (when localizations can change)
- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Relevant Windows and/or Android build completed

## Checklist

- [ ] The change is focused and includes appropriate tests.
- [ ] No local database, backup, signing material, or other secret is included.
- [ ] Documentation and migration notes are updated when behavior or scope changed.
