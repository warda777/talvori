import 'package:flutter/material.dart';

const _bankPreviewBackground = Color(0xFF041017);
const _bankPreviewPanel = Color(0xFF0A1A26);
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
      doorLabel: 'Uferplatz',
      title: 'Sitzbank',
      hint: 'Objekt am Ufer.',
      detail:
          'Das waere ein anderer Weg: Die Szene sagt nicht, dass Tali sich auf eine Sitzbank setzt.',
      icon: Icons.chair_alt_rounded,
    ),
    _BankMeaningOption(
      id: _BankMeaningOptionId.institution,
      doorLabel: 'Stadtschild',
      title: 'Geldinstitut',
      hint: 'Weg in die Stadt.',
      detail:
          'Ruhig nochmal schauen: In dieser Szene geht es um einen Fluss, nicht um Geld.',
      icon: Icons.account_balance_rounded,
    ),
    _BankMeaningOption(
      id: _BankMeaningOptionId.riverEdge,
      doorLabel: 'Wasserweg',
      title: 'Flussufer',
      hint: 'Kante am Wasser.',
      detail:
          'Genau: Am Fluss oeffnet Bank die Tuer zum Ufer. Kontext entscheidet die Bedeutung.',
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
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 58),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _PreviewStatusBanner(),
                      const SizedBox(height: 10),
                      _IslandPlotScene(
                        selectedOption: _selectedOption,
                        hasCorrectSelection: _hasCorrectSelection,
                        onSelect: _selectOption,
                      ),
                      const SizedBox(height: 10),
                      _SafeExitPanel(
                        selectedSafeExit: _selectedSafeExit,
                        onSelect: _selectSafeExit,
                      ),
                      const SizedBox(height: 10),
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
    required this.doorLabel,
    required this.title,
    required this.hint,
    required this.detail,
    required this.icon,
  });

  final _BankMeaningOptionId id;
  final String doorLabel;
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
          'Lokale Island-First Preview / keine Route / nichts wird gespeichert',
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

class _IslandPlotScene extends StatelessWidget {
  const _IslandPlotScene({
    required this.selectedOption,
    required this.hasCorrectSelection,
    required this.onSelect,
  });

  final _BankMeaningOptionId? selectedOption;
  final bool hasCorrectSelection;
  final ValueChanged<_BankMeaningOptionId> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = selectedOption == null
        ? null
        : _BankMeaningPuzzlePreviewState._options.firstWhere(
            (option) => option.id == selectedOption,
          );

