import 'audio_output_route.dart';
import 'xue_hua_speaker_earpiece_toggle_platform_interface.dart';

export 'audio_output_route.dart';

/// Flutter plugin for toggling between speaker and earpiece audio routes.
/// 用于在扬声器与听筒音频路由之间切换的 Flutter 插件。
class XueHuaSpeakerEarpieceToggle {
  /// Returns the current [AudioOutputRoute] from the native platform.
  /// 从原生平台获取当前 [AudioOutputRoute]。
  Future<AudioOutputRoute> getRoute() {
    return XueHuaSpeakerEarpieceTogglePlatform.instance.getRoute();
  }

  /// Switches the audio output to the given [route].
  /// 将音频输出切换到指定的 [route]。
  Future<void> setRoute(AudioOutputRoute route) {
    return XueHuaSpeakerEarpieceTogglePlatform.instance.setRoute(route);
  }
}
