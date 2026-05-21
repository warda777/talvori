import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_ai_profile.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_saved_message.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_payload.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_message_provider.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_provider.dart';
import 'package:talvori/features/tagesimpuls/data/tagesimpuls_selection_repository.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_models.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_service.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'standard is automatic one daily impulse and no AI request on open',
    (tester) async {
      final fakeClient = _FakeTagesimpulsAiClient();

      await _pumpCourseScreen(tester, fakeClient: fakeClient);

      final automaticChip = tester.widget<ChoiceChip>(
        find.byKey(const Key('tagesimpuls-mode-automatic')),
      );
      final oneChip = tester.widget<ChoiceChip>(
        find.byKey(const Key('tagesimpuls-frequency-1')),
      );
      final automaticWindowChip = tester.widget<ChoiceChip>(
        find.byKey(const Key('tagesimpuls-window-automatic')),
      );
      expect(automaticChip.selected, isTrue);
      expect(oneChip.selected, isTrue);
      expect(automaticWindowChip.selected, isTrue);
      expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsOneWidget);
      expect(find.text('Tagesimpuls speichern'), findsNothing);
      expect(fakeClient.requests, isEmpty);
    },
  );

  testWidgets('custom time option is visible and selected time is shown', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient();
    final settingsRepository = _MemorySettingsRepository(
      const TagesimpulsNotificationSettings(
        preferredWindow: TagesimpulsPreferredWindow.custom,
        customHour: 12,
        customMinute: 7,
      ),
    );

    await _pumpCourseScreen(
      tester,
      fakeClient: fakeClient,
      settingsRepository: settingsRepository,
    );

    expect(find.text('Eigene Zeit'), findsOneWidget);
    final customChip = tester.widget<ChoiceChip>(
      find.byKey(const Key('tagesimpuls-window-custom')),
    );
    expect(customChip.selected, isTrue);
    expect(find.text('Eigene Zeit: 12:07 Uhr'), findsOneWidget);
    expect(fakeClient.requests, isEmpty);
  });

  testWidgets('under three words shows hint and does not generate on change', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient();

    await _pumpCourseScreen(
      tester,
      initialItems: [_item('word-1', 'move'), _item('word-2', 'superstar')],
      fakeClient: fakeClient,
    );

    await tester.tap(find.byKey(const Key('tagesimpuls-frequency-2')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsOneWidget);
    expect(
      find.text(
        'Füge mindestens 3 Wörter hinzu. Automatische Wortauswahl folgt später.',
      ),
      findsNothing,
    );
    expect(
      find.byKey(const Key('tagesimpuls-planning-status')),
      findsOneWidget,
    );
    expect(fakeClient.requests, isEmpty);
  });

  testWidgets('zero words show exactly one planning status', (tester) async {
    await _pumpCourseScreen(tester);

    expect(
      find.byKey(const Key('tagesimpuls-planning-status')),
      findsOneWidget,
    );
    expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsOneWidget);
    expect(
      find.byKey(const Key('tagesimpuls-planning-status-secondary')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Füge mindestens 3 Wörter hinzu. Automatische Wortauswahl folgt später.',
      ),
      findsNothing,
    );
  });

  testWidgets(
    'selection changes update not enough status without changing settings',
    (tester) async {
      final fakeClient = _FakeTagesimpulsAiClient();
      final fakeScheduler = _FakeNotificationScheduler();

      await _pumpCourseScreen(
        tester,
        initialItems: [_item('word-1', 'move'), _item('word-2', 'superstar')],
        fakeClient: fakeClient,
        fakeScheduler: fakeScheduler,
      );

      expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsOneWidget);
      expect(
        find.byKey(const Key('tagesimpuls-planning-status')),
        findsOneWidget,
      );
      var realTestButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('real_tagesimpuls_10s_test_button')),
      );
      expect(realTestButton.onPressed, isNull);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourseScreen)),
        listen: false,
      );
      await container
          .read(tagesimpulsSelectionControllerProvider.notifier)
          .add(_item('word-3', 'destroyed'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsNothing);
      expect(
        find.text('Tagesimpuls aktiv · 1 Impuls pro Tag.'),
        findsOneWidget,
      );
      realTestButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('real_tagesimpuls_10s_test_button')),
      );
      expect(realTestButton.onPressed, isNotNull);
      expect(fakeClient.requests, isEmpty);
      expect(fakeScheduler.scheduled, isEmpty);
    },
  );

  testWidgets(
    'stale not enough error clears when global selection reaches three words',
    (tester) async {
      final fakeClient = _FakeTagesimpulsAiClient();
      final fakeScheduler = _FakeNotificationScheduler();

      await _pumpCourseScreen(
        tester,
        initialItems: [_item('word-1', 'move'), _item('word-2', 'superstar')],
        fakeClient: fakeClient,
        fakeScheduler: fakeScheduler,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CourseScreen)),
        listen: false,
      );
      container
          .read(tagesimpulsNotificationSettingsControllerProvider.notifier)
          .setErrorStatus('Füge mindestens 3 Wörter hinzu.');
      await tester.pump();
      expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsOneWidget);

      await container
          .read(tagesimpulsSelectionControllerProvider.notifier)
          .add(_item('word-3', 'destroyed'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsNothing);
      expect(
        find.text('Tagesimpuls aktiv · 1 Impuls pro Tag.'),
        findsOneWidget,
      );
      final realTestButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('real_tagesimpuls_10s_test_button')),
      );
      expect(realTestButton.onPressed, isNotNull);
      expect(fakeClient.requests, isEmpty);
      expect(fakeScheduler.scheduled, isEmpty);
    },
  );

  testWidgets('removing below three updates not enough status immediately', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient();
    final fakeScheduler = _FakeNotificationScheduler();

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
    );

    expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CourseScreen)),
      listen: false,
    );
    await container
        .read(tagesimpulsSelectionControllerProvider.notifier)
        .remove(_item('word-3', 'destroyed'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Füge mindestens 3 Wörter hinzu.'), findsOneWidget);
    expect(fakeClient.requests, isEmpty);
    expect(fakeScheduler.scheduled, isEmpty);
  });

  testWidgets(
    'changing a setting generates internally and plans one notification',
    (tester) async {
      final fakeClient = _FakeTagesimpulsAiClient(
        impulses: const [
          TagesimpulsGeneratedImpulse(
            slot: 'morning',
            message: 'I moved like a superstar.',
            usedWords: ['move', 'superstar'],
          ),
        ],
      );
      final fakeScheduler = _FakeNotificationScheduler();

      await _pumpCourseScreen(
        tester,
        initialItems: _threeItems(),
        fakeClient: fakeClient,
        fakeScheduler: fakeScheduler,
      );

      await tester.ensureVisible(
        find.byKey(const Key('tagesimpuls-window-morning')),
      );
      await tester.tap(find.byKey(const Key('tagesimpuls-window-morning')));
      await tester.pump();
      await tester.pump();

      expect(fakeClient.requests, hasLength(1));
      expect(fakeClient.requests.single.count, 1);
      expect(fakeScheduler.scheduled, hasLength(1));
      expect(
        find.textContaining(RegExp(r'Nächster Impuls: .* um \d\d:\d\d Uhr\.')),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Impuls-Vorschau'), findsNothing);
      expect(find.text('I moved like a superstar.'), findsNothing);
    },
  );

  testWidgets('planning stores generated impulse in inbox', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_tagesimpuls_planning_inbox',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final fakeClient = _FakeTagesimpulsAiClient(
      impulses: const [
        TagesimpulsGeneratedImpulse(
          slot: 'morning',
          message: 'I moved like a superstar.',
          usedWords: ['move', 'superstar'],
        ),
      ],
    );
    final fakeScheduler = _FakeNotificationScheduler();

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
      inboxRepository: repository,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-morning')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-morning')));
    await tester.pump();
    await tester.pump();

    final chats = await repository.listChats();
    final messages = await repository.listMessages(chats.single.id);
    expect(chats.single.title, 'Tagesimpuls');
    expect(chats.single.unreadCount, 1);
    expect(messages.single.text, 'I moved like a superstar.');
    expect(fakeScheduler.scheduled.single.body, 'I moved like a superstar.');
    final payloadTarget = ImpulseInboxNotificationPayload.parse(
      fakeScheduler.scheduled.single.payload,
    );
    expect(payloadTarget?.chatId, chats.single.id);
    expect(payloadTarget?.messageId, messages.single.id);
    await expectLater(
      fakeScheduler.pendingNotificationIds(),
      completion(hasLength(1)),
    );
  });

  testWidgets(
    'real Tagesimpuls test in ten seconds uses AI and stores inbox message',
    (tester) async {
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_tagesimpuls_real_test_inbox',
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final fakeClient = _FakeTagesimpulsAiClient(
        impulses: const [
          TagesimpulsGeneratedImpulse(
            slot: 'morning',
            message: 'Your real impulse is ready.',
            usedWords: ['move', 'superstar'],
          ),
        ],
      );
      final fakeScheduler = _FakeNotificationScheduler();

      await _pumpCourseScreen(
        tester,
        initialItems: _threeItems(),
        fakeClient: fakeClient,
        fakeScheduler: fakeScheduler,
        inboxRepository: repository,
      );

      await tester.ensureVisible(
        find.byKey(const Key('real_tagesimpuls_10s_test_button')),
      );
      await tester.tap(
        find.byKey(const Key('real_tagesimpuls_10s_test_button')),
      );
      await tester.pump();
      await tester.pump();

      expect(fakeClient.requests, hasLength(1));
      expect(fakeClient.requests.single.count, 1);
      final chats = await repository.listChats();
      final messages = await repository.listMessages(chats.single.id);
      expect(messages.single.text, 'Your real impulse is ready.');
      expect(fakeScheduler.scheduled, hasLength(1));
      expect(
        fakeScheduler.scheduled.single.id,
        TagesimpulsNotificationIds.realTest,
      );
      expect(
        fakeScheduler.scheduled.single.body,
        'Your real impulse is ready.',
      );
      final payloadTarget = ImpulseInboxNotificationPayload.parse(
        fakeScheduler.scheduled.single.payload,
      );
      expect(payloadTarget?.chatId, chats.single.id);
      expect(payloadTarget?.messageId, messages.single.id);
      expect(find.text('Tagesimpuls-Test geplant.'), findsOneWidget);
    },
  );

  testWidgets('real Tagesimpuls test is not replaced by regular replanning', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient(
      impulses: const [
        TagesimpulsGeneratedImpulse(
          slot: 'morning',
          message: 'Your real impulse is ready.',
          usedWords: ['move', 'superstar'],
        ),
      ],
    );
    final fakeScheduler = _FakeNotificationScheduler();

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
    );

    await tester.ensureVisible(
      find.byKey(const Key('real_tagesimpuls_10s_test_button')),
    );
    await tester.tap(find.byKey(const Key('real_tagesimpuls_10s_test_button')));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(fakeClient.requests, hasLength(1));
    expect(fakeScheduler.scheduled.map((notification) => notification.id), [
      TagesimpulsNotificationIds.realTest,
    ]);
    expect(fakeScheduler.cancelledIds, isEmpty);
    expect(find.text('Tagesimpuls-Test geplant.'), findsOneWidget);
  });

  testWidgets('real Tagesimpuls test shows immediate preparing status', (
    tester,
  ) async {
    final completer = Completer<TagesimpulsGenerateResult>();
    final fakeClient = _FakeTagesimpulsAiClient(resultCompleter: completer);
    final fakeScheduler = _FakeNotificationScheduler();

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
    );

    await tester.ensureVisible(
      find.byKey(const Key('real_tagesimpuls_10s_test_button')),
    );
    await tester.tap(find.byKey(const Key('real_tagesimpuls_10s_test_button')));
    await tester.pump();

    expect(find.text('Tagesimpuls-Test wird vorbereitet...'), findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.byKey(const Key('real_tagesimpuls_10s_test_button')),
    );
    expect(button.onPressed, isNull);
    expect(fakeClient.requests, hasLength(1));
    expect(fakeScheduler.scheduled, isEmpty);

    completer.complete(
      const TagesimpulsGenerateResult(
        impulses: [
          TagesimpulsGeneratedImpulse(
            slot: 'morning',
            message: 'Delayed impulse.',
            usedWords: ['move'],
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Tagesimpuls-Test geplant.'), findsOneWidget);
    expect(fakeScheduler.scheduled, hasLength(1));
  });

  testWidgets('real Tagesimpuls test maps AI failure to concrete status', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient(
      errorCode: 'functionCallFailed',
    );

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
    );

    await tester.ensureVisible(
      find.byKey(const Key('real_tagesimpuls_10s_test_button')),
    );
    await tester.tap(find.byKey(const Key('real_tagesimpuls_10s_test_button')));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Tagesimpulse konnten nicht erzeugt werden.'),
      findsOneWidget,
    );
  });

  testWidgets('real Tagesimpuls test maps inbox failure to concrete status', (
    tester,
  ) async {
    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      inboxRepository: _ThrowingImpulseInboxRepository(),
    );

    await tester.ensureVisible(
      find.byKey(const Key('real_tagesimpuls_10s_test_button')),
    );
    await tester.tap(find.byKey(const Key('real_tagesimpuls_10s_test_button')));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Impuls konnte nicht im Postfach gespeichert werden.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'real Tagesimpuls test maps notification failure to concrete status',
    (tester) async {
      final fakeScheduler = _FakeNotificationScheduler(throwOnSchedule: true);

      await _pumpCourseScreen(
        tester,
        initialItems: _threeItems(),
        fakeScheduler: fakeScheduler,
      );

      await tester.ensureVisible(
        find.byKey(const Key('real_tagesimpuls_10s_test_button')),
      );
      await tester.tap(
        find.byKey(const Key('real_tagesimpuls_10s_test_button')),
      );
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Benachrichtigung konnte nicht geplant werden.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('real Tagesimpuls test uses words added after screen opened', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_tagesimpuls_real_test_live_selection_inbox',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final fakeClient = _FakeTagesimpulsAiClient(
      impulses: const [
        TagesimpulsGeneratedImpulse(
          slot: 'morning',
          message: 'Live selected words worked.',
          usedWords: ['move', 'superstar', 'destroyed'],
        ),
      ],
    );
    final fakeScheduler = _FakeNotificationScheduler();

    await _pumpCourseScreen(
      tester,
      initialItems: [_item('word-1', 'move'), _item('word-2', 'superstar')],
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
      inboxRepository: repository,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CourseScreen)),
      listen: false,
    );
    await container
        .read(tagesimpulsSelectionControllerProvider.notifier)
        .add(_item('word-3', 'destroyed'));
    await tester.pump();
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const Key('real_tagesimpuls_10s_test_button')),
    );
    await tester.tap(find.byKey(const Key('real_tagesimpuls_10s_test_button')));
    await tester.pump();
    await tester.pump();

    expect(fakeClient.requests, hasLength(1));
    expect(fakeClient.requests.single.words.map((word) => word.word), [
      'move',
      'superstar',
      'destroyed',
    ]);
    expect(fakeScheduler.scheduled, hasLength(1));
    expect(fakeScheduler.scheduled.single.body, 'Live selected words worked.');
    expect(find.text('Tagesimpuls-Test geplant.'), findsOneWidget);
  });

  testWidgets('Aus disables Tagesimpuls and cancels scheduled notifications', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient();
    final fakeScheduler = _FakeNotificationScheduler();

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
    );

    await tester.tap(find.byKey(const Key('tagesimpuls-mode-off')));
    await tester.pump();
    await tester.pump();

    expect(fakeClient.requests, isEmpty);
    expect(fakeScheduler.cancelCalls, 0);
    expect(fakeScheduler.scheduled, isEmpty);
    expect(find.text('Tagesimpuls ist ausgeschaltet.'), findsWidgets);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('selection three plans three notifications by explicit choice', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient(
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
    );
    final fakeScheduler = _FakeNotificationScheduler();

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
    );

    await tester.tap(find.byKey(const Key('tagesimpuls-frequency-3')));
    await tester.pump();
    await tester.pump();

    expect(fakeClient.requests.single.count, 3);
    expect(fakeScheduler.scheduled, hasLength(3));
    expect(
      find.textContaining(RegExp(r'(Geplant|geplant): .* · .* ·')),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('permission denial is shown as calm status on setting change', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient();
    final fakeScheduler = _FakeNotificationScheduler(
      permissionStatus: TagesimpulsNotificationPermissionStatus.denied,
    );

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-afternoon')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-afternoon')));
    await tester.pump();
    await tester.pump();

    expect(fakeScheduler.scheduled, isEmpty);
    expect(find.text('Benachrichtigungen sind nicht erlaubt.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('selected words stay visible and removable', (tester) async {
    await _pumpCourseScreen(tester, initialItems: _threeItems());

    expect(find.text('move'), findsOneWidget);
    final chip = tester.widget<Chip>(find.widgetWithText(Chip, 'move'));
    expect(chip.onDeleted, isNotNull);
  });

  testWidgets('planning error is shown clearly', (tester) async {
    final fakeClient = _FakeTagesimpulsAiClient(impulses: const []);

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-evening')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-evening')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Es wurden keine Tagesimpulse erzeugt.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('function call failure is shown concretely', (tester) async {
    final fakeClient = _FakeTagesimpulsAiClient(
      errorCode: 'functionCallFailed',
    );

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-evening')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-evening')));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Tagesimpulse konnten nicht erzeugt werden.'),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('words required is shown as payload preparation problem', (
    tester,
  ) async {
    final fakeClient = _FakeTagesimpulsAiClient(errorCode: 'wordsRequired');

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-evening')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-evening')));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Tagesimpuls-Wörter konnten nicht vorbereitet werden.'),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('quota exceeded is shown concretely', (tester) async {
    final fakeClient = _FakeTagesimpulsAiClient(errorCode: 'quotaExceeded');

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-evening')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-evening')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Tagesimpuls-Limit erreicht.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('invalid AI response is shown concretely', (tester) async {
    final fakeClient = _FakeTagesimpulsAiClient(errorCode: 'invalidAiResponse');

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-evening')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-evening')));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('KI-Antwort konnte nicht verarbeitet werden.'),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('platform scheduling error is shown as concrete status', (
    tester,
  ) async {
    final fakeScheduler = _FakeNotificationScheduler(throwOnSchedule: true);

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeScheduler: fakeScheduler,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-evening')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-evening')));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Benachrichtigungen konnten vom System nicht geplant werden.'),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('pending count zero after scheduling corrects status', (
    tester,
  ) async {
    final fakeScheduler = _FakeNotificationScheduler(
      pendingIdsOverride: const [],
    );

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeScheduler: fakeScheduler,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-window-morning')),
    );
    await tester.tap(find.byKey(const Key('tagesimpuls-window-morning')));
    await tester.pump();
    await tester.pump();

    expect(fakeScheduler.scheduled, hasLength(1));
    expect(
      find.text('Benachrichtigungen wurden nicht registriert.'),
      findsOneWidget,
    );
    expect(
      find.textContaining(RegExp(r'Nächster Impuls: .* um \d\d:\d\d Uhr\.')),
      findsNothing,
    );
  });

  testWidgets('debug test notification plans without AI', (tester) async {
    final fakeClient = _FakeTagesimpulsAiClient();
    final fakeScheduler = _FakeNotificationScheduler();

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      fakeClient: fakeClient,
      fakeScheduler: fakeScheduler,
    );

    await tester.ensureVisible(
      find.byKey(const Key('tagesimpuls-test-notification')),
    );
    expect(find.text('Test in 10 Sekunden'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tagesimpuls-test-notification')));
    await tester.pump();
    await tester.pump();

    expect(fakeClient.requests, isEmpty);
    expect(fakeScheduler.scheduled, hasLength(1));
    expect(fakeScheduler.scheduled.single.title, 'Talvori Test');
    expect(find.text('Test-Benachrichtigung geplant.'), findsWidgets);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('activating automatic updates status without snackbar', (
    tester,
  ) async {
    final settingsRepository = _MemorySettingsRepository(
      const TagesimpulsNotificationSettings(enabled: false),
    );

    await _pumpCourseScreen(
      tester,
      initialItems: _threeItems(),
      settingsRepository: settingsRepository,
    );

    await tester.tap(find.byKey(const Key('tagesimpuls-mode-automatic')));
    await tester.pump();
    await tester.pump();

    expect(settingsRepository.settings.enabled, isTrue);
    expect(
      find.textContaining(RegExp(r'Nächster Impuls: .* um \d\d:\d\d Uhr\.')),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
  });
}

Future<void> _pumpCourseScreen(
  WidgetTester tester, {
  List<TagesimpulsSelectionItem> initialItems = const [],
  _FakeTagesimpulsAiClient? fakeClient,
  _FakeNotificationScheduler? fakeScheduler,
  _MemorySettingsRepository? settingsRepository,
  ImpulseInboxRepository? inboxRepository,
}) async {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tagesimpulsSelectionRepositoryProvider.overrideWithValue(
          _MemoryTagesimpulsRepository(initialItems),
        ),
        tagesimpulsAiClientProvider.overrideWithValue(
          fakeClient ?? _FakeTagesimpulsAiClient(),
        ),
        tagesimpulsNotificationSchedulerProvider.overrideWithValue(
          fakeScheduler ?? _FakeNotificationScheduler(),
        ),
        tagesimpulsNotificationSettingsRepositoryProvider.overrideWithValue(
          settingsRepository ?? _MemorySettingsRepository(),
        ),
        impulseInboxRepositoryProvider.overrideWithValue(
          inboxRepository ??
              SharedPreferencesImpulseInboxRepository(
                storageKey: 'test_tagesimpuls_message_screen_inbox',
              ),
        ),
      ],
      child: const MaterialApp(home: CourseScreen()),
    ),
  );
  await tester.pump();
}

