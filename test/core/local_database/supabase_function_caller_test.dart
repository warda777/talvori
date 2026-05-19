import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/translation/supabase_function_caller.dart';
import 'package:talvori/core/local_database/translation/translation_client.dart';

void main() {
  group('SupabaseEdgeFunctionCaller', () {
    test('returns_map_response_from_invoker', () async {
      String? capturedFunctionName;
      Map<String, Object?>? capturedPayload;
      final caller = SupabaseEdgeFunctionCaller.withInvoker((
        functionName,
        payload,
      ) async {
        capturedFunctionName = functionName;
        capturedPayload = payload;
        return {'translation': 'Haus'};
      });

      final response = await caller.call('translate-word', {
        'text': 'house',
        'targetLang': 'DE',
      });

      expect(response, {'translation': 'Haus'});
      expect(capturedFunctionName, 'translate-word');
      expect(capturedPayload, {'text': 'house', 'targetLang': 'DE'});
    });

    test('normalizes_dynamic_map_keys_to_strings', () async {
      final caller = SupabaseEdgeFunctionCaller.withInvoker((
        functionName,
        payload,
      ) async {
        return {1: 'one', 'translation': 'Haus'};
      });

      final response = await caller.call('translate-word', {
        'text': 'house',
        'targetLang': 'DE',
      });

      expect(response, {'1': 'one', 'translation': 'Haus'});
    });

    test('throws_translation_exception_for_invalid_response', () async {
      final caller = SupabaseEdgeFunctionCaller.withInvoker((
        functionName,
        payload,
      ) async {
        return 'not a map';
      });

      expect(
        () => caller.call('translate-word', {'text': 'house'}),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('invalid shape'),
          ),
        ),
      );
    });

    test('wraps_function_errors', () async {
      final caller = SupabaseEdgeFunctionCaller.withInvoker((
        functionName,
        payload,
      ) async {
        throw const SocketException('offline');
      });

      expect(
        () => caller.call('translate-word', {'text': 'house'}),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('Supabase function call failed'),
          ),
        ),
      );
    });
  });
}
