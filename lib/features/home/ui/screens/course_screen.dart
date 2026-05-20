import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_message_controller.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_message_provider.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_controller.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_provider.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_models.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_service.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_settings.dart';

class CourseScreen extends ConsumerStatefulWidget {
  const CourseScreen({super.key});

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends ConsumerState<CourseScreen> {
  bool _isApplyingTagesimpulsSettings = false;

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(tagesimpulsSelectionControllerProvider);
    final messageState = ref.watch(tagesimpulsMessageControllerProvider);
    final notificationSettings = ref.watch(
      tagesimpulsNotificationSettingsControllerProvider,
    );
    final messageController = ref.read(
      tagesimpulsMessageControllerProvider.notifier,
    );
    final settingsController = ref.read(
      tagesimpulsNotificationSettingsControllerProvider.notifier,
    );
    final notificationService = ref.read(
      tagesimpulsNotificationServiceProvider,
    );
    final controller = ref.read(
      tagesimpulsSelectionControllerProvider.notifier,
    );
    final count = selection.count;
    final max = selection.maxCount;
    final full = selection.isFull;

    ref.listen<TagesimpulsSelectionState>(
      tagesimpulsSelectionControllerProvider,
      (previous, next) {
        if (previous?.items == next.items && previous?.isLoading == false) {
          return;
        }
        _syncTagesimpulsStatusWithSelection(
          selection: next,
          notificationSettings: ref.read(
            tagesimpulsNotificationSettingsControllerProvider,
          ),
          settingsController: ref.read(
            tagesimpulsNotificationSettingsControllerProvider.notifier,
          ),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncTagesimpulsStatusWithSelection(
        selection: ref.read(tagesimpulsSelectionControllerProvider),
        notificationSettings: ref.read(
          tagesimpulsNotificationSettingsControllerProvider,
        ),
        settingsController: ref.read(
          tagesimpulsNotificationSettingsControllerProvider.notifier,
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Tagesimpuls  •  $count/$max'),
        actions: [
          IconButton(
            tooltip: count == 0 ? 'Keine Wörter ausgewählt' : 'Auswahl leeren',
            onPressed: count == 0
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Tagesimpuls leeren?'),
                        content: Text(
                          full
                              ? 'Alle $count Wörter aus der Auswahl entfernen?'
                              : 'Du hast $count von $max Wörtern ausgewählt. Auswahl leeren?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Abbrechen'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Leeren'),
                          ),
                        ],
                      ),
                    );
                    if (!context.mounted) return;

                    if (ok == true) {
                      await controller.clear();
                      if (!context.mounted) return;
                      _showTagesimpulsSnackBar('Tagesimpuls-Auswahl geleert.');
                    }
                  },
            icon: const Icon(Icons.outbound_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _TagesimpulsPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    full
                        ? 'Bereit: Du hast $max Wörter für den Tagesimpuls gewählt.'
                        : 'Wähle noch ${max - count} Wort${max - count == 1 ? '' : 'er'} aus.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selection.items.isEmpty)
                    const Text(
                      'Noch keine Wörter ausgewählt. Nutze den Pfeil auf der Home-Karte oder die Quick-Action im Lernmodus.',
                      style: TextStyle(
                        color: Color(0xFFB8C4D9),
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in selection.items)
                          Chip(
                            label: Text(item.text),
                            onDeleted: () => controller.remove(item),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _TagesimpulsPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Impuls planen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stelle einmal ein, wie oft Talvori dir Wörter als kurze Tagesimpulse zeigen soll.',
                    style: TextStyle(
                      color: Color(0xFFB8C4D9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1 Tagesimpuls pro Tag ist voreingestellt. Du kannst ihn ausschalten oder die Häufigkeit ändern.',
                    style: TextStyle(
                      color: Color(0xFF7D8BA3),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Modus',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        key: const Key('tagesimpuls-mode-off'),
                        label: const Text('Aus'),
                        selected: !notificationSettings.enabled,
                        onSelected: (_) => _disableTagesimpuls(
                          service: notificationService,
                          settingsController: settingsController,
                        ),
                      ),
                      ChoiceChip(
                        key: const Key('tagesimpuls-mode-automatic'),
                        label: const Text('Automatisch'),
                        selected: notificationSettings.enabled,
                        onSelected: (_) => _activateTagesimpuls(
                          service: notificationService,
                          messageController: messageController,
                          settingsController: settingsController,
                          selectedItems: selection.items,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Häufigkeit',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (
                        var impulseCount = 1;
                        impulseCount <= 5;
                        impulseCount++
                      )
                        ChoiceChip(
                          key: Key('tagesimpuls-frequency-$impulseCount'),
                          label: Text('$impulseCount'),
                          selected:
                              notificationSettings.frequencyPerDay ==
                              impulseCount,
                          onSelected: (_) => _setFrequency(
                            service: notificationService,
                            messageController: messageController,
                            settingsController: settingsController,
                            selectedItems: selection.items,
                            frequency: impulseCount,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Zeitfenster',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final window in TagesimpulsPreferredWindow.values)
                        ChoiceChip(
                          key: Key('tagesimpuls-window-${window.name}'),
                          label: Text(_labelForWindow(window)),
                          selected:
                              notificationSettings.preferredWindow == window,
                          onSelected: (_) => _setPreferredWindow(
                            service: notificationService,
                            messageController: messageController,
                            settingsController: settingsController,
                            selectedItems: selection.items,
                            window: window,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusText(notificationSettings),
                    style: const TextStyle(
                      color: Color(0xFFB8C4D9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (notificationSettings.nextPlannedInfo != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      notificationSettings.nextPlannedInfo!,
                      style: const TextStyle(
                        color: Color(0xFF7FFFE7),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  if (notificationSettings.plannedTimes.length > 1) ...[
                    const SizedBox(height: 6),
                    Text(
                      _plannedTimesText(notificationSettings.plannedTimes),
                      style: const TextStyle(
                        color: Color(0xFFB8C4D9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (messageState.isGenerating ||
                      _isApplyingTagesimpulsSettings) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Tagesimpuls wird aktualisiert...',
                          style: TextStyle(
                            color: Color(0xFFB8C4D9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (selection.items.length < 3)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Füge mindestens 3 Wörter hinzu. Automatische Wortauswahl folgt später.',
                        style: TextStyle(
                          color: Color(0xFFFFC857),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const Key('tagesimpuls-test-notification'),
                      onPressed: () => _scheduleTestNotification(
                        service: notificationService,
                        settingsController: settingsController,
                      ),
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Test-Benachrichtigung'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _disableTagesimpuls({
    required TagesimpulsNotificationService service,
    required TagesimpulsNotificationSettingsController settingsController,
  }) async {
    await settingsController.setEnabled(false);
    await service.clearScheduledNotifications();
  }

  Future<void> _activateTagesimpuls({
    required TagesimpulsNotificationService service,
    required TagesimpulsMessageController messageController,
    required TagesimpulsNotificationSettingsController settingsController,
    required List<TagesimpulsSelectionItem> selectedItems,
  }) async {
    final settings = await settingsController.setEnabled(true);
    await _applyTagesimpulsSettings(
      service: service,
      messageController: messageController,
      settingsController: settingsController,
      selectedItems: selectedItems,
      settings: settings,
      showActivationFeedback: true,
    );
  }

  Future<void> _setFrequency({
    required TagesimpulsNotificationService service,
    required TagesimpulsMessageController messageController,
    required TagesimpulsNotificationSettingsController settingsController,
    required List<TagesimpulsSelectionItem> selectedItems,
    required int frequency,
  }) async {
    final settings = await settingsController.setFrequencyPerDay(frequency);
    await _applyTagesimpulsSettings(
      service: service,
      messageController: messageController,
      settingsController: settingsController,
      selectedItems: selectedItems,
      settings: settings,
    );
  }

  Future<void> _setPreferredWindow({
    required TagesimpulsNotificationService service,
    required TagesimpulsMessageController messageController,
    required TagesimpulsNotificationSettingsController settingsController,
    required List<TagesimpulsSelectionItem> selectedItems,
    required TagesimpulsPreferredWindow window,
  }) async {
    final settings = await settingsController.setPreferredWindow(window);
    await _applyTagesimpulsSettings(
      service: service,
      messageController: messageController,
      settingsController: settingsController,
      selectedItems: selectedItems,
      settings: settings,
    );
  }

  Future<void> _applyTagesimpulsSettings({
    required TagesimpulsNotificationService service,
    required TagesimpulsMessageController messageController,
    required TagesimpulsNotificationSettingsController settingsController,
    required List<TagesimpulsSelectionItem> selectedItems,
    required TagesimpulsNotificationSettings settings,
    bool showActivationFeedback = false,
  }) async {
    if (!settings.enabled) return;
    if (selectedItems.length < 3) {
      debugPrint(
        'Tagesimpuls planning skipped selectedWords=${selectedItems.length}',
      );
      settingsController.setNeedsWordsStatus(_notEnoughWordsStatus);
      return;
    }

    setState(() => _isApplyingTagesimpulsSettings = true);
    try {
      debugPrint(
        'Tagesimpuls planning start selectedWords=${selectedItems.length} '
        'frequency=${settings.frequencyPerDay} '
        'window=${settings.preferredWindow.name}',
      );
      messageController.setCount(settings.frequencyPerDay);
      await messageController.generate(selectedItems);
      final generated = ref.read(tagesimpulsMessageControllerProvider);
      if (generated.error != null) {
        debugPrint(
          'Tagesimpuls planning generation failed '
          'status=${generated.generationStatus.name} code=${generated.error}',
        );
        settingsController.setErrorStatus(
          _generationStatusText(generated.generationStatus),
        );
        return;
      }
      if (generated.impulses.isEmpty) {
        debugPrint('Tagesimpuls planning no generated impulses');
        settingsController.setErrorStatus(
          'Kein Tagesimpuls zum Planen vorhanden.',
        );
        return;
      }
      debugPrint(
        'Tagesimpuls planning generatedImpulses=${generated.impulses.length}',
      );

      final result = await service.planNotifications(
        TagesimpulsNotificationPlanOptions(
          impulses: generated.impulses
              .take(settings.frequencyPerDay)
              .toList(growable: false),
          preferredWindow: settings.preferredWindow,
        ),
      );
      if (!mounted) return;
      debugPrint(
        'Tagesimpuls planning scheduleStatus=${result.status.name} '
        'pendingCount=${result.pendingNotificationCount ?? -1} '
        'debug=${result.debugMessage ?? "-"}',
      );
      switch (result.status) {
        case TagesimpulsNotificationPlanningStatus.scheduledSuccessfully:
          final info = _nextPlannedInfo(result.scheduled.first.scheduledAt);
          settingsController.setPlannedTimes(
            result.scheduled.map((schedule) => schedule.scheduledAt).toList(),
            info,
          );
        case TagesimpulsNotificationPlanningStatus.permissionGranted:
          settingsController.setNextPlannedInfo('Tagesimpuls ist aktiv.');
        case TagesimpulsNotificationPlanningStatus.permissionDenied:
          settingsController.setPermissionDeniedStatus(
            'Benachrichtigungen sind nicht erlaubt.',
          );
          if (showActivationFeedback) {
            _showTagesimpulsSnackBar(
              'Benachrichtigungen müssen erlaubt werden.',
            );
          }
        case TagesimpulsNotificationPlanningStatus.permissionNotRequested:
          settingsController.setErrorStatus(
            'Benachrichtigungen wurden noch nicht angefragt.',
          );
        case TagesimpulsNotificationPlanningStatus.noGeneratedImpulses:
          settingsController.setErrorStatus(
            'Kein Tagesimpuls zum Planen vorhanden.',
          );
        case TagesimpulsNotificationPlanningStatus
            .notificationServiceNotInitialized:
          settingsController.setErrorStatus(
            'Benachrichtigungen sind noch nicht bereit.',
          );
        case TagesimpulsNotificationPlanningStatus.invalidScheduleTime:
          settingsController.setErrorStatus('Zeitpunkt liegt ungültig.');
        case TagesimpulsNotificationPlanningStatus.timezoneNotInitialized:
          settingsController.setErrorStatus(
            'Zeitzone für Benachrichtigungen ist noch nicht bereit.',
          );
        case TagesimpulsNotificationPlanningStatus.schedulePlatformError:
          settingsController.setErrorStatus(
            'Benachrichtigungen konnten vom System nicht geplant werden.',
          );
        case TagesimpulsNotificationPlanningStatus.impulseGenerationFailed:
          settingsController.setErrorStatus(
            'Tagesimpulse konnten nicht erzeugt werden.',
          );
      }
    } catch (_) {
      if (!mounted) return;
      settingsController.setErrorStatus(_genericPlanningErrorStatus);
    } finally {
      if (mounted) {
        setState(() => _isApplyingTagesimpulsSettings = false);
      }
    }
  }

  void _syncTagesimpulsStatusWithSelection({
    required TagesimpulsSelectionState selection,
    required TagesimpulsNotificationSettingsState notificationSettings,
    required TagesimpulsNotificationSettingsController settingsController,
  }) {
    if (selection.isLoading || !notificationSettings.enabled) return;

    if (selection.items.length < 3) {
      if (notificationSettings.nextPlannedInfo != _notEnoughWordsStatus) {
        settingsController.setNeedsWordsStatus(_notEnoughWordsStatus);
      }
      return;
    }

    if (notificationSettings.nextPlannedInfo == _notEnoughWordsStatus) {
      settingsController.clearNeedsWordsStatus();
    }
  }

  String _statusText(TagesimpulsNotificationSettingsState settings) {
    if (!settings.enabled) return 'Tagesimpuls ist ausgeschaltet.';
    final count = settings.frequencyPerDay;
    final plural = count == 1 ? '' : 'e';
    return 'Tagesimpuls aktiv · $count Impuls$plural pro Tag.';
  }

  static const _genericPlanningErrorStatus =
      'Tagesimpuls konnte nicht geplant werden.';
  static const _notEnoughWordsStatus = 'Füge mindestens 3 Wörter hinzu.';

  Future<void> _scheduleTestNotification({
    required TagesimpulsNotificationService service,
    required TagesimpulsNotificationSettingsController settingsController,
  }) async {
    final result = await service.scheduleTestNotificationInTenSeconds();
    if (!mounted) return;
    debugPrint(
      'Tagesimpuls test notification status=${result.status.name} '
      'pendingCount=${result.pendingNotificationCount ?? -1} '
      'debug=${result.debugMessage ?? "-"}',
    );

    switch (result.status) {
      case TagesimpulsNotificationPlanningStatus.scheduledSuccessfully:
        settingsController.setNextPlannedInfo('Test-Benachrichtigung geplant.');
      case TagesimpulsNotificationPlanningStatus.permissionDenied:
        settingsController.setPermissionDeniedStatus(
          'Benachrichtigungen sind nicht erlaubt. Bitte in den iPhone-Einstellungen aktivieren.',
        );
        _showTagesimpulsSnackBar('Benachrichtigungen müssen erlaubt werden.');
      case TagesimpulsNotificationPlanningStatus.permissionNotRequested:
        settingsController.setErrorStatus(
          'Benachrichtigungen wurden noch nicht angefragt.',
        );
      case TagesimpulsNotificationPlanningStatus
          .notificationServiceNotInitialized:
        settingsController.setErrorStatus(
          'Benachrichtigungen sind noch nicht bereit.',
        );
      case TagesimpulsNotificationPlanningStatus.invalidScheduleTime:
        settingsController.setErrorStatus('Zeitpunkt liegt ungültig.');
      case TagesimpulsNotificationPlanningStatus.timezoneNotInitialized:
        settingsController.setErrorStatus(
          'Zeitzone für Benachrichtigungen ist noch nicht bereit.',
        );
      case TagesimpulsNotificationPlanningStatus.schedulePlatformError:
        settingsController.setErrorStatus(
          'Benachrichtigungen konnten vom System nicht geplant werden.',
        );
      case TagesimpulsNotificationPlanningStatus.noGeneratedImpulses:
      case TagesimpulsNotificationPlanningStatus.impulseGenerationFailed:
      case TagesimpulsNotificationPlanningStatus.permissionGranted:
        settingsController.setErrorStatus(_genericPlanningErrorStatus);
    }
  }

  String _generationStatusText(TagesimpulsGenerationStatus status) {
    return switch (status) {
      TagesimpulsGenerationStatus.aiClientNotConfigured =>
        'KI ist noch nicht konfiguriert.',
      TagesimpulsGenerationStatus.functionCallFailed =>
        'Tagesimpulse konnten nicht erzeugt werden.',
      TagesimpulsGenerationStatus.quotaExceeded =>
        'Tagesimpuls-Limit erreicht.',
      TagesimpulsGenerationStatus.invalidAiResponse =>
        'KI-Antwort konnte nicht verarbeitet werden.',
      TagesimpulsGenerationStatus.noImpulsesReturned =>
        'Es wurden keine Tagesimpulse erzeugt.',
      TagesimpulsGenerationStatus.notEnoughWords =>
        'Füge mindestens 3 Wörter hinzu.',
      TagesimpulsGenerationStatus.generationSucceeded ||
      TagesimpulsGenerationStatus.idle => _genericPlanningErrorStatus,
    };
  }

  String _labelForWindow(TagesimpulsPreferredWindow window) {
    return switch (window) {
      TagesimpulsPreferredWindow.automatic => 'Automatisch',
      TagesimpulsPreferredWindow.morning => 'Morgens',
      TagesimpulsPreferredWindow.noon => 'Mittags',
      TagesimpulsPreferredWindow.afternoon => 'Nachmittags',
      TagesimpulsPreferredWindow.evening => 'Abends',
    };
  }

  String _nextPlannedInfo(DateTime scheduledAt) {
    return 'Nächster Impuls: ${_dayLabel(scheduledAt)} um ${_timeLabel(scheduledAt)} Uhr.';
  }

  String _plannedTimesText(List<DateTime> plannedTimes) {
    if (plannedTimes.isEmpty) return '';
    final sorted = [...plannedTimes]..sort();
    final first = sorted.first;
    final sameDay = sorted.every(
      (time) =>
          time.year == first.year &&
          time.month == first.month &&
          time.day == first.day,
    );
    final times = sorted.map(_timeLabel).join(' · ');
    if (!sameDay) {
      return 'Geplant: ${sorted.map((time) => '${_dayLabel(time)} ${_timeLabel(time)}').join(' · ')}';
    }
    final prefix = _dayLabel(first);
    final capitalized = prefix.isEmpty
        ? 'Geplant'
        : '${prefix[0].toUpperCase()}${prefix.substring(1)} geplant';
    return '$capitalized: $times';
  }

  String _dayLabel(DateTime scheduledAt) {
    final now = DateTime.now();
    final day = DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'heute';
    if (day == today.add(const Duration(days: 1))) return 'morgen';
    return 'am ${scheduledAt.day}.${scheduledAt.month}.';
  }

  String _timeLabel(DateTime scheduledAt) {
    final hour = scheduledAt.hour.toString().padLeft(2, '0');
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showTagesimpulsSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF07111A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF59D7FF), width: 1),
        ),
      ),
    );
  }
}

class _TagesimpulsPanel extends StatelessWidget {
  const _TagesimpulsPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1018),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF59D7FF), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x2259D7FF), blurRadius: 20),
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