List<TagesimpulsSelectionItem> _threeItems() {
  return [
    _item('word-1', 'move'),
    _item('word-2', 'superstar'),
    _item('word-3', 'destroyed'),
  ];
}

TagesimpulsSelectionItem _item(String wordId, String text) {
  return TagesimpulsSelectionItem(
    wordId: wordId,
    text: text,
    addedAt: DateTime.utc(2026, 5, 19),
  );
}

class _MemoryTagesimpulsRepository implements TagesimpulsSelectionRepository {
  _MemoryTagesimpulsRepository([
    List<TagesimpulsSelectionItem> initial = const [],
  ]) : _items = List<TagesimpulsSelectionItem>.of(initial);

  List<TagesimpulsSelectionItem> _items;

  @override
  Future<List<TagesimpulsSelectionItem>> loadItems() async {
    return List<TagesimpulsSelectionItem>.of(_items);
  }

  @override
  Future<void> saveItems(List<TagesimpulsSelectionItem> items) async {
    _items = List<TagesimpulsSelectionItem>.of(items);
  }

  @override
  Future<void> clear() async {
    _items = const [];
  }
}

class _ThrowingImpulseInboxRepository implements ImpulseInboxRepository {
  @override
  Future<ImpulseChat> ensureDailyImpulseChat() {
    throw StateError('inbox failed');
  }

