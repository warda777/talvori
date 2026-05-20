import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_payload.dart';
import 'package:talvori/features/impuls_postfach/notifications/notification_tap_debug_state.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impulse_chat_detail_screen.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';

class ImpulseInboxNotificationRouter {
  ImpulseInboxNotificationRouter._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static ImpulseInboxNotificationTarget? _pendingTarget;
  static bool _appReady = false;
  static bool _flushScheduled = false;

  static void handlePayload(String? payload) {
    NotificationTapDebugStore.recordResponseReceived(
      source: 'router',
      payload: payload,
    );
    final target = ImpulseInboxNotificationPayload.parse(payload);
    final parsedType = target?.parsedType ?? 'unknown';
    NotificationTapDebugStore.recordParsed(
      parsedType: parsedType,
      chatId: target?.chatId,
      messageId: target?.messageId,
    );
    debugPrint(
      'notification response received '
      'payloadRawLength=${payload?.length ?? 0} '
      'payloadRawPreview=${NotificationTapDebugStore.previewPayload(payload)} '
      'parsedType=$parsedType '
      'legacyPayload=${target?.legacyPayload ?? false} '
      'parsedChatId=${target?.chatId?.isNotEmpty == true} '
      'parsedMessageId=${target?.messageId?.isNotEmpty == true}',
    );
    _queue(target ?? const ImpulseInboxNotificationTarget());
  }

  static void markReady() {
    if (_appReady) return;
    _appReady = true;
    debugPrint('ImpulseInboxNotificationRouter app ready');
    flushPending();
  }

  static void simulateImpulseMessage({
    String chatId = 'impulse-chat-daily-impulse',
    String? messageId,
  }) {
    handlePayload(
      ImpulseInboxNotificationPayload.encodeImpulseMessage(
        chatId: chatId,
        messageId: messageId ?? '',
      ),
    );
  }

  static void flushPending() {
    if (!_appReady) {
      debugPrint(
        'ImpulseInboxNotificationRouter flush skipped reason=app_not_ready',
      );
      NotificationTapDebugStore.recordRoute(
        routeTarget: _pendingTarget?.opensChat == true
            ? 'chat_detail'
            : 'inbox',
        routeResult: 'queued_app_not_ready',
      );
      return;
    }
    final target = _pendingTarget;
    if (target == null) return;
    _pendingTarget = null;
    _open(target);
  }

  @visibleForTesting
  static void resetForTests() {
    _pendingTarget = null;
    _appReady = false;
    _flushScheduled = false;
  }

  static void _queue(ImpulseInboxNotificationTarget target) {
    if (_appReady && navigatorKey.currentState != null) {
      _open(target);
      return;
    }

    _pendingTarget = target;
    NotificationTapDebugStore.recordRoute(
      routeTarget: target.opensChat ? 'chat_detail' : 'inbox',
      routeResult: 'queued',
    );
    debugPrint(
      'ImpulseInboxNotificationRouter queued notification route '
      'routeTarget=${target.opensChat ? 'chat_detail' : 'inbox'} '
      'appReady=$_appReady',
    );
    _scheduleFlush();
  }

  static void _scheduleFlush() {
    if (_flushScheduled) return;
    _flushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;
      flushPending();
    });
  }

  static void _open(ImpulseInboxNotificationTarget target) {
    final navigator = navigatorKey.currentState;
    if (!_appReady || navigator == null) {
      _pendingTarget = target;
      debugPrint(
        'ImpulseInboxNotificationRouter route deferred '
        'reason=${_appReady ? 'navigator_not_ready' : 'app_not_ready'}',
      );
      NotificationTapDebugStore.recordRoute(
        routeTarget: target.opensChat ? 'chat_detail' : 'inbox',
        routeResult: 'deferred',
        error: _appReady ? 'navigator_not_ready' : 'app_not_ready',
      );
      _scheduleFlush();
      return;
    }

    final routeTarget = target.opensChat ? 'chat_detail' : 'inbox';
    NotificationTapDebugStore.recordRoute(
      routeTarget: routeTarget,
      routeResult: 'pushing',
    );
    debugPrint(
      'ImpulseInboxNotificationRouter routeTarget=$routeTarget '
      'chatId=${target.chatId?.isNotEmpty == true} '
      'messageId=${target.messageId?.isNotEmpty == true}',
    );
    final inboxRoute = MaterialPageRoute(
      settings: const RouteSettings(name: 'impulse_notification_inbox'),
      builder: (_) => const ImpulsPostfachScreen(),
    );
    navigator.pushAndRemoveUntil(inboxRoute, (route) => route.isFirst);
    if (target.opensChat) {
      final detailRoute = MaterialPageRoute(
        settings: const RouteSettings(name: 'impulse_notification_chat_detail'),
        builder: (_) => _ImpulseNotificationTargetScreen(target: target),
      );
      navigator.push(detailRoute);
    }
    NotificationTapDebugStore.recordRoute(
      routeTarget: routeTarget,
      routeResult: target.opensChat
          ? 'success_stack_home_inbox_chat_detail'
          : 'success_stack_home_inbox',
    );
    debugPrint(
      'ImpulseInboxNotificationRouter routeSuccess=$routeTarget '
      'navigationMethod=root_stack_inbox_then_detail '
      'stackBuilt=${target.opensChat ? 'home>inbox>chat_detail' : 'home>inbox'} '
      'backTarget=${target.opensChat ? 'inbox' : 'home'} '
      'navigatorReady=${navigatorKey.currentState != null}',
    );
  }
}

class ImpulseNotificationTargetScreen extends ConsumerWidget {
  const ImpulseNotificationTargetScreen({super.key, required this.target});

  final ImpulseInboxNotificationTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!target.opensChat) {
      return const ImpulsPostfachScreen();
    }

    final state = ref.watch(impulseInboxControllerProvider);
    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050A12),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final chatExists = state.chats.any((chat) => chat.id == target.chatId);
    if (!chatExists) {
      debugPrint(
        'ImpulseInboxNotificationRouter fallback=inbox reason=chat_not_found',
      );
      NotificationTapDebugStore.recordRoute(
        routeTarget: 'inbox',
        routeResult: 'fallback_chat_not_found',
        error: 'chat_not_found',
      );
      return const ImpulsPostfachScreen();
    }

    return ImpulseChatDetailScreen(
      chatId: target.chatId!,
      initialMessageId: target.messageId,
    );
  }
}

class _ImpulseNotificationTargetScreen extends ImpulseNotificationTargetScreen {
  const _ImpulseNotificationTargetScreen({required super.target});
}
