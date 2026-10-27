import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<AudioOutputRoute> readRouteWithRetry(
    XueHuaSpeakerEarpieceToggle plugin, {
    AudioOutputRoute? expected,
    int attempts = 5,
    Duration delay = const Duration(milliseconds: 200),
  }) async {
    AudioOutputRoute? lastRoute;

    for (var attempt = 0; attempt < attempts; attempt++) {
      lastRoute = await plugin.getRoute();
      if (expected == null || lastRoute == expected) {
        return lastRoute;
      }
      await Future<void>.delayed(delay);
    }

    return lastRoute!;
  }

  testWidgets('switchable route helpers match public API', (
    WidgetTester tester,
  ) async {
    expect(
      switchableAudioOutputRoutes,
      unorderedEquals(<AudioOutputRoute>[
        AudioOutputRoute.speaker,
        AudioOutputRoute.earpiece,
      ]),
    );
    expect(isSwitchableAudioOutputRoute(AudioOutputRoute.speaker), isTrue);
    expect(isSwitchableAudioOutputRoute(AudioOutputRoute.earpiece), isTrue);
    expect(isSwitchableAudioOutputRoute(AudioOutputRoute.external), isFalse);
    expect(isSwitchableAudioOutputRoute(AudioOutputRoute.unknown), isFalse);
  });

  testWidgets('setRoute rejects non-switchable routes before native call', (
    WidgetTester tester,
  ) async {
    final plugin = XueHuaSpeakerEarpieceToggle();

    for (final route in const [
      AudioOutputRoute.external,
      AudioOutputRoute.unknown,
    ]) {
      await expectLater(
        plugin.setRoute(route),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'INVALID_ROUTE',
          ),
        ),
      );
    }
  });

  testWidgets('getRoute returns a known AudioOutputRoute', (
    WidgetTester tester,
  ) async {
    final plugin = XueHuaSpeakerEarpieceToggle();
    final route = await plugin.getRoute();
    expect(AudioOutputRoute.values, contains(route));
  });

  testWidgets('onRouteChanged emits current route on subscription', (
    WidgetTester tester,
  ) async {
    final plugin = XueHuaSpeakerEarpieceToggle();
    final route = await plugin.onRouteChanged.first.timeout(
      const Duration(seconds: 5),
    );
    expect(AudioOutputRoute.values, contains(route));
  });

  testWidgets('getRoute setRoute onRouteChanged restoreSession round-trip', (
    WidgetTester tester,
  ) async {
    final plugin = XueHuaSpeakerEarpieceToggle();

    final initialRoute = await plugin.getRoute();
    expect(AudioOutputRoute.values, contains(initialRoute));

    // restoreSession is always safe; no-op when plugin never changed session.
    await plugin.restoreSession();
    expect(
      AudioOutputRoute.values,
      contains(await plugin.getRoute()),
    );

    if (initialRoute == AudioOutputRoute.external ||
        initialRoute == AudioOutputRoute.unknown) {
      // Cannot request a switchable toggle from an unswitchable baseline.
      return;
    }

    final targetRoute = initialRoute == AudioOutputRoute.speaker
        ? AudioOutputRoute.earpiece
        : AudioOutputRoute.speaker;

    final routeEvents = <AudioOutputRoute>[];
    final sub = plugin.onRouteChanged.listen(routeEvents.add);
    addTearDown(() async {
      await sub.cancel();
      await plugin.restoreSession();
    });

    // Drain the immediate current-route event from onListen.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(routeEvents, isNotEmpty);
    routeEvents.clear();

    final switchResult = await plugin.setRoute(targetRoute);
    expect(switchResult.requested, targetRoute);
    expect(switchResult.available, switchResult.applied == targetRoute);
    expect(AudioOutputRoute.values, contains(switchResult.applied));

    if (switchResult.applied == AudioOutputRoute.external) {
      await plugin.restoreSession();
      return;
    }

    expect(
      await readRouteWithRetry(plugin, expected: switchResult.applied),
      switchResult.applied,
    );

    // setRoute should also push through the event channel.
    final sawApplied = await _waitUntil(
      () => routeEvents.contains(switchResult.applied),
      timeout: const Duration(seconds: 3),
    );
    expect(sawApplied, isTrue);

    final restoreRouteResult = await plugin.setRoute(initialRoute);
    if (restoreRouteResult.applied != AudioOutputRoute.external) {
      expect(
        await readRouteWithRetry(
          plugin,
          expected: restoreRouteResult.applied,
        ),
        restoreRouteResult.applied,
      );
    }

    await plugin.restoreSession();
    expect(
      AudioOutputRoute.values,
      contains(await plugin.getRoute()),
    );
  });
}

Future<bool> _waitUntil(
  bool Function() predicate, {
  required Duration timeout,
  Duration step = const Duration(milliseconds: 100),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (predicate()) {
      return true;
    }
    await Future<void>.delayed(step);
  }
  return predicate();
}
