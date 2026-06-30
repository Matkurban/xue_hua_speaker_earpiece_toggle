import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_speaker_earpiece_toggle/audio_output_route.dart';
import 'package:xue_hua_speaker_earpiece_toggle/route_result.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle_platform_interface.dart';
import 'package:xue_hua_speaker_earpiece_toggle_example/main.dart';

class WidgetTestPlatform extends XueHuaSpeakerEarpieceTogglePlatform {
  @override
  Future<AudioOutputRoute> getRoute() async => AudioOutputRoute.speaker;

  @override
  Future<RouteResult> setRoute(AudioOutputRoute route) async {
    return RouteResult(requested: route, applied: route, available: true);
  }

  @override
  Stream<AudioOutputRoute> get onRouteChanged =>
      Stream.value(AudioOutputRoute.speaker);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final XueHuaSpeakerEarpieceTogglePlatform initialPlatform =
      XueHuaSpeakerEarpieceTogglePlatform.instance;

  setUp(() {
    XueHuaSpeakerEarpieceTogglePlatform.instance = WidgetTestPlatform();
  });

  tearDown(() {
    XueHuaSpeakerEarpieceTogglePlatform.instance = initialPlatform;
  });

  testWidgets('shows the current route label', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Speaker / 扬声器'), findsOneWidget);
    expect(find.text('Current Route / 当前路由'), findsOneWidget);
  });
}
