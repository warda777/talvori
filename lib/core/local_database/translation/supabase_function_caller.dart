import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_translation_client.dart';
import 'translation_client.dart';

typedef SupabaseRawFunctionInvoker =
    Future<Object?> Function(String functionName, Map<String, Object?> payload);

class SupabaseEdgeFunctionCaller {
  SupabaseEdgeFunctionCaller({required SupabaseClient client})
    : _invoke = ((functionName, payload) async {
        final response = await client.functions.invoke(
          functionName,
          body: payload,
        );
        return response.data;
      });

  const SupabaseEdgeFunctionCaller.withInvoker(
    SupabaseRawFunctionInvoker invoker,
  ) : _invoke = invoker;

  final SupabaseRawFunctionInvoker _invoke;

  Future<Map<String, Object?>> call(
    String functionName,
    Map<String, Object?> payload,
  ) async {
    final Object? data;
    try {
      data = await _invoke(functionName, payload);
    } on Object catch (error) {
      throw TranslationException('Supabase function call failed: $error');
    }

    if (data is Map<String, Object?>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }

    throw const TranslationException(
      'Supabase function response has invalid shape.',
    );
  }
}

SupabaseFunctionCaller supabaseFunctionCallerFromClient(SupabaseClient client) {
  return SupabaseEdgeFunctionCaller(client: client).call;
}
