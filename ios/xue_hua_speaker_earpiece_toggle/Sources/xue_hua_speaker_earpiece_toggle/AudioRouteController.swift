import Foundation

final class AudioRouteController {
  private let session: AudioSessionProtocol
  private let detector: RouteDetector
  private let coordinator: SessionCoordinator
  private let applicator: RouteApplicator

  var onRouteChanged: ((String) -> Void)?

  init(session: AudioSessionProtocol = LiveAudioSession()) {
    self.session = session
    let detector = RouteDetector(session: session)
    let coordinator = SessionCoordinator(session: session)
    self.detector = detector
    self.coordinator = coordinator
    self.applicator = RouteApplicator(
      session: session,
      detector: detector,
      coordinator: coordinator
    )
  }

  deinit {
    coordinator.restoreIfNeeded()
  }

  func getRoute() -> String {
    detector.detect()
  }

  func setRoute(_ route: String) throws -> RouteApplyResult {
    let result = try applicator.apply(route: route)
    onRouteChanged?(detector.detect())
    return result
  }

  func restoreSessionIfNeeded() {
    coordinator.restoreIfNeeded()
  }
}
