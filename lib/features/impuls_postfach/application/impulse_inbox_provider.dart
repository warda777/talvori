import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_controller.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';

final impulseInboxRepositoryProvider = Provider<ImpulseInboxRepository>((ref) {
  return SharedPreferencesImpulseInboxRepository();
});

final impulseInboxControllerProvider =
    StateNotifierProvider<ImpulseInboxController, ImpulseInboxState>((ref) {
      final repository = ref.watch(impulseInboxRepositoryProvider);
      final controller = ImpulseInboxController(repository: repository);
      unawaited(controller.loadChats());
      return controller;
    });
