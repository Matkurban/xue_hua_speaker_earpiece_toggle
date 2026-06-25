import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_speaker_earpiece_toggle/audio_output_route.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelXueHuaSpeakerEarpieceToggle();
  const channel = MethodChannel('xue_hua_speaker_earpiece_toggle');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getRoute':
              return 'speaker';
            case 'setRoute':
              expect(methodCall.arguments, {'route': 'earpiece'});
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getRoute parses the native route string', () async {
    expect(await platform.getRoute(), AudioOutputRoute.speaker);
  });

  test('setRoute sends the enum name to the native platform', () async {
    await platform.setRoute(AudioOutputRoute.earpiece);
  });
}
