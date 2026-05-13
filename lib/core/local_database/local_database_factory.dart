import 'package:sqflite/sqflite.dart';

import 'local_database_schema.dart';

class LocalDatabaseFactory {
  const LocalDatabaseFactory();

  Future<Database> openAtPath(String path) {
    return openDatabase(
      path,
      version: LocalDatabaseSchema.version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await LocalDatabaseSchema.createV1(db);
      },
    );
  }
}
