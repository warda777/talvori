import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schlanker State für das Profil.
class ProfileState {
  final bool isPremium;
  /// Wochentage So–Sa; true = Streak aktiv.
  final List<bool> streakWeek;
  /// Ob bestimmte Module gelockt (Paywall/coming soon) angezeigt werden.
  final Set<String> lockedKeys;

  const ProfileState({
    required this.isPremium,
    required this.streakWeek,
    required this.lockedKeys,
  });

  ProfileState copyWith({
    bool? isPremium,
    List<bool>? streakWeek,
    Set<String>? lockedKeys,
  }) => ProfileState(
        isPremium: isPremium ?? this.isPremium,
        streakWeek: streakWeek ?? this.streakWeek,
        lockedKeys: lockedKeys ?? this.lockedKeys,
      );

  static ProfileState initial() => const ProfileState(
        isPremium: false,
        streakWeek: [false, false, false, false, false, false, false],
        lockedKeys: {
          // Default-Locks wie im Mockup (Schloss-Symbol)
          'history', 'widgets', 'collections', 'reminders',
          'alarm', 'themes', 'voices', 'app_icon',
        },
      );
}

/// Controller: Platz für spätere Supabase-Anbindung / Purchases.
/// (bewusst schlank, um Screen „präsentational“ zu halten)
class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    // TODO: hier später User-Profile/Premium aus Supabase laden
    // und Streak aus Daily-Stats aggregieren.
    return ProfileState.initial();
  }

  void togglePremiumMock() {
    state = state.copyWith(isPremium: !state.isPremium);
  }

  void setStreak(List<bool> flags) {
    if (flags.length == 7) {
      state = state.copyWith(streakWeek: List<bool>.from(flags));
    }
  }

  void unlock(String key) {
    final s = Set<String>.from(state.lockedKeys)..remove(key);
    state = state.copyWith(lockedKeys: s);
  }
}
