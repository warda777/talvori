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

    // Suche + Sort lokal auf sichtbarer Liste anwenden
    final filtered = _applyQuery(state.words, state.query);
    final sorted = _applySort(filtered, state.sort);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          WordListToolbar(
            onQueryChanged: ctrl.setQueryDebounced, // <-- statt ctrl.setQuery
            sort: state.sort,
            onSortChanged: ctrl.setSort,
            visibleCount: sorted.length,
          ),
          Expanded(
            child: state.isFirstLoad
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => ctrl.loadFirstPage(),
                    child: _buildList(context, sorted, state, ctrl),
                  ),
          ),
        ],
      ),
    );
  }

  List<Word> _applyQuery(List<Word> input, String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return input;
    return input
        .where((w) =>
            w.text.toLowerCase().contains(query) ||
            w.translation.toLowerCase().contains(query))
        .toList();
  }

  List<Word> _applySort(List<Word> input, SortMode mode) {
    final list = List<Word>.from(input);
    switch (mode) {
      case SortMode.az:
        list.sort((a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
        break;
      case SortMode.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return list;
  }

  Widget _buildList(BuildContext context, List<Word> list, WordListState state,
      WordListController ctrl) {
    if (list.isEmpty) {
      return const Center(child: Text('Keine Wörter gefunden.'));
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
