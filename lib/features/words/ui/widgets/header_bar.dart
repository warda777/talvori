// lib/features/words/ui/widgets/header_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'category_wheel.dart';

class HeaderBar extends ConsumerWidget {
  // ⬇️ NEU: Optionale Custom Wheel Labels für QuickSets
  final List<String>? customWheelLabels;
  final int? customWheelInitialIndex;
  final void Function(int index, String label)? customOnWheelChanged;

  // ⬇️ NEU: Custom Back-Button-Handler
  final VoidCallback? onBack;

  const HeaderBar({
    super.key,
    this.customWheelLabels,
    this.customWheelInitialIndex,
    this.customOnWheelChanged,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⬇️ NEU: Verwende Custom Wheel wenn vorhanden, sonst normale Kategorien
    final useCustomWheel =
        customWheelLabels != null && customWheelLabels!.isNotEmpty;

    final isLoading = useCustomWheel ? false : ref.watch(isLoadingProvider);
    final categories = useCustomWheel ? null : ref.watch(categoriesProvider);
    final s = useCustomWheel ? null : ref.watch(learnModeControllerProvider);
    final c = useCustomWheel
        ? null
        : ref.read(learnModeControllerProvider.notifier);

    return SizedBox(
      height: WordsUIConstants.headerHeight,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(WordsUIConstants.borderRadius),
            onTap: onBack ?? () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: WordsUIConstants.iconSize,
              height: WordsUIConstants.iconSize,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
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
                          child: CircularProgressIndicator(
                            color: WordsUIConstants.loadingIndicator,
                          ),
                        ),
                      )
                    : CategoryWheel(
                        categories: useCustomWheel
                            ? customWheelLabels!
                            : categories!.map((c) => c.name).toList(),
                        initialIndex: useCustomWheel
                            ? (customWheelInitialIndex ?? 0)
                            : s!.selectedCategoryIndex,
                        onChanged: useCustomWheel
                            ? (customOnWheelChanged ?? (idx, label) {})
                            : (idx, label) async {
                                // Kategorie umschalten → macht Controller (lädt Stages + Queue)
                                await c!.selectCategoryIndex(idx);
                              },
                      ),
              ),
            ),
          ),
          const SizedBox(
            width: WordsUIConstants.iconSize + WordsUIConstants.mediumSpacing,
          ),
        ],
      ),
    );
  }
}
