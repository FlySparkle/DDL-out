# ADR 001: Android Kotlin compatibility mode

## Status

Accepted on 2026-07-12.

## Context

Flutter 3.44.6 generates an AGP 9 project. `dynamic_color 1.8.1` still applies
the legacy Kotlin Android plugin, while `file_picker 11` expects AGP built-in
Kotlin. Enabling either mode for both dependencies makes the other fail.

## Decision

Keep Flutter's `android.builtInKotlin=false` compatibility mode and pin
`file_picker` to `10.3.10`. Disable Kotlin incremental compilation to support
the workspace's Windows subst-drive workflow.

## Consequences

Android release builds are reproducible with Flutter 3.44.6. Before upgrading
`file_picker` to 11 or later, verify that `dynamic_color` supports AGP built-in
Kotlin, then remove the compatibility pin and re-run the full Android build.
