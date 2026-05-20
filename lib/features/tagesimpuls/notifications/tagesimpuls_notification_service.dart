import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_payload.dart';
import 'package:talvori/features/impuls_postfach/notifications/notification_tap_debug_state.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../ai/tagesimpuls_ai_client.dart';
import 'tagesimpuls_notification_models.dart';
import 'tagesimpuls_notification_settings.dart';

abstract interface class TagesimpulsNotificationScheduler {
  Future<void> initialize();

  Future<TagesimpulsNotificationPermissionStatus> requestPermission();

  Future<void> schedule(TagesimpulsNotificationSchedule notification);

  Future<int> pendingNotificationCount();

  Future<List<int>> pendingNotificationIds();

  Future<void> cancel(int id);

  Future<void> cancelAll();
}

class FlutterLocalTagesimpulsNotificationScheduler
    implements TagesimpulsNotificationScheduler {
  factory FlutterLocalTagesimpulsNotificationScheduler({
    FlutterLocalNotificationsPlugin? plugin,
  }) {
    if (plugin != null) {
      return FlutterLocalTagesimpulsNotificationScheduler._(plugin);
    }
    return _shared;
  }

  FlutterLocalTagesimpulsNotificationScheduler._(this._plugin);

  static final _shared = FlutterLocalTagesimpulsNotificationScheduler._(
    FlutterLocalNotificationsPlugin(),
  );

  static ValueChanged<String?>? _payloadHandler;
  static String? _handledLaunchPayload;
  static String? _pendingPayloadForHandler;

  static void configurePayloadHandler(ValueChanged<String?> handler) {
    _payloadHandler = handler;
    final pending = _pendingPayloadForHandler;
    if (pending == null) return;
    _pendingPayloadForHandler = null;
    debugPrint(
      'FlutterLocalTagesimpulsNotificationScheduler flush pending payload '
      'payloadRawLength=${pending.length}',
    );
    handler(pending);
  }

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _timezoneInitialized = false;
  Future<void>? _initializeFuture;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    final existing = _initializeFuture;
    if (existing != null) return existing;
    _initializeFuture = _initialize().catchError((Object error) {
      _initializeFuture = null;
      throw error;
    });
    return _initializeFuture;
  }

  Future<void> _initialize() async {
    _initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        NotificationTapDebugStore.recordResponseReceived(
          source: 'foreground/background',
          payload: response.payload,
        );
        debugPrint(
          'notification response received '
          'foreground/background '
          'payloadRawLength=${response.payload?.length ?? 0}',
        );
        _dispatchPayload(response.payload);
      },
    );
    await _dispatchLaunchPayloadIfNeeded();
    _initialized = true;
  }

  void _initializeTimeZones() {
    if (_timezoneInitialized) return;
    tz.initializeTimeZones();
    _timezoneInitialized = true;
  }

  @override
  Future<TagesimpulsNotificationPermissionStatus> requestPermission() async {
    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted == false) {
      return TagesimpulsNotificationPermissionStatus.denied;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final iosGranted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return iosGranted == true
          ? TagesimpulsNotificationPermissionStatus.granted
          : TagesimpulsNotificationPermissionStatus.denied;
    }

    if (androidGranted == true) {
      return TagesimpulsNotificationPermissionStatus.granted;
    }

    return TagesimpulsNotificationPermissionStatus.notRequested;
  }

  @override
  Future<void> schedule(TagesimpulsNotificationSchedule notification) async {
    await initialize();
    if (!_timezoneInitialized) {
      throw StateError('timezone not initialized');
    }
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
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: notification.payload,
    );
  }

  @override
  Future<int> pendingNotificationCount() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }

  @override
  Future<List<int>> pendingNotificationIds() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((request) => request.id).toList(growable: false);
  }

  @override
  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  Future<void> _dispatchLaunchPayloadIfNeeded() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final didLaunch = details?.didNotificationLaunchApp == true;
    final payload = details?.notificationResponse?.payload;
    NotificationTapDebugStore.recordLaunchDetailsChecked(
      didNotificationLaunchApp: didLaunch,
      payloadLength: payload?.length ?? 0,
    );
    if (!didLaunch) return;
    if (payload == null || payload == _handledLaunchPayload) return;
    _handledLaunchPayload = payload;
    NotificationTapDebugStore.recordResponseReceived(
      source: 'launch_details',
      payload: payload,
    );
    debugPrint(
      'notification launch response received payloadRawLength=${payload.length}',
    );
    _dispatchPayload(payload);
  }

  void _dispatchPayload(String? payload) {
    debugPrint(
      'FlutterLocalTagesimpulsNotificationScheduler dispatch payload '
      'payloadRawLength=${payload?.length ?? 0}',
    );
    final handler = _payloadHandler;
    if (handler == null) {
      _pendingPayloadForHandler = payload;
      debugPrint(
        'FlutterLocalTagesimpulsNotificationScheduler queued payload '
        'reason=handler_not_configured',
      );
      return;
    }
    handler(payload);
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
    _debugPlanStart(
      selectedWordsCount: options.impulses
          .expand((impulse) => impulse.usedWords)
          .toSet()
          .length,
      generatedImpulsesCount: options.impulses.length,
      frequency: options.impulses.length.clamp(0, 5),
      preferredWindow: options.preferredWindow,
    );

    final schedules = buildSchedules(options);
    return _schedulePreparedNotifications(
      schedules,
      now: options.now,
      emptyStatus: TagesimpulsNotificationPlanningStatus.noGeneratedImpulses,
      successStatus:
          TagesimpulsNotificationPlanningStatus.scheduledSuccessfully,
      noPendingStatus: TagesimpulsNotificationPlanningStatus
          .scheduledButNoPendingNotification,
      platformErrorStatus:
          TagesimpulsNotificationPlanningStatus.schedulePlatformError,
    );
  }

  Future<TagesimpulsNotificationPlanningResult>
  scheduleRealImpulseTestNotificationInTenSeconds({
    required TagesimpulsGeneratedImpulse impulse,
    required String chatId,
    required String messageId,
    DateTime? now,
  }) async {
    final start = now ?? DateTime.now();
    final notification = TagesimpulsNotificationSchedule(
      id: TagesimpulsNotificationIds.realTest,
      title: 'Talvori Tagesimpuls',
      body: impulse.message,
      scheduledAt: start.add(const Duration(seconds: 10)),
      slot: impulse.slot.trim().isEmpty ? 'test' : impulse.slot,
      usedWords: impulse.usedWords,
      payload: _payloadFor(
        slot: impulse.slot.trim().isEmpty ? 'test' : impulse.slot,
        chatId: chatId,
        messageId: messageId,
      ),
    );

    debugPrint(
      'TagesimpulsNotificationService real impulse test start '
      'scheduledAt=${notification.scheduledAt.toIso8601String()} '
      'hasInboxPayload=${ImpulseInboxNotificationPayload.parse(notification.payload)?.opensChat ?? false}',
    );

    return _schedulePreparedNotifications(
      [notification],
      now: start,
      cancelRegularBeforeScheduling: false,
      cancelRealTestBeforeScheduling: true,
      emptyStatus: TagesimpulsNotificationPlanningStatus.noGeneratedImpulses,
      successStatus:
          TagesimpulsNotificationPlanningStatus.realImpulseTestScheduled,
      noPendingStatus:
          TagesimpulsNotificationPlanningStatus.notificationPendingMissing,
      platformErrorStatus:
          TagesimpulsNotificationPlanningStatus.realImpulseScheduleFailed,
    );
  }

  Future<TagesimpulsNotificationPlanningResult>
  scheduleTestNotificationInTenSeconds({DateTime? now}) async {
    final start = now ?? DateTime.now();
    final notification = TagesimpulsNotificationSchedule(
      id: TagesimpulsNotificationIds.technicalTest,
      title: 'Talvori Test',
      body: 'Benachrichtigungen funktionieren.',
      scheduledAt: start.add(const Duration(seconds: 10)),
      slot: 'test',
      usedWords: const [],
      payload: 'tagesimpuls:test',
    );

    debugPrint(
      'TagesimpulsNotificationService test notification start '
      'scheduledAt=${notification.scheduledAt.toIso8601String()}',
    );

    return _schedulePreparedNotifications(
      [notification],
      now: start,
      cancelRegularBeforeScheduling: false,
      emptyStatus: TagesimpulsNotificationPlanningStatus.noGeneratedImpulses,
      successStatus:
          TagesimpulsNotificationPlanningStatus.scheduledSuccessfully,
      noPendingStatus: TagesimpulsNotificationPlanningStatus
          .scheduledButNoPendingNotification,
      platformErrorStatus:
          TagesimpulsNotificationPlanningStatus.schedulePlatformError,
    );
  }

  Future<TagesimpulsNotificationPlanningResult>
  inspectPendingNotifications() async {
    final pendingIds = await _safePendingNotificationIds();
    final pendingCount = pendingIds?.length;
    debugPrint(
      'TagesimpulsNotificationService pending inspection '
      'pendingCount=${pendingCount ?? -1} pendingIds=${pendingIds ?? const []}',
    );
    if (pendingCount == 0) {
      return const TagesimpulsNotificationPlanningResult(
        status: TagesimpulsNotificationPlanningStatus.noPendingNotifications,
        pendingNotificationCount: 0,
      );
    }
    return TagesimpulsNotificationPlanningResult(
      status: TagesimpulsNotificationPlanningStatus.scheduledSuccessfully,
      pendingNotificationCount: pendingCount,
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
            title: 'Talvori Tagesimpuls',
            body: impulse.message,
            scheduledAt: _nextSlotTime(
              impulse.slot,
              options.now,
              index,
              options.preferredWindow,
              customHour: options.customHour,
              customMinute: options.customMinute,
            ),
            slot: impulse.slot,
            usedWords: impulse.usedWords,
            payload: _payloadFor(
              slot: impulse.slot,
              chatId: options.chatId,
              messageId: index < options.messageIds.length
                  ? options.messageIds[index]
                  : null,
            ),
          );
        })
        .toList(growable: false);
  }

  Future<void> clearScheduledNotifications() async {
    await _cancelMatchingPendingNotifications(
      reason: 'clear regular Tagesimpuls notifications',
      matches: TagesimpulsNotificationIds.isRegular,
    );
  }

  Future<int?> _safePendingNotificationCount() async {
    try {
      return await _scheduler.pendingNotificationCount();
    } on Object catch (error) {
      _debugLog('pending count failed', error);
      return null;
    }
  }

  Future<TagesimpulsNotificationPlanningResult> _schedulePreparedNotifications(
    List<TagesimpulsNotificationSchedule> schedules, {
    required DateTime now,
    required TagesimpulsNotificationPlanningStatus emptyStatus,
    required TagesimpulsNotificationPlanningStatus successStatus,
    required TagesimpulsNotificationPlanningStatus noPendingStatus,
    required TagesimpulsNotificationPlanningStatus platformErrorStatus,
    bool cancelRegularBeforeScheduling = true,
    bool cancelRealTestBeforeScheduling = false,
  }) async {
    if (schedules.isEmpty) {
      return TagesimpulsNotificationPlanningResult(status: emptyStatus);
    }

    final validationStatus = _validateSchedules(schedules, now);
    if (validationStatus != null) {
      return TagesimpulsNotificationPlanningResult(
        status: validationStatus,
        scheduled: schedules,
      );
    }
    _debugSchedules(schedules);

    try {
      await _scheduler.initialize();
    } on Object catch (error) {
      _debugLog('initialize failed', error);
      return TagesimpulsNotificationPlanningResult(
        status: _isTimezoneError(error)
            ? TagesimpulsNotificationPlanningStatus.timezoneNotInitialized
            : TagesimpulsNotificationPlanningStatus
                  .notificationServiceNotInitialized,
        debugMessage: _debugMessage(error),
      );
    }

    final TagesimpulsNotificationPermissionStatus permission;
    try {
      permission = await _scheduler.requestPermission();
    } on Object catch (error) {
      _debugLog('permission request failed', error);
      return TagesimpulsNotificationPlanningResult(
        status: platformErrorStatus,
        debugMessage: _debugMessage(error),
      );
    }
    debugPrint('TagesimpulsNotificationService permission=$permission');
    switch (permission) {
      case TagesimpulsNotificationPermissionStatus.granted:
        break;
      case TagesimpulsNotificationPermissionStatus.denied:
        return TagesimpulsNotificationPlanningResult(
          status: TagesimpulsNotificationPlanningStatus.permissionDenied,
          permissionStatus: permission,
        );
      case TagesimpulsNotificationPermissionStatus.notRequested:
        return TagesimpulsNotificationPlanningResult(
          status: TagesimpulsNotificationPlanningStatus.permissionNotRequested,
          permissionStatus: permission,
        );
    }

    if (cancelRegularBeforeScheduling) {
      await _cancelMatchingPendingNotifications(
        reason: 'regular Tagesimpuls replanning',
        matches: TagesimpulsNotificationIds.isRegular,
      );
    }
    if (cancelRealTestBeforeScheduling) {
      await _cancelMatchingPendingNotifications(
        reason: 'real Tagesimpuls test replanning',
        matches: TagesimpulsNotificationIds.isRealTest,
      );
    }

    try {
      for (final notification in schedules) {
        await _scheduler.schedule(notification);
      }
    } on Object catch (error) {
      _debugLog('schedule failed', error);
      return TagesimpulsNotificationPlanningResult(
        status: _isTimezoneError(error)
            ? TagesimpulsNotificationPlanningStatus.timezoneNotInitialized
            : platformErrorStatus,
        debugMessage: _debugMessage(error),
        permissionStatus: permission,
      );
    }

    final pendingIds = await _safePendingNotificationIds();
    final scheduledIds = schedules.map((schedule) => schedule.id).toSet();
    final matchingPendingIds = pendingIds
        ?.where(scheduledIds.contains)
        .toList(growable: false);
    final pendingCount = matchingPendingIds?.length;
    debugPrint(
      'TagesimpulsNotificationService schedule result=${successStatus.name} '
      'pendingCount=${pendingCount ?? -1} '
      'pendingIds=${pendingIds ?? const []} scheduledIds=$scheduledIds',
    );
    if (pendingCount == 0) {
      return TagesimpulsNotificationPlanningResult(
        status: noPendingStatus,
        scheduled: schedules,
        pendingNotificationCount: pendingCount,
        permissionStatus: permission,
      );
    }
    return TagesimpulsNotificationPlanningResult(
      status: successStatus,
      scheduled: schedules,
      pendingNotificationCount: pendingCount,
      permissionStatus: permission,
    );
  }

  TagesimpulsNotificationPlanningStatus? _validateSchedules(
    List<TagesimpulsNotificationSchedule> schedules,
    DateTime now,
  ) {
    if (schedules.any((schedule) => schedule.body.trim().isEmpty)) {
      return TagesimpulsNotificationPlanningStatus.notificationBodyEmpty;
    }
    if (schedules.any(
      (schedule) => schedule.payload != null && schedule.payload!.length > 512,
    )) {
      return TagesimpulsNotificationPlanningStatus.notificationPayloadInvalid;
    }
    if (schedules.any((schedule) => !schedule.scheduledAt.isAfter(now))) {
      return TagesimpulsNotificationPlanningStatus.scheduledAtInPast;
    }
    return null;
  }

  Future<List<int>?> _safePendingNotificationIds() async {
    try {
      return await _scheduler.pendingNotificationIds();
    } on Object catch (error) {
      _debugLog('pending ids failed', error);
      await _safePendingNotificationCount();
      return null;
    }
  }

  int _notificationIdFor(int index, DateTime now) {
    final maxOffset =
        TagesimpulsNotificationIds.regularEnd -
        TagesimpulsNotificationIds.regularStart;
    return TagesimpulsNotificationIds.regularStart + index.clamp(0, maxOffset);
  }

  Future<void> _cancelMatchingPendingNotifications({
    required String reason,
    required bool Function(int id) matches,
  }) async {
    final before = await _safePendingNotificationIds();
    if (before == null) return;

    final cancelIds = before.where(matches).toList(growable: false);
    debugPrint(
      'TagesimpulsNotificationService cancel reason=$reason '
      'idsBefore=$before cancelIds=$cancelIds',
    );
    for (final id in cancelIds) {
      try {
        await _scheduler.cancel(id);
      } on Object catch (error) {
        _debugLog('cancel id=$id failed', error);
      }
    }

    final after = await _safePendingNotificationIds();
    debugPrint(
      'TagesimpulsNotificationService cancel reason=$reason '
      'idsAfter=${after ?? const []}',
    );
  }

  String _payloadFor({
    required String slot,
    String? chatId,
    String? messageId,
  }) {
    if (chatId != null && chatId.trim().isNotEmpty) {
      return ImpulseInboxNotificationPayload.encodeImpulseMessage(
        chatId: chatId.trim(),
        messageId: messageId?.trim() ?? '',
      );
    }
    return 'tagesimpuls:$slot';
  }

  DateTime _nextSlotTime(
    String slot,
    DateTime now,
    int index,
    TagesimpulsPreferredWindow preferredWindow, {
    int? customHour,
    int? customMinute,
  }) {
    final time = preferredWindow == TagesimpulsPreferredWindow.automatic
        ? _timeForSlot(slot, index)
        : _timeForPreferredWindow(
            preferredWindow,
            index,
            customHour: customHour,
            customMinute: customMinute,
          );

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

  ({int hour, int minute}) _timeForSlot(String slot, int index) {
    final lowerSlot = slot.trim().toLowerCase();
    return switch (lowerSlot) {
      'morning' => const (hour: 9, minute: 0),
      'noon' || 'midday' => const (hour: 12, minute: 30),
      'afternoon' => const (hour: 14, minute: 0),
      'evening' => const (hour: 18, minute: 30),
      _ => _fallbackTime(index),
    };
  }

  ({int hour, int minute}) _timeForPreferredWindow(
    TagesimpulsPreferredWindow preferredWindow,
    int index, {
    int? customHour,
    int? customMinute,
  }) {
    return switch (preferredWindow) {
      TagesimpulsPreferredWindow.morning => (
        hour: 8 + index.clamp(0, 2),
        minute: index.isEven ? 30 : 0,
      ),
      TagesimpulsPreferredWindow.noon => (
        hour: 12 + index.clamp(0, 2),
        minute: index.isEven ? 0 : 30,
      ),
      TagesimpulsPreferredWindow.afternoon => (
        hour: 14 + index.clamp(0, 2),
        minute: index.isEven ? 0 : 30,
      ),
      TagesimpulsPreferredWindow.evening => (
        hour: 18 + index.clamp(0, 2),
        minute: index.isEven ? 0 : 30,
      ),
      TagesimpulsPreferredWindow.custom => _customTime(
        index,
        customHour: customHour,
        customMinute: customMinute,
      ),
      TagesimpulsPreferredWindow.automatic => _fallbackTime(index),
    };
  }

  ({int hour, int minute}) _customTime(
    int index, {
    int? customHour,
    int? customMinute,
  }) {
    final startHour = (customHour ?? 9).clamp(0, 23);
    final minute = (customMinute ?? 0).clamp(0, 59);
    final hour = startHour + (index * 3);
    if (hour <= 21) {
      return (hour: hour, minute: minute);
    }
    return _fallbackTime(index);
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

  String _debugMessage(Object error) {
    if (error is PlatformException) {
      return '${error.code}: ${error.message ?? 'platform error'}';
    }
    return error.toString();
  }

  void _debugLog(String action, Object error) {
    debugPrint(
      'TagesimpulsNotificationService $action: '
      '${error.runtimeType}: ${_debugMessage(error)}',
    );
  }

  bool _isTimezoneError(Object error) {
    return error.toString().toLowerCase().contains('timezone');
  }

  void _debugPlanStart({
    required int selectedWordsCount,
    required int generatedImpulsesCount,
    required int frequency,
    required TagesimpulsPreferredWindow preferredWindow,
  }) {
    debugPrint(
      'TagesimpulsNotificationService plan start '
      'selectedWords=$selectedWordsCount '
      'frequency=$frequency '
      'window=${preferredWindow.name} '
      'generatedImpulses=$generatedImpulsesCount',
    );
  }

  void _debugSchedules(List<TagesimpulsNotificationSchedule> schedules) {
    debugPrint(
      'TagesimpulsNotificationService planned times='
      '${schedules.map((schedule) => schedule.scheduledAt.toIso8601String()).toList()}',
    );
    debugPrint(
      'TagesimpulsNotificationService planned notification details='
      '${schedules.map((schedule) => {'id': schedule.id, 'slot': schedule.slot, 'hasInboxPayload': ImpulseInboxNotificationPayload.parse(schedule.payload)?.opensChat ?? false}).toList()}',
    );
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
