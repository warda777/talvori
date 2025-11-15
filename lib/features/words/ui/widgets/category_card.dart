import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/events/events.dart';
import 'package:talvori/features/words/application/sort/category_stroke_colors.dart';
import 'package:talvori/features/words/application/word_hub_glow_provider.dart';
import 'package:talvori/features/words/application/word_hub_tile_overrides_provider.dart';
import 'package:talvori/features/words/application/radial_palette_controller.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/application/category_stats_provider.dart';
import 'shimmer_box.dart';

class CategoryCard extends ConsumerStatefulWidget {
  final String sectionKey;
  final HubSubcat sub;
  final VoidCallback? onTap;
  final String? paletteId; // Eindeutige ID für Farb-Overrides
  final GlobalKey? titleKey; // Key für Titel-Target
  final GlobalKey? countKey; // Key für Counter-Target
  final GlobalKey? iconKey; // NEU: Key für Icon/Emoji-Target

  const CategoryCard({
    required this.sectionKey,
    required this.sub,
    this.onTap,
    this.paletteId,
    this.titleKey,
    this.countKey,
    this.iconKey, // NEU
    super.key,
  });

  @override
  ConsumerState<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends ConsumerState<CategoryCard>
    with WidgetsBindingObserver {
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
    final loading =
        asyncStats.isLoading && stats == null; // 👈 nur dann "echt" laden
    final String normalizedLabel = widget.sub.label
        .toLowerCase()
        .trim()
        .replaceAll('&', 'and');
    final Color defaultStrokeColor = CategoryStrokeColors.getStrokeColor(
      widget.sub.label,
    );
    final glowEnabled = ref.watch(wordHubGlowProvider);
    
    // Farb-Overrides lesen
    final overrides = widget.paletteId != null
        ? ref.watch(wordHubTileOverridesProvider)[widget.paletteId!]
        : null;
    final titleColor = overrides?.titleColor ?? Colors.white;
    final countColor = overrides?.countColor ?? const Color(0xFFF1C86B);
    final strokeColor = overrides?.strokeColor ?? defaultStrokeColor;
    final fillColor = overrides?.fillColor ?? const Color(0xFF040404);
    final icon = overrides?.icon;
    final emoji = overrides?.emoji;
    final iconColor = overrides?.iconColor; // NEU: Icon-Farbe (nur wenn gesetzt)
    
    // Fokus-IDs auslesen
    final palette = ref.watch(radialPaletteProvider);
    final focusedIds = palette.focusedIds;
    
    final baseId = widget.paletteId ?? 'wordHub.${widget.sectionKey}.${widget.sub.key}';
    final isTitleFocused = focusedIds.contains('$baseId.title');
    final isCountFocused = focusedIds.contains('$baseId.count');
    final isIconFocused = focusedIds.contains('$baseId.icon'); // NEU: Icon-Fokus prüfen

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.none,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
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
            borderRadius: BorderRadius.circular(24),
            boxShadow: glowEnabled
                ? [
                    BoxShadow(
                      color: (overrides?.strokeColor ?? defaultStrokeColor).withOpacity(0.32),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: (overrides?.strokeColor ?? defaultStrokeColor).withOpacity(0.18),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ]
                : const [],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: strokeColor.withOpacity(0.85),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardSize = math.min(constraints.maxWidth, constraints.maxHeight);
                  final iconSize = cardSize * 0.67; // Ca. 2/3 der Kachel
                  
                  return Stack(
                    children: [
                      // Icon/Emoji in der Mitte (hinter Text/Counter)
                      if (icon != null || emoji != null)
                        Positioned.fill(
                          child: Center(
                            child: KeyedSubtree(
                              key: widget.iconKey, // NEU: Key für Icon-Target
                              child: _buildIcon(icon, emoji, iconColor, iconSize, isIconFocused),
                            ),
                          ),
                        ),
                      // Text/Counter oben drauf
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            loading
                                ? const ShimmerBox(height: 18, borderRadius: 6)
                                : _buildTitle(t, titleColor, isTitleFocused, ref),
                            const Spacer(),
                            if (loading)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: SizedBox(
                                  width: 36,
                                  child: const ShimmerBox(
                                    height: 14,
                                    borderRadius: 6,
                                  ),
                                ),
                              )
                              else if (stats != null)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: _buildCount(stats.total, countColor, isCountFocused, ref),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData t, Color titleColor, bool isTitleFocused, WidgetRef ref) {
    Widget title = Text(
      widget.sub.label,
      key: widget.titleKey, // 🔹 der Key, damit das Target gemessen werden kann
      style: t.textTheme.titleMedium?.copyWith(
        color: titleColor,
      ),
    );

    if (isTitleFocused) {
      title = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // kleine Radien an den Ecken
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [], // Kein Glow mehr, nur Rahmen
        ),
        child: title,
      );
    }

    return title;
  }

  Widget _buildIcon(IconData? icon, String? emoji, Color? iconColor, double iconSize, bool isIconFocused) {
    Widget iconWidget = icon != null
        ? Icon(
            icon,
            color: iconColor ?? Colors.white, // Standard weiß für Icons
            size: iconSize,
          )
        : iconColor != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  // Originales Emoji mit reduzierter Opazität als Basis
                  Text(
                    emoji!,
                    style: TextStyle(
                      fontSize: iconSize,
                      color: Colors.white.withOpacity(0.3), // Leicht transparent für Konturen
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Gefärbtes Emoji darüber mit BlendMode.modulate
                  ColorFiltered(
                    // BlendMode.modulate multipliziert die Farben, behält aber die Struktur
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.modulate),
                    child: Text(
                      emoji!,
                      style: TextStyle(
                        fontSize: iconSize,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : Text(
                // NEU: Kein ColorFilter, wenn iconColor nicht gesetzt ist
                emoji!,
                style: TextStyle(
                  fontSize: iconSize,
                ),
                textAlign: TextAlign.center,
              );

    // NEU: Border wenn Icon fokussiert ist
    if (isIconFocused) {
      iconWidget = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  Widget _buildCount(int count, Color countColor, bool isCountFocused, WidgetRef ref) {
    Widget countWidget = Text(
      '$count',
      key: widget.countKey, // 🔹 Key für das Counter-Target
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: countColor, // Verwendet Override-Farbe oder Standard-Farbe
      ),
    );

    if (isCountFocused) {
      countWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [], // Kein Glow mehr, nur Rahmen
        ),
        child: countWidget,
      );
    }

    return countWidget;
  }
}
