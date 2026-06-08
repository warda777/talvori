import 'package:flutter/material.dart';

const _bankPreviewBackground = Color(0xFF041017);
const _bankPreviewPanel = Color(0xFF0A1A26);
const _bankPreviewSurface = Color(0xFF102838);
const _bankPreviewCyan = Color(0xFF5DDCFF);
const _bankPreviewMint = Color(0xFF9FF7D5);
const _bankPreviewViolet = Color(0xFFB36BFF);
const _bankPreviewGold = Color(0xFFFFD980);
const _bankPreviewInk = Colors.white;

class BankMeaningPuzzlePreview extends StatefulWidget {
  const BankMeaningPuzzlePreview({super.key});

  @override
  State<BankMeaningPuzzlePreview> createState() =>
      _BankMeaningPuzzlePreviewState();
}

class _BankMeaningPuzzlePreviewState extends State<BankMeaningPuzzlePreview> {
  _BankMeaningOptionId? _selectedOption;
  _SafeExitId? _selectedSafeExit;

  static const _options = [
    _BankMeaningOption(
      id: _BankMeaningOptionId.bench,
      title: 'Sitzbank',
      hint: 'Ein Ort zum Sitzen.',
      detail: 'Das waere moeglich, aber die Szene sagt nicht, dass Tali sitzt.',
      icon: Icons.chair_alt_rounded,
    ),
    _BankMeaningOption(
      id: _BankMeaningOptionId.institution,
      title: 'Geldinstitut',
      hint: 'Ein Ort fuer Geld.',
      detail:
          'Das passt hier nicht gut: In der Szene geht es um einen Fluss, nicht um Geld.',
      icon: Icons.account_balance_rounded,
    ),
    _BankMeaningOption(
      id: _BankMeaningOptionId.riverEdge,
      title: 'Flussufer',
      hint: 'Der Rand am Wasser.',
      detail:
          'Genau: Am Fluss meint Bank hier das Ufer. Kontext entscheidet die Bedeutung.',
      icon: Icons.water_rounded,
    ),
  ];

  bool get _hasCorrectSelection =>
      _selectedOption == _BankMeaningOptionId.riverEdge;

  void _selectOption(_BankMeaningOptionId id) {
    setState(() {
      _selectedOption = id;
      _selectedSafeExit = null;
    });
  }

