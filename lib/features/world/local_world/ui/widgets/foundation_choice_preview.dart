import 'package:flutter/material.dart';

const _foundationChoiceBackground = Color(0xFF02050A);
const _foundationChoicePanel = Color(0xFF07101A);
const _foundationChoiceCyan = Color(0xFF5DDCFF);
const _foundationChoiceMint = Color(0xFF9FF7D5);
const _foundationChoiceViolet = Color(0xFFB36BFF);
const _foundationChoiceGold = Color(0xFFFFD980);

class FoundationChoicePreview extends StatefulWidget {
  const FoundationChoicePreview({super.key});

  @override
  State<FoundationChoicePreview> createState() =>
      _FoundationChoicePreviewState();
}

class _FoundationChoicePreviewState extends State<FoundationChoicePreview> {
  _FoundationChoiceId? _selectedChoice;
  _FoundationChoicePreviewResult _result =
      _FoundationChoicePreviewResult.waiting;

  static const _choices = [
    _FoundationChoiceOption(
      id: _FoundationChoiceId.homeEveryday,
      title: 'Zuhause / Alltag',
      shortText: 'Wörter aus deinem echten Alltag.',
      examples: 'Küche, Stuhl, Familie',
      guardrail: 'Kein Pflicht-Hausstart.',
      icon: Icons.weekend_rounded,
      accent: _foundationChoiceMint,
    ),
    _FoundationChoiceOption(
      id: _FoundationChoiceId.schoolLearning,
      title: 'Schule / Lernen',
      shortText: 'Wörter fürs Verstehen und Üben.',
      examples: 'Buch, Frage, Pause',
      guardrail: 'Kein Testmodus.',
      icon: Icons.menu_book_rounded,
      accent: _foundationChoiceCyan,
    ),
    _FoundationChoiceOption(
      id: _FoundationChoiceId.gardenNature,
      title: 'Garten / Natur nah',
      shortText: 'Wörter aus Natur und draußen.',
      examples: 'Blatt, Regen, Samen',
      guardrail: 'Kein Timer-Druck.',
      icon: Icons.yard_rounded,
      accent: _foundationChoiceGold,
    ),
  ];

  void _selectChoice(_FoundationChoiceId choice) {
    setState(() {
      _selectedChoice = choice;
      _result = _FoundationChoicePreviewResult.waiting;
    });
  }

  void _confirmChoice() {
    if (_selectedChoice == null) return;
    setState(() {
      _result = _FoundationChoicePreviewResult.confirmedLocally;
    });
  }

