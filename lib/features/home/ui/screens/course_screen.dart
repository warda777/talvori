import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_payload.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_router.dart';
import 'package:talvori/features/impuls_postfach/notifications/notification_tap_debug_state.dart';
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

class _CourseScreenState extends ConsumerState<CourseScreen>
    with WidgetsBindingObserver {
  bool _isApplyingTagesimpulsSettings = false;
  DateTime? _lastRealTestScheduledAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateCurrentTagesimpulsPlan();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _validateCurrentTagesimpulsPlan();
    }
  }

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
    final statusViewModel = _TagesimpulsStatusViewModel.from(
      selection: selection,
      settings: notificationSettings,
    );
    final realTestEnabled = statusViewModel.canRunRealTenSecondTest;

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
                          onSelected: (_) async {
                            if (window == TagesimpulsPreferredWindow.custom) {
                              await _setCustomTime(
                                service: notificationService,
                                messageController: messageController,
                                settingsController: settingsController,
                                selectedItems: selection.items,
                                currentSettings: notificationSettings.settings,
                              );
                              return;
                            }
                            await _setPreferredWindow(
                              service: notificationService,
                              messageController: messageController,
                              settingsController: settingsController,
                              selectedItems: selection.items,
                              window: window,
                            );
                          },
                        ),
                    ],
                  ),
                  if (notificationSettings.preferredWindow ==
                      TagesimpulsPreferredWindow.custom) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Eigene Zeit: ${_customTimeLabel(notificationSettings.settings)} Uhr',
                      style: const TextStyle(
                        color: Color(0xFF7FFFE7),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _TagesimpulsStatusBlock(viewModel: statusViewModel),
                  if (statusViewModel.showPlannedTimes) ...[
                    const SizedBox(height: 6),
                    Text(
                      _plannedTimesText(statusViewModel.plannedTimes),
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
                  if (kDebugMode) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const Key('tagesimpuls-test-notification'),
                      onPressed: () => _scheduleTestNotification(
                        service: notificationService,
                        settingsController: settingsController,
                      ),
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Test in 10 Sekunden'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const Key('real_tagesimpuls_10s_test_button'),
                      onPressed:
                          !realTestEnabled || _isApplyingTagesimpulsSettings
                          ? null
                          : () => runRealTagesimpulsTestInTenSeconds(
                              service: notificationService,
                              messageController: messageController,
                              settingsController: settingsController,
                            ),
                      icon: const Icon(Icons.quickreply_outlined),
                      label: Text(
                        _isApplyingTagesimpulsSettings
                            ? 'Test wird geplant...'
                            : 'Tagesimpuls in 10 Sekunden testen',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _NotificationTapDebugPanel(),
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

  Future<void> _setCustomTime({
    required TagesimpulsNotificationService service,
    required TagesimpulsMessageController messageController,
    required TagesimpulsNotificationSettingsController settingsController,
    required List<TagesimpulsSelectionItem> selectedItems,
    required TagesimpulsNotificationSettings currentSettings,
  }) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentSettings.customHour,
        minute: currentSettings.customMinute,
      ),
    );
    if (selected == null) return;
    if (!mounted) return;

    final settings = await settingsController.setCustomTime(
      hour: selected.hour,
      minute: selected.minute,
    );
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
      final impulsesForPlan = generated.impulses
          .take(settings.frequencyPerDay)
          .toList(growable: false);
      final inboxMessages = await ref
          .read(impulseInboxControllerProvider.notifier)
          .addDailyImpulseMessages(impulsesForPlan);
      final messageIds = inboxMessages
          .map((message) => message.id)
          .toList(growable: false);
      debugPrint(
        'Tagesimpuls planning inbox savedMessages=${inboxMessages.length} '
        'chatId=${SharedPreferencesImpulseInboxRepository.dailyImpulseChatId} '
        'hasMessageIds=${messageIds.isNotEmpty} '
        'customTime=${settings.preferredWindow == TagesimpulsPreferredWindow.custom ? '${settings.customHour}:${settings.customMinute.toString().padLeft(2, '0')}' : '-'}',
      );

      final result = await service.planNotifications(
        TagesimpulsNotificationPlanOptions(
          impulses: impulsesForPlan,
          preferredWindow: settings.preferredWindow,
          customHour: settings.customHour,
          customMinute: settings.customMinute,
          chatId: SharedPreferencesImpulseInboxRepository.dailyImpulseChatId,
          messageIds: messageIds,
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
        case TagesimpulsNotificationPlanningStatus.realImpulseTestScheduled:
          settingsController.setPlannedTimes(
            result.scheduled.map((schedule) => schedule.scheduledAt).toList(),
            'Echter Tagesimpuls-Test geplant.',
          );
        case TagesimpulsNotificationPlanningStatus
            .realImpulseTestDeliveredUnknown:
          settingsController.setNextPlannedInfo(
            'Echter Tagesimpuls-Test geplant. Zustellung wird vom System übernommen.',
          );
        case TagesimpulsNotificationPlanningStatus.realImpulseScheduleFailed:
          settingsController.setErrorStatus(
            'Echter Tagesimpuls-Test konnte nicht geplant werden.',
          );
        case TagesimpulsNotificationPlanningStatus
            .scheduledButNoPendingNotification:
        case TagesimpulsNotificationPlanningStatus.notificationPendingMissing:
          settingsController.setErrorStatus(
            'Benachrichtigungen wurden nicht registriert.',
          );
        case TagesimpulsNotificationPlanningStatus.notificationBodyEmpty:
          settingsController.setErrorStatus('Tagesimpuls-Nachricht ist leer.');
        case TagesimpulsNotificationPlanningStatus.notificationPayloadInvalid:
          settingsController.setErrorStatus(
            'Tagesimpuls-Payload ist ungültig.',
          );
        case TagesimpulsNotificationPlanningStatus.scheduledAtInPast:
          settingsController.setErrorStatus(
            'Tagesimpuls-Zeit liegt in der Vergangenheit.',
          );
        case TagesimpulsNotificationPlanningStatus.noPendingNotifications:
          settingsController.setErrorStatus(
            'Keine geplanten Benachrichtigungen gefunden.',
          );
        case TagesimpulsNotificationPlanningStatus.expiredScheduleRecomputed:
          settingsController.setNextPlannedInfo(
            'Tagesimpuls-Zeit wurde aktualisiert.',
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
    if (kDebugMode) {
      debugPrint(
        'Tagesimpuls state sync headerCount=${selection.count} '
        'planningSelectionCount=${selection.items.length} '
        'controllerSelectionCount=${selection.items.length} '
        'buttonEnabled=${selection.items.length >= 3} '
        'selectedWords=${selection.items.map((item) => item.text).take(5).toList()}',
      );
    }

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
      case TagesimpulsNotificationPlanningStatus.realImpulseTestScheduled:
        settingsController.setNextPlannedInfo(
          'Echter Tagesimpuls-Test geplant.',
        );
      case TagesimpulsNotificationPlanningStatus
          .realImpulseTestDeliveredUnknown:
        settingsController.setNextPlannedInfo(
          'Echter Tagesimpuls-Test geplant. Zustellung wird vom System übernommen.',
        );
      case TagesimpulsNotificationPlanningStatus.realImpulseScheduleFailed:
        settingsController.setErrorStatus(
          'Echter Tagesimpuls-Test konnte nicht geplant werden.',
        );
      case TagesimpulsNotificationPlanningStatus
          .scheduledButNoPendingNotification:
      case TagesimpulsNotificationPlanningStatus.notificationPendingMissing:
        settingsController.setErrorStatus(
          'Test-Benachrichtigung wurde nicht registriert.',
        );
      case TagesimpulsNotificationPlanningStatus.notificationBodyEmpty:
        settingsController.setErrorStatus('Tagesimpuls-Nachricht ist leer.');
      case TagesimpulsNotificationPlanningStatus.notificationPayloadInvalid:
        settingsController.setErrorStatus('Tagesimpuls-Payload ist ungültig.');
      case TagesimpulsNotificationPlanningStatus.scheduledAtInPast:
        settingsController.setErrorStatus(
          'Tagesimpuls-Zeit liegt in der Vergangenheit.',
        );
      case TagesimpulsNotificationPlanningStatus.noPendingNotifications:
        settingsController.setErrorStatus(
          'Keine geplanten Benachrichtigungen gefunden.',
        );
      case TagesimpulsNotificationPlanningStatus.expiredScheduleRecomputed:
        settingsController.setNextPlannedInfo(
          'Tagesimpuls-Zeit wurde aktualisiert.',
        );
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

  Future<void> runRealTagesimpulsTestInTenSeconds({
    required TagesimpulsNotificationService service,
    required TagesimpulsMessageController messageController,
    required TagesimpulsNotificationSettingsController settingsController,
  }) async {
    debugPrint('real 10s button tapped');
    final selectedItems = ref
        .read(tagesimpulsSelectionControllerProvider)
        .items;
    final canRun = selectedItems.length >= 3;
    debugPrint(
      'Tagesimpuls real 10s actionSelectionCount=${selectedItems.length} '
      'canRun=$canRun '
      'selectedWords=${selectedItems.map((item) => item.text).take(5).toList()}',
    );
    if (selectedItems.length < 3) {
      settingsController.setNeedsWordsStatus(_notEnoughWordsStatus);
      return;
    }

    setState(() => _isApplyingTagesimpulsSettings = true);
    settingsController.setNextPlannedInfo(
      'Tagesimpuls-Test wird vorbereitet...',
    );
    try {
      debugPrint(
        'Tagesimpuls real 10s start selectionCount=${selectedItems.length}',
      );
      messageController.setCount(1);
      debugPrint('Tagesimpuls real 10s call generate-daily-impulses');
      await messageController.generate(selectedItems);
      final generated = ref.read(tagesimpulsMessageControllerProvider);
      if (generated.error != null || generated.impulses.isEmpty) {
        debugPrint(
          'Tagesimpuls real 10s generation failed '
          'status=${generated.generationStatus.name} code=${generated.error}',
        );
        settingsController.setErrorStatus(
          _generationStatusText(generated.generationStatus),
        );
        return;
      }
      debugPrint(
        'Tagesimpuls real 10s generatedImpulses=${generated.impulses.length}',
      );

      final impulse = generated.impulses.first;
      debugPrint('Tagesimpuls real 10s ensure daily impulse chat and save');
      final List<ImpulseMessage> inboxMessages;
      try {
        inboxMessages = await ref
            .read(impulseInboxControllerProvider.notifier)
            .addDailyImpulseMessages([impulse]);
      } on Object catch (error) {
        debugPrint(
          'Tagesimpuls real 10s inbox save failed: '
          '${error.runtimeType}: $error',
        );
        settingsController.setErrorStatus(
          'Impuls konnte nicht im Postfach gespeichert werden.',
        );
        return;
      }
      if (inboxMessages.isEmpty) {
        settingsController.setErrorStatus(
          'Impuls konnte nicht im Postfach gespeichert werden.',
        );
        return;
      }
      final message = inboxMessages.first;
      debugPrint(
        'Tagesimpuls real 10s inbox savedMessages=${inboxMessages.length} '
        'chatId=${SharedPreferencesImpulseInboxRepository.dailyImpulseChatId} '
        'messageId=${message.id} '
        'notificationBodyEmpty=${impulse.message.trim().isEmpty}',
      );

      final result = await service
          .scheduleRealImpulseTestNotificationInTenSeconds(
            impulse: impulse,
            chatId: SharedPreferencesImpulseInboxRepository.dailyImpulseChatId,
            messageId: message.id,
          );
      if (!mounted) return;
      final scheduledAt = result.scheduled.isEmpty
          ? '-'
          : result.scheduled.first.scheduledAt.toIso8601String();
      final notificationId = result.scheduled.isEmpty
          ? '-'
          : result.scheduled.first.id.toString();
      final payload = result.scheduled.isEmpty
          ? null
          : result.scheduled.first.payload;
      debugPrint(
        'Tagesimpuls real 10s scheduleStatus=${result.status.name} '
        'scheduledAt=$scheduledAt '
        'notificationId=$notificationId '
        'payloadHasInbox=${ImpulseInboxNotificationPayload.parse(payload)?.opensChat ?? false} '
        'pendingCount=${result.pendingNotificationCount ?? -1} '
        'debug=${result.debugMessage ?? "-"}',
      );
      switch (result.status) {
        case TagesimpulsNotificationPlanningStatus.realImpulseTestScheduled:
          _lastRealTestScheduledAt = DateTime.now();
          settingsController.setNextPlannedInfo('Tagesimpuls-Test geplant.');
        case TagesimpulsNotificationPlanningStatus.notificationPendingMissing:
          settingsController.setErrorStatus(
            'Benachrichtigung konnte nicht geplant werden.',
          );
        case TagesimpulsNotificationPlanningStatus.realImpulseScheduleFailed:
          settingsController.setErrorStatus(
            'Benachrichtigung konnte nicht geplant werden.',
          );
        case TagesimpulsNotificationPlanningStatus.permissionDenied:
          settingsController.setPermissionDeniedStatus(
            'Benachrichtigungen sind nicht erlaubt.',
          );
        case TagesimpulsNotificationPlanningStatus.notificationBodyEmpty:
          settingsController.setErrorStatus('Tagesimpuls-Nachricht ist leer.');
        case TagesimpulsNotificationPlanningStatus.notificationPayloadInvalid:
          settingsController.setErrorStatus(
            'Tagesimpuls-Payload ist ungültig.',
          );
        case TagesimpulsNotificationPlanningStatus.scheduledAtInPast:
          settingsController.setErrorStatus(
            'Tagesimpuls-Zeit liegt in der Vergangenheit.',
          );
        default:
          settingsController.setErrorStatus(
            'Benachrichtigung konnte nicht geplant werden.',
          );
      }
    } catch (error) {
      debugPrint('Tagesimpuls real 10s failed: ${error.runtimeType}: $error');
      if (!mounted) return;
      settingsController.setErrorStatus(
        'Benachrichtigung konnte nicht geplant werden.',
      );
    } finally {
      if (mounted) {
        setState(() => _isApplyingTagesimpulsSettings = false);
      }
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
      TagesimpulsGenerationStatus.wordsRequired =>
        'Tagesimpuls-Wörter konnten nicht vorbereitet werden.',
      TagesimpulsGenerationStatus.generationSucceeded ||
      TagesimpulsGenerationStatus.idle => _genericPlanningErrorStatus,
    };
  }

  Future<void> _validateCurrentTagesimpulsPlan() async {
    if (!mounted) return;

    final selection = ref.read(tagesimpulsSelectionControllerProvider);
    final notificationSettings = ref.read(
      tagesimpulsNotificationSettingsControllerProvider,
    );
    final settingsController = ref.read(
      tagesimpulsNotificationSettingsControllerProvider.notifier,
    );
    final notificationService = ref.read(
      tagesimpulsNotificationServiceProvider,
    );

    if (selection.isLoading || !notificationSettings.enabled) return;

    final hadLocalPlan =
        notificationSettings.plannedTimes.isNotEmpty ||
        notificationSettings.nextPlannedAt != null;

    if (_isRecentRealTest()) {
      debugPrint(
        'Tagesimpuls pending validation skipped because realTestInProgress=false '
        'recentRealTest=true',
      );
      return;
    }
    final prunedExpiredTimes = settingsController.pruneExpiredPlannedTimes(
      DateTime.now(),
      _nextPlannedInfo,
    );
    final refreshedSettings = ref.read(
      tagesimpulsNotificationSettingsControllerProvider,
    );

    if (selection.items.length < 3) {
      settingsController.setNeedsWordsStatus(_notEnoughWordsStatus);
      return;
    }

    if (!hadLocalPlan) return;

    final inspection = await notificationService.inspectPendingNotifications();
    if (!mounted) return;
    debugPrint(
      'Tagesimpuls pending validation status=${inspection.status.name} '
      'pendingCount=${inspection.pendingNotificationCount ?? -1} '
      'prunedExpiredTimes=$prunedExpiredTimes',
    );

    if (inspection.status ==
        TagesimpulsNotificationPlanningStatus.noPendingNotifications) {
      settingsController.setErrorStatus(
        'Keine geplanten Benachrichtigungen gefunden.',
      );
      await _applyTagesimpulsSettings(
        service: notificationService,
        messageController: ref.read(
          tagesimpulsMessageControllerProvider.notifier,
        ),
        settingsController: settingsController,
        selectedItems: selection.items,
        settings: refreshedSettings.settings,
      );
      return;
    }

    if (prunedExpiredTimes && refreshedSettings.plannedTimes.isEmpty) {
      await _applyTagesimpulsSettings(
        service: notificationService,
        messageController: ref.read(
          tagesimpulsMessageControllerProvider.notifier,
        ),
        settingsController: settingsController,
        selectedItems: selection.items,
        settings: refreshedSettings.settings,
      );
    }
  }

  String _labelForWindow(TagesimpulsPreferredWindow window) {
    return switch (window) {
      TagesimpulsPreferredWindow.automatic => 'Automatisch',
      TagesimpulsPreferredWindow.morning => 'Morgens',
      TagesimpulsPreferredWindow.noon => 'Mittags',
      TagesimpulsPreferredWindow.afternoon => 'Nachmittags',
      TagesimpulsPreferredWindow.evening => 'Abends',
      TagesimpulsPreferredWindow.custom => 'Eigene Zeit',
    };
  }

  bool _isRecentRealTest() {
    final scheduledAt = _lastRealTestScheduledAt;
    if (scheduledAt == null) return false;
    return DateTime.now().difference(scheduledAt) < const Duration(seconds: 20);
  }

  String _customTimeLabel(TagesimpulsNotificationSettings settings) {
    final hour = settings.customHour.toString().padLeft(2, '0');
    final minute = settings.customMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
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

enum _TagesimpulsStatusSeverity { info, warning, error }

class _NotificationTapDebugPanel extends StatelessWidget {
  const _NotificationTapDebugPanel();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NotificationTapDebugState>(
      valueListenable: NotificationTapDebugStore.value,
      builder: (context, state, _) {
        final title = state.hasTap
            ? 'Letzter Notification-Tap: ${state.lastParsedType ?? 'unbekannt'}'
            : 'Noch kein Notification-Tap empfangen';
        final details = [
          if (state.lastPayloadRawPreview != null)
            'Payload: ${state.lastPayloadRawPreview}',
          if (state.lastChatId != null) 'Chat: ${state.lastChatId}',
          if (state.lastMessageId != null) 'Message: ${state.lastMessageId}',
          if (state.lastRouteTarget != null)
            'Route: ${state.lastRouteTarget} / ${state.lastRouteResult ?? '-'}',
          if (state.didNotificationLaunchApp != null)
            'Launch checked: ${state.didNotificationLaunchApp}',
          if (state.lastError != null) 'Fehler: ${state.lastError}',
        ];

        return Container(
          key: const Key('notification-tap-debug-panel'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF07111A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x3359D7FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                key: const Key('notification-tap-debug-title'),
                style: const TextStyle(
                  color: Color(0xFF7FFFE7),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 6),
                for (final line in details)
                  Text(
                    line,
                    style: const TextStyle(
                      color: Color(0xFFB8C4D9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    key: const Key('open-last-notification-payload'),
                    onPressed: state.hasPayload
                        ? () => ImpulseInboxNotificationRouter.handlePayload(
                            state.lastPayloadRaw,
                          )
                        : null,
                    child: const Text('Letzte Notification-Payload öffnen'),
                  ),
                  OutlinedButton(
                    key: const Key('simulate-impulse-message-payload'),
                    onPressed: () =>
                        ImpulseInboxNotificationRouter.simulateImpulseMessage(
                          messageId: state.lastMessageId,
                        ),
                    child: const Text('Chat-Payload simulieren'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TagesimpulsStatusViewModel {
  const _TagesimpulsStatusViewModel({
    required this.statusText,
    required this.severity,
    required this.canRunRealTenSecondTest,
    this.secondaryText,
    this.plannedTimes = const [],
  });

  factory _TagesimpulsStatusViewModel.from({
    required TagesimpulsSelectionState selection,
    required TagesimpulsNotificationSettingsState settings,
  }) {
    final selectionCount = selection.count;
    if (selectionCount < 3) {
      return const _TagesimpulsStatusViewModel(
        statusText: 'Füge mindestens 3 Wörter hinzu.',
        secondaryText: 'Automatische Wortauswahl folgt später.',
        severity: _TagesimpulsStatusSeverity.warning,
        canRunRealTenSecondTest: false,
      );
    }

    if (!settings.enabled) {
      return const _TagesimpulsStatusViewModel(
        statusText: 'Tagesimpuls ist ausgeschaltet.',
        severity: _TagesimpulsStatusSeverity.info,
        canRunRealTenSecondTest: true,
      );
    }

    final nextInfo = settings.nextPlannedInfo;
    if (nextInfo != null &&
        nextInfo.trim().isNotEmpty &&
        nextInfo != 'Füge mindestens 3 Wörter hinzu.') {
      final severity =
          settings.displayStatus == TagesimpulsNotificationDisplayStatus.error
          ? _TagesimpulsStatusSeverity.error
          : settings.displayStatus ==
                TagesimpulsNotificationDisplayStatus.permissionDenied
          ? _TagesimpulsStatusSeverity.warning
          : _TagesimpulsStatusSeverity.info;
      return _TagesimpulsStatusViewModel(
        statusText: nextInfo,
        severity: severity,
        canRunRealTenSecondTest: true,
        plannedTimes: settings.plannedTimes,
      );
    }

    final count = settings.frequencyPerDay;
    final plural = count == 1 ? '' : 'e';
    return _TagesimpulsStatusViewModel(
      statusText: 'Tagesimpuls aktiv · $count Impuls$plural pro Tag.',
      severity: _TagesimpulsStatusSeverity.info,
      canRunRealTenSecondTest: true,
      plannedTimes: settings.plannedTimes,
    );
  }

  final String statusText;
  final String? secondaryText;
  final _TagesimpulsStatusSeverity severity;
  final bool canRunRealTenSecondTest;
  final List<DateTime> plannedTimes;

  bool get showPlannedTimes => plannedTimes.length > 1;
}

class _TagesimpulsStatusBlock extends StatelessWidget {
  const _TagesimpulsStatusBlock({required this.viewModel});

  final _TagesimpulsStatusViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final color = switch (viewModel.severity) {
      _TagesimpulsStatusSeverity.info => const Color(0xFF7FFFE7),
      _TagesimpulsStatusSeverity.warning => const Color(0xFFFFC857),
      _TagesimpulsStatusSeverity.error => const Color(0xFFFF6B8A),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viewModel.statusText,
          key: const Key('tagesimpuls-planning-status'),
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        if (viewModel.secondaryText != null) ...[
          const SizedBox(height: 4),
          Text(
            viewModel.secondaryText!,
            key: const Key('tagesimpuls-planning-status-secondary'),
            style: const TextStyle(
              color: Color(0xFF7D8BA3),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
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
