import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_output_route.dart';
import 'xue_hua_speaker_earpiece_toggle_platform_interface.dart';

/// Method channel implementation of [XueHuaSpeakerEarpieceTogglePlatform].
/// [XueHuaSpeakerEarpieceTogglePlatform] 的 Method Channel 实现。
class MethodChannelXueHuaSpeakerEarpieceToggle
    extends XueHuaSpeakerEarpieceTogglePlatform {
  /// The method channel used to interact with the native platform.
  /// 与原生平台通信的 Method Channel。
  @visibleForTesting
  final methodChannel = const MethodChannel('xue_hua_speaker_earpiece_toggle');

  @override
  Future<AudioOutputRoute> getRoute() async {
    final route = await methodChannel.invokeMethod<String>('getRoute');
    return _parseRoute(route);
  }

  @override
  Future<void> setRoute(AudioOutputRoute route) async {
    await methodChannel.invokeMethod<void>('setRoute', <String, String>{
      'route': route.name,
    });
  }

  // Map the platform string to enum; throw on unknown values.
  // 将平台返回的字符串映射为枚举；未知值时抛出异常。
  AudioOutputRoute _parseRoute(String? value) {
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
}
