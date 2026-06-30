import 'audio_output_route.dart';
import 'route_result.dart';
import 'xue_hua_speaker_earpiece_toggle_platform_interface.dart';

export 'audio_output_route.dart';
export 'route_result.dart';

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
  ///
  /// Only [AudioOutputRoute.speaker] and [AudioOutputRoute.earpiece] are
  /// accepted. Returns a [RouteResult] with the applied route.
  /// 仅接受 [AudioOutputRoute.speaker] 与 [AudioOutputRoute.earpiece]；
  /// 返回包含实际生效路由的 [RouteResult]。
  Future<RouteResult> setRoute(AudioOutputRoute route) {
    return XueHuaSpeakerEarpieceTogglePlatform.instance.setRoute(route);
  }

  /// Emits whenever the native audio route changes.
  /// 当原生音频路由发生变化时发出事件。
  ///
  /// The stream emits the current route immediately on subscription, then
  /// whenever the OS or another SDK changes the active output.
  /// 订阅后立即发出当前路由，随后在系统或其他 SDK 改变输出时再次发出。
  Stream<AudioOutputRoute> get onRouteChanged {
    return XueHuaSpeakerEarpieceTogglePlatform.instance.onRouteChanged;
  }
}
