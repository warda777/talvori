import 'package:flutter/material.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/domain/word.dart';

class MyWordsScreen extends StatefulWidget {
  const MyWordsScreen({super.key});

  @override
  State<MyWordsScreen> createState() => _MyWordsScreenState();
}

class _MyWordsScreenState extends State<MyWordsScreen> {
  final _repo = SupabaseWordRepository();
  final _scroll = ScrollController();

  final List<Word> _items = [];
  bool _isFirstLoad = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _pageSize = 50;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    setState(() {
      _isFirstLoad = true;
      _items.clear();
      _offset = 0;
      _hasMore = true;
    });

    final batch = await _repo.fetchMyWords(
      limit: _pageSize,
      offset: 0,
      query: _query,
    );

    setState(() {
      _items.addAll(batch);
      _offset = _items.length; // int, korrekt
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

    final batch = await _repo.fetchMyWords(
      limit: _pageSize,
      offset: _offset,
      query: _query,
    );

    setState(() {
      _items.addAll(batch);
      _offset = _items.length; // weiterzählen
      _hasMore = batch.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Wörter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: (_) => _loadFirst(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Suchen in „Meine Wörter“',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          Expanded(
            child: _isFirstLoad
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('Noch keine Wörter gemerkt.'))
                    : ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length + (_isLoadingMore || _hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          if (i >= _items.length) {
                            // Lade-Spinner-Zeile am Ende
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final w = _items[i];
                          return ListTile(
                            title: Text(w.text),
                            subtitle: Text(w.translation),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              tooltip: 'Aus „Meine Wörter“ entfernen',
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context); // vor await holen
                                await _repo.removeFromMyWords(w.id);
                                setState(() => _items.removeAt(i));
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Entfernt: ${w.text}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
