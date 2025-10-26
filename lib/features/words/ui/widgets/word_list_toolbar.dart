import 'package:flutter/material.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/ui/common/mini_badge.dart';

class WordListToolbar extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;
  final SortMode sort;
  final ValueChanged<SortMode> onSortChanged;
  final int visibleCount;
  final bool offline; // NEU

  const WordListToolbar({
    super.key,
    required this.onQueryChanged,
    required this.sort,
    required this.onSortChanged,
    required this.visibleCount,
    this.offline = false, // NEU
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Suchen (Wort oder Übersetzung)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<SortMode>(
                  segments: const [
                    ButtonSegment(value: SortMode.az, label: Text('A–Z')),
                    ButtonSegment(value: SortMode.newest, label: Text('Neueste')),
                  ],
                  selected: {sort},
                  onSelectionChanged: (s) => onSortChanged(s.first),
                ),
              ),
              const SizedBox(width: 12),
              Text('$visibleCount'),
              if (offline) ...[
                const SizedBox(width: 8),
                const MiniBadge(icon: Icons.cloud_off, label: 'Offline'),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
