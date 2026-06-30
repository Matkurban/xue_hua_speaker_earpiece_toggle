English | [中文](README.zh-CN.md)

# xue_hua_speaker_earpiece_toggle

A Flutter plugin that reads and switches the active audio output route between the **loudspeaker** and the **earpiece receiver**. It is designed for VoIP, voice-call, and real-time audio scenarios where users need an in-app speakerphone toggle.

## Platform support

| Platform | Minimum version | Implementation |
|----------|-----------------|----------------|
| Android  | API 24+         | `AudioManager` |
| iOS      | 13.0+           | `AVAudioSession` |

## Installation

Add the dependency to your app's `pubspec.yaml`:

```yaml
dependencies:
  xue_hua_speaker_earpiece_toggle: ^2.1.0
```

Then run:

```bash
flutter pub get
```

## Permissions and setup

This section describes every permission and platform configuration required by the plugin and by typical host apps.

### Permission overview

| Platform | Permission / key | Required by plugin | Runtime prompt | Purpose |
|----------|------------------|--------------------|----------------|---------|
| Android | `MODIFY_AUDIO_SETTINGS` | Yes | No | Switch speakerphone / audio route via `AudioManager` |
| iOS | `NSMicrophoneUsageDescription` | No* | Yes (if declared) | Required only when your app captures microphone input |
| iOS | `UIBackgroundModes` → `audio` | No | N/A | Optional; keep audio session alive in background VoIP apps |

\* The plugin switches output routes only. It does not record audio by itself.

---

### Android

#### What the plugin provides

The plugin declares the following permission in its own manifest:

