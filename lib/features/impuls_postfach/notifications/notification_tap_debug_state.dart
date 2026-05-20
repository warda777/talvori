import 'package:flutter/foundation.dart';

class NotificationTapDebugState {
  const NotificationTapDebugState({
    this.lastTapReceivedAt,
    this.lastPayloadRaw,
    this.lastPayloadRawPreview,
    this.lastParsedType,
    this.lastChatId,
    this.lastMessageId,
    this.lastRouteTarget,
    this.lastRouteResult,
    this.lastError,
    this.launchDetailsCheckedAt,
    this.didNotificationLaunchApp,
  });

  final DateTime? lastTapReceivedAt;
  final String? lastPayloadRaw;
  final String? lastPayloadRawPreview;
  final String? lastParsedType;
  final String? lastChatId;
  final String? lastMessageId;
  final String? lastRouteTarget;
  final String? lastRouteResult;
  final String? lastError;
  final DateTime? launchDetailsCheckedAt;
  final bool? didNotificationLaunchApp;

  bool get hasTap => lastTapReceivedAt != null;
  bool get hasPayload => lastPayloadRaw != null && lastPayloadRaw!.isNotEmpty;

  NotificationTapDebugState copyWith({
    DateTime? lastTapReceivedAt,
    String? lastPayloadRaw,
    String? lastPayloadRawPreview,
    String? lastParsedType,
    String? lastChatId,
    String? lastMessageId,
    String? lastRouteTarget,
    String? lastRouteResult,
    String? lastError,
    bool clearLastError = false,
    DateTime? launchDetailsCheckedAt,
    bool? didNotificationLaunchApp,
  }) {
    return NotificationTapDebugState(
      lastTapReceivedAt: lastTapReceivedAt ?? this.lastTapReceivedAt,
      lastPayloadRaw: lastPayloadRaw ?? this.lastPayloadRaw,
      lastPayloadRawPreview:
          lastPayloadRawPreview ?? this.lastPayloadRawPreview,
      lastParsedType: lastParsedType ?? this.lastParsedType,
      lastChatId: lastChatId ?? this.lastChatId,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastRouteTarget: lastRouteTarget ?? this.lastRouteTarget,
      lastRouteResult: lastRouteResult ?? this.lastRouteResult,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      launchDetailsCheckedAt:
          launchDetailsCheckedAt ?? this.launchDetailsCheckedAt,
      didNotificationLaunchApp:
          didNotificationLaunchApp ?? this.didNotificationLaunchApp,
    );
  }
}

class NotificationTapDebugStore {
  NotificationTapDebugStore._();

  static final value = ValueNotifier<NotificationTapDebugState>(
    const NotificationTapDebugState(),
  );

  static void recordLaunchDetailsChecked({
    required bool didNotificationLaunchApp,
    int payloadLength = 0,
  }) {
    debugPrint(
      'notification launch details checked '
      'didNotificationLaunchApp=$didNotificationLaunchApp '
      'launchPayloadLength=$payloadLength',
    );
    value.value = value.value.copyWith(
      launchDetailsCheckedAt: DateTime.now(),
      didNotificationLaunchApp: didNotificationLaunchApp,
    );
  }

  static void recordResponseReceived({
    required String source,
    required String? payload,
  }) {
    final preview = previewPayload(payload);
    debugPrint(
      'notification response received $source '
      'payloadRawLength=${payload?.length ?? 0} '
      'payloadRawPreview=$preview',
    );
    value.value = value.value.copyWith(
      lastTapReceivedAt: DateTime.now(),
      lastPayloadRaw: payload,
      lastPayloadRawPreview: preview,
      lastRouteResult: 'received',
      clearLastError: true,
    );
  }

  static void recordParsed({
    required String parsedType,
    required String? chatId,
    required String? messageId,
  }) {
    value.value = value.value.copyWith(
      lastParsedType: parsedType,
      lastChatId: chatId,
      lastMessageId: messageId,
    );
  }

  static void recordRoute({
    required String routeTarget,
    required String routeResult,
    String? error,
  }) {
    value.value = value.value.copyWith(
      lastRouteTarget: routeTarget,
      lastRouteResult: routeResult,
      lastError: error,
      clearLastError: error == null,
    );
  }

  static void reset() {
    value.value = const NotificationTapDebugState();
  }

  static String previewPayload(String? payload) {
    final value = payload?.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (value == null || value.isEmpty) return 'empty';
    if (value.length <= 96) return value;
    return '${value.substring(0, 96)}...';
  }
}
