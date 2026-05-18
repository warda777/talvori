import '../../srs/models/learning_mode.dart';
import '../import/shared_text_import_result.dart';
import '../repositories/category_repository.dart';
import '../repositories/word_progress_repository.dart';
import '../repositories/word_repository.dart';

const localMyWordsCategoryId = 'local-category-my-words';
const localMyWordsCategoryLabel = 'Meine Wörter';

class SharedTextImportService {
  const SharedTextImportService({
    required CategoryRepository categoryRepository,
    required WordRepository wordRepository,
    required WordProgressRepository wordProgressRepository,
  }) : _categoryRepository = categoryRepository,
       _wordRepository = wordRepository,
       _wordProgressRepository = wordProgressRepository;

  final CategoryRepository _categoryRepository;
  final WordRepository _wordRepository;
  final WordProgressRepository _wordProgressRepository;

  Future<SharedTextImportResult> importRawText({
    required String rawText,
    required DateTime now,
  }) async {
    try {
      final normalized = _normalize(rawText);
      if (normalized.isEmpty) {
        return const SharedTextImportResult(
          status: SharedTextImportStatus.empty,
          message: 'Kein Wort zum Importieren gefunden.',
        );
      }

      if (_containsMultipleWords(normalized)) {
        return const SharedTextImportResult(
          status: SharedTextImportStatus.invalid,
          message: 'Bitte markiere fuer Phase 1 nur ein einzelnes Wort.',
        );
      }

      if (!_containsLetter(normalized)) {
        return const SharedTextImportResult(
          status: SharedTextImportStatus.invalid,
          message: 'Der markierte Text enthaelt kein gueltiges Wort.',
        );
      }

      await _categoryRepository.upsertCategory(
        id: localMyWordsCategoryId,
        name: localMyWordsCategoryLabel,
        description: 'Lokal importierte Woerter.',
        sortOrder: 10000,
        now: now,
      );

      final existingWords = await _wordRepository.loadWordsForCategory(
        categoryId: localMyWordsCategoryId,
      );
      for (final word in existingWords) {
        if (word.term.trim().toLowerCase() == normalized.toLowerCase()) {
          return SharedTextImportResult(
            status: SharedTextImportStatus.duplicate,
            message: 'Dieses Wort ist bereits in Meine Woerter.',
            word: word,
          );
        }
      }

      final importedWord = await _wordRepository.upsertWord(
        id: _stableWordId(normalized),
        categoryId: localMyWordsCategoryId,
        term: normalized,
        translation: '',
        notes: 'Importiert. Uebersetzung ausstehend.',
        sortOrder: existingWords.length + 1,
        now: now,
      );

      for (final mode in LearningMode.values) {
        await _wordProgressRepository.ensureProgressForWord(
          wordId: importedWord.id,
          categoryId: localMyWordsCategoryId,
          mode: mode,
          now: now,
        );
      }

      return SharedTextImportResult(
        status: SharedTextImportStatus.imported,
        message: 'Wort wurde in Meine Woerter gespeichert.',
        word: importedWord,
      );
    } catch (_) {
      return const SharedTextImportResult(
        status: SharedTextImportStatus.error,
        message: 'Import konnte nicht abgeschlossen werden.',
      );
    }
  }

  String _normalize(String rawText) {
    return rawText.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  bool _containsMultipleWords(String text) {
    return text.contains(RegExp(r'\s'));
  }

  bool _containsLetter(String text) {
    return RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ]").hasMatch(text);
  }

  String _stableWordId(String term) {
    final slug = term
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9à-öø-ÿ'-]+"), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return 'local-my-words-$slug';
  }
}
