import 'package:flutter/material.dart';

const _background = Color(0xFF050811);
const _water = Color(0xFF0A3145);
const _waterLight = Color(0xFF46D5FF);
const _land = Color(0xFF172E25);
const _landLight = Color(0xFF9FF7D5);
const _soilLoose = Color(0xFF4A3427);
const _soilPrepared = Color(0xFF735D3F);
const _stone = Color(0xFFBBC7C3);
const _mist = Color(0xFFB7FFF0);
const _gold = Color(0xFFFFD980);
const _warning = Color(0xFFFFC66D);
const _panel = Color(0xFF101923);
const _workerBlue = Color(0xFF8FCBFF);
const _showDebugWorkPath = false;

class LocalObjectFoundationBuildsitePuzzlePreview extends StatefulWidget {
  const LocalObjectFoundationBuildsitePuzzlePreview({super.key});

  @override
  State<LocalObjectFoundationBuildsitePuzzlePreview> createState() =>
      _LocalObjectFoundationBuildsitePuzzlePreviewState();
}

class _LocalObjectFoundationBuildsitePuzzlePreviewState
    extends State<LocalObjectFoundationBuildsitePuzzlePreview> {
  _BuildsiteStage _stage = _BuildsiteStage.groundLoose;
  _WorkerJobPhase _jobPhase = _WorkerJobPhase.idle;
  _WorkerSpot _workerSpot = _WorkerSpot.toolEdge;
  _BuildAction? _recentAction;
  int _workStep = 0;
  int _jobToken = 0;
  bool _isWrongAttempt = false;
  String? _bubble = 'Der Boden ist locker.';

  bool get _isFoundationPlaced => _stage == _BuildsiteStage.foundationPlaced;
  bool get _isWorkerBusy => _jobPhase != _WorkerJobPhase.idle;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: _background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _landLight,
        brightness: Brightness.dark,
      ),
      textTheme: ThemeData.dark(useMaterial3: true).textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _BuildsiteWorld(
                stage: _stage,
                jobPhase: _jobPhase,
                workerSpot: _workerSpot,
                recentAction: _recentAction,
                workStep: _workStep,
                isWrongAttempt: _isWrongAttempt,
                isWorkerBusy: _isWorkerBusy,
                onGroundTap: _clearTransientBubble,
                onActionTry: _tryAction,
              ),
              const Positioned(left: 12, top: 10, child: _SceneTitle()),
              Positioned(
                right: 10,
                top: 10,
                child: _SafeToolbelt(
                  onBack: _handleBack,
                  onLater: _handleLater,
                  onChange: _resetPuzzle,
                  onArchive: _handleArchive,
                ),
              ),
              Positioned(
                left: 14,
                right: 110,
                top: 66,
                child: _HintBubble(
                  text: _bubble,
                  isSuccess: _isFoundationPlaced,
                ),
              ),
              if (_isFoundationPlaced)
                const Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: _NextHookPill(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _tryAction(_BuildAction action) {
    if (_isWorkerBusy) {
      return;
    }

    if (_stage == _BuildsiteStage.groundLoose) {
      if (action == _BuildAction.shovel) {
        _prepareGround(action);
      } else {
        _showWrongAction(
          action,
          'Noch nicht. Erst muss der Boden vorbereitet werden.',
        );
      }
      return;
    }

    if (_stage == _BuildsiteStage.groundPrepared) {
      if (action == _BuildAction.foundationStones) {
        _layFoundation(action);
      } else {
        _showWrongAction(
          action,
          'Noch nicht. Erst braucht das Haus einen festen Grund.',
        );
      }
      return;
    }

    setState(() {
      _recentAction = action;
      _isWrongAttempt = false;
      _workerSpot = _WorkerSpot.foundation;
      _bubble = 'Außenwände später.';
    });
  }

  void _showWrongAction(_BuildAction action, String message) {
    setState(() {
      _recentAction = action;
      _isWrongAttempt = true;
      _workStep = 0;
      _bubble = message;
    });
  }

  Future<void> _prepareGround(_BuildAction action) async {
    final jobToken = ++_jobToken;
    setState(() {
      _stage = _BuildsiteStage.workerPreparingGround;
      _jobPhase = _WorkerJobPhase.walkingToGround;
      _workerSpot = _WorkerSpot.groundLeft;
      _recentAction = action;
      _isWrongAttempt = false;
      _workStep = 0;
      _bubble = 'Der Boden wird eben.';
    });

    if (!await _waitForJob(jobToken, const Duration(milliseconds: 680))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.diggingStep1,
      1,
      workerSpot: _WorkerSpot.groundLeft,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 620))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.walkingToGround,
      1,
      workerSpot: _WorkerSpot.groundTop,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 540))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.diggingStep2,
      2,
      workerSpot: _WorkerSpot.groundTop,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 620))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.walkingToGround,
      2,
      workerSpot: _WorkerSpot.groundRight,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 540))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.diggingStep3,
      3,
      workerSpot: _WorkerSpot.groundRight,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 640))) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _stage = _BuildsiteStage.groundPrepared;
      _jobPhase = _WorkerJobPhase.idle;
      _workerSpot = _WorkerSpot.groundRight;
      _workStep = 0;
      _bubble = 'Der Boden wird eben.';
    });
  }

  Future<void> _layFoundation(_BuildAction action) async {
    final jobToken = ++_jobToken;
    setState(() {
      _stage = _BuildsiteStage.workerFetchingStones;
      _jobPhase = _WorkerJobPhase.walkingToStonePile;
      _workerSpot = _WorkerSpot.stones;
      _recentAction = action;
      _isWrongAttempt = false;
      _workStep = 0;
      _bubble = 'Steine werden gelegt.';
    });

    if (!await _waitForJob(jobToken, const Duration(milliseconds: 720))) {
      return;
    }
    _setJobStep(jobToken, _WorkerJobPhase.pickingUpStones, 1);
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 560))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.carryingStones,
      0,
      workerSpot: _WorkerSpot.foundationLeft,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 720))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.placingLayer1,
      1,
      stage: _BuildsiteStage.workerLayingFoundation,
      workerSpot: _WorkerSpot.foundationLeft,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 620))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.walkingToStonePile,
      1,
      workerSpot: _WorkerSpot.stones,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 560))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.pickingUpStones,
      1,
      workerSpot: _WorkerSpot.stones,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 500))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.carryingStones,
      1,
      workerSpot: _WorkerSpot.foundationRight,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 700))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.placingLayer2,
      2,
      workerSpot: _WorkerSpot.foundationRight,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 620))) {
      return;
    }
    _setJobStep(
      jobToken,
      _WorkerJobPhase.aligningFoundation,
      3,
      workerSpot: _WorkerSpot.foundation,
    );
    if (!await _waitForJob(jobToken, const Duration(milliseconds: 720))) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _stage = _BuildsiteStage.foundationPlaced;
      _jobPhase = _WorkerJobPhase.idle;
      _workerSpot = _WorkerSpot.foundation;
      _workStep = 3;
      _bubble = 'Der Boden hält. Außenwände später.';
    });
  }

  Future<bool> _waitForJob(int jobToken, Duration delay) async {
    await Future<void>.delayed(delay);
    return mounted && _jobToken == jobToken;
  }

  void _setJobStep(
    int jobToken,
    _WorkerJobPhase jobPhase,
    int workStep, {
    _BuildsiteStage? stage,
    _WorkerSpot? workerSpot,
  }) {
    if (!mounted || _jobToken != jobToken) {
      return;
    }
    setState(() {
      if (stage != null) {
        _stage = stage;
      }
      _jobPhase = jobPhase;
      _workerSpot = workerSpot ?? _workerSpot;
      _workStep = workStep;
      _bubble =
          jobPhase == _WorkerJobPhase.diggingStep1 ||
              jobPhase == _WorkerJobPhase.diggingStep2 ||
              jobPhase == _WorkerJobPhase.diggingStep3
          ? 'Der Boden wird eben.'
          : 'Steine werden gelegt.';
    });
  }

  void _clearTransientBubble() {
    if (_isWorkerBusy) {
      return;
    }
    setState(() {
      if (_isWrongAttempt) {
        _isWrongAttempt = false;
        _recentAction = null;
      }
      _bubble = null;
    });
  }

  void _handleBack() {
    _cancelToLoose('Zurück zur Lichtung bleibt möglich.');
  }

  void _handleLater() {
    setState(() {
      _bubble = 'Später ist okay. Der Bauplatz wartet.';
    });
  }

  void _handleArchive() {
    setState(() {
      _bubble = 'Wird später im Wortarchiv wiedergefunden.';
    });
  }

  void _resetPuzzle() {
    _cancelToLoose('Der Boden ist locker.');
  }

  void _cancelToLoose(String bubble) {
    _jobToken++;
    setState(() {
      _stage = _BuildsiteStage.groundLoose;
      _jobPhase = _WorkerJobPhase.idle;
      _workerSpot = _WorkerSpot.toolEdge;
      _recentAction = null;
      _workStep = 0;
      _isWrongAttempt = false;
      _bubble = bubble;
    });
  }
}

