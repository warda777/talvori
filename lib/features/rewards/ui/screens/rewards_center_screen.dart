import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/application/word_game_rewards_controller.dart';

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
    final wordGameRewards = ref.watch(wordGameRewardsSnapshotProvider);
    final snapshot = _ProgressSnapshot.from(
      allWords: allWords,
      myWords: myWords,
      favorites: favorites,
      knownWords: knownWords,
      rewards: wordGameRewards.valueOrNull ?? WordGameRewardsSnapshot.empty(),
      rewardsLoading: wordGameRewards.isLoading,
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
    required this.rewards,
    required this.isLoading,
  });

  final int totalWords;
  final int myWords;
  final int favoriteWords;
  final int knownWords;
  final int pendingTranslations;
  final WordGameRewardsSnapshot rewards;
  final bool isLoading;

  int get localXp => rewards.totalTalers;

  int get nextLeagueXp {
    if (localXp < 500) return 500;
    if (localXp < 1500) return 1500;
    if (localXp < 3000) return 3000;
    return 3000;
  }

  int get previousLeagueXp {
    if (localXp < 500) return 0;
    if (localXp < 1500) return 500;
    if (localXp < 3000) return 1500;
    return 3000;
  }

  String get leagueName {
    if (localXp < 500) return 'Bronze';
    if (localXp < 1500) return 'Silber';
    if (localXp < 3000) return 'Gold';
    return 'Diamant';
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
    required WordGameRewardsSnapshot rewards,
    required bool rewardsLoading,
  }) {
    final all = allWords.valueOrNull ?? const <LocalWord>[];
    return _ProgressSnapshot(
      totalWords: all.length,
      myWords: myWords.valueOrNull?.length ?? 0,
      favoriteWords: favorites.valueOrNull?.length ?? 0,
      knownWords: knownWords.valueOrNull?.length ?? 0,
      rewards: rewards,
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
          knownWords.isLoading ||
          rewardsLoading,
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
                ? 'Lokale Taler werden geladen.'
                : '${snapshot.rewards.talersThisWeek()} Wochentaler · Lokale Wochenliga ${snapshot.leagueName}',
            style: const TextStyle(
              color: _RewardsCenterScreenState._muted,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          _WeekSeriesRow(snapshot: snapshot.rewards),
          const SizedBox(height: 10),
          Text(
            'Serie: ${snapshot.rewards.currentStreak} Tage · Beste Serie: ${snapshot.rewards.bestStreak} Tage',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
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
                ? 'Diamant erreicht.'
                : '${snapshot.nextLeagueXp - snapshot.localXp} Taler bis zur nächsten Liga.',
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

class _WeekSeriesRow extends StatelessWidget {
  const _WeekSeriesRow({required this.snapshot});

  final WordGameRewardsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final days = const ['Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.', 'So.'];
    final active = snapshot.activeWeekDays();
    final todayIndex = DateTime.now().weekday - 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < days.length; i += 1)
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active[i]
                        ? _RewardsCenterScreenState._mint.withValues(
                            alpha: 0.18,
                          )
                        : Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: i == todayIndex
                          ? _RewardsCenterScreenState._gold
                          : active[i]
                          ? _RewardsCenterScreenState._mint
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    active[i] ? Icons.check_rounded : Icons.circle_outlined,
                    size: 18,
                    color: active[i]
                        ? _RewardsCenterScreenState._mint
                        : _RewardsCenterScreenState._muted,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  days[i],
                  maxLines: 1,
                  style: const TextStyle(
                    color: _RewardsCenterScreenState._muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
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
          title: 'Lokale Wochenliga',
          subtitle: 'Nur deine lokalen Wortspiel-Taler. Kein Online-Ranking.',
        ),
        _LeagueRow(
          rank: 'Du',
          name: snapshot.leagueName,
          points: '${snapshot.rewards.talersThisWeek()} Taler',
          color: _RewardsCenterScreenState._mint,
          note: 'diese Woche',
        ),
        _LeagueRow(
          rank: '→',
          name: 'Nächste Liga',
          points: snapshot.localXp >= snapshot.nextLeagueXp
              ? 'erreicht'
              : '${snapshot.nextLeagueXp - snapshot.localXp} fehlen',
          color: _RewardsCenterScreenState._gold,
          note: 'Bronze · Silber · Gold · Diamant',
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          icon: Icons.verified_user_rounded,
          title: 'Offline-first',
          text:
              'Die Liga ist lokal vorbereitet. Talvori erfindet keine fremden Nutzer und zeigt kein Fake-Leaderboard.',
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
        title: 'Erste Runde',
        progress: snapshot.rewards.totalRounds,
        target: 1,
        icon: Icons.play_circle_rounded,
      ),
      _RewardBadge(
        title: '100 Taler',
        progress: snapshot.rewards.totalTalers,
        target: 100,
        icon: Icons.toll_rounded,
      ),
      _RewardBadge(
        title: '1.000 Taler',
        progress: snapshot.rewards.totalTalers,
        target: 1000,
        icon: Icons.savings_rounded,
      ),
      _RewardBadge(
        title: 'Serien-Starter',
        progress: snapshot.rewards.bestStreak,
        target: 3,
        icon: Icons.local_fire_department_rounded,
      ),
      _RewardBadge(
        title: 'Wochenheld',
        progress: snapshot.rewards.bestStreak,
        target: 7,
        icon: Icons.emoji_events_rounded,
      ),
      _RewardBadge(
        title: 'Perfekte Runde',
        progress: snapshot.rewards.earnedBadgeIds.contains('perfect_round')
            ? 1
            : 0,
        target: 1,
        icon: Icons.diamond_rounded,
      ),
      _RewardBadge(
        title: 'Wortjäger',
        progress: _gameCorrect(snapshot, const {
          wordGameIdWordHunt,
          wordGameIdAudioCatch,
          wordGameIdSyllableRain,
        }),
        target: 50,
        icon: Icons.track_changes_rounded,
      ),
      _RewardBadge(
        title: 'Puzzle-Profi',
        progress: _gameCorrect(snapshot, const {
          wordGameIdWordPuzzle,
          wordGameIdWordPath,
          wordGameIdWordSearch,
        }),
        target: 50,
        icon: Icons.extension_rounded,
      ),
      _RewardBadge(
        title: 'KI-Entdecker',
        progress: _gameRounds(snapshot, const {
          wordGameIdContextChallenge,
          wordGameIdOppositeWord,
          wordGameIdSynonymRiddle,
        }),
        target: 5,
        icon: Icons.auto_awesome_rounded,
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
            _StatItem('Gesamt-Taler', '${snapshot.rewards.totalTalers}'),
            _StatItem('Gespielte Runden', '${snapshot.rewards.totalRounds}'),
            _StatItem('Richtig gelöst', '${snapshot.rewards.totalCorrect}'),
            _StatItem('Fehler', '${snapshot.rewards.totalWrong}'),
            _StatItem('Verpasst', '${snapshot.rewards.totalMissed}'),
            _StatItem('Beste Runde', '+${snapshot.rewards.bestRoundTalers}'),
            _StatItem(
              'Heute verdient',
              '${snapshot.rewards.talersForDate(DateTime.now())}',
            ),
            _StatItem('Diese Woche', '${snapshot.rewards.talersThisWeek()}'),
            _StatItem('Meistgespielt', snapshot.rewards.mostPlayedGameId),
          ],
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          icon: Icons.timeline_rounded,
          title: 'Getrennt vom Lernen',
          text:
              'Diese Statistik zählt nur abgeschlossene Wortspielrunden. SRS-Fortschritt, Review-Stufen und Lernstatus bleiben unverändert.',
        ),
      ],
    );
  }
}

int _gameCorrect(_ProgressSnapshot snapshot, Set<String> gameIds) {
  return snapshot.rewards.roundsByGame.values
      .where((stats) => gameIds.contains(stats.gameId))
      .fold(0, (sum, stats) => sum + stats.correct);
}

int _gameRounds(_ProgressSnapshot snapshot, Set<String> gameIds) {
  return snapshot.rewards.roundsByGame.values
      .where((stats) => gameIds.contains(stats.gameId))
      .fold(0, (sum, stats) => sum + stats.rounds);
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
  });

  final String title;
  final int progress;
  final int target;
  final IconData icon;

  bool get unlocked => progress >= target;

  double get ratio => target <= 0 ? 0 : (progress / target).clamp(0, 1);
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.reward});

  final _RewardBadge reward;

  @override
  Widget build(BuildContext context) {
    final color = reward.unlocked
        ? _RewardsCenterScreenState._mint
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
            reward.unlocked
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
