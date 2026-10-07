# Changelog

## [1.2.3] - 2026-10-08

### Changed

- Upgrade the Android build to Android Gradle Plugin 9.1.0, Gradle 9.3.1, and Kotlin 2.4.0, matching the Flutter 3.47 toolchain.

## [1.2.2] - 2026-09-21

### Added

- Package Agent Skills under `skills/` (`xue-hua-speaker-earpiece-toggle-usage` and `xue-hua-speaker-earpiece-toggle-api`) for `dart run skills@ get`.
- Add `.pubignore` so generated `example/build` is not packed into the pub archive.

### Documentation

- Correct the installation constraint in English and Chinese READMEs from `^2.1.0` to `^1.2.2`.
- Document `restoreSession()`, `switchableAudioOutputRoutes`, and `isSwitchableAudioOutputRoute`.
- Retitle the 1.1.0 migration section (package is still 1.x; there is no 2.0.0).

## [1.2.1] - 2026-08-21

- The Gradle tool version has been downgraded to 8.13.2.

## [1.2.0] - 2026-07-27

### Added

- `restoreSession()` API on `XueHuaSpeakerEarpieceToggle` to manually restore pre-call audio session settings on Android and iOS.
- Native `restoreSession` method channel handlers in Android (`XueHuaSpeakerEarpieceTogglePlugin.kt`) and iOS (`XueHuaSpeakerEarpieceTogglePlugin.swift`).
- Unit tests in `test/xue_hua_speaker_earpiece_toggle_test.dart` for `restoreSession()` platform delegation.

### Changed

- Code formatting across iOS Swift sources using SwiftFormat.

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
