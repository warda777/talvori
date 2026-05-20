import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_models.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_service.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_settings.dart';

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

      expect(
        result.status,
        TagesimpulsNotificationPlanningStatus.scheduledSuccessfully,
      );
      expect(scheduler.initializeCalls, 1);
      expect(scheduler.permissionRequestCalls, 1);
      expect(scheduler.scheduled, hasLength(1));
      expect(result.pendingNotificationCount, 1);
      expect(scheduler.scheduled.single.title, 'Talvori Tagesimpuls');
      expect(scheduler.scheduled.single.scheduledAt.hour, 9);
      expect(scheduler.scheduled.single.scheduledAt.minute, 0);
    });

    test('permission not requested returns dedicated status', () async {
      final scheduler = _FakeScheduler(
        permissionStatus: TagesimpulsNotificationPermissionStatus.notRequested,
      );
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
        TagesimpulsNotificationPlanningStatus.permissionNotRequested,
      );
      expect(scheduler.permissionRequestCalls, 1);
      expect(scheduler.scheduled, isEmpty);
    });

    test('empty impulses return no generated impulses status', () async {
      final scheduler = _FakeScheduler();
      final service = TagesimpulsNotificationService(scheduler: scheduler);

      final result = await service.planNotifications(
        TagesimpulsNotificationPlanOptions(impulses: const []),
      );

      expect(
        result.status,
        TagesimpulsNotificationPlanningStatus.noGeneratedImpulses,
      );
      expect(scheduler.initializeCalls, 0);
      expect(scheduler.permissionRequestCalls, 0);
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

    test('uses preferred manual time window', () {
      final service = TagesimpulsNotificationService(
        scheduler: _FakeScheduler(),
      );

      final schedules = service.buildSchedules(
        TagesimpulsNotificationPlanOptions(
          now: DateTime(2026, 5, 19, 8),
          preferredWindow: TagesimpulsPreferredWindow.afternoon,
          impulses: const [
            TagesimpulsGeneratedImpulse(
              slot: 'morning',
              message: 'First',
              usedWords: ['move'],
            ),
            TagesimpulsGeneratedImpulse(
              slot: 'evening',
              message: 'Second',
              usedWords: ['superstar'],
            ),
          ],
        ),
      );

      expect(schedules.map((schedule) => schedule.scheduledAt.hour), [14, 15]);
    });

    test('uses custom time today when still in the future', () {
      final service = TagesimpulsNotificationService(
        scheduler: _FakeScheduler(),
      );

      final schedules = service.buildSchedules(
        TagesimpulsNotificationPlanOptions(
          now: DateTime(2026, 5, 19, 11),
          preferredWindow: TagesimpulsPreferredWindow.custom,
          customHour: 12,
          customMinute: 7,
          impulses: const [
            TagesimpulsGeneratedImpulse(
              slot: 'morning',
              message: 'First',
              usedWords: ['move'],
            ),
          ],
        ),
      );

      expect(schedules.single.scheduledAt, DateTime(2026, 5, 19, 12, 7));
    });

    test('uses custom time tomorrow when today is already past', () {
      final service = TagesimpulsNotificationService(
        scheduler: _FakeScheduler(),
      );

      final schedules = service.buildSchedules(
        TagesimpulsNotificationPlanOptions(
          now: DateTime(2026, 5, 19, 13),
          preferredWindow: TagesimpulsPreferredWindow.custom,
          customHour: 12,
          customMinute: 7,
          impulses: const [
            TagesimpulsGeneratedImpulse(
              slot: 'morning',
              message: 'First',
              usedWords: ['move'],
            ),
          ],
        ),
      );

      expect(schedules.single.scheduledAt, DateTime(2026, 5, 20, 12, 7));
    });

    test('spreads multiple custom time impulses after the selected time', () {
      final service = TagesimpulsNotificationService(
        scheduler: _FakeScheduler(),
      );

      final schedules = service.buildSchedules(
        TagesimpulsNotificationPlanOptions(
          now: DateTime(2026, 5, 19, 11),
          preferredWindow: TagesimpulsPreferredWindow.custom,
          customHour: 12,
          customMinute: 7,
          impulses: const [
            TagesimpulsGeneratedImpulse(
              slot: 'morning',
              message: 'First',
              usedWords: ['move'],
            ),
            TagesimpulsGeneratedImpulse(
              slot: 'afternoon',
              message: 'Second',
              usedWords: ['superstar'],
            ),
            TagesimpulsGeneratedImpulse(
              slot: 'evening',
              message: 'Third',
              usedWords: ['destroyed'],
            ),
          ],
        ),
      );

      expect(schedules.map((schedule) => schedule.scheduledAt), [
        DateTime(2026, 5, 19, 12, 7),
        DateTime(2026, 5, 19, 15, 7),
        DateTime(2026, 5, 19, 18, 7),
      ]);
    });

    test('returns permission denied without scheduling', () async {
      final scheduler = _FakeScheduler(
        permissionStatus: TagesimpulsNotificationPermissionStatus.denied,
      );
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
      expect(scheduler.permissionRequestCalls, 1);
      expect(scheduler.scheduled, isEmpty);
    });

    test('returns not initialized when initialize fails', () async {
      final scheduler = _FakeScheduler(throwOnInitialize: true);
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
        TagesimpulsNotificationPlanningStatus.notificationServiceNotInitialized,
      );
      expect(result.debugMessage, contains('initialize failed'));
      expect(scheduler.permissionRequestCalls, 0);
    });

    test('returns platform error when scheduling fails', () async {
      final scheduler = _FakeScheduler(throwOnSchedule: true);
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
        TagesimpulsNotificationPlanningStatus.schedulePlatformError,
      );
    });

    test('timezone errors return timezone not initialized', () async {
      final scheduler = _FakeScheduler(throwTimezoneOnSchedule: true);
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
        TagesimpulsNotificationPlanningStatus.timezoneNotInitialized,
      );
    });

    test('test notification schedules without impulses or AI', () async {
      final scheduler = _FakeScheduler();
      final service = TagesimpulsNotificationService(scheduler: scheduler);

      final result = await service.scheduleTestNotificationInTenSeconds(
        now: DateTime(2026, 5, 19, 8),
      );

      expect(
        result.status,
        TagesimpulsNotificationPlanningStatus.scheduledSuccessfully,
      );
      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.scheduled.single.title, 'Talvori Test');
      expect(
        scheduler.scheduled.single.body,
        'Benachrichtigungen funktionieren.',
      );
      expect(
        scheduler.scheduled.single.scheduledAt,
        DateTime(2026, 5, 19, 8, 0, 10),
      );
    });

    test(
      'returns dedicated status when no pending notification is registered',
      () async {
        final scheduler = _FakeScheduler(pendingIdsOverride: const []);
        final service = TagesimpulsNotificationService(scheduler: scheduler);

        final result = await service.planNotifications(
          TagesimpulsNotificationPlanOptions(
            now: DateTime(2026, 5, 19, 8),
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
          TagesimpulsNotificationPlanningStatus
              .scheduledButNoPendingNotification,
        );
        expect(result.pendingNotificationCount, 0);
        expect(scheduler.scheduled, hasLength(1));
      },
    );

    test('inspects pending notifications', () async {
      final scheduler = _FakeScheduler();
      final service = TagesimpulsNotificationService(scheduler: scheduler);

      var result = await service.inspectPendingNotifications();

      expect(
        result.status,
        TagesimpulsNotificationPlanningStatus.noPendingNotifications,
      );
      expect(result.pendingNotificationCount, 0);

      scheduler.scheduled.add(
        TagesimpulsNotificationSchedule(
          id: 42,
          title: 'Tagesimpuls',
          body: 'Message',
          scheduledAt: DateTime(2026, 5, 19, 9),
          slot: 'morning',
          usedWords: const ['move'],
        ),
      );

      result = await service.inspectPendingNotifications();

      expect(
        result.status,
        TagesimpulsNotificationPlanningStatus.scheduledSuccessfully,
      );
      expect(result.pendingNotificationCount, 1);
    });

    test(
      'test notification returns permission denied without scheduling',
      () async {
        final scheduler = _FakeScheduler(
          permissionStatus: TagesimpulsNotificationPermissionStatus.denied,
        );
        final service = TagesimpulsNotificationService(scheduler: scheduler);

        final result = await service.scheduleTestNotificationInTenSeconds(
          now: DateTime(2026, 5, 19, 8),
        );

        expect(
          result.status,
          TagesimpulsNotificationPlanningStatus.permissionDenied,
        );
        expect(scheduler.scheduled, isEmpty);
      },
    );

    test('clears scheduled notifications', () async {
      final scheduler = _FakeScheduler();
      final service = TagesimpulsNotificationService(scheduler: scheduler);
      scheduler.scheduled.add(
        TagesimpulsNotificationSchedule(
          id: 1,
          title: 'Tagesimpuls',
          body: 'Message',
          scheduledAt: DateTime(2026, 5, 19, 9),
          slot: 'morning',
          usedWords: const ['move'],
        ),
      );

      await service.clearScheduledNotifications();

      expect(scheduler.cancelCalls, 1);
      expect(scheduler.scheduled, isEmpty);
    });
  });
}

