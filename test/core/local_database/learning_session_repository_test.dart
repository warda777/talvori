import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/learning_session_repository.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/new_card_policy.dart';
import 'package:talvori/core/srs/models/queue_build_result.dart';
import 'package:talvori/core/srs/models/queue_item_status.dart';
import 'package:talvori/core/srs/models/requeue_reason.dart';
import 'package:talvori/core/srs/models/session_item.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 13, 10);

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  Future<void> insertCategory(Database db, {String id = 'category-1'}) async {
    await db.insert('categories', {
      'id': id,
      'name': id,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> insertWord(
    Database db, {
    required String id,
    String categoryId = 'category-1',
  }) async {
    await db.insert('words', {
      'id': id,
      'category_id': categoryId,
      'term': id,
      'translation': 'translation-$id',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> insertWords(Database db, int count) async {
    for (var index = 0; index < count; index++) {
      await insertWord(db, id: 'word-$index');
    }
  }

  QueueBuildResult queueResult({
    int count = 3,
    LearningMode mode = LearningMode.time,
  }) {
    return QueueBuildResult(
      items: [
        for (var index = 0; index < count; index++)
          SessionItem(
            wordId: 'word-$index',
            categoryId: 'category-1',
            mode: mode,
            stageAtEnqueue: index == 0 ? SrsStage.s0 : SrsStage.s2,
            position: index,
            status: QueueItemStatus.queued,
            isNewCard: index == 0,
            dueAtEnqueue: now.add(Duration(days: index)),
          ),
      ],
      newCardsIncluded: 1,
      reviewsIncluded: count - 1,
      newCardPolicy: NewCardPolicy.allowed,
    );
  }

  QueueBuildResult emptyQueueResult() {
    return const QueueBuildResult(
      items: [],
      newCardsIncluded: 0,
      reviewsIncluded: 0,
      newCardPolicy: NewCardPolicy.allowed,
    );
  }

  Future<LearningSessionRecord> createSession(
    LearningSessionRepository repository, {
    String categoryId = 'category-1',
    LearningMode mode = LearningMode.time,
    TrainingArea trainingArea = TrainingArea.all,
    int itemCount = 3,
    DateTime? createdAt,
  }) {
    return repository.createSessionFromQueueResult(
      categoryId: categoryId,
      mode: mode,
      trainingArea: trainingArea,
      sessionSize: 20,
      queueBuildResult: queueResult(count: itemCount, mode: mode),
      now: createdAt ?? now,
    );
  }

  group('LearningSessionRepository', () {
    test('find_active_session_returns_existing_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWords(db, 3);
      final repository = LearningSessionRepository(database: db);
      final created = await createSession(repository);

      final found = await repository.findActiveSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
      );
      final missing = await repository.findActiveSession(
        categoryId: 'category-1',
        mode: LearningMode.hybrid,
        trainingArea: TrainingArea.all,
      );

      expect(found, isNotNull);
      expect(found!.id, created.id);
      expect(found.status, 'active');
      expect(found.currentPosition, 0);
      expect(missing, isNull);
    });

    test('create_session_stores_session_and_items_in_order', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWords(db, 4);
      final repository = LearningSessionRepository(database: db);

      final session = await createSession(repository, itemCount: 4);
      final items = await repository.loadSessionItems(session.id);

      expect(session.status, 'active');
      expect(session.sessionSize, 20);
      expect(items, hasLength(4));
      expect(items.map((item) => item.position), [0, 1, 2, 3]);
      expect(items.map((item) => item.wordId), [
        'word-0',
        'word-1',
        'word-2',
        'word-3',
      ]);
      expect(items.first.isNewCard, isTrue);
      expect(items.first.status, QueueItemStatus.queued);
    });

    test('create_session_requires_existing_non_system_category', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repository = LearningSessionRepository(database: db);

      expect(
        () => repository.createSessionFromQueueResult(
          categoryId: 'missing-category',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          sessionSize: 20,
          queueBuildResult: emptyQueueResult(),
          now: now,
        ),
        throwsA(isA<StateError>()),
      );

      expect(await db.query('learning_sessions'), isEmpty);
    });

    test('create_session_ensures_local_my_words_system_category', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repository = LearningSessionRepository(database: db);

      final session = await repository.createSessionFromQueueResult(
        categoryId: 'local-category-my-words',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        sessionSize: 20,
        queueBuildResult: emptyQueueResult(),
        now: now,
      );

      final categories = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: ['local-category-my-words'],
      );
      expect(categories, hasLength(1));
      expect(categories.single['name'], 'Meine Wörter');
      expect(session.categoryId, 'local-category-my-words');
    });

    test('cannot_create_second_active_session_for_same_context', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWords(db, 3);
      final repository = LearningSessionRepository(database: db);

      final first = await createSession(repository);
      final second = await createSession(repository);

      expect(second.id, first.id);
      final rows = await db.query('learning_sessions');
      expect(rows, hasLength(1));
    });

    test(
      'completed_session_allows_new_active_session_for_same_context',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWords(db, 3);
        final repository = LearningSessionRepository(database: db);

        final first = await createSession(repository);
        await repository.completeSession(
          sessionId: first.id,
          completedAt: now.add(const Duration(minutes: 10)),
        );
        final second = await createSession(
          repository,
          createdAt: now.add(const Duration(minutes: 11)),
        );

        expect(second.id, isNot(first.id));
        final rows = await db.query('learning_sessions');
        expect(rows, hasLength(2));
        expect(rows.where((row) => row['status'] == 'active'), hasLength(1));
        expect(rows.where((row) => row['status'] == 'completed'), hasLength(1));
      },
    );

    test('load_session_items_returns_items_ordered_by_position', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWords(db, 3);
      final repository = LearningSessionRepository(database: db);
      final session = await createSession(repository);

      await db.update(
        'session_items',
        {'position': 10},
        where: 'word_id = ?',
        whereArgs: ['word-0'],
      );

      final items = await repository.loadSessionItems(session.id);

      expect(items.map((item) => item.position), [1, 2, 10]);
      expect(items.map((item) => item.wordId), ['word-1', 'word-2', 'word-0']);
    });

    test('find_latest_session_with_items_skips_newer_empty_sessions', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWords(db, 3);
      final repository = LearningSessionRepository(database: db);

      final learnedSession = await createSession(
        repository,
        itemCount: 2,
        createdAt: now,
      );
      await repository.completeSession(
        sessionId: learnedSession.id,
        completedAt: now.add(const Duration(minutes: 10)),
      );
      final emptySession = await createSession(
        repository,
        itemCount: 0,
        createdAt: now.add(const Duration(minutes: 20)),
      );

      final latest = await repository.findLatestSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
      );
      final latestWithItems = await repository.findLatestSessionWithItems(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
      );

      expect(latest!.id, emptySession.id);
      expect(latestWithItems!.id, learnedSession.id);
    });

    test('update_current_position_persists_position', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWords(db, 3);
      final repository = LearningSessionRepository(database: db);
      final session = await createSession(repository);
      final updatedAt = now.add(const Duration(minutes: 5));

      await repository.updateCurrentPosition(
        sessionId: session.id,
        position: 2,
        now: updatedAt,
      );

      final found = await repository.findActiveSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
      );

      expect(found!.currentPosition, 2);
      expect(found.lastActivityAt, updatedAt);
      expect(found.updatedAt, updatedAt);
    });

    test(
      'add_requeue_item_creates_new_item_and_keeps_original_answered',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWords(db, 3);
        final repository = LearningSessionRepository(database: db);
        final session = await createSession(repository);
        final original = (await repository.loadSessionItems(session.id)).first;
        final requeuedAt = now.add(const Duration(minutes: 3));

        final requeueItem = await repository.addRequeueItem(
          sessionId: session.id,
          originalItemId: original.id,
          wordId: original.wordId,
          categoryId: original.categoryId,
          mode: original.mode,
          stageAtEnqueue: SrsStage.s1,
          sameSessionWrongCount: 2,
          requeueReason: RequeueReason.repeatedWrongAnswer,
          retryAfterPosition: 5,
          now: requeuedAt,
        );

        final items = await repository.loadSessionItems(session.id);
        final updatedOriginal = items.singleWhere(
          (item) => item.id == original.id,
        );

        expect(items, hasLength(4));
        expect(updatedOriginal.status, QueueItemStatus.answered);
        expect(updatedOriginal.answeredAt, requeuedAt);
        expect(requeueItem.position, 3);
        expect(requeueItem.status, QueueItemStatus.retryPending);
        expect(requeueItem.wordId, original.wordId);
        expect(requeueItem.stageAtEnqueue, SrsStage.s1);
        expect(requeueItem.sameSessionWrongCount, 2);
        expect(requeueItem.requeueReason, RequeueReason.repeatedWrongAnswer);
        expect(requeueItem.retryAfterPosition, 5);
      },
    );
  });
}
