import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_models.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_service.dart';

void main() {
  group('TagesimpulsNotificationService', () {
    test('plans one impulse', () async {
      final scheduler = _FakeScheduler();
      final service = TagesimpulsNotificationService(scheduler: scheduler);

      final result = await service.planNotifications(
        TagesimpulsNotificationPlanOptions(
          now: DateTime(2026, 5, 19, 8),
          impulses: const [
            TagesimpulsGeneratedImpulse(
              slot: 'morning',
              message: 'Good morning!',
              usedWords: ['morning'],
            ),
          ],
        ),
      );

      expect(result.status, TagesimpulsNotificationPlanningStatus.planned);
      expect(scheduler.initializeCalls, 1);
      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.scheduled.single.scheduledAt.hour, 9);
      expect(scheduler.scheduled.single.scheduledAt.minute, 0);
    });

    test('plans multiple impulses with slot fallback times', () async {
      final scheduler = _FakeScheduler();
      final service = TagesimpulsNotificationService(scheduler: scheduler);

      await service.planNotifications(
        TagesimpulsNotificationPlanOptions(
          now: DateTime(2026, 5, 19, 8),
          impulses: const [
            TagesimpulsGeneratedImpulse(
              slot: 'morning',
              message: 'Morning',
              usedWords: ['move'],
            ),
            TagesimpulsGeneratedImpulse(
              slot: 'afternoon',
              message: 'Afternoon',
              usedWords: ['superstar'],
            ),
            TagesimpulsGeneratedImpulse(
              slot: 'evening',
              message: 'Evening',
              usedWords: ['destroyed'],
            ),
          ],
        ),
      );

      expect(
        scheduler.scheduled.map(
          (notification) => notification.scheduledAt.hour,
        ),
        [9, 14, 18],
      );
      expect(scheduler.scheduled.last.scheduledAt.minute, 30);
    });

    test(
      'moves past slots to the next day and avoids night defaults',
      () async {
        final service = TagesimpulsNotificationService(
          scheduler: _FakeScheduler(),
        );

        final schedules = service.buildSchedules(
          TagesimpulsNotificationPlanOptions(
            now: DateTime(2026, 5, 19, 20),
            impulses: const [
              TagesimpulsGeneratedImpulse(
                slot: 'unknown',
                message: 'Fallback',
                usedWords: ['word'],
              ),
            ],
          ),
        );

        expect(schedules.single.scheduledAt.day, 20);
        expect(schedules.single.scheduledAt.hour, 9);
      },
    );

    test('returns permission denied without scheduling', () async {
      final scheduler = _FakeScheduler(permissionGranted: false);
      final service = TagesimpulsNotificationService(scheduler: scheduler);

      final result = await service.planNotifications(
        TagesimpulsNotificationPlanOptions(
          impulses: const [
            TagesimpulsGeneratedImpulse(
              slot: 'morning',
              message: 'Morning',
              usedWords: ['move'],
            ),
          ],
        ),
      );

      expect(
        result.status,
        TagesimpulsNotificationPlanningStatus.permissionDenied,
      );
      expect(scheduler.scheduled, isEmpty);
    });
  });
}

class _FakeScheduler implements TagesimpulsNotificationScheduler {
  _FakeScheduler({this.permissionGranted = true});

  final bool permissionGranted;
  final scheduled = <TagesimpulsNotificationSchedule>[];
  int initializeCalls = 0;

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<bool> requestPermission() async {
    return permissionGranted;
  }

  @override
  Future<void> schedule(TagesimpulsNotificationSchedule notification) async {
    scheduled.add(notification);
  }

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
  }
}
