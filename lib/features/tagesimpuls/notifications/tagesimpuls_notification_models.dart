import '../ai/tagesimpuls_ai_client.dart';
import 'tagesimpuls_notification_settings.dart';

class TagesimpulsNotificationIds {
  const TagesimpulsNotificationIds._();

  static const technicalTest = 900001;
  static const realTestStart = 910000;
  static const realTestEnd = 910099;
  static const realTest = 910011;
  static const regularStart = 920000;
  static const regularEnd = 920999;

  static bool isRegular(int id) => id >= regularStart && id <= regularEnd;

  static bool isRealTest(int id) => id >= realTestStart && id <= realTestEnd;
}

class TagesimpulsNotificationSchedule {
  const TagesimpulsNotificationSchedule({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.slot,
    required this.usedWords,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String slot;
  final List<String> usedWords;
  final String? payload;
}

enum TagesimpulsNotificationPlanningStatus {
  scheduledSuccessfully,
  realImpulseTestScheduled,
  realImpulseTestDeliveredUnknown,
  realImpulseScheduleFailed,
  scheduledButNoPendingNotification,
  notificationPendingMissing,
  notificationBodyEmpty,
  notificationPayloadInvalid,
  scheduledAtInPast,
  noPendingNotifications,
  expiredScheduleRecomputed,
  permissionGranted,
  permissionDenied,
  permissionNotRequested,
  notificationServiceNotInitialized,
  impulseGenerationFailed,
  noGeneratedImpulses,
  invalidScheduleTime,
  timezoneNotInitialized,
  schedulePlatformError,
}

enum TagesimpulsNotificationPermissionStatus { granted, denied, notRequested }

class TagesimpulsNotificationPlanningResult {
  const TagesimpulsNotificationPlanningResult({
    required this.status,
    this.scheduled = const [],
    this.debugMessage,
    this.pendingNotificationCount,
    this.permissionStatus,
  });

  final TagesimpulsNotificationPlanningStatus status;
  final List<TagesimpulsNotificationSchedule> scheduled;
  final String? debugMessage;
  final int? pendingNotificationCount;
  final TagesimpulsNotificationPermissionStatus? permissionStatus;

  bool get isPlanned =>
      status == TagesimpulsNotificationPlanningStatus.scheduledSuccessfully;
}

class TagesimpulsNotificationPlanOptions {
  TagesimpulsNotificationPlanOptions({
    required this.impulses,
    this.preferredWindow = TagesimpulsPreferredWindow.automatic,
    this.customHour,
    this.customMinute,
    this.chatId,
    this.messageIds = const [],
    DateTime? now,
  }) : now = now ?? DateTime.now();

  final List<TagesimpulsGeneratedImpulse> impulses;
  final TagesimpulsPreferredWindow preferredWindow;
  final int? customHour;
  final int? customMinute;
  final String? chatId;
  final List<String> messageIds;
  final DateTime now;
}
