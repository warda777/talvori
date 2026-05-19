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

void main() {
  testWidgets('shows hint when fewer than three words are selected', (
    tester,
  ) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
    ]);
    final fakeClient = _FakeTagesimpulsAiClient();
    final fakeScheduler = _FakeNotificationScheduler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
          tagesimpulsAiClientProvider.overrideWithValue(fakeClient),
          tagesimpulsNotificationSchedulerProvider.overrideWithValue(
            fakeScheduler,
          ),
        ],
        child: const MaterialApp(home: CourseScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tagesimpulse vorbereiten'));
    await tester.pump();

    expect(
      find.text('Wähle mindestens 3 Wörter für einen manuellen Tagesimpuls.'),
      findsOneWidget,
    );
    expect(fakeClient.requests, isEmpty);
  });

  testWidgets('generates and shows Tagesimpuls impulses for three words', (
    tester,
  ) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
      _item('word-3', 'destroyed'),
    ]);
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
          tagesimpulsAiClientProvider.overrideWithValue(fakeClient),
          tagesimpulsNotificationSchedulerProvider.overrideWithValue(
            fakeScheduler,
          ),
        ],
        child: const MaterialApp(home: CourseScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tagesimpulse vorbereiten'));
    await tester.pump();
    await tester.pump();

    expect(fakeClient.requests, hasLength(1));
    expect(fakeClient.requests.single.count, 1);
    expect(fakeClient.requests.single.language, 'EN');
    expect(fakeClient.requests.single.style, 'natural_message');
    expect(fakeClient.requests.single.words.map((word) => word.word), [
      'move',
      'superstar',
      'destroyed',
    ]);
    expect(find.text('Impuls-Vorschau'), findsOneWidget);
    expect(find.text('Morgens'), findsOneWidget);
    expect(find.text('I moved like a superstar.'), findsOneWidget);
    expect(find.text('move'), findsWidgets);
    expect(find.text('Benachrichtigungen planen'), findsOneWidget);
    expect(fakeScheduler.scheduled, isEmpty);
  });

  testWidgets('shows mapped error when AI request fails', (tester) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
      _item('word-3', 'destroyed'),
    ]);
    final fakeClient = _FakeTagesimpulsAiClient(
      error: const TagesimpulsAiException('quota_exceeded'),
    );
    final fakeScheduler = _FakeNotificationScheduler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
          tagesimpulsAiClientProvider.overrideWithValue(fakeClient),
          tagesimpulsNotificationSchedulerProvider.overrideWithValue(
            fakeScheduler,
          ),
        ],
        child: const MaterialApp(home: CourseScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tagesimpulse vorbereiten'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Limit erreicht oder Anbieter begrenzt Anfrage.'),
      findsOneWidget,
    );
  });

  testWidgets('lets the user consciously select multiple daily impulses', (
    tester,
  ) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
      _item('word-3', 'destroyed'),
    ]);
    final fakeClient = _FakeTagesimpulsAiClient();
    final fakeScheduler = _FakeNotificationScheduler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
          tagesimpulsAiClientProvider.overrideWithValue(fakeClient),
          tagesimpulsNotificationSchedulerProvider.overrideWithValue(
            fakeScheduler,
          ),
        ],
        child: const MaterialApp(home: CourseScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.tap(find.text('Tagesimpulse vorbereiten'));
    await tester.pump();
    await tester.pump();

    expect(fakeClient.requests.single.count, 3);
  });

  testWidgets('plans notifications only after explicit user action', (
    tester,
  ) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
      _item('word-3', 'destroyed'),
    ]);
    final fakeClient = _FakeTagesimpulsAiClient(
      impulses: const [
        TagesimpulsGeneratedImpulse(
          slot: 'morning',
          message: 'I moved like a superstar.',
          usedWords: ['move'],
        ),
      ],
    );
    final fakeScheduler = _FakeNotificationScheduler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
          tagesimpulsAiClientProvider.overrideWithValue(fakeClient),
          tagesimpulsNotificationSchedulerProvider.overrideWithValue(
            fakeScheduler,
          ),
        ],
        child: const MaterialApp(home: CourseScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tagesimpulse vorbereiten'));
    await tester.pump();
    await tester.pump();

    expect(fakeScheduler.scheduled, isEmpty);

    await tester.ensureVisible(find.text('Benachrichtigungen planen'));
    await tester.pump();
    await tester.tap(find.text('Benachrichtigungen planen'));
    await tester.pump();
    await tester.pump();

    expect(fakeScheduler.scheduled, hasLength(1));
    expect(find.text('Tagesimpulse geplant.'), findsOneWidget);
  });

  testWidgets('shows permission warning when notifications are denied', (
    tester,
  ) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
      _item('word-3', 'destroyed'),
    ]);
    final fakeClient = _FakeTagesimpulsAiClient();
    final fakeScheduler = _FakeNotificationScheduler(permissionGranted: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
          tagesimpulsAiClientProvider.overrideWithValue(fakeClient),
          tagesimpulsNotificationSchedulerProvider.overrideWithValue(
            fakeScheduler,
          ),
        ],
        child: const MaterialApp(home: CourseScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tagesimpulse vorbereiten'));
    await tester.pump();
    await tester.pump();
    await tester.ensureVisible(find.text('Benachrichtigungen planen'));
    await tester.pump();
    await tester.tap(find.text('Benachrichtigungen planen'));
    await tester.pump();
    await tester.pump();

    expect(fakeScheduler.scheduled, isEmpty);
    expect(
      find.text('Benachrichtigungen müssen erlaubt werden.'),
      findsOneWidget,
    );
  });
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

class _FakeTagesimpulsAiClient implements TagesimpulsAiClient {
  _FakeTagesimpulsAiClient({
    this.impulses = const [
      TagesimpulsGeneratedImpulse(
        slot: 'day',
        message: 'Antwort',
        usedWords: ['word'],
      ),
    ],
    this.error,
  });

  final List<TagesimpulsGeneratedImpulse> impulses;
  final TagesimpulsAiException? error;
  final List<TagesimpulsGenerateRequest> requests = [];

  @override
  Future<TagesimpulsGenerateResult> generate(
    TagesimpulsGenerateRequest request,
  ) async {
    requests.add(request);
    final error = this.error;
    if (error != null) throw error;
    return TagesimpulsGenerateResult(impulses: impulses);
  }
}

class _FakeNotificationScheduler implements TagesimpulsNotificationScheduler {
  _FakeNotificationScheduler({this.permissionGranted = true});

  final bool permissionGranted;
  final scheduled = <TagesimpulsNotificationSchedule>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> schedule(TagesimpulsNotificationSchedule notification) async {
    scheduled.add(notification);
  }

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
  }
}