  @override
  Future<ImpulseChat> ensureCategoryChat(String categoryId, String title) {
    throw StateError('inbox failed');
  }

  @override
  Future<ImpulseChat> createCustomAiChat(String title) {
    throw StateError('inbox failed');
  }

  @override
  Future<ImpulseChat?> getCategoryChat(String categoryId) async => null;

  @override
  Future<void> setCategoryChatEnabled(String categoryId, bool enabled) async {}

  @override
  Future<void> setChatEnabled(String chatId, bool enabled) async {}

  @override
  Future<void> updateChatAvatarImagePath(
    String chatId,
    String? imagePath,
  ) async {}

  @override
  Future<List<ImpulseMessage>> addDailyImpulseMessages(
    List<TagesimpulsGeneratedImpulse> impulses,
  ) {
    throw StateError('inbox failed');
  }

  @override
  Future<ImpulseMessage> addMessage(
    ImpulseMessage message, {
    bool incrementUnread = true,
  }) {
    throw StateError('inbox failed');
  }

  @override
  Future<void> clearChat(String chatId) async {}

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {}

  @override
  Future<void> deleteCustomAiChat(String chatId) async {}

  @override
  Future<void> updateMessagePinned(
    String chatId,
    String messageId, {
    required bool isPinned,
  }) async {}

