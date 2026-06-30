import Flutter
import UIKit
import XCTest

@testable import xue_hua_speaker_earpiece_toggle

class RunnerTests: XCTestCase {
  func testGetRouteReturnsKnownValue() {
    let plugin = XueHuaSpeakerEarpieceTogglePlugin()
    let call = FlutterMethodCall(methodName: "getRoute", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      let route = result as! String
      XCTAssertTrue(
        route == "speaker"
          || route == "earpiece"
          || route == "external"
          || route == "unknown"
      )
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testSetRouteSpeakerReturnsRouteResult() {
    let plugin = XueHuaSpeakerEarpieceTogglePlugin()
    let call = FlutterMethodCall(
      methodName: "setRoute",
      arguments: ["route": "speaker"]
    )

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      let payload = result as! [String: Any]
      XCTAssertEqual(payload["applied"] as? String, "speaker")
      XCTAssertEqual(payload["available"] as? Bool, true)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testSetRouteWithInvalidValueReturnsError() {
    let plugin = XueHuaSpeakerEarpieceTogglePlugin()
    let call = FlutterMethodCall(
      methodName: "setRoute",
      arguments: ["route": "unknown"]
    )

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      let error = result as! FlutterError
      XCTAssertEqual(error.code, "INVALID_ROUTE")
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testSetRouteWithWrongTypeReturnsInvalidArgument() {
    let plugin = XueHuaSpeakerEarpieceTogglePlugin()
    let call = FlutterMethodCall(
      methodName: "setRoute",
      arguments: ["route": 1]
    )

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      let error = result as! FlutterError
      XCTAssertEqual(error.code, "INVALID_ARGUMENT")
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  #if DEBUG
  func testRouteDetectorMapsExternalPorts() {
    let session = FakeAudioSession()
    session.outputPortTypes = [.headphones]
    let detector = RouteDetector(session: session)

    XCTAssertEqual(detector.detect(), AudioRouteNames.external)
  }

  func testRouteDetectorReturnsUnknownForEmptyOutputs() {
    let session = FakeAudioSession()
    session.outputPortTypes = []
    let detector = RouteDetector(session: session)

    XCTAssertEqual(detector.detect(), AudioRouteNames.unknown)
  }

  func testRouteApplicatorReportsUnavailableWhenExternalDevicePresent() {
    let session = FakeAudioSession()
    session.outputPortTypes = [.headphones]
    let detector = RouteDetector(session: session)
    let coordinator = SessionCoordinator(session: session)
    let applicator = RouteApplicator(
      session: session,
      detector: detector,
      coordinator: coordinator
    )

    let result = try! applicator.apply(route: AudioRouteNames.earpiece)

    XCTAssertEqual(result.applied, AudioRouteNames.external)
    XCTAssertFalse(result.available)
  }
  #endif
}
