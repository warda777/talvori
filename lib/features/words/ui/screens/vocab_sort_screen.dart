import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/sort/vocab_sort_controller.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/application/sort/add_button_lock_provider.dart';
import 'package:talvori/features/words/ui/widgets/sort/word_decision_wheel.dart';

class VocabSortScreen extends ConsumerStatefulWidget {
  const VocabSortScreen({super.key});
  @override
  ConsumerState<VocabSortScreen> createState() => _VocabSortScreenState();
}

class _VocabSortScreenState extends ConsumerState<VocabSortScreen> {
  int _selectedCategoryIndex = 0;

  // Alle Kategorien aus Word Hub sammeln
  List<String> get _allCategories {
    final categories = <String>[];
    for (final section in hubSections) {
      for (final subcat in section.subcats) {
        categories.add(subcat.label);
      }
    }
    return categories;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (_allCategories.isNotEmpty) {
        await ref.read(vocabSortControllerProvider.notifier)
            .loadForCategory(_allCategories[0]); // lädt Queue + Counter
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = ref.watch(vocabSortControllerProvider);
    final ctrl = ref.read(vocabSortControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Topbar mit Überschrift
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Überschrift "Words" absolut zentriert
                  const Text(
                    'Words',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // Close-Button rechts ausgerichtet
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.surfaceContainerHighest,
                        foregroundColor: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Word Decision Wheel mit Overlay-Bar
            Expanded(
              child: s.loading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Mitte des verfügbaren Platzes berechnen
                        final centerY = constraints.maxHeight / 2;
                        final lineTop = centerY;
                        
                        return Stack(
                          children: [
                            // 1) Pfeil nach oben (über der Box, genau über der "0")
                            Positioned(
                              top: lineTop - 24 - 24, // über der Box (24px Abstand)
                              left: 34, // 16 (Box left) + 18 (Box padding) = Position der "0"
                              child: IgnorePointer(
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 20,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),

                            // 2) Overlay-Box (hinter dem Wheel) - in der Mitte
                            Positioned(
                              top: lineTop - 24, // halbe Boxhöhe
                              left: 16,
                              right: 16,
                              height: 48,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent, // transparent
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xFF6D7473), // grauer Rand
                                      width: 1.4,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${s.overlayCounter}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 3) Pfeil nach unten (unter der Box)
                            Positioned(
                              top: lineTop + 24 + 4, // unter der Box (4px Abstand)
                              left: 34, // 16 (Box left) + 18 (Box padding) = Position der "0"
                              child: IgnorePointer(
                                child: Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 20,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),

                            // 4) Wheel (wird NACH der Box gezeichnet → liegt oben)
                            Positioned(
                              top: lineTop - 420 / 2, // Center-Linie bei lineTop
                              left: 0,
                              right: 0,
                              height: 420, // _wheelViewportH
                              child: WordDecisionWheel(
                                words: s.queue,
                                onCenterChange: (w) => ctrl.setCenter(w),
                                onCrossUp: (w) => ctrl.crossedUp(w),    // hoch -> abziehen
                                onCrossDown: (w) => ctrl.crossedDown(w),  // runter -> wieder drauf
                              ),
                            ),

                            // 5) "I know" + Counter links auf Höhe des unteren Wheel-Rands
                            Positioned(
                              top: lineTop - 460 / 2 + 420 - 60, // Unten des Wheels minus Abstand für Text + Counter
                              left: 20,
                              child: IgnorePointer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'I know',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${s.knownCount}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Bottom actions (Add + Wheel)
            SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Wheel für Kategorie-Auswahl
                  Center(
                    child: CategoryWheel(
                      categories: _allCategories,
                      initialIndex: _selectedCategoryIndex,
                      onChanged: (index, label) async {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                        // Lädt Queue + Counter
                        await ctrl.loadForCategory(label);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Add Button + Lock Icon + Plus Button
                  Row(
                    children: [
                      // Links: Add Button + Lock Icon
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Add Button
                            Opacity(
                              opacity: ref.watch(addButtonLockedProvider) ? 0.5 : 1.0,
                              child: FilledButton(
                                onPressed: ref.watch(addButtonLockedProvider)
                                    ? null
                                    : () async {
                                        await ctrl.applyKnown(); // persist „I know"
                                        if (mounted) Navigator.of(context).pop();
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2F2F3A),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  side: BorderSide(
                                    color: s.currentCategoryStrokeColor,
                                    width: 1.5,
                                  ),
                                  disabledBackgroundColor: const Color(0xFF2F2F3A),
                                  disabledForegroundColor: Colors.white70,
                                ),
                                child: const Text('Add'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Lock Icon
                            GestureDetector(
                              onTap: () {
                                final notifier = ref.read(addButtonLockedProvider.notifier);
                                notifier.state = !notifier.state;
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: s.currentCategoryStrokeColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  ref.watch(addButtonLockedProvider)
                                      ? Icons.lock_rounded
                                      : Icons.lock_open_rounded,
                                  color: s.currentCategoryStrokeColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Rechts: Undo Button + Plus Button
                      Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Undo Button
                              GestureDetector(
                                onTap: () async {
                                  await ctrl.undo();
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.undo_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Plus Button
                              GestureDetector(
                                onTap: () async {
                                  await ctrl.addCenterToKnown();
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFB0CCFE),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Color(0xFFB0CCFE),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
