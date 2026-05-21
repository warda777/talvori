import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';
import 'package:talvori/features/home/application/application.dart';

Future<void> showPracticePicker(BuildContext context) {
  const double btnWidth = 156;
  const double btnHeight = 52;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) {
      return Consumer(
        builder: (context, ref, _) {
          final glowEnabled = ref.watch(
            homeControllerProvider.select((s) => s.glowEnabled),
          );

          final bottomInset = MediaQuery.of(ctx).padding.bottom;
          const navBottomPadding = 12.0;
          const overlapAdjust = 6.0;
          final bottom = bottomInset + navBottomPadding + overlapAdjust;

          const wheelBlue = Color(0xFFB0CCFE); // Blau aus Word Wheel
          const buttonColor = Color(0xFF2D2D2E); // Button-Hintergrundfarbe

          const TextStyle labelStyle = TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Colors.white,
          );

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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: buttonColor,
                          border: Border.all(
                            color: wheelBlue,
                            width: 2,
                          ), // Blauer Rand
                          boxShadow: glowEnabled
                              ? [
                                  // Durchgehender blauer Glow
                                  BoxShadow(
                                    color: wheelBlue.withValues(alpha: 0.55),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CourseScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: btnWidth,
                              height: btnHeight,
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.school_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Course', style: labelStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: btnWidth,
                      height: btnHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: buttonColor,
                          border: Border.all(
                            color: wheelBlue,
                            width: 2,
                          ), // Blauer Rand
                          boxShadow: glowEnabled
                              ? [
                                  // Durchgehender blauer Glow
                                  BoxShadow(
                                    color: wheelBlue.withValues(alpha: 0.55),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const VocabScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: btnWidth,
                              height: btnHeight,
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Vocabs', style: labelStyle),
                                ],
                              ),
                            ),
                          ),
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
    },
  );
}
