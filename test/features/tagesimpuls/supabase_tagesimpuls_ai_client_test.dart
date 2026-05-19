import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/tagesimpuls/ai/supabase_tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

void main() {
  group('SupabaseTagesimpulsAiClient', () {
    test('sends words count language and style', () async {
      final calls = <Map<String, Object?>>[];
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (functionName, payload) async {
          calls.add({'functionName': functionName, ...payload});
          return {
            'impulses': [
              {
                'slot': 'morning',
                'message': 'You moved like a superstar.',
                'usedWords': ['move', 'superstar'],
              },
            ],
          };
        },
      );

      final result = await client.generate(
        const TagesimpulsGenerateRequest(
          words: [
            TagesimpulsGenerateWord(word: 'move', translation: 'bewegen'),
            TagesimpulsGenerateWord(word: 'superstar'),
          ],
          count: 3,
          language: 'EN',
          style: 'natural_message',
        ),
      );

      expect(calls, hasLength(1));
      expect(calls.single['functionName'], 'generate-daily-impulses');
      expect(calls.single['count'], 3);
      expect(calls.single['language'], 'EN');
      expect(calls.single['style'], 'natural_message');
      expect(calls.single['words'], [
        {'word': 'move', 'translation': 'bewegen'},
        {'word': 'superstar'},
      ]);
      expect(result.impulses.single.slot, 'morning');
      expect(result.impulses.single.message, 'You moved like a superstar.');
      expect(result.impulses.single.usedWords, ['move', 'superstar']);
    });

    test('handles quota exceeded', () async {
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async => {'error': 'quota_exceeded'},
      );

      await expectLater(
        client.generate(_request()),
        throwsA(
          isA<TagesimpulsAiException>().having(
            (error) => error.code,
            'code',
            'quota_exceeded',
          ),
        ),
      );
    });

    test('handles invalid AI response', () async {
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async => {'impulses': []},
      );

      await expectLater(
        client.generate(_request()),
        throwsA(
          isA<TagesimpulsAiException>().having(
            (error) => error.code,
            'code',
            'ai_invalid_response',
          ),
        ),
      );
    });

    test('rejects invalid count without network call', () async {
      var called = false;
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async {
          called = true;
          return {};
        },
      );

      await expectLater(
        client.generate(
          const TagesimpulsGenerateRequest(
            words: [TagesimpulsGenerateWord(word: 'move')],
            count: 6,
          ),
        ),
        throwsA(isA<TagesimpulsAiException>()),
      );
      expect(called, isFalse);
    });
  });
}

TagesimpulsGenerateRequest _request() {
  return const TagesimpulsGenerateRequest(
    words: [TagesimpulsGenerateWord(word: 'move')],
  );
}
