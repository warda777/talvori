import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/tagesimpuls/ai/supabase_tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_message_provider.dart';

void main() {
  group('tagesimpuls message providers', () {
    test('builds Supabase client with injected function caller', () async {
      final calls = <Map<String, Object?>>[];

      Future<Map<String, Object?>> fakeCaller(
        String functionName,
        Map<String, Object?> payload,
      ) async {
        calls.add({'functionName': functionName, ...payload});
        return {
          'impulses': [
            {
              'slot': 'morning',
              'message': 'You moved like a superstar today.',
              'usedWords': ['move', 'superstar'],
            },
          ],
        };
      }

      final container = ProviderContainer(
        overrides: [
          tagesimpulsFunctionCallerProvider.overrideWithValue(fakeCaller),
        ],
      );
      addTearDown(container.dispose);

      final client = container.read(tagesimpulsAiClientProvider);
      expect(client, isA<SupabaseTagesimpulsAiClient>());

      final result = await client.generate(
        const TagesimpulsGenerateRequest(
          words: [
            TagesimpulsGenerateWord(word: 'move', translation: 'bewegen'),
            TagesimpulsGenerateWord(word: 'superstar'),
            TagesimpulsGenerateWord(word: 'destroyed'),
          ],
          count: 1,
          language: 'EN',
          style: 'natural_message',
        ),
      );

      expect(result.impulses.single.message, contains('superstar'));
      expect(calls, hasLength(1));
      expect(calls.single['functionName'], 'generate-daily-impulses');
      expect(calls.single['count'], 1);
      expect(calls.single['language'], 'EN');
      expect(calls.single['style'], 'natural_message');
      expect(calls.single['words'], [
        {'word': 'move', 'translation': 'bewegen'},
        {'word': 'superstar'},
        {'word': 'destroyed'},
      ]);
    });
  });
}
