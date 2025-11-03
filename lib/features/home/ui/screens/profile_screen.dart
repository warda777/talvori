import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_controller.dart';
import '../../providers.dart';
import '../widgets/profile_premium_card.dart';
import '../widgets/profile_streak_card.dart';
import '../widgets/profile_tile.dart';
import '../widgets/settings_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final ctrl = ref.read(profileControllerProvider.notifier);
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: SettingsButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [

            ProfilePremiumCard(
              isPremium: state.isPremium,
              onTap: ctrl.togglePremiumMock,
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Text(
                'Your Vocabulary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            ProfileStreakCard(streak: state.streakWeek),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ProfileTile(
                    label: 'History',
                    locked: state.lockedKeys.contains('history'),
                    onTap: () {
                      // TODO: Navigation zu History
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProfileTile(
                    label: 'Favoriten',
                    onTap: () {
                      // TODO: Navigation zu Favorites
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ProfileTile(
                    label: 'Deine eigenen',
                    onTap: () {
                      // TODO: Navigation zu MyWords
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProfileTile(
                    label: 'Sammlungen',
                    locked: state.lockedKeys.contains('collections'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Text(
                'Customize the app',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              children: [
                ProfileTile(
                    label: 'Widgets',
                    locked: state.lockedKeys.contains('widgets')),
                ProfileTile(
                    label: 'Reminders',
                    locked: state.lockedKeys.contains('reminders')),
                ProfileTile(
                    label: 'Alarm',
                    locked: state.lockedKeys.contains('alarm')),
                ProfileTile(
                    label: 'Themes',
                    locked: state.lockedKeys.contains('themes')),
                ProfileTile(
                    label: 'Voices',
                    locked: state.lockedKeys.contains('voices')),
                ProfileTile(
                    label: 'App icon',
                    locked: state.lockedKeys.contains('app_icon')),
                const ProfileTile(label: 'Watch'),
                const ProfileTile(label: 'Self–Growth bundle'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
