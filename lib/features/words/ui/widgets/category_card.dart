import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/events/events.dart';
import 'package:talvori/features/home/ui/widgets/food_bowl_bg.dart';
import 'package:talvori/features/home/ui/widgets/health_pulse_bg.dart';
import 'package:talvori/features/home/ui/widgets/home_silhouette_bg.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/application/category_stats_provider.dart';
import 'mini_badge.dart';
import 'shimmer_box.dart';

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
    final stats = asyncStats.value; // kann schon befüllt sein
    final loading = asyncStats.isLoading && stats == null; // 👈 nur dann "echt" laden
    final String normalizedLabel = widget.sub.label.toLowerCase().trim().replaceAll('&', 'and');
    final bool isHealth = normalizedLabel == 'health and fitness';
    final bool isHomeLiving = normalizedLabel == 'home and living';
    final bool isFoodCooking = normalizedLabel == 'food and cooking';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.none,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          if (widget.onTap != null) widget.onTap!();
        },
        overlayColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        ),
        splashFactory: InkRipple.splashFactory,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFAFCCFE).withOpacity(0.55),
                blurRadius: 28,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: const Color(0xFFAFCCFE).withOpacity(0.35),
                blurRadius: 46,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: (isHealth || isHomeLiving || isFoodCooking)
                  ? Colors.black
                  : t.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFAFCCFE).withOpacity(0.85), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isHealth) const HealthPulseBackground()
                  else if (isHomeLiving) const HomeSilhouetteBackground()
                  else if (isFoodCooking)
                    const FoodBowlBackground(
                      scale: 0.36,
                      yAlign: 0.62,
                      speed: 0.9,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        loading
                            ? const ShimmerBox(height: 18, borderRadius: 6)
                            : Text(widget.sub.label, style: t.textTheme.titleMedium),
                        const Spacer(),
                        if (loading)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: SizedBox(
                              width: 36,
                              child: const ShimmerBox(height: 14, borderRadius: 6),
                            ),
                          )
                        else if (stats != null)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${stats.total}',
                              style: t.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
