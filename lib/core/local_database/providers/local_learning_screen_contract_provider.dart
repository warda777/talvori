import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/local_learning_screen_contract.dart';
import 'local_learning_view_model_provider.dart';

final localLearningScreenContractProvider =
    Provider<LocalLearningScreenContract>((ref) {
      final viewModelState = ref.watch(localLearningViewModelProvider);
      return LocalLearningScreenContract.fromViewModelState(viewModelState);
    });
