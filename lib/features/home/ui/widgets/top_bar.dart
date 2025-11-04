import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/features/home/ui/widgets/tap_flash.dart';
import 'package:talvori/features/home/ui/widgets/animated_fireball_icon.dart';
import 'package:talvori/features/home/application/application.dart';
import 'progress_pill.dart';
import 'package:talvori/features/rewards/ui/screens/rewards_center_screen.dart';

class HomeTopBar extends ConsumerStatefulWidget {
  final VoidCallback onAllWords;
  final VoidCallback onRewards;         // bleibt für Kompatibilität, wird für Tap genutzt
  final VoidCallback? onProgressTap;
  final int selected;
  final int max;
  final bool showProgress;
  final GlobalKey? progressPillKey; // GlobalKey für Progress Pill (für Flug-Animation)
  final GlobalKey? crownButtonKey; // GlobalKey für Crown Button

  const HomeTopBar({
    super.key,
    required this.onAllWords,
    required this.onRewards,
    this.onProgressTap,
    this.selected = 1,
    this.max = 5,
    this.showProgress = true,
    this.progressPillKey,
    this.crownButtonKey,
  });

  @override
  ConsumerState<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends ConsumerState<HomeTopBar> {
  // Größen / Layout
  static const double _dim = 52.0;     // Durchmesser deiner Topbar-Buttons
  static const double _quickBtnSize = 52.0; // Größe der Quick-Select-Buttons (gleich wie Fireball-Button)
  static const double _gap = 16.0;     // Abstand zwischen Krone und Quick-Buttons

  final GlobalKey _crownKey = GlobalKey();
  final GlobalKey<_TapFlashWithoutGestureState> _tapFlashKey = GlobalKey();
  OverlayEntry? _rewardsOverlay;
  bool _quickOpen = false;

  void _showRewardsQuick(BuildContext context) {
    debugPrint('🔥 _showRewardsQuick aufgerufen!');
    if (_quickOpen) {
      debugPrint('🔥 _quickOpen ist bereits true, überspringe');
      return;
    }
    final overlay = Overlay.of(context);

    // Verwende entweder widget.crownButtonKey oder _crownKey
    final keyToUse = widget.crownButtonKey ?? _crownKey;
    final rb = keyToUse.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) {
      debugPrint('🔥 RenderBox ist null - Key nicht gefunden');
      return;
    }
    debugPrint('🔥 RenderBox gefunden: ${rb.size}');

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
    final glowEnabled = ref.watch(homeControllerProvider.select((s) => s.glowEnabled));
    const wheelBlue = Color(0xFFB0CCFE); // Blau aus Word Wheel
    const buttonColor = Color(0xFF2D2D2E); // Button-Hintergrundfarbe
    const gold = Color(0xFFF1C86B); // Gold für Krone

    return SizedBox(
      height: _dim,
      child: Row(
        children: [
          // ───────── links: V-Button (rund) mit TapFlash ─────────
          SizedBox.square(
            dimension: _dim,
            child: TapFlash(
              color: gold, // Gold für V-Button
              shape: BoxShape.circle,
              maxOpacity: 1.0,
              blur: 28,
              spread: 6,
              duration: const Duration(milliseconds: 220),
              onTapAfter: widget.onAllWords,
              child: Container(
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 2), // Goldener Rand
                  boxShadow: glowEnabled ? [
                    // Durchgehender goldener Glow
                    BoxShadow(
                      color: gold.withValues(alpha: 0.55),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/v.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    gold, // Gold statt weiß
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
                                key: widget.progressPillKey,
                                selected: widget.selected,
                                max: widget.max,
                                barWidth: 120,
                              )
                            : TapFlash(
                                color: gold, // Gold für Progress Pill
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                                maxOpacity: 1.0,
                                blur: 28,
                                spread: 6,
                                duration: const Duration(milliseconds: 220),
                                onTapAfter: widget.onProgressTap,
                                child: ProgressPill(
                                  key: widget.progressPillKey,
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
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Trigger Flash-Effekt
              final flashState = _tapFlashKey.currentState;
              flashState?.triggerFlash();
              // Kurzer Tap: wie bisher (Standard-Rewards öffnen)
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const RewardsCenterScreen(),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
              );
            },
            onLongPress: () {
              debugPrint('🔥 LongPress erkannt!');
              // LongPress erkannt - zeige Quick-Select
              _showRewardsQuick(context);
            },
            child: SizedBox.square(
              dimension: _dim,
              child: _TapFlashWithoutGesture(
                key: _tapFlashKey,
                color: gold, // Gold für Krone
                shape: BoxShape.circle,
                maxOpacity: 1.0,
                blur: 28,
                spread: 6,
                duration: const Duration(milliseconds: 220),
                child: Container(
                  key: widget.crownButtonKey ?? _crownKey, // Wichtig für die Overlay-Position
                  decoration: BoxDecoration(
                    color: buttonColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: gold, width: 2), // Goldener Rand
                    boxShadow: glowEnabled ? [
                      // Durchgehender goldener Glow
                      BoxShadow(
                        color: gold.withValues(alpha: 0.55),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                  alignment: Alignment.center,
                  child: AnimatedFireballIcon(
                    size: 38,
                    baseColor: gold, // Ursprungsfarbe (gold)
                    animationColor: const Color(0xFFA05260), // #A05260
                    animationInterval: const Duration(seconds: 5), // 5 Sekunden Abstand
                    animationDuration: const Duration(seconds: 5), // 5 Sekunden Einfärbung und Flammen
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

/// TapFlash ohne GestureDetector - nur visueller Effekt
class _TapFlashWithoutGesture extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;
  final double maxOpacity;
  final double blur;
  final double spread;
  final BoxShape shape;

  const _TapFlashWithoutGesture({
    super.key,
    required this.child,
    required this.color,
    this.duration = const Duration(milliseconds: 240),
    this.maxOpacity = 0.85,
    this.blur = 18,
    this.spread = 6,
    this.shape = BoxShape.circle,
  });

  @override
  State<_TapFlashWithoutGesture> createState() => _TapFlashWithoutGestureState();
}

class _TapFlashWithoutGestureState extends State<_TapFlashWithoutGesture>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  bool _running = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void triggerFlash() {
    if (_running) return;
    _running = true;
    _controller.forward().then((_) {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            _running = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    
    final glow = AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final opacity = _animation.value * widget.maxOpacity;
        final color = widget.color.withValues(alpha: opacity);
        
        final decoration = widget.shape == BoxShape.circle
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color, blurRadius: widget.blur, spreadRadius: widget.spread),
                ],
              )
            : BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(color: color, blurRadius: widget.blur, spreadRadius: widget.spread),
                ],
              );
        
        return IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1),
            opacity: opacity > 0 ? 1 : 0,
            child: Container(decoration: decoration),
          ),
        );
      },
    );
    
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        widget.child,
        Positioned.fill(child: glow),
      ],
    );
  }
}
