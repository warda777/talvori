import 'package:flutter/material.dart';

// Local greybox preview only.
//
// Island-First check:
// - Later play moments happen on spatial plot slots.
// - Plots, paths, water edges, and island zones carry the play space.
// - UI only explains through HUD, bubbles, or small signs.
// - This preview is not a separate learning-window flow.
class StarterIslandPlotBoardPreview extends StatefulWidget {
  const StarterIslandPlotBoardPreview({super.key});

  @override
  State<StarterIslandPlotBoardPreview> createState() =>
      _StarterIslandPlotBoardPreviewState();
}

class _StarterIslandPlotBoardPreviewState
    extends State<StarterIslandPlotBoardPreview> {
  static const _boardSize = Size(1100, 900);

  final TransformationController _mapController = TransformationController();
  _PlotSlotId _selectedSlotId = _PlotSlotId.hub;
  bool _initialViewSet = false;

  _PlotSlot get _selectedSlot =>
      _plotSlots.firstWhere((slot) => slot.id == _selectedSlotId);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _selectSlot(_PlotSlotId id) {
    setState(() {
      _selectedSlotId = id;
    });
  }

  void _scheduleInitialView(Size viewportSize) {
    if (_initialViewSet || viewportSize.isEmpty) {
      return;
    }
    _initialViewSet = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final scale = viewportSize.width < 430 ? 0.58 : 0.72;
      final dx = (viewportSize.width - _boardSize.width * scale) / 2;
      final dy = (viewportSize.height - _boardSize.height * scale) / 2 - 24;

      _mapController.value = Matrix4.fromList([
        scale,
        0,
        0,
        0,
        0,
        scale,
        0,
        0,
        0,
        0,
        1,
        0,
        dx,
        dy,
        0,
        1,
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5CC9A7),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF061511),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: const Color(0xFFEAF7EF),
          displayColor: const Color(0xFFEAF7EF),
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportSize = constraints.biggest;
              _scheduleInitialView(viewportSize);

              return Stack(
                children: [
                  Positioned.fill(
                    child: _PannableIslandMap(
                      boardSize: _boardSize,
                      controller: _mapController,
                      selectedSlotId: _selectedSlotId,
                      onSelectSlot: _selectSlot,
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    top: 10,
                    right: 12,
                    child: _TopHud(),
                  ),
                  const Positioned(
                    left: 12,
                    top: 92,
                    child: _IslandFirstBadge(),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _SelectedPlotHud(slot: _selectedSlot),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PannableIslandMap extends StatelessWidget {
  const _PannableIslandMap({
    required this.boardSize,
    required this.controller,
    required this.selectedSlotId,
    required this.onSelectSlot,
  });

  final Size boardSize;
  final TransformationController controller;
  final _PlotSlotId selectedSlotId;
  final ValueChanged<_PlotSlotId> onSelectSlot;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF071B1F),
      child: InteractiveViewer(
        transformationController: controller,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(260),
        minScale: 0.48,
        maxScale: 1.8,
        panEnabled: true,
        scaleEnabled: true,
        child: SizedBox(
          width: boardSize.width,
          height: boardSize.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: _IslandCanvas()),
              const Positioned(left: 528, top: 378, child: _CompanionMarker()),
              for (final slot in _plotSlots)
                Positioned(
                  left: slot.position.dx,
                  top: slot.position.dy,
                  width: slot.markerSize.width,
                  height: slot.markerSize.height,
                  child: _PlotMarker(
                    slot: slot,
                    isSelected: slot.id == selectedSlotId,
                    onTap: () => onSelectSlot(slot.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IslandCanvas extends StatelessWidget {
  const _IslandCanvas();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IslandCanvasPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _IslandCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final oceanPaint = Paint()..color = const Color(0xFF0A2E36);
    canvas.drawRect(Offset.zero & size, oceanPaint);

    _drawWaterTexture(canvas, size);
    _drawIsland(canvas);
    _drawRiver(canvas);
    _drawZones(canvas);
    _drawPaths(canvas);
  }

  void _drawWaterTexture(Canvas canvas, Size size) {
    final ripplePaint = Paint()
      ..color = const Color(0xFF61BFD3).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var y = 72.0; y < size.height; y += 92) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x < size.width + 80; x += 120) {
        path.quadraticBezierTo(x + 42, y - 16, x + 84, y);
      }
      canvas.drawPath(path, ripplePaint);
    }
  }

  void _drawIsland(Canvas canvas) {
    final islandPath = Path()
      ..moveTo(220, 138)
      ..cubicTo(340, 42, 548, 78, 720, 120)
      ..cubicTo(902, 164, 1002, 288, 976, 444)
      ..cubicTo(948, 612, 816, 766, 622, 804)
      ..cubicTo(430, 840, 210, 778, 124, 620)
      ..cubicTo(38, 462, 74, 258, 220, 138)
      ..close();

    final shorePaint = Paint()
      ..color = const Color(0xFFD7B86D).withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    final landPaint = Paint()
      ..color = const Color(0xFF4E7538)
      ..style = PaintingStyle.fill;
    final shadePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26;

    canvas.drawPath(islandPath, shorePaint);

    final innerPath = Path()
      ..moveTo(244, 166)
      ..cubicTo(360, 78, 540, 110, 694, 148)
      ..cubicTo(852, 188, 938, 302, 916, 436)
      ..cubicTo(890, 584, 770, 712, 606, 746)
      ..cubicTo(444, 776, 250, 720, 178, 590)
      ..cubicTo(104, 458, 130, 274, 244, 166)
      ..close();
    canvas.drawPath(innerPath, landPaint);
    canvas.drawPath(innerPath, shadePaint);
  }

  void _drawRiver(Canvas canvas) {
    final riverPaint = Paint()
      ..color = const Color(0xFF4CB7D8).withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 66
      ..strokeCap = StrokeCap.round;
    final riverEdgePaint = Paint()
      ..color = const Color(0xFFD4BD77).withValues(alpha: 0.54)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 82
      ..strokeCap = StrokeCap.round;

    final river = Path()
      ..moveTo(70, 320)
      ..cubicTo(234, 268, 324, 340, 438, 328)
      ..cubicTo(568, 316, 628, 198, 806, 218)
      ..cubicTo(914, 230, 986, 294, 1044, 358);

    canvas.drawPath(river, riverEdgePaint);
    canvas.drawPath(river, riverPaint);
  }

  void _drawZones(Canvas canvas) {
    void blob(Rect rect, Color color) {
      canvas.drawOval(rect, Paint()..color = color.withValues(alpha: 0.20));
    }

    blob(const Rect.fromLTWH(164, 510, 250, 170), const Color(0xFF8CE092));
    blob(const Rect.fromLTWH(606, 488, 254, 170), const Color(0xFFFFB56F));
    blob(const Rect.fromLTWH(724, 610, 228, 134), const Color(0xFFFF9D8D));
    blob(const Rect.fromLTWH(366, 146, 250, 150), const Color(0xFFB9A6FF));
    blob(const Rect.fromLTWH(668, 148, 220, 128), const Color(0xFFA9D2FF));
    blob(const Rect.fromLTWH(790, 292, 170, 132), const Color(0xFFFFD37A));
  }

  void _drawPaths(Canvas canvas) {
    final pathPaint = Paint()
      ..color = const Color(0xFFE6D399).withValues(alpha: 0.46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final mainPath = Path()
      ..moveTo(542, 438)
      ..lineTo(300, 438)
      ..lineTo(250, 610)
      ..moveTo(542, 438)
      ..lineTo(648, 598)
      ..lineTo(820, 666)
      ..moveTo(542, 438)
      ..lineTo(482, 236)
      ..moveTo(542, 438)
      ..lineTo(762, 220)
      ..moveTo(542, 438)
      ..lineTo(892, 360);

    canvas.drawPath(mainPath, pathPaint);

    final ridgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final ridge = Path()
      ..moveTo(214, 220)
      ..cubicTo(330, 182, 390, 204, 486, 174)
      ..moveTo(692, 716)
      ..cubicTo(746, 684, 810, 656, 858, 598);
    canvas.drawPath(ridge, ridgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlotMarker extends StatelessWidget {
  const _PlotMarker({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final _PlotSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = isSelected
        ? Color.alphaBlend(
            slot.accent.withValues(alpha: 0.34),
            const Color(0xFF10251F),
          )
        : Color.alphaBlend(
            slot.accent.withValues(alpha: 0.16),
            const Color(0xDD10251F),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? slot.accent
                  : slot.accent.withValues(alpha: 0.62),
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: slot.accent.withValues(alpha: isSelected ? 0.34 : 0.14),
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(slot.icon, color: slot.accent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    slot.slotCode,
                    style: TextStyle(
                      color: slot.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                slot.mapName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFF1FFF6),
                  fontSize: 13,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanionMarker extends StatelessWidget {
  const _CompanionMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF081612).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF95E6B8), width: 2),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF95E6B8),
              size: 18,
            ),
            SizedBox(width: 5),
            Text(
              'Tali/Vori',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1C18).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF31594F)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              color: Color(0xFF95E6B8),
              size: 22,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Starter Island Plot Board',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pan und Zoom: grosse Greybox-Insel, raeumliche Plot-Slots, '
                    'HUD statt Lernfenster.',
                    style: TextStyle(fontSize: 12.5, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IslandFirstBadge extends StatelessWidget {
  const _IslandFirstBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF17322B).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF4B8F78)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          'Island-First: Plot-Slots tragen den Spielmoment',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SelectedPlotHud extends StatelessWidget {
  const _SelectedPlotHud({required this.slot});

  final _PlotSlot slot;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF10231E).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: slot.accent.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 238),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(slot.icon, color: slot.accent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${slot.slotCode}  ${slot.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _InfoLine(label: 'Plot-Familie', value: slot.family),
              _InfoLine(label: 'Beispiel-Woerter', value: slot.examples),
              _InfoLine(label: 'Spielmomente', value: slot.allowedMoments),
              _InfoLine(label: 'Blockiert', value: slot.blocked),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniStatusPill(label: 'Greybox'),
                  _MiniStatusPill(label: 'kein Build'),
                  _MiniStatusPill(label: 'keine Persistenz'),
                  _MiniStatusPill(label: 'kein SRS-Write'),
                  _MiniStatusPill(label: 'keine Assets'),
                  _MiniStatusPill(label: 'keine Route'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFFEAF7EF),
            fontSize: 12.4,
            height: 1.24,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _MiniStatusPill extends StatelessWidget {
  const _MiniStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF31594F)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10.8, color: Color(0xFFBFE5D2)),
        ),
      ),
    );
  }
}

enum _PlotSlotId {
  hub,
  river,
  home,
  garden,
  learning,
  market,
  workshop,
  container,
  codex,
  backlog,
}

class _PlotSlot {
  const _PlotSlot({
    required this.id,
    required this.slotCode,
    required this.name,
    required this.mapName,
    required this.family,
    required this.examples,
    required this.allowedMoments,
    required this.blocked,
    required this.position,
    required this.markerSize,
    required this.icon,
    required this.accent,
  });

  final _PlotSlotId id;
  final String slotCode;
  final String name;
  final String mapName;
  final String family;
  final String examples;
  final String allowedMoments;
  final String blocked;
  final Offset position;
  final Size markerSize;
  final IconData icon;
  final Color accent;
}

const _plotSlots = [
  _PlotSlot(
    id: _PlotSlotId.hub,
    slotCode: 'P-00',
    name: 'Hub / Startplatz',
    mapName: 'Hub',
    family: 'hub / orientation',
    examples: 'heute, weiter, Pause',
    allowedMoments: 'Calm Comeback, World Hint, erste Wegwahl.',
    blocked: 'keine Pflichtentscheidung, kein Timer, kein BuildState.',
    position: Offset(486, 420),
    markerSize: Size(150, 86),
    icon: Icons.place_rounded,
    accent: Color(0xFF95E6B8),
  ),
  _PlotSlot(
    id: _PlotSlotId.river,
    slotCode: 'P-01',
    name: 'Flussufer / Wasser-Plot',
    mapName: 'Flussufer',
    family: 'water / coast / movement',
    examples: 'Bank, schwimmen, Hafen',
    allowedMoments: 'Meaning Puzzle, Context Door, Action Moment.',
    blocked: 'kein Bank-Encounter-Flow in diesem Board-Slice.',
    position: Offset(218, 294),
    markerSize: Size(174, 92),
    icon: Icons.water_rounded,
    accent: Color(0xFF6BC8F2),
  ),
  _PlotSlot(
    id: _PlotSlotId.home,
    slotCode: 'P-02',
    name: 'Zuhause / Alltag',
    mapName: 'Zuhause',
    family: 'dwelling / home / daily life',
    examples: 'Haus, Garage, Zimmer',
    allowedMoments: 'Choice Fork, Context Door, Codex Discovery.',
    blocked: 'kein Hausbau, kein Placement, kein Persistenzwrite.',
    position: Offset(246, 430),
    markerSize: Size(162, 90),
    icon: Icons.home_rounded,
    accent: Color(0xFFE6C07B),
  ),
  _PlotSlot(
    id: _PlotSlotId.garden,
    slotCode: 'P-03',
    name: 'Garten / Natur',
    mapName: 'Garten',
    family: 'garden / nature',
    examples: 'Baum, Blume, Samen',
    allowedMoments: 'World Hint, Tiny Mystery, ContextCard.',
    blocked: 'keine Objektwolke, keine automatische Pflanzung.',
    position: Offset(190, 606),
    markerSize: Size(160, 88),
    icon: Icons.park_rounded,
    accent: Color(0xFF8CE092),
  ),
  _PlotSlot(
    id: _PlotSlotId.learning,
    slotCode: 'P-04',
    name: 'Lernen / Wissen',
    mapName: 'Wissen',
    family: 'learning / school / knowledge',
    examples: 'lernen, Schule, Frage',
    allowedMoments: 'ContextCard Challenge, Codex Discovery.',
    blocked: 'kein Vokabeltest-Fenster als Hauptspielraum.',
    position: Offset(438, 162),
    markerSize: Size(168, 92),
    icon: Icons.school_rounded,
    accent: Color(0xFFB9A6FF),
  ),
  _PlotSlot(
    id: _PlotSlotId.market,
    slotCode: 'P-05',
    name: 'Markt / Kueche / Essen',
    mapName: 'Markt',
    family: 'food / kitchen / restaurant',
    examples: 'kochen, Brot, Markt',
    allowedMoments: 'Choice Fork, Action Moment, Container Hint.',
    blocked: 'keine Economy, kein Shop, kein Pay-to-Win.',
    position: Offset(642, 562),
    markerSize: Size(176, 92),
    icon: Icons.restaurant_rounded,
    accent: Color(0xFFFFB56F),
  ),
  _PlotSlot(
    id: _PlotSlotId.workshop,
    slotCode: 'P-06',
    name: 'Werkstatt / Arbeit',
    mapName: 'Werkstatt',
    family: 'work / craft / production',
    examples: 'arbeiten, Werkzeug, bauen',
    allowedMoments: 'ActionChallenge, Meaning Puzzle, World Hint.',
    blocked: 'kein Build-Wheel-Code, kein frame_started.',
    position: Offset(782, 660),
    markerSize: Size(176, 92),
    icon: Icons.handyman_rounded,
    accent: Color(0xFFFF9D8D),
  ),
  _PlotSlot(
    id: _PlotSlotId.container,
    slotCode: 'P-07',
    name: 'Container / Tasche / Lager',
    mapName: 'Lager',
    family: 'container / storage / depth',
    examples: 'Schluessel, Messer, Tasse',
    allowedMoments: 'Container Hunt, Codex Link, Findability Hint.',
    blocked: 'TinyObjects bekommen kein eigenes Grundstueck.',
    position: Offset(670, 338),
    markerSize: Size(174, 92),
    icon: Icons.inventory_2_rounded,
    accent: Color(0xFFA9D2FF),
  ),
  _PlotSlot(
    id: _PlotSlotId.codex,
    slotCode: 'P-08',
    name: 'Codex / Kontext / Abstrakt',
    mapName: 'Codex',
    family: 'abstract / context / codex',
    examples: 'Freiheit, lernen, Bedeutung',
    allowedMoments: 'Codex Discovery, ContextCard, Tali/Vori-Erklaerung.',
    blocked: 'keine Symbolpflicht, kein Zwang zur Weltform.',
    position: Offset(700, 176),
    markerSize: Size(174, 92),
    icon: Icons.menu_book_rounded,
    accent: Color(0xFFD6F18C),
  ),
  _PlotSlot(
    id: _PlotSlotId.backlog,
    slotCode: 'P-09',
    name: 'Later / Backlog / Sensitive-safe',
    mapName: 'Safe Rand',
    family: 'safe fallback / sensitive gate',
    examples: 'Angst, Polizei, unklar',
    allowedMoments: 'Later, Backlog, Hide, SensitiveGated.',
    blocked: 'keine sensitive Deko, kein Reward-Trigger.',
    position: Offset(858, 382),
    markerSize: Size(184, 94),
    icon: Icons.shield_rounded,
    accent: Color(0xFFFFD37A),
  ),
];
