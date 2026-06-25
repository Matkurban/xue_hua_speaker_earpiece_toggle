# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/example/xue_hua_speaker_earpiece_toggle/releases/tag/v1.0.0
