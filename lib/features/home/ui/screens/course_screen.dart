import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_provider.dart';

class CourseScreen extends ConsumerWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(tagesimpulsSelectionControllerProvider);
    final controller = ref.read(
      tagesimpulsSelectionControllerProvider.notifier,
    );
    final count = selection.count;
    final max = selection.maxCount;
    final full = selection.isFull;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tagesimpuls  •  $count/$max'),
        actions: [
          IconButton(
            tooltip: count == 0 ? 'Keine Wörter ausgewählt' : 'Auswahl leeren',
            onPressed: count == 0
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Tagesimpuls leeren?'),
                        content: Text(
                          full
                              ? 'Alle $count Wörter aus der Auswahl entfernen?'
                              : 'Du hast $count von $max Wörtern ausgewählt. Auswahl leeren?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Abbrechen'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Leeren'),
                          ),
                        ],
                      ),
                    );
                    if (!context.mounted) return;

                    if (ok == true) {
                      await controller.clear();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tagesimpuls-Auswahl geleert'),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.outbound_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              full
                  ? 'Bereit: Du hast $max Wörter für den Tagesimpuls gewählt.'
                  : 'Wähle noch ${max - count} Wort${max - count == 1 ? '' : 'er'} aus.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (selection.items.isEmpty)
              Text(
                'Noch keine Wörter ausgewählt. Nutze den Pfeil auf der Home-Karte.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in selection.items)
                    Chip(
                      label: Text(item.text),
                      onDeleted: () => controller.remove(item),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
