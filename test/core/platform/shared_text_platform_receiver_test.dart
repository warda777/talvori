import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/platform/shared_text_platform_receiver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('talvori/share');
  const eventChannelName = 'talvori/share/events';
  const eventCodec = StandardMethodCodec();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(eventChannelName, null);
    debugDefaultTargetPlatformOverride = null;
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

  test('getInitialSharedPayload_reads_ios_payload', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getInitialSharedText');
          return {
            'id': 'share-1',
            'text': '  Umbrella  ',
            'createdAt': 1779184800.0,
            'source': 'ios_share_extension',
            'type': 'text',
          };
        });

    final receiver = SharedTextPlatformReceiver();

    final payload = await receiver.getInitialSharedPayload();
    expect(payload?.id, 'share-1');
    expect(payload?.text, 'Umbrella');
    expect(payload?.source, 'ios_share_extension');
    expect(payload?.type, 'text');
  });

  test('getInitialSharedText_returns_null_for_blank_text', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => '   ');

    final receiver = SharedTextPlatformReceiver();

    expect(await receiver.getInitialSharedText(), isNull);
  });

  test('watchSharedText_is_empty_on_unsupported_platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    final receiver = SharedTextPlatformReceiver();

    await expectLater(receiver.watchSharedText(), emitsDone);
  });

  test('watchSharedText_receives_trimmed_ios_event', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(eventChannelName, (message) async {
      final call = eventCodec.decodeMethodCall(message);
      if (call.method == 'listen' || call.method == 'cancel') {
        return eventCodec.encodeSuccessEnvelope(null);
      }
      fail('Unexpected event channel method: ${call.method}');
    });

    final receiver = SharedTextPlatformReceiver();
    final expectation = expectLater(
      receiver.watchSharedText().take(1),
      emits('Bonjour'),
    );
    await testerIdle();

    await messenger.handlePlatformMessage(
      eventChannelName,
      eventCodec.encodeSuccessEnvelope('  Bonjour  '),
      (_) {},
    );
    await expectation;
  });

  test('watchSharedPayload_processes_same_text_with_new_share_id', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(eventChannelName, (message) async {
      final call = eventCodec.decodeMethodCall(message);
      if (call.method == 'listen' || call.method == 'cancel') {
        return eventCodec.encodeSuccessEnvelope(null);
      }
      fail('Unexpected event channel method: ${call.method}');
    });

    final receiver = SharedTextPlatformReceiver();
    final payloadsFuture = receiver.watchSharedPayload().take(2).toList();
    await testerIdle();

    for (final id in ['share-1', 'share-2']) {
      await messenger.handlePlatformMessage(
        eventChannelName,
        eventCodec.encodeSuccessEnvelope({
          'id': id,
          'text': 'Bonjour',
          'source': 'ios_share_extension',
          'type': 'text',
        }),
        (_) {},
      );
    }
    final payloads = await payloadsFuture;

    expect(payloads.map((payload) => payload.id), ['share-1', 'share-2']);
    expect(payloads.map((payload) => payload.text), ['Bonjour', 'Bonjour']);
  });

  test('watchSharedPayload_pulls_pending_payload_on_resume', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    var pendingReadCount = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getInitialSharedText');
      pendingReadCount += 1;
      if (pendingReadCount == 1) return null;
      return {
        'id': 'resume-share-1',
        'text': '  Resume text  ',
        'source': 'ios_share_extension',
        'type': 'text',
      };
    });
    messenger.setMockMessageHandler(eventChannelName, (message) async {
      final call = eventCodec.decodeMethodCall(message);
      if (call.method == 'listen' || call.method == 'cancel') {
        return eventCodec.encodeSuccessEnvelope(null);
      }
      fail('Unexpected event channel method: ${call.method}');
    });

    final receiver = SharedTextPlatformReceiver();
    final payloads = <SharedTextPayload>[];
    final payloadReceived = Completer<void>();
    final subscription = receiver.watchSharedPayload().listen((payload) {
      payloads.add(payload);
      if (!payloadReceived.isCompleted) {
        payloadReceived.complete();
      }
    });
    await testerIdle();

    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );

    await payloadReceived.future;
    await subscription.cancel();
    expect(payloads.single.id, 'resume-share-1');
    expect(payloads.single.text, 'Resume text');
  });

  test('watchSharedPayload_ignores_duplicate_share_id', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(eventChannelName, (message) async {
      final call = eventCodec.decodeMethodCall(message);
      if (call.method == 'listen' || call.method == 'cancel') {
        return eventCodec.encodeSuccessEnvelope(null);
      }
      fail('Unexpected event channel method: ${call.method}');
    });

    final receiver = SharedTextPlatformReceiver();
    final payloads = <SharedTextPayload>[];
    final subscription = receiver.watchSharedPayload().listen(payloads.add);
    await testerIdle();

    for (var i = 0; i < 2; i += 1) {
      await messenger.handlePlatformMessage(
        eventChannelName,
        eventCodec.encodeSuccessEnvelope({
          'id': 'duplicate-share',
          'text': i == 0 ? 'First' : 'Second',
          'source': 'ios_share_extension',
          'type': 'text',
        }),
        (_) {},
      );
    }
    await testerIdle();
    await subscription.cancel();

    expect(payloads, hasLength(1));
    expect(payloads.single.id, 'duplicate-share');
    expect(payloads.single.text, 'First');
  });
}

Future<void> testerIdle() async {
  await Future<void>.delayed(Duration.zero);
}
