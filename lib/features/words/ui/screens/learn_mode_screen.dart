import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';
import 'package:talvori/core/local_database/adapters/local_learn_mode_ui_adapter.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/models/local_review_visual_feedback.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import '../widgets/widgets.dart';
import 'package:talvori/features/words/ui/widgets/single_mode_switch_row.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/srs_visuals.dart';
import 'package:talvori/features/words/application/s0_lock_provider.dart';
import 'package:talvori/features/words/application/word_list_controller.dart'
    show WordListFilter, WordFilterKind;
import 'package:talvori/features/words/application/learn_navigation_origin.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/widgets/plasma_link_painter.dart';
import 'package:talvori/features/words/ui/widgets/local_stage_inspector_sheet.dart';
import 'package:talvori/features/words/ui/widgets/card_glow_settings_popup.dart';
import 'package:talvori/features/words/ui/widgets/switch_pulse_painter.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart'
    show WordUserView;
import 'package:talvori/core/ui/effects/fireworks_service.dart';
import 'package:talvori/features/words/ui/cards/arrow_fly_service.dart';

class LearnModeScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String title; // z. B. "Money & Shopping"
  final bool useLocalOfflineFlow;
  final String? localCategoryId;
  final LearningMode? localLearningMode;

  // ⬇️ NEU: Custom Wheel für QuickSets
  final List<String>? customWheelLabels;
  final int? customWheelInitialIndex;

  // ⬇️ NEU: Navigation-Herkunft für Back-Button-Logik
  final LearnNavigationOrigin? navigationOrigin;

  const LearnModeScreen({
    super.key,
    required this.categoryId,
    required this.title,
    this.useLocalOfflineFlow = false,
    this.localCategoryId,
    this.localLearningMode,
    this.customWheelLabels, // <— NEU
    this.customWheelInitialIndex, // <— NEU
    this.navigationOrigin, // <— NEU
  });

  @override
  ConsumerState<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends ConsumerState<LearnModeScreen>
    with TickerProviderStateMixin {
  // Controller (Business-Logik)
  LearnModeController? _controller;
  // Controller für Switch-Row Blink-Effekte
  final _switchCtrl = StageSwitchRowController();

  // Plasma-Link: zeigt Herkunft der aktuellen Karte (Stage)
  static const _plasmaLinkEnabled = true;

  final stackKey = GlobalKey();
  final cardKey = GlobalKey();
  final passCountButtonKey = GlobalKey();
  final Map<int, GlobalKey> switchKeys = {
    0: GlobalKey(),
    1: GlobalKey(),
    2: GlobalKey(),
    3: GlobalKey(),
    4: GlobalKey(),
    5: GlobalKey(),
  };

  // Keys für Single-Modus Switches (SRC, R1, R2)
  final Map<String, GlobalKey> singleSwitchKeys = {
    'SRC': GlobalKey(),
    'R1': GlobalKey(),
    'R2': GlobalKey(),
  };

  Rect? cardRect;
  Rect? switchRect;
  bool linkVisible = false;

  late final AnimationController fx;
  late final AnimationController pulse;
  int? pulseStage; // Für normale Stages (0-5)
  Color pulseColor = const Color(0xFFB16CFF);
  String? pulseSingleBucket; // Für Single-Modus ('SRC', 'R1', 'R2')

  // ✅ Swipe-Commit Throttling (verhindert doppelte Swipes)
  DateTime? _lastSwipeCommitAt;
  bool _localShowTranslation = false;

  // ✅ Provider Subscription für Stage-Änderungen
  ProviderSubscription<LearnModeState>? _stagesSub;

  // Koordinaten-Helper: Global → Stack-lokal
  Offset _centerInStack(GlobalKey key) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final box = key.currentContext!.findRenderObject() as RenderBox;

    final global = box.localToGlobal(box.size.center(Offset.zero));
    return stackBox.globalToLocal(global);
  }

  /// Karte: Bottom-Edge exakt (und optional 2–6 px unter die Karte)
  Offset _cardBottomEdgeInStack(GlobalKey key, {double yOutset = 3}) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final box = key.currentContext!.findRenderObject() as RenderBox;

    // exakt bottom-center, leicht nach außen (unter die Karte)
    final local = Offset(box.size.width / 2, box.size.height + yOutset);
    final global = box.localToGlobal(local);
    return stackBox.globalToLocal(global);
  }

  /// Switch: Top-Edge der großen Pill (nicht das schwarze Inlay)
  Offset _switchTopEdgeInStack(GlobalKey key, {double yOutset = 2}) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final box = key.currentContext!.findRenderObject() as RenderBox;

    // top-center, leicht nach außen (über den Switch hinaus)
    final local = Offset(box.size.width / 2, -yOutset);
    final global = box.localToGlobal(local);
    return stackBox.globalToLocal(global);
  }

  Rect _rectInStack(GlobalKey key) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final box = key.currentContext!.findRenderObject() as RenderBox;

    final globalTopLeft = box.localToGlobal(Offset.zero);
    final localTopLeft = stackBox.globalToLocal(globalTopLeft);

    return localTopLeft & box.size;
  }

  /// Sichere Variante: gibt null zurück, wenn Element inactive oder nicht im Baum.
  Rect? _tryRectInStack(GlobalKey key) {
    try {
      final stackContext = stackKey.currentContext;
      final keyContext = key.currentContext;
      if (stackContext == null || keyContext == null) return null;
      final stackObj = stackContext.findRenderObject();
      final keyObj = keyContext.findRenderObject();
      if (stackObj is! RenderBox || keyObj is! RenderBox) return null;
      final box = keyObj as RenderBox;
      final stackBox = stackObj as RenderBox;
      final globalTopLeft = box.localToGlobal(Offset.zero);
      final localTopLeft = stackBox.globalToLocal(globalTopLeft);
      return localTopLeft & box.size;
    } catch (_) {
      return null;
    }
  }

  void _updateLink(int? targetStage) {
    if (!_plasmaLinkEnabled) return;
    final mode = ref.read(levelSelectionProvider);
    GlobalKey? targetKey;
    if (mode == LevelSelectionMode.single && targetStage == -1) {
      targetKey = singleSwitchKeys['SRC'];
    } else if (targetStage != null && targetStage >= 0 && targetStage <= 5) {
      targetKey = switchKeys[targetStage];
    }
    if (targetKey == null) return;
    if (cardKey.currentContext == null || targetKey!.currentContext == null)
      return;
    setState(() {
      cardRect = _rectInStack(cardKey);
      switchRect = _rectInStack(targetKey!);
      linkVisible = true;
    });
  }

  void _hideLink() => setState(() => linkVisible = false);

  void _hideLinkIfVisible() {
    if (!linkVisible) return;
    _hideLink();
  }

  int? _localTargetStageForCard(LocalLearnModeUiState uiState) {
    final stage = uiState.currentStage;
    if (stage == null) return null;
    return stage.index.clamp(0, 5);
  }

  List<int> _normalizeLocalStageCounts(List<int> counts) {
    return List<int>.generate(6, (index) {
      return index < counts.length ? counts[index] : 0;
    }, growable: false);
  }

  Color _localPulseColorForFeedback(LocalReviewVisualFeedback feedback) {
    return switch (feedback.outcomeType) {
      LocalReviewOutcomeType.promoted => const Color(0xFF36F58A),
      LocalReviewOutcomeType.demoted ||
      LocalReviewOutcomeType.unchangedWrong => const Color(0xFFFF4B6E),
      LocalReviewOutcomeType.repeatedSameStage => switch (feedback.repeatIndex
          .clamp(1, 3)) {
        1 => const Color(0xFF5DDCFF),
        2 => const Color(0xFFB36BFF),
        _ => const Color(0xFFFFB84A),
      },
    };
  }

  void _updateLocalLink(int? targetStage) {
    if (!_plasmaLinkEnabled || !widget.useLocalOfflineFlow) return;
    if (targetStage == null) {
      _hideLinkIfVisible();
      return;
    }

    final targetKey = switchKeys[targetStage];
    if (targetKey == null) return;

    final nextCardRect = _tryRectInStack(cardKey);
    final nextSwitchRect = _tryRectInStack(targetKey);
    if (nextCardRect == null || nextSwitchRect == null) return;

    if (linkVisible &&
        cardRect == nextCardRect &&
        switchRect == nextSwitchRect) {
      return;
    }

    setState(() {
      cardRect = nextCardRect;
      switchRect = nextSwitchRect;
      linkVisible = true;
    });
  }

  void triggerPulse(int stage, {Color? color}) {
    debugPrint(
      '🎬 triggerPulse aufgerufen: stage=$stage, switchKeys vorhanden: ${switchKeys.containsKey(stage)}',
    );
    setState(() {
      pulseStage = stage;
      pulseColor = color ?? const Color(0xFFB16CFF);
      pulseSingleBucket = null; // Normal-Modus
    });
    pulse.forward(from: 0);
    debugPrint('🎬 Pulse-Animation gestartet: pulseStage=$pulseStage');
  }

  void triggerPulseSingle(String bucket) {
    setState(() {
      pulseSingleBucket = bucket;
      pulseStage = null; // Single-Modus
    });
    pulse.forward(from: 0);
  }

  void _handlePulseStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() {
      pulseStage = null;
      pulseSingleBucket = null;
      pulseColor = const Color(0xFFB16CFF);
    });
  }

  void _handleDragUpdate(double dx) {
    final threshold = MediaQuery.of(context).size.width * 0.35;
    if (dx.abs() < threshold) {
      _hideLink();
      return;
    }

    final mode = ref.read(levelSelectionProvider);
    if (mode == LevelSelectionMode.single) {
      _updateLink(-1);
      return;
    }

    // PlasmaLink zeigt immer die QUELLE der Karte (wo sie herkommt: Fach 0, A1, …),
    // nicht das Ziel – damit man sieht, aus welchem Fach die Karte stammt
    final targetStage = _targetStageForIdleCard();
    if (targetStage != null && targetStage >= 0) {
      _updateLink(targetStage);
    }
  }

  void _handleDragEnd() {
    _hideLink();
    // Pulse wird beim Swipe-Commit getriggert (in onSwipe)
  }

  void _handleDragReturn() {
    // Karte kommt zurück - Link schnell wieder anzeigen
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        _showLinkForCurrentCard();
      }
    });
  }

  /// Wird VOR der Karten-Animation aufgerufen (für Sparkle bei Stage-Up)
  void _handleSwipeWillStart(BuildContext context, bool correct) {
    if (!correct) return;
    final srs = ref.read(srsModeControllerProvider).mode;
    if (srs != SrsSystem.adaptive) return; // Nur A-SRS hat passCount
    final current = ref.read(currentWordProvider);
    if (current == null) return;
    final passCount = current.passCount;
    final currentStage = current.srsStage ?? 0;
    // S1-S3: 2× richtig, S4-S5: 3× richtig
    final requiredPass = switch (currentStage) {
      0 => 1,
      1 => 2,
      2 => 2,
      3 => 2,
      4 => 3,
      5 => 3,
      _ => 1,
    };
    // S5: pass_count auf 0..2 clamps (DB kann veraltete Werte haben), sonst korrekt
    final effectivePassCount = (currentStage == 5)
        ? passCount.clamp(0, 2)
        : passCount;
    final futurePassCount = effectivePassCount + 1;
    // Zauberstaub nur bei S1→S2, S2→S3, … S5→mastered (grün→richtig), NICHT bei S0→S1 oder weiß/blau
    if (currentStage > 0 && futurePassCount >= requiredPass) {
      ArrowFlyService.showSparkleAtKey(
        context: context,
        key: passCountButtonKey,
      );
    }
  }

  void _handleSwipeCommit(bool correct) {
    final state = ref.read(learnModeControllerProvider);
    debugPrint(
      '🔥 ANSWER CHECK | finalPassActive=${state.finalPassActive} | '
      'queue=${state.wordQueue.length} | index=${state.index}',
    );
    if (state.shuffledWordIds.isEmpty ||
        state.index >= state.shuffledWordIds.length) {
      debugPrint(
        '⛔ _handleSwipeCommit abgebrochen: kein aktives Deck vorhanden',
      );
      return;
    }
    if (state.isSubmitting) return;
    ref.read(learnModeControllerProvider.notifier).setSubmitting(true);

    // ✅ Swipe-Commit Throttling (verhindert doppelte Swipes innerhalb von 250ms)
    final now = DateTime.now();
    if (_lastSwipeCommitAt != null &&
        now.difference(_lastSwipeCommitAt!) <
            const Duration(milliseconds: 250)) {
      debugPrint('🧯 SwipeCommit THROTTLED (duplicate within 250ms)');
      ref.read(learnModeControllerProvider.notifier).setSubmitting(false);
      return;
    }
    _lastSwipeCommitAt = now;

    final mode = ref.read(levelSelectionProvider);
    final srs = ref.read(srsModeControllerProvider).mode;

    // ✅ Routing nach SRS-System (explizit für Klarheit)
    debugPrint(
      '🧭 UI _handleSwipeCommit: srs=$srs mode=$mode correct=$correct',
    );

    // Alle SRS-Systeme verwenden aktuell denselben Controller,
    // aber die Routing-Logik ist explizit nach SRS-System getrennt
    switch (srs) {
      case SrsSystem.time:
      case SrsSystem.adaptive:
      case SrsSystem.hybrid:
        // Alle verwenden den gleichen Controller, aber die Logik ist explizit geroutet
        if (correct) {
          _controller!.onSwipeRight();
        } else {
          _controller!.onSwipeLeft();
        }
        break;
    }

    if (mode == LevelSelectionMode.single) {
      // Im Single-Modus: Bestimme den Ziel-Bucket basierend auf correct
      // Die Counts werden im Controller aktualisiert, wir müssen darauf warten
      final countsBefore = ref.read(singleSessionCountsProvider);

      // Verwende ref.listen, um auf Counts-Änderungen zu reagieren
      // Aber nur einmal, deshalb verwenden wir einen Timer
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;

        final countsAfter = ref.read(singleSessionCountsProvider);

        // Bestimme, welcher Bucket größer geworden ist
        String? targetBucket;
        if (correct) {
          // Correct: Wort geht zu R1 oder R2
          if (countsAfter.sr1 > countsBefore.sr1) {
            targetBucket = 'R1';
          } else if (countsAfter.sr2 > countsBefore.sr2) {
            targetBucket = 'R2';
          } else {
            // Fallback: Wenn sich nichts geändert hat, zeige auf R1
            targetBucket = 'R1';
          }
        } else {
          // Incorrect: Wort bleibt in SRC oder geht zurück zu SRC
          targetBucket = 'SRC';
        }

        // Pulse-Animation auf den Ziel-Bucket
        if (targetBucket != null && mounted) {
          triggerPulseSingle(targetBucket);
        }
      });
    } else {
      // Normal-Modus: Pulse bei correct (Ziel-Stage) und bei wrong (bleibt in derselben Stage)
      final current = ref.read(currentWordProvider);
      if (current != null) {
        final targetStage = _getTargetStageForBounce(
          current.srsStage,
          current.passCount,
          correct,
        );
        if (targetStage != null) {
          triggerPulse(targetStage);
        }
      }
    }

    // PlasmaLink für neue Karte: Wird vom currentWordProvider-Listener aktualisiert.
    // Fallback nach 400ms falls Listener nicht feuert.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLinkForCurrentCard();
        });
      }
    });
  }

  /// Berechnet die nächste Stage für Link (z.B. beim Drag).
  /// Exakt abgestimmt auf fn_user_review_time_mode, fn_user_review_hybrid_mode, fn_user_review_mode_text.
  int? _getNextStageForLink(int currentStage, int currentStreak, bool correct) {
    final srs = ref.read(srsModeControllerProvider).mode;

    // T-SRS und Hybrid: identische Server-Logik (fn_user_review_time_mode / fn_user_review_hybrid_mode)
    if (srs == SrsSystem.time || srs == SrsSystem.hybrid) {
      if (correct) {
        return currentStage < 5 ? currentStage + 1 : 5;
      }
      // Wrong: S0→S0, T1/H1→T1/H1 (bleibt!), T2/H2→T1/H1, ...
      if (currentStage <= 0) return 0;
      if (currentStage == 1) return 1; // T1/H1 wrong bleibt in T1/H1
      return currentStage - 1;
    }

    // A-SRS: fn_user_review_mode_text - Streak-basiert bei correct, S1 bleibt bei wrong
    if (!correct) {
      // Wrong: S1→S1, S2→S1, S3→S2, ...
      return (currentStage - 1).clamp(1, 5);
    }
    final requiredStreak = switch (currentStage) {
      0 => 1,
      1 => 2,
      2 => 2,
      3 => 2,
      4 => 3,
      5 => 3,
      _ => 1,
    };
    if (currentStreak + 1 < requiredStreak) return currentStage; // bleibt
    return currentStage < 5 ? currentStage + 1 : 5;
  }

  /// Berechnet die tatsächliche Ziel-Stage für Bounce nach einem Swipe.
  /// Exakt abgestimmt auf Supabase A-SRS: S1=2, S2=3, S3=3, S4=4, S5=5 (bis is_mastered).
  /// Bounce bei: Stage up ODER Wiederholung in derselben Stage (pass_count+1 erreicht).
  int? _getTargetStageForBounce(int currentStage, int passCount, bool correct) {
    final srs = ref.read(srsModeControllerProvider).mode;

    // T-SRS und Hybrid: identische Logik
    if (srs == SrsSystem.time || srs == SrsSystem.hybrid) {
      int targetStage;
      if (correct) {
        targetStage = currentStage < 5 ? currentStage + 1 : 5;
      } else {
        if (currentStage <= 0)
          targetStage = 0;
        else if (currentStage == 1)
          targetStage = 1; // T1/H1 wrong bleibt
        else
          targetStage = currentStage - 1;
      }
      if (targetStage == 0) return null; // S0 wird nie gebounct
      return targetStage;
    }

    // A-SRS: Bei Falsch S1 bleibt S1, S2→S1, S3→S2, S4→S3, S5 bleibt S5
    if (!correct) {
      return (currentStage - 1).clamp(1, 5);
    }
    final effectivePassCount = (currentStage == 5)
        ? passCount.clamp(0, 2)
        : passCount;
    final futurePassCount = effectivePassCount + 1;
    // S1-S3: 2× richtig, S4-S5: 3× richtig
    final requiredPass = switch (currentStage) {
      0 => 1,
      1 => 2,
      2 => 2,
      3 => 2,
      4 => 3,
      5 => 3,
      _ => 1,
    };
    if (futurePassCount >= requiredPass) {
      final targetStage = currentStage < 5 ? currentStage + 1 : 5;
      return targetStage;
    }
    return currentStage; // bleibt in currentStage (Wiederholung zählt)
  }

  /// Ziel-Stage für Idle-Karte (noch nicht geswiped)
  /// Zeigt auf den AUSGANG: die Stage, in der die Karte aktuell ist.
  /// WICHTIG: PlasmaLink darf nie auf einer leeren Stage stehen.
  /// A-SRS Phase 1: S5 nie berühren – erst in Final Round (Phase 2).
  int? _targetStageForIdleCard() {
    final state = ref.read(learnModeControllerProvider);
    if (state.categoryMastered)
      return null; // Kein Link bei Kategorie-Abschluss
    final mode = ref.read(levelSelectionProvider);
    if (mode == LevelSelectionMode.single) {
      return -1; // Single-Modus: SRC-Switch
    }
    final stages = state.stages;
    final srs = ref.read(srsModeControllerProvider).mode;
    final isA_SrsPhase1 = srs == SrsSystem.adaptive && !state.finalPassActive;

    // Hilfsfunktion: höchste Stage mit Wörtern (maxStage: A-SRS Phase 1 nur S0-S4)
    int? _highestNonEmptyStage({int maxStage = 5}) {
      for (int i = maxStage; i >= 0; i--) {
        if (stages.length > i && stages[i] > 0) return i;
      }
      return null;
    }

    // A-SRS Final Round aktiv: S5 erlaubt
    if (state.finalPassActive) {
      return stages.length > 5 && stages[5] > 0
          ? 5
          : _highestNonEmptyStage() ?? 5;
    }
    // A-SRS Phase 1: S5 niemals – auch nicht bei showFinalStartButton
    final maxStage = isA_SrsPhase1 ? 4 : 5;
    if (state.showFinalStartButton) {
      return _highestNonEmptyStage(maxStage: maxStage) ??
          (isA_SrsPhase1 ? 4 : 5);
    }
    final current = ref.read(currentWordProvider);
    if (current == null) return _highestNonEmptyStage(maxStage: maxStage) ?? 0;

    int target = (current.srsStage ?? 0).clamp(0, maxStage);
    // S0-Karte: immer Fach 0 zeigen (Pool, aus dem die Karte kommt)
    if (target == 0) return 0;
    // Nie auf leere Stage zeigen
    if (stages.length <= target || stages[target] == 0) {
      return _highestNonEmptyStage(maxStage: maxStage) ?? target;
    }
    return target;
  }

  void _showLinkForCurrentCard() {
    if (!_plasmaLinkEnabled) return;
    _updateLink(_targetStageForIdleCard());
  }

  @override
  void dispose() {
    // ✅ Provider Subscription schließen
    _stagesSub?.close();
    if (!widget.useLocalOfflineFlow) {
      // Learn-Screen ist nicht mehr aktiv (wichtig, damit CategoryDetail sofort mode-aktuelle Server-Counts zeigt).
      // WICHTIG: Nach dem Build setzen, nicht während dispose (verursacht Provider-Modifikation-Fehler)
      Future.microtask(() {
        _controller?.setInLearnScreen(false);
      });
    }
    fx.dispose();
    pulse.removeStatusListener(_handlePulseStatus);
    pulse.dispose();
    super.dispose();
  }

  // ⬇️ NEU: State für Custom Wheel
  late List<String> _wheelLabels;
  late int _wheelIndex;

  // ⬇️ NEU: Track ob Wheel gedreht wurde (für Back-Button-Logik)
  bool _wheelChanged = false;

  @override
  void initState() {
    super.initState();

    if (!widget.useLocalOfflineFlow) {
      // ✅ Listener für Stage-Änderungen (statt Logs in build())
      _stagesSub = ref.listenManual<LearnModeState>(learnModeControllerProvider, (
        prev,
        next,
      ) {
        final prevStages = prev?.stages;
        final nextStages = next.stages;
        if (prevStages != nextStages) {
          debugPrint("📊 stages changed: $prevStages -> $nextStages");
        }
        // PlasmaLink sofort aktualisieren, wenn Final Round startet (Layout hat sich geändert)
        if (prev?.finalPassActive != next.finalPassActive &&
            next.finalPassActive &&
            next.shuffledWordIds.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _showLinkForCurrentCard();
              });
            }
          });
        }
      });
    }

    // Animation Controller initialisieren - sehr langsame Animation
    fx = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 10000,
      ), // 10 Sekunden Animation (3x schneller)
    )..repeat();

    pulse = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2000,
      ), // Doppelt so langer Bounce-Effekt
    );
    pulse.addStatusListener(_handlePulseStatus);

    // ⬇️ NEU: Wheel-Labels initialisieren (ganz am Anfang)
    // Wenn übergeben, nutze die QuickSets-Wheel, sonst die bisherigen Kategorien
    if (widget.customWheelLabels != null &&
        widget.customWheelLabels!.isNotEmpty) {
      _wheelLabels = widget.customWheelLabels!;
      _wheelIndex = (widget.customWheelInitialIndex ?? 0).clamp(
        0,
        _wheelLabels.length - 1,
      );
    } else {
      // Behalte die bestehende Logik für die normale Kategorie-Wheel
      // Die Labels werden später aus categoriesProvider geholt
      _wheelLabels = [];
      _wheelIndex = 0;
    }

    if (!widget.useLocalOfflineFlow) {
      _controller = ref.read(learnModeControllerProvider.notifier);
      // Markiere Learn-Screen als aktiv, damit Hub/CategoryDetail nur dann LearnState-Live-Counts nutzt,
      // wenn dieser Screen wirklich offen ist.
      // WICHTIG: Nach dem Build setzen, nicht während initState (verursacht Provider-Modifikation-Fehler)
      Future.microtask(() {
        if (mounted) {
          _controller?.setInLearnScreen(true);
        }
      });

      // Init nach 1. Frame (damit Provider hängt)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller?.init(
          categoryId: widget.categoryId,
          title: widget.title,
          initialQuickSetsIndex: widget.categoryId == 'quicksets'
              ? _wheelIndex
              : null,
        );

        // Link für erste Karte schnell aktivieren
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLinkForCurrentCard();
            });
          }
        });
      });
    }
  }

  // ⬇️ NEU: Helper-Funktion für QuickSets-Filter
  WordListFilter _quicksetsFilterFor(int idx) {
    // nur aktiv, wenn wir im QuickSets-Modus sind
    if (widget.categoryId != 'quicksets') {
      return const WordListFilter(WordFilterKind.query, '');
    }
    switch (idx) {
      case 0:
        return const WordListFilter(WordFilterKind.query, '');
      case 1:
        return const WordListFilter(WordFilterKind.about, 'my-words');
      case 2:
        return const WordListFilter(WordFilterKind.about, 'favorites');
      case 3:
        return const WordListFilter(WordFilterKind.about, 'known-words');
      case 4:
        return const WordListFilter(WordFilterKind.about, 'my-mix');
      default:
        return const WordListFilter(WordFilterKind.query, '');
    }
  }

  // ⬇️ NEU: Back-Button-Logik basierend auf Herkunft und Wheel-Status
  void _handleBackNavigation(BuildContext context) {
    final origin = widget.navigationOrigin;

    // Wenn keine Herkunft definiert → Standard-Navigation (pop)
    if (origin == null) {
      final didReset = ref.read(learnModeControllerProvider.notifier).didReset;
      Navigator.of(context).pop(didReset);
      return;
    }

    // Wenn von Category kommt → zur aktuell ausgewählten Kategorie navigieren
    if (origin.isFromCategory) {
      // QuickSets-Sonderbehandlung
      if (origin.isQuickSets) {
        final originalIndex = origin.initialIndex ?? _wheelIndex;
        final currentIndex = _wheelIndex;

        // Wenn sich der Index geändert hat → zur neuen QuickSets Detail Screen navigieren
        if (currentIndex != originalIndex) {
          // Pop LearnMode und die alte QuickSets Detail Screen
          final didReset = ref
              .read(learnModeControllerProvider.notifier)
              .didReset;
          Navigator.of(context).pop(didReset); // Pop LearnMode
          Navigator.of(context).pop(); // Pop alte QuickSets Detail Screen
          // Push neue QuickSets Detail Screen mit neuem Index
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuickSetsDetailScreen(initialIndex: currentIndex),
            ),
          );
          return;
        }

        // Fallback: Wenn keine Änderung → einfach zurück (pop)
        final didReset = ref
            .read(learnModeControllerProvider.notifier)
            .didReset;
        Navigator.of(context).pop(didReset);
        return;
      }

      // Normale Category-Navigation (nicht QuickSets)
      // Hinweis: s ist hier nicht verfügbar (außerhalb von build), daher read verwenden
      final state = ref.read(learnModeControllerProvider);
      final categories = state.categories;
      final selectedIndex = state.selectedCategoryIndex;

      // Wenn Kategorien vorhanden sind und Index gültig ist
      if (categories.isNotEmpty &&
          selectedIndex >= 0 &&
          selectedIndex < categories.length) {
        final currentCat = categories[selectedIndex];
        final originalCatId = origin.categoryId;

        // Wenn die aktuelle Kategorie anders ist als die ursprüngliche → zur neuen Kategorie navigieren
        if (originalCatId != null && currentCat.id != originalCatId) {
          // Pop LearnMode und die alte Category Detail Screen
          final didReset = ref
              .read(learnModeControllerProvider.notifier)
              .didReset;
          Navigator.of(context).pop(didReset); // Pop LearnMode
          Navigator.of(context).pop(); // Pop alte Category Detail Screen
          // Push neue Category Detail Screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryDetailScreen(
                title: currentCat.name,
                categoryId: currentCat.id,
                categorySlug: currentCat.slug,
                listFilter: WordListFilter(
                  WordFilterKind.category,
                  currentCat.id,
                ),
              ),
            ),
          );
          return;
        }
      }

      // Fallback: Wenn keine Änderung oder gleiche Kategorie → einfach zurück (pop)
      final didReset = ref.read(learnModeControllerProvider.notifier).didReset;
      Navigator.of(context).pop(didReset);
      return;
    }

    // Wenn von Home kommt (nur für QuickSets relevant)
    if (origin.isFromHome && widget.categoryId == 'quicksets') {
      // Wenn Wheel auf "My words" (Index 1) UND nicht gedreht → zurück zu Home
      if (_wheelIndex == 1 && !_wheelChanged) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      // Wenn Wheel gedreht wurde oder nicht auf "My words" → zurück zu QuickSets-Detail
      // Pop LearnMode, dann navigiere zu QuickSetsDetailScreen mit aktuellem Index
      final didReset = ref.read(learnModeControllerProvider.notifier).didReset;
      Navigator.of(context).pop(didReset); // Pop LearnMode
      // Nach pop sollten wir auf Home sein, dann navigiere zu QuickSetsDetailScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuickSetsDetailScreen(initialIndex: _wheelIndex),
        ),
      );
      return;
    }

    // Fallback: Standard pop
    final didReset = ref.read(learnModeControllerProvider.notifier).didReset;
    Navigator.of(context).pop(didReset);
  }

  // === Build ===

  @override
  Widget build(BuildContext context) {
    if (widget.useLocalOfflineFlow) {
      return _buildLocalOfflineFlow(context);
    }

    final s = ref.watch(learnModeControllerProvider);
    final mode = ref.watch(levelSelectionProvider);
    final allowed = ref.watch(allowedStagesProvider);
    final mask = List<bool>.generate(6, (i) => allowed.contains(i));

    // Kategorie mastered: PlasmaLink ausblenden, Feuerwerk starten, nach 5s Restart-Button freischalten
    ref.listen<bool>(
      learnModeControllerProvider.select((s) => s.categoryMastered),
      (prev, next) {
        if (next && prev != true && mounted) {
          _hideLink(); // PlasmaLink verschwindet, wenn Finale erreicht
          FireworksService.show(context, duration: const Duration(seconds: 10));
          Future.delayed(const Duration(seconds: 10), () {
            if (mounted) {
              ref
                  .read(learnModeControllerProvider.notifier)
                  .setCategoryMasteredRestartReady();
            }
          });
        }
      },
    );

    // Link aktualisieren, wenn sich die Karte ändert (nur wenn nicht gerade gedragt wird)
    // ABER: Warte bis die Karten-Animation fertig ist
    ref.listen<WordUserView?>(currentWordProvider, (previous, next) {
      if (previous?.id != next?.id && !linkVisible) {
        // Karte hat sich geändert – Link schnell anzeigen
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLinkForCurrentCard();
            });
          }
        });
      }
    });

    Widget switchesRow;
    if (s.categoryMastered) {
      // Kategorie absolviert: Switch verschwindet, Mastered-Zahl blinkend in der Mitte
      switchesRow = _MasteredCountBlink(
        count: s.masteredCount,
        restartReady: s.categoryMasteredRestartReady,
      );
    } else if (mode == LevelSelectionMode.single) {
      final st = ref.watch(singleStageProvider); // z.B. 2
      final counts = ref.watch(singleSessionCountsProvider); // (src, sr1, sr2)

      // Modus → Stroke & Prefix ableiten
      final srsMode = ref.watch(srsModeControllerProvider);
      final kind = switch (srsMode.mode) {
        SrsSystem.time => SrsKind.tSrs,
        SrsSystem.adaptive => SrsKind.aSrs,
        SrsSystem.hybrid => SrsKind.neutral,
      };
      final t = Theme.of(context);
      // Stroke: T/A ausblenden, Hybrid beibehalten
      final stroke = () {
        switch (kind) {
          case SrsKind.tSrs:
          case SrsKind.aSrs:
            return Colors.transparent;
          case SrsKind.neutral:
            return innerCapsuleStrokeColor(t, kind);
        }
      }();
      // Inner-Fill je Modus (A-SRS: 542C78 Violett, Hybrid: 244B8B Blau)
      final innerFill = () {
        switch (kind) {
          case SrsKind.tSrs:
            return const Color(0xFF1A1A1A);
          case SrsKind.aSrs:
            return const Color(0xFF542C78);
          case SrsKind.neutral:
            return const Color(0xFF244B8B);
        }
      }();
      final prefix = switch (kind) {
        SrsKind.tSrs => 'T',
        SrsKind.aSrs => 'A',
        SrsKind.neutral => 'H', // Hybrid
      };
      final stageLabelText = '$prefix$st';
      final srPrefix = prefix; // 'H' => Hybrid zeigt 'HR1/HR2'

      switchesRow = SingleModeSwitchRow(
        stageLabel: stageLabelText,
        srcCount: counts.src,
        sr1Count: counts.sr1,
        sr2Count: counts.sr2,
        srPrefix: srPrefix, // ← NEU
        innerStrokeColor: stroke, // ← NEU
        innerFillColor: innerFill, // ← NEU
        switchKeys: singleSwitchKeys, // ← NEU: Keys für Plasma-Link
      );
    } else {
      // Non-Single: S0–S5 / S1–S5
      // Modus → Stroke & Prefix ableiten
      final srsMode = ref.watch(srsModeControllerProvider);
      final kind = switch (srsMode.mode) {
        SrsSystem.time => SrsKind.tSrs,
        SrsSystem.adaptive => SrsKind.aSrs,
        SrsSystem.hybrid => SrsKind.neutral,
      };
      final t = Theme.of(context);
      // Stroke: T/A ausblenden, Hybrid beibehalten
      final stroke = () {
        switch (kind) {
          case SrsKind.tSrs:
          case SrsKind.aSrs:
            return Colors.transparent;
          case SrsKind.neutral:
            return innerCapsuleStrokeColor(t, kind);
        }
      }();
      // Inner-Fill je Modus (A-SRS: 542C78 Violett, Hybrid: 244B8B Blau)
      final innerFill = () {
        switch (kind) {
          case SrsKind.tSrs:
            return const Color(0xFF1A1A1A);
          case SrsKind.aSrs:
            return const Color(0xFF542C78);
          case SrsKind.neutral:
            return const Color(0xFF244B8B);
        }
      }();
      final prefix = switch (kind) {
        SrsKind.tSrs => 'T',
        SrsKind.aSrs => 'A',
        SrsKind.neutral => 'H',
      };

      // Switches sollen die echten Category-Stage-Counts anzeigen (z.B. S0=250),
      // nicht nur das aktuell geladene A‑SRS-Deck (z.B. 20).
      // Live-Updates passieren über LearnModeController (stages wird nach RPC/ServerProgress aktualisiert).
      final List<int> stageCounts = s.stages;

      switchesRow = StageSwitchRow(
        controller: _switchCtrl,
        counts: stageCounts,
        goalPerStage: 100,
        gap: 12, // kSwitchGap
        showLearnedCounterInStage5:
            true, // show same learned counter as in Category Detail
        learnedCounterCategoryId: widget.categoryId,
        sizes: const StageSwitchSizes(
          width: 42,
          height: 75,
          knobTop: 2,
          knobBottom: 18,
        ),
        colors: StageSwitchColors(
          newOuter: const Color(0xFFA05260),
          stageOuter: const Color(0xFFE4B866),
          inner: innerFill,
          disabledOuter: Colors.white,
          innerStroke: stroke,
        ),
        labels: StageSwitchLabels(
          newLabel: 'New',
          newNote: '0',
          stagePrefix: prefix,
        ),
        visibleMask:
            mask, // ⚠️ KEINE visibleMask hier für Single – diese Branch rendert nur für non-Single
        s0Locked: ref
            .watch(s0LockedProvider(widget.categoryId))
            .maybeWhen(data: (v) => v, orElse: () => false),
        onTapS0:
            null, // Icon ist im Category Detail Screen, hier nicht benötigt
        switchKeys: switchKeys, // ← NEU: Keys für Plasma-Link
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          key: stackKey,
          children: [
            // Normaler Screen
            Column(
              children: [
                HeaderBar(
                  // ⬇️ NEU: Custom Wheel Labels übergeben, wenn vorhanden
                  customWheelLabels:
                      widget.customWheelLabels != null &&
                          widget.customWheelLabels!.isNotEmpty
                      ? _wheelLabels
                      : null,
                  customWheelInitialIndex:
                      widget.customWheelLabels != null &&
                          widget.customWheelLabels!.isNotEmpty
                      ? _wheelIndex
                      : null,
                  customOnWheelChanged:
                      widget.customWheelLabels != null &&
                          widget.customWheelLabels!.isNotEmpty
                      ? (idx, label) {
                          setState(() {
                            _wheelIndex = idx;
                            _wheelChanged =
                                true; // ⬇️ NEU: Markiere dass Wheel gedreht wurde
                          });
                          // ⬇️ NEU: Bei QuickSets Wörter neu laden mit neuem Filter
                          if (widget.categoryId == 'quicksets') {
                            _controller!.loadWordsForQuickSets(idx);
                          }
                        }
                      : null,
                  // ⬇️ NEU: Custom Back-Button-Handler mit Navigation-Logik
                  onBack: () => _handleBackNavigation(context),
                ),
                CardArea(
                  cardKey: cardKey, // ← NEU
                  onDragUpdate: _handleDragUpdate, // ← NEU
                  onDragEnd: _handleDragEnd, // ← NEU
                  onDragReturn:
                      _handleDragReturn, // ← NEU: Link wieder anzeigen wenn Karte zurückkommt
                  onSwipeCommit: _handleSwipeCommit, // ← NEU: Pulse-Animation
                  onSettingsTap: () => showCardGlowSettingsPopup(context),
                  passCountButtonKey: passCountButtonKey,
                  onSwipeWillStart: _handleSwipeWillStart,
                ),
                switchesRow,
                const SizedBox(
                  height: WordsUIConstants.sectionSpacing,
                ), // Mehr Luft zwischen Switches und Buttons
                const BottomControls(),
              ],
            ),

            // FX Overlay: Plasma-Link (verschwindet bei Kategorie-Abschluss)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: fx,
                builder: (_, __) {
                  final hideForMastered = ref.watch(
                    learnModeControllerProvider.select(
                      (s) => s.categoryMastered,
                    ),
                  );
                  return CustomPaint(
                    painter: PlasmaBandPainter(
                      cardRect: cardRect,
                      switchRect: switchRect,
                      phase: fx.value,
                      visible:
                          _plasmaLinkEnabled && linkVisible && !hideForMastered,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // FX Overlay: Switch-Pulse (Corona beim Commit)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: pulse,
                builder: (_, __) {
                  if (!mounted) return const SizedBox.shrink();
                  if (ref.read(learnModeControllerProvider).categoryMastered) {
                    return const SizedBox.shrink();
                  }
                  GlobalKey? targetKey;
                  if (pulseSingleBucket != null) {
                    targetKey = singleSwitchKeys[pulseSingleBucket];
                  } else if (pulseStage != null) {
                    targetKey = switchKeys[pulseStage!];
                  }
                  if (targetKey == null) return const SizedBox.shrink();
                  final rect = _tryRectInStack(targetKey);
                  if (rect == null) return const SizedBox.shrink();
                  return CustomPaint(
                    painter: SwitchPulsePainter(
                      rect: rect,
                      t: Curves.easeOutCubic.transform(pulse.value),
                      color: pulseColor,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalOfflineFlow(BuildContext context) {
    final localCategoryId = widget.localCategoryId;
    final localLearningMode = widget.localLearningMode ?? LearningMode.adaptive;
    final rawViewModelState = ref.watch(localLearningViewModelProvider);
    final viewModelState =
        rawViewModelState.categoryId == localCategoryId &&
            rawViewModelState.mode == localLearningMode
        ? rawViewModelState
        : const LocalLearningViewModelState(
            isLoading: false,
            hasSession: false,
            currentPosition: 0,
            totalItems: 0,
            answeredCount: 0,
            remainingCount: 0,
            canSubmitAnswer: false,
            canCompleteSession: false,
            lastAction: LocalLearningControllerAction.none,
          );
    final uiState = const LocalLearnModeUiAdapter().map(viewModelState);
    final cardState = const LearnModeCardPresenter().map(uiState);
    final localTargetStage = cardState.hasCard
        ? _localTargetStageForCard(uiState)
        : null;
    final localStageCounts = _normalizeLocalStageCounts(
      viewModelState.stageCounts,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.useLocalOfflineFlow) return;
      if (cardState.hasCard) {
        _updateLocalLink(localTargetStage);
      } else {
        _hideLinkIfVisible();
      }
    });

    Future<void> startOrResume() async {
      if (localCategoryId == null || localCategoryId.isEmpty) return;
      await ref
          .read(localLearningControllerProvider.notifier)
          .startOrResume(
            categoryId: localCategoryId,
            mode: localLearningMode,
            trainingArea: TrainingArea.all,
            now: DateTime.now(),
          );
    }

    Future<void> submitCorrect() async {
      setState(() => _localShowTranslation = false);
      await ref
          .read(localLearningControllerProvider.notifier)
          .submitCorrect(now: DateTime.now());
      final feedback = ref
          .read(localLearningViewModelProvider)
          .lastReviewFeedback;
      final pulseTargetStage = feedback?.targetStage.index;
      if (feedback != null && pulseTargetStage != null && mounted) {
        triggerPulse(
          pulseTargetStage,
          color: _localPulseColorForFeedback(feedback),
        );
      }
    }

    Future<void> submitWrong() async {
      setState(() => _localShowTranslation = false);
      await ref
          .read(localLearningControllerProvider.notifier)
          .submitWrong(now: DateTime.now());
      final feedback = ref
          .read(localLearningViewModelProvider)
          .lastReviewFeedback;
      final pulseTargetStage = feedback?.targetStage.index;
      if (feedback != null && pulseTargetStage != null && mounted) {
        triggerPulse(
          pulseTargetStage,
          color: _localPulseColorForFeedback(feedback),
        );
      }
    }

    Future<void> openStageInspector(int stageIndex) async {
      if (localCategoryId == null || localCategoryId.isEmpty) return;
      await showLocalStageInspectorSheet(
        context: context,
        categoryId: localCategoryId,
        mode: localLearningMode,
        stage: SrsStage.values[stageIndex],
        categoryLabel: widget.title,
      );
      if (!mounted) return;
      await ref
          .read(localLearningControllerProvider.notifier)
          .startOrResume(
            categoryId: localCategoryId,
            mode: localLearningMode,
            trainingArea: TrainingArea.all,
            now: DateTime.now(),
          );
    }

    Widget cardContent;
    if (uiState.isLoading) {
      cardContent = const Center(
        child: Text('Laedt...', style: TextStyle(color: Colors.white)),
      );
    } else if (uiState.errorMessage != null) {
      cardContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fehler',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              uiState.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    } else if (cardState.hasCard) {
      cardContent = SwipeableWordCard(
        key: cardKey,
        frontText: cardState.frontText ?? '',
        backText: cardState.backText ?? '',
        level: null,
        showTranslation: _localShowTranslation,
        gesturesEnabled: true,
        srsStage: uiState.currentStage?.index,
        streak: null,
        passCount: null,
        onFlip: () {
          setState(() => _localShowTranslation = !_localShowTranslation);
        },
        onSwipe: (correct) async {
          if (correct) {
            await submitCorrect();
          } else {
            await submitWrong();
          }
        },
      );
    } else if (uiState.isCompleted) {
      cardContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Session abgeschlossen',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              uiState.progressLabel,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: localCategoryId == null || localCategoryId.isEmpty
                  ? null
                  : startOrResume,
              child: const Text('Weiterlernen'),
            ),
          ],
        ),
      );
    } else {
      final hasEmptyLocalSession =
          viewModelState.hasSession && viewModelState.totalItems == 0;
      cardContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasEmptyLocalSession
                  ? 'Keine lokalen Wörter verfügbar'
                  : localCategoryId == null || localCategoryId.isEmpty
                  ? 'Keine lokale Kategorie'
                  : 'Keine aktive lokale Session',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: localCategoryId == null || localCategoryId.isEmpty
                  ? null
                  : startOrResume,
              child: const Text('Starten/Fortsetzen'),
            ),
          ],
        ),
      );
    }

    final cardFrame = cardState.hasCard
        ? cardContent
        : _LocalLearnModeCardFrame(child: cardContent);
    const visibleMask = [true, true, true, true, true, true];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          key: stackKey,
          children: [
            Column(
              children: [
                HeaderBar(
                  customWheelLabels: [widget.title],
                  customWheelInitialIndex: 0,
                  customOnWheelChanged: (_, _) {},
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(child: Center(child: cardFrame)),
                StageSwitchRowView(
                  counts: localStageCounts,
                  goalPerStage: 100,
                  gap: 12,
                  visibleMask: visibleMask,
                  showLearnedCounterInStage5: true,
                  showSwitchNotes: true,
                  useNumericSwitchNotes: true,
                  learnedInStage5: 0,
                  s0Locked: false,
                  switchKeys: switchKeys,
                  onTapStage: openStageInspector,
                  activePulseStage: pulseStage,
                  activePulseColor: pulseColor,
                  activePulseAnimation: pulse,
                  labels: const StageSwitchLabels(
                    newLabel: 'New',
                    newNote: '0',
                    stagePrefix: 'T',
                  ),
                  colors: const StageSwitchColors(
                    newOuter: Color(0xFF8DBBFF),
                    stageOuter: Color(0xFF8DBBFF),
                    inner: Color(0xFF0B0B0D),
                    disabledOuter: Color(0xFFE9F1FF),
                    innerStroke: Color(0xFFB36BFF),
                  ),
                ),
                const SizedBox(height: WordsUIConstants.sectionSpacing),
                SizedBox(height: WordsUIConstants.bottomControlsPadding.bottom),
              ],
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: fx,
                builder: (_, __) {
                  return CustomPaint(
                    painter: PlasmaBandPainter(
                      cardRect: cardRect,
                      switchRect: switchRect,
                      phase: fx.value,
                      visible: _plasmaLinkEnabled && linkVisible,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: pulse,
                builder: (_, __) {
                  if (!mounted || pulseStage == null) {
                    return const SizedBox.shrink();
                  }
                  final targetKey = switchKeys[pulseStage!];
                  if (targetKey == null) return const SizedBox.shrink();
                  final rect = _tryRectInStack(targetKey);
                  if (rect == null) return const SizedBox.shrink();
                  return CustomPaint(
                    painter: SwitchPulsePainter(
                      rect: rect,
                      t: Curves.easeOutCubic.transform(pulse.value),
                      color: pulseColor,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalLearnModeCardFrame extends StatelessWidget {
  const _LocalLearnModeCardFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('local-learn-mode-card-frame'),
      width: MediaQuery.of(context).size.width * 0.78,
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(WordsUIConstants.borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.36),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: const Color(0xFFB1CCFE).withValues(alpha: 0.08),
            blurRadius: 42,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}

/// Blinkende Mastered-Zahl in der Mitte (während Feuerwerk)
/// Nach Feuerwerk (restartReady): nur weiß leuchten, kein Blinken
class _MasteredCountBlink extends StatefulWidget {
  final int count;
  final bool restartReady;

  const _MasteredCountBlink({required this.count, this.restartReady = false});

  @override
  State<_MasteredCountBlink> createState() => _MasteredCountBlinkState();
}

class _MasteredCountBlinkState extends State<_MasteredCountBlink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const _colors = [
    Color(0xFFE4B866), // Gold
    Color(0xFF4CAF50), // Grün
    Color(0xFF2196F3), // Blau
    Color(0xFF9C27B0), // Lila
    Color(0xFFFF5722), // Orange
  ];
  static const _white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (!widget.restartReady) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant _MasteredCountBlink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restartReady && _ctrl.isAnimating) {
      _ctrl.stop();
    } else if (!widget.restartReady && !_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.restartReady) {
      return SizedBox(
        height: 75,
        child: Center(
          child: Text(
            '${widget.count}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _white,
              shadows: [Shadow(color: _white.withOpacity(0.6), blurRadius: 12)],
            ),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final color =
            _colors[(_ctrl.value * _colors.length).floor() % _colors.length];
        return SizedBox(
          height: 75,
          child: Center(
            child: Text(
              '${widget.count}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: color,
                shadows: [
                  Shadow(color: color.withOpacity(0.6), blurRadius: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
