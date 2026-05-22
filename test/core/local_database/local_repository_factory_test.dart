import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_factory.dart';
import 'package:talvori/core/local_database/local_repository_factory.dart';
import 'package:talvori/core/local_database/models/local_session_read_state.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('LocalRepositoryFactory', () {
    test('repository_factory_creates_local_facade_dependencies', () async {
      final now = DateTime(2026, 5, 13, 10);
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_repository_factory_test_',
      );
      final databasePath = '${tempDir.path}/talvori_local_v1.db';
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final db = await const LocalDatabaseFactory().openAtPath(databasePath);
      addTearDown(db.close);
      final repositoryFactory = LocalRepositoryFactory(database: db);

      final category = await repositoryFactory.categoryRepository
          .upsertCategory(id: 'category-basics', name: 'Basics', now: now);
      for (var index = 1; index <= 4; index++) {
        await repositoryFactory.wordRepository.upsertWord(
          id: 'word-$index',
          categoryId: category.id,
          term: 'Term $index',
          translation: 'Translation $index',
          exampleSentence: 'Example sentence $index',
          notes: 'Notes $index',
          sortOrder: index,
          now: now,
        );
      }

      final readState = await repositoryFactory.learningSessionFacade
          .startOrResumeLearning(
            categoryId: category.id,
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
      final activeSessions = await db.query(
        'learning_sessions',
        where:
            'category_id = ? AND mode_id = ? AND training_area_id = ? AND status = ?',
        whereArgs: [
          category.id,
          LearningMode.adaptive.name,
          TrainingArea.all.name,
          'active',
        ],
      );

      expect(readState, isA<LocalSessionReadState>());
      expect(readState.currentWordId, isNotNull);
      expect(readState.currentTerm, isNotNull);
      expect(readState.currentStage, SrsStage.s0);
      expect(activeSessions, hasLength(1));
      final savedSource = await repositoryFactory.wordSourceRepository
          .saveSource(
            wordId: 'word-1',
            sourceUrl: 'https://example.com/article',
            createdAt: now,
          );
      expect(savedSource?.sourceUrl, 'https://example.com/article');
    });
  });
}