enum _BuildsiteStage {
  groundLoose,
  workerPreparingGround,
  groundPrepared,
  workerFetchingStones,
  workerLayingFoundation,
  foundationPlaced,
}

enum _WorkerJobPhase {
  idle,
  walkingToGround,
  diggingStep1,
  diggingStep2,
  diggingStep3,
  walkingToStonePile,
  pickingUpStones,
  carryingStones,
  placingLayer1,
  placingLayer2,
  aligningFoundation,
}

enum _WorkerSpot {
  toolEdge,
  groundLeft,
  groundTop,
  groundRight,
  stones,
  foundationLeft,
  foundationRight,
  foundation,
}

enum _BuildAction { shovel, foundationStones, window, roof }

extension _BuildActionText on _BuildAction {
  String get label {
    switch (this) {
      case _BuildAction.shovel:
        return 'Spaten';
      case _BuildAction.foundationStones:
        return 'Fundamentsteine';
      case _BuildAction.window:
        return 'Fenster';
      case _BuildAction.roof:
        return 'Dach';
    }
  }

  String get shortLabel {
    switch (this) {
      case _BuildAction.foundationStones:
        return 'Steine';
      case _BuildAction.shovel:
      case _BuildAction.window:
      case _BuildAction.roof:
        return label;
    }
  }

  IconData get icon {
    switch (this) {
      case _BuildAction.shovel:
        return Icons.construction_rounded;
      case _BuildAction.foundationStones:
        return Icons.foundation_rounded;
      case _BuildAction.window:
        return Icons.window_rounded;
      case _BuildAction.roof:
        return Icons.roofing_rounded;
    }
  }

  Color get color {
    switch (this) {
      case _BuildAction.shovel:
        return _gold;
      case _BuildAction.foundationStones:
        return _landLight;
      case _BuildAction.window:
        return const Color(0xFF92C9FF);
      case _BuildAction.roof:
        return const Color(0xFFFFD980);
    }
  }
}

class _BuildsiteWorld extends StatelessWidget {
  const _BuildsiteWorld({
    required this.stage,
    required this.jobPhase,
    required this.workerSpot,
    required this.recentAction,
    required this.workStep,
    required this.isWrongAttempt,
    required this.isWorkerBusy,
    required this.onGroundTap,
    required this.onActionTry,
  });

