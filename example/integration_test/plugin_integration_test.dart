import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<AudioOutputRoute> readRouteWithRetry(
    XueHuaSpeakerEarpieceToggle plugin, {
    AudioOutputRoute? expected,
    int attempts = 3,
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

  testWidgets('getRoute and setRoute integration test', (
    WidgetTester tester,
  ) async {
    final plugin = XueHuaSpeakerEarpieceToggle();

    final initialRoute = await plugin.getRoute();
    expect(AudioOutputRoute.values.contains(initialRoute), isTrue);

    if (initialRoute == AudioOutputRoute.external ||
        initialRoute == AudioOutputRoute.unknown) {
      return;
    }

    final targetRoute = initialRoute == AudioOutputRoute.speaker
        ? AudioOutputRoute.earpiece
        : AudioOutputRoute.speaker;

    final switchResult = await plugin.setRoute(targetRoute);
    expect(switchResult.requested, targetRoute);

    if (switchResult.applied == AudioOutputRoute.external) {
      return;
    }

    expect(
      await readRouteWithRetry(plugin, expected: switchResult.applied),
      switchResult.applied,
    );

    final restoreResult = await plugin.setRoute(initialRoute);
    if (restoreResult.applied == AudioOutputRoute.external) {
      return;
    }

    expect(
      await readRouteWithRetry(plugin, expected: restoreResult.applied),
      restoreResult.applied,
    );
  });
}
