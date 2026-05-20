import 'package:flutter/foundation.dart';

import 'tagesimpuls_ai_client.dart';

typedef TagesimpulsFunctionCaller =
    Future<Map<String, Object?>> Function(
      String functionName,
      Map<String, Object?> payload,
    );

class SupabaseTagesimpulsAiClient implements TagesimpulsAiClient {
  const SupabaseTagesimpulsAiClient({
    required TagesimpulsFunctionCaller functionCaller,
    this.functionName = 'generate-daily-impulses',
  }) : _functionCaller = functionCaller;

  final TagesimpulsFunctionCaller _functionCaller;
  final String functionName;

  @override
  Future<TagesimpulsGenerateResult> generate(
    TagesimpulsGenerateRequest request,
  ) async {
    if (request.words.isEmpty) {
      throw const TagesimpulsAiException('notEnoughWords');
    }
    if (request.count < 1 || request.count > 5) {
      throw const TagesimpulsAiException('invalid_count');
    }

    final payload = <String, Object?>{
      'words': [for (final word in request.words) word.toJson()],
      'count': request.count,
      'language': request.language,
      'style': request.style,
    };
    debugPrint(
      'SupabaseTagesimpulsAiClient call function=$functionName '
      'words=${request.words.length} count=${request.count} '
      'language=${request.language} style=${request.style}',
    );

    late final Map<String, Object?> response;
    try {
      response = await _functionCaller(functionName, payload);
    } on Object catch (error) {
      debugPrint(
        'SupabaseTagesimpulsAiClient function call failed: '
        '${error.runtimeType} message=${_safeErrorMessage(error)}',
      );
      throw const TagesimpulsAiException('functionCallFailed');
    }
    debugPrint(
      'SupabaseTagesimpulsAiClient responseKeys=${response.keys.toList()}',
    );

    final error = response['error'];
    if (error is String && error.trim().isNotEmpty) {
      final code = _mapFunctionError(error.trim());
      debugPrint(
        'SupabaseTagesimpulsAiClient function error=$code '
        'raw=${error.trim()}',
      );
      throw TagesimpulsAiException(code);
    }

    final rawImpulses = response['impulses'];
    if (rawImpulses is! List) {
      throw const TagesimpulsAiException('invalidAiResponse');
    }
    if (rawImpulses.isEmpty) {
      throw const TagesimpulsAiException('noImpulsesReturned');
    }

    final impulses = rawImpulses
        .map(_parseImpulse)
        .whereType<TagesimpulsGeneratedImpulse>()
        .toList(growable: false);
    if (impulses.isEmpty) {
      throw const TagesimpulsAiException('invalidAiResponse');
    }
    debugPrint('SupabaseTagesimpulsAiClient impulses=${impulses.length}');

    return TagesimpulsGenerateResult(impulses: impulses);
  }

  String _mapFunctionError(String error) {
    return switch (error) {
      'ai_not_configured' ||
      'ai_provider_not_supported' => 'aiClientNotConfigured',
      'quota_exceeded' || 'ai_rate_limited' => 'quotaExceeded',
      'ai_invalid_response' => 'invalidAiResponse',
      'words_required' => 'notEnoughWords',
      _ => 'functionCallFailed',
    };
  }

  TagesimpulsGeneratedImpulse? _parseImpulse(Object? raw) {
    if (raw is! Map) return null;

    final slot = raw['slot'];
    final message = raw['message'];
    final usedWords = raw['usedWords'];
    if (message is! String || message.trim().isEmpty) return null;

    return TagesimpulsGeneratedImpulse(
      slot: slot is String && slot.trim().isNotEmpty ? slot.trim() : 'day',
      message: message.trim(),
      usedWords: usedWords is List
          ? usedWords
                .whereType<String>()
                .map((word) => word.trim())
                .where((word) => word.isNotEmpty)
                .toList(growable: false)
          : const [],
    );
  }

  String _safeErrorMessage(Object error) {
    final message = error.toString();
    if (message.length <= 240) return message;
    return '${message.substring(0, 240)}...';
  }
}
