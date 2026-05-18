import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/widgets/mix_donut_toggle.dart';

class BurgerSectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onSelectAll;
  final List<BurgerItem> items;
  final Color? background;
  final bool allSelected; // Ob alle Items ausgewählt sind

  const BurgerSectionCard({
    super.key,
    required this.title,
    required this.onSelectAll,
    required this.items,
    this.background,
    this.allSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF5DDCFF);
    const violet = Color(0xFFB36BFF);
    final bg = background ?? const Color(0xFF09111C);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (items.length > 1)
                  TextButton(
                    onPressed: onSelectAll,
                    style: TextButton.styleFrom(
                      foregroundColor: allSelected ? cyan : Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Alle auswählen'),
                  )
                else
                  const SizedBox(height: 40),
              ],
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cyan.withValues(alpha: 0.28)),
                boxShadow: [
                  BoxShadow(
                    color: violet.withValues(alpha: 0.08),
                    blurRadius: 28,
                    spreadRadius: -4,
                  ),
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _BurgerRow(
                      label: items[i].label,
                      selected: items[i].selected,
                      onChanged: items[i].onChanged,
                      isTop: i == 0,
                      isBottom: i == items.length - 1,
                    ),
                    if (i != items.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BurgerItem {
  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;
  const BurgerItem({
    required this.label,
    required this.selected,
    required this.onChanged,
  });
}

class _BurgerRow extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final bool isTop;
  final bool isBottom;

  const _BurgerRow({
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.isTop,
    required this.isBottom,
  });

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF5DDCFF);
    const violet = Color(0xFFB36BFF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!selected),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? cyan.withValues(alpha: 0.08) : Colors.transparent,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              MixDonutToggle(
                value: selected,
                onChanged: onChanged,
                activeRing: cyan,
                activeCore: violet,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
