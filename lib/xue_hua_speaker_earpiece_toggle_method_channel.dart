import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_output_route.dart';
import 'route_result.dart';
import 'xue_hua_speaker_earpiece_toggle_platform_interface.dart';

/// Method channel implementation of [XueHuaSpeakerEarpieceTogglePlatform].
/// [XueHuaSpeakerEarpieceTogglePlatform] 的 Method Channel 实现。
class MethodChannelXueHuaSpeakerEarpieceToggle
    extends XueHuaSpeakerEarpieceTogglePlatform {
  /// The method channel used to interact with the native platform.
  /// 与原生平台通信的 Method Channel。
  @visibleForTesting
  final methodChannel = const MethodChannel('xue_hua_speaker_earpiece_toggle');

  /// Event channel for route change notifications.
  /// 路由变更通知的 Event Channel。
  @visibleForTesting
  final eventChannel = const EventChannel(
    'xue_hua_speaker_earpiece_toggle/events',
  );

  @override
  Stream<AudioOutputRoute> get onRouteChanged {
    return eventChannel.receiveBroadcastStream().map((event) {
      if (event is! String) {
        throw PlatformException(
          code: 'INVALID_ROUTE',
          message:
              'Native platform returned an invalid route event type: $event',
          details: '原生平台返回了无效的路由事件类型：$event',
        );
      }
      return parseRoute(event);
    });
  }

  @override
  Future<AudioOutputRoute> getRoute() async {
    final result = await methodChannel.invokeMethod<Object?>('getRoute');
    if (result is! String) {
      throw PlatformException(
        code: 'INVALID_ROUTE',
        message: 'Native platform returned an invalid route type: $result',
        details: '原生平台返回了无效的路由类型：$result',
      );
    }
    return parseRoute(result);
  }

  @override
  Future<RouteResult> setRoute(AudioOutputRoute route) async {
    if (!isSwitchableAudioOutputRoute(route)) {
      throw PlatformException(
        code: 'INVALID_ROUTE',
        message: 'Only speaker and earpiece routes can be set: ${route.name}',
        details: '仅可设置 speaker 与 earpiece 路由：${route.name}',
      );
    }

    final result = await methodChannel.invokeMethod<Object?>(
      'setRoute',
      <String, String>{'route': route.name},
    );
    return parseRouteResult(route, result);
  }

  /// Maps a platform route string to [AudioOutputRoute].
  /// 将平台路由字符串映射为 [AudioOutputRoute]。
  @visibleForTesting
  AudioOutputRoute parseRoute(String? value) {
    if (value == null) {
      throw PlatformException(
        code: 'INVALID_ROUTE',
        message: 'Native platform returned a null route.',
        details: '原生平台返回了空路由。',
      );
    }

    for (final route in AudioOutputRoute.values) {
      if (route.name == value) {
        return route;
      }
    }

    throw PlatformException(
      code: 'INVALID_ROUTE',
      message: 'Unknown audio route: $value',
      details: '未知的音频路由：$value',
    );
  }

  /// Parses the native [setRoute] response into [RouteResult].
  /// 将原生 [setRoute] 响应解析为 [RouteResult]。
  @visibleForTesting
  RouteResult parseRouteResult(AudioOutputRoute requested, Object? value) {
    if (value is! Map) {
      throw PlatformException(
        code: 'INVALID_ROUTE_RESULT',
        message: 'Native platform returned an invalid setRoute result: $value',
        details: '原生平台返回了无效的 setRoute 结果：$value',
      );
    }

    final appliedValue = value['applied'];
    if (appliedValue is! String) {
      throw PlatformException(
        code: 'INVALID_ROUTE_RESULT',
        message: 'Native platform returned a missing applied route.',
        details: '原生平台未返回 applied 路由。',
      );
    }

    final availableValue = value['available'];
    if (availableValue is! bool) {
      throw PlatformException(
        code: 'INVALID_ROUTE_RESULT',
        message: 'Native platform returned a missing available flag.',
        details: '原生平台未返回 available 标志。',
      );
    }

    return RouteResult(
      requested: requested,
      applied: parseRoute(appliedValue),
      available: availableValue,
    );
  }
}