  @override
  Future<void> updateMessageReaction(
    String chatId,
    String messageId,
    String? reaction,
  ) async {}

  @override
  Future<void> updateMessageStarred(
    String chatId,
    String messageId, {
    required bool isStarred,
  }) async {}

  @override
  Future<List<ImpulseChat>> listChats() async => const [];

  @override
  Future<List<ImpulseChat>> listAllChats() async => const [];

  @override
  Future<List<ImpulseChat>> listHiddenChats() async => const [];

  @override
  Future<List<ImpulseSavedMessage>> listStarredMessages() async => const [];

  @override
  Future<ImpulseAiProfile> loadAiProfile() async => ImpulseAiProfile.defaults;

  @override
  Future<void> saveAiProfile(ImpulseAiProfile profile) async {}

  @override
  Future<List<ImpulseMessage>> listMessages(String chatId) async => const [];

  @override
  Future<void> markChatRead(String chatId) async {}
}

class _MemorySettingsRepository
    implements TagesimpulsNotificationSettingsRepository {
  _MemorySettingsRepository([
    this.settings = const TagesimpulsNotificationSettings(),
  ]);

  TagesimpulsNotificationSettings settings;

  @override
  Future<TagesimpulsNotificationSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(TagesimpulsNotificationSettings settings) async {
    this.settings = settings;
  }
}

