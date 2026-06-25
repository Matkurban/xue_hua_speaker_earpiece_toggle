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
      XCTAssertTrue(route == "speaker" || route == "earpiece")
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
}
