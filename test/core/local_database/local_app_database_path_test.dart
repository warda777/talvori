import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';

void main() {
  group('LocalAppDatabasePath', () {
    test('app_database_path_uses_expected_name', () {
      final path = LocalAppDatabasePath.buildPath('/tmp/talvori_databases');

      expect(LocalAppDatabasePath.databaseName, 'talvori_local_v1.db');
      expect(path, endsWith('talvori_local_v1.db'));
    });

    test('app_database_path_does_not_use_old_word_progress_database_name', () {
      final path = LocalAppDatabasePath.buildPath('/tmp/talvori_databases');

      expect(path, isNot(contains('word_progress.db')));
      expect(LocalAppDatabasePath.databaseName, isNot('word_progress.db'));
    });
  });
}
