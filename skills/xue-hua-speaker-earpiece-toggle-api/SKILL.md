---
name: xue-hua-speaker-earpiece-toggle-api
description: >-
  Use when calling or documenting xue_hua_speaker_earpiece_toggle APIs:
  XueHuaSpeakerEarpieceToggle, AudioOutputRoute, RouteResult,
  switchableAudioOutputRoutes, isSwitchableAudioOutputRoute, PlatformException
  codes, or XueHuaSpeakerEarpieceTogglePlatform mocks.
---

# xue_hua_speaker_earpiece_toggle API

Source of truth: `lib/`. Consumer barrel:

```dart
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';
```

That library exports `AudioOutputRoute`, `switchableAudioOutputRoutes`, `isSwitchableAudioOutputRoute`, `RouteResult`, and `XueHuaSpeakerEarpieceToggle`. Platform-interface types are **not** barrel-exported; import them only for tests or custom platforms — see [platform-interface.md](references/platform-interface.md). Exception codes: [exceptions.md](references/exceptions.md).

Setup, permissions, and call-end restore: sibling skill `xue-hua-speaker-earpiece-toggle-usage`.

## `XueHuaSpeakerEarpieceToggle`

Plugin facade. File: `lib/xue_hua_speaker_earpiece_toggle.dart`.

Delegates every member to `XueHuaSpeakerEarpieceTogglePlatform.instance` (default: `MethodChannelXueHuaSpeakerEarpieceToggle`).

### Constructor

Implicit default constructor. No parameters, no `initialize()`.

```dart
final toggle = XueHuaSpeakerEarpieceToggle();
```

### `Future<AudioOutputRoute> getRoute()`

Reads the active native output.

- **Returns:** `AudioOutputRoute.speaker`, `.earpiece`, `.external`, or `.unknown`.
- **Throws:** `PlatformException` with `code: INVALID_ROUTE` when the method-channel payload is not a `String`, is `null`, or is not one of the four enum `name`s.

### `Future<RouteResult> setRoute(AudioOutputRoute route)`

Requests speaker or earpiece on the native platform.

- **Parameter `route`:** must be in `switchableAudioOutputRoutes` (`speaker`, `earpiece`).
- **Returns:** `RouteResult` with `requested` equal to the argument, `applied` from native, `available` from native (`applied == requested` on the native side).
- **Throws before the channel call:** `PlatformException(code: INVALID_ROUTE)` when `!isSwitchableAudioOutputRoute(route)` — message `Only speaker and earpiece routes can be set: ${route.name}`.
- **Throws after the channel call:** `INVALID_ROUTE_RESULT` if the native map is missing `applied` (`String`) or `available` (`bool`); native `INVALID_ARGUMENT`, `INVALID_ROUTE`, or `AUDIO_ROUTE_ERROR` (see [exceptions.md](references/exceptions.md)).
- **Side effects:** Android may set `AudioManager` to `MODE_IN_COMMUNICATION`; iOS may set category `.playAndRecord`, mode `.voiceChat`, option `.allowBluetooth`, activate the session, then `overrideOutputAudioPort(.speaker)` or `.none`.

### `Future<void> restoreSession()`

Restores the audio session snapshot this plugin took during `setRoute`, if any.

- **Returns:** `Future<void>` (native success payload is `null`).
- **No-op** when the plugin never changed the session (no snapshot).
- **Android:** restores previous `AudioManager.mode` if this plugin changed it.
- **iOS:** clears speaker override; restores previous category/mode/options if this plugin changed them; deactivates the session if this plugin activated it.
- Native also calls the same restore on plugin detach (`onDetachedFromEngine` / `deinit`).
- Host apps still call this when a call ends so media routing returns before the engine detaches.

### `Stream<AudioOutputRoute> get onRouteChanged`

Broadcast stream of the active route.

- **First event:** current route, emitted by native `onListen`.
- **Later events:** OS or another SDK changes output; this plugin's `setRoute` also notifies the same sink.
- **Throws in the stream:** `PlatformException(code: INVALID_ROUTE)` if an event is not a `String` or is not a known route `name`.
- **Lifecycle:** cancel the `StreamSubscription` when the widget/controller is disposed.

```dart
final sub = toggle.onRouteChanged.listen((route) {}, onError: (Object e) {});
await sub.cancel();
```

## `AudioOutputRoute`

Enum. File: `lib/audio_output_route.dart`. Wire format is `enum.name`: `'speaker'`, `'earpiece'`, `'external'`, `'unknown'`.

| Value | Meaning |
| --- | --- |
| `speaker` | Built-in loudspeaker. Valid `setRoute` argument. |
| `earpiece` | Built-in receiver. Valid `setRoute` argument. |
| `external` | Wired headset, Bluetooth, AirPlay, USB, car audio, line-out, or similar. Report-only. |
| `unknown` | Cannot determine the route (for example iOS `currentRoute` outputs empty / inactive session). Report-only. |

Exhaustive `switch` on all four values.

## `switchableAudioOutputRoutes`

```dart
const switchableAudioOutputRoutes = <AudioOutputRoute>{
  AudioOutputRoute.speaker,
  AudioOutputRoute.earpiece,
};
```

Top-level `const Set<AudioOutputRoute>`. The set of routes `setRoute` accepts.

## `isSwitchableAudioOutputRoute`

```dart
bool isSwitchableAudioOutputRoute(AudioOutputRoute route)
```

Top-level function. Returns whether `switchableAudioOutputRoutes` contains `route`. Use before `setRoute` when the value might be `external` or `unknown`.

## `RouteResult`

Immutable outcome of `setRoute`. File: `lib/route_result.dart`.

### Constructor

```dart
const RouteResult({
  required AudioOutputRoute requested,
  required AudioOutputRoute applied,
  required bool available,
});
```

All three fields are required named parameters. The class is const-constructible.

### Fields

| Member | Type | Meaning |
| --- | --- | --- |
| `requested` | `AudioOutputRoute` | Argument passed to `setRoute`. |
| `applied` | `AudioOutputRoute` | Route in effect after native apply (from native `applied` string). |
| `available` | `bool` | Native flag that the request fully applied. Documented and computed on native as `applied == requested`. Dart copies the bool; it does not recompute it. |

### `operator ==`

Two `RouteResult`s are equal when `requested`, `applied`, and `available` are all equal.

### `int get hashCode`

`Object.hash(requested, applied, available)`.

### `String toString()`

`'RouteResult(requested: $requested, applied: $applied, available: $available)'`.

```dart
final result = await toggle.setRoute(AudioOutputRoute.speaker);
if (!result.available) {
  // Use result.applied for UI; result.requested is what was asked.
}
```

## Channel names (default implementation)

| Channel | Name |
| --- | --- |
| MethodChannel | `xue_hua_speaker_earpiece_toggle` |
| EventChannel | `xue_hua_speaker_earpiece_toggle/events` |

Methods: `getRoute` (no args), `setRoute` (`{'route': route.name}`), `restoreSession` (no args).
