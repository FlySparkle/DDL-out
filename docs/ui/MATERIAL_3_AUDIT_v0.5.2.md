# v0.5.2 Material 3 UI audit

## Scope

This audit covers the application theme, navigation shell, board actions,
nearby-sync flow, conflict review, and task-detail editor. It checks whether
the UI uses Material 3 components, semantic color roles, standard icons,
responsive layouts, and platform-appropriate interaction patterns.

## Findings

- The app theme enables Material 3 and derives light and dark schemes from a
  seed or the platform dynamic-color scheme.
- Navigation uses Material 3 destinations and keeps the same information
  architecture across compact and expanded layouts.
- Board, settings, dialogs, text fields, snack bars, badges, and progress
  indicators use Material components and color-scheme roles instead of fixed
  foreground/background pairs.
- The deadline auto-sort action used a custom-painted glyph. It is replaced by
  the standard Material `sort` icon so size, optical weight, disabled state,
  semantics, and theme color follow the icon library.
- Nearby sync should present symmetric “start” and “join” roles on every
  platform. The initiator uses a QR code and copyable key; the receiver uses a
  scanner or key field. The large-transfer option uses `SwitchListTile`.
- Conflict choices should expose user content rather than storage keys or raw
  serialized values. Text, image, and ordering conflicts need distinct visual
  treatments.
- On phones, image insertion belongs next to the detail editor as a compact
  tonal action that opens the system photo picker. Desktop paste behavior stays
  available without adding a persistent toolbar.

## Intentional exceptions

- The image viewer uses a dark neutral canvas because it is an immersive media
  surface rather than normal application chrome.
- Category colors and deadline urgency colors are domain data. Their text and
  controls still use contrast-aware foreground colors.
- Shape values remain centralized in `AppTheme`; changing the complete shape
  scale is a separate visual migration and should not be mixed into a sync
  protocol release.
