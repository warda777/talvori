import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/mix/mix_groups.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_controller.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_origin.dart';
import 'package:talvori/features/words/application/mix/mix_search_providers.dart';
import 'package:talvori/features/words/application/mix/mix_selection_controller.dart';
import 'package:talvori/features/words/ui/widgets/burger_section_card.dart';
import 'package:talvori/features/words/ui/widgets/mix_pick_or_search_bar.dart';
import 'package:talvori/features/words/ui/widgets/mix_search_result_tile.dart';
import 'package:talvori/features/words/ui/widgets/mix_top_bar.dart';

class MixBuilderScreen extends ConsumerStatefulWidget {
  final MixNavigationOrigin? navigationOrigin;

  const MixBuilderScreen({super.key, this.navigationOrigin});

  @override
  ConsumerState<MixBuilderScreen> createState() => _MixBuilderScreenState();
}

class _MixBuilderScreenState extends ConsumerState<MixBuilderScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, GlobalKey> _sectionKeys = {};
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    for (final group in mixGroups) {
      _sectionKeys[group.title] = GlobalKey();
    }
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
      if (mounted) _shakeController.reverse();
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

  void _closeSearchIfNeeded(bool isSearch) {
    if (!isSearch) return;
    ref.read(mixIsSearchModeProvider.notifier).state = false;
    ref.read(mixSearchTextProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final isSearch = ref.watch(mixIsSearchModeProvider);
    final results = ref.watch(mixSearchResultsProvider);
    final selection = ref.watch(mixSelectionProvider);
    final selectionController = ref.read(mixSelectionProvider.notifier);

    return GestureDetector(
      onTap: () => _closeSearchIfNeeded(isSearch),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFF02050A),
        body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF07101A), Color(0xFF02050A)],
              ),
            ),
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
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                    onMore: () {},
                  ),
                ),
                const SliverToBoxAdapter(child: MixPickOrSearchBar()),
                if (isSearch && results.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Suchergebnisse',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  for (final result in results)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: MixSearchResultTile(
                          result: result,
                          onTap: () =>
                              _scrollToAndPick(result.group, result.item),
                        ),
                      ),
                    ),
                ] else if (isSearch && results.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Keine Ergebnisse gefunden',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                      ),
                    ),
                  ),
                ],
                if (!isSearch || results.isEmpty) ...[
                  for (final group in mixGroups)
                    SliverToBoxAdapter(
                      key: _sectionKeys[group.title],
                      child: BurgerSectionCard(
                        title: group.title,
                        onSelectAll: () =>
                            selectionController.toggleAll(group.items),
                        allSelected: selectionController.areAllSelected(
                          group.items,
                        ),
                        items: [
                          for (final item in group.items)
                            BurgerItem(
                              label: item,
                              selected: selection.contains(item),
                              onChanged: (value) =>
                                  selectionController.setSelected(item, value),
                            ),
                        ],
                      ),
                    ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 104)),
              ],
            ),
          ),
        ),
        floatingActionButton: (isSearch && results.isNotEmpty)
            ? null
            : SafeArea(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final shakeValue = _shakeController.value;
                    var offsetX = 0.0;
                    if (shakeValue > 0 && shakeValue < 1) {
                      final cycle = shakeValue * 4.0;
                      final phase = cycle % 1.0;
                      offsetX = phase < 0.5
                          ? -8.0 * (1.0 - phase * 2.0)
                          : 8.0 * ((phase - 0.5) * 2.0);
                    }

                    final enabled = selection.isNotEmpty;
                    return Transform.translate(
                      offset: Offset(offsetX, 0),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        width: 154,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: enabled
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF5DDCFF,
                                    ).withValues(alpha: 0.26),
                                    blurRadius: 24,
                                  ),
                                ]
                              : null,
                        ),
                        child: FilledButton(
                          onPressed: enabled
                              ? () async {
                                  if (!context.mounted) return;
                                  await MixNavigationController.navigateToQuickSets(
                                    context,
                                    initialIndex: 4,
                                  );
                                }
                              : _shakeButton,
                          style: FilledButton.styleFrom(
                            backgroundColor: enabled
                                ? const Color(0xFF0E1A24)
                                : const Color(0xFF15181F),
                            foregroundColor: enabled
                                ? Colors.white
                                : Colors.white38,
                            side: BorderSide(
                              color: enabled
                                  ? const Color(0xFF5DDCFF)
                                  : Colors.white24,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Start',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
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
