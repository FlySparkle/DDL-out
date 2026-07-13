# ADR 002: Feature-oriented source layout

- Status: Accepted
- Date: 2026-07-13

## Context

Board and settings behavior had accumulated in a few large presentation files.
Page layout, dialogs, persistence interfaces, provider wiring, and reusable
widgets changed for different reasons but were compiled together. This made a
small feature likely to touch unrelated code.

## Decision

- Keep route-level widgets as thin composition roots.
- Organize feature internals into `application/` and `presentation/` folders.
- Split presentation code by independently changing component or dialog.
- Keep database infrastructure under `lib/data/database/`.
- Separate repository interfaces, Drift implementations, and Riverpod wiring.
- Keep small compatibility barrels for existing imports, while application code
  imports the narrow module it actually needs.
- Do not manually split generated Drift or localization files.

## Consequences

New board and settings behavior should normally be added inside the owning
feature without expanding route-level files. Cross-feature dependencies must be
explicit imports. Compatibility barrels may be removed in a future breaking
cleanup after external imports have migrated.
