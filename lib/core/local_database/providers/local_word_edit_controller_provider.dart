import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_word.dart';
import 'local_bootstrap_provider.dart';
import 'local_word_detail_provider.dart';
import 'local_words_for_category_provider.dart';

class LocalWordEditControllerState {
  const LocalWordEditControllerState({this.isSaving = false, this.error});

  final bool isSaving;
  final String? error;

  LocalWordEditControllerState copyWith({
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return LocalWordEditControllerState(
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final localWordEditControllerProvider =
    NotifierProvider<LocalWordEditController, LocalWordEditControllerState>(
      LocalWordEditController.new,
    );

class LocalWordEditController extends Notifier<LocalWordEditControllerState> {
  @override
  LocalWordEditControllerState build() {
    return const LocalWordEditControllerState();
  }

  Future<LocalWord?> updateWord({
    required String wordId,
    required String categoryId,
    required String term,
    required String translation,
    required DateTime updatedAt,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final bootstrapResult = await ref.read(localBootstrapProvider.future);
      final updatedWord = await bootstrapResult.repositoryFactory.wordRepository
          .updateWord(
            id: wordId,
            term: term,
            translation: translation,
            updatedAt: updatedAt,
          );

      ref.invalidate(localWordsForCategoryProvider(categoryId));
      ref.invalidate(
        localWordDetailProvider(
          LocalWordDetailRequest(wordId: wordId, categoryId: categoryId),
        ),
      );

      state = state.copyWith(isSaving: false, clearError: true);
      return updatedWord;
    } catch (error) {
      state = state.copyWith(isSaving: false, error: error.toString());
      return null;
    }
  }
}
