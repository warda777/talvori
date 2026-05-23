import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/features/onboarding/application/onboarding_settings_provider.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(hasCompletedOnboardingProvider);
    return completed.when(
      data: (hasCompleted) {
        if (hasCompleted) {
          return child;
        }
        return OnboardingFlowScreen(
          onComplete: () => ref.invalidate(hasCompletedOnboardingProvider),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: _OnboardingStyle.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => OnboardingFlowScreen(
        onComplete: () => ref.invalidate(hasCompletedOnboardingProvider),
      ),
    );
  }
}

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key, this.onComplete});

  final VoidCallback? onComplete;

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final _pageController = PageController();
  final Set<String> _knownWords = {};
  final Set<String> _topicInterests = {};
  final Set<String> _motivations = {};
  String? _referralSource;
  String? _weeklyGoal;
  String? _uncertaintyArea;
  String? _selfAssessment;
  int _currentPage = 0;

  static const _introPages = [
    _IntroContent(
      icon: Icons.auto_stories_rounded,
      title: 'Erweitere dein Vokabular',
      body:
          'Talvori begleitet dich mit Wortwelten, Wiederholungen und kurzen Übungen durch deinen Alltag.',
    ),
    _IntroContent(
      icon: Icons.tune_rounded,
      title: 'Passe die App an',
      body:
          'Wähle später Wortquellen, Stimmen und Erinnerungen so, dass Lernen zu deinem Tag passt.',
    ),
    _IntroContent(
      icon: Icons.notifications_active_rounded,
      title: 'Wörter über den Tag',
      body:
          'Erhalte kleine Impulse und bleib in Kontakt mit deinem Wortschatz, ohne lange Sessions planen zu müssen.',
    ),
    _IntroContent(
      icon: Icons.widgets_rounded,
      title: 'Bereit für Widgets',
      body:
          'Home- und Sperrbildschirm-Widgets sind vorbereitet, damit Wörter später noch näher an deinem Alltag sind.',
    ),
    _IntroContent(
      icon: Icons.flag_rounded,
      title: 'Lerne mit Ziel',
      body:
          'Lege Vokabeln fest, die dir wirklich helfen: für Reisen, Beruf, Schule oder deine eigenen Themen.',
    ),
  ];

  static const _beginnerWords = [
    'house',
    'water',
    'friend',
    'school',
    'morning',
    'food',
  ];
  static const _intermediateWords = [
    'journey',
    'choice',
    'improve',
    'confidence',
    'support',
    'purpose',
  ];
  static const _expertWords = [
    'resilient',
    'ambiguous',
    'elaborate',
    'reluctant',
    'sustainable',
    'perception',
  ];

  static const _referralOptions = [
    'Facebook',
    'Instagram',
    'Websuche',
    'TikTok',
    'App Store',
    'Freund/Familie',
    'Andere',
  ];
  static const _topicOptions = [
    'Gesellschaft',
    'Menschlicher Körper',
    'Geschäftlich',
    'Emotionen',
    'Wörter in Fremdsprachen',
    'Andere',
  ];
  static const _motivationOptions = [
    'Mehr wissen als andere',
    'Ich lerne ein Leben lang',
    'Andere Menschen beeindrucken',
    'Aus meiner Blase ausbrechen',
    'Andere Gründe',
  ];
  static const _weeklyGoalOptions = [
    '10 Wörter pro Woche',
    '30 Wörter pro Woche',
    '50 Wörter pro Woche',
  ];
  static const _uncertaintyOptions = [
    'Beim Lesen',
    'In der Schule',
    'Bei der Arbeit',
    'In Gesprächen mit anderen',
    'Beim Schreiben',
    'Ich fühle mich immer sicher',
  ];
  static const _selfAssessmentOptions = [
    'Anfänger',
    'Mittleres Niveau',
    'Fortgeschritten',
  ];

  int get _questionCount => 6;
  int get _placementIntroIndex => _introPages.length + _questionCount;
  int get _resultPageIndex => _totalPages - 1;
  int get _totalPages => _introPages.length + _questionCount + 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    await ref.read(onboardingStateServiceProvider).skip();
    widget.onComplete?.call();
  }

  Future<void> _finish() async {
    await ref
        .read(onboardingStateServiceProvider)
        .complete(
          placementLevel: _placementLevel,
          knownWords: _knownWords.length,
          referralSource: _referralSource ?? 'Nicht angegeben',
          topicInterests: _topicInterests.toList(growable: false),
          motivations: _motivations.toList(growable: false),
          weeklyGoal: _weeklyGoal ?? '10 Wörter pro Woche',
          uncertaintyArea: _uncertaintyArea ?? 'Nicht angegeben',
          selfAssessment: _selfAssessment ?? 'Nicht angegeben',
        );
    widget.onComplete?.call();
  }

  void _next() {
    if (!_canContinue) {
      return;
    }
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _finish();
  }

  String get _placementLevel {
    final count = _knownWords.length;
    if (count >= 11) {
      return 'Fortgeschritten';
    }
    if (count >= 6) {
      return 'Mittleres Niveau';
    }
    return 'Anfänger';
  }

  bool get _canContinue {
    final relativeQuestionIndex = _currentPage - _introPages.length;
    if (relativeQuestionIndex == 2) {
      return _motivations.isNotEmpty;
    }
    if (relativeQuestionIndex == 5) {
      return _selfAssessment != null;
    }
    return true;
  }

  String get _primaryLabel {
    if (_currentPage == _resultPageIndex) {
      return 'Los geht’s';
    }
    if (_currentPage == _placementIntroIndex - 1) {
      return 'Zur Einstufung';
    }
    return 'Weiter';
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _totalPages - 1;
    return Scaffold(
      backgroundColor: _OnboardingStyle.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _ProgressBar(
                      value: (_currentPage + 1) / _totalPages,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isLast)
                    TextButton(
                      key: const Key('onboarding-skip-button'),
                      onPressed: _skip,
                      child: const Text('Überspringen'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  for (final page in _introPages) _IntroPage(content: page),
                  _QuestionPage(
                    title: 'Wie hast du von Talvori erfahren?',
                    options: _referralOptions,
                    selectedValues: {
                      if (_referralSource != null) _referralSource!,
                    },
                    onToggle: (value) =>
                        setState(() => _referralSource = value),
                  ),
                  _QuestionPage(
                    title: 'Welche Themen interessieren dich?',
                    subtitle: 'Wähle eine oder mehrere Optionen aus.',
                    options: _topicOptions,
                    selectedValues: _topicInterests,
                    multiSelect: true,
                    onToggle: _toggleTopic,
                  ),
                  _QuestionPage(
                    title: 'Was treibt deine Neugier an?',
                    subtitle:
                        'Wähle mindestens eine Option aus, um fortzufahren.',
                    options: _motivationOptions,
                    selectedValues: _motivations,
                    multiSelect: true,
                    onToggle: _toggleMotivation,
                  ),
                  _QuestionPage(
                    title: 'Wie viele Wörter möchtest du pro Woche lernen?',
                    options: _weeklyGoalOptions,
                    selectedValues: {if (_weeklyGoal != null) _weeklyGoal!},
                    onToggle: (value) => setState(() => _weeklyGoal = value),
                  ),
                  _QuestionPage(
                    title:
                        'Wo fühlst du dich mit deinem Wortschatz am unsichersten?',
                    options: _uncertaintyOptions,
                    selectedValues: {
                      if (_uncertaintyArea != null) _uncertaintyArea!,
                    },
                    onToggle: (value) =>
                        setState(() => _uncertaintyArea = value),
                  ),
                  _QuestionPage(
                    title: 'Wie groß ist dein Wortschatz?',
                    subtitle: 'Wähle eine Option aus, um fortzufahren.',
                    options: _selfAssessmentOptions,
                    selectedValues: {
                      if (_selfAssessment != null) _selfAssessment!,
                    },
                    onToggle: (value) =>
                        setState(() => _selfAssessment = value),
                  ),
                  const _PlacementIntroPage(),
                  _WordSelectionPage(
                    title: 'Anfängerwörter',
                    words: _beginnerWords,
                    selectedWords: _knownWords,
                    onToggle: _toggleWord,
                  ),
                  _WordSelectionPage(
                    title: 'Mittelstufenwörter',
                    words: _intermediateWords,
                    selectedWords: _knownWords,
                    onToggle: _toggleWord,
                  ),
                  _WordSelectionPage(
                    title: 'Expertenwörter',
                    words: _expertWords,
                    selectedWords: _knownWords,
                    onToggle: _toggleWord,
                  ),
                  _ResultPage(level: _placementLevel),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
              child: _PrimaryButton(
                label: _primaryLabel,
                enabled: _canContinue,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleWord(String word) {
    setState(() {
      if (_knownWords.contains(word)) {
        _knownWords.remove(word);
      } else {
        _knownWords.add(word);
      }
    });
  }

  void _toggleTopic(String value) {
    setState(() {
      if (_topicInterests.contains(value)) {
        _topicInterests.remove(value);
      } else {
        _topicInterests.add(value);
      }
    });
  }

  void _toggleMotivation(String value) {
    setState(() {
      if (_motivations.contains(value)) {
        _motivations.remove(value);
      } else {
        _motivations.add(value);
      }
    });
  }
}

class _OnboardingStyle {
  const _OnboardingStyle._();

  static const background = Color(0xFF05070D);
  static const panel = Color(0xFF08131B);
  static const cyan = Color(0xFF78E6FF);
  static const mint = Color(0xFF7DFFE3);
  static const violet = Color(0xFFB37CFF);
  static const muted = Color(0xFF93A2B8);
}

class _IntroContent {
  const _IntroContent({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.content});

  final _IntroContent content;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
      children: [
        const SizedBox(height: 46),
        _HeroIcon(icon: content.icon),
        const SizedBox(height: 40),
        Text(
          content.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.08,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          content.body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _OnboardingStyle.muted,
            fontSize: 16,
            height: 1.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlacementIntroPage extends StatelessWidget {
  const _PlacementIntroPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
      children: const [
        SizedBox(height: 58),
        _HeroIcon(icon: Icons.psychology_alt_rounded),
        SizedBox(height: 42),
        Text(
          'Lass uns testen, wie viele Wörter du kennst',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.08,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Wähle gleich einfach alle Wörter aus, die dir bekannt vorkommen. Das ist nur eine grobe erste Einschätzung.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _OnboardingStyle.muted,
            fontSize: 16,
            height: 1.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WordSelectionPage extends StatelessWidget {
  const _WordSelectionPage({
    required this.title,
    required this.words,
    required this.selectedWords,
    required this.onToggle,
  });

  final String title;
  final List<String> words;
  final Set<String> selectedWords;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Wähle alle aus, die du kennst.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _OnboardingStyle.muted,
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 28),
        for (final word in words) ...[
          _WordChoiceCard(
            word: word,
            selected: selectedWords.contains(word),
            onTap: () => onToggle(word),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onToggle,
    this.subtitle,
    this.multiSelect = false,
  });

  final String title;
  final String? subtitle;
  final List<String> options;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      children: [
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.12,
            letterSpacing: 0,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _OnboardingStyle.muted,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in options)
              _PreferenceChip(
                label: option,
                selected: selectedValues.contains(option),
                multiSelect: multiSelect,
                onTap: () => onToggle(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultPage extends StatelessWidget {
  const _ResultPage({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
      children: [
        const SizedBox(height: 52),
        const _HeroIcon(icon: Icons.waving_hand_rounded),
        const SizedBox(height: 38),
        const Text(
          'Willkommen bei Talvori',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.08,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Dein Startniveau wurde grob eingeschätzt: $level.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _OnboardingStyle.muted,
            fontSize: 16,
            height: 1.42,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Wir passen deine ersten Inhalte entsprechend an, ohne deinen Lernfortschritt zu verändern.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _OnboardingStyle.muted,
            fontSize: 15,
            height: 1.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _OnboardingStyle.cyan.withValues(alpha: 0.22),
              _OnboardingStyle.violet.withValues(alpha: 0.16),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: _OnboardingStyle.cyan.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: _OnboardingStyle.cyan.withValues(alpha: 0.16),
              blurRadius: 38,
              spreadRadius: -12,
            ),
          ],
        ),
        child: Icon(icon, color: _OnboardingStyle.mint, size: 74),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? _OnboardingStyle.mint : _OnboardingStyle.cyan;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.16)
                : _OnboardingStyle.panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : multiSelect
                    ? Icons.add_circle_outline_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? accent : Colors.white38,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordChoiceCard extends StatelessWidget {
  const _WordChoiceCard({
    required this.word,
    required this.selected,
    required this.onTap,
  });

  final String word;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? _OnboardingStyle.mint : _OnboardingStyle.cyan;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.16)
                : _OnboardingStyle.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? accent : Colors.white38,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: value,
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        valueColor: const AlwaysStoppedAnimation<Color>(_OnboardingStyle.cyan),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _OnboardingStyle.cyan,
          foregroundColor: _OnboardingStyle.background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(label),
      ),
    );
  }
}