  final _BuildsiteStage stage;
  final _WorkerJobPhase jobPhase;
  final _WorkerSpot workerSpot;
  final _BuildAction? recentAction;
  final int workStep;
  final bool isWrongAttempt;
  final bool isWorkerBusy;
  final VoidCallback onGroundTap;
  final ValueChanged<_BuildAction> onActionTry;

  bool get _foundationPlaced => stage == _BuildsiteStage.foundationPlaced;
  bool get _stonesVisible =>
      stage == _BuildsiteStage.groundPrepared ||
      stage == _BuildsiteStage.workerFetchingStones ||
      stage == _BuildsiteStage.workerLayingFoundation ||
      stage == _BuildsiteStage.foundationPlaced;

  List<_BuildAction> get _availableActions {
    if (stage == _BuildsiteStage.groundLoose ||
        stage == _BuildsiteStage.workerPreparingGround) {
      return const [
        _BuildAction.shovel,
        _BuildAction.window,
        _BuildAction.roof,
      ];
    }
    return const [
      _BuildAction.foundationStones,
      _BuildAction.window,
      _BuildAction.roof,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final actionGap = width < 390 ? 7.0 : 10.0;
        final actionWidth = (width - 32 - (actionGap * 2)) / 3;
        final actionTop = height * 0.73;
        final workZoneLeft = width * 0.26;
        final workZoneTop = height * 0.31;
        final workZoneWidth = width * 0.48;
        final workZoneHeight = height * 0.22;
        final workerOffset = _workerOffset(width, height, workerSpot);

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onGroundTap,
                child: CustomPaint(
                  painter: _BuildsitePainter(
                    stage: stage,
                    jobPhase: jobPhase,
                    workerSpot: workerSpot,
                    workStep: workStep,
                  ),
                ),
              ),
            ),
            Positioned(
              left: workZoneLeft,
              top: workZoneTop,
              width: workZoneWidth,
              height: workZoneHeight,
              child: DragTarget<_BuildAction>(
                onWillAcceptWithDetails: (_) =>
                    !_foundationPlaced && !isWorkerBusy,
                onAcceptWithDetails: (details) => onActionTry(details.data),
                builder: (context, candidateActions, rejectedActions) {
                  return _WorkZone(
                    stage: stage,
                    isHovering: candidateActions.isNotEmpty,
                  );
                },
              ),
            ),
            if (_stonesVisible)
              Positioned(
                left: width * 0.69,
                top: height * 0.58,
                width: 70,
                height: 52,
                child: _StonePile(
                  isActive:
                      jobPhase == _WorkerJobPhase.walkingToStonePile ||
                      jobPhase == _WorkerJobPhase.pickingUpStones ||
                      jobPhase == _WorkerJobPhase.carryingStones ||
                      jobPhase == _WorkerJobPhase.placingLayer1 ||
                      jobPhase == _WorkerJobPhase.placingLayer2 ||
                      jobPhase == _WorkerJobPhase.aligningFoundation,
                  useStep: _stoneUseStep,
                  isSpent: _foundationPlaced,
                ),
              ),
            if (_foundationPlaced)
              Positioned(
                left: width * 0.33,
                top: height * 0.23,
                width: width * 0.34,
                child: const _WallGhostLabel(),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              left: workerOffset.dx,
              top: workerOffset.dy,
              child: _BuildHelper(
                action: _workerAction,
                isWorking: _workerIsWorking,
                workStep: workStep,
              ),
            ),
            ..._availableActions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              final isWrongAction =
                  isWrongAttempt &&
                  recentAction == action &&
                  !_isCorrectForCurrentStage(action);
              final isSpent =
                  _foundationPlaced && action == _BuildAction.foundationStones;
              final isDisabled = isWorkerBusy || isSpent;
              return Positioned(
                left: 16 + ((actionWidth + actionGap) * index),
                top: actionTop,
                width: actionWidth,
                child: _BuildActionDraggable(
                  action: action,
                  isWrongAction: isWrongAction,
                  isDimmed: isDisabled,
                  isDisabled: isDisabled,
                  onTap: () => onActionTry(action),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  _BuildAction? get _workerAction {
    if (workerSpot == _WorkerSpot.toolEdge) {
      return null;
    }
    if (jobPhase == _WorkerJobPhase.walkingToGround ||
        jobPhase == _WorkerJobPhase.diggingStep1 ||
        jobPhase == _WorkerJobPhase.diggingStep2 ||
        jobPhase == _WorkerJobPhase.diggingStep3) {
      return _BuildAction.shovel;
    }
    if (jobPhase == _WorkerJobPhase.pickingUpStones ||
        jobPhase == _WorkerJobPhase.carryingStones ||
        jobPhase == _WorkerJobPhase.placingLayer1 ||
        jobPhase == _WorkerJobPhase.placingLayer2 ||
        jobPhase == _WorkerJobPhase.aligningFoundation) {
      return _BuildAction.foundationStones;
    }
    return null;
  }

  bool get _workerIsWorking =>
      jobPhase == _WorkerJobPhase.diggingStep1 ||
      jobPhase == _WorkerJobPhase.diggingStep2 ||
      jobPhase == _WorkerJobPhase.diggingStep3 ||
      jobPhase == _WorkerJobPhase.pickingUpStones ||
      jobPhase == _WorkerJobPhase.placingLayer1 ||
      jobPhase == _WorkerJobPhase.placingLayer2 ||
      jobPhase == _WorkerJobPhase.aligningFoundation;

  int get _stoneUseStep {
    switch (jobPhase) {
      case _WorkerJobPhase.placingLayer1:
        return 1;
      case _WorkerJobPhase.placingLayer2:
        return 2;
      case _WorkerJobPhase.aligningFoundation:
        return 3;
      case _WorkerJobPhase.idle:
      case _WorkerJobPhase.walkingToGround:
      case _WorkerJobPhase.diggingStep1:
      case _WorkerJobPhase.diggingStep2:
      case _WorkerJobPhase.diggingStep3:
      case _WorkerJobPhase.walkingToStonePile:
      case _WorkerJobPhase.pickingUpStones:
      case _WorkerJobPhase.carryingStones:
        return 0;
    }
  }

  bool _isCorrectForCurrentStage(_BuildAction action) {
    if (stage == _BuildsiteStage.groundLoose ||
        stage == _BuildsiteStage.workerPreparingGround) {
      return action == _BuildAction.shovel;
    }
    if (stage == _BuildsiteStage.groundPrepared ||
        stage == _BuildsiteStage.workerFetchingStones ||
        stage == _BuildsiteStage.workerLayingFoundation) {
      return action == _BuildAction.foundationStones;
    }
    return false;
  }

  Offset _workerOffset(double width, double height, _WorkerSpot spot) {
    switch (spot) {
      case _WorkerSpot.toolEdge:
        return Offset(width * 0.16, height * 0.61);
      case _WorkerSpot.groundLeft:
        return Offset(width * 0.31, height * 0.52);
      case _WorkerSpot.groundTop:
        return Offset(width * 0.45, height * 0.39);
      case _WorkerSpot.groundRight:
        return Offset(width * 0.60, height * 0.51);
      case _WorkerSpot.stones:
        return Offset(width * 0.70, height * 0.56);
      case _WorkerSpot.foundationLeft:
        return Offset(width * 0.40, height * 0.43);
      case _WorkerSpot.foundationRight:
        return Offset(width * 0.60, height * 0.44);
      case _WorkerSpot.foundation:
        return Offset(width * 0.56, height * 0.43);
    }
  }
}

class _WorkZone extends StatelessWidget {
  const _WorkZone({required this.stage, required this.isHovering});

  final _BuildsiteStage stage;
  final bool isHovering;

  bool get _foundationPlaced => stage == _BuildsiteStage.foundationPlaced;
  bool get _groundPrepared =>
      stage == _BuildsiteStage.groundPrepared ||
      stage == _BuildsiteStage.workerFetchingStones ||
      stage == _BuildsiteStage.workerLayingFoundation ||
      stage == _BuildsiteStage.foundationPlaced;
  @override
  Widget build(BuildContext context) {
    final color = _foundationPlaced
        ? _landLight
        : _groundPrepared
        ? _gold
        : _mist;
    return Semantics(
      label: 'Arbeitszone am Bauplatz',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _foundationPlaced
              ? _landLight.withValues(alpha: 0.07)
              : isHovering
              ? color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isHovering || _foundationPlaced
                ? color.withValues(alpha: _foundationPlaced ? 0.28 : 0.30)
                : Colors.transparent,
            width: _foundationPlaced ? 2 : 1.4,
          ),
          boxShadow: [
            if (_foundationPlaced)
              BoxShadow(
                color: _landLight.withValues(alpha: 0.14),
                blurRadius: 26,
                spreadRadius: -4,
              ),
            if (isHovering)
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 24,
                spreadRadius: 1,
              ),
          ],
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _StonePile extends StatelessWidget {
  const _StonePile({
    required this.isActive,
    required this.useStep,
    required this.isSpent,
  });

  final bool isActive;
  final int useStep;
  final bool isSpent;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: isSpent ? 0.42 : 1,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          scale: isActive ? 1.04 : 1,
          child: CustomPaint(
            painter: _StonePilePainter(isActive: isActive, useStep: useStep),
          ),
        ),
      ),
    );
  }
}

