import AVFoundation

protocol RouteOutputProviding: AnyObject {
  var outputPortTypes: [AVAudioSession.Port] { get }
}

protocol AudioSessionProtocol: RouteOutputProviding {
  var category: AVAudioSession.Category { get }
  var categoryOptions: AVAudioSession.CategoryOptions { get }
  var mode: AVAudioSession.Mode { get }
  func setCategory(
    _ category: AVAudioSession.Category,
    mode: AVAudioSession.Mode,
    options: AVAudioSession.CategoryOptions
  ) throws
  func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws
  func overrideOutputAudioPort(_ port: AVAudioSession.PortOverride) throws
}

final class LiveAudioSession: AudioSessionProtocol {
  private let session = AVAudioSession.sharedInstance()

  var outputPortTypes: [AVAudioSession.Port] {
    session.currentRoute.outputs.map(\.portType)
  }

  var category: AVAudioSession.Category {
    session.category
  }

  var categoryOptions: AVAudioSession.CategoryOptions {
    session.categoryOptions
  }

  var mode: AVAudioSession.Mode {
    session.mode
  }

  func setCategory(
    _ category: AVAudioSession.Category,
    mode: AVAudioSession.Mode,
    options: AVAudioSession.CategoryOptions
  ) throws {
    try session.setCategory(category, mode: mode, options: options)
  }

  func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
    try session.setActive(active, options: options)
  }

  func overrideOutputAudioPort(_ port: AVAudioSession.PortOverride) throws {
    try session.overrideOutputAudioPort(port)
  }
}
