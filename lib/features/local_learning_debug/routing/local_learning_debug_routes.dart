import 'package:flutter/widgets.dart';

import '../ui/local_learning_test_screen.dart';

const localLearningDebugRoutePath = '/debug/local-learning';

Widget buildLocalLearningDebugScreen({required String categoryId}) {
  return LocalLearningTestScreen(categoryId: categoryId);
}