class _FakeTagesimpulsAiClient implements TagesimpulsAiClient {
  _FakeTagesimpulsAiClient({
    this.impulses = const [
      TagesimpulsGeneratedImpulse(
        slot: 'day',
        message: 'Antwort',
        usedWords: ['word'],
      ),
    ],
    this.errorCode,
    this.resultCompleter,
  });

  final List<TagesimpulsGeneratedImpulse> impulses;
  final String? errorCode;
  final Completer<TagesimpulsGenerateResult>? resultCompleter;
  final List<TagesimpulsGenerateRequest> requests = [];

  @override
  Future<TagesimpulsGenerateResult> generate(
    TagesimpulsGenerateRequest request,
  ) async {
    requests.add(request);
    if (errorCode != null) {
      throw TagesimpulsAiException(errorCode!);
    }
    final completer = resultCompleter;
    if (completer != null) {
      return completer.future;
    }
    return TagesimpulsGenerateResult(impulses: impulses);
  }
}

class _FakeNotificationScheduler implements TagesimpulsNotificationScheduler {
  _FakeNotificationScheduler({
    this.permissionStatus = TagesimpulsNotificationPermissionStatus.granted,
    this.throwOnSchedule = false,
    this.pendingIdsOverride,
  });

  final TagesimpulsNotificationPermissionStatus permissionStatus;
  final bool throwOnSchedule;
  final List<int>? pendingIdsOverride;
  final scheduled = <TagesimpulsNotificationSchedule>[];
  int cancelCalls = 0;
  final cancelledIds = <int>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<TagesimpulsNotificationPermissionStatus> requestPermission() async {
    return permissionStatus;
  }

  @override
  Future<void> schedule(TagesimpulsNotificationSchedule notification) async {
    if (throwOnSchedule) throw StateError('schedule failed');
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
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    scheduled.removeWhere((notification) => notification.id == id);
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
    scheduled.clear();
  }
}