class _StonePilePainter extends CustomPainter {
  const _StonePilePainter({required this.isActive, required this.useStep});

  final bool isActive;
  final int useStep;

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.82),
        width: size.width * 0.82,
        height: size.height * 0.24,
      ),
      shadowPaint,
    );

    final stones = <Offset>[
      Offset(size.width * 0.28, size.height * 0.62),
      Offset(size.width * 0.44, size.height * 0.48),
      Offset(size.width * 0.60, size.height * 0.61),
      Offset(size.width * 0.52, size.height * 0.32),
      Offset(size.width * 0.72, size.height * 0.50),
    ];
    for (var i = 0; i < stones.length; i++) {
      final isUsed = i < useStep;
      final radius = i == 3 ? 9.0 : 10.5;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: stones[i],
          width: radius * 2.2,
          height: radius * 1.55,
        ),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        rect.shift(const Offset(2, 2)),
        Paint()..color = Colors.black.withValues(alpha: 0.22),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = (isActive ? _landLight : _stone).withValues(
            alpha: isUsed ? 0.24 : 0.86,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StonePilePainter oldDelegate) {
    return oldDelegate.isActive != isActive || oldDelegate.useStep != useStep;
  }
}

class _BuildHelper extends StatelessWidget {
  const _BuildHelper({
    required this.action,
    required this.isWorking,
    required this.workStep,
  });

  final _BuildAction? action;
  final bool isWorking;
  final int workStep;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 62,
        height: 72,
        child: CustomPaint(
          painter: _BuildHelperPainter(
            action: action,
            isWorking: isWorking,
            workStep: workStep,
          ),
        ),
      ),
    );
  }
}

class _BuildHelperPainter extends CustomPainter {
  const _BuildHelperPainter({
    required this.action,
    required this.isWorking,
    required this.workStep,
  });

