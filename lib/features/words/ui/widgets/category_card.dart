import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/events/events.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/application/category_stats_provider.dart';
import 'mini_badge.dart';

class CategoryCard extends ConsumerStatefulWidget {
  final String sectionKey;
  final HubSubcat sub;
  final VoidCallback? onTap;

  const CategoryCard({
    required this.sectionKey,
    required this.sub,
    this.onTap,
    super.key,
  });

  @override
  ConsumerState<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends ConsumerState<CategoryCard> with WidgetsBindingObserver {
  StreamSubscription<String>? _resetSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Invalidate Stats bei Reset-Events
    _resetSubscription = ResetEvent.stream.listen((_) {
      ref.invalidate(categoryStatsProvider(widget.sub));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(categoryStatsProvider(widget.sub));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final asyncStats = ref.watch(categoryStatsProvider(widget.sub));
    final loading = asyncStats.isLoading;
    final stats = asyncStats.value;

    return Material(
      color: t.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
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
                if (loading)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const Spacer(),
                if (!loading && stats != null) ...[
                  MiniBadge(icon: Icons.refresh, label: '${stats.dueToday}'),
                  const SizedBox(width: 6),
                  MiniBadge(icon: Icons.fiber_new, label: '${stats.newTotal}'),
                ],
              ]),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Text(widget.sub.label, style: t.textTheme.titleMedium)),
                  if (!loading && stats != null) Text('${stats.total}', style: t.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
