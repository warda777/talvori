import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_provider.dart';
import 'package:talvori/features/tagesimpuls/data/tagesimpuls_selection_repository.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';

void main() {
  testWidgets('shows hint when fewer than three words are selected', (
    tester,
  ) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
    ]);
    final fakeClient = _FakeAiChatClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(home: CourseScreen(aiChatClient: fakeClient)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Impuls vorbereiten'));
    await tester.pump();

    expect(find.text('Wähle mindestens 3 Wörter aus.'), findsOneWidget);
    expect(fakeClient.requests, isEmpty);
  });

  testWidgets('generates and shows Tagesimpuls message for three words', (
    tester,
  ) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
      _item('word-3', 'destroyed'),
    ]);
    final fakeClient = _FakeAiChatClient(reply: 'I moved like a superstar.');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(home: CourseScreen(aiChatClient: fakeClient)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Impuls vorbereiten'));
    await tester.pump();
    await tester.pump();

    expect(fakeClient.requests, hasLength(1));
    expect(fakeClient.requests.single.message, contains('move'));
    expect(fakeClient.requests.single.message, contains('superstar'));
    expect(fakeClient.requests.single.message, contains('destroyed'));
    expect(fakeClient.requests.single.message, contains('eine einzelne kurze'));
    final context = fakeClient.requests.single.context;
    expect(context, isA<Map<String, Object?>>());
    expect(
      (context! as Map<String, Object?>)['feature'],
      'tagesimpuls_preview',
    );
    expect(fakeClient.requests.single.language, 'EN');
    expect(find.text('Impuls-Vorschau'), findsOneWidget);
    expect(find.text('I moved like a superstar.'), findsOneWidget);
  });

  testWidgets('shows mapped error when AI request fails', (tester) async {
    final repository = _MemoryTagesimpulsRepository([
      _item('word-1', 'move'),
      _item('word-2', 'superstar'),
      _item('word-3', 'destroyed'),
    ]);
    final fakeClient = _FakeAiChatClient(
      error: const AiChatException('Supabase AI chat failed: quota_exceeded'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagesimpulsSelectionRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(home: CourseScreen(aiChatClient: fakeClient)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Impuls vorbereiten'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Limit erreicht oder Anbieter begrenzt Anfrage.'),
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

class _FakeAiChatClient implements AiChatClient {
  _FakeAiChatClient({this.reply = 'Antwort', this.error});

  final String reply;
  final AiChatException? error;
  final List<AiChatRequest> requests = [];

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) async {
    requests.add(request);
    final error = this.error;
    if (error != null) throw error;
    return AiChatResult(reply: reply);
  }
}
