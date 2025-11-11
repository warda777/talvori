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
import 'package:talvori/features/words/ui/widgets/glow_toggle_button.dart';
import 'package:talvori/features/words/ui/widgets/slide_hint_button.dart';

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
  bool _allowHints = true;

  Future<void> _handleGlowToggle(bool glowEnabled) async {
    if (mounted) setState(() => _allowHints = false);

    await _slideCtrl.close();

    ref.read(wordHubGlowProvider.notifier).state = !glowEnabled;
  }

  Widget _buildFrontButton() {
    return SizedBox(
      width: _frontButtonWidth,
      height: 36,
      child: TextButton(
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
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
              const Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Word Hub', overflow: TextOverflow.ellipsis),
                ),
              ),
              Positioned(
                right: 12,
                top: 6,
                child: SlideHintButton(
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
                  child: _buildFrontButton(),
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
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Suche
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
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
            _SectionHeader(section.title),
            _GridSection(
              sectionKey: section.key,
              subs: section.subcats,
              repo: repo,
              onTapSub: (sub) async {
                String? catId;
                try {
                  catId = (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
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
                  final (kind, value) = _mapToFilter(section.key, sub.label);
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
    );
  }
}

(WordFilterKind, String) _mapToFilter(String sectionKey, String label) {
  if (sectionKey == 'levels_progress') {
    return (WordFilterKind.level, label);
  }
  return (WordFilterKind.about, label);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _GridSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => CategoryCard(
            sectionKey: sectionKey,
            sub: subs[i],
            onTap: onTapSub == null ? null : () => onTapSub!(subs[i]),
          ),
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

String _slugifyLocal(String s) {
  return s
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
