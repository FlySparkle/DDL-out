import 'dart:io';

import 'package:ddl_out/data/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('schema 5 upgrades deadline_utc from required to nullable', () async {
    final directory = await Directory.systemTemp.createTemp(
      'ddl-out-migration-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'migration.sqlite'));
    var database = AppDatabase(NativeDatabase(file));
    final deadline = DateTime.utc(2026, 8, 12, 12);
    await database.createTask(
      name: 'Existing task',
      deadlineUtc: deadline,
      categoryId: null,
    );

    await database.customStatement('PRAGMA foreign_keys = OFF');
    await database.customStatement('''
      CREATE TABLE tasks_v5 (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT,
        name TEXT NOT NULL,
        details TEXT NOT NULL DEFAULT '',
        detail_images_json TEXT NOT NULL DEFAULT '[]',
        deadline_utc INTEGER NOT NULL,
        category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
        position_key TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at_utc INTEGER NOT NULL,
        updated_at_utc INTEGER NOT NULL,
        completed_at_utc INTEGER,
        deleted_at_utc INTEGER
      )
    ''');
    await database.customStatement('INSERT INTO tasks_v5 SELECT * FROM tasks');
    await database.customStatement('DROP TABLE tasks');
    await database.customStatement('ALTER TABLE tasks_v5 RENAME TO tasks');
    await database.customStatement('PRAGMA user_version = 5');
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    final task = (await database.readTasks()).single;
    expect(task.deadlineUtc!.toUtc(), deadline);

    await database.updateTask(
      task: task,
      name: task.name,
      deadlineUtc: null,
      categoryId: task.categoryId,
    );
    expect((await database.readTasks()).single.deadlineUtc, null);
  });
}
