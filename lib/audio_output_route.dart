/// Represents the active audio output route.
/// 表示当前激活的音频输出路由。
enum AudioOutputRoute {
  /// Routes audio through the loudspeaker.
  /// 通过外放扬声器输出音频。
  speaker,

  /// Routes audio through the earpiece receiver.
  /// 通过听筒输出音频。
  earpiece,

  /// Routes audio through a wired headset, Bluetooth, AirPlay, or similar.
  /// 通过有线耳机、蓝牙、AirPlay 等外接设备输出音频。
  external,

  /// Route cannot be determined (e.g. inactive audio session).
  /// 无法确定路由（例如音频会话未激活）。
  unknown,
}

/// Routes that [setRoute] can request.
/// [setRoute] 可请求的路由。
const switchableAudioOutputRoutes = <AudioOutputRoute>{
  AudioOutputRoute.speaker,
  AudioOutputRoute.earpiece,
};

/// Whether [route] can be passed to [setRoute].
/// [route] 是否可作为 [setRoute] 的参数。
bool isSwitchableAudioOutputRoute(AudioOutputRoute route) {
  return switchableAudioOutputRoutes.contains(route);
}
