import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_message_controller.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';

void main() {
  group('TagesimpulsMessageController', () {
    test('starts with count 1', () {
      final controller = TagesimpulsMessageController(
        client: _FakeTagesimpulsAiClient(),
      );

      expect(controller.state.count, 1);
      expect(controller.state.impulses, isEmpty);
    });

    test('allows count 1 to 5 and ignores invalid values', () {
      final controller = TagesimpulsMessageController(
        client: _FakeTagesimpulsAiClient(),
      );

      controller.setCount(5);
      expect(controller.state.count, 5);

      controller.setCount(0);
      expect(controller.state.count, 5);

      controller.setCount(1);
      expect(controller.state.count, 1);
    });

    test('does not generate automatically', () {
      final fakeClient = _FakeTagesimpulsAiClient();

      TagesimpulsMessageController(client: fakeClient);

      expect(fakeClient.requests, isEmpty);
    });

    test(
      'requires at least three selected words for manual generation',
      () async {
        final fakeClient = _FakeTagesimpulsAiClient();
        final controller = TagesimpulsMessageController(client: fakeClient);

        await controller.generate([_item('word-1', 'move')]);

        expect(controller.state.error, 'words_required');
        expect(fakeClient.requests, isEmpty);
      },
    );

    test('generates impulses manually', () async {
      final fakeClient = _FakeTagesimpulsAiClient(
        impulses: const [
          TagesimpulsGeneratedImpulse(
            slot: 'morning',
            message: 'You moved like a superstar.',
            usedWords: ['move'],
          ),
        ],
      );
      final controller = TagesimpulsMessageController(client: fakeClient);
      controller.setCount(3);

      await controller.generate([
        _item('word-1', 'move'),
        _item('word-2', 'superstar'),
        _item('word-3', 'destroyed'),
      ]);

      expect(fakeClient.requests, hasLength(1));
      expect(fakeClient.requests.single.count, 3);
      expect(controller.state.error, isNull);
      expect(controller.state.impulses.single.message, contains('superstar'));
    });
  });
}

TagesimpulsSelectionItem _item(String wordId, String text) {
  return TagesimpulsSelectionItem(
    wordId: wordId,
    text: text,
    addedAt: DateTime.utc(2026, 5, 19),
  );
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
  });

  final List<TagesimpulsGeneratedImpulse> impulses;
  final List<TagesimpulsGenerateRequest> requests = [];

  @override
  Future<TagesimpulsGenerateResult> generate(
    TagesimpulsGenerateRequest request,
  ) async {
    requests.add(request);
    return TagesimpulsGenerateResult(impulses: impulses);
  }
}
