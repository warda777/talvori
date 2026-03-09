import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controller/Provider
import '../../application/settings_controller.dart';
import '../../providers.dart';
import 'package:talvori/features/onboarding/application/onboarding_settings_provider.dart';
import 'package:talvori/features/onboarding/ui/screens/onboarding_flow_screen.dart';
import 'package:talvori/features/words/application/tooltip_settings_provider.dart'
    show showTooltipsAlwaysProvider, resetAllTooltipFlags;

// Settings Widgets
import '../widgets/widgets.dart';
import '../widgets/settings_switch_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final state = ref.watch(settingsControllerProvider);
    final ctrl  = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [

            // TOOLTIPS
            SettingsSection(
              title: 'Hinweise',
              children: [
                SettingsSwitchTile(
                  title: 'Tooltips bei Nutzung anzeigen',
                  subtitle: 'Zeigt kurze Hinweise bei der Bedienung.',
                  value: ref.watch(showTooltipsAlwaysProvider),
                  onChanged: (v) =>
                      ref.read(showTooltipsAlwaysProvider.notifier).setShowTooltipsAlways(v),
                ),
                SettingsTile(
                  title: 'Tooltips zurücksetzen',
                  onTap: () async {
                    await resetAllTooltipFlags(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tooltips wurden zurückgesetzt')),
                      );
                    }
                  },
                ),
              ],
            ),

            // ONBOARDING
            SettingsSection(
              title: 'Onboarding',
              children: [
                SettingsSwitchTile(
                  title: 'Onboarding bei Start anzeigen',
                  subtitle: 'Zeigt die Einführung beim Öffnen einer Kategorie im Word Hub.',
                  value: ref.watch(showOnboardingOnStartProvider),
                  onChanged: (v) =>
                      ref.read(showOnboardingOnStartProvider.notifier).setShowOnStart(v),
                ),
                SettingsTile(
                  title: 'Onboarding erneut ansehen',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OnboardingFlowScreen(
                          onComplete: () => Navigator.of(context).pop(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // PREMIUM
            SettingsSection(
              title: 'Premium',
              children: [
                SettingsTile(
                  title: 'Manage subscription',
                  onTap: () {
                    // TODO: navigate to Paywall/Subscription Management
                  },
                ),
              ],
            ),

            // MAKE IT YOURS
            SettingsSection(
              title: 'Make it yours',
              children: [
                SettingsTile(
                  title: 'Content preferences',
                  onTap: () {
                    // TODO: open content preferences
                  },
                ),
                SettingsTile(
                  title: 'Muted content',
                  onTap: () {
                    // TODO: open muted content
                  },
                ),
                SettingsTile(
                  title: 'Language',
                  onTap: () {
                    // TODO: open language picker
                  },
                ),
              ],
            ),

            // ACCOUNT
            SettingsSection(
              title: 'Account',
              children: [
                SettingsTile(
                  title: 'Sign in',
                  onTap: () {
                    // TODO: push auth/sign-in
                  },
                ),
              ],
            ),

            // SUPPORT US
            SettingsSection(
              title: 'Support us',
              children: [
                SettingsTile(
                  title: 'Share Vocabulary',
                  onTap: () {
                    // TODO: share app link
                  },
                ),
                SettingsTile(
                  title: 'Leave us a review',
                  onTap: () {
                    // TODO: open store review
                  },
                ),
                SettingsTile(
                  title: 'Vote on next features',
                  onTap: () {
                    // TODO: open survey/feature-vote
                  },
                ),
              ],
            ),

            // FOLLOW US (externe Links ↗)
            SettingsSection(
              title: 'Follow us',
              children: [
                SettingsTile(
                  title: 'Instagram',
                  external: true,
                  onTap: () { /* TODO: launchUrl(instagram) */ },
                ),
                SettingsTile(
                  title: 'Facebook',
                  external: true,
                  onTap: () { /* TODO: launchUrl(facebook) */ },
                ),
                SettingsTile(
                  title: 'X (formerly Twitter)',
                  external: true,
                  onTap: () { /* TODO: launchUrl(x) */ },
                ),
              ],
            ),

            // HELP
            SettingsSection(
              title: 'Help',
              children: [
                SettingsTile(
                  title: 'Help',
                  onTap: () { /* TODO: open help/faq */ },
                ),
              ],
            ),

            // OTHER
            SettingsSection(
              title: 'Other',
              children: [
                SettingsTile(
                  title: 'Privacy Policy',
                  onTap: () { /* TODO: open privacy page */ },
                ),
                SettingsTile(
                  title: 'Terms and Conditions',
                  onTap: () { /* TODO: open terms page */ },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Footer mit Version + UserID + Copy
            SettingsFooterCard(
              appVersion: state.appVersion,
              userId: state.userId,
              onCopy: ctrl.copyUserIdToClipboard,
            ),
          ],
        ),
      ),
    );
  }
}
