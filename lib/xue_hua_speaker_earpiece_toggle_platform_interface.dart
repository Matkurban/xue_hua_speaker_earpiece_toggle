import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_output_route.dart';
import 'xue_hua_speaker_earpiece_toggle_method_channel.dart';

/// Platform contract for reading and switching speaker/earpiece routes.
/// 用于读取与切换扬声器/听筒路由的平台契约。
abstract class XueHuaSpeakerEarpieceTogglePlatform extends PlatformInterface {
  /// Constructs a [XueHuaSpeakerEarpieceTogglePlatform].
  /// 构造 [XueHuaSpeakerEarpieceTogglePlatform]。
  XueHuaSpeakerEarpieceTogglePlatform() : super(token: _token);

  static final Object _token = Object();

  static XueHuaSpeakerEarpieceTogglePlatform _instance =
      MethodChannelXueHuaSpeakerEarpieceToggle();

  /// The default instance of [XueHuaSpeakerEarpieceTogglePlatform] to use.
  /// 默认使用的 [XueHuaSpeakerEarpieceTogglePlatform] 实例。
  ///
  /// Defaults to [MethodChannelXueHuaSpeakerEarpieceToggle].
  /// 默认为 [MethodChannelXueHuaSpeakerEarpieceToggle]。
  static XueHuaSpeakerEarpieceTogglePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XueHuaSpeakerEarpieceTogglePlatform]
  /// when they register themselves.
  /// 平台实现应在注册时用自身子类替换此实例。
  static set instance(XueHuaSpeakerEarpieceTogglePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the current audio output route from the native platform.
  /// 从原生平台获取当前音频输出路由。
  Future<AudioOutputRoute> getRoute() {
    throw UnimplementedError('getRoute() has not been implemented.');
  }

  /// Switches the audio output route on the native platform.
  /// 在原生平台上切换音频输出路由。
  Future<void> setRoute(AudioOutputRoute route) {
    throw UnimplementedError('setRoute() has not been implemented.');
  }
}
