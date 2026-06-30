import Flutter
import UIKit

public class XueHuaSpeakerEarpieceTogglePlugin: NSObject, FlutterPlugin {
  private let controller = AudioRouteController()
  private lazy var routeChangeStreamHandler = RouteChangeStreamHandler(
    controller: controller
  )

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = XueHuaSpeakerEarpieceTogglePlugin()
    let methodChannel = FlutterMethodChannel(
      name: "xue_hua_speaker_earpiece_toggle",
      binaryMessenger: registrar.messenger()
    )
    let eventChannel = FlutterEventChannel(
      name: "xue_hua_speaker_earpiece_toggle/events",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance.routeChangeStreamHandler)
  }

  deinit {
    controller.restoreSessionIfNeeded()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getRoute":
      result(controller.getRoute())
    case "setRoute":
      guard let arguments = call.arguments as? [String: Any] else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENT",
            message: "Missing route argument.",
            details: nil
          )
        )
        return
      }

      guard let route = arguments["route"] as? String else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENT",
            message: "Route argument must be a string.",
            details: nil
          )
        )
        return
      }

      do {
        let applyResult = try controller.setRoute(route)
        result(applyResult.dictionary)
      } catch let error as AudioRouteError {
        let flutterError = error.flutterError
        result(
          FlutterError(
            code: flutterError.code,
            message: flutterError.message,
            details: nil
          )
        )
      } catch {
        result(
          FlutterError(
            code: "AUDIO_ROUTE_ERROR",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}