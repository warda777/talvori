import 'package:flutter/material.dart';

// Local greybox preview only.
//
// Island-First + Candidate check:
// - Later play moments happen on spatial plot candidates.
// - Plot families and capabilities are permission frames, not placements.
// - UI only explains through HUD, bubbles, or small signs.
// - This preview is not a separate learning-window flow.
// Interaction pattern decision:
// - Chosen: direct world action + compact category picker + reduced HUD.
// - Rejected: large window, drag as standard flow, permanent rule text,
//   showcase page for this small category choice.
class StarterIslandPlotBoardPreview extends StatefulWidget {
  const StarterIslandPlotBoardPreview({super.key});

  @override
  State<StarterIslandPlotBoardPreview> createState() =>
      _StarterIslandPlotBoardPreviewState();
}

class _StarterIslandPlotBoardPreviewState
    extends State<StarterIslandPlotBoardPreview> {
  static const _boardSize = Size(1280, 1280);

  final TransformationController _mapController = TransformationController();
  final Map<String, String> _anchorCategoryIds = {};

  _PlotSlotId _selectedSlotId = _PlotSlotId.hub;
  bool _initialViewSet = false;
  bool _detailsExpanded = false;
  bool _bankEncounterActive = false;
  String? _activeWheelAnchorId;
  String? _selectedAnchorId;
  String? _wheelSelectedCategoryId;
  Map<String, String>? _wheelCategorySnapshot;
  _BankMeaningOptionId? _selectedBankOption;
  _BankSafeExitId? _selectedBankSafeExit;

  _PlotSlot get _selectedSlot =>
      _plotSlots.firstWhere((slot) => slot.id == _selectedSlotId);

  _PlotAnchor get _selectedAnchor => _selectedAnchorId == null
      ? _anchorById(_selectedSlot.initialAnchorId)
      : _anchorById(_selectedAnchorId!);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _handleAnchorTap(_PlotAnchor anchor) {
    if (anchor.state == _PlotAnchorState.reserved) {
      return;
    }

    final existingCategoryId = _anchorCategoryIds[anchor.id];
    final category = existingCategoryId == null
        ? null
        : _wheelCategoryById(existingCategoryId);
    final isStartSlot = anchor.state == _PlotAnchorState.start;
    final restoredCategories = Map<String, String>.from(
      _wheelCategorySnapshot ?? _anchorCategoryIds,
    );

    setState(() {
      if (!isStartSlot) {
        _anchorCategoryIds
          ..clear()
          ..addAll(restoredCategories);
      }
      _activeWheelAnchorId = isStartSlot ? anchor.id : null;
      _selectedAnchorId = anchor.id;
      _wheelSelectedCategoryId = null;
      _wheelCategorySnapshot = isStartSlot
          ? Map<String, String>.from(_anchorCategoryIds)
          : null;
      _detailsExpanded = false;
      _bankEncounterActive = false;
      _selectedBankOption = null;
      _selectedBankSafeExit = null;
      if (category != null) {
        _selectedSlotId = category.slotId;
      }
    });
  }

  void _selectWheelCategory(String categoryId) {
    final anchorId = _activeWheelAnchorId;
    if (anchorId == null) {
      return;
    }

    final category = _wheelCategoryById(categoryId);

    setState(() {
      _anchorCategoryIds[anchorId] = categoryId;
      _selectedAnchorId = anchorId;
      _wheelSelectedCategoryId = categoryId;
      _selectedSlotId = category.slotId;
      _detailsExpanded = false;
    });
  }

  void _confirmWheelCandidate() {
    final anchorId = _activeWheelAnchorId;
    final categoryId = _wheelSelectedCategoryId;
    if (anchorId == null || categoryId == null) {
      return;
    }

    final category = _wheelCategoryById(categoryId);
    setState(() {
      _activeWheelAnchorId = null;
      _selectedAnchorId = anchorId;
      _wheelSelectedCategoryId = null;
      _wheelCategorySnapshot = null;
      _selectedSlotId = category.slotId;
    });
  }

  void _changeWheelCandidate() {
    setState(() {
      final anchorId = _activeWheelAnchorId;
      final snapshot = _wheelCategorySnapshot;
      if (anchorId != null) {
        final previousCategoryId = snapshot?[anchorId];
        if (previousCategoryId == null) {
          _anchorCategoryIds.remove(anchorId);
        } else {
          _anchorCategoryIds[anchorId] = previousCategoryId;
        }
      }
      _wheelSelectedCategoryId = null;
    });
  }

  void _cancelWheelCandidate() {
    setState(() {
      _restoreWheelSnapshot();
    });
  }

  void _laterWheelCandidate() {
    setState(() {
      _restoreWheelSnapshot();
    });
  }

  void _restoreWheelSnapshot() {
    final snapshot = _wheelCategorySnapshot;
    if (snapshot != null) {
      _anchorCategoryIds
        ..clear()
        ..addAll(snapshot);
    }
    _activeWheelAnchorId = null;
    _wheelSelectedCategoryId = null;
    _wheelCategorySnapshot = null;
  }

  void _clearBoardSelection() {
    setState(() {
      _restoreWheelSnapshot();
      _selectedAnchorId = null;
      _detailsExpanded = false;
      _bankEncounterActive = false;
      _selectedBankOption = null;
      _selectedBankSafeExit = null;
    });
  }

  void _startBankEncounter() {
    setState(() {
      _selectedSlotId = _PlotSlotId.river;
      _detailsExpanded = false;
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
              final hudAnchor = _selectedAnchorId == null
                  ? null
                  : _anchorById(_selectedAnchorId!);
              final hudCategoryId = _selectedAnchorId == null
                  ? null
                  : _anchorCategoryIds[_selectedAnchorId!];
              final hudCandidate = hudCategoryId == null
                  ? null
                  : _wheelCategoryById(hudCategoryId);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: _PannableIslandMap(
                      boardSize: _boardSize,
                      controller: _mapController,
                      anchorCategoryIds: _anchorCategoryIds,
                      activeWheelAnchorId: _activeWheelAnchorId,
                      wheelSelectedCategoryId: _wheelSelectedCategoryId,
                      onTapMap: _clearBoardSelection,
                      onTapAnchor: _handleAnchorTap,
                      onSelectWheelCategory: _selectWheelCategory,
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
                    child: const _TopHud(),
                  ),
                  if (hudAnchor != null ||
                      hudCandidate != null ||
                      _bankEncounterActive)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: _SelectedPlotHud(
                        slot: _selectedSlot,
                        anchor: _selectedAnchor,
                        focusAnchor: hudAnchor,
                        wheelCandidate: hudCandidate,
                        hasPendingWheelCandidate:
                            _wheelSelectedCategoryId != null,
                        bankEncounterActive: _bankEncounterActive,
                        detailsExpanded: _detailsExpanded,
                        onToggleDetails: _toggleDetails,
                        onConfirmWheelCandidate: _confirmWheelCandidate,
                        onChangeWheelCandidate: _changeWheelCandidate,
                        onCancelWheelCandidate: _cancelWheelCandidate,
                        onLaterWheelCandidate: _laterWheelCandidate,
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
    required this.anchorCategoryIds,
    required this.activeWheelAnchorId,
    required this.wheelSelectedCategoryId,
    required this.onTapMap,
    required this.onTapAnchor,
    required this.onSelectWheelCategory,
    required this.bankEncounterActive,
    required this.selectedBankOption,
    required this.selectedBankSafeExit,
    required this.onSelectBankOption,
    required this.onSelectBankSafeExit,
  });

  final Size boardSize;
  final TransformationController controller;
  final Map<String, String> anchorCategoryIds;
  final String? activeWheelAnchorId;
  final String? wheelSelectedCategoryId;
  final VoidCallback onTapMap;
  final ValueChanged<_PlotAnchor> onTapAnchor;
  final ValueChanged<String> onSelectWheelCategory;
  final bool bankEncounterActive;
  final _BankMeaningOptionId? selectedBankOption;
  final _BankSafeExitId? selectedBankSafeExit;
  final ValueChanged<_BankMeaningOptionId> onSelectBankOption;
  final ValueChanged<_BankSafeExitId> onSelectBankSafeExit;

  @override
  Widget build(BuildContext context) {
    final riverSlot = _slotById(_PlotSlotId.river);
    final riverPosition = _topLeftForAnchor(
      riverSlot,
      _anchorById(riverSlot.initialAnchorId),
    );
    final bankBubbleLeft = (riverPosition.dx + 20)
        .clamp(24.0, boardSize.width - 360)
        .toDouble();
    final bankBubbleTop = (riverPosition.dy + riverSlot.markerSize.height + 14)
        .clamp(24.0, boardSize.height - 360)
        .toDouble();
    final activeWheelAnchor = activeWheelAnchorId == null
        ? null
        : _anchorById(activeWheelAnchorId!);
    const pickerSize = Size(306, 184);
    final wheelLeft = activeWheelAnchor == null
        ? 24.0
        : (activeWheelAnchor.center.dx - pickerSize.width / 2)
              .clamp(24.0, boardSize.width - pickerSize.width - 24)
              .toDouble();
    final wheelTop = activeWheelAnchor == null
        ? 24.0
        : (activeWheelAnchor.center.dy - pickerSize.height / 2)
              .clamp(98.0, boardSize.height - pickerSize.height - 24)
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
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onTapMap,
                  child: const SizedBox.expand(),
                ),
              ),
              for (final entry in anchorCategoryIds.entries)
                if (_anchorById(entry.key).isVisible)
                  _PlotShapePreviewPositioned(
                    anchor: _anchorById(entry.key),
                    category: _wheelCategoryById(entry.value),
                    isActive: entry.key == activeWheelAnchorId,
                  ),
              for (final anchor in _visiblePlotAnchors)
                Positioned(
                  left: anchor.center.dx - anchor.radius - 14,
                  top: anchor.center.dy - anchor.radius - 14,
                  width: (anchor.radius + 14) * 2,
                  height: (anchor.radius + 14) * 2,
                  child: _AnchorTapTarget(
                    anchor: anchor,
                    isActive: anchor.id == activeWheelAnchorId,
                    hasCandidate: anchorCategoryIds.containsKey(anchor.id),
                    onTap: () => onTapAnchor(anchor),
                  ),
                ),
              const Positioned(left: 528, top: 378, child: _CompanionMarker()),
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
              if (activeWheelAnchor != null && wheelSelectedCategoryId == null)
                Positioned(
                  left: wheelLeft,
                  top: wheelTop,
                  width: pickerSize.width,
                  height: pickerSize.height,
                  child: _PlotCategoryWheel(
                    anchor: activeWheelAnchor,
                    options: _wheelCategoriesForAnchor(activeWheelAnchor),
                    selectedCategoryId: wheelSelectedCategoryId,
                    existingCategoryId: anchorCategoryIds[activeWheelAnchor.id],
                    onSelectCategory: onSelectWheelCategory,
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
    for (final anchor in _visiblePlotAnchors) {
      final isExpansion = anchor.state == _PlotAnchorState.expansion;
      final fillPaint = Paint()
        ..color = anchor.color.withValues(alpha: isExpansion ? 0.06 : 0.16)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = anchor.color.withValues(alpha: isExpansion ? 0.32 : 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isExpansion ? 2 : 3;
      final pointPaint = Paint()
        ..color = anchor.color.withValues(alpha: isExpansion ? 0.42 : 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(anchor.center, anchor.radius, fillPaint);
      canvas.drawCircle(anchor.center, anchor.radius, strokePaint);
      canvas.drawCircle(anchor.center, isExpansion ? 3.5 : 5, pointPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: _anchorDisplayId(anchor),
          style: TextStyle(
            color: anchor.color.withValues(alpha: 0.9),
            fontSize: isExpansion ? 9.5 : 10.5,
            height: 1.0,
            fontWeight: isExpansion ? FontWeight.w700 : FontWeight.w800,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 48);

      textPainter.paint(
        canvas,
        anchor.center + Offset(-textPainter.width / 2, anchor.radius + 7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlotShapePreviewPositioned extends StatelessWidget {
  const _PlotShapePreviewPositioned({
    required this.anchor,
    required this.category,
    required this.isActive,
  });

  final _PlotAnchor anchor;
  final _WheelCategory category;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final size = category.shape.previewSize;

    return Positioned(
      left: anchor.center.dx - size.width / 2,
      top: anchor.center.dy - size.height / 2,
      width: size.width,
      height: size.height,
      child: _PlotShapePreviewMarker(
        category: category,
        anchor: anchor,
        isActive: isActive,
      ),
    );
  }
}

class _PlotShapePreviewMarker extends StatelessWidget {
  const _PlotShapePreviewMarker({
    required this.category,
    required this.anchor,
    required this.isActive,
  });

  final _WheelCategory category;
  final _PlotAnchor anchor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final slot = _slotById(category.slotId);
    final borderRadius = switch (category.shape) {
      _PlotShapeKind.small => 18.0,
      _PlotShapeKind.medium => 22.0,
      _PlotShapeKind.large => 26.0,
      _PlotShapeKind.waterEdge => 999.0,
      _PlotShapeKind.protected => 20.0,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: slot.accent.withValues(alpha: isActive ? 0.25 : 0.16),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: slot.accent.withValues(alpha: isActive ? 0.95 : 0.58),
          width: isActive ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: slot.accent.withValues(alpha: isActive ? 0.24 : 0.10),
            blurRadius: isActive ? 22 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(slot.icon, color: slot.accent, size: 15),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  category.shortLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFFEAF7EF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Candidate',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xFFB8D8CA),
                  fontSize: 8.5,
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

class _AnchorTapTarget extends StatelessWidget {
  const _AnchorTapTarget({
    required this.anchor,
    required this.isActive,
    required this.hasCandidate,
    required this.onTap,
  });

  final _PlotAnchor anchor;
  final bool isActive;
  final bool hasCandidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isExpansion = anchor.state == _PlotAnchorState.expansion;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: isActive ? 38 : 32,
          height: isActive ? 38 : 32,
          decoration: BoxDecoration(
            color: hasCandidate
                ? anchor.color.withValues(alpha: 0.34)
                : isExpansion
                ? const Color(0xFF061511).withValues(alpha: 0.36)
                : const Color(0xFF061511).withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFEAF7EF)
                  : anchor.color.withValues(alpha: isExpansion ? 0.48 : 0.88),
              width: isActive ? 2.4 : 1.6,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasCandidate
                    ? Icons.check_rounded
                    : isExpansion
                    ? Icons.lock_clock_rounded
                    : Icons.add_rounded,
                color: anchor.color,
                size: isActive ? 17 : 14,
              ),
              if (!hasCandidate)
                Text(
                  isExpansion ? 'spaeter' : 'frei',
                  style: TextStyle(
                    color: anchor.color,
                    fontSize: isExpansion ? 6.2 : 7,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlotCategoryWheel extends StatelessWidget {
  const _PlotCategoryWheel({
    required this.anchor,
    required this.options,
    required this.selectedCategoryId,
    required this.existingCategoryId,
    required this.onSelectCategory,
  });

  final _PlotAnchor anchor;
  final List<_WheelCategory> options;
  final String? selectedCategoryId;
  final String? existingCategoryId;
  final ValueChanged<String> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final selected = selectedCategoryId == null
        ? null
        : _wheelCategoryById(selectedCategoryId!);
    final occupied = existingCategoryId == null
        ? null
        : _wheelCategoryById(existingCategoryId!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WheelAnchorHub(anchor: anchor, selectedCategory: selected ?? occupied),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final option in options)
              SizedBox(
                width: 88,
                height: 38,
                child: _WheelOptionButton(
                  category: option,
                  isSelected:
                      selectedCategoryId == option.id ||
                      existingCategoryId == option.id,
                  onTap: () => onSelectCategory(option.id),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WheelAnchorHub extends StatelessWidget {
  const _WheelAnchorHub({required this.anchor, required this.selectedCategory});

  final _PlotAnchor anchor;
  final _WheelCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final category = selectedCategory;
    final label = category?.shortLabel ?? _anchorDisplayId(anchor);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF071614).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: anchor.color.withValues(alpha: 0.82)),
        boxShadow: [
          BoxShadow(
            color: anchor.color.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: 74,
        height: 34,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category?.icon ?? Icons.add_location_alt_rounded,
                color: anchor.color,
                size: 15,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
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

class _WheelOptionButton extends StatelessWidget {
  const _WheelOptionButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final _WheelCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final slot = _slotById(category.slotId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? slot.accent.withValues(alpha: 0.32)
              : const Color(0xFF102D2D).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? slot.accent : const Color(0xFF31594F),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, color: slot.accent, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  category.shortLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
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
      return 'ContextCard / Codex Discovery: Genau, am Fluss meint Bank das Flussufer. Kontext entscheidet.';
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
  const _TopHud();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1C18).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF31594F)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.travel_explore_rounded,
                  color: Color(0xFF95E6B8),
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'Starter-Insel',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const _HudHintPill(
              icon: Icons.touch_app_rounded,
              label: 'Slot tippen',
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 190),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
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
    required this.focusAnchor,
    required this.wheelCandidate,
    required this.hasPendingWheelCandidate,
    required this.bankEncounterActive,
    required this.detailsExpanded,
    required this.onToggleDetails,
    required this.onConfirmWheelCandidate,
    required this.onChangeWheelCandidate,
    required this.onCancelWheelCandidate,
    required this.onLaterWheelCandidate,
    required this.onStartBankEncounter,
  });

  final _PlotSlot slot;
  final _PlotAnchor anchor;
  final _PlotAnchor? focusAnchor;
  final _WheelCategory? wheelCandidate;
  final bool hasPendingWheelCandidate;
  final bool bankEncounterActive;
  final bool detailsExpanded;
  final VoidCallback onToggleDetails;
  final VoidCallback onConfirmWheelCandidate;
  final VoidCallback onChangeWheelCandidate;
  final VoidCallback onCancelWheelCandidate;
  final VoidCallback onLaterWheelCandidate;
  final VoidCallback onStartBankEncounter;

  @override
  Widget build(BuildContext context) {
    final candidate = wheelCandidate;
    final focus = focusAnchor;
    final activeAnchor = focus ?? anchor;
    final isExpansion = activeAnchor.state == _PlotAnchorState.expansion;
    final focusLabel = focus == null
        ? null
        : '${_anchorDisplayId(focus)} ${_anchorTerrainLabel(focus)}';
    final candidateVariant = candidate == null
        ? null
        : '${candidate.shortLabel} ${_anchorVariantLabel(activeAnchor)}';
    final title =
        candidateVariant ??
        (focus != null
            ? isExpansion
                  ? 'Erweiterung $focusLabel'
                  : 'Freier Slot $focusLabel'
            : 'Freie Startslots');
    final summary = candidate != null
        ? 'Lokaler Candidate, kein Placement.'
        : focus != null
        ? isExpansion
              ? 'Spaeter freischaltbarer Slot.'
              : 'Freier Slot - Kategorie waehlen.'
        : 'Startslot antippen. Kategorien sind Templates.';
    final titleIcon = candidate != null
        ? candidate.icon
        : focus != null
        ? isExpansion
              ? Icons.lock_clock_rounded
              : Icons.add_location_alt_rounded
        : Icons.add_location_alt_rounded;
    final titleColor = candidate != null
        ? _slotById(candidate.slotId).accent
        : focus?.color ?? const Color(0xFF95E6B8);
    final hudBorderColor = candidate != null
        ? _slotById(candidate.slotId).accent
        : activeAnchor.color;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF10231E).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hudBorderColor.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: detailsExpanded
              ? 300
              : candidate == null
              ? 136
              : 188,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(titleIcon, color: titleColor, size: 22),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.6,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.8, height: 1.16),
              ),
              if (candidate != null && focus != null) ...[
                const SizedBox(height: 7),
                _WheelDecisionHud(
                  category: candidate,
                  anchor: focus,
                  isPending: hasPendingWheelCandidate,
                  onConfirm: onConfirmWheelCandidate,
                  onChange: onChangeWheelCandidate,
                  onCancel: onCancelWheelCandidate,
                  onLater: onLaterWheelCandidate,
                ),
              ],
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!isExpansion && slot.id == _PlotSlotId.river)
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
              if (detailsExpanded) ...[
                const SizedBox(height: 10),
                const Divider(color: Color(0xFF31594F), height: 1),
                const SizedBox(height: 8),
                if (candidate != null) ...[
                  _InfoLine(label: 'Kategorie', value: candidate.label),
                  _InfoLine(
                    label: 'Standortvariante',
                    value: candidateVariant ?? candidate.shortLabel,
                  ),
                  const _InfoLine(
                    label: 'Template-Regel',
                    value:
                        '9 Kategorien sind Templates fuer 17 freie Slots und duerfen mehrfach als lokale Varianten erscheinen.',
                  ),
                  _InfoLine(
                    label: 'Gelaende-Hinweis',
                    value:
                        'Gelaende kann spaeter die Variante beeinflussen, blockiert aber keine Kategorie.',
                  ),
                  _InfoLine(
                    label: 'Preview',
                    value: 'Lokale Preview, nichts wird gespeichert.',
                  ),
                ] else if (isExpansion) ...[
                  _InfoLine(
                    label: 'Status',
                    value:
                        'Spaeter sichtbar, aber in dieser Preview nicht normal waehlbar.',
                  ),
                  const _InfoLine(
                    label: 'Unlock-Regel',
                    value:
                        'Kein Wheel, keine Muenzen-Implementierung, kein Timer und kein Druck.',
                  ),
                  const _InfoLine(
                    label: 'Preview',
                    value: 'Lokale Preview, nichts wird gespeichert.',
                  ),
                ] else ...[
                  _InfoLine(label: 'Slot', value: focusLabel ?? 'freie Slots'),
                  const _InfoLine(
                    label: 'Template-Regel',
                    value:
                        'Kategorien sind wiederverwendbare Templates, keine einmalige Belegung.',
                  ),
                  const _InfoLine(
                    label: 'Hinweis',
                    value: 'Gelaende kann spaeter die Variante beeinflussen.',
                  ),
                  const _InfoLine(
                    label: 'Preview',
                    value: 'Lokale Preview, nichts wird gespeichert.',
                  ),
                ],
                _InfoLine(
                  label: 'Modus',
                  value: 'Karte: Pan/Zoom, Slot-Tap und Kategorieauswahl.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelDecisionHud extends StatelessWidget {
  const _WheelDecisionHud({
    required this.category,
    required this.anchor,
    required this.isPending,
    required this.onConfirm,
    required this.onChange,
    required this.onCancel,
    required this.onLater,
  });

  final _WheelCategory category;
  final _PlotAnchor anchor;
  final bool isPending;
  final VoidCallback onConfirm;
  final VoidCallback onChange;
  final VoidCallback onCancel;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final slot = _slotById(category.slotId);
    final variant = '${category.shortLabel} ${_anchorVariantLabel(anchor)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: slot.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: slot.accent.withValues(alpha: 0.42)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HudHintPill(icon: category.icon, label: variant),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                FilledButton.icon(
                  onPressed: isPending ? onConfirm : null,
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text('Confirm'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: slot.accent.withValues(alpha: 0.78),
                    foregroundColor: const Color(0xFF061511),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onChange,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                  label: const Text('Change'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFFEAF7EF),
                    side: const BorderSide(color: Color(0xFF4B8F78)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded, size: 15),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFFEAF7EF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
                TextButton.icon(
                  onPressed: onLater,
                  icon: const Icon(Icons.schedule_rounded, size: 15),
                  label: const Text('Later'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFFEAF7EF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
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

enum _BankMeaningOptionId { bench, institution, riverEdge }

enum _BankSafeExitId { later, codex, backlog, change }

enum _PlotAnchorState { start, expansion, reserved }

enum _PlotShapeKind { small, medium, large, waterEdge, protected }

extension _PlotShapeKindLabel on _PlotShapeKind {
  Size get previewSize {
    return switch (this) {
      _PlotShapeKind.small => const Size(74, 48),
      _PlotShapeKind.medium => const Size(106, 64),
      _PlotShapeKind.large => const Size(138, 82),
      _PlotShapeKind.waterEdge => const Size(144, 58),
      _PlotShapeKind.protected => const Size(112, 72),
    };
  }
}

class _WheelCategory {
  const _WheelCategory({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.slotId,
    required this.shape,
    required this.summary,
    required this.icon,
  });

  final String id;
  final String label;
  final String shortLabel;
  final _PlotSlotId slotId;
  final _PlotShapeKind shape;
  final String summary;
  final IconData icon;
}

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

const _wheelCategories = [
  _WheelCategory(
    id: 'water_plot',
    label: 'Wasser / Ufer',
    shortLabel: 'Ufer',
    slotId: _PlotSlotId.river,
    shape: _PlotShapeKind.waterEdge,
    summary: 'Ufer- oder Wasser-Kontext als lokale Candidate-Flaeche.',
    icon: Icons.water_rounded,
  ),
  _WheelCategory(
    id: 'home_daily',
    label: 'Zuhause / Alltag',
    shortLabel: 'Zuhause',
    slotId: _PlotSlotId.home,
    shape: _PlotShapeKind.large,
    summary: 'Alltags-Candidate, kein Pflicht-Haus und kein BuildState.',
    icon: Icons.home_rounded,
  ),
  _WheelCategory(
    id: 'market_food',
    label: 'Markt / Kueche / Essen',
    shortLabel: 'Markt',
    slotId: _PlotSlotId.market,
    shape: _PlotShapeKind.medium,
    summary: 'Moeglicher Food-/Choice-Ort, kein Shop und keine Economy.',
    icon: Icons.restaurant_rounded,
  ),
  _WheelCategory(
    id: 'learning_knowledge',
    label: 'Lernen / Wissen',
    shortLabel: 'Wissen',
    slotId: _PlotSlotId.learning,
    shape: _PlotShapeKind.medium,
    summary: 'Kontext- oder Denk-Ort, kein Testfenster.',
    icon: Icons.school_rounded,
  ),
  _WheelCategory(
    id: 'container_storage',
    label: 'Container / Lager',
    shortLabel: 'Lager',
    slotId: _PlotSlotId.container,
    shape: _PlotShapeKind.small,
    summary: 'Findability fuer kleine Objekte, kein Inventar-Dump.',
    icon: Icons.inventory_2_rounded,
  ),
  _WheelCategory(
    id: 'garden_nature',
    label: 'Garten / Natur',
    shortLabel: 'Garten',
    slotId: _PlotSlotId.garden,
    shape: _PlotShapeKind.large,
    summary: 'Natur-Candidate mit Luft, kein Timer und kein Growth-Druck.',
    icon: Icons.park_rounded,
  ),
  _WheelCategory(
    id: 'workshop_craft',
    label: 'Werkstatt / Arbeit',
    shortLabel: 'Werkstatt',
    slotId: _PlotSlotId.workshop,
    shape: _PlotShapeKind.medium,
    summary: 'Craft-Candidate, kein Produktionsloop.',
    icon: Icons.handyman_rounded,
  ),
  _WheelCategory(
    id: 'codex_context',
    label: 'Codex / Kontext',
    shortLabel: 'Codex',
    slotId: _PlotSlotId.codex,
    shape: _PlotShapeKind.medium,
    summary: 'Ruhiger Kontextort fuer abstrakte oder unsichere Woerter.',
    icon: Icons.menu_book_rounded,
  ),
  _WheelCategory(
    id: 'safe_backlog',
    label: 'Later / Backlog / Sensitive-safe',
    shortLabel: 'Safe',
    slotId: _PlotSlotId.backlog,
    shape: _PlotShapeKind.protected,
    summary: 'Geschuetzter Fallback, keine sensitive Deko.',
    icon: Icons.shield_rounded,
  ),
];

_WheelCategory _wheelCategoryById(String id) {
  return _wheelCategories.firstWhere((category) => category.id == id);
}

List<_WheelCategory> _wheelCategoriesForAnchor(_PlotAnchor _) {
  return _wheelCategories;
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

class _PlotAnchor {
  const _PlotAnchor({
    required this.id,
    required this.center,
    required this.state,
    required this.zone,
    required this.allowedFamilies,
    required this.radius,
    required this.color,
  });

  final String id;
  final Offset center;
  final _PlotAnchorState state;
  final String zone;
  final List<String> allowedFamilies;
  final double radius;
  final Color color;

  bool get isVisible => state != _PlotAnchorState.reserved;
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

List<_PlotAnchor> get _visiblePlotAnchors => [
  for (final anchor in _plotAnchors)
    if (anchor.isVisible) anchor,
];

_PlotSlot _slotById(_PlotSlotId id) {
  return _plotSlots.firstWhere((slot) => slot.id == id);
}

Offset _topLeftForAnchor(_PlotSlot slot, _PlotAnchor anchor) {
  return Offset(
    anchor.center.dx - slot.markerSize.width / 2,
    anchor.center.dy - slot.markerSize.height / 2,
  );
}

String _anchorDisplayId(_PlotAnchor anchor) {
  final anchors = anchor.isVisible ? _visiblePlotAnchors : _plotAnchors;
  final index = anchors.indexWhere((item) => item.id == anchor.id);
  return 'A-${(index + 1).toString().padLeft(2, '0')}';
}

String _anchorTerrainLabel(_PlotAnchor anchor) {
  return switch (anchor.id) {
    'A-HUB-C' => 'Freier Platz',
    'A-WATER-W' => 'Uferplatz',
    'A-WATER-E' => 'Wassernahe Flaeche',
    'A-HOME-W' => 'Freier Platz',
    'A-HOME-HUB' => 'Zentraler Platz',
    'A-NATURE-S' => 'Waldlichtung',
    'A-NATURE-W' => 'Randplatz',
    'A-LEARN-N' => 'Huegelplatz',
    'A-MARKET-HUB' => 'Zentraler Platz',
    'A-MARKET-SE' => 'Freier Platz',
    'A-CRAFT-SE' => 'Randplatz',
    'A-CRAFT-E' => 'Randplatz',
    'A-STORAGE-E' => 'Freier Platz',
    'A-CODEX-NE' => 'Ruhiger Platz',
    'A-CODEX-Q' => 'Ruhiger Platz',
    'A-SAFE-E' => 'Randplatz',
    'A-SAFE-S' => 'Randplatz',
    _ => 'Freier Platz',
  };
}

String _anchorVariantLabel(_PlotAnchor anchor) {
  return switch (anchor.id) {
    'A-WATER-W' || 'A-WATER-E' => 'am Ufer',
    'A-HUB-C' || 'A-HOME-HUB' || 'A-MARKET-HUB' => 'zentral',
    'A-NATURE-S' || 'A-NATURE-W' => 'in der Waldlichtung',
    'A-LEARN-N' => 'am Huegel',
    'A-CODEX-NE' || 'A-CODEX-Q' => 'am ruhigen Platz',
    'A-SAFE-E' || 'A-SAFE-S' || 'A-CRAFT-E' || 'A-CRAFT-SE' => 'am Rand',
    _ => 'am freien Platz',
  };
}

const _plotAnchors = [
  _PlotAnchor(
    id: 'A-HUB-C',
    center: Offset(565, 465),
    state: _PlotAnchorState.start,
    zone: 'hub',
    allowedFamilies: ['hub', 'home', 'market'],
    radius: 56,
    color: Color(0xFF95E6B8),
  ),
  _PlotAnchor(
    id: 'A-WATER-W',
    center: Offset(310, 341),
    state: _PlotAnchorState.start,
    zone: 'water',
    allowedFamilies: ['water', 'coast'],
    radius: 58,
    color: Color(0xFF6BC8F2),
  ),
  _PlotAnchor(
    id: 'A-WATER-E',
    center: Offset(840, 256),
    state: _PlotAnchorState.reserved,
    zone: 'coast',
    allowedFamilies: ['water', 'coast'],
    radius: 54,
    color: Color(0xFF6BC8F2),
  ),
  _PlotAnchor(
    id: 'A-HOME-W',
    center: Offset(334, 477),
    state: _PlotAnchorState.start,
    zone: 'home',
    allowedFamilies: ['home', 'hub-near'],
    radius: 54,
    color: Color(0xFFE6C07B),
  ),
  _PlotAnchor(
    id: 'A-HOME-HUB',
    center: Offset(444, 386),
    state: _PlotAnchorState.reserved,
    zone: 'hub-near',
    allowedFamilies: ['home', 'hub'],
    radius: 50,
    color: Color(0xFFE6C07B),
  ),
  _PlotAnchor(
    id: 'A-NATURE-S',
    center: Offset(273, 651),
    state: _PlotAnchorState.start,
    zone: 'nature',
    allowedFamilies: ['nature', 'edge'],
    radius: 58,
    color: Color(0xFF8CE092),
  ),
  _PlotAnchor(
    id: 'A-NATURE-W',
    center: Offset(182, 522),
    state: _PlotAnchorState.reserved,
    zone: 'edge',
    allowedFamilies: ['nature', 'safe'],
    radius: 50,
    color: Color(0xFF8CE092),
  ),
  _PlotAnchor(
    id: 'A-LEARN-N',
    center: Offset(527, 209),
    state: _PlotAnchorState.start,
    zone: 'learning',
    allowedFamilies: ['learning', 'codex'],
    radius: 56,
    color: Color(0xFFB9A6FF),
  ),
  _PlotAnchor(
    id: 'A-MARKET-HUB',
    center: Offset(640, 470),
    state: _PlotAnchorState.expansion,
    zone: 'market',
    allowedFamilies: ['market', 'hub'],
    radius: 56,
    color: Color(0xFFFFB56F),
  ),
  _PlotAnchor(
    id: 'A-MARKET-SE',
    center: Offset(737, 610),
    state: _PlotAnchorState.reserved,
    zone: 'market',
    allowedFamilies: ['market', 'food'],
    radius: 58,
    color: Color(0xFFFFB56F),
  ),
  _PlotAnchor(
    id: 'A-CRAFT-SE',
    center: Offset(874, 707),
    state: _PlotAnchorState.expansion,
    zone: 'craft',
    allowedFamilies: ['craft', 'edge'],
    radius: 58,
    color: Color(0xFFFF9D8D),
  ),
  _PlotAnchor(
    id: 'A-CRAFT-E',
    center: Offset(930, 558),
    state: _PlotAnchorState.reserved,
    zone: 'edge',
    allowedFamilies: ['craft', 'safe'],
    radius: 50,
    color: Color(0xFFFF9D8D),
  ),
  _PlotAnchor(
    id: 'A-STORAGE-E',
    center: Offset(762, 385),
    state: _PlotAnchorState.expansion,
    zone: 'storage',
    allowedFamilies: ['container', 'hub-near'],
    radius: 52,
    color: Color(0xFFA9D2FF),
  ),
  _PlotAnchor(
    id: 'A-CODEX-NE',
    center: Offset(792, 223),
    state: _PlotAnchorState.expansion,
    zone: 'codex',
    allowedFamilies: ['codex', 'quiet'],
    radius: 58,
    color: Color(0xFFD6F18C),
  ),
  _PlotAnchor(
    id: 'A-CODEX-Q',
    center: Offset(618, 166),
    state: _PlotAnchorState.reserved,
    zone: 'quiet',
    allowedFamilies: ['codex', 'learning'],
    radius: 48,
    color: Color(0xFFD6F18C),
  ),
  _PlotAnchor(
    id: 'A-SAFE-E',
    center: Offset(956, 430),
    state: _PlotAnchorState.expansion,
    zone: 'safe',
    allowedFamilies: ['safe', 'edge'],
    radius: 56,
    color: Color(0xFFFFD37A),
  ),
  _PlotAnchor(
    id: 'A-SAFE-S',
    center: Offset(760, 770),
    state: _PlotAnchorState.reserved,
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
