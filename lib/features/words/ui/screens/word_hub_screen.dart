import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

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

          // Über uns
          _SectionHeader('Über uns'),
          _GridSection(
            items: const ['Menschen', 'Körper', 'Essen'],
            locks: const [false, true, true],
            onTapItem: (label) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WordListScreen(
                    filter: WordListFilter(WordFilterKind.about, label),
                  ),
                ),
              );
            },
          ),

          // Nach Fachgebiet
          _SectionHeader('Nach Fachgebiet'),
          _GridSection(
            items: const ['Technik', 'Wissenschaft', 'Medizin', 'Literatur'],
            locks: const [true, true, true, true],
            onTapItem: (label) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WordListScreen(
                    filter: WordListFilter(WordFilterKind.domain, label),
                  ),
                ),
              );
            },
          ),

          // Nach Wortart
          _SectionHeader('Nach Wortart'),
          _GridSection(
            items: const ['Verben', 'Nomen', 'Adjektive'],
            locks: const [true, true, true],
            onTapItem: (label) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WordListScreen(
                    filter: WordListFilter(WordFilterKind.pos, label),
                  ),
                ),
              );
            },
          ),

          // Nach Level
          _SectionHeader('Nach Level'),
          _GridSection(
            items: const ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
            locks: const [true, true, true, true, true, true],
            onTapItem: (label) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WordListScreen(
                    filter: WordListFilter(WordFilterKind.level, label),
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: bottomInset + 10), // extra Luft über dem Home-Indicator
          ),
        ],
      ),
    );
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
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _GridSection extends StatelessWidget {
  final List<String> items;
  final List<bool>? locks;
  final void Function(String label)? onTapItem;

  const _GridSection({required this.items, this.locks, this.onTapItem});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _CategoryCard(
            label: items[i],
            locked: locks != null ? locks![i] : false,
            onTap: onTapItem == null ? null : () => onTapItem!(items[i]),
          ),
          childCount: items.length,
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

class _CategoryCard extends StatelessWidget {
  final String label;
  final bool locked;
  final VoidCallback? onTap;

  const _CategoryCard({required this.label, this.locked = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // In Debug immer öffnen; in Release gesperrt lassen
        if (locked && !kDebugMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Premium-Bereich – „Alles freischalten“, um Zugriff zu erhalten.')),
          );
          return;
        }
        onTap?.call();
      },
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Stack(
          children: [
            // Label
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(label, style: theme.textTheme.titleMedium),
                ),
              ),
            ),
            // Lock
            if (locked)
              const Positioned(
                right: 10,
                top: 10,
                child: Icon(Icons.lock_outline, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

