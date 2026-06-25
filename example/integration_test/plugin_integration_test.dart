import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Verifies the plugin can read and switch routes on a real device or emulator.
  // 在真机或模拟器上验证插件可以读取并切换路由。
  testWidgets('getRoute and setRoute integration test', (
    WidgetTester tester,
  ) async {
    final plugin = XueHuaSpeakerEarpieceToggle();

    final initialRoute = await plugin.getRoute();
    expect(AudioOutputRoute.values.contains(initialRoute), isTrue);

    final targetRoute = initialRoute == AudioOutputRoute.speaker
        ? AudioOutputRoute.earpiece
        : AudioOutputRoute.speaker;

    await plugin.setRoute(targetRoute);
    expect(await plugin.getRoute(), targetRoute);

    await plugin.setRoute(initialRoute);
    expect(await plugin.getRoute(), initialRoute);
  });
}
