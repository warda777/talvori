import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';

Future<void> showPracticePicker(BuildContext context) {
  const double btnWidth = 140;
  const double btnHeight = 52;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;

      final bottomInset = MediaQuery.of(ctx).padding.bottom;
      const navBottomPadding = 12.0;
      const overlapAdjust = 6.0;
      final bottom = bottomInset + navBottomPadding + overlapAdjust;

      final ButtonStyle pillTonal = FilledButton.styleFrom(
        backgroundColor: cs.secondaryContainer,
        foregroundColor: cs.onSecondaryContainer,
        shape: const StadiumBorder(),
        padding: EdgeInsets.zero,
        minimumSize: const Size(btnWidth, btnHeight),
        fixedSize: const Size(btnWidth, btnHeight),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );

      const TextStyle labelStyle =
          TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.2);

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(ctx),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: btnWidth,
                  height: btnHeight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CourseScreen()),
                      );
                    },
                    style: pillTonal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_rounded, size: 22),
                        SizedBox(width: 8),
                        Text('course', style: labelStyle),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: btnWidth,
                  height: btnHeight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VocabScreen()),
                      );
                    },
                    style: pillTonal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_rounded, size: 22),
                        SizedBox(width: 8),
                        Text('vocab', style: labelStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
