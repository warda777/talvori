import 'package:flutter/material.dart';

// Local greybox preview only.
//
// Island-First + Candidate check:
// - Later play moments happen on spatial plot candidates.
// - Plot families and capabilities are permission frames, not placements.
// - Markers move locally only through their layout handle; nothing is saved.
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
  static const _boardSize = Size(1280, 1280);
  static const _canvasPadding = 24.0;
  static const _snapRadius = 128.0;

  final TransformationController _mapController = TransformationController();
  late Map<_PlotSlotId, Offset> _slotPositions;
  late Map<_PlotSlotId, String> _slotAnchorIds;
  final Map<_PlotSlotId, Offset> _dragStartPositions = {};

  _PlotSlotId _selectedSlotId = _PlotSlotId.hub;
  bool _initialViewSet = false;
  bool _layoutMode = false;
  bool _detailsExpanded = false;
  bool _bankEncounterActive = false;
  _BankMeaningOptionId? _selectedBankOption;
  _BankSafeExitId? _selectedBankSafeExit;
  String _snapNotice =
      'Kandidaten snappen nur auf passende lokale Anchor-Zonen.';

  _PlotSlot get _selectedSlot =>
      _plotSlots.firstWhere((slot) => slot.id == _selectedSlotId);

  _PlotAnchor get _selectedAnchor => _anchorById(
    _slotAnchorIds[_selectedSlotId] ?? _selectedSlot.initialAnchorId,
  );

  @override
  void initState() {
    super.initState();
    _slotPositions = _initialSlotPositions();
    _slotAnchorIds = _initialSlotAnchors();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Map<_PlotSlotId, Offset> _initialSlotPositions() {
    return {
      for (final slot in _plotSlots)
        slot.id: _topLeftForAnchor(slot, _anchorById(slot.initialAnchorId)),
    };
  }

  Map<_PlotSlotId, String> _initialSlotAnchors() {
    return {for (final slot in _plotSlots) slot.id: slot.initialAnchorId};
  }

  void _selectSlot(_PlotSlotId id) {
    setState(() {
      if (_selectedSlotId != id) {
        _detailsExpanded = false;
      }
      _selectedSlotId = id;
    });
  }

  void _setLayoutMode(bool enabled) {
    setState(() {
      _layoutMode = enabled;
    });
  }

  void _resetLayout() {
    setState(() {
      _slotPositions = _initialSlotPositions();
      _slotAnchorIds = _initialSlotAnchors();
      _selectedSlotId = _PlotSlotId.hub;
      _detailsExpanded = false;
      _bankEncounterActive = false;
      _selectedBankOption = null;
      _selectedBankSafeExit = null;
      _snapNotice = 'Layout zurueckgesetzt: Start-Anker sind wieder aktiv.';
    });
  }

  void _startBankEncounter() {
    setState(() {
      _selectedSlotId = _PlotSlotId.river;
      _detailsExpanded = false;
      _layoutMode = false;
      _bankEncounterActive = true;
      _selectedBankOption = null;
      _selectedBankSafeExit = null;
    });
  }

  void _selectBankOption(_BankMeaningOptionId option) {
    setState(() {
      _selectedSlotId = _PlotSlotId.river;
      _detailsExpanded = false;
      _bankEncounterActive = true;
      _selectedBankOption = option;
      _selectedBankSafeExit = null;
    });
  }

  void _selectBankSafeExit(_BankSafeExitId exit) {
    setState(() {
      _selectedSlotId = _PlotSlotId.river;
      _detailsExpanded = false;
      _bankEncounterActive = true;
      _selectedBankSafeExit = exit;
      if (exit == _BankSafeExitId.change) {
        _selectedBankOption = null;
      }
    });
  }

  void _beginMoveSlot(_PlotSlot slot) {
    setState(() {
      _selectedSlotId = slot.id;
      _detailsExpanded = false;
      _dragStartPositions[slot.id] =
          _slotPositions[slot.id] ??
          _topLeftForAnchor(slot, _anchorById(slot.initialAnchorId));
      _snapNotice =
          'Drag aktiv: beim Loslassen wird ein passender Anchor gesucht.';
    });
  }

  void _moveSlot(_PlotSlot slot, DragUpdateDetails details) {
    final current =
        _slotPositions[slot.id] ??
        _topLeftForAnchor(slot, _anchorById(slot.initialAnchorId));
    final scale = _mapController.value.getMaxScaleOnAxis().clamp(0.4, 2.0);
    final delta = details.delta / scale;
    final maxX = _boardSize.width - slot.markerSize.width - _canvasPadding;
    final maxY = _boardSize.height - slot.markerSize.height - _canvasPadding;

    setState(() {
      _selectedSlotId = slot.id;
      _slotPositions[slot.id] = Offset(
        (current.dx + delta.dx).clamp(_canvasPadding, maxX),
        (current.dy + delta.dy).clamp(_canvasPadding, maxY),
      );
    });
  }

  void _finishMoveSlot(_PlotSlot slot) {
    final current =
        _slotPositions[slot.id] ??
        _topLeftForAnchor(slot, _anchorById(slot.initialAnchorId));
    final center =
        current + Offset(slot.markerSize.width / 2, slot.markerSize.height / 2);
    final nearestAnchor = _nearestAnchor(center);
    final previous =
        _dragStartPositions[slot.id] ??
        _topLeftForAnchor(slot, _anchorById(slot.initialAnchorId));

    setState(() {
      _selectedSlotId = slot.id;

      if (nearestAnchor == null) {
        _slotPositions[slot.id] = previous;
        _snapNotice =
            '${slot.slotCode}: kein lokaler Anchor nah genug. Candidate wurde zurueckgesetzt.';
        return;
      }

      if (!slot.allowedAnchorZones.contains(nearestAnchor.zone)) {
        _slotPositions[slot.id] = previous;
        _snapNotice =
            '${slot.slotCode}: ${nearestAnchor.zone}-Anchor passt nicht. Candidate wurde zurueckgesetzt.';
        return;
      }

      _slotPositions[slot.id] = _topLeftForAnchor(slot, nearestAnchor);
      _slotAnchorIds[slot.id] = nearestAnchor.id;
      _snapNotice =
          '${slot.slotCode}: auf ${nearestAnchor.id} (${nearestAnchor.zone}) gesnappt.';
    });
  }

  _PlotAnchor? _nearestAnchor(Offset center) {
    _PlotAnchor? nearest;
    var nearestDistance = double.infinity;

    for (final anchor in _plotAnchors) {
      final distance = (anchor.center - center).distance;
      if (distance < nearestDistance) {
        nearest = anchor;
        nearestDistance = distance;
      }
    }

    if (nearest == null || nearestDistance > _snapRadius) {
      return null;
    }

    return nearest;
  }

  void _toggleDetails() {
    setState(() {
      _detailsExpanded = !_detailsExpanded;
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

      final scale = viewportSize.width < 430 ? 0.68 : 0.78;
      final dx = (viewportSize.width - _boardSize.width * scale) / 2;
      final dy = (viewportSize.height - _boardSize.height * scale) / 2 - 18;

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
                      layoutMode: _layoutMode,
                      slotPositions: _slotPositions,
                      onSelectSlot: _selectSlot,
                      onBeginMoveSlot: _beginMoveSlot,
                      onMoveSlot: _moveSlot,
                      onFinishMoveSlot: _finishMoveSlot,
                      bankEncounterActive: _bankEncounterActive,
                      selectedBankOption: _selectedBankOption,
                      selectedBankSafeExit: _selectedBankSafeExit,
                      onSelectBankOption: _selectBankOption,
                      onSelectBankSafeExit: _selectBankSafeExit,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 10,
                    right: 12,
                    child: _TopHud(
                      layoutMode: _layoutMode,
                      onLayoutModeChanged: _setLayoutMode,
                      onResetLayout: _resetLayout,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _SelectedPlotHud(
                      slot: _selectedSlot,
                      anchor: _selectedAnchor,
                      layoutMode: _layoutMode,
                      snapNotice: _snapNotice,
                      bankEncounterActive: _bankEncounterActive,
                      detailsExpanded: _detailsExpanded,
                      onToggleDetails: _toggleDetails,
                      onStartBankEncounter: _startBankEncounter,
                    ),
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
    required this.layoutMode,
    required this.slotPositions,
    required this.onSelectSlot,
    required this.onBeginMoveSlot,
    required this.onMoveSlot,
    required this.onFinishMoveSlot,
    required this.bankEncounterActive,
    required this.selectedBankOption,
    required this.selectedBankSafeExit,
    required this.onSelectBankOption,
    required this.onSelectBankSafeExit,
  });

  final Size boardSize;
  final TransformationController controller;
  final _PlotSlotId selectedSlotId;
  final bool layoutMode;
  final Map<_PlotSlotId, Offset> slotPositions;
  final ValueChanged<_PlotSlotId> onSelectSlot;
  final ValueChanged<_PlotSlot> onBeginMoveSlot;
  final void Function(_PlotSlot slot, DragUpdateDetails details) onMoveSlot;
  final ValueChanged<_PlotSlot> onFinishMoveSlot;
  final bool bankEncounterActive;
  final _BankMeaningOptionId? selectedBankOption;
  final _BankSafeExitId? selectedBankSafeExit;
  final ValueChanged<_BankMeaningOptionId> onSelectBankOption;
  final ValueChanged<_BankSafeExitId> onSelectBankSafeExit;

  @override
  Widget build(BuildContext context) {
    final riverSlot = _slotById(_PlotSlotId.river);
    final riverPosition =
        slotPositions[_PlotSlotId.river] ??
        _topLeftForAnchor(riverSlot, _anchorById(riverSlot.initialAnchorId));
    final bankBubbleLeft = (riverPosition.dx + 20)
        .clamp(24.0, boardSize.width - 360)
        .toDouble();
    final bankBubbleTop = (riverPosition.dy + riverSlot.markerSize.height + 14)
        .clamp(24.0, boardSize.height - 360)
        .toDouble();

    return ColoredBox(
      color: const Color(0xFF071B1F),
      child: InteractiveViewer(
        transformationController: controller,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(420),
        minScale: 0.52,
        maxScale: 1.8,
        panAxis: PanAxis.free,
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
                  left:
                      (slotPositions[slot.id] ??
                              _topLeftForAnchor(
                                slot,
                                _anchorById(slot.initialAnchorId),
                              ))
                          .dx,
                  top:
                      (slotPositions[slot.id] ??
                              _topLeftForAnchor(
                                slot,
                                _anchorById(slot.initialAnchorId),
                              ))
                          .dy,
                  width: slot.markerSize.width,
                  height: slot.markerSize.height,
                  child: _PlotMarker(
                    slot: slot,
                    isSelected: slot.id == selectedSlotId,
                    layoutMode: layoutMode,
                    onTap: () => onSelectSlot(slot.id),
                    onDragStart: () => onBeginMoveSlot(slot),
                    onDragUpdate: (details) => onMoveSlot(slot, details),
                    onDragEnd: () => onFinishMoveSlot(slot),
                  ),
                ),
              if (bankEncounterActive)
                Positioned(
                  left: bankBubbleLeft,
                  top: bankBubbleTop,
                  width: 340,
                  child: _BankEncounterBubble(
                    selectedOption: selectedBankOption,
                    selectedSafeExit: selectedBankSafeExit,
                    onSelectOption: onSelectBankOption,
                    onSelectSafeExit: onSelectBankSafeExit,
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
    _drawAnchorZones(canvas);
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

  void _drawAnchorZones(Canvas canvas) {
    for (final anchor in _plotAnchors) {
      final fillPaint = Paint()
        ..color = anchor.color.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = anchor.color.withValues(alpha: 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final pointPaint = Paint()
        ..color = anchor.color.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(anchor.center, anchor.radius, fillPaint);
      canvas.drawCircle(anchor.center, anchor.radius, strokePaint);
      canvas.drawCircle(anchor.center, 5, pointPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: anchor.zone,
          style: TextStyle(
            color: anchor.color.withValues(alpha: 0.9),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 92);

      textPainter.paint(
        canvas,
        anchor.center + Offset(-textPainter.width / 2, anchor.radius + 7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlotMarker extends StatelessWidget {
  const _PlotMarker({
    required this.slot,
    required this.isSelected,
    required this.layoutMode,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final _PlotSlot slot;
  final bool isSelected;
  final bool layoutMode;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;

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
          child: Stack(
            children: [
              Center(
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
              if (layoutMode)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _MarkerDragHandle(
                    accent: slot.accent,
                    onDragStart: onDragStart,
                    onDragUpdate: onDragUpdate,
                    onDragEnd: onDragEnd,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkerDragHandle extends StatelessWidget {
  const _MarkerDragHandle({
    required this.accent,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final Color accent;
  final VoidCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => onDragStart(),
      onPanUpdate: onDragUpdate,
      onPanEnd: (_) => onDragEnd(),
      onPanCancel: onDragEnd,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF071614).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent, width: 1.4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(Icons.open_with_rounded, color: accent, size: 15),
        ),
      ),
    );
  }
}

class _BankEncounterBubble extends StatelessWidget {
  const _BankEncounterBubble({
    required this.selectedOption,
    required this.selectedSafeExit,
    required this.onSelectOption,
    required this.onSelectSafeExit,
  });

  final _BankMeaningOptionId? selectedOption;
  final _BankSafeExitId? selectedSafeExit;
  final ValueChanged<_BankMeaningOptionId> onSelectOption;
  final ValueChanged<_BankSafeExitId> onSelectSafeExit;

  bool get _hasCorrectSelection =>
      selectedOption == _BankMeaningOptionId.riverEdge;

  @override
  Widget build(BuildContext context) {
    final selected = selectedOption == null
        ? null
        : _bankOptions.firstWhere((option) => option.id == selectedOption);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1D20).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF6BC8F2), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6BC8F2).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.water_rounded, color: Color(0xFF6BC8F2), size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'P-01 Bank-Spielmoment',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Am Fluss macht Tali kurz Pause. Welche Bedeutung passt?',
                        style: TextStyle(fontSize: 12.2, height: 1.22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _bankOptions)
                  _BankOptionChip(
                    option: option,
                    isSelected: selectedOption == option.id,
                    onTap: () => onSelectOption(option.id),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _BankFeedbackPanel(
              selected: selected,
              selectedSafeExit: selectedSafeExit,
              hasCorrectSelection: _hasCorrectSelection,
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final exit in _bankSafeExits)
                  _SafeExitChip(
                    exit: exit,
                    isSelected: selectedSafeExit == exit.id,
                    onTap: () => onSelectSafeExit(exit.id),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MiniStatusPill(label: 'kein Build'),
                _MiniStatusPill(label: 'kein Placement'),
                _MiniStatusPill(label: 'kein SRS-Write'),
                _MiniStatusPill(label: 'keine Speicherung'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BankOptionChip extends StatelessWidget {
  const _BankOptionChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _BankMeaningOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = option.isCorrect
        ? const Color(0xFF6BC8F2)
        : const Color(0xFFD6F18C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 98,
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.22)
              : const Color(0xFF102D2D).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : const Color(0xFF31594F),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(option.icon, color: accent, size: 20),
            const SizedBox(height: 5),
            Text(
              option.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.4,
                height: 1.08,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              option.sceneLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.8, color: Color(0xFFCFE4D8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankFeedbackPanel extends StatelessWidget {
  const _BankFeedbackPanel({
    required this.selected,
    required this.selectedSafeExit,
    required this.hasCorrectSelection,
  });

  final _BankMeaningOption? selected;
  final _BankSafeExitId? selectedSafeExit;
  final bool hasCorrectSelection;

  @override
  Widget build(BuildContext context) {
    final text = _feedbackText;
    final icon = hasCorrectSelection
        ? Icons.auto_stories_rounded
        : Icons.tips_and_updates_rounded;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF071614),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasCorrectSelection
              ? const Color(0xFF95E6B8)
              : const Color(0xFFD6F18C).withValues(alpha: 0.62),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: hasCorrectSelection
                  ? const Color(0xFF95E6B8)
                  : const Color(0xFFD6F18C),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 11.8, height: 1.22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _feedbackText {
    if (selectedSafeExit != null) {
      return switch (selectedSafeExit!) {
        _BankSafeExitId.later =>
          'Later: Der P-01-Spielmoment bleibt lokal offen. Kein Verlust, keine Pflicht.',
        _BankSafeExitId.codex =>
          'Codex: Bank kann Sitzbank, Geldinstitut oder Flussufer bedeuten. Kontext entscheidet.',
        _BankSafeExitId.backlog =>
          'Backlog: Der Bedeutungsfall wird nur simuliert geparkt. Nichts wird gespeichert.',
        _BankSafeExitId.change =>
          'Change: Waehle ruhig neu. Die Szene am Fluss bleibt dein Hinweis.',
      };
    }

    if (selected == null) {
      return 'Tali schaut auf den Wasserweg. Das Wort Bank ist mehrdeutig; der Ort gibt den Hinweis.';
    }

    if (selected!.isCorrect) {
      return 'ContextCard / Codex Discovery: Genau, am Fluss meint Bank das Flussufer. Kein Build, kein Placement.';
    }

    return 'Calm Retry: Schau nochmal auf den Kontext "am Fluss". Keine Strafe, kein Verlust, kein Score.';
  }
}

class _SafeExitChip extends StatelessWidget {
  const _SafeExitChip({
    required this.exit,
    required this.isSelected,
    required this.onTap,
  });

  final _BankSafeExit exit;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(exit.icon, size: 15),
      label: Text(exit.label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(
        color: isSelected ? const Color(0xFF95E6B8) : const Color(0xFF31594F),
      ),
      backgroundColor: isSelected
          ? const Color(0xFF244C3F)
          : const Color(0xFF0A1A16),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
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
  const _TopHud({
    required this.layoutMode,
    required this.onLayoutModeChanged,
    required this.onResetLayout,
  });

  final bool layoutMode;
  final ValueChanged<bool> onLayoutModeChanged;
  final VoidCallback onResetLayout;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1C18).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF31594F)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
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
                        'Flexible Plot Candidate Board',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Insel bewegen, Plot waehlen, Kandidaten nur per Handle verschieben.',
                        style: TextStyle(fontSize: 12.5, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _LayoutModeChip(
                  layoutMode: layoutMode,
                  onChanged: onLayoutModeChanged,
                ),
                OutlinedButton.icon(
                  onPressed: onResetLayout,
                  icon: const Icon(Icons.restart_alt_rounded, size: 17),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFFEAF7EF),
                    side: const BorderSide(color: Color(0xFF4B8F78)),
                  ),
                ),
                if (layoutMode) ...[
                  const _HudHintPill(
                    icon: Icons.open_with_rounded,
                    label: 'Marker per Handle verschieben',
                  ),
                  const _HudHintPill(
                    icon: Icons.anchor_rounded,
                    label: 'Snap auf passende Anchor',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HudHintPill extends StatelessWidget {
  const _HudHintPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF17322B).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF4B8F78)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF95E6B8), size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutModeChip extends StatelessWidget {
  const _LayoutModeChip({required this.layoutMode, required this.onChanged});

  final bool layoutMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: layoutMode ? const Color(0xFF244C3F) : const Color(0xFF10231E),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: layoutMode ? const Color(0xFF95E6B8) : const Color(0xFF31594F),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Layout-Modus',
              style: TextStyle(fontSize: 12.2, fontWeight: FontWeight.w800),
            ),
            Switch.adaptive(
              value: layoutMode,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlotHud extends StatelessWidget {
  const _SelectedPlotHud({
    required this.slot,
    required this.anchor,
    required this.layoutMode,
    required this.snapNotice,
    required this.bankEncounterActive,
    required this.detailsExpanded,
    required this.onToggleDetails,
    required this.onStartBankEncounter,
  });

  final _PlotSlot slot;
  final _PlotAnchor anchor;
  final bool layoutMode;
  final String snapNotice;
  final bool bankEncounterActive;
  final bool detailsExpanded;
  final VoidCallback onToggleDetails;
  final VoidCallback onStartBankEncounter;

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
        constraints: BoxConstraints(maxHeight: detailsExpanded ? 324 : 202),
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
              Text(
                slot.boardSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.8, height: 1.22),
              ),
              if (layoutMode) ...[
                const SizedBox(height: 8),
                _SnapNoticeLine(text: snapNotice),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (slot.id == _PlotSlotId.river)
                    FilledButton.icon(
                      onPressed: onStartBankEncounter,
                      icon: const Icon(Icons.water_rounded, size: 18),
                      label: Text(
                        bankEncounterActive ? 'Bank neu' : 'Bank testen',
                      ),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: const Color(0xFF1B6F82),
                        foregroundColor: const Color(0xFFEAF7EF),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: onToggleDetails,
                    icon: Icon(
                      detailsExpanded
                          ? Icons.expand_more_rounded
                          : Icons.info_outline_rounded,
                      size: 18,
                    ),
                    label: Text(detailsExpanded ? 'Weniger' : 'Details'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: const Color(0xFFEAF7EF),
                      side: const BorderSide(color: Color(0xFF4B8F78)),
                    ),
                  ),
                ],
              ),
              if (detailsExpanded) ...[
                const SizedBox(height: 10),
                const Divider(color: Color(0xFF31594F), height: 1),
                const SizedBox(height: 8),
                _InfoLine(label: 'Plot-Familie', value: slot.family),
                _InfoLine(label: 'Beispiel-Woerter', value: slot.examples),
                _InfoLine(label: 'Spielmomente', value: slot.allowedMoments),
                _InfoLine(
                  label: 'Anchor jetzt',
                  value:
                      '${anchor.id} / ${anchor.zone} / erlaubt: ${anchor.allowedFamilies.join(', ')}',
                ),
                _InfoLine(
                  label: 'Erlaubte Anchor-Zonen',
                  value: slot.allowedAnchorZones.join(', '),
                ),
                _InfoLine(label: 'Blockiert', value: slot.blocked),
                _InfoLine(label: 'Flex-Regel', value: slot.flexRule),
                _InfoLine(
                  label: 'Modus',
                  value: layoutMode
                      ? 'Layout: Handle verschiebt, Karte bleibt pannbar.'
                      : 'Karte: Pan/Zoom und Plot-Auswahl.',
                ),
              ],
              const SizedBox(height: 10),
              const Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MiniStatusPill(label: 'kein Build'),
                  _MiniStatusPill(label: 'keine Persistenz'),
                  _MiniStatusPill(label: 'kein SRS-Write'),
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

class _SnapNoticeLine extends StatelessWidget {
  const _SnapNoticeLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A16).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF31594F)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.anchor_rounded,
              color: Color(0xFF95E6B8),
              size: 16,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.6, height: 1.18),
              ),
            ),
          ],
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

enum _BankMeaningOptionId { bench, institution, riverEdge }

enum _BankSafeExitId { later, codex, backlog, change }

class _BankMeaningOption {
  const _BankMeaningOption({
    required this.id,
    required this.title,
    required this.sceneLabel,
    required this.icon,
  });

  final _BankMeaningOptionId id;
  final String title;
  final String sceneLabel;
  final IconData icon;

  bool get isCorrect => id == _BankMeaningOptionId.riverEdge;
}

class _BankSafeExit {
  const _BankSafeExit({
    required this.id,
    required this.label,
    required this.icon,
  });

  final _BankSafeExitId id;
  final String label;
  final IconData icon;
}

const _bankOptions = [
  _BankMeaningOption(
    id: _BankMeaningOptionId.bench,
    title: 'Sitzbank',
    sceneLabel: 'Uferplatz',
    icon: Icons.chair_alt_rounded,
  ),
  _BankMeaningOption(
    id: _BankMeaningOptionId.institution,
    title: 'Geldinstitut',
    sceneLabel: 'Stadtschild',
    icon: Icons.account_balance_rounded,
  ),
  _BankMeaningOption(
    id: _BankMeaningOptionId.riverEdge,
    title: 'Flussufer',
    sceneLabel: 'Wasserweg',
    icon: Icons.water_rounded,
  ),
];

const _bankSafeExits = [
  _BankSafeExit(
    id: _BankSafeExitId.later,
    label: 'Later',
    icon: Icons.schedule_rounded,
  ),
  _BankSafeExit(
    id: _BankSafeExitId.codex,
    label: 'Codex',
    icon: Icons.menu_book_rounded,
  ),
  _BankSafeExit(
    id: _BankSafeExitId.backlog,
    label: 'Backlog',
    icon: Icons.inventory_2_rounded,
  ),
  _BankSafeExit(
    id: _BankSafeExitId.change,
    label: 'Change',
    icon: Icons.swap_horiz_rounded,
  ),
];

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

class _PlotAnchor {
  const _PlotAnchor({
    required this.id,
    required this.center,
    required this.zone,
    required this.allowedFamilies,
    required this.radius,
    required this.color,
  });

  final String id;
  final Offset center;
  final String zone;
  final List<String> allowedFamilies;
  final double radius;
  final Color color;
}

class _PlotSlot {
  const _PlotSlot({
    required this.id,
    required this.slotCode,
    required this.name,
    required this.mapName,
    required this.boardSummary,
    required this.family,
    required this.examples,
    required this.allowedMoments,
    required this.blocked,
    required this.flexRule,
    required this.allowedAnchorZones,
    required this.initialAnchorId,
    required this.markerSize,
    required this.icon,
    required this.accent,
  });

  final _PlotSlotId id;
  final String slotCode;
  final String name;
  final String mapName;
  final String boardSummary;
  final String family;
  final String examples;
  final String allowedMoments;
  final String blocked;
  final String flexRule;
  final List<String> allowedAnchorZones;
  final String initialAnchorId;
  final Size markerSize;
  final IconData icon;
  final Color accent;
}

_PlotAnchor _anchorById(String id) {
  return _plotAnchors.firstWhere((anchor) => anchor.id == id);
}

_PlotSlot _slotById(_PlotSlotId id) {
  return _plotSlots.firstWhere((slot) => slot.id == id);
}

Offset _topLeftForAnchor(_PlotSlot slot, _PlotAnchor anchor) {
  return Offset(
    anchor.center.dx - slot.markerSize.width / 2,
    anchor.center.dy - slot.markerSize.height / 2,
  );
}

const _plotAnchors = [
  _PlotAnchor(
    id: 'A-HUB-C',
    center: Offset(565, 465),
    zone: 'hub',
    allowedFamilies: ['hub', 'home', 'market'],
    radius: 56,
    color: Color(0xFF95E6B8),
  ),
  _PlotAnchor(
    id: 'A-WATER-W',
    center: Offset(310, 341),
    zone: 'water',
    allowedFamilies: ['water', 'coast'],
    radius: 58,
    color: Color(0xFF6BC8F2),
  ),
  _PlotAnchor(
    id: 'A-WATER-E',
    center: Offset(840, 256),
    zone: 'coast',
    allowedFamilies: ['water', 'coast'],
    radius: 54,
    color: Color(0xFF6BC8F2),
  ),
  _PlotAnchor(
    id: 'A-HOME-W',
    center: Offset(334, 477),
    zone: 'home',
    allowedFamilies: ['home', 'hub-near'],
    radius: 54,
    color: Color(0xFFE6C07B),
  ),
  _PlotAnchor(
    id: 'A-HOME-HUB',
    center: Offset(444, 386),
    zone: 'hub-near',
    allowedFamilies: ['home', 'hub'],
    radius: 50,
    color: Color(0xFFE6C07B),
  ),
  _PlotAnchor(
    id: 'A-NATURE-S',
    center: Offset(273, 651),
    zone: 'nature',
    allowedFamilies: ['nature', 'edge'],
    radius: 58,
    color: Color(0xFF8CE092),
  ),
  _PlotAnchor(
    id: 'A-NATURE-W',
    center: Offset(182, 522),
    zone: 'edge',
    allowedFamilies: ['nature', 'safe'],
    radius: 50,
    color: Color(0xFF8CE092),
  ),
  _PlotAnchor(
    id: 'A-LEARN-N',
    center: Offset(527, 209),
    zone: 'learning',
    allowedFamilies: ['learning', 'codex'],
    radius: 56,
    color: Color(0xFFB9A6FF),
  ),
  _PlotAnchor(
    id: 'A-MARKET-HUB',
    center: Offset(640, 470),
    zone: 'market',
    allowedFamilies: ['market', 'hub'],
    radius: 56,
    color: Color(0xFFFFB56F),
  ),
  _PlotAnchor(
    id: 'A-MARKET-SE',
    center: Offset(737, 610),
    zone: 'market',
    allowedFamilies: ['market', 'food'],
    radius: 58,
    color: Color(0xFFFFB56F),
  ),
  _PlotAnchor(
    id: 'A-CRAFT-SE',
    center: Offset(874, 707),
    zone: 'craft',
    allowedFamilies: ['craft', 'edge'],
    radius: 58,
    color: Color(0xFFFF9D8D),
  ),
  _PlotAnchor(
    id: 'A-CRAFT-E',
    center: Offset(930, 558),
    zone: 'edge',
    allowedFamilies: ['craft', 'safe'],
    radius: 50,
    color: Color(0xFFFF9D8D),
  ),
  _PlotAnchor(
    id: 'A-STORAGE-E',
    center: Offset(762, 385),
    zone: 'storage',
    allowedFamilies: ['container', 'hub-near'],
    radius: 52,
    color: Color(0xFFA9D2FF),
  ),
  _PlotAnchor(
    id: 'A-CODEX-NE',
    center: Offset(792, 223),
    zone: 'codex',
    allowedFamilies: ['codex', 'quiet'],
    radius: 58,
    color: Color(0xFFD6F18C),
  ),
  _PlotAnchor(
    id: 'A-CODEX-Q',
    center: Offset(618, 166),
    zone: 'quiet',
    allowedFamilies: ['codex', 'learning'],
    radius: 48,
    color: Color(0xFFD6F18C),
  ),
  _PlotAnchor(
    id: 'A-SAFE-E',
    center: Offset(956, 430),
    zone: 'safe',
    allowedFamilies: ['safe', 'edge'],
    radius: 56,
    color: Color(0xFFFFD37A),
  ),
  _PlotAnchor(
    id: 'A-SAFE-S',
    center: Offset(760, 770),
    zone: 'edge',
    allowedFamilies: ['safe', 'craft', 'nature'],
    radius: 50,
    color: Color(0xFFFFD37A),
  ),
];

const _plotSlots = [
  _PlotSlot(
    id: _PlotSlotId.hub,
    slotCode: 'P-00',
    name: 'Hub / Startplatz Candidate',
    mapName: 'Hub',
    boardSummary: 'Start- und Rueckkehrpunkt fuer ruhige Weltmomente.',
    family: 'hub / orientation',
    examples: 'heute, weiter, Pause',
    allowedMoments: 'Calm Comeback, World Hint, erste Wegwahl.',
    blocked: 'keine Pflichtentscheidung, kein Timer, kein BuildState.',
    flexRule:
        'zentraler Vorschlag; kann spaeter gewaehlt oder verschoben werden.',
    allowedAnchorZones: ['hub', 'hub-near'],
    initialAnchorId: 'A-HUB-C',
    markerSize: Size(158, 90),
    icon: Icons.place_rounded,
    accent: Color(0xFF95E6B8),
  ),
  _PlotSlot(
    id: _PlotSlotId.river,
    slotCode: 'P-01',
    name: 'Flussufer / Wasser Candidate',
    mapName: 'Flussufer',
    boardSummary:
        'Der Wasser-Plot traegt Kontext fuer Bank, Hafen und Bewegung.',
    family: 'water / coast / movement',
    examples: 'Bank, schwimmen, Hafen',
    allowedMoments: 'Meaning Puzzle, Context Door, Action Moment.',
    blocked: 'kein Bank-Encounter-Flow in diesem Board-Slice.',
    flexRule: 'Bank bleibt nur Beispiel; Wasser-Capability ist kein Placement.',
    allowedAnchorZones: ['water', 'coast'],
    initialAnchorId: 'A-WATER-W',
    markerSize: Size(184, 94),
    icon: Icons.water_rounded,
    accent: Color(0xFF6BC8F2),
  ),
  _PlotSlot(
    id: _PlotSlotId.home,
    slotCode: 'P-02',
    name: 'Zuhause / Alltag Candidate',
    mapName: 'Zuhause',
    boardSummary: 'Alltagsort fuer spaetere BuildChoice-Ideen, nicht gebaut.',
    family: 'dwelling / home / daily life',
    examples: 'Haus, Garage, Garten als spaetere BuildChoice-Kandidaten.',
    allowedMoments: 'Home-nahe Context Door, Choice Fork, Codex Discovery.',
    blocked: 'Haus, Garage und Garten sind hier nicht fest gebaut.',
    flexRule:
        'Alltags-Capability bleibt Vorschlag; Nutzer kann spaeter abwaehlen.',
    allowedAnchorZones: ['home', 'hub-near'],
    initialAnchorId: 'A-HOME-W',
    markerSize: Size(176, 94),
    icon: Icons.home_rounded,
    accent: Color(0xFFE6C07B),
  ),
  _PlotSlot(
    id: _PlotSlotId.garden,
    slotCode: 'P-03',
    name: 'Garten / Natur Candidate',
    mapName: 'Garten',
    boardSummary: 'Naturzone fuer kleine sichere Welt-Hinweise.',
    family: 'garden / nature',
    examples: 'Baum, Blume, Samen',
    allowedMoments: 'World Hint, Tiny Mystery, ContextCard.',
    blocked: 'keine Objektwolke, keine automatische Pflanzung.',
    flexRule:
        'Naturflaeche ist verschiebbarer Kandidat, kein Wachstums-System.',
    allowedAnchorZones: ['nature', 'edge'],
    initialAnchorId: 'A-NATURE-S',
    markerSize: Size(166, 90),
    icon: Icons.park_rounded,
    accent: Color(0xFF8CE092),
  ),
  _PlotSlot(
    id: _PlotSlotId.learning,
    slotCode: 'P-04',
    name: 'Lernen / Wissen Candidate',
    mapName: 'Wissen',
    boardSummary: 'Wissensort fuer Kontext, Codex und Denkaufgaben.',
    family: 'learning / school / knowledge',
    examples: 'lernen, Schule, Frage',
    allowedMoments: 'ContextCard Challenge, Codex Discovery.',
    blocked: 'kein Vokabeltest-Fenster als Hauptspielraum.',
    flexRule: 'Wissensort ist Candidate; keine Pflichtschule, kein Testmodus.',
    allowedAnchorZones: ['learning', 'codex', 'quiet'],
    initialAnchorId: 'A-LEARN-N',
    markerSize: Size(178, 94),
    icon: Icons.school_rounded,
    accent: Color(0xFFB9A6FF),
  ),
  _PlotSlot(
    id: _PlotSlotId.market,
    slotCode: 'P-05',
    name: 'Markt / Kueche / Essen Candidate',
    mapName: 'Markt',
    boardSummary: 'Moeglicher Essens- und Handlungsort, kein Shop-System.',
    family: 'food / kitchen / restaurant',
    examples: 'kochen, Brot, Markt/Kueche/Essen als moegliche Spielmomente.',
    allowedMoments: 'Choice Fork, Action Moment, Container Hint.',
    blocked: 'kein Gebaeude, keine Economy, kein Shop, kein Pay-to-Win.',
    flexRule: 'Food/Market-Capability ist Moeglichkeit, kein gebauter Markt.',
    allowedAnchorZones: ['market', 'hub'],
    initialAnchorId: 'A-MARKET-SE',
    markerSize: Size(190, 96),
    icon: Icons.restaurant_rounded,
    accent: Color(0xFFFFB56F),
  ),
  _PlotSlot(
    id: _PlotSlotId.workshop,
    slotCode: 'P-06',
    name: 'Werkstatt / Arbeit Candidate',
    mapName: 'Werkstatt',
    boardSummary: 'Craft-Zone als Vorschlag, kein Produktionszustand.',
    family: 'work / craft / production',
    examples: 'arbeiten, Werkzeug, Werkstatt-Familie.',
    allowedMoments: 'ActionChallenge, Meaning Puzzle, World Hint.',
    blocked: 'Werkstatt ist Plot-Familie, kein gebauter Zustand.',
    flexRule: 'kein Build-Wheel-Code, kein frame_started, keine Produktion.',
    allowedAnchorZones: ['craft', 'edge'],
    initialAnchorId: 'A-CRAFT-SE',
    markerSize: Size(184, 94),
    icon: Icons.handyman_rounded,
    accent: Color(0xFFFF9D8D),
  ),
  _PlotSlot(
    id: _PlotSlotId.container,
    slotCode: 'P-07',
    name: 'Container / Tasche / Lager Candidate',
    mapName: 'Lager',
    boardSummary: 'Auffindbarer Ort fuer kleine Objekte und Container-Ideen.',
    family: 'container / storage / depth',
    examples: 'Schluessel, Messer, Tasse',
    allowedMoments: 'Container Hunt, Codex Link, Findability Hint.',
    blocked: 'TinyObjects bekommen kein eigenes Grundstueck.',
    flexRule:
        'Container-Pfad bleibt auffindbarer Candidate, kein Inventar-Dump.',
    allowedAnchorZones: ['storage', 'hub-near'],
    initialAnchorId: 'A-STORAGE-E',
    markerSize: Size(184, 94),
    icon: Icons.inventory_2_rounded,
    accent: Color(0xFFA9D2FF),
  ),
  _PlotSlot(
    id: _PlotSlotId.codex,
    slotCode: 'P-08',
    name: 'Codex / Kontext Candidate',
    mapName: 'Codex',
    boardSummary: 'Ruhiger Kontextort fuer abstrakte oder mehrdeutige Woerter.',
    family: 'abstract / context / codex',
    examples: 'Freiheit, lernen, Bedeutung',
    allowedMoments: 'Codex Discovery, ContextCard, Tali/Vori-Erklaerung.',
    blocked: 'keine Symbolpflicht, kein Zwang zur Weltform.',
    flexRule: 'Abstraktes bleibt Codex/Context-Candidate, kein Objektzwang.',
    allowedAnchorZones: ['codex', 'quiet', 'learning'],
    initialAnchorId: 'A-CODEX-NE',
    markerSize: Size(184, 94),
    icon: Icons.menu_book_rounded,
    accent: Color(0xFFD6F18C),
  ),
  _PlotSlot(
    id: _PlotSlotId.backlog,
    slotCode: 'P-09',
    name: 'Later / Backlog / Sensitive Candidate',
    mapName: 'Safe Rand',
    boardSummary:
        'Geschuetzter Rand fuer Later, Backlog und sensitive Defaults.',
    family: 'safe fallback / sensitive gate',
    examples: 'Angst, Polizei, unklar',
    allowedMoments: 'Later, Backlog, Hide, SensitiveGated.',
    blocked: 'keine sensitive Deko, kein Reward-Trigger.',
    flexRule:
        'geschuetzter Randbereich bleibt Fallback-Candidate, kein Symbol.',
    allowedAnchorZones: ['safe', 'edge'],
    initialAnchorId: 'A-SAFE-E',
    markerSize: Size(196, 96),
    icon: Icons.shield_rounded,
    accent: Color(0xFFFFD37A),
  ),
];
