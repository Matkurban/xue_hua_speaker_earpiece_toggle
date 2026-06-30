import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_speaker_earpiece_toggle/audio_output_route.dart';
import 'package:xue_hua_speaker_earpiece_toggle/route_result.dart';
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
              return {'applied': 'earpiece', 'available': true};
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

  test('setRoute sends the enum name and parses RouteResult', () async {
    final result = await platform.setRoute(AudioOutputRoute.earpiece);

    expect(
      result,
      const RouteResult(
        requested: AudioOutputRoute.earpiece,
        applied: AudioOutputRoute.earpiece,
        available: true,
      ),
    );
  });

  test('parseRoute throws for null route', () {
    expect(
      () => platform.parseRoute(null),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'INVALID_ROUTE',
        ),
      ),
    );
  });

  test('parseRoute throws for unknown route', () {
    expect(
      () => platform.parseRoute('bluetooth'),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'INVALID_ROUTE',
        ),
      ),
    );
  });

  test('parseRoute supports external and unknown routes', () {
    expect(platform.parseRoute('external'), AudioOutputRoute.external);
    expect(platform.parseRoute('unknown'), AudioOutputRoute.unknown);
  });

  test(
    'setRoute rejects non-switchable routes before invoking channel',
    () async {
      await expectLater(
        platform.setRoute(AudioOutputRoute.external),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'INVALID_ROUTE',
          ),
        ),
      );
    },
  );

  test('getRoute throws when native returns invalid type', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return 42;
        });

    await expectLater(
      platform.getRoute(),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'INVALID_ROUTE',
        ),
      ),
    );
  });

  test('parseRouteResult throws when applied route is missing', () {
    expect(
      () => platform.parseRouteResult(AudioOutputRoute.speaker, {
        'available': true,
      }),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'INVALID_ROUTE_RESULT',
        ),
      ),
    );
  });
}