class _FakeScheduler implements TagesimpulsNotificationScheduler {
  _FakeScheduler({
    this.permissionStatus = TagesimpulsNotificationPermissionStatus.granted,
    this.throwOnInitialize = false,
    this.throwOnSchedule = false,
    this.throwTimezoneOnSchedule = false,
    this.pendingIdsOverride,
  });

  final TagesimpulsNotificationPermissionStatus permissionStatus;
  final bool throwOnInitialize;
  final bool throwOnSchedule;
  final bool throwTimezoneOnSchedule;
  final List<int>? pendingIdsOverride;
  final scheduled = <TagesimpulsNotificationSchedule>[];
  int initializeCalls = 0;
  int permissionRequestCalls = 0;
  int cancelCalls = 0;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    if (throwOnInitialize) throw StateError('initialize failed');
  }

  @override
  Future<TagesimpulsNotificationPermissionStatus> requestPermission() async {
    permissionRequestCalls++;
    return permissionStatus;
  }

  @override
  Future<void> schedule(TagesimpulsNotificationSchedule notification) async {
    if (throwOnSchedule) throw StateError('schedule failed');
    if (throwTimezoneOnSchedule) throw StateError('timezone not initialized');
    scheduled.add(notification);
  }

  @override
  Future<int> pendingNotificationCount() async => scheduled.length;

  @override
  Future<List<int>> pendingNotificationIds() async {
    return pendingIdsOverride ??
        scheduled.map((notification) => notification.id).toList();
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
    scheduled.clear();
  }
}
