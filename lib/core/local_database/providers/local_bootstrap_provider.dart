import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local_app_bootstrap.dart';
import '../local_app_bootstrap_result.dart';
import '../services/local_learning_session_facade.dart';

final localBootstrapDatabasesPathProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'Override localBootstrapDatabasesPathProvider before reading '
    'localBootstrapProvider.',
  );
});

final localBootstrapProvider = FutureProvider<LocalAppBootstrapResult>((
  ref,
) async {
  final databasesPath = ref.watch(localBootstrapDatabasesPathProvider);

  final result = await const LocalAppBootstrap().bootstrap(
    databasesPath: databasesPath,
    seedDefaults: false,
    now: DateTime.now(),
  );

  ref.onDispose(() {
    result.database.close();
  });

  return result;
});

final localLearningSessionFacadeProvider =
    FutureProvider<LocalLearningSessionFacade>((ref) async {
      final result = await ref.watch(localBootstrapProvider.future);
      return result.learningSessionFacade;
    });
