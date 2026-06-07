import 'package:flutter/material.dart';

const _semanticBackground = Color(0xFF050811);
const _semanticPanel = Color(0xFF0D1724);
const _semanticPanelSoft = Color(0xFF121F2E);
const _semanticCyan = Color(0xFF5DDCFF);
const _semanticMint = Color(0xFF9FF7D5);
const _semanticViolet = Color(0xFFB36BFF);
const _semanticGold = Color(0xFFFFD980);
const _semanticRose = Color(0xFFFF9EAE);

class WordSemanticsDecisionPreview extends StatefulWidget {
  const WordSemanticsDecisionPreview({super.key});

  @override
  State<WordSemanticsDecisionPreview> createState() =>
      _WordSemanticsDecisionPreviewState();
}

class _WordSemanticsDecisionPreviewState
    extends State<WordSemanticsDecisionPreview> {
  _PreviewWordId _selectedWord = _PreviewWordId.house;

  static const _words = [
    _PreviewWord(
      id: _PreviewWordId.house,
      word: 'Haus',
      shortPurpose: 'Multi-Home statt Pflichtstart',
      contextSense: 'Zuhause, Stadt, Land/Farm oder Küste/Strand',
      wordType: 'Nomen / BuildingCandidate / Multi-Home',
      safetySensitive: 'nicht sensibel, aber kontextabhängig',
      themeIslands: 'Zuhause, Stadt, Land/Farm, Küste/Strand',
      plotDepth: 'Plot oder Blueprint nur als Kandidat',
      representation: 'Context/Sense + Blueprint oder PlacementCandidate',
      previewGate: 'Nutzerkontext und Plot-/Build-Gate bleiben nötig',
      safeOutput: 'kein Pflicht-Hausstart',
      icon: Icons.home_work_rounded,
      accent: _semanticCyan,
    ),
    _PreviewWord(
      id: _PreviewWordId.garage,
      word: 'Garage',
      shortPurpose: 'nicht automatisch Zuhause',
      contextSense: 'Zuhause/Dorf, Verkehr/Fahrzeuge oder Stadt',
      wordType: 'Nomen / Utility / Vehicle-Parking-Kontext',
      safetySensitive: 'nicht sensibel, aber Fahrzeuglogik offen',
      themeIslands: 'Zuhause, Verkehr, Stadt',
      plotDepth: 'Utility-Plot oder Blueprint-Kandidat',
      representation: 'ContextCard oder Blueprint-Preview',
      previewGate: 'Theme-, Vehicle- und Plot-Gate bleiben nötig',
      safeOutput: 'keine automatische Fahrzeuglogik',
      icon: Icons.garage_rounded,
      accent: _semanticGold,
    ),
    _PreviewWord(
      id: _PreviewWordId.tree,
      word: 'Baum',
      shortPurpose: 'Natur ohne Deko-Clutter',
      contextSense: 'Garten/Natur, Stadt/Park oder Farm/Obstbaum',
      wordType: 'Nomen / Naturwort / mögliches Deko-Objekt',
      safetySensitive: 'Clutter-Risiko auf kleinen Displays',
      themeIslands: 'Garten/Natur, Stadt/Park, Farm/Land',
      plotDepth: 'Naturfläche, PlotCandidate oder Backlog',
      representation: 'Natur-/Clutter-Hinweis, ggf. Backlog',
      previewGate: 'Mobile-/Clutter-Gate bleibt nötig',
      safeOutput: 'keine Massendeko',
      icon: Icons.park_rounded,
      accent: _semanticMint,
    ),
    _PreviewWord(
      id: _PreviewWordId.swim,
      word: 'schwimmen',
      shortPurpose: 'Aktion statt Objekt',
      contextSense: 'Wasser, Freizeit, Küste/Meer oder Sport',
      wordType: 'Verb / Aktion / Water-Safety',
      safetySensitive: 'Wasser- und Action-Gate offen',
      themeIslands: 'Küste/Meer, Freizeit, Sport',
      plotDepth: 'ActionChallenge oder ContextCard, kein Gebäude',
      representation: 'ActionChallenge oder ContextCard',
      previewGate: 'Water-/Safety-/Action-Gate bleibt nötig',
      safeOutput: 'kein statisches Objekt',
      icon: Icons.waves_rounded,
      accent: _semanticViolet,
    ),
    _PreviewWord(
      id: _PreviewWordId.fear,
      word: 'Angst',
      shortPurpose: 'Emotion ohne Druck',
      contextSense: 'Gefühl, Companion-Kontext oder Codex',
      wordType: 'Emotion / abstrakt / sensibel',
      safetySensitive: 'Sensitive-/UX-Gate erforderlich',
      themeIslands: 'Companion, Codex, Kontextkarte',
      plotDepth: 'kein Plot; ContextCard oder Codex',
      representation: 'Companion/ContextCard/Codex',
      previewGate: 'Sensitive-/UX-Gate bleibt nötig',
      safeOutput: 'kein Objekt und kein Reward-Druck',
      icon: Icons.psychology_alt_rounded,
      accent: _semanticRose,
    ),
    _PreviewWord(
      id: _PreviewWordId.learn,
      word: 'lernen',
      shortPurpose: 'Aktion statt Schulzwang',
      contextSense: 'Aktion, Lernmodus oder Schule nach Kontext',
      wordType: 'Verb / Aktion / LearningMode',
      safetySensitive: 'kein sensibler Inhalt, aber Pflichtschule vermeiden',
      themeIslands: 'Schule möglich, Codex oder Challenge möglich',
      plotDepth: 'Challenge, LearningMode oder Codex',
      representation: 'Challenge/LearningMode oder Codex',
      previewGate: 'Learning-/School-Misread-Gate bleibt nötig',
      safeOutput: 'kein automatisches Schulgebäude',
      icon: Icons.school_rounded,
      accent: _semanticMint,
    ),
    _PreviewWord(
      id: _PreviewWordId.knife,
      word: 'Messer',
      shortPurpose: 'Tool mit Safety-Kontext',
      contextSense: 'Küche, Tool, ContainerItem oder Safety-Fall',
      wordType: 'Nomen / kleines Tool / ContainerItem',
      safetySensitive: 'Safety-, Container- und Clutter-Gate erforderlich',
      themeIslands: 'Zuhause/Küche, Essen, Container, Codex',
      plotDepth: 'ContainerItem oder ContextCard, nicht frei sichtbar',
      representation: 'ContainerItem-Preview oder ContextCard',
      previewGate: 'Safety-/Container-/Clutter-Gate bleibt nötig',
      safeOutput: 'kein sichtbares Objekt ohne Gate',
      icon: Icons.restaurant_menu_rounded,
      accent: Color(0xFFE1D4BF),
    ),
    _PreviewWord(
      id: _PreviewWordId.police,
      word: 'Polizei',
      shortPurpose: 'Policy Gate vor Weltobjekt',
      contextSense: 'öffentliche Institution, Verwaltung oder Sicherheit',
      wordType: 'Nomen / Public Institution / sensibel',
      safetySensitive: 'Policy-/Sensitive-Gate erforderlich',
      themeIslands: 'Verwaltung, Gesellschaft, Codex, ContextCard',
      plotDepth: 'kein automatischer Plot; ContextCard oder Codex',
      representation: 'ContextCard, Codex oder BlockedUntilRules',
      previewGate: 'Policy-/Sensitive-Gate bleibt nötig',
      safeOutput: 'keine automatische Polizeiwache',
      icon: Icons.policy_rounded,
      accent: _semanticRose,
    ),
  ];

  _PreviewWord get _selectedExample =>
      _words.firstWhere((word) => word.id == _selectedWord);

  void _selectWord(_PreviewWordId id) {
    setState(() {
      _selectedWord = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _semanticCyan,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _semanticBackground,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: theme,
        child: Material(
          color: _semanticBackground,
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
                      const _PreviewIntroCard(),
                      const SizedBox(height: 14),
                      _WordCardGrid(
                        words: _words,
                        selectedWord: _selectedWord,
                        onSelect: _selectWord,
                      ),
                      const SizedBox(height: 14),
                      _DecisionDetailPanel(example: _selectedExample),
                      const SizedBox(height: 14),
                      const _GlobalGuardrailsPanel(),
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

enum _PreviewWordId { house, garage, tree, swim, fear, learn, knife, police }

class _PreviewWord {
  const _PreviewWord({
    required this.id,
    required this.word,
    required this.shortPurpose,
    required this.contextSense,
    required this.wordType,
    required this.safetySensitive,
    required this.themeIslands,
    required this.plotDepth,
    required this.representation,
    required this.previewGate,
    required this.safeOutput,
    required this.icon,
    required this.accent,
  });

  final _PreviewWordId id;
  final String word;
  final String shortPurpose;
  final String contextSense;
  final String wordType;
  final String safetySensitive;
  final String themeIslands;
  final String plotDepth;
  final String representation;
  final String previewGate;
  final String safeOutput;
  final IconData icon;
  final Color accent;
}

class _PreviewStatusBanner extends StatelessWidget {
  const _PreviewStatusBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Lokale Word Semantics Preview. Keine Speicherung. Keine Platzierung. Kein Bauzustand.',
      child: Container(
        key: const Key('word-semantics-preview-status'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _semanticViolet.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _semanticViolet.withValues(alpha: 0.42)),
        ),
        child: const Text(
          'Lokale Semantik-Preview / keine Route / keine Speicherung',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
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

class _PreviewIntroCard extends StatelessWidget {
  const _PreviewIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('word-semantics-preview-intro'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        color: _semanticPanel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _semanticCyan.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _semanticCyan.withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _semanticCyan.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _semanticCyan.withValues(alpha: 0.42)),
            ),
            child: const Icon(Icons.schema_rounded, color: _semanticCyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WordSemanticsDecisionPreview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Wähle ein Beispielwort. Die Preview zeigt, warum daraus nicht automatisch ein Weltobjekt, Grundstück oder Bauzustand entsteht.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordCardGrid extends StatelessWidget {
  const _WordCardGrid({
    required this.words,
    required this.selectedWord,
    required this.onSelect,
  });

  final List<_PreviewWord> words;
  final _PreviewWordId selectedWord;
  final ValueChanged<_PreviewWordId> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('word-semantics-example-grid'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _semanticPanelSoft.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          final cardWidth = compact
              ? constraints.maxWidth
              : (constraints.maxWidth - 10) / 2;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final word in words)
                SizedBox(
                  width: cardWidth,
                  child: _WordExampleCard(
                    word: word,
                    selected: selectedWord == word.id,
                    onTap: () => onSelect(word.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WordExampleCard extends StatelessWidget {
  const _WordExampleCard({
    required this.word,
    required this.selected,
    required this.onTap,
  });

  final _PreviewWord word;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = word.accent;

    return Semantics(
      button: true,
      selected: selected,
      label:
          '${word.word}. ${word.shortPurpose}. Lokale Auswahl ohne Speicherung.',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          key: Key('word-semantics-card-${word.word}'),
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: selected ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accent.withValues(alpha: selected ? 0.86 : 0.34),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: accent.withValues(alpha: 0.2),
                  blurRadius: 18,
                  spreadRadius: -8,
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(word.icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      word.shortPurpose,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle_rounded, color: accent, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DecisionDetailPanel extends StatelessWidget {
  const _DecisionDetailPanel({required this.example});

  final _PreviewWord example;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('word-semantics-decision-detail'),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        color: _semanticPanel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: example.accent.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: example.accent.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DecisionHeader(example: example),
          const SizedBox(height: 12),
          _DecisionStep(
            label: 'Context / Sense',
            text: example.contextSense,
            color: _semanticCyan,
          ),
          _DecisionStep(
            label: 'Word Type',
            text: example.wordType,
            color: _semanticMint,
          ),
          _DecisionStep(
            label: 'Safety / Sensitive',
            text: example.safetySensitive,
            color: _semanticRose,
          ),
          _DecisionStep(
            label: 'Candidate ThemeIsland(s)',
            text: example.themeIslands,
            color: _semanticGold,
          ),
          _DecisionStep(
            label: 'Candidate Plot / Depth',
            text: example.plotDepth,
            color: _semanticViolet,
          ),
          _DecisionStep(
            label: 'Representation Decision',
            text: example.representation,
            color: _semanticCyan,
          ),
          _DecisionStep(
            label: 'Preview Only / Later Gate',
            text: example.previewGate,
            color: _semanticMint,
          ),
          const SizedBox(height: 4),
          _SafeOutputPill(text: example.safeOutput, color: example.accent),
        ],
      ),
    );
  }
}

class _DecisionHeader extends StatelessWidget {
  const _DecisionHeader({required this.example});

  final _PreviewWord example;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: example.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: example.accent.withValues(alpha: 0.4)),
          ),
          child: Icon(example.icon, color: example.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                example.word,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lokale Entscheidungsvorschau. Keine echte Routinglogik.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 12,
                  height: 1.28,
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

class _DecisionStep extends StatelessWidget {
  const _DecisionStep({
    required this.label,
    required this.text,
    required this.color,
  });

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              height: 1.28,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeOutputPill extends StatelessWidget {
  const _SafeOutputPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.2,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _GlobalGuardrailsPanel extends StatelessWidget {
  const _GlobalGuardrailsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('word-semantics-global-guardrails'),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _GuardrailChip(
            icon: Icons.save_alt_rounded,
            text: 'Keine Speicherung',
          ),
          _GuardrailChip(icon: Icons.place_outlined, text: 'Keine Platzierung'),
          _GuardrailChip(
            icon: Icons.domain_disabled_rounded,
            text: 'Kein Bauzustand',
          ),
          _GuardrailChip(
            icon: Icons.auto_fix_off_rounded,
            text: 'Keine automatische Wortplatzierung',
          ),
        ],
      ),
    );
  }
}

class _GuardrailChip extends StatelessWidget {
  const _GuardrailChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _semanticCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _semanticCyan.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _semanticCyan, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
