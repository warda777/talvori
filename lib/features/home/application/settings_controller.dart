import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final String appVersion;
  final String userId;         // aus Supabase später befüllen
  const SettingsState({required this.appVersion, required this.userId});

  SettingsState copyWith({String? appVersion, String? userId}) =>
      SettingsState(appVersion: appVersion ?? this.appVersion, userId: userId ?? this.userId);

  static const SettingsState initial =
      SettingsState(appVersion: '1.0', userId: '—');
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // TODO: Version aus package_info + userId aus Supabase-Session laden
    return SettingsState.initial;
  }

  Future<void> copyUserIdToClipboard() async {
    if (state.userId.isEmpty || state.userId == '—') return;
    await Clipboard.setData(ClipboardData(text: state.userId));
  }
}
