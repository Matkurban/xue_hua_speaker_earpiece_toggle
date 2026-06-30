import AVFoundation

final class RouteApplicator {
  private let session: AudioSessionProtocol
  private let detector: RouteDetector
  private let coordinator: SessionCoordinator

  init(
    session: AudioSessionProtocol,
    detector: RouteDetector,
    coordinator: SessionCoordinator
  ) {
    self.session = session
    self.detector = detector
    self.coordinator = coordinator
  }

  func apply(route: String) throws -> RouteApplyResult {
    guard AudioRouteNames.switchableRoutes.contains(route) else {
      throw AudioRouteError.invalidRoute(route)
    }

    try coordinator.prepareForRouteChange()

    switch route {
    case AudioRouteNames.speaker:
      try session.overrideOutputAudioPort(.speaker)
    case AudioRouteNames.earpiece:
      try session.overrideOutputAudioPort(.none)
    default:
      throw AudioRouteError.invalidRoute(route)
    }

    let applied = detector.detect()
    return RouteApplyResult(applied: applied, available: applied == route)
  }
}
