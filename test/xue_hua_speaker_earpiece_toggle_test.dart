import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle_method_channel.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle_platform_interface.dart';

/// Mock platform used to verify the public plugin API.
/// 用于验证公开插件 API 的 Mock 平台。
class MockXueHuaSpeakerEarpieceTogglePlatform
    with MockPlatformInterfaceMixin
    implements XueHuaSpeakerEarpieceTogglePlatform {
  AudioOutputRoute routeToReturn = AudioOutputRoute.speaker;
  RouteResult? routeResultToReturn;
  AudioOutputRoute? lastSetRoute;
  final StreamController<AudioOutputRoute> routeChangeController =
      StreamController<AudioOutputRoute>.broadcast();

  @override
  Future<AudioOutputRoute> getRoute() => Future.value(routeToReturn);

  @override
  Stream<AudioOutputRoute> get onRouteChanged => routeChangeController.stream;

  @override
  Future<RouteResult> setRoute(AudioOutputRoute route) async {
    lastSetRoute = route;
    return routeResultToReturn ??
        RouteResult(requested: route, applied: route, available: true);
  }
}

void main() {
  final XueHuaSpeakerEarpieceTogglePlatform initialPlatform =
      XueHuaSpeakerEarpieceTogglePlatform.instance;

  tearDown(() {
    XueHuaSpeakerEarpieceTogglePlatform.instance = initialPlatform;
  });

  test('onRouteChanged forwards platform route events', () async {
    final plugin = XueHuaSpeakerEarpieceToggle();
    final fakePlatform = MockXueHuaSpeakerEarpieceTogglePlatform();
    XueHuaSpeakerEarpieceTogglePlatform.instance = fakePlatform;

    final pendingRoute = plugin.onRouteChanged.first;
    fakePlatform.routeChangeController.add(AudioOutputRoute.external);

    expect(await pendingRoute, AudioOutputRoute.external);
  });

  test('$MethodChannelXueHuaSpeakerEarpieceToggle is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelXueHuaSpeakerEarpieceToggle>(),
    );
  });

  test('getRoute returns the platform route', () async {
    final plugin = XueHuaSpeakerEarpieceToggle();
    final fakePlatform = MockXueHuaSpeakerEarpieceTogglePlatform()
      ..routeToReturn = AudioOutputRoute.earpiece;
    XueHuaSpeakerEarpieceTogglePlatform.instance = fakePlatform;

    expect(await plugin.getRoute(), AudioOutputRoute.earpiece);
  });

  test('setRoute forwards the selected route to the platform', () async {
    final plugin = XueHuaSpeakerEarpieceToggle();
    final fakePlatform = MockXueHuaSpeakerEarpieceTogglePlatform();
    XueHuaSpeakerEarpieceTogglePlatform.instance = fakePlatform;

    final result = await plugin.setRoute(AudioOutputRoute.speaker);

    expect(fakePlatform.lastSetRoute, AudioOutputRoute.speaker);
    expect(result.requested, AudioOutputRoute.speaker);
    expect(result.applied, AudioOutputRoute.speaker);
    expect(result.available, isTrue);
  });

  test('setRoute returns applied route from platform', () async {
    final plugin = XueHuaSpeakerEarpieceToggle();
    final fakePlatform = MockXueHuaSpeakerEarpieceTogglePlatform()
      ..routeResultToReturn = const RouteResult(
        requested: AudioOutputRoute.earpiece,
        applied: AudioOutputRoute.external,
        available: false,
      );
    XueHuaSpeakerEarpieceTogglePlatform.instance = fakePlatform;

    final result = await plugin.setRoute(AudioOutputRoute.earpiece);

    expect(result.applied, AudioOutputRoute.external);
    expect(result.available, isFalse);
  });
}
