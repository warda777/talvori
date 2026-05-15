import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_category.dart';
import 'local_bootstrap_provider.dart';

final localCategoriesProvider = FutureProvider<List<LocalCategory>>((
  ref,
) async {
  final bootstrapResult = await ref.watch(localBootstrapProvider.future);

  return bootstrapResult.repositoryFactory.categoryRepository.loadCategories();
});
