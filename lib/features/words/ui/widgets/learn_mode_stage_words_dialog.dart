import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

/// Dialog im Lernmodus: Zeigt nur die Wörter eines Stages mit
/// Level, Richtig/Falsch, Status (weiß/blau/grün).
class LearnModeStageWordsDialog extends ConsumerWidget {
  final String categoryId;
  final int stage;
  final String stageLabel;
  final int wordCount;
  final SrsSystem srsSystem;

  const LearnModeStageWordsDialog({
    super.key,
    required this.categoryId,
    required this.stage,
    required this.stageLabel,
    required this.wordCount,
    required this.srsSystem,
  });

  static Color _statusColor(int passCount) {
    switch (passCount.clamp(0, 2)) {
      case 0:
        return Colors.white;
      case 1:
        return const Color(0xFF64B5F6); // Hellblau
      case 2:
        return const Color(0xFF81C784); // Hellgrün
      default:
        return Colors.white;
    }
  }

  static String _statusLabel(int passCount) {
    switch (passCount.clamp(0, 2)) {
      case 0:
        return 'Weiß';
      case 1:
        return 'Blau';
      case 2:
        return 'Grün';
      default:
        return 'Weiß';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stageLabel,
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
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: FutureBuilder<List<WordUserView>>(
                future: fetchWordsByStage(
                  categoryId,
                  stage,
                  srsSystem: srsSystem,
                  useDisplayStageForAdaptive: srsSystem == SrsSystem.adaptive,
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
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      final statusColor = _statusColor(word.passCount);
                      final statusLabel = _statusLabel(word.passCount);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2F),
                          borderRadius: BorderRadius.circular(12),
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
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${word.passCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor == Colors.white
                                          ? const Color(0xFF333333)
                                          : Colors.white,
                                    ),
                                  ),
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
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                if (word.level != null)
                                  _InfoChip(
                                    label: 'Level',
                                    value: word.level!,
                                  ),
                                _InfoChip(
                                  label: 'Richtig',
                                  value: '${word.passCount}',
                                ),
                                _InfoChip(
                                  label: 'Falsch',
                                  value: '${word.lapses}',
                                ),
                                _InfoChip(
                                  label: 'Status',
                                  value: statusLabel,
                                  color: statusColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoChip({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.white24).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: color ?? Colors.white70,
        ),
      ),
    );
  }
}
