import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_provider.dart';
import 'package:talvori/features/home/application/profile_preferences_controller.dart';
import 'package:talvori/features/home/providers.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_settings.dart';
import 'package:talvori/features/words/application/primary_language_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _background = Color(0xFF05070D);
  static const _panel = Color(0xFF08131B);
  static const _panelSoft = Color(0xFF0C1823);
  static const _cyan = Color(0xFF78E6FF);
  static const _mint = Color(0xFF7DFFE3);
  static const _violet = Color(0xFFB37CFF);
  static const _gold = Color(0xFFFFD976);
  static const _muted = Color(0xFF93A2B8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final preferences = ref.watch(profilePreferencesControllerProvider);
    final preferenceController = ref.read(
      profilePreferencesControllerProvider.notifier,
    );
    final primaryLanguage = ref.watch(primaryLanguageProvider);
    final impulseProfile = ref.watch(impulseInboxControllerProvider).aiProfile;
    final tagesimpulsSettings = ref.watch(
      tagesimpulsNotificationSettingsControllerProvider,
    );
    final myWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.myWords),
    );
    final allWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.allWords),
    );
    final knownWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.knownWords),
    );
    final favoriteWords = ref.watch(
      localWordsForSourceProvider(LocalLearningSource.favorites),
    );

    final pendingTranslations = allWords.whenOrNull(
      data: (words) => words
          .where(
            (word) =>
                word.translationStatus == TranslationStatus.pending ||
                word.translationStatus == TranslationStatus.failed,
          )
          .length,
    );
    final languageLabel = primaryLanguage == PrimaryLanguage.german
        ? 'Deutsch -> Englisch'
        : 'Englisch -> Deutsch';
    final pronunciationLanguage = primaryLanguage == PrimaryLanguage.german
        ? 'de'
        : 'en';

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            _ProfileHeader(isPremium: profileState.isPremium),
            const SizedBox(height: 18),
            _Section(
              title: 'Dein Lernen',
              subtitle: 'Lokaler Überblick ohne SRS-Veränderung.',
              children: [
                _MetricGrid(
                  children: [
                    _MetricTile(
                      label: 'Lernstreak',
                      value: '${_activeStreakDays(profileState.streakWeek)}',
                      detail: 'Tage aktiv',
                      color: _gold,
                    ),
                    _MetricTile(
                      label: 'Heute gelernt',
                      value: 'bereit',
                      detail: 'noch kein Tageszähler',
                      color: _violet,
                    ),
                    _MetricTile(
                      label: 'Deine Wörter',
                      value: _asyncCount(myWords),
                      detail: 'lokal gespeichert',
                      color: _mint,
                    ),
                    _MetricTile(
                      label: 'Bekannt',
                      value: _asyncCount(knownWords),
                      detail: 'aus SRS gelesen',
                      color: _cyan,
                    ),
                    _MetricTile(
                      label: 'Markiert',
                      value: _asyncCount(favoriteWords),
                      detail: 'lokale Merkliste',
                      color: _violet,
                    ),
                    _MetricTile(
                      label: 'Offene Übersetzungen',
                      value: pendingTranslations?.toString() ?? '...',
                      detail: 'pending oder fehlgeschlagen',
                      color: _gold,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Sprache & Aussprache',
              subtitle:
                  'Geräte-TTS, lokale Spracheinstellung und DeepL-Status.',
              children: [
                _InfoRow(
                  icon: Icons.language_rounded,
                  title: 'Lernrichtung',
                  value: languageLabel,
                ),
                _ActionRow(
                  key: const Key('profile-pronunciation-test-row'),
                  icon: Icons.volume_up_rounded,
                  title: 'Aussprache testen',
                  value: primaryLanguage == PrimaryLanguage.german
                      ? 'Beispiel: Willkommen'
                      : 'Beispiel: emergency',
                  onTap: () => _testPronunciation(
                    context,
                    ref,
                    primaryLanguage == PrimaryLanguage.german
                        ? 'Willkommen'
                        : 'emergency',
                    pronunciationLanguage,
                  ),
                ),
                _ToggleRow(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Karten automatisch aussprechen',
                  value: preferences.autoPronounceCards,
                  onChanged: preferenceController.setAutoPronounceCards,
                ),
                const _InfoRow(
                  icon: Icons.translate_rounded,
                  title: 'Übersetzungsweg',
                  value: 'DeepL über Supabase',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Benachrichtigungen',
              subtitle: 'Lokale Steuerung für Impulse und Erinnerungen.',
              children: [
                _ToggleRow(
                  icon: Icons.notifications_active_rounded,
                  title: 'Tagesimpuls',
                  value: tagesimpulsSettings.enabled,
                  onChanged: (value) => ref
                      .read(
                        tagesimpulsNotificationSettingsControllerProvider
                            .notifier,
                      )
                      .setEnabled(value),
                ),
                _ToggleRow(
                  icon: Icons.school_rounded,
                  title: 'Lern-Erinnerung',
                  value: preferences.learningRemindersEnabled,
                  onChanged: preferenceController.setLearningRemindersEnabled,
                ),
                _ToggleRow(
                  icon: Icons.sync_problem_rounded,
                  title: 'Offene Übersetzungen erinnern',
                  value: preferences.pendingTranslationRemindersEnabled,
                  onChanged: preferenceController
                      .setPendingTranslationRemindersEnabled,
                ),
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  title: 'Tagesimpuls-Zeitfenster',
                  value: _notificationWindowLabel(tagesimpulsSettings),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Impuls & KI',
              subtitle: 'Globaler Standard für Chats und Kategorie-Impulse.',
              children: [
                _InfoRow(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Antwortstil',
                  value: impulseProfile.style.label,
                ),
                _InfoRow(
                  icon: Icons.short_text_rounded,
                  title: 'Antwortlänge',
                  value: impulseProfile.answerLength.label,
                ),
                _InfoRow(
                  icon: Icons.flag_rounded,
                  title: 'Lernziel',
                  value: impulseProfile.learningGoal.label,
                ),
                _InfoRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Erklärungssprache',
                  value: impulseProfile.explanationLanguage.label,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'App-Einstellungen',
              subtitle: 'Ruhige Steuerung für das Talvori-Gefühl.',
              children: [
                _ToggleRow(
                  icon: Icons.vibration_rounded,
                  title: 'Haptik',
                  value: preferences.hapticsEnabled,
                  onChanged: preferenceController.setHapticsEnabled,
                ),
                _ToggleRow(
                  icon: Icons.graphic_eq_rounded,
                  title: 'Sound & Aussprache',
                  value: preferences.soundEnabled,
                  onChanged: preferenceController.setSoundEnabled,
                ),
                _ToggleRow(
                  icon: Icons.auto_fix_high_rounded,
                  title: 'Animationen',
                  value: preferences.animationsEnabled,
                  onChanged: preferenceController.setAnimationsEnabled,
                ),
                const _InfoRow(
                  icon: Icons.dark_mode_rounded,
                  title: 'Design',
                  value: 'Talvori Dark-Neon',
                ),
                const _InfoRow(
                  icon: Icons.translate_rounded,
                  title: 'App-Sprache',
                  value: 'Deutsch',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Daten & Hilfe',
              subtitle: 'Lokaler Speicher, Importstatus und App-Info.',
              children: [
                _InfoRow(
                  icon: Icons.inventory_2_rounded,
                  title: 'Importierte Wörter',
                  value: '${_asyncCount(myWords)} in Meine Wörter',
                ),
                _InfoRow(
                  icon: Icons.pending_actions_rounded,
                  title: 'Übersetzungsstatus',
                  value: pendingTranslations == null
                      ? 'wird geladen'
                      : pendingTranslations == 0
                      ? 'alles aktuell'
                      : '$pendingTranslations ausstehend',
                ),
                const _InfoRow(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Datenschutz',
                  value: 'lokal gespeichert',
                ),
                const _InfoRow(
                  icon: Icons.info_outline_rounded,
                  title: 'App-Version',
                  value: '1.0.0+1',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static int _activeStreakDays(List<bool> streakWeek) {
    return streakWeek.where((day) => day).length;
  }

  static String _asyncCount(AsyncValue<List<Object?>> value) {
    return value.when(
      data: (items) => items.length.toString(),
      loading: () => '...',
      error: (_, _) => '0',
    );
  }

  static String _notificationWindowLabel(
    TagesimpulsNotificationSettingsState state,
  ) {
    if (!state.enabled) return 'aus';
    return switch (state.preferredWindow) {
      TagesimpulsPreferredWindow.automatic => 'automatisch',
      TagesimpulsPreferredWindow.morning => 'morgens',
      TagesimpulsPreferredWindow.noon => 'mittags',
      TagesimpulsPreferredWindow.afternoon => 'nachmittags',
      TagesimpulsPreferredWindow.evening => 'abends',
      TagesimpulsPreferredWindow.custom =>
        '${state.customHour.toString().padLeft(2, '0')}:${state.customMinute.toString().padLeft(2, '0')}',
    };
  }

  static Future<void> _testPronunciation(
    BuildContext context,
    WidgetRef ref,
    String word,
    String languageCode,
  ) async {
    unawaited(HapticFeedback.selectionClick());
    final result = await ref
        .read(wordPronunciationServiceProvider)
        .speakWord(word, languageCode: languageCode);
    if (!context.mounted || result.isSuccess) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Aussprache konnte nicht starten.'),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _neonDecoration(ProfileScreen._cyan.withValues(alpha: 0.34)),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Zurück',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [ProfileScreen._cyan, ProfileScreen._violet],
              ),
              boxShadow: [
                BoxShadow(
                  color: ProfileScreen._cyan.withValues(alpha: 0.22),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: ProfileScreen._background,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPremium
                      ? 'Dein Talvori-Kontrollraum ist aktiv.'
                      : 'Dein lokaler Lernstatus und deine Steuerung.',
                  style: const TextStyle(
                    color: ProfileScreen._muted,
                    fontSize: 14,
                    height: 1.25,
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

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _neonDecoration(ProfileScreen._mint.withValues(alpha: 0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: ProfileScreen._muted,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 520 ? 3 : 2;
        final gap = 10.0;
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ProfileScreen._panelSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ProfileScreen._muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF6F7E94), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _ProfileRow(
      icon: icon,
      title: title,
      trailing: _RightValueText(value),
    );
  }
}

class _RightValueText extends StatelessWidget {
  const _RightValueText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 132),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          value,
          textAlign: TextAlign.right,
          softWrap: true,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: _ProfileRow(
          icon: icon,
          title: title,
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.play_arrow_rounded,
                  color: ProfileScreen._mint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ProfileRow(
      icon: icon,
      title: title,
      trailing: Switch.adaptive(
        value: value,
        activeThumbColor: ProfileScreen._mint,
        activeTrackColor: ProfileScreen._mint.withValues(alpha: 0.32),
        inactiveThumbColor: const Color(0xFF8B94A5),
        inactiveTrackColor: const Color(0xFF1B2430),
        onChanged: onChanged,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ProfileScreen._panelSoft.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ProfileScreen._cyan.withValues(alpha: 0.12),
              border: Border.all(
                color: ProfileScreen._cyan.withValues(alpha: 0.24),
              ),
            ),
            child: Icon(icon, color: ProfileScreen._mint, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }
}

BoxDecoration _neonDecoration(Color borderColor) {
  return BoxDecoration(
    color: ProfileScreen._panel.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: borderColor),
    boxShadow: [
      BoxShadow(
        color: borderColor.withValues(alpha: 0.45),
        blurRadius: 22,
        spreadRadius: -16,
      ),
    ],
  );
}
