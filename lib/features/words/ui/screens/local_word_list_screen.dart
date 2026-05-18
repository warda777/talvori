import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/features/words/ui/screens/local_word_detail_screen.dart';

enum _LocalWordSortMode {
  termAz('A–Z nach Wort'),
  termZa('Z–A nach Wort'),
  translationAz('A–Z nach Übersetzung'),
  translationZa('Z–A nach Übersetzung');

  const _LocalWordSortMode(this.label);

  final String label;
}

class LocalWordListScreen extends ConsumerStatefulWidget {
  const LocalWordListScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  final String categoryId;
  final String title;

  @override
  ConsumerState<LocalWordListScreen> createState() =>
      _LocalWordListScreenState();
}

class _LocalWordListScreenState extends ConsumerState<LocalWordListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _LocalWordSortMode _sortMode = _LocalWordSortMode.termAz;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(
      localWordsForCategoryProvider(widget.categoryId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('Lokale Wörter konnten nicht geladen werden'),
        ),
        data: (words) {
          if (words.isEmpty) {
            return const Center(child: Text('Keine lokalen Wörter verfügbar'));
          }

          final visibleWords = _sortWords(_filterWords(words));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Suchen',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: DropdownButtonFormField<_LocalWordSortMode>(
                  initialValue: _sortMode,
                  decoration: InputDecoration(
                    labelText: 'Sortierung',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: _LocalWordSortMode.values
                      .map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(mode.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (mode) {
                    if (mode == null) return;
                    setState(() => _sortMode = mode);
                  },
                ),
              ),
              Expanded(
                child: visibleWords.isEmpty
                    ? const Center(
                        child: Text('Keine passenden Wörter gefunden'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visibleWords.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final word = visibleWords[index];
                          return ListTile(
                            title: Text(word.term),
                            subtitle: Text(word.translation),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LocalWordDetailScreen(
                                    wordId: word.id,
                                    categoryId: word.categoryId,
                                    title: widget.title,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<LocalWord> _filterWords(List<LocalWord> words) {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return words;
    }

    return words
        .where(
          (word) =>
              word.term.toLowerCase().contains(normalizedQuery) ||
              word.translation.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  List<LocalWord> _sortWords(List<LocalWord> words) {
    final sorted = [...words];
    int compareText(String left, String right) {
      return left.toLowerCase().compareTo(right.toLowerCase());
    }

    sorted.sort((left, right) {
      return switch (_sortMode) {
        _LocalWordSortMode.termAz => compareText(left.term, right.term),
        _LocalWordSortMode.termZa => compareText(right.term, left.term),
        _LocalWordSortMode.translationAz => compareText(
          left.translation,
          right.translation,
        ),
        _LocalWordSortMode.translationZa => compareText(
          right.translation,
          left.translation,
        ),
      };
    });

    return sorted;
  }
}