  final _BuildAction? action;
  final bool isWorking;
  final int workStep;

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.88),
        width: size.width * 0.62,
        height: size.height * 0.16,
      ),
      shadowPaint,
    );

    final bob = isWorking ? (workStep.isEven ? 0.0 : 3.0) : 0.0;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.56 + bob),
        width: size.width * 0.36,
        height: size.height * 0.34,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, Paint()..color = _workerBlue);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.38),
    );

    final headCenter = Offset(size.width * 0.50, size.height * 0.28 + bob);
    canvas.drawCircle(headCenter, size.width * 0.15, Paint()..color = _gold);
    canvas.drawArc(
      Rect.fromCircle(center: headCenter.translate(0, -2), radius: 12),
      3.20,
      3.15,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = _panel,
    );

    final legPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = _workerBlue.withValues(alpha: 0.95);
    canvas.drawLine(
      Offset(size.width * 0.43, size.height * 0.72),
      Offset(size.width * 0.33, size.height * 0.84),
      legPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.57, size.height * 0.72),
      Offset(size.width * 0.67, size.height * 0.84),
      legPaint,
    );

    final armPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = _workerBlue;
    final swing = isWorking ? (workStep.isEven ? -9.0 : 6.0) : 0.0;
    final armLift = isWorking ? swing : 0.0;
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.50),
      Offset(size.width * 0.18, size.height * (0.62) + armLift),
      armPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.50),
      Offset(size.width * 0.82, size.height * (0.62) + armLift),
      armPaint,
    );

    if (action == _BuildAction.shovel) {
      final toolPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = _gold;
      final toolSwing = isWorking ? (workStep.isEven ? -5.0 : 7.0) : 0.0;
      canvas.drawLine(
        Offset(size.width * 0.72, size.height * 0.35 + toolSwing),
        Offset(size.width * 0.30, size.height * 0.82 - toolSwing),
        toolPaint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.27, size.height * 0.85 - toolSwing),
        5,
        Paint()..color = _gold,
      );
    } else if (action == _BuildAction.foundationStones) {
      final carryLift = isWorking ? (workStep.isEven ? -2.0 : 4.0) : 0.0;
      final blockPaint = Paint()..color = _landLight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.13,
            size.height * 0.68 + carryLift,
            size.width * 0.24,
            size.height * 0.14,
          ),
          const Radius.circular(4),
        ),
        blockPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.62,
            size.height * 0.67 + carryLift,
            size.width * 0.24,
            size.height * 0.14,
          ),
          const Radius.circular(4),
        ),
        blockPaint,
      );
    } else {
      canvas.drawCircle(
        Offset(size.width * 0.77, size.height * 0.18),
        4,
        Paint()..color = _landLight,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BuildHelperPainter oldDelegate) {
    return oldDelegate.action != action ||
        oldDelegate.isWorking != isWorking ||
        oldDelegate.workStep != workStep;
  }
}

class _BuildActionDraggable extends StatelessWidget {
  const _BuildActionDraggable({
    required this.action,
    required this.isWrongAction,
    required this.isDimmed,
    required this.isDisabled,
    required this.onTap,
  });

  final _BuildAction action;
  final bool isWrongAction;
  final bool isDimmed;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final object = AnimatedSlide(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      offset: isWrongAction ? const Offset(0.05, 0) : Offset.zero,
      child: _BuildActionObject(
        action: action,
        isWrongAction: isWrongAction,
        isDimmed: isDimmed,
        onTap: onTap,
      ),
    );

    if (isDisabled) {
      return object;
    }

    return Draggable<_BuildAction>(
      data: action,
      maxSimultaneousDrags: 1,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 108,
          child: _BuildActionObject(
            action: action,
            isWrongAction: false,
            isDimmed: false,
            onTap: () {},
            isFloating: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.42, child: object),
      child: object,
    );
  }
}

class _BuildActionObject extends StatelessWidget {
  const _BuildActionObject({
    required this.action,
    required this.isWrongAction,
    required this.isDimmed,
    required this.onTap,
    this.isFloating = false,
  });

  final _BuildAction action;
  final bool isWrongAction;
  final bool isDimmed;
  final VoidCallback onTap;
  final bool isFloating;

  @override
  Widget build(BuildContext context) {
    final color = isWrongAction ? _warning : action.color;
    return Semantics(
      button: true,
      label: '${action.label} am Bauplatz nutzen',
      child: GestureDetector(
        onTap: isDimmed ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: _panel.withValues(alpha: isDimmed ? 0.50 : 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: isDimmed ? 0.26 : 0.78),
              width: isWrongAction ? 2 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isFloating ? 0.28 : 0.15),
                blurRadius: isFloating ? 28 : 18,
                spreadRadius: isFloating ? 1 : -6,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                color: color.withValues(alpha: isDimmed ? 0.55 : 1),
                size: 28,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    action.shortLabel,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: isDimmed ? 0.58 : 0.96,
                      ),
                      fontSize: 13,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
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

class _SceneTitle extends StatelessWidget {
  const _SceneTitle();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panel.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _landLight.withValues(alpha: 0.24)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terrain_rounded, color: _landLight, size: 18),
            SizedBox(width: 7),
            Text(
              'Uferhain',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeToolbelt extends StatelessWidget {
  const _SafeToolbelt({
    required this.onBack,
    required this.onLater,
    required this.onChange,
    required this.onArchive,
  });

  final VoidCallback onBack;
  final VoidCallback onLater;
  final VoidCallback onChange;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ToolPill(
            icon: Icons.arrow_back_rounded,
            label: 'Zurück',
            onTap: onBack,
          ),
          const SizedBox(height: 5),
          _ToolPill(
            icon: Icons.schedule_rounded,
            label: 'Später',
            onTap: onLater,
          ),
          const SizedBox(height: 5),
          _ToolPill(icon: Icons.tune_rounded, label: 'Ändern', onTap: onChange),
          const SizedBox(height: 5),
          _ToolPill(
            icon: Icons.inventory_2_rounded,
            label: 'Archiv',
            onTap: onArchive,
          ),
        ],
      ),
    );
  }
}