[`android/src/main/AndroidManifest.xml`](android/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

When you add this plugin as a dependency, Gradle **merges** that declaration into your app manifest automatically. You normally do **not** need to copy it into your host app.

| Item | Value |
|------|-------|
| Permission | `android.permission.MODIFY_AUDIO_SETTINGS` |
| Protection level | Normal |
| Runtime request | Not required |
| User-visible dialog | None |

#### Manual declaration (optional)

If manifest merge is disabled in your project, or you want the permission to be explicit in the host app, add it to:

`android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />

    <application
        android:label="your_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

#### Verify merged permissions

After building, inspect the merged manifest:

```bash
cd android
./gradlew :app:processDebugMainManifest
```

Open the generated file under `android/app/build/intermediates/merged_manifest/` and confirm `MODIFY_AUDIO_SETTINGS` is present.

#### Related Android permissions (host app responsibility)

The plugin does **not** declare these. Add them in your host app only when your use case needs them:

| Permission | When you need it |
|------------|------------------|
| `RECORD_AUDIO` | Your app records or streams microphone audio (VoIP, voice chat) |
| `BLUETOOTH` / `BLUETOOTH_CONNECT` (API 31+) | Your app manages Bluetooth headset routing explicitly |
| `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_MICROPHONE` | Long-running background voice calls on newer Android versions |

No Dart or Kotlin runtime permission code is required for `MODIFY_AUDIO_SETTINGS` alone.

---

### iOS

The plugin uses `AVAudioSession` with category `.playAndRecord` when calling `setRoute()`. iOS does not expose a dedicated “modify audio settings” permission string for this plugin.

#### Microphone usage description (host app)

If your app **captures microphone input** (typical for VoIP / voice calls), you must add a usage description to the host app `Info.plist`. Without it, iOS will terminate the app when microphone access is requested.

File: `ios/Runner/Info.plist`

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone for voice calls.</string>
```

Replace the string with text that matches your App Store review scenario.

#### Background audio (optional)

For VoIP apps that must keep the audio session active while backgrounded, add the `audio` background mode to the host app:

File: `ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

This is **not** required for simply toggling speaker vs earpiece in the foreground.

#### Capabilities checklist

| Configuration | File | Required | Notes |
|---------------|------|----------|-------|
| `NSMicrophoneUsageDescription` | `ios/Runner/Info.plist` | When using mic | Shown on first microphone access |
| `UIBackgroundModes` → `audio` | `ios/Runner/Info.plist` | Optional | Background VoIP / continuous audio |
| Xcode → Signing & Capabilities | Xcode project | Optional | Enable **Background Modes → Audio** if you use background audio |

#### Audio session interaction

On iOS, `setRoute()` activates the shared `AVAudioSession`. If another SDK (WebRTC, Agora, LiveKit, etc.) also manages the session, configure route switching **after** that SDK initializes its session, or coordinate category / mode between libraries to avoid conflicts.

---

### Configuration summary

**Minimum setup to use this plugin:**

1. Add the dependency and run `flutter pub get`.
2. **Android:** No extra steps in most projects (permission is merged automatically).
3. **iOS:** No extra keys if you only switch routes during foreground playback without microphone capture.
4. **iOS + VoIP / mic:** Add `NSMicrophoneUsageDescription` (and optionally `UIBackgroundModes` → `audio`) in your host app.

**Example app:** See [`example/android/app/src/main/AndroidManifest.xml`](example/android/app/src/main/AndroidManifest.xml) and [`example/ios/Runner/Info.plist`](example/ios/Runner/Info.plist) for reference layouts. The example relies on the plugin’s merged Android permission and does not require microphone keys unless you extend it for live capture.

## Usage

Import the package and create a plugin instance:

```dart
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';

final toggle = XueHuaSpeakerEarpieceToggle();
```

### Read the current route

```dart
final route = await toggle.getRoute();

switch (route) {
  case AudioOutputRoute.speaker:
    // Audio is routed through the loudspeaker.
    break;
  case AudioOutputRoute.earpiece:
    // Audio is routed through the earpiece receiver.
    break;
  case AudioOutputRoute.external:
    // Wired headset, Bluetooth, AirPlay, etc.
    break;
  case AudioOutputRoute.unknown:
    // Session inactive or route cannot be determined.
    break;
}
```

### Switch the route

```dart
final speakerResult = await toggle.setRoute(AudioOutputRoute.speaker);
if (!speakerResult.available) {
  // OS kept audio on [speakerResult.applied], e.g. external device priority.
}

final earpieceResult = await toggle.setRoute(AudioOutputRoute.earpiece);
```

Only `AudioOutputRoute.speaker` and `AudioOutputRoute.earpiece` are valid `setRoute` requests.

### Listen for route changes

```dart
final subscription = toggle.onRouteChanged.listen((route) {
  // Updates when the OS or another SDK changes the active output.
  // Emits the current route immediately on subscription.
});

// Cancel when done.
await subscription.cancel();
```

## API reference

### `AudioOutputRoute`

| Value | Description |
|-------|-------------|
| `speaker` | Routes audio through the device loudspeaker. |
| `earpiece` | Routes audio through the earpiece receiver. |
| `external` | Wired headset, Bluetooth, AirPlay, or similar external output. |
| `unknown` | Route cannot be determined (e.g. inactive audio session). |

### `RouteResult`

Returned by `setRoute()`.

| Field | Type | Description |
|-------|------|-------------|
| `requested` | `AudioOutputRoute` | Route the caller asked for. |
| `applied` | `AudioOutputRoute` | Route actually in effect after the platform applied the change. |
| `available` | `bool` | Whether `requested` was fully applied (`applied == requested`). |

### `XueHuaSpeakerEarpieceToggle`

| Method | Return type | Description |
|--------|-------------|-------------|
| `getRoute()` | `Future<AudioOutputRoute>` | Returns the current native audio route. |
| `setRoute(AudioOutputRoute route)` | `Future<RouteResult>` | Switches the native audio route and reports what was applied. |
| `onRouteChanged` | `Stream<AudioOutputRoute>` | Emits on subscription and when the OS changes the active route. |

Both methods may throw `PlatformException` when the native platform rejects the request.

## Migrating from 1.x to 2.0.0

1. **`setRoute` now returns `RouteResult`** instead of `Future<void>`. Check `result.available` and use `result.applied` for UI state.
2. **Handle new `AudioOutputRoute` values** — `external` and `unknown` can be returned from `getRoute()`. Only `speaker` and `earpiece` may be passed to `setRoute()`.
3. **Re-read after switching** — when external devices are connected, `applied` may differ from `requested`.
4. **Session behavior** — native implementations now avoid unnecessary session/mode changes and restore borrowed state on plugin detach where possible.

## Example app

The [`example/`](example/) directory contains a small demo that shows the current route and lets you switch between speaker and earpiece.

Run it on a physical device for the most reliable audio behavior:

```bash
cd example
flutter run
```

## Platform behavior

### Android

- Detects routes via `communicationDevice` on API 31+, with legacy fallbacks for wired/BT headsets.
- Applies speaker/earpiece using `setCommunicationDevice()` on API 34+ when available, otherwise `MODE_IN_COMMUNICATION` + `isSpeakerphoneOn`.
- Saves and restores the previous `AudioManager.mode` on plugin detach when changed.

### iOS

- Detects routes from `AVAudioSession.currentRoute` output ports (`speaker`, `earpiece`, `external`, `unknown`).
- Configures the session only when category/mode mismatch or activation is required before applying a route.
- Uses `overrideOutputAudioPort(.speaker)` for speaker mode and `.none` to clear speaker override.
- Restores borrowed session configuration on plugin teardown when the plugin changed it.

## Known limitations

- This plugin toggles **speaker vs earpiece**, not general media playback routing.
- When wired or Bluetooth headsets are connected, the operating system may prioritize the external device. `getRoute()` reports `external` and `setRoute()` returns `available: false` when the requested route could not be applied.
- Other audio SDKs in the same app may override the session category or output port. Coordinate audio session ownership with those libraries.
- Always validate route switching on real hardware during an active call or while audio is playing.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

See [LICENSE](LICENSE).
