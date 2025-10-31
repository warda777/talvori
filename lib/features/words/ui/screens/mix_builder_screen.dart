import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
import 'package:talvori/features/words/ui/widgets/section_header.dart';
import 'package:talvori/features/words/ui/widgets/burger_section_card.dart';

class MixBuilderScreen extends ConsumerStatefulWidget {
  const MixBuilderScreen({super.key});

  @override
  ConsumerState<MixBuilderScreen> createState() => _MixBuilderScreenState();
}

class _MixBuilderScreenState extends ConsumerState<MixBuilderScreen> {
  final TextEditingController _search = TextEditingController();
  
  // State für Auswahl
  final Map<String, bool> _sel = {}; // label -> selected
  bool _isSel(String label) => _sel[label] ?? false;
  void _setSel(String label, bool v) => setState(() => _sel[label] = v);
  void _selectAll(Iterable<String> labels) => setState(() {
    for (final l in labels) { _sel[l] = true; }
  });
  bool _areAllSelected(Iterable<String> labels) {
    if (labels.isEmpty) return false;
    return labels.every((l) => _isSel(l));
  }
  void _toggleAll(Iterable<String> labels) => setState(() {
    final allSelected = _areAllSelected(labels);
    for (final l in labels) { _sel[l] = !allSelected; }
  });

  static const _gold = Color(0xFFF1C86B); // wie im Category-Popup
  static const _groups = <_Group>[
    _Group('Your collections', ['Want to memorize']),
    _Group('Action & Adventure', ['Gaming', 'Sports', 'Transport', 'Travel']),
    _Group('Culture & Creativity', ['Music & Entertainment', 'Art & Literature', 'Noch nicht besetzt']),
    _Group('Life & Daily Flow', ['Food & Cooking', 'Health & Fitness', 'Home & Living', 'Money & Shopping', 'Style & Fashion']),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top-Bar (Back + More)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        foregroundColor: cs.onSurface,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Make your own mix',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Suche
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: TextField(
                  controller: _search,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Suchen',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    isDense: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                ),
              ),
            ),

            // Select all (Gold)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SizedBox(
                  height: 46,
                  child: FilledButton(
                    onPressed: () {
                      // Alle Labels aus _groups auswählen
                      _selectAll(_groups.expand((g) => g.items));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: const Text('Pick all', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ),

            // Gruppenlisten
            for (final g in _groups) ...[
              SliverToBoxAdapter(
                child: BurgerSectionCard(
                  title: g.title,
                  onSelectAll: () => _toggleAll(g.items),
                  allSelected: _areAllSelected(g.items),
                  items: [
                    for (final item in g.items)
                      BurgerItem(
                        label: item,
                        selected: _isSel(item),
                        onChanged: (v) => _setSel(item, v),
                      ),
                  ],
                ),
              ),
            ],

            // Bottom-Spacer
            const SliverToBoxAdapter(child: SizedBox(height: WordsLayout.pageBottomPadding)),
          ],
        ),
      ),
      // Bottom-CTA (Start)
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () {
                // TODO: Selektion in "my-mix" speichern und Learn-Mode starten
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Group {
  final String title;
  final List<String> items;
  const _Group(this.title, this.items);
}

class _MixRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _MixRow({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 22,
              color: selected ? cs.primary : cs.outline,
            ),
          ],
        ),
      ),
    );
  }
}
