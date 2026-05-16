import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';

class LocalLearnModeActionBar extends StatelessWidget {
  const LocalLearnModeActionBar({
    super.key,
    required this.showAnswerActions,
    required this.showStartAction,
    required this.showCompleteAction,
    required this.onStartOrResume,
    required this.onCorrect,
    required this.onWrong,
    required this.onCompleteIfFinished,
  });

  final bool showAnswerActions;
  final bool showStartAction;
  final bool showCompleteAction;
  final Future<void> Function() onStartOrResume;
  final Future<void> Function() onCorrect;
  final Future<void> Function() onWrong;
  final Future<void> Function() onCompleteIfFinished;

  @override
  Widget build(BuildContext context) {
    Widget center;
    if (showStartAction) {
      center = _LocalActionPill(
        label: 'Starten/Fortsetzen',
        onPressed: onStartOrResume,
      );
    } else if (showCompleteAction) {
      center = _LocalActionPill(
        label: 'Session abschließen',
        onPressed: onCompleteIfFinished,
      );
    } else {
      center = const _LocalRoundControl(icon: Icons.play_arrow_rounded);
    }

    return Padding(
      padding: WordsUIConstants.bottomControlsPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          showAnswerActions
              ? _LocalAnswerButton(
                  label: 'Falsch',
                  icon: Icons.close_rounded,
                  onPressed: onWrong,
                )
              : const _LocalRoundControl(icon: Icons.grid_view_rounded),
          const SizedBox(width: 28),
          center,
          const SizedBox(width: 28),
          showAnswerActions
              ? _LocalAnswerButton(
                  label: 'Richtig',
                  icon: Icons.check_rounded,
                  onPressed: onCorrect,
                  highlighted: true,
                )
              : const _LocalRoundControl(icon: Icons.refresh_rounded),
        ],
      ),
    );
  }
}

class _LocalRoundControl extends StatelessWidget {
  const _LocalRoundControl({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2D2D2F),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: Colors.white.withValues(alpha: 0.74)),
    );
  }
}

class _LocalActionPill extends StatelessWidget {
  const _LocalActionPill({required this.label, required this.onPressed});

  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2D2D2F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _LocalAnswerButton extends StatelessWidget {
  const _LocalAnswerButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final background = highlighted
        ? const Color(0xFFB1CCFE)
        : const Color(0xFF2D2D2F);
    final foreground = highlighted ? const Color(0xFF111111) : Colors.white;

    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(
              color: Colors.white.withValues(alpha: highlighted ? 0.0 : 0.2),
            ),
          ),
        ),
      ),
    );
  }
}
