import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/application/srs_logic.dart';
import 'package:talvori/features/words/application/srs_config.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';

/// Dialog, der die Wörter eines bestimmten Stages anzeigt
class StageWordsDialog extends ConsumerWidget {
  final String categoryId;
  final int stage;
  final String stageLabel; // z.B. "T0", "T1", etc.
  final int wordCount;
  final SrsPopupMode popupMode;
  final SrsPopupRange popupRange;
  final bool s0Locked;
  final int? dailyNewLimit;
  final int? learnedTodayFromS0;

  const StageWordsDialog({
    super.key,
    required this.categoryId,
    required this.stage,
    required this.stageLabel,
    required this.wordCount,
    required this.popupMode,
    required this.popupRange,
    required this.s0Locked,
    this.dailyNewLimit,
    this.learnedTodayFromS0,
  });

  static SrsSystem _popupModeToSrsSystem(SrsPopupMode mode) {
    switch (mode) {
      case SrsPopupMode.tSrs:
        return SrsSystem.time;
      case SrsPopupMode.aSrs:
        return SrsSystem.adaptive;
      case SrsPopupMode.hybrid:
        return SrsSystem.hybrid;
    }
  }

  /// Berechnet die Tage für T-SRS Stages
  static int? getTSrsDaysForStage(int stage) {
    switch (stage) {
      case 0:
        return 0; // Sofort verfügbar
      case 1:
        return 2; // Nach 2 Tagen
      case 2:
        return 6; // Nach 6 Tagen
      case 3:
      case 4:
      case 5:
        return 19; // Nach 19 Tagen
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final srsState = ref.watch(srsModeControllerProvider);
    final isTSrs = srsState.mode == SrsSystem.time;
    final daysForStage = isTSrs ? getTSrsDaysForStage(stage) : null;

    final header = SrsPopupText.stageHeader(stage, popupMode);
    final rangeLine = SrsPopupText.rangeLabel(popupRange, popupMode);

    final modeLogic = switch (popupMode) {
      SrsPopupMode.tSrs => SrsPopupText.tSrsLogicForStage(stage, s0Locked: s0Locked, mode: popupMode),
      SrsPopupMode.aSrs => SrsPopupText.aSrsLogicForStage(stage),
      SrsPopupMode.hybrid => SrsPopupText.hybridLogicForStage(stage, popupMode),
    };

    final progression = SrsPopupText.progressionBlock(
      stage: stage,
      mode: popupMode,
      s0Locked: s0Locked,
      range: popupRange,
    );

    final colors = SrsPopupText.colorLegend(s0Locked: s0Locked, mode: popupMode);

    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (fest)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          header,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$wordCount Wörter',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollbarer Content
            Expanded(
              child: Scrollbar(
                thumbVisibility: false, // Wird automatisch beim Scrollen sichtbar
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Range Info
                    Text(
                      rangeLine,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Was ist das?
                    _Section(
                      title: "Was ist das?",
                      text: SrsPopupText.whatIs(stage, popupMode),
                    ),

                    // Wie funktioniert es?
                    _Section(
                      title: "Wie funktioniert es?",
                      text: modeLogic,
                    ),

                    // Aufstieg / Abstieg
                    _Section(
                      title: "Aufstieg / Abstieg",
                      text: progression,
                    ),

                    // Tageslimit (nur für Stage 0 bei T-SRS)
                    if (popupMode == SrsPopupMode.tSrs && stage == 0) ...[
                      const SizedBox(height: 12),
                      _Section(
                        title: "Tageslimit (${SrsPopupText.stageLabel(0, popupMode)})",
                        text: s0Locked
                            ? "${SrsPopupText.stageLabel(0, popupMode)} ist blockiert – heute werden keine neuen Wörter eingeführt."
                            : "Heute maximal: ${dailyNewLimit ?? SrsUiConfig.tSrsDailyNewLimit} neue Wörter"
                                "${learnedTodayFromS0 != null ? "\nHeute bereits gelernt: $learnedTodayFromS0 / ${(dailyNewLimit ?? SrsUiConfig.tSrsDailyNewLimit)}" : ""}",
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),

                    // Aktuell in dieser Stufe
                    Text(
                      "Aktuell in dieser Stufe",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Wortliste (modus-spezifisch aus user_word_srs)
                    FutureBuilder<List<WordUserView>>(
                      future: fetchWordsByStage(
                        categoryId,
                        stage,
                        srsSystem: _popupModeToSrsSystem(popupMode),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Fehler beim Laden: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final words = snapshot.data ?? [];

                        if (words.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Keine Wörter in diesem Stage',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        return Column(
                          children: words.asMap().entries.map((entry) {
                            final index = entry.key;
                            final word = entry.value;
                            final total = words.length;
                            final daysUntilDue = word.nextDueAt != null
                                ? word.nextDueAt!.difference(DateTime.now()).inDays
                                : null;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2D2F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: daysUntilDue != null && daysUntilDue > 0
                                      ? Colors.orange.withOpacity(0.5)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          word.text,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (daysUntilDue != null && daysUntilDue > 0 && isTSrs)
                                            Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'In $daysUntilDue Tag${daysUntilDue == 1 ? '' : 'en'}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          // Nummerierung unten rechts
                                          Text(
                                            '${index + 1}/$total',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    word.translation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  if (word.level != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Level: ${word.level}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),

                    // Farben & Feedback
                    _Section(
                      title: "Farben & Feedback",
                      text: colors,
                    ),

                    const SizedBox(height: 20),
                  ],
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

class _Section extends StatelessWidget {
  final String title;
  final String text;
  const _Section({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}
