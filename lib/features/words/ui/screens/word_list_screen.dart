import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/widgets/word_list_toolbar.dart';
import 'package:talvori/features/words/ui/widgets/word_list_item.dart';

class WordListScreen extends ConsumerStatefulWidget {
  final WordListFilter filter;
  final String? titleOverride;
  final String? overrideCategoryId;
  final String? overrideCategoryLabel;

  const WordListScreen({
    super.key,
    required this.filter,
    this.titleOverride,
    this.overrideCategoryId,
    this.overrideCategoryLabel,
  });

  @override
  ConsumerState<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends ConsumerState<WordListScreen> {
  final _scroll = ScrollController();
  late final String _provKey; // stabiler Key für provider family

  @override
  void initState() {
    super.initState();
    _provKey = _buildKey();
    _scroll.addListener(_onScroll);

    // Controller initialisieren
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(wordListControllerProvider(_provKey));
      if (s.isFirstLoad && s.words.isEmpty) {
        ref
            .read(wordListControllerProvider(_provKey).notifier)
            .init(filter: widget.filter, overrideCategoryId: widget.overrideCategoryId);
      }
    });
  }

  String _buildKey() =>
      '${widget.filter.kind}:${widget.overrideCategoryId ?? widget.filter.value}';

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final s = ref.read(wordListControllerProvider(_provKey));
    if (s.isLoadingMore || !s.hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      ref.read(wordListControllerProvider(_provKey).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordListControllerProvider(_provKey));
    final ctrl = ref.read(wordListControllerProvider(_provKey).notifier);
    final effectiveCategoryLabel =
        widget.overrideCategoryLabel ?? widget.filter.value;
    final title = widget.titleOverride ?? 'Word Hub • $effectiveCategoryLabel';

    final list = state.words;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          WordListToolbar(
            onQueryChanged: ctrl.setQueryDebounced, // <-- statt ctrl.setQuery
            sort: state.sort,
            onSortChanged: ctrl.setSort,
            visibleCount: list.length, // statt: sorted.length
          ),
          Expanded(
            child: state.isFirstLoad
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Fehler: ${state.error}', textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => ctrl.loadFirstPage(),
                              child: const Text('Erneut versuchen'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ctrl.loadFirstPage(),
                        child: _buildList(context, list, state, ctrl),
                      ),
          ),
        ],
      ),
    );
  }


  Widget _buildList(BuildContext context, List<Word> list, WordListState state,
      WordListController ctrl) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Keine Wörter gefunden.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                // Suche zurücksetzen + neu laden (serverside)
                ctrl.setQuery('');
                await ctrl.loadFirstPage();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter zurückgesetzt')),
                  );
                }
              },
              child: const Text('Filter zurücksetzen'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      key: PageStorageKey('wordList:$_provKey'),
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (state.isLoadingMore || state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        if (i >= list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final w = list[i];

        return WordListItem(
          word: w,
          picked: state.picked.contains(w.id),
          onTogglePick: () async {
            final msg = await ctrl.togglePick(context, w);
            if (context.mounted && msg != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            }
          },
          onTap: () {}, // optional
        );
      },
    );
  }
}
