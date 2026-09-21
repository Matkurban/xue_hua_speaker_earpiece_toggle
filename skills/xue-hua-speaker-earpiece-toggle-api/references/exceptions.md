# PlatformException codes

`getRoute`, `setRoute`, `restoreSession`, and `onRouteChanged` may complete with / emit `PlatformException`. Always catch `PlatformException` (from `package:flutter/services.dart`) around those APIs.

## Dart (`MethodChannelXueHuaSpeakerEarpieceToggle`)

Thrown in Dart before or after the channel, in `lib/xue_hua_speaker_earpiece_toggle_method_channel.dart`.

| code | When |
| --- | --- |
| `INVALID_ROUTE` | `setRoute` given `external` or `unknown` (`!isSwitchableAudioOutputRoute`). Message: `Only speaker and earpiece routes can be set: ${route.name}`. |
| `INVALID_ROUTE` | `getRoute` native result is not a `String`. |
| `INVALID_ROUTE` | `onRouteChanged` event is not a `String`. |
| `INVALID_ROUTE` | `parseRoute` given `null`. Message: `Native platform returned a null route.` |
| `INVALID_ROUTE` | `parseRoute` string is not `speaker` / `earpiece` / `external` / `unknown`. Message: `Unknown audio route: $value`. |
| `INVALID_ROUTE_RESULT` | `setRoute` native result is not a `Map`. |
| `INVALID_ROUTE_RESULT` | native map `applied` is missing or not a `String`. |
| `INVALID_ROUTE_RESULT` | native map `available` is missing or not a `bool`. |

`details` on these Dart exceptions is a Chinese string mirroring `message`.

`requested` on the returned `RouteResult` is always the Dart argument, not a native field. Native `setRoute` maps contain only `applied` and `available`.

## Native `setRoute` (Android / iOS)

These become `PlatformException` on the Dart isolate.

| code | When |
| --- | --- |
| `INVALID_ARGUMENT` | Missing `route` argument, or `route` is not a string. |
| `INVALID_ROUTE` | Native string is not in `{speaker, earpiece}`. Android/iOS message: `Unknown audio route: $route`. |
| `AUDIO_ROUTE_ERROR` | Any other exception while applying the route (Android `Exception.message`; iOS `localizedDescription`). |

`getRoute` and `restoreSession` native handlers return a string / `null` and do not use these error codes.

## `restoreSession`

The Dart method-channel implementation does not map a dedicated error code. A channel failure still surfaces as `PlatformException` from `invokeMethod`.
