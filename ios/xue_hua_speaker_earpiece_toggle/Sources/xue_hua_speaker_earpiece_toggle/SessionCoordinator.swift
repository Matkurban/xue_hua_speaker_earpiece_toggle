import AVFoundation

final class SessionCoordinator {
  private struct SessionSnapshot {
    let category: AVAudioSession.Category
    let mode: AVAudioSession.Mode
    let options: AVAudioSession.CategoryOptions
  }

  private let session: AudioSessionProtocol
  private var snapshot: SessionSnapshot?
  private var sessionActivatedByPlugin = false
  private var categoryChangedByPlugin = false

  private let targetCategory = AVAudioSession.Category.playAndRecord
  private let targetMode = AVAudioSession.Mode.voiceChat
  private let targetOptions: AVAudioSession.CategoryOptions = [.allowBluetooth]

  init(session: AudioSessionProtocol) {
    self.session = session
  }

  func prepareForRouteChange() throws {
    if snapshot == nil {
      snapshot = SessionSnapshot(
        category: session.category,
        mode: session.mode,
        options: session.categoryOptions
      )
    }

    let needsCategoryChange =
      session.category != targetCategory
      || session.mode != targetMode
      || !session.categoryOptions.contains(.allowBluetooth)

    if needsCategoryChange {
      try session.setCategory(targetCategory, mode: targetMode, options: targetOptions)
      categoryChangedByPlugin = true
    }

    if session.outputPortTypes.isEmpty {
      try session.setActive(true, options: [])
      sessionActivatedByPlugin = true
    }
  }

  func restoreIfNeeded() {
    guard snapshot != nil else {
      return
    }

    try? session.overrideOutputAudioPort(.none)

    if categoryChangedByPlugin, let snapshot {
      try? session.setCategory(
        snapshot.category,
        mode: snapshot.mode,
        options: snapshot.options
      )
    }

    if sessionActivatedByPlugin {
      try? session.setActive(false, options: [.notifyOthersOnDeactivation])
    }

    self.snapshot = nil
    sessionActivatedByPlugin = false
    categoryChangedByPlugin = false
  }
}
