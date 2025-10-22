import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RewardsCenterScreen extends StatefulWidget {
  const RewardsCenterScreen({super.key, this.initialTab = RewardsTab.rewards}); // ⬅️ neu
  final RewardsTab initialTab; // ⬅️ neu
  @override
  State<RewardsCenterScreen> createState() => _RewardsCenterScreenState();
}

enum RewardsTab { rewards, leaderboard, stats }

class _RewardsCenterScreenState extends State<RewardsCenterScreen> {
  late RewardsTab tab;

  // Keys für Ausrichtung
  final _statsKey = GlobalKey();
  final _leaderKey = GlobalKey();
  final _rewardsKey = GlobalKey();
  final _trackKey = GlobalKey(); // Referenzfläche mit gleichem Padding wie die Button-Row

  double _tongueAlignX = 0; // -1..1 (Alignment.x)

  

  // Größen
  static const double kBtnSize = 56;       // Durchmesser der runden Buttons
  static const double kBtnGap = 16;       // Abstand zwischen den drei Top-Buttons
  static const double kTongueHeight = 140;  // Höhe der Zunge
  static const double kTopRowTop = 8;      // Padding oben für die Button-Row
  static const double kCardTop = 92;       // Position der Karte
  static const double kTongueOverlap = 27;  // wie weit die Zunge "hinter" den Button ragt
  static const double kTongueXOffsetPx = 0; // + = nach rechts, - = nach links
  static const double kTongueTopRadius = 28;     // Radius oben
  static const double kTongueBottomRadius = 28;  // Radius unten
  static const double kTongueWidth = 56; // ← deine Wunschbreite in px (z.B. 60)


   // Pro-Tab X-Korrektur der Zunge (Pixel): + = rechts, − = links
  static const Map<RewardsTab, double> kTongueOffsetsPx = {
    RewardsTab.rewards: 44,   // Gold
    RewardsTab.leaderboard: 23, // Rot
    RewardsTab.stats: 2,     // Blau
  }; 

  // Markenfarben
  static const gold = Color(0xFFFAD17D);
  static const red  = Color(0xFFFE9393);
  static const blue = Color(0xFFB0CCFE);
  Color get accent => switch (tab) {
        RewardsTab.rewards => gold,
        RewardsTab.leaderboard => red,
        RewardsTab.stats => blue,
      };

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab; // <-- vom Aufrufer übergeben

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Richte die Zunge unter dem passenden Button aus
      final GlobalKey targetKey = switch (tab) {
        RewardsTab.stats => _statsKey,
        RewardsTab.leaderboard => _leaderKey,
        _ => _rewardsKey,
      };
      _updateTongueFor(targetKey);
    });
  }

  /// Berechne die X-Ausrichtung relativ zum Track (gleiche Breite/Einrückung wie Buttons)
  void _updateTongueFor(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rb = key.currentContext?.findRenderObject() as RenderBox?;
      final track = _trackKey.currentContext?.findRenderObject() as RenderBox?;
      if (rb == null || track == null) return;

      final centerGlobal = rb.localToGlobal(rb.size.center(Offset.zero));
      final trackOrigin = track.localToGlobal(Offset.zero);
      final localX = centerGlobal.dx - trackOrigin.dx; // x innerhalb des Tracks
      final w = track.size.width;

      setState(() => _tongueAlignX = ((localX + kTongueXOffsetPx + (kTongueOffsetsPx[tab] ?? 0)) / w) * 2 - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Stack(
          children: [
            // 1) ZUNGE – GANZ HINTEN (unter Buttons & unter Karte)
            Positioned(
              top: kTopRowTop + (kBtnSize / 2) - kTongueOverlap,
              left: 0,
              right: 0,
              child: KeyedSubtree(
                key: _trackKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IgnorePointer(
                    ignoring: true,
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment(_tongueAlignX, -1),
                      child: Container(
                        width: kTongueWidth,
                        height: kTongueHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(kTongueTopRadius),
                            topRight: Radius.circular(kTongueTopRadius),
                            bottomLeft: Radius.circular(kTongueBottomRadius),
                            bottomRight: Radius.circular(kTongueBottomRadius),
                          ),
                        ),
                        foregroundDecoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(kTongueTopRadius),
                            topRight: Radius.circular(kTongueTopRadius),
                            bottomLeft: Radius.circular(kTongueBottomRadius),
                            bottomRight: Radius.circular(kTongueBottomRadius),
                          ),
                        ),
                      ),

                    ),
                  ),
                ),
              ),
            ),

            // 2) KARTE – MITTIG (liegt über der Zunge)
            Positioned.fill(
              top: kCardTop,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: accent, width: 1),
                  ),
                  child: _buildScrollableCard(),
                ),
              ),
            ),

            // 3) TOP-ROW – GANZ VORNE (Buttons + Zurück)
            Positioned(
              left: 16,
              right: 16,
              top: kTopRowTop,
              child: Row(
                children: [
                  _roundIcon(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _switchButton(
                    (c) => Icon(Icons.bar_chart_rounded, color: c, size: 26),
                    RewardsTab.stats,
                    key: _statsKey,
                  ),
                  const SizedBox(width: kBtnGap),
                  _switchButton(
                    (c) => Icon(Icons.emoji_events_rounded, color: c, size: 26),
                    RewardsTab.leaderboard,
                    key: _leaderKey,
                  ),
                  const SizedBox(width: kBtnGap),
                  _switchButton(
                    (c) => SvgPicture.asset(
                      'assets/icons/crown.svg',
                      width: 24,
                      height: 19,
                      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
                    ),
                    RewardsTab.rewards,
                    key: _rewardsKey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sticky-Header (Titel bleibt beim Scrollen sichtbar)
  Widget _buildScrollableCard() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _TitleHeaderDelegate(
            height: 72,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              alignment: Alignment.center,
              child: Text(
                switch (tab) {
                  RewardsTab.rewards => 'Rewards',
                  RewardsTab.leaderboard => 'Leaderboard',
                  RewardsTab.stats => 'Stats',
                },
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _tabContent()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // Inhalte je Tab (Platzhalter)
  Widget _tabContent() {
    switch (tab) {
      case RewardsTab.rewards:
        return _sectionPlaceholder('Rewards-Inhalt …');
      case RewardsTab.leaderboard:
        return _sectionPlaceholder('Leaderboard-Inhalt …');
      case RewardsTab.stats:
        return _sectionPlaceholder('Stats-Inhalt …');
    }
  }

  Widget _sectionPlaceholder(String text) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            12,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$text  •  Row ${i + 1}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _roundIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }

  Widget _switchButton(
    Widget Function(Color) iconBuilder,
    RewardsTab target, {
    Key? key,
  }) {
    final selected = tab == target;
    final color = selected ? accent : Colors.white60;
    return GestureDetector(
      key: key,
      onTap: () {
        setState(() => tab = target);
        _updateTongueFor(
          target == RewardsTab.stats
              ? _statsKey
              : target == RewardsTab.leaderboard
                  ? _leaderKey
                  : _rewardsKey,
        );
      },
      child: Container(
        width: kBtnSize,
        height: kBtnSize,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          shape: BoxShape.circle,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
          border: Border.all(
            color: selected ? accent : Colors.white24,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: iconBuilder(color),
      ),
    );
  }
}

class _TitleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _TitleHeaderDelegate({required this.height, required this.child});
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;
  @override
  bool shouldRebuild(covariant _TitleHeaderDelegate old) =>
      old.height != height || old.child != child;
}
