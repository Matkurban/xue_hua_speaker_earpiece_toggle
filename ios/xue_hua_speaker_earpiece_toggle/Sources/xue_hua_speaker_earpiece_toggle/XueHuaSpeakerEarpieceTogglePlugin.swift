import AVFoundation
import Flutter
import UIKit

public class XueHuaSpeakerEarpieceTogglePlugin: NSObject, FlutterPlugin {
  private static let routeSpeaker = "speaker"
  private static let routeEarpiece = "earpiece"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "xue_hua_speaker_earpiece_toggle",
      binaryMessenger: registrar.messenger()
    )
    let instance = XueHuaSpeakerEarpieceTogglePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getRoute":
      do {
        result(try currentRoute())
      } catch {
        result(
          FlutterError(
            code: "AUDIO_ROUTE_ERROR",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    case "setRoute":
      guard
        let arguments = call.arguments as? [String: Any],
        let route = arguments["route"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENT",
            message: "Missing route argument.",
            details: nil
          )
        )
        return
      }

      do {
        try applyRoute(route)
        result(nil)
      } catch let error as RouteError {
        result(
          FlutterError(
            code: error.code,
            message: error.message,
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

  private func currentRoute() throws -> String {
    let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
    if outputs.contains(where: { $0.portType == .builtInSpeaker }) {
      return Self.routeSpeaker
    }
    return Self.routeEarpiece
  }

  private func applyRoute(_ route: String) throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playAndRecord, options: [.allowBluetooth])
    try session.setActive(true)

    switch route {
    case Self.routeSpeaker:
      try session.overrideOutputAudioPort(.speaker)
    case Self.routeEarpiece:
      try session.overrideOutputAudioPort(.none)
    default:
      throw RouteError.invalidRoute(route)
    }
  }

  private struct RouteError: Error {
    let code: String
    let message: String

    static func invalidRoute(_ route: String) -> RouteError {
      RouteError(
        code: "INVALID_ROUTE",
        message: "Unknown audio route: \(route)"
      )
    }
  }
}
