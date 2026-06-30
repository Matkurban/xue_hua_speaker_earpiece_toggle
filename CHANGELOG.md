# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-30

### Added

- `onRouteChanged` stream on `XueHuaSpeakerEarpieceToggle` for OS-initiated route updates.
- iOS `RouteChangeStreamHandler` listening to `AVAudioSession.routeChangeNotification`.
- Android `RouteChangeNotifier` using `AudioDeviceCallback` and API 31+ `OnCommunicationDeviceChangedListener`.
- Example app subscribes to `onRouteChanged` instead of polling after every switch.
- `AudioOutputRoute.external` and `AudioOutputRoute.unknown` for accurate route reporting.
- `RouteResult` returned from `setRoute()` with `requested`, `applied`, and `available`.
- `CONTEXT.md` domain glossary for the AudioRoute module.
- Deep native modules: `RouteDetector`, `RouteApplicator`, `SessionCoordinator` on iOS and Android.
- iOS `AudioSessionProtocol` seam and `FakeAudioSession` for unit testing.
- Android API 31+ `communicationDevice` detection and API 34+ `setCommunicationDevice()` support.
- Session/mode snapshot and restore on plugin detach.
- Expanded Dart, Android, and iOS unit tests; hardened integration test with retry and `@Tags(['device'])`.

### Changed

- **Breaking:** `setRoute()` now returns `Future<RouteResult>` instead of `Future<void>`.
- **Breaking:** `getRoute()` may return `external` or `unknown` in addition to `speaker` and `earpiece`.
- iOS only configures `AVAudioSession` when category/mode mismatch or activation is required.
- Android only sets `MODE_IN_COMMUNICATION` when needed; restores previous mode on detach.
- Example app re-reads route after `setRoute()` and surfaces `RouteResult.available`.

### Fixed

- iOS `getRoute` / `setRoute` asymmetry and passive mis-reporting when session is inactive.
- iOS and Android mis-labeling Bluetooth/wired outputs as `earpiece`.
- Android wrong-type `route` argument reporting a generic missing-argument error.
- Dart type-cast failures when native returns non-String route values.
- Example app optimistic UI updates after route switches.

## [1.0.0] - 2026-06-26

### Added

- `AudioOutputRoute` enum with `speaker` and `earpiece` values.
- `getRoute()` API to read the current audio output route from the native platform.
- `setRoute()` API to switch between speaker and earpiece on the native platform.
- Android implementation using `AudioManager` and `MODIFY_AUDIO_SETTINGS` permission.
- iOS implementation using `AVAudioSession` and `overrideOutputAudioPort`.
- Example app with a segmented control to demo route switching.
- Bilingual README documentation (English and 中文).
- Bilingual Dart doc comments (English and 中文) on public APIs.
