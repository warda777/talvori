import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

enum RewardsTab { leaderboard, rewards, stats }

class RewardsCenterScreen extends ConsumerStatefulWidget {
  const RewardsCenterScreen({
    super.key,
    this.initialTab = RewardsTab.leaderboard,
  });

  final RewardsTab initialTab;

  @override
  ConsumerState<RewardsCenterScreen> createState() =>
      _RewardsCenterScreenState();
}

class _RewardsCenterScreenState extends ConsumerState<RewardsCenterScreen> {
  static const _background = Color(0xFF05070D);
  static const _panel = Color(0xFF08131B);
  static const _panelSoft = Color(0xFF0C1823);
  static const _cyan = Color(0xFF78E6FF);
  static const _mint = Color(0xFF7DFFE3);
  static const _violet = Color(0xFFB37CFF);
  static const _gold = Color(0xFFFFD976);
  static const _rose = Color(0xFFFF7598);
  static const _muted = Color(0xFF93A2B8);

  late RewardsTab _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final allWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.allWords),
    );
    final myWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.myWords),
    );
    final favorites = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.favorites),
    );
    final knownWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.knownWords),
    );
    final snapshot = _ProgressSnapshot.from(
      allWords: allWords,
      myWords: myWords,
      favorites: favorites,
      knownWords: knownWords,
    );

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            _Header(onBack: () => Navigator.of(context).maybePop()),
            const SizedBox(height: 16),
            _WeeklyStatusCard(snapshot: snapshot),
            const SizedBox(height: 16),
            _SegmentedTabs(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: switch (_tab) {
                RewardsTab.leaderboard => _LeagueTab(
                  key: const ValueKey('league'),
                  snapshot: snapshot,
                ),
                RewardsTab.rewards => _RewardsTab(
                  key: const ValueKey('rewards'),
                  snapshot: snapshot,
                ),
                RewardsTab.stats => _StatsTab(
                  key: const ValueKey('stats'),
                  snapshot: snapshot,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSnapshot {
  const _ProgressSnapshot({
    required this.totalWords,
    required this.myWords,
    required this.favoriteWords,
    required this.knownWords,
    required this.pendingTranslations,
    required this.isLoading,
  });

  final int totalWords;
  final int myWords;
  final int favoriteWords;
  final int knownWords;
  final int pendingTranslations;
  final bool isLoading;

  int get localXp => knownWords * 25;

  int get nextLeagueXp {
    if (localXp < 250) return 250;
    if (localXp < 750) return 750;
    if (localXp < 1500) return 1500;
    if (localXp < 3000) return 3000;
    if (localXp < 5000) return 5000;
    return 5000;
  }

  int get previousLeagueXp {
    if (localXp < 250) return 0;
    if (localXp < 750) return 250;
    if (localXp < 1500) return 750;
    if (localXp < 3000) return 1500;
    if (localXp < 5000) return 3000;
    return 5000;
  }

  String get leagueName {
    if (localXp < 250) return 'Bronze';
    if (localXp < 750) return 'Silber';
    if (localXp < 1500) return 'Gold';
    if (localXp < 3000) return 'Diamant';
    if (localXp < 5000) return 'Neon';
    return 'Talvori Elite';
  }

  double get leagueProgress {
    final span = nextLeagueXp - previousLeagueXp;
    if (span <= 0) return 1;
    return ((localXp - previousLeagueXp) / span).clamp(0, 1);
  }

  static _ProgressSnapshot from({
    required AsyncValue<List<LocalWord>> allWords,
    required AsyncValue<List<LocalWord>> myWords,
    required AsyncValue<List<LocalWord>> favorites,
    required AsyncValue<List<LocalWord>> knownWords,
  }) {
    final all = allWords.valueOrNull ?? const <LocalWord>[];
    return _ProgressSnapshot(
      totalWords: all.length,
      myWords: myWords.valueOrNull?.length ?? 0,
      favoriteWords: favorites.valueOrNull?.length ?? 0,
      knownWords: knownWords.valueOrNull?.length ?? 0,
      pendingTranslations: all
          .where(
            (word) =>
                word.translationStatus == TranslationStatus.pending ||
                word.translationStatus == TranslationStatus.failed,
          )
          .length,
      isLoading:
          allWords.isLoading ||
          myWords.isLoading ||
          favorites.isLoading ||
          knownWords.isLoading,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _neonDecoration(_RewardsCenterScreenState._cyan),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Zurück',
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  _RewardsCenterScreenState._violet,
                  _RewardsCenterScreenState._cyan,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _RewardsCenterScreenState._violet.withValues(
                    alpha: 0.25,
                  ),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: _RewardsCenterScreenState._background,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fortschritt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Deine Woche in Talvori',
                  style: TextStyle(
                    color: _RewardsCenterScreenState._muted,
                    fontWeight: FontWeight.w600,
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

class _WeeklyStatusCard extends StatelessWidget {
  const _WeeklyStatusCard({required this.snapshot});

  final _ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _neonDecoration(_RewardsCenterScreenState._gold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Diese Woche',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _Pill(
                text: 'Reset montags',
                color: _RewardsCenterScreenState._gold,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.isLoading
                ? 'Lokale Lernpunkte werden geladen.'
                : '${snapshot.localXp} lokale Lernpunkte · Liga ${snapshot.leagueName}',
            style: const TextStyle(
              color: _RewardsCenterScreenState._muted,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: snapshot.leagueProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                _RewardsCenterScreenState._mint,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.localXp >= snapshot.nextLeagueXp
                ? 'Talvori Elite erreicht.'
                : '${snapshot.nextLeagueXp - snapshot.localXp} Punkte bis zur nächsten Stufe.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selected, required this.onChanged});

  final RewardsTab selected;
  final ValueChanged<RewardsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _RewardsCenterScreenState._panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Liga',
            icon: Icons.leaderboard_rounded,
            selected: selected == RewardsTab.leaderboard,
            onTap: () => onChanged(RewardsTab.leaderboard),
          ),
          _TabButton(
            label: 'Belohnungen',
            icon: Icons.workspace_premium_rounded,
            selected: selected == RewardsTab.rewards,
            onTap: () => onChanged(RewardsTab.rewards),
          ),
          _TabButton(
            label: 'Statistik',
            icon: Icons.bar_chart_rounded,
            selected: selected == RewardsTab.stats,
            onTap: () => onChanged(RewardsTab.stats),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? _RewardsCenterScreenState._mint
        : _RewardsCenterScreenState._muted;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
            decoration: BoxDecoration(
              color: selected
                  ? _RewardsCenterScreenState._mint.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? _RewardsCenterScreenState._mint.withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
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

class _LeagueTab extends StatelessWidget {
  const _LeagueTab({super.key, required this.snapshot});

  final _ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _TabPanel(
      children: [
        _SectionTitle(
          title: 'Wochenliga',
          subtitle: 'Neue Woche, neue Chance. Online-Ranking ist vorbereitet.',
        ),
        _LeagueRow(
          rank: '1',
          name: 'Du',
          points: '${snapshot.localXp} LP',
          color: _RewardsCenterScreenState._mint,
          note: 'lokal gezählt',
        ),
        const _LeagueRow(
          rank: '2',
          name: 'Online-Liga vorbereitet',
          points: '-',
          color: _RewardsCenterScreenState._violet,
          note: 'keine globalen Daten aktiv',
        ),
        const _LeagueRow(
          rank: '3',
          name: 'Wöchentlicher Reset',
          points: 'Mo',
          color: _RewardsCenterScreenState._gold,
          note: 'fairer Neustart',
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          icon: Icons.verified_user_rounded,
          title: 'Fairness-Regel',
          text:
              'Punkte sollen später nur aus echten Lernaktionen entstehen: richtige Antworten, abgeschlossene Sessions und wiederholte Wörter. Öffnen dieser Seite gibt keine Punkte.',
        ),
      ],
    );
  }
}

class _RewardsTab extends StatelessWidget {
  const _RewardsTab({super.key, required this.snapshot});

  final _ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final rewards = [
      _RewardBadge(
        title: 'Erste 10 Wörter',
        progress: snapshot.totalWords,
        target: 10,
        icon: Icons.library_books_rounded,
      ),
      _RewardBadge(
        title: 'Erste 50 Wörter',
        progress: snapshot.totalWords,
        target: 50,
        icon: Icons.auto_stories_rounded,
      ),
      _RewardBadge(
        title: 'Aussprache-Profi',
        progress: 0,
        target: 5,
        icon: Icons.volume_up_rounded,
        comingSoon: true,
      ),
      _RewardBadge(
        title: 'Übersetzungsmeister',
        progress: snapshot.totalWords - snapshot.pendingTranslations,
        target: 20,
        icon: Icons.translate_rounded,
      ),
      _RewardBadge(
        title: 'Kategorie-Champion',
        progress: snapshot.knownWords,
        target: 25,
        icon: Icons.emoji_events_rounded,
      ),
      _RewardBadge(
        title: 'Neon-Rahmen',
        progress: snapshot.localXp,
        target: 750,
        icon: Icons.crop_square_rounded,
      ),
    ];

    return _TabPanel(
      children: [
        const _SectionTitle(
          title: 'Belohnungen',
          subtitle: 'Badges und kosmetische Rewards, lokal vorbereitet.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 540 ? 3 : 2;
            final gap = 10.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final reward in rewards)
                  SizedBox(
                    width: width,
                    child: _RewardCard(reward: reward),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({super.key, required this.snapshot});

  final _ProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _TabPanel(
      children: [
        const _SectionTitle(
          title: 'Statistik',
          subtitle: 'Lokale Werte ohne Server-Ranking und ohne SRS-Schreiben.',
        ),
        _StatsGrid(
          stats: [
            _StatItem('Wörter insgesamt', '${snapshot.totalWords}'),
            _StatItem('Meine Wörter', '${snapshot.myWords}'),
            _StatItem('Favoriten', '${snapshot.favoriteWords}'),
            _StatItem('Bekannte Wörter', '${snapshot.knownWords}'),
            _StatItem(
              'Offene Übersetzungen',
              '${snapshot.pendingTranslations}',
            ),
            _StatItem('Lokale Lernpunkte', '${snapshot.localXp}'),
          ],
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          icon: Icons.timeline_rounded,
          title: 'Wochenverlauf',
          text:
              'Antworten, Lernzeit und Trefferquote werden als lokale Statistik vorbereitet. Noch nicht vorhandene Daten werden nicht erfunden.',
        ),
      ],
    );
  }
}

class _TabPanel extends StatelessWidget {
  const _TabPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _neonDecoration(_RewardsCenterScreenState._violet),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _RewardsCenterScreenState._muted,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueRow extends StatelessWidget {
  const _LeagueRow({
    required this.rank,
    required this.name,
    required this.points,
    required this.color,
    required this.note,
  });

  final String rank;
  final String name;
  final String points;
  final Color color;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _softCardDecoration(color),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.18),
            child: Text(
              rank,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: const TextStyle(
                    color: _RewardsCenterScreenState._muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            points,
            textAlign: TextAlign.right,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _RewardBadge {
  const _RewardBadge({
    required this.title,
    required this.progress,
    required this.target,
    required this.icon,
    this.comingSoon = false,
  });

  final String title;
  final int progress;
  final int target;
  final IconData icon;
  final bool comingSoon;

  bool get unlocked => !comingSoon && progress >= target;

  double get ratio => target <= 0 ? 0 : (progress / target).clamp(0, 1);
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.reward});

  final _RewardBadge reward;

  @override
  Widget build(BuildContext context) {
    final color = reward.unlocked
        ? _RewardsCenterScreenState._mint
        : reward.comingSoon
        ? _RewardsCenterScreenState._violet
        : _RewardsCenterScreenState._gold;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _softCardDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(reward.icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            reward.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: reward.ratio,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          Text(
            reward.comingSoon
                ? 'bald verfügbar'
                : reward.unlocked
                ? 'freigeschaltet'
                : '${reward.progress}/${reward.target}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_StatItem> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 520 ? 3 : 2;
        final gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final stat in stats) SizedBox(width: width, child: stat),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _softCardDecoration(_RewardsCenterScreenState._cyan),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _RewardsCenterScreenState._muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _RewardsCenterScreenState._cyan,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _softCardDecoration(_RewardsCenterScreenState._rose),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _RewardsCenterScreenState._rose),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: _RewardsCenterScreenState._muted,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

BoxDecoration _neonDecoration(Color color) {
  return BoxDecoration(
    color: _RewardsCenterScreenState._panel.withValues(alpha: 0.96),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: color.withValues(alpha: 0.32)),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.24),
        blurRadius: 26,
        spreadRadius: -14,
      ),
    ],
  );
}

BoxDecoration _softCardDecoration(Color color) {
  return BoxDecoration(
    color: _RewardsCenterScreenState._panelSoft,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color.withValues(alpha: 0.28)),
  );
}