    return Container(
      key: const Key('bank-meaning-island-plot-scene'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _bankPreviewCyan.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: _bankPreviewCyan.withValues(alpha: 0.11),
            blurRadius: 30,
            spreadRadius: -12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned.fill(child: _RiverbankBackdrop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SceneTopHud(),
                  const SizedBox(height: 12),
                  _CompanionSceneBubble(selectedOption: selectedOption),
                  const SizedBox(height: 16),
                  _MeaningObjectGrid(
                    selectedOption: selectedOption,
                    onSelect: onSelect,
                  ),
                  const SizedBox(height: 14),
                  _WorldFeedbackBubble(
                    selected: selected,
                    hasCorrectSelection: hasCorrectSelection,
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

class _RiverbankBackdrop extends StatelessWidget {
  const _RiverbankBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF123D36), Color(0xFF0A2A2F), Color(0xFF073250)],
          stops: [0, 0.58, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -40,
            right: -30,
            bottom: -16,
            height: 122,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _bankPreviewCyan.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            left: -24,
            right: 86,
            bottom: 78,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _bankPreviewMint.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 92,
            width: 76,
            height: 22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _bankPreviewGold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneTopHud extends StatelessWidget {
  const _SceneTopHud();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _bankPreviewCyan.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _bankPreviewCyan.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.terrain_rounded, color: _bankPreviewCyan),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flussufer-Plot',
                style: TextStyle(
                  color: _bankPreviewInk,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Am Fluss macht Tali kurz Pause. Welcher Ort meint hier "Bank"?',
                style: TextStyle(
                  color: _bankPreviewInk,
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompanionSceneBubble extends StatelessWidget {
  const _CompanionSceneBubble({required this.selectedOption});

  final _BankMeaningOptionId? selectedOption;

  @override
  Widget build(BuildContext context) {
    final text = selectedOption == null
        ? 'Tali zeigt drei Orte am Plot. Tippe den Ort, der zur Flussszene passt.'
        : 'Tali bleibt ruhig: Kontext entscheidet, nicht Punkte.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _bankPreviewViolet.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _bankPreviewViolet.withValues(alpha: 0.4),
            ),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: _bankPreviewViolet,
            size: 20,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: _bankPreviewPanel.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _bankPreviewViolet.withValues(alpha: 0.26),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.86),
                fontSize: 13,
                height: 1.28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MeaningObjectGrid extends StatelessWidget {
  const _MeaningObjectGrid({
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
        final markers = _BankMeaningPuzzlePreviewState._options.map((option) {
          return _MeaningObjectMarker(
            option: option,
            selected: selectedOption == option.id,
            onTap: () => onSelect(option.id),
          );
        }).toList();

        if (compact) {
          return Column(
            key: const Key('bank-meaning-island-options-column'),
            children: [
              for (final marker in markers) ...[
                marker,
                if (marker != markers.last) const SizedBox(height: 9),
              ],
            ],
          );
        }

        return Row(
          key: const Key('bank-meaning-island-options-row'),
          children: [
            for (final marker in markers) ...[
              Expanded(child: marker),
              if (marker != markers.last) const SizedBox(width: 9),
            ],
          ],
        );
      },
    );
  }
}

class _MeaningObjectMarker extends StatelessWidget {
  const _MeaningObjectMarker({
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
          key: Key('bank-meaning-island-option-${option.id.name}'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
            decoration: BoxDecoration(
              color: _bankPreviewPanel.withValues(alpha: selected ? 0.86 : 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accent.withValues(alpha: selected ? 0.7 : 0.28),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: selected ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withValues(alpha: 0.34)),
                  ),
                  child: Icon(option.icon, color: accent, size: 26),
                ),
                const SizedBox(height: 7),
                Text(
                  option.doorLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _bankPreviewInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    height: 1.2,
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

class _WorldFeedbackBubble extends StatelessWidget {
  const _WorldFeedbackBubble({
    required this.selected,
    required this.hasCorrectSelection,
  });

  final _BankMeaningOption? selected;
  final bool hasCorrectSelection;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected != null;
    final accent = !hasSelection
        ? _bankPreviewCyan
        : hasCorrectSelection
        ? _bankPreviewMint
        : _bankPreviewGold;
    final title = !hasSelection
        ? 'Plot-Hinweis'
        : hasCorrectSelection
        ? 'Codex Discovery am Ufer'
        : 'Calm Retry am Plot';
    final body = !hasSelection
        ? 'Die Insel zeigt drei Orte. Kontext oeffnet den passenden Weg.'
        : selected!.detail;
    final support = !hasSelection
        ? 'Kein Score: du liest die Szene.'
        : hasCorrectSelection
        ? 'Bank = Flussufer in dieser Szene. Kein Build, kein Placement, kein SRS-Write.'
        : 'Kein Verlust. Tali schaut mit dir nochmal auf "am Fluss".';

    return Container(
      key: const Key('bank-meaning-world-feedback'),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: _bankPreviewPanel.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.36)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasCorrectSelection
                ? Icons.travel_explore_rounded
                : Icons.tips_and_updates_rounded,
            color: accent,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _bankPreviewInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                _SoftCallout(text: support, color: accent),
              ],
            ),
          ),
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
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _bankPreviewViolet.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.exit_to_app_rounded,
                color: _bankPreviewMint,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'HUD: Safe Exits',
                  style: TextStyle(
                    color: _bankPreviewInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                'lokal',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Toolbelt ohne Side Effects: kein Build, keine Speicherung.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
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
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bankPreviewGold.withValues(alpha: 0.16)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Safety Footer',
            style: TextStyle(
              color: _bankPreviewInk,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8),
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
              _GuardrailBadge(text: 'keine Speicherung'),
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
