# ADR 005: GitHub Release based in-app updates

## Status

Accepted.

## Context

DDL out! is distributed from GitHub Releases rather than an app store. Asking
users to choose and install a platform package manually makes routine updates
error-prone, especially because Windows and Android publish architecture-specific
assets.

## Decision

- The release API response is the update manifest. The app selects an asset by
  operating system and runtime ABI.
- Every release publishes `SHA256SUMS.txt`. The app refuses to install an asset
  that is missing from this manifest or whose digest does not match.
- On Windows, the app downloads and extracts the portable ZIP. A detached
  PowerShell helper waits for the current process to exit, swaps the application
  directory, restarts the executable, and restores the previous directory if the
  swap fails.
- On Android, the app downloads the matching signed APK and opens Android's
  package installer through a private `FileProvider`. Android retains the final
  user confirmation and unknown-source permission flow.
- Linux, macOS, and iOS report that in-app installation is unsupported until a
  platform-native signed update channel is available. They do not silently fall
  back to a manual package download.

Application data remains outside the installation directory and is not touched
by an update.

## Consequences

Windows releases must remain self-contained portable ZIP archives, and Android
updates must use the same application ID and signing key. A release without the
checksum manifest cannot be installed in-app. HTTPS plus SHA-256 detects damaged
or substituted assets within the published release, while GitHub account and
release security remain part of the distribution trust boundary.
