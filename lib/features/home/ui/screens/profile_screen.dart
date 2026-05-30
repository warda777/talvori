import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';
import 'package:talvori/features/favorites/ui/local_favorites_list_screen.dart';
import 'package:talvori/features/home/application/word_game_rewards_controller.dart';
import 'package:talvori/features/home/ui/screens/settings_screen.dart';
import 'package:talvori/features/home/ui/screens/vocabulary_level_test_screen.dart';
import 'package:talvori/features/rewards/ui/screens/rewards_center_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _background = Color(0xFF05070D);
  static const _panel = Color(0xFF08131B);
  static const _panelSoft = Color(0xFF0C1823);
  static const _cyan = Color(0xFF78E6FF);
  static const _mint = Color(0xFF7DFFE3);
  static const _violet = Color(0xFFB37CFF);
  static const _gold = Color(0xFFFFD976);
  static const _rose = Color(0xFFFF7598);
  static const _muted = Color(0xFF93A2B8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(wordGameRewardsSnapshotProvider);
    final rewards = rewardsAsync.valueOrNull ?? WordGameRewardsSnapshot.empty();
    final myWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.myWords),
    );
    final favoriteWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.favorites),
    );

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 18),
            _PremiumCard(
              onTap: () => _openPreparedScreen(
                context,
                title: 'Abonnement verwalten',
                icon: Icons.workspace_premium_rounded,
                accent: _gold,
                body:
                    'Premium wird als Erweiterung für zusätzliche KI-Spiele, Wortwelten und tiefere Statistiken vorbereitet. Der aktuelle MVP bleibt ohne Abo nutzbar.',
                actionLabel: 'Premium-Plan ansehen',
              ),
            ),
            const SizedBox(height: 16),
            _LevelTestCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const VocabularyLevelTestScreen(),
                ),
              ),
            ),
            const SizedBox(height: 22),
            _ProfileSection(
              title: 'Dein Fortschritt',
              children: [
                _ProfileQuickCard(
                  icon: Icons.paid_rounded,
                  title: 'Taler',
                  value: '${rewards.totalTalers}',
                  accent: _gold,
                  onTap: () => _openRewards(context),
                ),
                _ProfileQuickCard(
                  icon: Icons.local_fire_department_rounded,
                  title: 'Wochenserie',
                  value: '${rewards.currentStreak} Tage',
                  accent: _rose,
                  onTap: () => _openRewards(context),
                ),
                _ProfileQuickCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Belohnungen',
                  value: '${rewards.earnedBadgeIds.length} aktiv',
                  accent: _mint,
                  onTap: () => _openRewards(context, RewardsTab.rewards),
                ),
                _ProfileQuickCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Statistik',
                  value: '${rewards.totalRounds} Runden',
                  accent: _cyan,
                  onTap: () => _openRewards(context, RewardsTab.stats),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _ProfileSection(
              title: 'Dein Wortschatz',
              children: [
                _ProfileQuickCard(
                  icon: Icons.favorite_rounded,
                  title: 'Favoriten',
                  value: _countLabel(favoriteWords),
                  accent: _rose,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LocalFavoritesListScreen(),
                    ),
                  ),
                ),
                _ProfileQuickCard(
                  icon: Icons.edit_note_rounded,
                  title: 'Meine Wörter',
                  value: _countLabel(myWords),
                  accent: _mint,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LocalWordListScreen(
                        categoryId: LocalLearningSource.myWords.id,
                        title: 'Meine Wörter',
                      ),
                    ),
                  ),
                ),
                _ProfileQuickCard(
                  icon: Icons.folder_rounded,
                  title: 'Sammlungen',
                  value: 'vorbereitet',
                  accent: _violet,
                  onTap: () => _openPreparedScreen(
                    context,
                    title: 'Sammlungen',
                    icon: Icons.folder_rounded,
                    accent: _violet,
                    body:
                        'Sammlungen bündeln künftig eigene Wortgruppen und gespeicherte Themen. Bis dahin findest du deine aktiven Listen unter Favoriten, Meine Wörter und Wortwelten.',
                  ),
                ),
                _ProfileQuickCard(
                  icon: Icons.history_rounded,
                  title: 'Verlauf',
                  value: 'vorbereitet',
                  accent: _cyan,
                  onTap: () => _openPreparedScreen(
                    context,
                    title: 'Verlauf',
                    icon: Icons.history_rounded,
                    accent: _cyan,
                    body:
                        'Der Verlauf wird als lesbare Chronik vorbereitet. Dein SRS-Fortschritt und deine Wortspiel-Belohnungen bleiben schon jetzt getrennt gespeichert.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _ProfileSection(
              title: 'App anpassen',
              children: [
                _ProfileQuickCard(
                  icon: Icons.travel_explore_rounded,
                  title: 'Wortwelten',
                  value: 'entdecken',
                  accent: _mint,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const WordHubScreen(useLocalOfflineFlow: true),
                    ),
                  ),
                ),
                _ProfileQuickCard(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Stimmen',
                  value: 'vorbereitet',
                  accent: _cyan,
                  onTap: () => _openPreparedScreen(
                    context,
                    title: 'Stimmen',
                    icon: Icons.record_voice_over_rounded,
                    accent: _cyan,
                    body:
                        'Stimmen werden als eigener Einstellungsbereich vorbereitet. Aussprache nutzt bereits die vorhandene Sprachlogik der Lernkarten.',
                  ),
                ),
                _ProfileQuickCard(
                  icon: Icons.notifications_active_rounded,
                  title: 'Erinnerungen',
                  value: 'öffnen',
                  accent: _gold,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReminderSettingsScreen(),
                    ),
                  ),
                ),
                _ProfileQuickCard(
                  icon: Icons.widgets_rounded,
                  title: 'Widgets',
                  value: 'Info',
                  accent: _violet,
                  onTap: () => _openPreparedScreen(
                    context,
                    title: 'Widgets',
                    icon: Icons.widgets_rounded,
                    accent: _violet,
                    body:
                        'Widgets sind als späterer Schnellzugriff auf Wörter und Tagesimpulse geplant. Sobald die Integration stabil ist, erscheint hier die Einrichtung.',
                    actionLabel: 'Verstanden',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _ProfileSection(
              title: 'Hilfe & Konto',
              children: [
                _ProfileQuickCard(
                  icon: Icons.help_outline_rounded,
                  title: 'Hilfe',
                  value: 'Kontakt',
                  accent: _mint,
                  onTap: () => _openPreparedScreen(
                    context,
                    title: 'Hilfe',
                    icon: Icons.help_outline_rounded,
                    accent: _mint,
                    body:
                        'Hilfe und Feedback werden hier gebündelt. Für den MVP bleibt das Profil ruhig und trennt Support klar von technischen Einstellungen.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _countLabel<T>(AsyncValue<List<T>> value) {
    return value.when(
      data: (items) => '${items.length} Wörter',
      loading: () => 'lädt',
      error: (_, _) => '0 Wörter',
    );
  }

  static void _openRewards(
    BuildContext context, [
    RewardsTab tab = RewardsTab.leaderboard,
  ]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RewardsCenterScreen(initialTab: tab),
      ),
    );
  }

  static void _openPreparedScreen(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accent,
    required String body,
    String? actionLabel,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PreparedProfileScreen(
          title: title,
          icon: icon,
          accent: accent,
          body: body,
          actionLabel: actionLabel,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _RoundHeaderButton(
            key: const Key('profile-close-button'),
            tooltip: 'Schließen',
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        const Text(
          'Profil',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _RoundHeaderButton(
            key: const Key('profile-settings-button'),
            tooltip: 'Einstellungen',
            icon: Icons.settings_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundHeaderButton extends StatelessWidget {
  const _RoundHeaderButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ProfileScreen._panelSoft.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: ProfileScreen._cyan.withValues(alpha: 0.1),
                blurRadius: 18,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _LevelTestCard extends StatelessWidget {
  const _LevelTestCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ProfileScreen._panel.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ProfileScreen._mint.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: ProfileScreen._mint.withValues(alpha: 0.1),
                blurRadius: 22,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: ProfileScreen._mint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ProfileScreen._mint.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: ProfileScreen._mint,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mach einen Test',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Einstufung wird vorbereitet',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ProfileScreen._muted,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ProfileScreen._cyan.withValues(alpha: 0.28),
                ProfileScreen._violet.withValues(alpha: 0.18),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: ProfileScreen._cyan.withValues(alpha: 0.36),
            ),
            boxShadow: [
              BoxShadow(
                color: ProfileScreen._cyan.withValues(alpha: 0.14),
                blurRadius: 26,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ProfileScreen._gold.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ProfileScreen._gold.withValues(alpha: 0.32),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: ProfileScreen._gold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium-Erweiterung',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Geplant für KI-Spiele, zusätzliche Wortwelten und erweiterte Statistiken.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ProfileScreen._muted,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final itemWidth = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final child in children)
                  SizedBox(width: itemWidth, height: 126, child: child),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProfileQuickCard extends StatelessWidget {
  const _ProfileQuickCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ProfileScreen._panel.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.11),
                blurRadius: 20,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withValues(alpha: 0.28)),
                    ),
                    child: Icon(icon, color: accent, size: 22),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white38,
                    size: 23,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ProfileScreen._muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreparedProfileScreen extends StatelessWidget {
  const _PreparedProfileScreen({
    required this.title,
    required this.icon,
    required this.accent,
    required this.body,
    this.actionLabel,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String body;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileScreen._background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _RoundHeaderButton(
                    tooltip: 'Zurück',
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: ProfileScreen._panel,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 26,
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: accent, size: 42),
                  const SizedBox(height: 18),
                  Text(
                    body,
                    style: const TextStyle(
                      color: ProfileScreen._muted,
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 26),
              _ProfilePrimaryButton(
                label: actionLabel!,
                onTap: () => TalvoriSnackBar.show(
                  context,
                  message: 'Dieser Bereich ist für den Marktstart vorbereitet.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfilePrimaryButton extends StatelessWidget {
  const _ProfilePrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: ProfileScreen._cyan,
          foregroundColor: ProfileScreen._background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
