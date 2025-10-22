import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import 'package:talvori/features/home/ui/widgets/tap_flash.dart';
import 'progress_pill.dart';
import 'package:talvori/features/rewards/ui/screens/rewards_center_screen.dart';

class HomeTopBar extends StatefulWidget {
  final VoidCallback onAllWords;
  final VoidCallback onRewards;         // bleibt für Kompatibilität, wird für Tap genutzt
  final VoidCallback? onProgressTap;
  final int selected;
  final int max;
  final bool showProgress;

  const HomeTopBar({
    super.key,
    required this.onAllWords,
    required this.onRewards,
    this.onProgressTap,
    this.selected = 1,
    this.max = 5,
    this.showProgress = true,
  });

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  // Größen / Layout
  static const double _dim = 52.0;     // Durchmesser deiner Topbar-Buttons
  static const double _quickBtnSize = 56.0; // Größe der Quick-Select-Buttons
  static const double _gap = 16.0;     // Abstand zwischen Krone und Quick-Buttons

  final GlobalKey _crownKey = GlobalKey();
  OverlayEntry? _rewardsOverlay;
  bool _quickOpen = false;

  void _showRewardsQuick(BuildContext context) {
    if (_quickOpen) return;
    final overlay = Overlay.of(context);

    final rb = _crownKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return;

    final crownTopLeft = rb.localToGlobal(Offset.zero);
    final crownSize = rb.size;
    final screenW = MediaQuery.of(context).size.width;

    _quickOpen = true;
    HapticFeedback.mediumImpact();

    _rewardsOverlay = OverlayEntry(
      builder: (ctx) {
        // Basis-Positionen
        double redLeft  = crownTopLeft.dx - _gap - _quickBtnSize;                 // Leaderboard (rot) links
        double blueLeft = crownTopLeft.dx + crownSize.width + _gap;               // Stats (blau) rechts
        final top = crownTopLeft.dy + (crownSize.height - _quickBtnSize) / 2;

        // Sichtbarkeits-Checks
        final roomRightForBlue = blueLeft + _quickBtnSize <= screenW - 8;
        final roomLeftForRed   = redLeft >= 8;

        if (!roomRightForBlue && roomLeftForRed) {
          // Kein Platz rechts -> beide auf die linke Seite
          blueLeft = crownTopLeft.dx - (_gap * 2) - (_quickBtnSize * 2);
        } else if (!roomLeftForRed && roomRightForBlue) {
          // Kein Platz links -> beide auf die rechte Seite
          redLeft  = crownTopLeft.dx + crownSize.width + _gap;
          blueLeft = redLeft + _gap + _quickBtnSize;
        } else if (!roomLeftForRed && !roomRightForBlue) {
          // Extrem eng (sehr kleiner Screen) -> packe Buttons rechts an den Rand
          redLeft  = screenW - _quickBtnSize - 8 - _gap - _quickBtnSize;
          blueLeft = screenW - _quickBtnSize - 8;
        }

        return Stack(
          children: [
            // Tap-Outside: schließt & aktiviert ProgressPill wieder
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hideRewardsQuick,
                child: const SizedBox.expand(),
              ),
            ),

            // Leaderboard (Rot)
            Positioned(
              left: redLeft,
              top: top,
              child: _quickBtn(
                color: const Color(0xFFFE9393),
                icon: Icons.emoji_events_rounded,
                onTap: () {
                  _hideRewardsQuick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RewardsCenterScreen(
                        initialTab: RewardsTab.leaderboard,
                      ),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );
                },
              ),
            ),

            // Stats (Blau)
            Positioned(
              left: blueLeft,
              top: top,
              child: _quickBtn(
                color: const Color(0xFFB0CCFE),
                icon: Icons.bar_chart_rounded,
                onTap: () {
                  _hideRewardsQuick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RewardsCenterScreen(
                        initialTab: RewardsTab.stats,
                      ),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_rewardsOverlay!);
    setState(() {}); // ProgressPill ausblenden
  }


  void _hideRewardsQuick() {
    _rewardsOverlay?.remove();
    _rewardsOverlay = null;
    _quickOpen = false;
    setState(() {}); // Progressbar einblenden
  }

  // runder Quick-Select-Button
  Widget _quickBtn({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _quickBtnSize,
        height: _quickBtnSize,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: _dim,
      child: Row(
        children: [
          // ───────── links: V-Button (rund) mit TapFlash ─────────
          SizedBox.square(
            dimension: _dim,
            child: TapFlash(
              color: cs.primary, // Flash-Farbe
              shape: BoxShape.circle,
              onTapAfter: widget.onAllWords,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/v.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    cs.onSecondaryContainer,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          // ───────── Mitte: Progress-Pill (blendet aus, wenn Quick-Select offen) ─────────
          Expanded(
            child: Center(
              child: widget.showProgress
                  ? AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: _quickOpen ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: _quickOpen,
                        child: (widget.onProgressTap == null)
                            ? ProgressPill(
                                selected: widget.selected,
                                max: widget.max,
                                barWidth: 120,
                              )
                            : TapFlash(
                                color: cs.secondary,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                                onTapAfter: widget.onProgressTap,
                                child: ProgressPill(
                                  selected: widget.selected,
                                  max: widget.max,
                                  barWidth: 120,
                                ),
                              ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // ───────── rechts: Krone (Tap = wie bisher, Long-Press = Quick-Select) ─────────
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPressStart: (_) => _showRewardsQuick(context),
            child: SizedBox.square(
              dimension: _dim,
              child: TapFlash(
                color: cs.tertiary, // Akzent fürs Rewards
                shape: BoxShape.circle,
                onTapAfter: () {
                  // kurzer Tap: wie bisher (Standard-Rewards öffnen)
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RewardsCenterScreen(),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );
                },
                child: Container(
                  key: _crownKey, // wichtig für die Overlay-Position
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/crown.svg',
                    width: 24,
                    height: 19,
                    colorFilter: ColorFilter.mode(
                      cs.onSecondaryContainer,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideRewardsQuick();
    super.dispose();
  }
}
