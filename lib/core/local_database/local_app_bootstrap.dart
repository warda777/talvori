import 'local_app_bootstrap_result.dart';
import 'local_app_database_path.dart';
import 'local_database_factory.dart';
import 'local_repository_factory.dart';
import 'services/local_seed_data_service.dart';

class LocalAppBootstrap {
  const LocalAppBootstrap({
    LocalDatabaseFactory databaseFactory = const LocalDatabaseFactory(),
  }) : _databaseFactory = databaseFactory;

  final LocalDatabaseFactory _databaseFactory;

  Future<LocalAppBootstrapResult> bootstrap({
    required String databasesPath,
    required bool seedDefaults,
    required DateTime now,
  }) async {
    final databasePath = LocalAppDatabasePath.buildPath(databasesPath);
    final database = await _databaseFactory.openAtPath(databasePath);
    final repositoryFactory = LocalRepositoryFactory(database: database);

    if (seedDefaults) {
      await LocalSeedDataService(
        categoryRepository: repositoryFactory.categoryRepository,
        wordRepository: repositoryFactory.wordRepository,
      ).seedDefaults(now: now);
    }

    return LocalAppBootstrapResult(
      databasePath: databasePath,
      database: database,
      repositoryFactory: repositoryFactory,
      learningSessionFacade: repositoryFactory.learningSessionFacade,
    );
  }
}
