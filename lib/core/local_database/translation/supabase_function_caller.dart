import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    debugPrint(
      'SupabaseEdgeFunctionCaller call function=$functionName '
      'payloadKeys=${payload.keys.toList()}',
    );

    final Object? data;
    try {
      data = await _invoke(functionName, payload);
    } on FunctionException catch (error) {
      final details = _normalizeFunctionErrorDetails(error.details);
      debugPrint(
        'SupabaseEdgeFunctionCaller function exception '
        'function=$functionName status=${error.status} '
        'reason=${error.reasonPhrase} detailsKeys=${details?.keys.toList()}',
      );
      if (details != null) {
        return details;
      }
      throw TranslationException(
        'Supabase function call failed: '
        '${error.runtimeType} status=${error.status} reason=${error.reasonPhrase}',
      );
    } on Object catch (error) {
      debugPrint(
        'SupabaseEdgeFunctionCaller function call failed '
        'function=$functionName exception=${error.runtimeType} '
        'message=${_safeErrorMessage(error)}',
      );
      throw TranslationException(
        'Supabase function call failed: ${_safeErrorMessage(error)}',
      );
    }

    debugPrint(
      'SupabaseEdgeFunctionCaller response function=$functionName '
      'responseType=${data.runtimeType}',
    );

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

  Map<String, Object?>? _normalizeFunctionErrorDetails(Object? details) {
    if (details is Map<String, Object?>) {
      return details;
    }
    if (details is Map) {
      return details.map((key, value) => MapEntry(key.toString(), value));
    }
    if (details is String && details.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map<String, Object?>) {
          return decoded;
        }
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  String _safeErrorMessage(Object error) {
    final message = error.toString();
    if (message.length <= 240) return message;
    return '${message.substring(0, 240)}...';
  }
}

SupabaseFunctionCaller supabaseFunctionCallerFromClient(SupabaseClient client) {
  return SupabaseEdgeFunctionCaller(client: client).call;
}
