import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/core/events/events.dart';
import 'dart:async';


// Repo top-level (vermeidet const-Konstruktor-Fehler)
final _repo = SupabaseWordRepository();

class WordHubScreen extends StatelessWidget {
  const WordHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

          // Dynamische Bereiche aus hubSections
          for (final section in hubSections) ...[
            _SectionHeader('${section.title} • ${section.focus}'),
            _GridSection(
              sectionKey: section.key,
              subs: section.subcats,
              repo: _repo,
              onTapSub: (sub) async {
                String? catId;

                try {
                  // 1) UUID aus Taxonomie oder dynamisch per Name
                  catId = (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
                      ? sub.supabaseId
                      : await _repo.findCategoryIdByName(sub.label);
                } catch (e) {
                  // Lookup fehlgeschlagen – wir navigieren trotzdem via Fallback
                  catId = null;
                }

                // Context nach await prüfen
                if (!context.mounted) return;
                
                // Fehler-SnackBar nur anzeigen, wenn Context noch gültig ist
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
                  // 2) Sicherer Fallback (Tags/Level), immer navigieren
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

  // Mapping: Level explizit; Rest vorerst als Tag („about“)
  (WordFilterKind, String) _mapToFilter(String sectionKey, String label) {
    if (sectionKey == 'levels_progress') {
      return (WordFilterKind.level, label);
    }
    return (WordFilterKind.about, label);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
          (context, i) => _CategoryCard(
            sectionKey: sectionKey,
            sub: subs[i],
            repo: repo,
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

class _CategoryCard extends StatefulWidget {
  final String sectionKey;
  final HubSubcat sub;
  final SupabaseWordRepository repo;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.sectionKey,
    required this.sub,
    required this.repo,
    this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> with WidgetsBindingObserver {
  int? _total;
  int? _dueToday;
  int? _newTotal;
  bool _loading = true;
  
  // Reset-Event Listener
  StreamSubscription<String>? _resetSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Lausche auf Reset-Events
    _resetSubscription = ResetEvent.stream.listen((categoryId) {
      // Lade für alle Kategorien neu (da wir nicht wissen, welche Kategorie betroffen ist)
      _load();
    });
    
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Lade Daten neu, wenn die App wieder aktiv wird (z.B. nach Reset im Lernmodus)
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      String? catId = (widget.sub.supabaseId != null && widget.sub.supabaseId!.isNotEmpty)
          ? widget.sub.supabaseId
          : await widget.repo.findCategoryIdByName(widget.sub.label);

      if (catId != null) {
        final prog = await fetchCategoryProgress(catId);
        final wl = await fetchWorkloadToday(catId);
        if (!mounted) return;
        setState(() {
          _total = prog.total;
          _dueToday = wl.dueToday;
          _newTotal = prog.stages[0]; // Stage 0 = neue Wörter (korrekte Berechnung)
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _loading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Material(
      color: t.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias, // für saubere Ripple
      child: InkWell(
        onTap: widget.onTap, // Navigation kommt aus dem Parent
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: t.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (_loading)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const Spacer(),
                if (!_loading && _dueToday != null) _MiniBadge(icon: Icons.refresh, label: '$_dueToday'),
                const SizedBox(width: 6),
                if (!_loading && _newTotal != null) _MiniBadge(icon: Icons.fiber_new, label: '$_newTotal'),
              ]),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Text(widget.sub.label, style: t.textTheme.titleMedium)),
                  if (!_loading && _total != null) Text('$_total', style: t.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  const _MiniBadge({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: t.colorScheme.surface, // modern, neutral
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const SizedBox(width: 4),
          ],
          Text(label, style: t.textTheme.labelSmall),
        ],
      ),
    );
  }
}
