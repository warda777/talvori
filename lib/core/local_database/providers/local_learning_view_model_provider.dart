import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/local_learning_view_model_adapter.dart';
import '../adapters/local_learning_view_model_state.dart';
import '../controllers/local_learning_controller.dart';

final localLearningViewModelProvider = Provider<LocalLearningViewModelState>((
  ref,
) {
  final controllerState = ref.watch(localLearningControllerProvider);
  return const LocalLearningViewModelAdapter().map(controllerState);
});
