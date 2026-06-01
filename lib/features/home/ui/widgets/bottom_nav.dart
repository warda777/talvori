import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';
import 'package:talvori/features/home/application/application.dart';

// Einheitliche Größe für die runden Bottom-Buttons (Category/Profile)
const double kTopBtnSize = 52; // oder 52 – nimm deinen Zielwert

class HomeBottomNav extends ConsumerWidget {
  final VoidCallback onImpulseInbox;
  final VoidCallback onWords;
  final VoidCallback onPractice;
  final VoidCallback onProfile;
  final bool impulseActive;
  final int impulseUnreadCount;
  final bool practiceActive;
  final GlobalKey? practiceButtonKey;

  const HomeBottomNav({
    super.key,
    required this.onImpulseInbox,
    required this.onWords,
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
    const mint = Color(0xFF9FF7D5);
    const buttonColor = Color(0xFF07101A);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: buttonColor.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: wheelBlue.withValues(alpha: 0.22)),
          boxShadow: glowEnabled
              ? [
                  BoxShadow(
                    color: wheelBlue.withValues(alpha: 0.14),
                    blurRadius: 34,
                    spreadRadius: -8,
                  ),
                  BoxShadow(
                    color: violet.withValues(alpha: 0.1),
                    blurRadius: 44,
                    spreadRadius: -12,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DockItem(
              itemKey: const Key('home-impuls-postfach-button'),
              icon: Icons.forum_rounded,
              label: 'Chat',
              accent: wheelBlue,
              onTap: onImpulseInbox,
              active: impulseActive,
              badgeCount: impulseUnreadCount,
            ),
            _DockItem(
              itemKey: const Key('home-words-import-button'),
              icon: Icons.auto_stories_rounded,
              label: 'Wörter',
              accent: mint,
              onTap: onWords,
            ),
            _DockItem(
              itemKey: const Key('home-practice-button'),
              icon: Icons.sports_esports_rounded,
              label: 'Wortspiele',
              accent: violet,
              onTap: onPractice,
              active: practiceActive,
              childKey: practiceButtonKey,
            ),
            _DockItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              accent: wheelBlue,
              onTap: onProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
    this.itemKey,
    this.childKey,
    this.active = false,
    this.badgeCount = 0,
  });

  final Key? itemKey;
  final Key? childKey;
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final bool active;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TapFlash(
        key: itemKey,
        color: accent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        maxOpacity: 0.58,
        blur: 28,
        spread: -6,
        duration: const Duration(milliseconds: 220),
        onTapAfter: onTap,
        child: Container(
          key: childKey,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? accent.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? accent.withValues(alpha: 0.52)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  key: const Key('home-impuls-postfach-unread-badge'),
                  right: 4,
                  top: 1,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5F7A),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF07101A),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeCount > 9 ? '9+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
