import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/home_controller.dart';
import 'package:talvori/features/home/application/home_state.dart';
import 'package:talvori/features/home/application/profile_controller.dart';
import 'package:talvori/features/home/application/settings_controller.dart';
import 'package:talvori/features/home/application/vocab_controller.dart';

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(() {
  return HomeController();
});

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(() => ProfileController());

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(() => SettingsController());

final vocabControllerProvider =
    NotifierProvider<VocabController, VocabState>(() => VocabController());
