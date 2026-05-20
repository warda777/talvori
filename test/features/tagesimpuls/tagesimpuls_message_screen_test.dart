import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_message_provider.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_provider.dart';
import 'package:talvori/features/tagesimpuls/data/tagesimpuls_selection_repository.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_models.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_service.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_settings.dart';

void main() {
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
      expect(
        find.text('Tagesimpuls aktiv · 1 Impuls pro Tag.'),
        findsOneWidget,
      );
      expect(find.text('Tagesimpuls speichern'), findsNothing);
      expect(fakeClient.requests, isEmpty);
    },
  );

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
    expect(fakeClient.requests, isEmpty);
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
    expect(fakeScheduler.cancelCalls, 1);
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
    expect(find.textContaining(RegExp(r'Geplant: .* · .* ·')), findsOneWidget);
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
  });

  final List<TagesimpulsGeneratedImpulse> impulses;
  final String? errorCode;
  final List<TagesimpulsGenerateRequest> requests = [];

  @override
  Future<TagesimpulsGenerateResult> generate(
    TagesimpulsGenerateRequest request,
  ) async {
    requests.add(request);
    if (errorCode != null) {
      throw TagesimpulsAiException(errorCode!);
    }
    return TagesimpulsGenerateResult(impulses: impulses);
  }
}

class _FakeNotificationScheduler implements TagesimpulsNotificationScheduler {
  _FakeNotificationScheduler({
    this.permissionStatus = TagesimpulsNotificationPermissionStatus.granted,
    this.throwOnSchedule = false,
  });

  final TagesimpulsNotificationPermissionStatus permissionStatus;
  final bool throwOnSchedule;
  final scheduled = <TagesimpulsNotificationSchedule>[];
  int cancelCalls = 0;

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
  Future<void> cancelAll() async {
    cancelCalls++;
    scheduled.clear();
  }
}
