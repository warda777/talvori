import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/platform/shared_text_platform_receiver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('talvori/share');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getInitialSharedText_trims_shared_text', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getInitialSharedText');
          return '  Umbrella  ';
        });

    final receiver = SharedTextPlatformReceiver();

    expect(await receiver.getInitialSharedText(), 'Umbrella');
  });

  test('getInitialSharedText_returns_null_for_blank_text', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => '   ');

    final receiver = SharedTextPlatformReceiver();

    expect(await receiver.getInitialSharedText(), isNull);
  });
}
