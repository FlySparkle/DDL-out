# ADR 004: Manual task ordering with explicit deadline sort

## Status

Accepted.

## Context

Automatically sorting tasks after every completion change makes rows jump while
the user is interacting with them. Users also need to place tasks freely within
each category while keeping that order across restarts, backups, and peer sync.

## Decision

- Every task stores a fractional `positionKey` scoped to its category.
- Board reads use `positionKey` as the default task order.
- Changing completion state does not change `positionKey`.
- Dragging a task writes a new category and/or position.
- The explicit sort action rewrites each category to:
  incomplete tasks by deadline, followed by completed tasks by deadline.
- Task position participates in database migration, JSON backups, and sync
  field operations.

## Consequences

Task order stays visually stable during ordinary edits. Automatic deadline
ordering becomes an intentional user action, and older databases are migrated
from the former automatic order.
