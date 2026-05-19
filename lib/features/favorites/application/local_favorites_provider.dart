import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_favorites_repository.dart';
import 'local_favorites_controller.dart';

final localFavoritesRepositoryProvider = Provider<LocalFavoritesRepository>((
  ref,
) {
  return SharedPreferencesLocalFavoritesRepository();
});

final localFavoritesControllerProvider =
    StateNotifierProvider<LocalFavoritesController, LocalFavoritesState>((ref) {
      final repository = ref.watch(localFavoritesRepositoryProvider);
      final controller = LocalFavoritesController(repository: repository);
      unawaited(controller.load());
      return controller;
    });
