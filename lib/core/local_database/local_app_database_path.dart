import 'package:path/path.dart' as p;

class LocalAppDatabasePath {
  const LocalAppDatabasePath._();

  static const String databaseName = 'talvori_local_v1.db';

  static String buildPath(String databasesPath) {
    return p.join(databasesPath, databaseName);
  }
}
