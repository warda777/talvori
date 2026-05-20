import '../ai/tagesimpuls_ai_client.dart';
import 'tagesimpuls_notification_settings.dart';

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
  scheduledButNoPendingNotification,
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
    DateTime? now,
  }) : now = now ?? DateTime.now();

  final List<TagesimpulsGeneratedImpulse> impulses;
  final TagesimpulsPreferredWindow preferredWindow;
  final int? customHour;
  final int? customMinute;
  final DateTime now;
}
