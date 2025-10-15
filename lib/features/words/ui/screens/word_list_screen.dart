import 'package:flutter/material.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

// Filter-Modell
enum WordFilterKind { about, domain, pos, level, query }
class WordListFilter {
  final WordFilterKind kind;
  final String value;
  const WordListFilter(this.kind, this.value);
}

// Sortiermodus (Top-Level)
enum SortMode { az, newest }

class WordListScreen extends StatefulWidget {
  final WordListFilter filter;
  const WordListScreen({super.key, required this.filter});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final _repo = SupabaseWordRepository();
  final _scroll = ScrollController();

  final List<Word> _words = [];
  final Set<String> _picked = {}; // Quick-Add Häkchen

  bool _isFirstLoad = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _authMissingWarned = false; // SnackBar nicht spammen

  int _offset = 0;
  final int _pageSize = 50;

  String _query = '';
  SortMode _sort = SortMode.az;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isFirstLoad = true;
      _words.clear();
      _picked.clear();
      _offset = 0;
      _hasMore = true;
    });

    // 1) Erste Seite laden
    final batch = await _repo.fetchByFilter(
      widget.filter,
      limit: _pageSize,
      offset: _offset,
    );

    // 2) Bereits markierte IDs für diese Page laden (falls vorhanden)
    Set<String> pickedIds = {};
    if (batch.isNotEmpty) {
      pickedIds = await _repo.getPickedWordIds(batch.map((w) => w.id));
    }

    // 3) State aktualisieren
    setState(() {
      _words.addAll(batch);
      _picked.addAll(pickedIds);
      _offset += batch.length;
      _hasMore = batch.length == _pageSize;
      _isFirstLoad = false;
    });
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    final batch = await _repo.fetchByFilter(
      widget.filter,
      limit: _pageSize,
      offset: _offset,
    );

    // Optional: auch hier bereits gepickte IDs nachladen
    Set<String> pickedIds = {};
    if (batch.isNotEmpty) {
      pickedIds = await _repo.getPickedWordIds(batch.map((w) => w.id));
    }

    setState(() {
      _words.addAll(batch);
      _picked.addAll(pickedIds);
      _offset += batch.length;
      _hasMore = batch.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Word Hub • ${widget.filter.value}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          // Suche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Suchen (Wort oder Übersetzung)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          // Sortier-Toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<SortMode>(
                    segments: const [
                      ButtonSegment(value: SortMode.az,     label: Text('A–Z')),
                      ButtonSegment(value: SortMode.newest, label: Text('Neueste')),
                    ],
                    selected: {_sort},
                    onSelectionChanged: (s) => setState(() => _sort = s.first),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_words.length}'),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: _isFirstLoad
                ? const Center(child: CircularProgressIndicator())
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    // Suche anwenden
    final q = _query.trim().toLowerCase();
    final visible = q.isEmpty
        ? _words
        : _words
            .where((w) =>
                w.text.toLowerCase().contains(q) ||
                w.translation.toLowerCase().contains(q))
            .toList();

    if (visible.isEmpty) {
      return const Center(child: Text('Keine Wörter gefunden.'));
    }

    // Sortierung anwenden
    final list = List<Word>.from(visible);
    switch (_sort) {
      case SortMode.az:
        list.sort((a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
        break;
      case SortMode.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    // Liste mit Pagination-Footer
    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (_isLoadingMore || _hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        if (i >= list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final w = list[i];
        final picked = _picked.contains(w.id);

        return ListTile(
          title: Text(w.text),
          subtitle: Text(w.translation),
          trailing: IconButton(
            icon: Icon(picked ? Icons.check_circle : Icons.add_circle_outline),
            onPressed: () async {
              final wasPicked = picked;
              final messenger = ScaffoldMessenger.of(context); // vor await

              // Optimistisches UI-Update
              setState(() {
                if (picked) {
                  _picked.remove(w.id);
                } else {
                  _picked.add(w.id);
                }
              });

              try {
                if (wasPicked) {
                  await _repo.removeFromMyWords(w.id);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Entfernt: ${w.text}')),
                  );
                } else {
                  await _repo.addToMyWords(w.id);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Hinzugefügt: ${w.text}')),
                  );
                }
              } catch (e) {
                // Rollback
                setState(() {
                  if (wasPicked) {
                    _picked.add(w.id);
                  } else {
                    _picked.remove(w.id);
                  }
                });

                final msg = e.toString();
                if (!_authMissingWarned && msg.contains('Not authenticated')) {
                  _authMissingWarned = true;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Bitte anmelden, um zu speichern.')),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Fehler: $msg')),
                  );
                }
              }
            },
          ),
          onTap: () {
            // Optional: Detail/BottomSheet
          },
        );
      },
    );
  }
}
