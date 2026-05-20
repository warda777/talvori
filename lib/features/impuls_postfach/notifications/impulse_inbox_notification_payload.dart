import 'dart:convert';

class ImpulseInboxNotificationTarget {
  const ImpulseInboxNotificationTarget({
    this.chatId,
    this.messageId,
    this.parsedType,
    this.legacyPayload = false,
  });

  final String? chatId;
  final String? messageId;
  final String? parsedType;
  final bool legacyPayload;

  bool get opensChat => chatId != null && chatId!.trim().isNotEmpty;
}

class ImpulseInboxNotificationPayload {
  const ImpulseInboxNotificationPayload._();

  static const prefix = 'impuls-postfach';
  static const typeImpulseMessage = 'impulse_message';

  static String encodeImpulseMessage({
    required String chatId,
    required String messageId,
    String source = 'daily_impulse',
    int? notificationId,
  }) {
    return jsonEncode({
      'type': typeImpulseMessage,
      'chatId': chatId,
      'messageId': messageId,
      'source': source,
      if (notificationId != null) 'notificationId': notificationId,
    });
  }

  static ImpulseInboxNotificationTarget? parse(String? payload) {
    final value = payload?.trim();
    if (value == null || value.isEmpty) {
      return const ImpulseInboxNotificationTarget(parsedType: 'missing');
    }

    final jsonTarget = _parseJson(value);
    if (jsonTarget != null) return jsonTarget;

    final parts = value.split(':');
    if (parts.first != prefix) {
      return const ImpulseInboxNotificationTarget(parsedType: 'unknown');
    }
    if (parts.length < 2 || parts[1].trim().isEmpty) {
      return const ImpulseInboxNotificationTarget(
        parsedType: 'legacy_invalid',
        legacyPayload: true,
      );
    }

    return ImpulseInboxNotificationTarget(
      chatId: parts[1].trim(),
      messageId: parts.length > 2 && parts[2].trim().isNotEmpty
          ? parts[2].trim()
          : null,
      parsedType: typeImpulseMessage,
      legacyPayload: true,
    );
  }

  static ImpulseInboxNotificationTarget? _parseJson(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, Object?>) return null;
      if (decoded['type'] != typeImpulseMessage) {
        return ImpulseInboxNotificationTarget(
          parsedType: decoded['type']?.toString() ?? 'unknown_json',
        );
      }

      final chatId = decoded['chatId'];
      final messageId = decoded['messageId'];
      return ImpulseInboxNotificationTarget(
        chatId: chatId is String && chatId.trim().isNotEmpty
            ? chatId.trim()
            : null,
        messageId: messageId is String && messageId.trim().isNotEmpty
            ? messageId.trim()
            : null,
        parsedType: typeImpulseMessage,
      );
    } catch (_) {
      return null;
    }
  }
}