class _ToolPill extends StatelessWidget {
  const _ToolPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _panel.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: Colors.white70),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
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

class _HintBubble extends StatelessWidget {
  const _HintBubble({required this.text, required this.isSuccess});

  final String? text;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: text == null ? 0 : 1,
        child: Align(
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _panel.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (isSuccess ? _landLight : _mist).withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: _background.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Text(
                text ?? '',
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextHookPill extends StatelessWidget {
  const _NextHookPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _gold.withValues(alpha: 0.48)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, color: _gold, size: 17),
              SizedBox(width: 7),
              Text(
                'Außenwände später',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WallGhostLabel extends StatelessWidget {
  const _WallGhostLabel();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _panel.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withValues(alpha: 0.32)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Wand-Schatten',
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildsitePainter extends CustomPainter {
  const _BuildsitePainter({
    required this.stage,
    required this.jobPhase,
    required this.workerSpot,
    required this.workStep,
  });

  final _BuildsiteStage stage;
  final _WorkerJobPhase jobPhase;
  final _WorkerSpot workerSpot;
  final int workStep;

  bool get _groundPrepared =>
      stage == _BuildsiteStage.groundPrepared ||
      stage == _BuildsiteStage.workerFetchingStones ||
      stage == _BuildsiteStage.workerLayingFoundation ||
      stage == _BuildsiteStage.foundationPlaced;
  bool get _foundationPlaced => stage == _BuildsiteStage.foundationPlaced;
  bool get _isDigging =>
      jobPhase == _WorkerJobPhase.diggingStep1 ||
      jobPhase == _WorkerJobPhase.diggingStep2 ||
      jobPhase == _WorkerJobPhase.diggingStep3;
  bool get _isPlacing =>
      jobPhase == _WorkerJobPhase.placingLayer1 ||
      jobPhase == _WorkerJobPhase.placingLayer2 ||
      jobPhase == _WorkerJobPhase.aligningFoundation;

  int get _groundProgress {
    if (stage == _BuildsiteStage.workerPreparingGround) {
      return _clampStep(workStep);
    }
    switch (jobPhase) {
      case _WorkerJobPhase.diggingStep1:
        return 1;
      case _WorkerJobPhase.diggingStep2:
        return 2;
      case _WorkerJobPhase.diggingStep3:
        return 3;
      case _WorkerJobPhase.idle:
      case _WorkerJobPhase.walkingToGround:
      case _WorkerJobPhase.walkingToStonePile:
      case _WorkerJobPhase.pickingUpStones:
      case _WorkerJobPhase.carryingStones:
      case _WorkerJobPhase.placingLayer1:
      case _WorkerJobPhase.placingLayer2:
      case _WorkerJobPhase.aligningFoundation:
        break;
    }
    if (_groundPrepared) {
      return 3;
    }
    return 0;
  }

  int get _foundationProgress {
    if (stage == _BuildsiteStage.workerLayingFoundation) {
      return _clampStep(workStep);
    }
    switch (jobPhase) {
      case _WorkerJobPhase.placingLayer1:
        return 1;
      case _WorkerJobPhase.placingLayer2:
        return 2;
      case _WorkerJobPhase.aligningFoundation:
        return 3;
      case _WorkerJobPhase.idle:
      case _WorkerJobPhase.walkingToGround:
      case _WorkerJobPhase.diggingStep1:
      case _WorkerJobPhase.diggingStep2:
      case _WorkerJobPhase.diggingStep3:
      case _WorkerJobPhase.walkingToStonePile:
      case _WorkerJobPhase.pickingUpStones:
      case _WorkerJobPhase.carryingStones:
        break;
    }
    if (_foundationPlaced) {
      return 3;
    }
    return 0;
  }

  int _clampStep(int value) {
    if (value < 0) {
      return 0;
    }
    if (value > 3) {
      return 3;
    }
    return value;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF071A26), _background],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    _drawWater(canvas, size);
    _drawLand(canvas, size);
    _drawBuildPatch(canvas, size);
    _drawPreparedZones(canvas, size);
    _drawGroundState(canvas, size);
    if (_foundationProgress > 0) {
      _drawFoundationProgress(canvas, size, _foundationProgress);
    }
    if (_foundationPlaced) {
      _drawWallGhost(canvas, size);
    }
    if (_isDigging || _isPlacing) {
      _drawWorkDust(canvas, size);
    }
    if (_showDebugWorkPath && jobPhase != _WorkerJobPhase.idle) {
      _drawWorkRoute(canvas, size);
    }
    _drawForegroundStones(canvas, size);
  }

  void _drawWater(Canvas canvas, Size size) {
    final waterPath = Path()
      ..moveTo(0, size.height * 0.06)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.18,
        size.width * 0.10,
        size.height * 0.46,
        size.width * 0.20,
        size.height * 0.64,
      )
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.79,
        size.width * 0.16,
        size.height,
        0,
        size.height,
      )
      ..close();

    canvas.drawPath(waterPath, Paint()..color = _water);
    canvas.drawPath(
      waterPath.shift(const Offset(8, 0)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _waterLight.withValues(alpha: 0.24),
    );
  }

  void _drawLand(Canvas canvas, Size size) {
    final landPath = Path()
      ..moveTo(size.width * 0.07, size.height * 0.19)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.05,
        size.width * 0.82,
        size.height * 0.06,
        size.width * 0.94,
        size.height * 0.28,
      )
      ..cubicTo(
        size.width,
        size.height * 0.43,
        size.width * 0.95,
        size.height * 0.83,
        size.width * 0.75,
        size.height * 0.91,
      )
      ..cubicTo(
        size.width * 0.46,
        size.height,
        size.width * 0.16,
        size.height * 0.84,
        size.width * 0.10,
        size.height * 0.57,
      )
      ..cubicTo(
        size.width * 0.04,
        size.height * 0.37,
        size.width * 0.02,
        size.height * 0.25,
        size.width * 0.07,
        size.height * 0.19,
      )
      ..close();

    canvas.drawShadow(landPath, Colors.black, 16, true);
    canvas.drawPath(landPath, Paint()..color = _land);
    canvas.drawPath(
      landPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _landLight.withValues(alpha: 0.34),
    );

    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13
      ..color = const Color(0xFF685539).withValues(alpha: 0.58);
    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.64)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.54,
        size.width * 0.43,
        size.height * 0.45,
        size.width * 0.53,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.39,
        size.width * 0.72,
        size.height * 0.32,
        size.width * 0.78,
        size.height * 0.24,
      );
    canvas.drawPath(path, pathPaint);
  }

  void _drawBuildPatch(Canvas canvas, Size size) {
    final progress = _groundProgress;
    final patchRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.43),
      width: size.width * 0.58,
      height: size.height * 0.29,
    );
    final patchColor = Color.lerp(_soilLoose, _soilPrepared, progress / 3)!;
    canvas.drawOval(
      patchRect,
      Paint()
        ..color = patchColor.withValues(
          alpha: _foundationPlaced ? 0.82 : 0.66 + (progress * 0.04),
        ),
    );
    canvas.drawOval(
      patchRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _groundPrepared ? 2.6 : 2
        ..color = Color.lerp(
          _mist,
          _landLight,
          progress / 3,
        )!.withValues(alpha: 0.18 + (progress * 0.06)),
    );
  }

  void _drawPreparedZones(Canvas canvas, Size size) {
    final progress = _groundProgress;
    if (progress == 0) {
      return;
    }

    final zonePaint = Paint()
      ..color = _soilPrepared.withValues(alpha: 0.18 + (progress * 0.03));
    final zones = <Rect>[
      Rect.fromCenter(
        center: Offset(size.width * 0.39, size.height * 0.48),
        width: size.width * 0.28,
        height: size.height * 0.13,
      ),
      Rect.fromCenter(
        center: Offset(size.width * 0.51, size.height * 0.39),
        width: size.width * 0.30,
        height: size.height * 0.12,
      ),
      Rect.fromCenter(
        center: Offset(size.width * 0.61, size.height * 0.50),
        width: size.width * 0.30,
        height: size.height * 0.13,
      ),
    ];

    for (var i = 0; i < progress; i++) {
      canvas.drawOval(zones[i], zonePaint);
    }
  }

  void _drawGroundState(Canvas canvas, Size size) {
    final progress = _groundProgress;
    if (progress < 3) {
      _drawLooseCracks(canvas, size, progress);
      _drawMist(canvas, size, 0.08 - (progress * 0.018), progress);
    }
    if (progress > 0) {
      _drawPreparedLines(canvas, size, progress);
    }
    if (progress == 3) {
      _drawMist(canvas, size, _foundationPlaced ? 0.018 : 0.032, progress);
    }
  }

  void _drawLooseCracks(Canvas canvas, Size size, int progress) {
    final crackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = Colors.black.withValues(alpha: 0.32 - (progress * 0.08));
    final crack = Path()
      ..moveTo(size.width * 0.37, size.height * 0.38)
      ..lineTo(size.width * 0.45, size.height * 0.42)
      ..lineTo(size.width * 0.42, size.height * 0.48)
      ..lineTo(size.width * 0.52, size.height * 0.51)
      ..lineTo(size.width * 0.57, size.height * 0.57);
    canvas.drawPath(crack, crackPaint);

    if (progress >= 2) {
      return;
    }

    final sideCrack = Path()
      ..moveTo(size.width * 0.60, size.height * 0.36)
      ..lineTo(size.width * 0.55, size.height * 0.43)
      ..lineTo(size.width * 0.62, size.height * 0.47);
    canvas.drawPath(sideCrack, crackPaint);
  }

  void _drawPreparedLines(Canvas canvas, Size size, int progress) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = _gold.withValues(alpha: 0.07 + (progress * 0.035));
    for (var i = 0; i < progress + 2; i++) {
      final y = size.height * (0.36 + (i * 0.045));
      canvas.drawLine(
        Offset(size.width * 0.34, y),
        Offset(size.width * 0.66, y + size.height * 0.015),
        linePaint,
      );
    }
  }

  void _drawMist(Canvas canvas, Size size, double alpha, int progress) {
    final mistPaint = Paint()..color = _mist.withValues(alpha: alpha);
    canvas.drawCircle(
      Offset(size.width * 0.31, size.height * 0.39),
      34 - (progress * 5),
      mistPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.67, size.height * 0.51),
      46 - (progress * 6),
      mistPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.47, size.height * 0.58),
      28 - (progress * 4),
      mistPaint,
    );
  }

  void _drawFoundationProgress(Canvas canvas, Size size, int progress) {
    final foundationRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.42),
        width: size.width * 0.40,
        height: size.height * 0.17,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      foundationRect,
      Paint()..color = _landLight.withValues(alpha: 0.10 + (progress * 0.045)),
    );

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = _landLight.withValues(alpha: 0.48 + (progress * 0.14));
    final rect = foundationRect.outerRect;
    final corners = [
      [Offset(rect.left + 18, rect.top), Offset(rect.right - 18, rect.top)],
      [
        Offset(rect.left + 7, rect.center.dy),
        Offset(rect.right - 7, rect.center.dy),
      ],
      [
        Offset(rect.left + 18, rect.bottom),
        Offset(rect.right - 18, rect.bottom),
      ],
    ];

    for (var i = 0; i < progress; i++) {
      final line = corners[i];
      canvas.drawLine(line[0], line[1], edgePaint);
    }
    if (progress >= 3) {
      canvas.drawRRect(
        foundationRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = _landLight.withValues(alpha: 0.9),
      );

      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.22);
      canvas.drawLine(
        Offset(size.width * 0.38, size.height * 0.42),
        Offset(size.width * 0.62, size.height * 0.42),
        linePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.50, size.height * 0.34),
        Offset(size.width * 0.50, size.height * 0.50),
        linePaint,
      );
    }
  }

  void _drawWallGhost(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = _gold.withValues(alpha: 0.33);

    final wallPath = Path()
      ..moveTo(size.width * 0.37, size.height * 0.34)
      ..lineTo(size.width * 0.37, size.height * 0.24)
      ..lineTo(size.width * 0.63, size.height * 0.24)
      ..lineTo(size.width * 0.63, size.height * 0.34);
    canvas.drawPath(wallPath, wallPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = _gold.withValues(alpha: 0.06);
    canvas.drawPath(wallPath, glowPaint);
  }

  void _drawForegroundStones(Canvas canvas, Size size) {
    final rubblePaint = Paint()..color = _stone.withValues(alpha: 0.48);
    final darkRubblePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22);
    final stones = <Offset>[
      Offset(size.width * 0.26, size.height * 0.56),
      Offset(size.width * 0.72, size.height * 0.42),
      Offset(size.width * 0.65, size.height * 0.62),
      Offset(size.width * 0.32, size.height * 0.31),
      Offset(size.width * 0.79, size.height * 0.72),
    ];

    for (final stone in stones) {
      final radius = 6.0 - (_groundProgress * 1.0);
      canvas.drawCircle(stone.translate(2, 2), radius, darkRubblePaint);
      canvas.drawCircle(stone, radius, rubblePaint);
    }
  }

  void _drawWorkDust(Canvas canvas, Size size) {
    final dustPaint = Paint()..color = _gold.withValues(alpha: 0.10);
    final base = _spotCenter(size, workerSpot);
    for (var i = 0; i < workStep + 2; i++) {
      final offset = Offset((i - 1) * 13.0, (i.isEven ? -6.0 : 7.0));
      canvas.drawCircle(base + offset, 8 - i.toDouble(), dustPaint);
    }
  }

  void _drawWorkRoute(Canvas canvas, Size size) {
    final isGroundRoute =
        jobPhase == _WorkerJobPhase.walkingToGround ||
        jobPhase == _WorkerJobPhase.diggingStep1 ||
        jobPhase == _WorkerJobPhase.diggingStep2 ||
        jobPhase == _WorkerJobPhase.diggingStep3;
    final route = isGroundRoute
        ? <_WorkerSpot>[
            _WorkerSpot.groundLeft,
            _WorkerSpot.groundTop,
            _WorkerSpot.groundRight,
          ]
        : <_WorkerSpot>[
            _WorkerSpot.stones,
            _WorkerSpot.foundationLeft,
            _WorkerSpot.stones,
            _WorkerSpot.foundationRight,
            _WorkerSpot.foundation,
          ];

    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = _gold.withValues(alpha: 0.16);
    final path = Path()
      ..moveTo(
        _spotCenter(size, route.first).dx,
        _spotCenter(size, route.first).dy,
      );
    for (final spot in route.skip(1)) {
      final point = _spotCenter(size, spot);
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, routePaint);

    for (final spot in route) {
      final point = _spotCenter(size, spot);
      final isActive = spot == workerSpot;
      canvas.drawCircle(
        point,
        isActive ? 5.5 : 3.5,
        Paint()
          ..color = (isActive ? _landLight : _gold).withValues(
            alpha: isActive ? 0.54 : 0.24,
          ),
      );
    }
  }

  Offset _spotCenter(Size size, _WorkerSpot spot) {
    switch (spot) {
      case _WorkerSpot.toolEdge:
        return Offset(size.width * 0.20, size.height * 0.65);
      case _WorkerSpot.groundLeft:
        return Offset(size.width * 0.37, size.height * 0.51);
      case _WorkerSpot.groundTop:
        return Offset(size.width * 0.50, size.height * 0.39);
      case _WorkerSpot.groundRight:
        return Offset(size.width * 0.63, size.height * 0.50);
      case _WorkerSpot.stones:
        return Offset(size.width * 0.74, size.height * 0.62);
      case _WorkerSpot.foundationLeft:
        return Offset(size.width * 0.43, size.height * 0.43);
      case _WorkerSpot.foundationRight:
        return Offset(size.width * 0.62, size.height * 0.44);
      case _WorkerSpot.foundation:
        return Offset(size.width * 0.53, size.height * 0.42);
    }
  }

  @override
  bool shouldRepaint(covariant _BuildsitePainter oldDelegate) {
    return oldDelegate.stage != stage ||
        oldDelegate.jobPhase != jobPhase ||
        oldDelegate.workerSpot != workerSpot ||
        oldDelegate.workStep != workStep;
  }
}
