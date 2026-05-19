import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/tagesimpuls_ai_client.dart';
import '../models/tagesimpuls_selection_item.dart';

class TagesimpulsMessageState {
  const TagesimpulsMessageState({
    this.count = 1,
    this.isGenerating = false,
    this.error,
    this.impulses = const [],
  });

  final int count;
  final bool isGenerating;
  final String? error;
  final List<TagesimpulsGeneratedImpulse> impulses;

  TagesimpulsMessageState copyWith({
    int? count,
    bool? isGenerating,
    String? error,
    bool clearError = false,
    List<TagesimpulsGeneratedImpulse>? impulses,
  }) {
    return TagesimpulsMessageState(
      count: count ?? this.count,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : error ?? this.error,
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
        error: 'words_required',
        impulses: const [],
        isGenerating: false,
      );
      return;
    }

    state = state.copyWith(
      isGenerating: true,
      clearError: true,
      impulses: const [],
    );

    try {
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
      state = state.copyWith(
        isGenerating: false,
        clearError: true,
        impulses: result.impulses,
      );
    } on TagesimpulsAiException catch (error) {
      state = state.copyWith(
        isGenerating: false,
        error: error.code,
        impulses: const [],
      );
    } on Object {
      state = state.copyWith(
        isGenerating: false,
        error: 'ai_request_failed',
        impulses: const [],
      );
    }
  }
}
