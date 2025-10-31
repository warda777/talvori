import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/mix_builder_screen.dart';

typedef VoidSnack = void Function(String);

Future<void> showCategoryPopup({
  required BuildContext context,
  required Future<void> Function() onRefreshMyWords,
  required VoidSnack onTodo,
}) {
  final cs = Theme.of(context).colorScheme;
  const gold = Color(0xFFF1C86B);

  ButtonStyle pill(BuildContext ctx) => FilledButton.styleFrom(
        backgroundColor: cs.surfaceContainerHighest,
        foregroundColor: cs.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: EdgeInsets.zero,
        fixedSize: const Size(110, 48),
        minimumSize: const Size(110, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );

  Widget content(BuildContext context) => Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: gold, width: 1.6),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Category',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuickSetsDetailScreen(initialIndex: 0)),
                      );
                    },
                    style: pill(context),
                    child: const Text('All words'),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuickSetsDetailScreen(initialIndex: 1)),
                      );
                      await onRefreshMyWords();
                    },
                    style: pill(context),
                    child: const Text('My words'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuickSetsDetailScreen(initialIndex: 2)),
                      );
                    },
                    style: pill(context),
                    child: const Text('Favorites'),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuickSetsDetailScreen(initialIndex: 3)),
                      );
                    },
                    style: pill(context),
                    child: const Text('Words I know'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WordHubScreen()),
                    );
                  },
                  child: Container(
                    width: 232,
                    height: 103,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
                    ),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Word hub',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 180,
                  height: 40,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MixBuilderScreen()),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text('Make your own mix'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) {
      const double navBtn = 52;
      const double navPad = 12;
      const double leftPad = 16;
      const double gap = 10;
      const double offsetX = 8;
      const double offsetY = 32;

      final bottomInset = MediaQuery.of(ctx).padding.bottom;
      final double baseBottom = bottomInset + navPad + navBtn + gap;

      final double posLeft = leftPad + offsetX;
      final double posBottom = baseBottom + offsetY;

      final screen = MediaQuery.of(ctx).size;
      final safeLeft = posLeft.clamp(0.0, screen.width - 280);
      final safeBottom = posBottom.clamp(8.0, screen.height - 415 - 8);

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(ctx),
            ),
          ),
          Positioned(
            left: safeLeft,
            bottom: safeBottom,
            child: SizedBox(
              width: 280,
              height: 415,
              child: content(ctx),
            ),
          ),
        ],
      );
    },
  );
}
