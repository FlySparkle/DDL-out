import 'dart:convert';

import 'package:ddl_out/data/backup/backup_service.dart';
import 'package:ddl_out/data/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase source;
  late AppDatabase target;

  setUp(() {
    source = AppDatabase(NativeDatabase.memory());
    target = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('backup round trip preserves categories and tasks', () async {
    final categoryId = await source.createCategory('项目', 0xFF4A90E2);
    await source.createTask(
      name: '发布版本',
      deadlineUtc: DateTime.utc(2026, 8, 1, 12),
      categoryId: categoryId,
    );
    final sourceService = BackupService(source);
    final bytes = await sourceService.createBackupBytes();
    final preview = BackupService(target).parseBackup(bytes);

    await BackupService(target).restore(preview);

    expect((await target.readCategories()).single.name, '项目');
    final task = (await target.readTasks()).single;
    expect(task.name, '发布版本');
    expect(task.categoryId, categoryId);
    expect(task.deadlineUtc.toUtc(), DateTime.utc(2026, 8, 1, 12));
  });

  test('future schema version is rejected', () {
    final bytes = utf8.encode(
      jsonEncode({
        'schemaVersion': 999,
        'categories': <Object>[],
        'tasks': <Object>[],
      }),
    );
    expect(
      () => BackupService(target).parseBackup(bytes),
      throwsA(isA<BackupException>()),
    );
  });

  test('dangling category reference is rejected', () {
    final now = DateTime.now().toUtc().toIso8601String();
    final bytes = utf8.encode(
      jsonEncode({
        'schemaVersion': 1,
        'categories': <Object>[],
        'tasks': [
          {
            'id': 1,
            'name': '错误事项',
            'deadlineUtc': now,
            'categoryId': 99,
            'isCompleted': false,
            'createdAtUtc': now,
            'updatedAtUtc': now,
            'completedAtUtc': null,
          },
        ],
      }),
    );
    expect(
      () => BackupService(target).parseBackup(bytes),
      throwsA(isA<BackupException>()),
    );
  });
}
