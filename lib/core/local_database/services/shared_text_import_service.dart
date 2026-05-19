import '../../srs/models/learning_mode.dart';
import '../import/shared_text_import_result.dart';
import '../models/translation_status.dart';
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
      final candidate = _extractSingleWordCandidate(rawText);
      if (candidate == null) {
        return const SharedTextImportResult(
          status: SharedTextImportStatus.empty,
          message: 'Kein Wort zum Importieren gefunden.',
        );
      }

      if (candidate.isAmbiguous) {
        return const SharedTextImportResult(
          status: SharedTextImportStatus.invalid,
          message: 'Bitte markiere für Phase 1 nur ein einzelnes Wort.',
        );
      }

      final normalized = candidate.word;
      if (!_containsLetter(normalized)) {
        return const SharedTextImportResult(
          status: SharedTextImportStatus.invalid,
          message: 'Der markierte Text enthält kein gültiges Wort.',
        );
      }

      await _categoryRepository.upsertCategory(
        id: localMyWordsCategoryId,
        name: localMyWordsCategoryLabel,
        description: 'Lokal importierte Wörter.',
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
            message: 'Dieses Wort ist bereits in Meine Wörter.',
            word: word,
          );
        }
      }

      final importedWord = await _wordRepository.upsertWord(
        id: _stableWordId(normalized),
        categoryId: localMyWordsCategoryId,
        term: normalized,
        translation: '',
        translationStatus: TranslationStatus.pending,
        sourceLanguage: 'en',
        targetLanguage: 'de',
        notes: 'Importiert.',
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
        message: 'Wort wurde in Meine Wörter gespeichert.',
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

  _ImportCandidate? _extractSingleWordCandidate(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return null;

    final lines = trimmed
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);
    final candidates = <String>{};
    var hasAmbiguousContent = false;

    for (final line in lines) {
      final withoutUrls = _removeUrls(line).trim();
      if (withoutUrls.isEmpty) continue;

      final candidate = _singleWordFromText(withoutUrls);
      if (candidate != null) {
        candidates.add(candidate);
        continue;
      }

      if (candidates.isEmpty) {
        hasAmbiguousContent = true;
      }
    }

    if (candidates.length == 1 && !hasAmbiguousContent) {
      return _ImportCandidate(candidates.single);
    }
    if (candidates.isEmpty && !hasAmbiguousContent) return null;
    return const _ImportCandidate.ambiguous();
  }

  String _removeUrls(String text) {
    return text
        .replaceAll(RegExp(r'https?://\S+', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'www\.\S+', caseSensitive: false), ' ');
  }

  String? _singleWordFromText(String text) {
    final cleaned = _stripEdgePunctuation(_normalize(text));
    if (cleaned.isEmpty) return null;
    if (!_wordPattern.hasMatch(cleaned)) return null;
    return cleaned;
  }

  String _stripEdgePunctuation(String text) {
    return text
        .replaceAll(RegExp(r'''^[\s"'“”‘’„‚«»()\[\]{}<>.,;:!?]+'''), '')
        .replaceAll(RegExp(r'''[\s"'“”‘’„‚«»()\[\]{}<>.,;:!?]+$'''), '');
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

  static final _wordPattern = RegExp(
    r"^[a-z0-9à-öø-ÿ]+(?:[-'][a-z0-9à-öø-ÿ]+)*$",
  );
}

class _ImportCandidate {
  const _ImportCandidate(this.word) : isAmbiguous = false;

  const _ImportCandidate.ambiguous() : word = '', isAmbiguous = true;

  final String word;
  final bool isAmbiguous;
}
