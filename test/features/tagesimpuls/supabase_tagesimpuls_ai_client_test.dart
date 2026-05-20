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
      final words = calls.single['words']! as List<Object?>;
      expect(
        words.singleWhere((word) => word is Map && word['word'] == 'move'),
        isA<Map>(),
      );
      expect(result.impulses.single.slot, 'morning');
      expect(result.impulses.single.message, 'You moved like a superstar.');
      expect(result.impulses.single.usedWords, ['move', 'superstar']);
    });

    test('normalizes URL and newline leftovers before sending words', () async {
      final calls = <Map<String, Object?>>[];
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (functionName, payload) async {
          calls.add({'functionName': functionName, ...payload});
          return {
            'impulses': [
              {
                'slot': 'day',
                'message': 'Move today.',
                'usedWords': ['move'],
              },
            ],
          };
        },
      );

      await client.generate(
        const TagesimpulsGenerateRequest(
          words: [
            TagesimpulsGenerateWord(
              word: 'move https://www.bbc.com/news/story\nsource text',
            ),
            TagesimpulsGenerateWord(word: 'reefs\nhttps://example.com'),
            TagesimpulsGenerateWord(word: 'serving'),
          ],
        ),
      );

      expect(calls.single['words'], [
        {'word': 'move'},
        {'word': 'reefs'},
        {'word': 'serving'},
      ]);
    });

    test('filters empty words before calling function', () async {
      final calls = <Map<String, Object?>>[];
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (functionName, payload) async {
          calls.add({'functionName': functionName, ...payload});
          return {
            'impulses': [
              {
                'slot': 'day',
                'message': 'Move today.',
                'usedWords': ['move'],
              },
            ],
          };
        },
      );

      await client.generate(
        const TagesimpulsGenerateRequest(
          words: [
            TagesimpulsGenerateWord(word: 'https://example.com'),
            TagesimpulsGenerateWord(word: 'move'),
          ],
        ),
      );

      expect(calls.single['words'], [
        {'word': 'move'},
      ]);
    });

    test('maps words_required to payload preparation diagnosis', () async {
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async => {'error': 'words_required'},
      );

      await expectLater(
        client.generate(_request()),
        throwsA(
          isA<TagesimpulsAiException>().having(
            (error) => error.code,
            'code',
            'wordsRequired',
          ),
        ),
      );
    });

    test(
      'rejects words that normalize to empty without network call',
      () async {
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
              words: [TagesimpulsGenerateWord(word: 'https://example.com')],
            ),
          ),
          throwsA(
            isA<TagesimpulsAiException>().having(
              (error) => error.code,
              'code',
              'wordsRequired',
            ),
          ),
        );
        expect(called, isFalse);
      },
    );

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
            'quotaExceeded',
          ),
        ),
      );
    });

    test('handles invalid AI response', () async {
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async => {'impulses': 'nope'},
      );

      await expectLater(
        client.generate(_request()),
        throwsA(
          isA<TagesimpulsAiException>().having(
            (error) => error.code,
            'code',
            'invalidAiResponse',
          ),
        ),
      );
    });

    test('handles empty impulse list separately', () async {
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async => {'impulses': []},
      );

      await expectLater(
        client.generate(_request()),
        throwsA(
          isA<TagesimpulsAiException>().having(
            (error) => error.code,
            'code',
            'noImpulsesReturned',
          ),
        ),
      );
    });

    test('handles function call failure', () async {
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async => throw StateError('network failed'),
      );

      await expectLater(
        client.generate(_request()),
        throwsA(
          isA<TagesimpulsAiException>().having(
            (error) => error.code,
            'code',
            'functionCallFailed',
          ),
        ),
      );
    });

    test('maps ai_not_configured to client diagnosis', () async {
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async => {'error': 'ai_not_configured'},
      );

      await expectLater(
        client.generate(_request()),
        throwsA(
          isA<TagesimpulsAiException>().having(
            (error) => error.code,
            'code',
            'aiClientNotConfigured',
          ),
        ),
      );
    });

    test('parses impulse without usedWords', () async {
      final client = SupabaseTagesimpulsAiClient(
        functionCaller: (_, _) async => {
          'impulses': [
            {'slot': 'morning', 'message': 'Good morning.'},
          ],
        },
      );

      final result = await client.generate(_request());

      expect(result.impulses.single.message, 'Good morning.');
      expect(result.impulses.single.usedWords, isEmpty);
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