  void _selectSafeExit(_SafeExitId id) {
    setState(() {
      _selectedSafeExit = id;
      if (id == _SafeExitId.change) {
        _selectedOption = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _bankPreviewCyan,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _bankPreviewBackground,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: theme,
        child: Material(
          color: _bankPreviewBackground,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _PreviewStatusBanner(),
                      const SizedBox(height: 14),
                      const _BankSceneCard(),
                      const SizedBox(height: 14),
                      _MeaningOptionGrid(
                        selectedOption: _selectedOption,
                        onSelect: _selectOption,
                      ),
                      const SizedBox(height: 14),
                      _MeaningFeedbackPanel(
                        selectedOption: _selectedOption,
                        hasCorrectSelection: _hasCorrectSelection,
                      ),
                      const SizedBox(height: 14),
                      _SafeExitPanel(
                        selectedSafeExit: _selectedSafeExit,
                        onSelect: _selectSafeExit,
                      ),
                      const SizedBox(height: 14),
                      const _GuardrailPanel(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _BankMeaningOptionId { bench, institution, riverEdge }

enum _SafeExitId { later, codex, backlog, change }

class _BankMeaningOption {
  const _BankMeaningOption({
    required this.id,
    required this.title,
    required this.hint,
    required this.detail,
    required this.icon,
  });

  final _BankMeaningOptionId id;
  final String title;
  final String hint;
  final String detail;
  final IconData icon;

  bool get isCorrect => id == _BankMeaningOptionId.riverEdge;
}

class _PreviewStatusBanner extends StatelessWidget {
  const _PreviewStatusBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Lokale Bank Meaning Puzzle Preview. Keine Route. Keine Speicherung. Kein Bauzustand.',
      child: Container(
        key: const Key('bank-meaning-puzzle-preview-status'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _bankPreviewViolet.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _bankPreviewViolet.withValues(alpha: 0.42)),
        ),
        child: const Text(
          'Lokale Context-Door-Preview / keine Route / nichts wird gespeichert',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _bankPreviewInk,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.25,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _BankSceneCard extends StatelessWidget {
  const _BankSceneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bank-meaning-puzzle-scene'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        color: _bankPreviewPanel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _bankPreviewCyan.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: _bankPreviewCyan.withValues(alpha: 0.1),
            blurRadius: 28,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _bankPreviewCyan.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _bankPreviewCyan.withValues(alpha: 0.44),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _bankPreviewCyan,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tali/Vori Micro Scene',
                      style: TextStyle(
                        color: _bankPreviewInk,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Am Fluss macht Tali kurz Pause.',
                      style: TextStyle(
                        color: _bankPreviewInk,
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            decoration: BoxDecoration(
              color: _bankPreviewSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _bankPreviewMint.withValues(alpha: 0.2),
              ),
            ),
            child: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Context Door: '),
                  TextSpan(
                    text: 'Welche Bedeutung von "Bank" passt zur Szene?',
                    style: TextStyle(color: _bankPreviewMint),
                  ),
                ],
              ),
              style: TextStyle(
                color: _bankPreviewInk,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeaningOptionGrid extends StatelessWidget {
  const _MeaningOptionGrid({
    required this.selectedOption,
    required this.onSelect,
  });

  final _BankMeaningOptionId? selectedOption;
  final ValueChanged<_BankMeaningOptionId> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final cards = _BankMeaningPuzzlePreviewState._options.map((option) {
          return _MeaningOptionCard(
            option: option,
            selected: selectedOption == option.id,
            onTap: () => onSelect(option.id),
          );
        }).toList();

        if (compact) {
          return Column(
            key: const Key('bank-meaning-options-column'),
            children: [
              for (final card in cards) ...[
                card,
                if (card != cards.last) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          key: const Key('bank-meaning-options-row'),
          children: [
            for (final card in cards) ...[
              Expanded(child: card),
              if (card != cards.last) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _MeaningOptionCard extends StatelessWidget {
  const _MeaningOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _BankMeaningOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? _bankPreviewMint : _bankPreviewCyan;

    return Semantics(
      button: true,
      selected: selected,
      label: '${option.title}. ${option.hint}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('bank-meaning-option-${option.id.name}'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
            decoration: BoxDecoration(
              color: selected
                  ? _bankPreviewMint.withValues(alpha: 0.13)
                  : _bankPreviewPanel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accent.withValues(alpha: selected ? 0.62 : 0.24),
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(option.icon, color: accent, size: 28),
                const SizedBox(height: 9),
                Text(
                  option.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _bankPreviewInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  option.hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeaningFeedbackPanel extends StatelessWidget {
  const _MeaningFeedbackPanel({
    required this.selectedOption,
    required this.hasCorrectSelection,
  });

  final _BankMeaningOptionId? selectedOption;
  final bool hasCorrectSelection;

  @override
  Widget build(BuildContext context) {
    final selected = selectedOption == null
        ? null
        : _BankMeaningPuzzlePreviewState._options.firstWhere(
            (option) => option.id == selectedOption,
          );
    final accent = selectedOption == null
        ? _bankPreviewCyan
        : hasCorrectSelection
        ? _bankPreviewMint
        : _bankPreviewGold;
    final title = selectedOption == null
        ? 'Kleine Bedeutungstuer'
        : hasCorrectSelection
        ? 'ContextCard / Codex Discovery'
        : 'Calm Retry';
    final body = selectedOption == null
        ? 'Waehle eine Bedeutung. Es geht nicht um Punkte, sondern darum, die Szene zu verstehen.'
        : selected!.detail;
    final support = selectedOption == null
        ? 'Feedback ist Bedeutungsklarheit, kein Score.'
        : hasCorrectSelection
        ? 'Kein Build, kein Placement, kein SRS-Write.'
        : 'Schau ruhig noch einmal auf den Kontext "am Fluss". Kein Verlust, keine Strafe.';

    return Container(
      key: const Key('bank-meaning-feedback-panel'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: _bankPreviewPanel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasCorrectSelection
                    ? Icons.travel_explore_rounded
                    : Icons.lightbulb_outline_rounded,
                color: accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _bankPreviewInk,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.77),
              fontSize: 14,
              height: 1.38,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          _SoftCallout(text: support, color: accent),
        ],
      ),
    );
  }
}

class _SafeExitPanel extends StatelessWidget {
  const _SafeExitPanel({
    required this.selectedSafeExit,
    required this.onSelect,
  });

  final _SafeExitId? selectedSafeExit;
  final ValueChanged<_SafeExitId> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bank-meaning-safe-exits'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: _bankPreviewSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Safe Defaults bleiben sichtbar',
            style: TextStyle(
              color: _bankPreviewInk,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Du musst nichts bauen, speichern oder sofort entscheiden.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SafeExitChip(
                id: _SafeExitId.later,
                label: 'Later',
                selected: selectedSafeExit == _SafeExitId.later,
                onTap: onSelect,
              ),
              _SafeExitChip(
                id: _SafeExitId.codex,
                label: 'Codex',
                selected: selectedSafeExit == _SafeExitId.codex,
                onTap: onSelect,
              ),
              _SafeExitChip(
                id: _SafeExitId.backlog,
                label: 'Backlog',
                selected: selectedSafeExit == _SafeExitId.backlog,
                onTap: onSelect,
              ),
              _SafeExitChip(
                id: _SafeExitId.change,
                label: 'Change',
                selected: selectedSafeExit == _SafeExitId.change,
                onTap: onSelect,
              ),
            ],
          ),
          if (selectedSafeExit != null) ...[
            const SizedBox(height: 12),
            _SoftCallout(
              text: _safeExitMessage(selectedSafeExit!),
              color: _bankPreviewViolet,
            ),
          ],
        ],
      ),
    );
  }

  String _safeExitMessage(_SafeExitId id) {
    return switch (id) {
      _SafeExitId.later =>
        'Later parkt die Entscheidung ohne Nachteil und ohne Druck.',
      _SafeExitId.codex =>
        'Codex erklaert die Bedeutung neutral, ohne Weltobjekt.',
      _SafeExitId.backlog =>
        'Backlog merkt die Idee fachlich vor, ohne Persistenz in dieser Preview.',
      _SafeExitId.change =>
        'Change setzt die lokale Auswahl zurueck. Nichts ist irreversibel.',
    };
  }
}

class _SafeExitChip extends StatelessWidget {
  const _SafeExitChip({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _SafeExitId id;
  final String label;
  final bool selected;
  final ValueChanged<_SafeExitId> onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _bankPreviewMint : _bankPreviewCyan;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('bank-meaning-safe-exit-${id.name}'),
        borderRadius: BorderRadius.circular(999),
        onTap: () => onTap(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.36)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _bankPreviewInk,
              fontSize: 12,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftCallout extends StatelessWidget {
  const _SoftCallout({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.84),
          fontSize: 13,
          height: 1.32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _GuardrailPanel extends StatelessWidget {
  const _GuardrailPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('bank-meaning-guardrails'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _bankPreviewGold.withValues(alpha: 0.22)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ende ohne Pflicht',
            style: TextStyle(
              color: _bankPreviewInk,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GuardrailBadge(text: 'kein Timer'),
              _GuardrailBadge(text: 'kein Streak'),
              _GuardrailBadge(text: 'kein XP'),
              _GuardrailBadge(text: 'kein Review-Zwang'),
              _GuardrailBadge(text: 'kein Build'),
              _GuardrailBadge(text: 'kein Placement'),
              _GuardrailBadge(text: 'kein SRS-Write'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuardrailBadge extends StatelessWidget {
  const _GuardrailBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _bankPreviewGold.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _bankPreviewGold.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 11,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
