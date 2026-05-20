import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/tagesimpuls_ai_client.dart';
import '../models/tagesimpuls_selection_item.dart';

class TagesimpulsMessageState {
  const TagesimpulsMessageState({
    this.count = 1,
    this.isGenerating = false,
    this.error,
    this.generationStatus = TagesimpulsGenerationStatus.idle,
    this.impulses = const [],
  });

  final int count;
  final bool isGenerating;
  final String? error;
  final TagesimpulsGenerationStatus generationStatus;
  final List<TagesimpulsGeneratedImpulse> impulses;

  TagesimpulsMessageState copyWith({
    int? count,
    bool? isGenerating,
    String? error,
    bool clearError = false,
    TagesimpulsGenerationStatus? generationStatus,
    List<TagesimpulsGeneratedImpulse>? impulses,
  }) {
    return TagesimpulsMessageState(
      count: count ?? this.count,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : error ?? this.error,
      generationStatus: generationStatus ?? this.generationStatus,
      impulses: impulses ?? this.impulses,
    );
  }
}

class TagesimpulsMessageController
    extends StateNotifier<TagesimpulsMessageState> {
  TagesimpulsMessageController({required TagesimpulsAiClient client})
    : _client = client,
      super(const TagesimpulsMessageState());

  final TagesimpulsAiClient _client;

  void setCount(int count) {
    if (count < 1 || count > 5) return;
    state = state.copyWith(count: count, clearError: true);
  }

  Future<void> generate(List<TagesimpulsSelectionItem> items) async {
    if (items.length < 3) {
      state = state.copyWith(
        error: 'notEnoughWords',
        generationStatus: TagesimpulsGenerationStatus.notEnoughWords,
        impulses: const [],
        isGenerating: false,
      );
      return;
    }

    state = state.copyWith(
      isGenerating: true,
      clearError: true,
      generationStatus: TagesimpulsGenerationStatus.idle,
      impulses: const [],
    );

    try {
      debugPrint(
        'TagesimpulsMessageController generate start '
        'selectedWords=${items.length} requestedCount=${state.count}',
      );
      final result = await _client.generate(
        TagesimpulsGenerateRequest(
          words: [
            for (final item in items)
              TagesimpulsGenerateWord(
                word: item.text.trim(),
                translation: item.translation?.trim(),
              ),
          ],
          count: state.count,
          language: 'EN',
          style: 'natural_message',
        ),
      );
      debugPrint(
        'TagesimpulsMessageController generate success '
        'impulses=${result.impulses.length}',
      );
      if (result.impulses.isEmpty) {
        state = state.copyWith(
          isGenerating: false,
          error: 'noImpulsesReturned',
          generationStatus: TagesimpulsGenerationStatus.noImpulsesReturned,
          impulses: const [],
        );
        return;
      }
      state = state.copyWith(
        isGenerating: false,
        clearError: true,
        generationStatus: TagesimpulsGenerationStatus.generationSucceeded,
        impulses: result.impulses,
      );
    } on TagesimpulsAiException catch (error) {
      final status = _statusForErrorCode(error.code);
      debugPrint(
        'TagesimpulsMessageController generate failed code=${error.code} '
        'status=${status.name}',
      );
      state = state.copyWith(
        isGenerating: false,
        error: error.code,
        generationStatus: status,
        impulses: const [],
      );
    } on Object {
      debugPrint('TagesimpulsMessageController generate failed unexpected');
      state = state.copyWith(
        isGenerating: false,
        error: 'functionCallFailed',
        generationStatus: TagesimpulsGenerationStatus.functionCallFailed,
        impulses: const [],
      );
    }
  }

  TagesimpulsGenerationStatus _statusForErrorCode(String code) {
    return switch (code) {
      'aiClientNotConfigured' =>
        TagesimpulsGenerationStatus.aiClientNotConfigured,
      'quotaExceeded' => TagesimpulsGenerationStatus.quotaExceeded,
      'invalidAiResponse' => TagesimpulsGenerationStatus.invalidAiResponse,
      'noImpulsesReturned' => TagesimpulsGenerationStatus.noImpulsesReturned,
      'notEnoughWords' => TagesimpulsGenerationStatus.notEnoughWords,
      _ => TagesimpulsGenerationStatus.functionCallFailed,
    };
  }
}
