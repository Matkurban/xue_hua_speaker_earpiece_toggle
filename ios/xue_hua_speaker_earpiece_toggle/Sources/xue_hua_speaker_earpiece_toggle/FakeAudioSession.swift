import AVFoundation

#if DEBUG
final class FakeAudioSession: AudioSessionProtocol {
  var outputPortTypes: [AVAudioSession.Port] = []
  var category: AVAudioSession.Category = .ambient
  var categoryOptions: AVAudioSession.CategoryOptions = []
  var mode: AVAudioSession.Mode = .default
  var setCategoryCalls = 0
  var setActiveCalls = 0
  var overridePortCalls: [AVAudioSession.PortOverride] = []

  func setCategory(
    _ category: AVAudioSession.Category,
    mode: AVAudioSession.Mode,
    options: AVAudioSession.CategoryOptions
  ) throws {
    setCategoryCalls += 1
    self.category = category
    self.mode = mode
    self.categoryOptions = options
  }

  func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
    setActiveCalls += 1
    if !active {
      outputPortTypes = []
    }
  }

  func overrideOutputAudioPort(_ port: AVAudioSession.PortOverride) throws {
    overridePortCalls.append(port)
    switch port {
    case .speaker:
      outputPortTypes = [.builtInSpeaker]
    case .none:
      if !outputPortTypes.contains(where: Self.isExternalPort) {
        outputPortTypes = [.builtInReceiver]
      }
    default:
      break
    }
  }

  private static func isExternalPort(_ port: AVAudioSession.Port) -> Bool {
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
#endif
