import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';
import 'package:talvori/features/home/application/application.dart';

// Einheitliche Größe für die runden Bottom-Buttons (Category/Profile)
const double kTopBtnSize = 52; // oder 52 – nimm deinen Zielwert

class HomeBottomNav extends ConsumerWidget {
  final VoidCallback onImpulseInbox;
  final VoidCallback onPractice;
  final VoidCallback onProfile;
  final bool impulseActive;
  final int impulseUnreadCount;
  final bool practiceActive;
  final GlobalKey? practiceButtonKey;

  const HomeBottomNav({
    super.key,
    required this.onImpulseInbox,
    required this.onPractice,
    required this.onProfile,
    this.impulseActive = false,
    this.impulseUnreadCount = 0,
    this.practiceActive = false,
    this.practiceButtonKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glowEnabled = ref.watch(
      homeControllerProvider.select((s) => s.glowEnabled),
    );
    const wheelBlue = Color(0xFF5DDCFF);
    const violet = Color(0xFFB36BFF);
    const buttonColor = Color(0xFF07101A);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox.square(
            dimension: kTopBtnSize,
            child: GestureDetector(
              key: const Key('home-impuls-postfach-button'),
              behavior: HitTestBehavior.opaque,
              onTap: onImpulseInbox,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TapFlash(
                    color: wheelBlue,
                    shape: BoxShape.circle,
                    maxOpacity: 0.72,
                    blur: 36,
                    spread: -2,
                    duration: const Duration(milliseconds: 220),
                    onTapAfter: onImpulseInbox,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: buttonColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: wheelBlue, width: 1.5),
                        boxShadow: glowEnabled
                            ? [
                                BoxShadow(
                                  color: wheelBlue.withValues(alpha: 0.29),
                                  blurRadius: 38,
                                  spreadRadius: -2,
                                ),
                                BoxShadow(
                                  color: wheelBlue.withValues(alpha: 0.11),
                                  blurRadius: 68,
                                  spreadRadius: -8,
                                ),
                                BoxShadow(
                                  color: wheelBlue.withValues(alpha: 0.05),
                                  blurRadius: 88,
                                  spreadRadius: -14,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (impulseActive)
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: wheelBlue, width: 1.5),
                        ),
                      ),
                    ),
                  if (impulseUnreadCount > 0)
                    Positioned(
                      key: const Key('home-impuls-postfach-unread-badge'),
                      right: 2,
                      top: 1,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5F7A),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: buttonColor, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          impulseUnreadCount > 9
                              ? '9+'
                              : impulseUnreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: 168,
            height: 52,
            child: GestureDetector(
              key: const Key('home-practice-button'),
              behavior: HitTestBehavior.opaque,
              onTap: onPractice,
              child: TapFlash(
                color: violet,
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                maxOpacity: 0.72,
                blur: 36,
                spread: -2,
                duration: const Duration(milliseconds: 220),
                onTapAfter: onPractice,
                child: Container(
                  key: practiceButtonKey,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    border: Border.all(color: violet, width: 1.5),
                    boxShadow: glowEnabled
                        ? [
                            BoxShadow(
                              color: violet.withValues(alpha: 0.27),
                              blurRadius: 38,
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: violet.withValues(alpha: 0.11),
                              blurRadius: 68,
                              spreadRadius: -8,
                            ),
                            BoxShadow(
                              color: violet.withValues(alpha: 0.05),
                              blurRadius: 88,
                              spreadRadius: -14,
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sports_esports_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Wortspiele',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox.square(
            dimension: 52,
            child: TapFlash(
              color: wheelBlue,
              shape: BoxShape.circle,
              maxOpacity: 0.72,
              blur: 36,
              spread: -2,
              duration: const Duration(milliseconds: 220),
              onTapAfter: onProfile,
              child: Container(
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: wheelBlue, width: 1.5),
                  boxShadow: glowEnabled
                      ? [
                          BoxShadow(
                            color: wheelBlue.withValues(alpha: 0.29),
                            blurRadius: 38,
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: wheelBlue.withValues(alpha: 0.11),
                            blurRadius: 68,
                            spreadRadius: -8,
                          ),
                          BoxShadow(
                            color: wheelBlue.withValues(alpha: 0.05),
                            blurRadius: 88,
                            spreadRadius: -14,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
