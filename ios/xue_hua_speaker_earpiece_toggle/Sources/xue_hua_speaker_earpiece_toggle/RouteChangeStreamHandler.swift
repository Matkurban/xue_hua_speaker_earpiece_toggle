import AVFoundation
import Flutter

final class RouteChangeStreamHandler: NSObject, FlutterStreamHandler {
  private let controller: AudioRouteController
  private var eventSink: FlutterEventSink?

  init(controller: AudioRouteController) {
    self.controller = controller
    super.init()
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    controller.onRouteChanged = { [weak self] route in
      self?.eventSink?(route)
    }

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleRouteChangeNotification),
      name: AVAudioSession.routeChangeNotification,
      object: nil
    )

    events(controller.getRoute())
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(
      self,
      name: AVAudioSession.routeChangeNotification,
      object: nil
    )
    controller.onRouteChanged = nil
    eventSink = nil
    return nil
  }

  @objc private func handleRouteChangeNotification() {
    eventSink?(controller.getRoute())
  }
}
