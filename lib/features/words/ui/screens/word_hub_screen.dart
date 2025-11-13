import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_hub_glow_provider.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/ui/widgets/category_card.dart';
// ⬇️ NEU
import 'package:talvori/features/words/application/radial_palette_controller.dart';
import 'package:talvori/features/words/ui/widgets/glow_toggle_button.dart';
import 'package:talvori/features/words/ui/widgets/slide_hint_button.dart';
import 'package:talvori/features/words/ui/widgets/floating_palette_button.dart';

class WordHubScreen extends ConsumerStatefulWidget {
  const WordHubScreen({super.key});

  @override
  ConsumerState<WordHubScreen> createState() => _WordHubScreenState();
}

class _WordHubScreenState extends ConsumerState<WordHubScreen> {
  static const double _frontButtonWidth = 120.0;
  static const double _maxReveal = 90.0;
  static const double _laneWidth = _frontButtonWidth + _maxReveal;

  final SlideHintController _slideCtrl = SlideHintController();
  final ScrollController _scroll = ScrollController();
  bool _allowHints = true;

  Future<void> _handleGlowToggle(bool glowEnabled) async {
    if (mounted) setState(() => _allowHints = false);
    await _slideCtrl.closeAndFreeze();
    ref.read(wordHubGlowProvider.notifier).state = !glowEnabled;
  }

  Widget _buildFrontButton({Key? key}) {
    return SizedBox(
      width: _frontButtonWidth,
      height: 36,
      child: TextButton(
        key: key,
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: const StadiumBorder(),
          foregroundColor: const Color(0xFFAFCCFE),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: const BorderSide(color: Color(0xFFAFCCFE), width: 1.8),
          shadowColor: const Color(0x550D1A2E),
          elevation: 6,
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Alles freischalten'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final repo = ref.read(wordHubControllerProvider.notifier).repo;
    final glowEnabled = ref.watch(wordHubGlowProvider);

    // Keys für Header-Elemente
    final titleKey = GlobalKey();
    final backKey = GlobalKey();
    final unlockKey = GlobalKey();
    final searchKey = GlobalKey();

    // Header-Targets registrieren
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final headerTargets = <PaletteTarget>[
        PaletteTarget(
          id: 'wordHub.title',
          key: titleKey,
          kind: TargetKind.header,
          tools: {PaletteTool.text},
        ),
        PaletteTarget(
          id: 'wordHub.backButton',
          key: backKey,
          kind: TargetKind.icon,
          tools: {PaletteTool.icon, PaletteTool.stroke},
        ),
        PaletteTarget(
          id: 'wordHub.unlockButton',
          key: unlockKey,
          kind: TargetKind.button,
          tools: {PaletteTool.stroke, PaletteTool.fill, PaletteTool.text},
        ),
        PaletteTarget(
          id: 'wordHub.search',
          key: searchKey,
          kind: TargetKind.searchBar,
          tools: {PaletteTool.stroke, PaletteTool.fill},
        ),
      ];
      ref.read(radialPaletteProvider.notifier).registerTargets(headerTargets);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          key: backKey,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
        titleSpacing: 8,
        title: SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Word Hub',
                    key: titleKey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 8,
                child: GlowToggleButton(
                  glowEnabled: glowEnabled,
                  onToggle: () => _handleGlowToggle(glowEnabled),
                ),
              ),
              Positioned(
                right: 12,
                top: 6,
                child: SlideHintButton(
                  key: ValueKey(_allowHints),
                  controller: _slideCtrl,
                  buttonWidth: _frontButtonWidth,
                  reveal: _maxReveal,
                  enableDrag: true,
                  autoHint: _allowHints,
                  firstHintDelay: const Duration(milliseconds: 800),
                  hintInterval: const Duration(seconds: 5),
                  hintFraction: 2 / 3,
                  hintOutDuration: const Duration(milliseconds: 1200),
                  hintBackDuration: const Duration(milliseconds: 600),
                  onUnderlayTap: () {
                    if (mounted) setState(() => _allowHints = false);
                    final glow = ref.read(wordHubGlowProvider);
                    ref.read(wordHubGlowProvider.notifier).state = !glow;
                  },
                  child: _buildFrontButton(key: unlockKey),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              // Suche
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    key: searchKey,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (q) {
                      final query = q.trim();
                      if (query.isEmpty) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WordListScreen(
                            filter: WordListFilter(WordFilterKind.query, query),
                          ),
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Suchen',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFF1C86B),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(
                          color: const Color(0xFFF1C86B).withOpacity(0.85),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(
                          color: Color(0xFFF1C86B),
                          width: 1.6,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(
                          color: Color(0xFFF1C86B),
                          width: 2.2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.12),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Sektionen
              for (final section in hubSections) ...[
                _SectionHeader(section.title, section.key),
                _GridSection(
                  sectionKey: section.key,
                  subs: section.subcats,
                  repo: repo,
                  onTapSub: (sub) async {
                    String? catId;
                    try {
                      catId =
                          (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
                          ? sub.supabaseId
                          : await repo.findCategoryIdByName(sub.label);
                    } catch (_) {
                      catId = null;
                    }

                    if (!context.mounted) return;
                    if (catId == null && sub.supabaseId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Hinweis: Kategorie-Lookup nicht möglich. Fallback aktiv.',
                          ),
                        ),
                      );
                    }

                    if (catId != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryDetailScreen(
                            title: sub.label,
                            categoryId: catId!,
                            categorySlug: null,
                            listFilter: WordListFilter(
                              WordFilterKind.category,
                              catId,
                            ),
                          ),
                        ),
                      );
                    } else {
                      final (kind, value) = _mapToFilter(
                        section.key,
                        sub.label,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryDetailScreen(
                            title: sub.label,
                            categoryId: null,
                            categorySlug: _slugifyLocal(sub.label),
                            listFilter: WordListFilter(kind, value),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],

              SliverToBoxAdapter(child: SizedBox(height: bottomInset + 10)),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: FloatingPaletteButton(scrollController: _scroll),
          ),
        ],
      ),
    );
  }
}

(WordFilterKind, String) _mapToFilter(String sectionKey, String label) {
  if (sectionKey == 'levels_progress') {
    return (WordFilterKind.level, label);
  }
  return (WordFilterKind.about, label);
}

class _SectionHeader extends ConsumerWidget {
  final String title;
  final String sectionKey;
  
  const _SectionHeader(this.title, this.sectionKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleKey = GlobalKey();
    
    // Target registrieren
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(radialPaletteProvider.notifier).registerTargets([
        PaletteTarget(
          id: 'wordHub.sectionTitle.$sectionKey',
          key: titleKey,
          kind: TargetKind.sectionTitle,
          tools: {
            PaletteTool.text,
            PaletteTool.glow,
          },
        ),
      ]);
    });
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Text(
          title,
          key: titleKey,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _GridSection extends ConsumerWidget {
  final String sectionKey;
  final List<HubSubcat> subs;
  final SupabaseWordRepository repo;
  final void Function(HubSubcat sub)? onTapSub;

  const _GridSection({
    required this.sectionKey,
    required this.subs,
    required this.repo,
    this.onTapSub,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) Für jede Subkategorie einen Key anlegen
    final keys = List.generate(subs.length, (_) => GlobalKey());

    // 2) Zu JEDEM Sub eine PaletteTarget-ID + Key anlegen
    final targets = <PaletteTarget>[];
    for (var i = 0; i < subs.length; i++) {
      final sub = subs[i];
      final id = 'wordHub.$sectionKey.${sub.key}';
      targets.add(PaletteTarget(
        id: id,
        key: keys[i],
        kind: TargetKind.tile,
        tools: {
          PaletteTool.stroke,
          PaletteTool.fill,
          PaletteTool.text,
          PaletteTool.icon,
          PaletteTool.image,
          PaletteTool.glow,
        },
      ));
    }

    // 3) Targets nach dem Frame einmalig registrieren
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (targets.isEmpty) return;
      ref.read(radialPaletteProvider.notifier).registerTargets(targets);
    });

    // 4) Grid ganz normal bauen, aber die vorbereiteten Keys verwenden
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final sub = subs[i];
            final id = 'wordHub.$sectionKey.${sub.key}';
            return _HighlightableTarget(
              id: id,
              child: CategoryCard(
                key: keys[i],
                sectionKey: sectionKey,
                sub: sub,
                onTap: onTapSub == null ? null : () => onTapSub!(sub),
              ),
            );
          },
          childCount: subs.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
      ),
    );
  }
}

