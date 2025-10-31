import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
import 'package:talvori/features/words/ui/widgets/burger_section_card.dart';
import 'package:talvori/features/words/ui/widgets/mix_top_bar.dart';
import 'package:talvori/features/words/ui/widgets/mix_pick_or_search_bar.dart';
import 'package:talvori/features/words/ui/widgets/mix_search_result_tile.dart';
import 'package:talvori/features/words/application/mix/mix_groups.dart';
import 'package:talvori/features/words/application/mix/mix_selection_controller.dart';
import 'package:talvori/features/words/application/mix/mix_search_providers.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_controller.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_origin.dart';

class MixBuilderScreen extends ConsumerStatefulWidget {
  /// Navigation-Herkunft für Back-Button-Logik
  final MixNavigationOrigin? navigationOrigin;
  
  const MixBuilderScreen({
    super.key,
    this.navigationOrigin,
  });

  @override
  ConsumerState<MixBuilderScreen> createState() => _MixBuilderScreenState();
}

class _MixBuilderScreenState extends ConsumerState<MixBuilderScreen> with SingleTickerProviderStateMixin {
  // Scroll-to-section Keys (müssen persistent sein)
  final Map<String, GlobalKey> _sectionKeys = {};
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    // Keys für jede Sektion initialisieren
    for (final g in mixGroups) {
      _sectionKeys[g.title] = GlobalKey();
    }
    // Animation Controller für Wackel-Effekt
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _shakeButton() {
    _shakeController.forward(from: 0.0).then((_) {
      _shakeController.reverse();
    });
  }

  void _scrollToAndPick(String groupTitle, String itemLabel) {
    final key = _sectionKeys[groupTitle];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    ref.read(mixSelectionProvider.notifier).setSelected(itemLabel, true);
    ref.read(mixIsSearchModeProvider.notifier).state = false;
    ref.read(mixSearchTextProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSearch = ref.watch(mixIsSearchModeProvider);
    final results = ref.watch(mixSearchResultsProvider);
    final sel = ref.watch(mixSelectionProvider);
    final selCtrl = ref.read(mixSelectionProvider.notifier);

    return GestureDetector(
      onTap: () {
        // Bei Tap irgendwo auf dem Screen: Suchmodus beenden
        if (isSearch) {
          ref.read(mixIsSearchModeProvider.notifier).state = false;
          ref.read(mixSearchTextProvider.notifier).state = '';
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: MixTopBar(
                  onBack: () {
                    if (widget.navigationOrigin != null) {
                      MixNavigationController.handleBackNavigation(
                        context,
                        widget.navigationOrigin,
                        null,
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  onMore: () {},
                ),
              ),
              const SliverToBoxAdapter(child: MixPickOrSearchBar()),

              // Suchergebnisse (wenn aktiv und Ergebnisse vorhanden)
              if (isSearch && results.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Suchergebnisse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                for (final r in results)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: MixSearchResultTile(
                        result: r,
                        onTap: () => _scrollToAndPick(r.group, r.item),
                      ),
                    ),
                  ),
              ] else if (isSearch && results.isEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Keine Ergebnisse gefunden',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ),
                ),
              ],

              // Gruppenlisten (immer sichtbar, außer wenn Suche aktiv mit Ergebnissen)
              if (!isSearch || results.isEmpty) ...[
                for (final g in mixGroups) ...[
                  SliverToBoxAdapter(
                    key: _sectionKeys[g.title],
                    child: BurgerSectionCard(
                      title: g.title,
                      onSelectAll: () => selCtrl.toggleAll(g.items),
                      allSelected: selCtrl.areAllSelected(g.items),
                      items: [
                        for (final item in g.items)
                          BurgerItem(
                            label: item,
                            selected: sel.contains(item),
                            onChanged: (v) => selCtrl.setSelected(item, v),
                          ),
                      ],
                    ),
                  ),
                ],
              ],

              const SliverToBoxAdapter(
                child: SizedBox(height: WordsLayout.pageBottomPadding),
              ),
            ],
          ),
        ),

        // Floating Start - immer anzeigen (auch während Suche, wenn keine Ergebnisse)
        floatingActionButton: (isSearch && results.isNotEmpty)
            ? null
            : SafeArea(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    // Wackel-Animation: 4x links-rechts
                    final shakeValue = _shakeController.value;
                    double offsetX = 0.0;
                    if (shakeValue > 0 && shakeValue < 1) {
                      // 4 Wackel-Bewegungen
                      final cycle = shakeValue * 4.0;
                      final phase = cycle % 1.0;
                      if (phase < 0.5) {
                        offsetX = -8.0 * (1.0 - phase * 2.0);
                      } else {
                        offsetX = 8.0 * ((phase - 0.5) * 2.0);
                      }
                    }
                    
                    return Transform.translate(
                      offset: Offset(offsetX, 0),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        width: 138,
                        height: 48,
                        child: FilledButton(
                          onPressed: sel.isEmpty
                              ? () {
                                  // Nichts ausgewählt: Button wackeln lassen
                                  _shakeButton();
                                }
                              : () async {
                                  if (!context.mounted) return;
                                  // TODO: hier (später) Selektion → 'picked_user' persistieren
                                  await MixNavigationController.navigateToQuickSets(
                                    context,
                                    initialIndex: 4, // My mix
                                  );
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: sel.isEmpty
                                ? const Color(0xFF2C2C2E).withOpacity(0.5)
                                : const Color(0xFF2C2C2E),
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 4,
                          ),
                          child: const Text('Start'),
                        ),
                      ),
                    );
                  },
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
