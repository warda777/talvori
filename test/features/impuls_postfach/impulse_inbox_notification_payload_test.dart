import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_payload.dart';
import 'package:talvori/features/impuls_postfach/notifications/notification_tap_debug_state.dart';

void main() {
  setUp(NotificationTapDebugStore.reset);

  test('encodes and parses impulse inbox notification payload as JSON', () {
    final payload = ImpulseInboxNotificationPayload.encodeImpulseMessage(
      chatId: 'chat-1',
      messageId: 'message-1',
      notificationId: 910011,
    );

    expect(payload, contains('"type":"impulse_message"'));
    expect(payload, contains('"chatId":"chat-1"'));
    expect(payload, contains('"messageId":"message-1"'));

    final target = ImpulseInboxNotificationPayload.parse(payload);

    expect(target, isNotNull);
    expect(target!.chatId, 'chat-1');
    expect(target.messageId, 'message-1');
    expect(target.parsedType, 'impulse_message');
    expect(target.legacyPayload, isFalse);
    expect(target.opensChat, isTrue);
  });

  test('parses legacy impulse inbox notification payload', () {
    final target = ImpulseInboxNotificationPayload.parse(
      'impuls-postfach:chat-1:message-1',
    );

    expect(target, isNotNull);
    expect(target!.chatId, 'chat-1');
    expect(target.messageId, 'message-1');
    expect(target.parsedType, 'impulse_message');
    expect(target.legacyPayload, isTrue);
    expect(target.opensChat, isTrue);
  });

  test('malformed impulse inbox payload falls back to inbox', () {
    final target = ImpulseInboxNotificationPayload.parse(
      'impuls-postfach::message-1',
    );

    expect(target, isNotNull);
    expect(target!.opensChat, isFalse);
  });

  test('unknown payload falls back to inbox', () {
    final target = ImpulseInboxNotificationPayload.parse('tagesimpuls:morning');

    expect(target, isNotNull);
    expect(target!.opensChat, isFalse);
  });

  test('missing payload falls back to inbox', () {
    expect(ImpulseInboxNotificationPayload.parse(null)?.opensChat, isFalse);
  });

  test('debug state records launch details and payload response', () {
    final payload = ImpulseInboxNotificationPayload.encodeImpulseMessage(
      chatId: 'chat-1',
      messageId: 'message-1',
    );

    NotificationTapDebugStore.recordLaunchDetailsChecked(
      didNotificationLaunchApp: true,
      payloadLength: payload.length,
    );
    NotificationTapDebugStore.recordResponseReceived(
      source: 'launch_details',
      payload: payload,
    );

    final state = NotificationTapDebugStore.value.value;
    expect(state.didNotificationLaunchApp, isTrue);
    expect(state.hasTap, isTrue);
    expect(state.lastPayloadRaw, payload);
    expect(state.lastPayloadRawPreview, contains('impulse_message'));
  });
}
