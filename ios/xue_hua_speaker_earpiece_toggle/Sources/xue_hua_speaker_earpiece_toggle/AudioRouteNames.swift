import Foundation

enum AudioRouteNames {
  static let speaker = "speaker"
  static let earpiece = "earpiece"
  static let external = "external"
  static let unknown = "unknown"

  static let switchableRoutes: Set<String> = [speaker, earpiece]
}

struct RouteApplyResult {
  let applied: String
  let available: Bool

  var dictionary: [String: Any] {
    ["applied": applied, "available": available]
  }
}

enum AudioRouteError: Error {
  case invalidRoute(String)

  var flutterError: (code: String, message: String) {
    switch self {
    case .invalidRoute(let route):
      return ("INVALID_ROUTE", "Unknown audio route: \(route)")
    }
  }
}
