import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'tagesimpuls_notification_models.dart';

abstract interface class TagesimpulsNotificationScheduler {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<void> schedule(TagesimpulsNotificationSchedule notification);

  Future<void> cancelAll();
}

class FlutterLocalTagesimpulsNotificationScheduler
    implements TagesimpulsNotificationScheduler {
  FlutterLocalTagesimpulsNotificationScheduler({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;

    return androidGranted && iosGranted;
  }

  @override
  Future<void> schedule(TagesimpulsNotificationSchedule notification) async {
    await initialize();
    await _plugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      tz.TZDateTime.from(notification.scheduledAt, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'tagesimpuls',
          'Tagesimpuls',
          channelDescription: 'Kurze Tagesimpuls-Nachrichten zum Wiederholen.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}

class TagesimpulsNotificationService {
  TagesimpulsNotificationService({
    required TagesimpulsNotificationScheduler scheduler,
  }) : _scheduler = scheduler;

  final TagesimpulsNotificationScheduler _scheduler;

  Future<TagesimpulsNotificationPlanningResult> planNotifications(
    TagesimpulsNotificationPlanOptions options,
  ) async {
    final schedules = buildSchedules(options);
    if (schedules.isEmpty) {
      return const TagesimpulsNotificationPlanningResult(
        status: TagesimpulsNotificationPlanningStatus.empty,
      );
    }

    await _scheduler.initialize();
    final granted = await _scheduler.requestPermission();
    if (!granted) {
      return const TagesimpulsNotificationPlanningResult(
        status: TagesimpulsNotificationPlanningStatus.permissionDenied,
      );
    }

    for (final notification in schedules) {
      await _scheduler.schedule(notification);
    }

    return TagesimpulsNotificationPlanningResult(
      status: TagesimpulsNotificationPlanningStatus.planned,
      scheduled: schedules,
    );
  }

  List<TagesimpulsNotificationSchedule> buildSchedules(
    TagesimpulsNotificationPlanOptions options,
  ) {
    return options.impulses
        .take(5)
        .indexed
        .map((entry) {
          final (index, impulse) = entry;
          return TagesimpulsNotificationSchedule(
            id: _notificationIdFor(index, options.now),
            title: 'Tagesimpuls',
            body: impulse.message,
            scheduledAt: _nextSlotTime(impulse.slot, options.now, index),
            slot: impulse.slot,
            usedWords: impulse.usedWords,
          );
        })
        .toList(growable: false);
  }

  Future<void> clearScheduledNotifications() async {
    await _scheduler.cancelAll();
  }

  int _notificationIdFor(int index, DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    return day.millisecondsSinceEpoch ~/ 1000 + index;
  }

  DateTime _nextSlotTime(String slot, DateTime now, int index) {
    final lowerSlot = slot.trim().toLowerCase();
    final time = switch (lowerSlot) {
      'morning' => const (hour: 9, minute: 0),
      'noon' || 'midday' => const (hour: 12, minute: 30),
      'afternoon' => const (hour: 14, minute: 0),
      'evening' => const (hour: 18, minute: 30),
      _ => _fallbackTime(index),
    };

    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  ({int hour, int minute}) _fallbackTime(int index) {
    return switch (index) {
      0 => const (hour: 9, minute: 0),
      1 => const (hour: 12, minute: 30),
      2 => const (hour: 14, minute: 0),
      3 => const (hour: 18, minute: 30),
      _ => const (hour: 19, minute: 30),
    };
  }
}

final tagesimpulsNotificationSchedulerProvider =
    Provider<TagesimpulsNotificationScheduler>((ref) {
      return FlutterLocalTagesimpulsNotificationScheduler();
    });

final tagesimpulsNotificationServiceProvider =
    Provider<TagesimpulsNotificationService>((ref) {
      final scheduler = ref.watch(tagesimpulsNotificationSchedulerProvider);
      return TagesimpulsNotificationService(scheduler: scheduler);
    });
