import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/ai/supabase_ai_chat_client.dart';

void main() {
  group('SupabaseAiChatClient', () {
    test('sends_message_context_and_language', () async {
      String? capturedFunctionName;
      Map<String, Object?>? capturedPayload;
      final client = SupabaseAiChatClient(
        functionCaller: (functionName, payload) async {
          capturedFunctionName = functionName;
          capturedPayload = payload;
          return {'answer': 'Hallo.'};
        },
      );

      final result = await client.sendMessage(
        const AiChatRequest(
          message: '  Help me practice house.  ',
          context: {'word': 'house'},
          language: 'de',
        ),
      );

      expect(result.reply, 'Hallo.');
      expect(capturedFunctionName, 'ai-chat');
      expect(capturedPayload, {
        'message': 'Help me practice house.',
        'language': 'de',
        'context': {'word': 'house'},
      });
    });

    test('omits_empty_context_and_language', () async {
      Map<String, Object?>? capturedPayload;
      final client = SupabaseAiChatClient(
        functionCaller: (functionName, payload) async {
          capturedPayload = payload;
          return {'answer': 'Sure.'};
        },
      );

      final result = await client.sendMessage(
        const AiChatRequest(message: 'hello', language: ' '),
      );

      expect(result.reply, 'Sure.');
      expect(capturedPayload, {'message': 'hello'});
    });

    test('handles_ai_not_configured_response', () async {
      final client = SupabaseAiChatClient(
        functionCaller: (functionName, payload) async {
          return {'error': 'ai_not_configured'};
        },
      );

      expect(
        () => client.sendMessage(const AiChatRequest(message: 'hello')),
        throwsA(
          isA<AiChatException>().having(
            (error) => error.toString(),
            'message',
            contains('ai_not_configured'),
          ),
        ),
      );
    });

    test('handles_quota_exceeded_response', () async {
      final client = SupabaseAiChatClient(
        functionCaller: (functionName, payload) async {
          return {'error': 'quota_exceeded'};
        },
      );

      expect(
        () => client.sendMessage(const AiChatRequest(message: 'hello')),
        throwsA(
          isA<AiChatException>().having(
            (error) => error.toString(),
            'message',
            contains('quota_exceeded'),
          ),
        ),
      );
    });

    test('handles_ai_request_failed_response', () async {
      final client = SupabaseAiChatClient(
        functionCaller: (functionName, payload) async {
          return {'error': 'ai_request_failed'};
        },
      );

      expect(
        () => client.sendMessage(const AiChatRequest(message: 'hello')),
        throwsA(
          isA<AiChatException>().having(
            (error) => error.toString(),
            'message',
            contains('ai_request_failed'),
          ),
        ),
      );
    });

    test('handles_invalid_response_shape', () async {
      final client = SupabaseAiChatClient(
        functionCaller: (functionName, payload) async {
          return {'answer': ''};
        },
      );

      expect(
        () => client.sendMessage(const AiChatRequest(message: 'hello')),
        throwsA(
          isA<AiChatException>().having(
            (error) => error.toString(),
            'message',
            contains('missing reply'),
          ),
        ),
      );
    });

    test('handles_function_failure', () async {
      final client = SupabaseAiChatClient(
        functionCaller: (functionName, payload) async {
          throw const SocketException('offline');
        },
      );

      expect(
        () => client.sendMessage(const AiChatRequest(message: 'hello')),
        throwsA(
          isA<AiChatException>().having(
            (error) => error.toString(),
            'message',
            contains('Supabase AI chat request failed'),
          ),
        ),
      );
    });

    test('rejects_empty_message', () async {
      final client = SupabaseAiChatClient(
        functionCaller: (functionName, payload) async {
          return {'reply': 'ignored'};
        },
      );

      expect(
        () => client.sendMessage(const AiChatRequest(message: ' ')),
        throwsA(isA<AiChatException>()),
      );
    });
  });
}
