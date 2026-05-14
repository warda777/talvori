import 'package:flutter/widgets.dart';

import '../ui/local_learning_test_screen.dart';

const localLearningDebugRoutePath = '/debug/local-learning';
const localLearningDebugRouteName = 'debugLocalLearning';
const localLearningDebugDefaultCategoryId = 'basics';

typedef LocalLearningDebugRouteBuilder =
    Widget Function({required String categoryId});

class LocalLearningDebugRouteDefinition {
  const LocalLearningDebugRouteDefinition({
    required this.path,
    required this.name,
    required this.defaultCategoryId,
    required this.builder,
  });

  final String path;
  final String name;
  final String defaultCategoryId;
  final LocalLearningDebugRouteBuilder builder;
}

const localLearningDebugRouteDefinition = LocalLearningDebugRouteDefinition(
  path: localLearningDebugRoutePath,
  name: localLearningDebugRouteName,
  defaultCategoryId: localLearningDebugDefaultCategoryId,
  builder: buildLocalLearningDebugScreen,
);

List<LocalLearningDebugRouteDefinition> getLocalLearningDebugRoutes({
  required bool enabled,
}) {
  if (!enabled) {
    return const [];
  }

  return const [localLearningDebugRouteDefinition];
}

Widget buildLocalLearningDebugScreen({required String categoryId}) {
  return LocalLearningTestScreen(categoryId: categoryId);
}
