import 'package:sqflite/sqflite.dart';

import 'local_repository_factory.dart';
import 'services/local_learning_session_facade.dart';

class LocalAppBootstrapResult {
  const LocalAppBootstrapResult({
    required this.databasePath,
    required this.database,
    required this.repositoryFactory,
    required this.learningSessionFacade,
  });

  final String databasePath;
  final Database database;
  final LocalRepositoryFactory repositoryFactory;
  final LocalLearningSessionFacade learningSessionFacade;
}
