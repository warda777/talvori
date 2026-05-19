import '../ai/tagesimpuls_ai_client.dart';

class TagesimpulsNotificationSchedule {
  const TagesimpulsNotificationSchedule({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.slot,
    required this.usedWords,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String slot;
  final List<String> usedWords;
}

enum TagesimpulsNotificationPlanningStatus { planned, permissionDenied, empty }

class TagesimpulsNotificationPlanningResult {
  const TagesimpulsNotificationPlanningResult({
    required this.status,
    this.scheduled = const [],
  });

  final TagesimpulsNotificationPlanningStatus status;
  final List<TagesimpulsNotificationSchedule> scheduled;

  bool get isPlanned => status == TagesimpulsNotificationPlanningStatus.planned;
}

class TagesimpulsNotificationPlanOptions {
  TagesimpulsNotificationPlanOptions({required this.impulses, DateTime? now})
    : now = now ?? DateTime.now();

  final List<TagesimpulsGeneratedImpulse> impulses;
  final DateTime now;
}
