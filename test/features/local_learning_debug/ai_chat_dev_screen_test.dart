import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/features/local_learning_debug/ui/ai_chat_dev_screen.dart';

void main() {
  group('AiChatDevScreen', () {
    testWidgets('renders_input_and_button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AiChatDevScreen(client: _FakeAiChatClient())),
      );

      expect(find.text('AI Chat Test'), findsOneWidget);
      expect(find.text('Nachricht'), findsOneWidget);
      expect(find.text('Sprache'), findsOneWidget);
      expect(find.text('KI testen'), findsOneWidget);
      expect(find.text('DE'), findsOneWidget);
    });

    testWidgets('sends_message_and_shows_answer', (tester) async {
      final fake = _FakeAiChatClient(reply: 'Haus bedeutet house.');
      await tester.pumpWidget(MaterialApp(home: AiChatDevScreen(client: fake)));

      await tester.enterText(find.byType(TextField).first, 'Erkläre house.');
      await tester.tap(find.text('KI testen'));
      await tester.pump();
      await tester.pump();

      expect(fake.lastRequest?.message, 'Erkläre house.');
      expect(fake.lastRequest?.language, 'DE');
      expect(find.text('Antwort'), findsOneWidget);
      expect(find.text('Haus bedeutet house.'), findsOneWidget);
    });

    testWidgets('shows_mapped_error', (tester) async {
      final fake = _FakeAiChatClient(
        error: const AiChatException(
          'Supabase AI chat failed: ai_not_configured',
        ),
      );
      await tester.pumpWidget(MaterialApp(home: AiChatDevScreen(client: fake)));

      await tester.enterText(find.byType(TextField).first, 'Hallo');
      await tester.tap(find.text('KI testen'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Fehler'), findsOneWidget);
      expect(find.text('KI ist noch nicht konfiguriert.'), findsOneWidget);
    });

    testWidgets('validates_empty_message_without_calling_client', (
      tester,
    ) async {
      final fake = _FakeAiChatClient();
      await tester.pumpWidget(MaterialApp(home: AiChatDevScreen(client: fake)));

      await tester.tap(find.text('KI testen'));
      await tester.pump();

      expect(fake.callCount, 0);
      expect(find.text('Bitte gib eine Nachricht ein.'), findsOneWidget);
    });
  });
}

class _FakeAiChatClient implements AiChatClient {
  _FakeAiChatClient({this.reply = 'Antwort', this.error});

  final String reply;
  final Object? error;
  AiChatRequest? lastRequest;
  int callCount = 0;

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) async {
    callCount += 1;
    lastRequest = request;
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return AiChatResult(reply: reply);
  }
}