class _HighlightableTarget extends ConsumerWidget {
  const _HighlightableTarget({
    super.key,
    required this.id,
    required this.child,
  });

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(radialPaletteProvider);

    bool isFocused = false;
    if (palette.targets.isNotEmpty &&
        palette.focusedIndex >= 0 &&
        palette.focusedIndex < palette.targets.length) {
      final focused = palette.targets[palette.focusedIndex];
      isFocused = focused.id == id;
    }

    if (!isFocused) {
      return child;
    }

    const gold = Color(0xFFFFC66A);
    final tool = palette.activeTool;

    Widget overlay;

    switch (tool) {
      case PaletteTool.stroke:
        // 🔹 Nur Rahmen + Glow → verdeutlicht: hier geht es um Stroke
        overlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold, width: 3),
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.9),
                blurRadius: 26,
                spreadRadius: 3,
              ),
            ],
          ),
        );
        break;

      case PaletteTool.fill:
      case PaletteTool.hubBackground:
      case PaletteTool.image:
        // 🔹 Halbdurchsichtiger Gold-Overlay + leichter Rahmen:
        //     „du änderst den Hintergrund / Inhalt"
        overlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: gold.withOpacity(0.22),
            border: Border.all(color: gold.withOpacity(0.9), width: 2),
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.8),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
        );
        break;

      case PaletteTool.text:
        // 🔹 Kleine TEXT-Badge oben links → „du änderst Text"
        overlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold.withOpacity(0.7), width: 1.6),
          ),
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'TEXT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        break;

      case PaletteTool.icon:
        // 🔹 ICON-Badge oben rechts
        overlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold.withOpacity(0.7), width: 1.6),
          ),
          alignment: Alignment.topRight,
          padding: const EdgeInsets.all(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ICON',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        break;

      case PaletteTool.glow:
        // 🔹 Nur äußerer Glow, kein Rahmen → „Glow/Light"
        overlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.95),
                blurRadius: 32,
                spreadRadius: 6,
              ),
            ],
          ),
        );
        break;

      default:
        // Fallback: wie Stroke
        overlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold, width: 3),
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.9),
                blurRadius: 26,
                spreadRadius: 3,
              ),
            ],
          ),
        );
        break;
    }

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      scale: 1.04,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          // 🔹 Highlight-Layer legt sich oben drauf
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: overlay,
          ),
        ],
      ),
    );
  }
}

String _slugifyLocal(String s) {
  return s
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
