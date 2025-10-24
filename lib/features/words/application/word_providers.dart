import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/mock_word_repository.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/application/learn_mode_controller.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

final wordRepositoryProvider = Provider<MockWordRepository>((ref) {
  return MockWordRepository();
});

final recentWordsProvider = FutureProvider<List<Word>>((ref) async {
  return ref.read(wordRepositoryProvider).fetchRecentWords();
});

// ---- Learn Mode Selektoren ----

/// Aktuelles Wort basierend auf Index und Queue
final currentWordProvider = Provider<WordUserView?>((ref) {
  final s = ref.watch(learnModeControllerProvider);
  if (s.shuffledWordIds.isEmpty || s.index >= s.shuffledWordIds.length) return null;
  final id = s.shuffledWordIds[s.index];
  final w = s.wordQueue.where((e) => e.id == id);
  return w.isEmpty ? null : w.first;
});

/// Stages für die Switches
final stagesProvider = Provider<List<int>>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.stages));
});

/// Timer-Status (aktiv und läuft)
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.timerActive && s.running));
});

/// Timer-Status (pausiert)
final isPausedProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.timerActive && s.timerPaused));
});

/// Verbleibende Zeit
final remainingTimeProvider = Provider<double>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.remainingMillis));
});

/// Karten in Session
final cardsSwipedProvider = Provider<int>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.cardsSwipedInSession));
});

/// Loading-Status
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.loading));
});

/// Kategorien
final categoriesProvider = Provider<List<CategoryInfo>>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.categories));
});

/// Ausgewählte Kategorie
final selectedCategoryProvider = Provider<CategoryInfo?>((ref) {
  final s = ref.watch(learnModeControllerProvider);
  if (s.selectedCategoryIndex < 0 || s.selectedCategoryIndex >= s.categories.length) return null;
  return s.categories[s.selectedCategoryIndex];
});
