import 'package:flutter/material.dart';
import 'package:talvori/features/push/data/daily_picks_store.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DailyPicksStore.I;

    // Reagiert live, wenn du über QuickSend Wörter hinzufügst
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final count = store.items.length;
        final max   = store.maxCount;
        final full  = count >= max;

        return Scaffold(
          appBar: AppBar(
            title: Text("Course  •  $count/$max picks"),
            actions: [
              IconButton(
                tooltip: full ? 'Send now' : 'Send (need ${max - count} more)',
                onPressed: count == 0
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Mark as sent?'),
                            content: Text(
                              full
                                  ? 'Send $count words now and clear the list?'
                                  : 'You have only $count of $max picks.\nSend anyway and clear the list?',
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send')),
                            ],
                          ),
                        );
                        if (!context.mounted) return;

                        if (ok == true) {
                          store.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Daily picks cleared')),
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
                      ? 'Ready: You reached your $max picks.'
                      : 'Pick ${max - count} more word${max - count == 1 ? '' : 's'}.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (store.items.isEmpty)
                  Text('No picks yet. Use the ↓ button on the Home card to add.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final w in store.items)
                        Chip(
                          label: Text(w),
                          onDeleted: () => store.remove(w),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
