import 'package:flutter/material.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

final localLearningSourceItems = <LocalCategoryDetailGroupItem>[
  LocalCategoryDetailGroupItem(
    wordHubKey: 'all_words',
    displayLabel: 'Alle Wörter',
    localCategoryId: LocalLearningSource.allWords.id,
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'favorites',
    displayLabel: 'Favoriten',
    localCategoryId: LocalLearningSource.favorites.id,
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'my_words',
    displayLabel: localMyWordsCategoryLabel,
    localCategoryId: localMyWordsCategoryId,
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'known_words',
    displayLabel: 'Wörter, die ich kenne',
    localCategoryId: LocalLearningSource.knownWords.id,
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'reviewed_for_learning',
    displayLabel: 'Noch zu lernen',
    localCategoryId: LocalLearningSource.reviewedForLearning.id,
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'my_mix',
    displayLabel: 'Mein Mix',
    localCategoryId: LocalLearningSource.myMix.id,
  ),
];

class LocalLearningSourceDetailScreen extends StatelessWidget {
  const LocalLearningSourceDetailScreen({
    super.key,
    this.initialSourceKey = 'my_words',
  });

  final String initialSourceKey;

  @override
  Widget build(BuildContext context) {
    final selectedSource = localLearningSourceItems.firstWhere(
      (item) => item.wordHubKey == initialSourceKey,
      orElse: () => localLearningSourceItems[2],
    );
    final selectedLearningSource =
        LocalLearningSource.fromWordHubKey(selectedSource.wordHubKey) ??
        LocalLearningSource.myWords;

    if (selectedLearningSource == LocalLearningSource.knownWords ||
        selectedLearningSource == LocalLearningSource.reviewedForLearning) {
      return LocalWordListScreen(
        categoryId: selectedLearningSource.id,
        title: selectedLearningSource.label,
      );
    }

    return CategoryDetailScreen(
      title: selectedSource.displayLabel,
      categoryId: selectedLearningSource.id,
      listFilter: const WordListFilter(WordFilterKind.about, 'local-my-words'),
      useLocalOfflineFlow: true,
      localCategoryId: selectedLearningSource.id,
      localCategoryItems: localLearningSourceItems,
      localSelectedWordHubKey: selectedSource.wordHubKey,
    );
  }
}
