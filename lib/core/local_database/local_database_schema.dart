import 'package:sqflite/sqflite.dart';

class LocalDatabaseSchema {
  const LocalDatabaseSchema._();

  static const int version = 2;

  static Future<void> createV1(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');

    await db.execute('''
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE words (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  term TEXT NOT NULL,
  translation TEXT NOT NULL,
  translation_status TEXT NOT NULL DEFAULT 'translated',
  source_language TEXT,
  target_language TEXT,
  translation_error TEXT,
  example_sentence TEXT,
  notes TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id)
)
''');

    await db.execute(
      'CREATE INDEX idx_words_category_id ON words (category_id)',
    );

    await db.execute('''
CREATE TABLE word_progress (
  id TEXT PRIMARY KEY,
  word_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  mode_id TEXT NOT NULL,
  stage TEXT NOT NULL,
  pass_count INTEGER NOT NULL DEFAULT 0,
  wrong_count INTEGER NOT NULL DEFAULT 0,
  next_due_at TEXT,
  last_reviewed_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE (word_id, category_id, mode_id),
  FOREIGN KEY (word_id) REFERENCES words (id),
  FOREIGN KEY (category_id) REFERENCES categories (id)
)
''');

    await db.execute('''
CREATE INDEX idx_word_progress_due
ON word_progress (category_id, mode_id, next_due_at)
''');
    await db.execute(
      'CREATE INDEX idx_word_progress_word_id ON word_progress (word_id)',
    );
    await db.execute(
      'CREATE INDEX idx_word_progress_stage ON word_progress (stage)',
    );

    await db.execute('''
CREATE TABLE learning_sessions (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  mode_id TEXT NOT NULL,
  training_area_id TEXT NOT NULL,
  status TEXT NOT NULL,
  session_size INTEGER NOT NULL,
  current_position INTEGER NOT NULL DEFAULT 0,
  started_at TEXT NOT NULL,
  last_activity_at TEXT NOT NULL,
  completed_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id)
)
''');

    await db.execute('''
CREATE INDEX idx_learning_sessions_context_status
ON learning_sessions (category_id, mode_id, training_area_id, status)
''');
    await db.execute('''
CREATE INDEX idx_learning_sessions_last_activity
ON learning_sessions (last_activity_at)
''');
    await db.execute('''
CREATE UNIQUE INDEX idx_learning_sessions_one_active_context
ON learning_sessions (category_id, mode_id, training_area_id)
WHERE status = 'active'
''');

    await db.execute('''
CREATE TABLE review_history (
  id TEXT PRIMARY KEY,
  word_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  mode_id TEXT NOT NULL,
  training_area_id TEXT NOT NULL,
  session_id TEXT,
  answer TEXT NOT NULL,
  reviewed_at TEXT NOT NULL,
  old_stage TEXT NOT NULL,
  new_stage TEXT NOT NULL,
  old_pass_count INTEGER NOT NULL,
  new_pass_count INTEGER NOT NULL,
  old_next_due_at TEXT,
  new_next_due_at TEXT,
  requeue_reason TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (word_id) REFERENCES words (id),
  FOREIGN KEY (category_id) REFERENCES categories (id),
  FOREIGN KEY (session_id) REFERENCES learning_sessions (id)
)
''');

    await db.execute(
      'CREATE INDEX idx_review_history_word_id ON review_history (word_id)',
    );
    await db.execute('''
CREATE INDEX idx_review_history_category_mode_reviewed
ON review_history (category_id, mode_id, reviewed_at)
''');
    await db.execute(
      'CREATE INDEX idx_review_history_session_id ON review_history (session_id)',
    );

    await db.execute('''
CREATE TABLE session_items (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  word_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  mode_id TEXT NOT NULL,
  stage_at_enqueue TEXT NOT NULL,
  position INTEGER NOT NULL,
  status TEXT NOT NULL,
  is_new_card INTEGER NOT NULL DEFAULT 0,
  due_at_enqueue TEXT,
  retry_after_position INTEGER,
  requeue_reason TEXT,
  same_session_wrong_count INTEGER NOT NULL DEFAULT 0,
  shown_at TEXT,
  answered_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE (session_id, position),
  FOREIGN KEY (session_id) REFERENCES learning_sessions (id),
  FOREIGN KEY (word_id) REFERENCES words (id),
  FOREIGN KEY (category_id) REFERENCES categories (id)
)
''');

    await db.execute('''
CREATE INDEX idx_session_items_session_position
ON session_items (session_id, position)
''');
    await db.execute('''
CREATE INDEX idx_session_items_session_status
ON session_items (session_id, status)
''');
    await db.execute('''
CREATE INDEX idx_session_items_session_word
ON session_items (session_id, word_id)
''');

    await db.execute('''
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  value_type TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
  }

  static Future<void> migrateV1ToV2(Database db) async {
    await db.execute(
      "ALTER TABLE words ADD COLUMN translation_status TEXT NOT NULL DEFAULT 'translated'",
    );
    await db.execute('ALTER TABLE words ADD COLUMN source_language TEXT');
    await db.execute('ALTER TABLE words ADD COLUMN target_language TEXT');
    await db.execute('ALTER TABLE words ADD COLUMN translation_error TEXT');
    await db.execute('''
UPDATE words
SET translation_status = CASE
  WHEN TRIM(translation) = '' THEN 'pending'
  ELSE 'translated'
END
''');
  }
}
