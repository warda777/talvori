import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/ui/widgets/widgets.dart';

class WordHubScreen extends ConsumerWidget {
  const WordHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final vm = ref.watch(wordHubControllerProvider);
    final controller = ref.read(wordHubControllerProvider.notifier);
    final repo = controller.repo;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Schließen',
        ),
        title: const Text('Word Hub'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                // TODO: Paywall / Unlock-All
              },
              child: const Text('Alles freischalten'),
            ),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 800) { // nahe am Ende
            controller.loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
          // Suche
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                textInputAction: TextInputAction.search,
                onChanged: (q) => controller.searchDebounced(q.trim()),
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
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

          // Dynamische Bereiche
          for (final section in hubSections) ...[
            SectionHeader('${section.title} • ${section.focus}'),
            GridSection(
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
                    const SnackBar(content: Text('Hinweis: Kategorie-Lookup nicht möglich. Fallback aktiv.')),
                  );
                }

                if (catId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        title: sub.label,
                        categoryId: catId!,
                        categorySlug: null,
                        listFilter: WordListFilter(WordFilterKind.category, catId),
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

          if (vm.loading && vm.canLoadMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: bottomInset + 10)),
        ],
        ),
      ),
    );
  }

  (WordFilterKind, String) _mapToFilter(String sectionKey, String label) {
    if (sectionKey == 'levels_progress') {
      return (WordFilterKind.level, label);
    }
    return (WordFilterKind.about, label);
  }
}

String _slugifyLocal(String s) {
  return s
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
