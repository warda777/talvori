import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_text_import_service.dart';
import 'local_bootstrap_provider.dart';

final sharedTextImportServiceProvider = FutureProvider<SharedTextImportService>(
  (ref) async {
    final bootstrap = await ref.watch(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    return SharedTextImportService(
      categoryRepository: repositories.categoryRepository,
      wordRepository: repositories.wordRepository,
    );
  },
);
