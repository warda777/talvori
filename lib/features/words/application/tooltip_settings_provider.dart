import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyShowTooltipsAlways = 'showTooltipsAlways';

/// Interview-Modus: Wenn true, werden Tooltips bei jeder relevanten Interaktion angezeigt.
final showTooltipsAlwaysProvider =
    StateNotifierProvider<TooltipSettingsNotifier, bool>((ref) {
  return TooltipSettingsNotifier();
});

class TooltipSettingsNotifier extends StateNotifier<bool> {
  TooltipSettingsNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyShowTooltipsAlways) ?? false;
  }

  Future<void> setShowTooltipsAlways(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowTooltipsAlways, value);
  }
}

/// Einzelne Flags pro Tooltip – jedes unabhängig, kein gemeinsamer State.
class _TooltipFlagNotifier extends StateNotifier<bool> {
  _TooltipFlagNotifier(this._prefsKey) : super(false) {
    _load();
  }

  final String _prefsKey;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    state = true;
  }
}

final hasSeenLockTooltipProvider =
    StateNotifierProvider<_TooltipFlagNotifier, bool>((ref) =>
        _TooltipFlagNotifier('hasSeenLockTooltip'));
final hasSeenSingleTooltipProvider =
    StateNotifierProvider<_TooltipFlagNotifier, bool>((ref) =>
        _TooltipFlagNotifier('hasSeenSingleTooltip'));
final hasSeenTrainingTooltipProvider =
    StateNotifierProvider<_TooltipFlagNotifier, bool>((ref) =>
        _TooltipFlagNotifier('hasSeenTrainingTooltip'));
final hasSeenVocabsTooltipProvider =
    StateNotifierProvider<_TooltipFlagNotifier, bool>((ref) =>
        _TooltipFlagNotifier('hasSeenVocabsTooltip'));
final hasSeenWheelTooltipProvider =
    StateNotifierProvider<_TooltipFlagNotifier, bool>((ref) =>
        _TooltipFlagNotifier('hasSeenWheelTooltip'));
final hasSeenAutoTooltipProvider =
    StateNotifierProvider<_TooltipFlagNotifier, bool>((ref) =>
        _TooltipFlagNotifier('hasSeenAutoTooltip'));
final hasSeenResetTooltipProvider =
    StateNotifierProvider<_TooltipFlagNotifier, bool>((ref) =>
        _TooltipFlagNotifier('hasSeenResetTooltip'));
final hasSeenPlayTooltipProvider =
    StateNotifierProvider<_TooltipFlagNotifier, bool>((ref) =>
        _TooltipFlagNotifier('hasSeenPlayTooltip'));

/// Reset nur der Category-Detail-Tooltips (Lock, Single, Training, Vocabs, Wheel, Auto).
/// Wird aufgerufen, wenn der Nutzer Category Detail verlässt → beim nächsten Besuch
/// sind die Tooltips wieder für einen Durchlauf aktiv.
Future<void> resetCategoryDetailTooltipFlags(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  for (final key in [
    'hasSeenLockTooltip',
    'hasSeenSingleTooltip',
    'hasSeenTrainingTooltip',
    'hasSeenVocabsTooltip',
    'hasSeenWheelTooltip',
    'hasSeenAutoTooltip',
  ]) {
    await prefs.remove(key);
  }
  ref.invalidate(hasSeenLockTooltipProvider);
  ref.invalidate(hasSeenSingleTooltipProvider);
  ref.invalidate(hasSeenTrainingTooltipProvider);
  ref.invalidate(hasSeenVocabsTooltipProvider);
  ref.invalidate(hasSeenWheelTooltipProvider);
  ref.invalidate(hasSeenAutoTooltipProvider);
}

/// Reset aller Tooltip-Flags (für Settings)
Future<void> resetAllTooltipFlags(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  for (final key in [
    'hasSeenLockTooltip',
    'hasSeenSingleTooltip',
    'hasSeenTrainingTooltip',
    'hasSeenVocabsTooltip',
    'hasSeenWheelTooltip',
    'hasSeenAutoTooltip',
    'hasSeenResetTooltip',
    'hasSeenPlayTooltip',
  ]) {
    await prefs.remove(key);
  }
  ref.invalidate(hasSeenLockTooltipProvider);
  ref.invalidate(hasSeenSingleTooltipProvider);
  ref.invalidate(hasSeenTrainingTooltipProvider);
  ref.invalidate(hasSeenVocabsTooltipProvider);
  ref.invalidate(hasSeenWheelTooltipProvider);
  ref.invalidate(hasSeenAutoTooltipProvider);
  ref.invalidate(hasSeenResetTooltipProvider);
  ref.invalidate(hasSeenPlayTooltipProvider);
}
