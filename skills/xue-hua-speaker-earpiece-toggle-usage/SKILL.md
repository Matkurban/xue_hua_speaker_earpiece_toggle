---
name: xue-hua-speaker-earpiece-toggle-usage
description: >-
  Use when adding or changing xue_hua_speaker_earpiece_toggle: VoIP speakerphone
  toggle, getRoute, setRoute, onRouteChanged, restoreSession, Android
  MODIFY_AUDIO_SETTINGS, iOS AVAudioSession, or RouteResult.available when an
  external headset blocks speaker/earpiece.
---

# xue_hua_speaker_earpiece_toggle usage

Flutter plugin for **loudspeaker vs earpiece** during voice calls. Android and iOS only. For every public signature, exception code, and platform-interface member, load sibling skill `xue-hua-speaker-earpiece-toggle-api`.

## Guidelines

* Import `package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart` and construct `XueHuaSpeakerEarpieceToggle()` (implicit default constructor; no init method).
* Pass only `AudioOutputRoute.speaker` or `AudioOutputRoute.earpiece` to `setRoute`. Call `isSwitchableAudioOutputRoute(route)` (or check `switchableAudioOutputRoutes`) before switching. `external` and `unknown` are report-only.
* After `setRoute`, drive UI from `RouteResult.applied` and `RouteResult.available`. Treat `available: false` as success of the call with a different active output (OS kept a headset, Bluetooth, AirPlay, etc.).
* Subscribe to `onRouteChanged` for live updates. Cancel the `StreamSubscription` in `dispose`. The native side emits the current route immediately on listen, then again on OS / other-SDK changes and after this plugin's `setRoute`.
* Catch `PlatformException` on `getRoute`, `setRoute`, `restoreSession`, and the `onRouteChanged` stream. Codes live in sibling skill `xue-hua-speaker-earpiece-toggle-api` (`references/exceptions.md`).
* Call `restoreSession()` when the voice call ends if this plugin ran `setRoute` (it borrowed Android `AudioManager.mode` / iOS `AVAudioSession`). It is a no-op when the plugin never changed the session. The native plugin also restores on detach.
* On iOS, apply this plugin **after** WebRTC / Agora / LiveKit (or any other owner) has configured the shared `AVAudioSession`.
* Validate speaker/earpiece switching on a physical device during an active call or while audio is playing.

## Setup

Minimum: add the dependency and `flutter pub get`.

```yaml
dependencies:
  xue_hua_speaker_earpiece_toggle: ^1.2.2
```

**Android:** the plugin declares `MODIFY_AUDIO_SETTINGS` (normal permission, no runtime prompt). Gradle merges it into the host app. Host apps that capture mic still declare `RECORD_AUDIO` themselves.

**iOS:** `setRoute` uses `AVAudioSession` category `.playAndRecord`, mode `.voiceChat`, option `.allowBluetooth`. Add `NSMicrophoneUsageDescription` when the app captures microphone audio. Add `UIBackgroundModes` → `audio` only for background VoIP.

## Workflows

### 1. Construct and read

```dart
import 'package:flutter/services.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';

final toggle = XueHuaSpeakerEarpieceToggle();

try {
  final route = await toggle.getRoute();
  // speaker | earpiece | external | unknown
} on PlatformException catch (error) {
  // error.code is INVALID_ROUTE when the native payload is not a known route string
}
```

### 2. Switch speaker or earpiece

```dart
Future<void> switchTo(AudioOutputRoute route) async {
  if (!isSwitchableAudioOutputRoute(route)) {
    return; // external and unknown cannot be requested
  }
  try {
    final result = await toggle.setRoute(route);
    if (!result.available) {
      // Requested result.requested; OS left result.applied active.
    }
  } on PlatformException catch (error) {
    // INVALID_ROUTE (bad request or unreadable native payload),
    // INVALID_ROUTE_RESULT (malformed setRoute map),
    // INVALID_ARGUMENT / AUDIO_ROUTE_ERROR from native setRoute
  }
}
```

### 3. Listen, then restore when the call ends

```dart
late final StreamSubscription<AudioOutputRoute> subscription;

void startWatching() {
  subscription = toggle.onRouteChanged.listen(
    (route) { /* update UI */ },
    onError: (Object error) { /* PlatformException on bad event type */ },
  );
}

Future<void> endCall() async {
  await subscription.cancel();
  await toggle.restoreSession();
}
```

## Host UI pattern

Subscribe to `onRouteChanged` in `initState`, cancel in `dispose`, call `setRoute` only for speaker/earpiece, and treat `result.available == false` as a user-visible mismatch (`requested` vs `applied`). The package `example/` app follows this pattern.
