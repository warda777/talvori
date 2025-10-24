// lib/features/words/ui/widgets/header_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'category_wheel.dart';

class HeaderBar extends ConsumerWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final categories = ref.watch(categoriesProvider);
    final s = ref.watch(learnModeControllerProvider);
    final c = ref.read(learnModeControllerProvider.notifier);

    return SizedBox(
      height: WordsUIConstants.headerHeight,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(WordsUIConstants.borderRadius),
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: WordsUIConstants.iconSize,
              height: WordsUIConstants.iconSize,
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: WordsUIConstants.mediumSpacing),
          Expanded(
            child: Transform.translate(
              offset: WordsUIConstants.headerOffset,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: WordsUIConstants.loadingSize.width,
                        height: WordsUIConstants.loadingSize.height,
                        child: const Center(
                          child: CircularProgressIndicator(color: WordsUIConstants.loadingIndicator),
                        ),
                      )
                    : CategoryWheel(
                        categories: categories.map((c) => c.name).toList(),
                        initialIndex: s.selectedCategoryIndex,
                        onChanged: (idx, label) async {
                          // Kategorie umschalten → macht Controller (lädt Stages + Queue)
                          await c.selectCategoryIndex(idx);
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(width: WordsUIConstants.iconSize + WordsUIConstants.mediumSpacing),
        ],
      ),
    );
  }
}
