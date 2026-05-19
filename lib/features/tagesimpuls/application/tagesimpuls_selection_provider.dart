import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tagesimpuls_selection_repository.dart';
import 'tagesimpuls_selection_controller.dart';

final tagesimpulsSelectionRepositoryProvider =
    Provider<TagesimpulsSelectionRepository>((ref) {
      return SharedPreferencesTagesimpulsSelectionRepository();
    });

final tagesimpulsSelectionControllerProvider =
    StateNotifierProvider<
      TagesimpulsSelectionController,
      TagesimpulsSelectionState
    >((ref) {
      final repository = ref.watch(tagesimpulsSelectionRepositoryProvider);
      final controller = TagesimpulsSelectionController(repository: repository);
      unawaited(controller.load());
      return controller;
    });