  void _decideLater() {
    setState(() {
      _selectedChoice = null;
      _result = _FoundationChoicePreviewResult.decideLater;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('foundation-choice-preview'),
      color: _foundationChoiceBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PreviewStatusBanner(),
                  const SizedBox(height: 14),
                  const _TaliVoriIntroCard(),
                  const SizedBox(height: 14),
                  for (final choice in _choices) ...[
                    _FoundationChoiceCard(
                      option: choice,
                      selected: _selectedChoice == choice.id,
                      onTap: () => _selectChoice(choice.id),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 4),
                  _FoundationChoiceActions(
                    hasSelection: _selectedChoice != null,
                    onConfirm: _confirmChoice,
                    onDecideLater: _decideLater,
                  ),
                  const SizedBox(height: 12),
                  _FoundationChoiceResultPanel(result: _result),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewStatusBanner extends StatelessWidget {
  const _PreviewStatusBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Lokale Preview. Kein echtes Onboarding. Es wird nichts gespeichert.',
      child: Container(
        key: const Key('foundation-choice-preview-status'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _foundationChoiceViolet.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _foundationChoiceViolet.withValues(alpha: 0.42),
          ),
        ),
        child: const Text(
          'Lokale Preview / kein echtes Onboarding / nichts wird gespeichert',
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

class _TaliVoriIntroCard extends StatelessWidget {
  const _TaliVoriIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('foundation-choice-tali-vori-intro'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        color: _foundationChoicePanel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _foundationChoiceCyan.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _foundationChoiceCyan.withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _foundationChoiceCyan.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _foundationChoiceCyan.withValues(alpha: 0.42),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: _foundationChoiceCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tali/Vori Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Wähle einen ersten Lernfokus. Du entscheidest ruhig und kannst später wechseln.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontSize: 14,
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

class _FoundationChoiceCard extends StatelessWidget {
  const _FoundationChoiceCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _FoundationChoiceOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? option.accent
        : Colors.white.withValues(alpha: 0.14);
    final background = selected
        ? option.accent.withValues(alpha: 0.14)
        : _foundationChoicePanel.withValues(alpha: 0.84);

    return Semantics(
      button: true,
      selected: selected,
      label: '${option.title}. ${option.shortText} ${option.guardrail}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('foundation-choice-card-${option.id.keyName}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: selected ? 2 : 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: option.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: option.accent.withValues(alpha: 0.36),
                    ),
                  ),
                  child: Icon(option.icon, color: option.accent, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              option.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: option.accent,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        option.shortText,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _ChoiceChiplet(
                            text: option.examples,
                            color: option.accent,
                          ),
                          _ChoiceChiplet(
                            text: option.guardrail,
                            color: _foundationChoiceViolet,
                          ),
                        ],
                      ),
                    ],
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

class _ChoiceChiplet extends StatelessWidget {
  const _ChoiceChiplet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.78),
          fontSize: 11,
          height: 1.15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _FoundationChoiceActions extends StatelessWidget {
  const _FoundationChoiceActions({
    required this.hasSelection,
    required this.onConfirm,
    required this.onDecideLater,
  });

  final bool hasSelection;
  final VoidCallback onConfirm;
  final VoidCallback onDecideLater;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const Key('foundation-choice-confirm-local-preview'),
          onPressed: hasSelection ? onConfirm : null,
          style: FilledButton.styleFrom(
            backgroundColor: _foundationChoiceCyan,
            foregroundColor: _foundationChoiceBackground,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.42),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          icon: const Icon(Icons.check_rounded),
          label: const Text(
            'Lernfokus lokal anzeigen',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('foundation-choice-decide-later'),
          onPressed: onDecideLater,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: 0.86),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Später entscheiden',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Später änderbar. Keine Startinsel. Keine Speicherung.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.56),
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _FoundationChoiceResultPanel extends StatelessWidget {
  const _FoundationChoiceResultPanel({required this.result});

  final _FoundationChoicePreviewResult result;

  @override
  Widget build(BuildContext context) {
    final text = switch (result) {
      _FoundationChoicePreviewResult.waiting =>
        'Wähle eine Karte. Diese Preview speichert nichts.',
      _FoundationChoicePreviewResult.confirmedLocally =>
        'Lokaler Preview-Status gesetzt. Kein Onboarding, keine Datenbank.',
      _FoundationChoicePreviewResult.decideLater =>
        'Später entscheiden ist sicher. Es geht nichts verloren.',
    };

    return Container(
      key: const Key('foundation-choice-result-panel'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: _foundationChoiceMint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _foundationChoiceMint.withValues(alpha: 0.26),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

enum _FoundationChoiceId {
  homeEveryday('home-everyday'),
  schoolLearning('school-learning'),
  gardenNature('garden-nature');

  const _FoundationChoiceId(this.keyName);

  final String keyName;
}

enum _FoundationChoicePreviewResult { waiting, confirmedLocally, decideLater }

class _FoundationChoiceOption {
  const _FoundationChoiceOption({
    required this.id,
    required this.title,
    required this.shortText,
    required this.examples,
    required this.guardrail,
    required this.icon,
    required this.accent,
  });

  final _FoundationChoiceId id;
  final String title;
  final String shortText;
  final String examples;
  final String guardrail;
  final IconData icon;
  final Color accent;
}
