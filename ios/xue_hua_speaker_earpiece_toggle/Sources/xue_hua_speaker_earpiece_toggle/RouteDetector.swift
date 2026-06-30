import AVFoundation

final class RouteDetector {
  private let session: RouteOutputProviding

  init(session: RouteOutputProviding) {
    self.session = session
  }

  func detect() -> String {
    let outputs = session.outputPortTypes
    if outputs.isEmpty {
      return AudioRouteNames.unknown
    }

    if outputs.contains(.builtInSpeaker) {
      return AudioRouteNames.speaker
    }

    if outputs.contains(.builtInReceiver) {
      return AudioRouteNames.earpiece
    }

    if outputs.contains(where: isExternalPort) {
      return AudioRouteNames.external
    }

    return AudioRouteNames.unknown
  }

  private func isExternalPort(_ port: AVAudioSession.Port) -> Bool {
    switch port {
    case .bluetoothA2DP,
      .bluetoothHFP,
      .bluetoothLE,
      .headphones,
      .headsetMic,
      .airPlay,
      .carAudio,
      .usbAudio,
      .lineOut:
      return true
    default:
      return false
    }
  }
}
