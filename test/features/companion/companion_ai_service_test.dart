import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/features/companion/application/companion_ai_service.dart';
import 'package:talvori/features/companion/domain/companion_ai_context.dart';

void main() {
  test('uses the injected AI chat client and passes compact context', () async {
    AiChatRequest? capturedRequest;
    final service = CompanionAiService(
      aiChatClient: _FakeAiChatClient((request) async {
        capturedRequest = request;
        return const AiChatResult(reply: 'Klar. Starte mit drei Wörtern.');
      }),
    );

    final reply = await service.reply(
      message: 'Was soll ich üben?',
      context: const CompanionAiContext(
        myWordsCount: 3,
        lastCompanionMessage: 'Bereit?',
      ),
    );

    expect(reply, 'Klar. Starte mit drei Wörtern.');
    expect(capturedRequest?.message, 'Was soll ich üben?');
    expect(capturedRequest?.language, 'DE');
    expect(capturedRequest?.context, isA<Map<String, Object?>>());
  });

  test('falls back locally when AI is unavailable', () async {
    final service = CompanionAiService(
      aiChatClient: _FakeAiChatClient((request) {
        throw const AiChatException('ai_not_configured');
      }),
    );

    final reply = await service.reply(
      message: 'Ich will Wörter üben',
      context: const CompanionAiContext(myWordsCount: 0),
    );

    expect(reply, contains('Speichere ein Wort'));
  });
}

class _FakeAiChatClient implements AiChatClient {
  const _FakeAiChatClient(this._handler);

  final Future<AiChatResult> Function(AiChatRequest request) _handler;

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) => _handler(request);
}
