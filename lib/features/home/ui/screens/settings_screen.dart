import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/profile_preferences_controller.dart';
import 'package:talvori/features/home/ui/screens/supabase_words_local_import_screen.dart';

import '../../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _background = Color(0xFF05070D);
  static const _panel = Color(0xFF0B121C);
  static const _tile = Color(0xFF111B28);
  static const _tileSoft = Color(0xFF172432);
  static const _cyan = Color(0xFF78E6FF);
  static const _mint = Color(0xFF7DFFE3);
  static const _violet = Color(0xFFB37CFF);
  static const _gold = Color(0xFFFFD976);
  static const _muted = Color(0xFF93A2B8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final preferences = ref.watch(profilePreferencesControllerProvider);
    final controller = ref.read(profilePreferencesControllerProvider.notifier);

    return _SettingsScaffold(
      title: 'Einstellungen',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          _SettingsSection(
            title: 'Premium',
            children: [
              _SettingsTile(
                icon: Icons.workspace_premium_rounded,
                title: 'Abonnement verwalten',
                onTap: () => _push(context, const _SubscriptionScreen()),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Über dich',
            children: [
              _SettingsTile(
                icon: Icons.badge_rounded,
                title: 'Name',
                value: preferences.displayName.isEmpty
                    ? null
                    : preferences.displayName,
                onTap: () => _push(context, const _NameSettingsScreen()),
              ),
              _SettingsTile(
                icon: Icons.diversity_2_rounded,
                title: 'Geschlechtsidentität',
                value: preferences.genderIdentity.isEmpty
                    ? null
                    : preferences.genderIdentity,
                onTap: () => _push(
                  context,
                  _ChoiceSettingsScreen(
                    title: 'Geschlechtsidentität',
                    options: const [
                      'Weiblich',
                      'Männlich',
                      'Divers',
                      'Möchte ich nicht sagen',
                    ],
                    currentValue: preferences.genderIdentity,
                    onSelected: controller.setGenderIdentity,
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.cake_rounded,
                title: 'Alter',
                value: preferences.ageRange.isEmpty
                    ? null
                    : preferences.ageRange,
                onTap: () => _push(
                  context,
                  _ChoiceSettingsScreen(
                    title: 'Alter',
                    options: const [
                      '13 bis 17',
                      '18 bis 24',
                      '25 bis 34',
                      '35 bis 44',
                      '45 bis 54',
                      '55+',
                      'Möchte ich nicht sagen',
                    ],
                    currentValue: preferences.ageRange,
                    onSelected: controller.setAgeRange,
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.stacked_bar_chart_rounded,
                title: 'Level',
                value: preferences.level.isEmpty ? null : preferences.level,
                onTap: () => _push(
                  context,
                  _ChoiceSettingsScreen(
                    title: 'Level',
                    options: const [
                      'Anfänger',
                      'Mittleres Niveau',
                      'Fortgeschritten',
                    ],
                    currentValue: preferences.level,
                    onSelected: controller.setLevel,
                  ),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'App & Lernen',
            children: [
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Sprache',
                value:
                    '${preferences.nativeLanguage} -> ${preferences.learningLanguage}',
                onTap: () => _push(context, const _LanguageSettingsScreen()),
              ),
              _SettingsTile(
                icon: Icons.volume_up_rounded,
                title: 'Ton',
                value: preferences.soundEnabled ? 'An' : 'Aus',
                onTap: () => _push(context, const _SoundSettingsScreen()),
              ),
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Erinnerungen',
                value: preferences.dailyReminderEnabled ? 'An' : 'Aus',
                onTap: () => _push(context, const ReminderSettingsScreen()),
              ),
              _SettingsTile(
                icon: Icons.volume_off_rounded,
                title: 'Stummgeschaltete Inhalte',
                onTap: () => _push(context, const _MutedContentScreen()),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Konto',
            children: [
              _SettingsTile(
                icon: Icons.person_rounded,
                title: 'Anmelden',
                onTap: () => _push(
                  context,
                  const _PlaceholderSettingsScreen(
                    title: 'Anmelden',
                    body:
                        'Die Anmeldung wird vorbereitet. Du kannst Talvori aktuell vollständig lokal nutzen.',
                  ),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Unterstützung',
            children: [
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Hilfe',
                onTap: () => _push(
                  context,
                  const _PlaceholderSettingsScreen(
                    title: 'Hilfe',
                    body: 'Wie können wir helfen?',
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.rate_review_rounded,
                title: 'Eine Bewertung schreiben',
                onTap: () => _preparedSnack(context),
              ),
              _SettingsTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Feedback zu neuen Funktionen',
                onTap: () => _push(
                  context,
                  const _PlaceholderSettingsScreen(
                    title: 'Feedback zu neuen Funktionen',
                    body: 'Diese Funktion wird vorbereitet.',
                  ),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Rechtliches',
            children: [
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Datenschutzrichtlinie',
                onTap: () => _push(
                  context,
                  const _PlaceholderSettingsScreen(
                    title: 'Datenschutzrichtlinie',
                    body: 'Datenschutzinformationen werden hier angezeigt.',
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.description_rounded,
                title: 'AGB',
                onTap: () => _push(
                  context,
                  const _PlaceholderSettingsScreen(
                    title: 'AGB',
                    body:
                        'Die Allgemeinen Geschäftsbedingungen werden hier angezeigt.',
                  ),
                ),
              ),
              _SwitchSettingsTile(
                icon: Icons.analytics_rounded,
                title: 'Marketing & Analysen',
                value: preferences.marketingAnalyticsEnabled,
                onChanged: controller.setMarketingAnalyticsEnabled,
              ),
            ],
          ),
          if (kDebugMode)
            _SettingsSection(
              title: 'Entwickler',
              children: [
                _SettingsTile(
                  icon: Icons.cloud_download_rounded,
                  title: 'Supabase-Wörter lokal importieren',
                  value: 'Preview und manueller Import',
                  onTap: () =>
                      _push(context, const SupabaseWordsLocalImportScreen()),
                ),
              ],
            ),
          const SizedBox(height: 8),
          _FooterCard(
            appVersion: settings.appVersion,
            userId: settings.userId,
            onCopy: () async {
              await ref
                  .read(settingsControllerProvider.notifier)
                  .copyUserIdToClipboard();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nutzer-ID kopiert.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  static void _preparedSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diese Funktion wird vorbereitet.')),
    );
  }
}

class _SettingsScaffold extends StatelessWidget {
  const _SettingsScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: SettingsScreen._background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Row(
                children: [
                  _CircleButton(
                    tooltip: 'Zurück',
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SettingsScreen._tileSoft.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: SettingsScreen._cyan.withValues(alpha: 0.12),
                blurRadius: 18,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: SettingsScreen._muted,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: SettingsScreen._panel.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: SettingsScreen._cyan.withValues(alpha: 0.12),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i != children.length - 1)
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              _TileIcon(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (value != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        value!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SettingsScreen._muted,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchSettingsTile extends StatelessWidget {
  const _SwitchSettingsTile({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _TileIcon(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: SettingsScreen._mint,
            activeTrackColor: SettingsScreen._mint.withValues(alpha: 0.34),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: SettingsScreen._cyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: SettingsScreen._mint, size: 21),
    );
  }
}

class _FooterCard extends StatelessWidget {
  const _FooterCard({
    required this.appVersion,
    required this.userId,
    required this.onCopy,
  });

  final String appVersion;
  final String userId;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SettingsScreen._panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Talvori · Version $appVersion',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nutzer-ID: $userId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SettingsScreen._muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Nutzer-ID kopieren',
            onPressed: userId == '—' ? null : onCopy,
            icon: const Icon(Icons.copy_rounded),
            color: SettingsScreen._mint,
          ),
        ],
      ),
    );
  }
}

class _NameSettingsScreen extends ConsumerStatefulWidget {
  const _NameSettingsScreen();

  @override
  ConsumerState<_NameSettingsScreen> createState() =>
      _NameSettingsScreenState();
}

class _NameSettingsScreenState extends ConsumerState<_NameSettingsScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(profilePreferencesControllerProvider).displayName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Name',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: EdgeInsets.fromLTRB(
              22,
              24,
              22,
              28 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            children: [
              const Text(
                'Dein Name wird verwendet, um deine App persönlicher zu gestalten.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Namen eingeben',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  filled: true,
                  fillColor: SettingsScreen._tileSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: SettingsScreen._cyan),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                ),
              ),
              SizedBox(height: constraints.maxHeight < 560 ? 28 : 160),
              _PrimaryButton(
                label: 'Speichern',
                onTap: () async {
                  await ref
                      .read(profilePreferencesControllerProvider.notifier)
                      .setDisplayName(_controller.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name gespeichert.')),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChoiceSettingsScreen extends StatelessWidget {
  const _ChoiceSettingsScreen({
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String currentValue;
  final Future<void> Function(String value) onSelected;

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: title,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = option == currentValue;
          return _ChoiceTile(
            label: option,
            selected: selected,
            onTap: () async {
              await onSelected(option);
              if (context.mounted) Navigator.of(context).maybePop();
            },
          );
        },
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: SettingsScreen._tileSoft,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? SettingsScreen._mint
                  : Colors.white.withValues(alpha: 0.12),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? SettingsScreen._mint
                    : Colors.white.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoundSettingsScreen extends ConsumerWidget {
  const _SoundSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(profilePreferencesControllerProvider);
    final controller = ref.read(profilePreferencesControllerProvider.notifier);
    return _SettingsScaffold(
      title: 'Ton',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          _SettingsSection(
            title: 'Audio',
            children: [
              _SwitchSettingsTile(
                icon: Icons.volume_up_rounded,
                title: 'Ton an/aus',
                value: preferences.soundEnabled,
                onChanged: controller.setSoundEnabled,
              ),
              _SwitchSettingsTile(
                icon: Icons.music_note_rounded,
                title: 'Spielsounds an/aus',
                value: preferences.gameSoundsEnabled,
                onChanged: controller.setGameSoundsEnabled,
              ),
              _SwitchSettingsTile(
                icon: Icons.record_voice_over_rounded,
                title: 'Aussprache/TTS an/aus',
                value: preferences.ttsEnabled,
                onChanged: controller.setTtsEnabled,
              ),
            ],
          ),
          const _InfoCard(
            text:
                'Diese Werte werden lokal gespeichert. Eine vollständige Audio-Anbindung kann später darauf aufsetzen.',
          ),
        ],
      ),
    );
  }
}

class _LanguageSettingsScreen extends ConsumerWidget {
  const _LanguageSettingsScreen();

  static const _languages = ['Deutsch', 'Englisch', 'Spanisch', 'Französisch'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(profilePreferencesControllerProvider);
    final controller = ref.read(profilePreferencesControllerProvider.notifier);
    return _SettingsScaffold(
      title: 'Sprache',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          _SettingsSection(
            title: 'Sprachen',
            children: [
              _SettingsTile(
                icon: Icons.phone_iphone_rounded,
                title: 'App-Sprache',
                value: preferences.appLanguage,
                onTap: () => _openLanguageChoice(
                  context,
                  title: 'App-Sprache',
                  current: preferences.appLanguage,
                  onSelected: controller.setAppLanguage,
                ),
              ),
              _SettingsTile(
                icon: Icons.home_rounded,
                title: 'Muttersprache',
                value: preferences.nativeLanguage,
                onTap: () => _openLanguageChoice(
                  context,
                  title: 'Muttersprache',
                  current: preferences.nativeLanguage,
                  onSelected: controller.setNativeLanguage,
                ),
              ),
              _SettingsTile(
                icon: Icons.school_rounded,
                title: 'Lernsprache',
                value: preferences.learningLanguage,
                onTap: () => _openLanguageChoice(
                  context,
                  title: 'Lernsprache',
                  current: preferences.learningLanguage,
                  onSelected: controller.setLearningLanguage,
                ),
              ),
            ],
          ),
          const _InfoCard(
            text:
                'Die Sprachwerte bleiben lokal und sind so vorbereitet, dass KI-Spiele später konsistent damit arbeiten können.',
          ),
        ],
      ),
    );
  }

  static void _openLanguageChoice(
    BuildContext context, {
    required String title,
    required String current,
    required Future<void> Function(String value) onSelected,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ChoiceSettingsScreen(
          title: title,
          options: _languages,
          currentValue: current,
          onSelected: onSelected,
        ),
      ),
    );
  }
}

class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(profilePreferencesControllerProvider);
    final controller = ref.read(profilePreferencesControllerProvider.notifier);
    return _SettingsScaffold(
      title: 'Erinnerungen',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          _SettingsSection(
            title: 'Erinnerungen',
            children: [
              _SwitchSettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Tageserinnerung',
                value: preferences.dailyReminderEnabled,
                onChanged: controller.setDailyReminderEnabled,
              ),
              _SettingsTile(
                icon: Icons.schedule_rounded,
                title: 'Uhrzeit',
                value: '20:00',
                onTap: () => SettingsScreen._preparedSnack(context),
              ),
            ],
          ),
          const _InfoCard(
            text:
                'Die Erinnerung ist lokal vorbereitet. Eine neue Benachrichtigungslogik wird hier bewusst nicht hinzugefügt.',
          ),
        ],
      ),
    );
  }
}

class _MutedContentScreen extends StatelessWidget {
  const _MutedContentScreen();

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Stummgeschaltete Inhalte',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 56,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SettingsScreen._cyan.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.volume_off_rounded,
                      color: SettingsScreen._mint,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Du hast noch nichts stummgeschaltet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Stummgeschaltete Inhalte werden nicht in deinen Hinweisen und Benachrichtigungen angezeigt.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SettingsScreen._muted,
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _PrimaryButton(
                    label: 'Inhalte hinzufügen',
                    onTap: () => SettingsScreen._preparedSnack(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SubscriptionScreen extends StatelessWidget {
  const _SubscriptionScreen();

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Abonnement verwalten',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: SettingsScreen._panel,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: SettingsScreen._gold.withValues(alpha: 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: SettingsScreen._gold.withValues(alpha: 0.1),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: SettingsScreen._gold,
                  size: 42,
                ),
                SizedBox(height: 18),
                Text(
                  'Premium ist vorbereitet.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Später erhältst du hier Zugriff auf KI-Spiele, zusätzliche Wortwelten und erweiterte Statistiken.',
                  style: TextStyle(
                    color: SettingsScreen._muted,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _PrimaryButton(
            label: 'Premium-Mitglied werden',
            onTap: () => SettingsScreen._preparedSnack(context),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderSettingsScreen extends StatelessWidget {
  const _PlaceholderSettingsScreen({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: title,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
        children: [_InfoCard(text: body)],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SettingsScreen._tile.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SettingsScreen._violet.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: SettingsScreen._muted,
          fontSize: 15,
          height: 1.35,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: SettingsScreen._background,
          backgroundColor: SettingsScreen._mint,
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
