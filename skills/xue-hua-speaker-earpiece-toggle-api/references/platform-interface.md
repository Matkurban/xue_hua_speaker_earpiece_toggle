# Platform interface and method channel

Use these types for **unit tests** and **federated / fake platforms**. App UI should construct `XueHuaSpeakerEarpieceToggle` and stay on the barrel import.

```dart
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle_platform_interface.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle_method_channel.dart';
```

## `XueHuaSpeakerEarpieceTogglePlatform`

Abstract `PlatformInterface` in `lib/xue_hua_speaker_earpiece_toggle_platform_interface.dart`.

### Constructor

```dart
XueHuaSpeakerEarpieceTogglePlatform() : super(token: _token);
```

Subclasses must call this constructor so `PlatformInterface.verifyToken` accepts them.

### `static XueHuaSpeakerEarpieceTogglePlatform get instance`

Default is a `MethodChannelXueHuaSpeakerEarpieceToggle()`. `XueHuaSpeakerEarpieceToggle` reads this getter on every call.

### `static set instance(XueHuaSpeakerEarpieceTogglePlatform instance)`

Replaces the implementation. Calls `PlatformInterface.verifyToken(instance, _token)` then assigns. Tests typically mix in `MockPlatformInterfaceMixin` (see `test/xue_hua_speaker_earpiece_toggle_test.dart`). Restore the previous instance in `tearDown`.

### Default method bodies

The abstract class provides implementations that **throw `UnimplementedError`**:

| Member | Default error message |
| --- | --- |
| `Future<AudioOutputRoute> getRoute()` | `getRoute() has not been implemented.` |
| `Future<RouteResult> setRoute(AudioOutputRoute route)` | `setRoute() has not been implemented.` |
| `Future<void> restoreSession()` | `restoreSession() has not been implemented.` |
| `Stream<AudioOutputRoute> get onRouteChanged` | `onRouteChanged has not been implemented.` |

Custom platforms must override all four. Semantics match `XueHuaSpeakerEarpieceToggle`: only `speaker`/`earpiece` for `setRoute`; `onRouteChanged` should emit the current route on subscription.

## `MethodChannelXueHuaSpeakerEarpieceToggle`

Default platform in `lib/xue_hua_speaker_earpiece_toggle_method_channel.dart`. Extends `XueHuaSpeakerEarpieceTogglePlatform`.

### Fields (`@visibleForTesting`)

| Member | Type | Channel name |
| --- | --- | --- |
| `methodChannel` | `MethodChannel` | `xue_hua_speaker_earpiece_toggle` |
| `eventChannel` | `EventChannel` | `xue_hua_speaker_earpiece_toggle/events` |

### Overrides

- `onRouteChanged` — `eventChannel.receiveBroadcastStream().map`: non-`String` → `INVALID_ROUTE`; else `parseRoute`.
- `getRoute` — `invokeMethod('getRoute')`; non-`String` → `INVALID_ROUTE`; else `parseRoute`.
- `setRoute` — reject non-switchable routes with `INVALID_ROUTE`; `invokeMethod('setRoute', {'route': route.name})`; `parseRouteResult`.
- `restoreSession` — `invokeMethod<void>('restoreSession')`.

### `AudioOutputRoute parseRoute(String? value)` (`@visibleForTesting`)

Maps a native string to `AudioOutputRoute` by comparing `route.name`.

- `null` → `PlatformException(code: INVALID_ROUTE)` (`Native platform returned a null route.`).
- Match against `AudioOutputRoute.values`.
- No match → `INVALID_ROUTE` (`Unknown audio route: $value`).

### `RouteResult parseRouteResult(AudioOutputRoute requested, Object? value)` (`@visibleForTesting`)

- `value` not a `Map` → `INVALID_ROUTE_RESULT`.
- `value['applied']` not a `String` → `INVALID_ROUTE_RESULT`.
- `value['available']` not a `bool` → `INVALID_ROUTE_RESULT`.
- Returns `RouteResult(requested: requested, applied: parseRoute(appliedValue), available: availableValue)`.

`requested` is the Dart argument, never read from the map.

## Test pattern

```dart
class FakePlatform extends XueHuaSpeakerEarpieceTogglePlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<AudioOutputRoute> getRoute() async => AudioOutputRoute.speaker;

  @override
  Future<RouteResult> setRoute(AudioOutputRoute route) async =>
      RouteResult(requested: route, applied: route, available: true);

  @override
  Future<void> restoreSession() async {}

  @override
  Stream<AudioOutputRoute> get onRouteChanged =>
      Stream<AudioOutputRoute>.empty();
}

final previous = XueHuaSpeakerEarpieceTogglePlatform.instance;
XueHuaSpeakerEarpieceTogglePlatform.instance = FakePlatform();
// ...
XueHuaSpeakerEarpieceTogglePlatform.instance = previous;
```
