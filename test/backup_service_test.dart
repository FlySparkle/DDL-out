import 'dart:convert';

import 'package:ddl_out/core/version/app_version.dart';
import 'package:ddl_out/data/backup/backup_service.dart';
import 'package:ddl_out/data/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAppVersionReader implements AppVersionReader {
  const _TestAppVersionReader(this.value);

  final String value;

  @override
  Future<String> read() async => value;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  const appVersionReader = _TestAppVersionReader('0.1.1+1');
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
    final secondCategoryId = await source.createCategory('生活', 0xFF50E3C2);
    await source.reorderCategories([secondCategoryId, categoryId]);
    await source.createTask(
      name: '发布版本',
      deadlineUtc: DateTime.utc(2026, 8, 1, 12),
      categoryId: categoryId,
    );
    final sourceService = BackupService(source, appVersionReader);
    final bytes = await sourceService.createBackupBytes();
    final payload = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    expect(payload['appVersion'], '0.1.1+1');
    final preview = BackupService(target, appVersionReader).parseBackup(bytes);

    await BackupService(target, appVersionReader).restore(preview);

    expect((await target.readCategories()).map((category) => category.name), [
      '生活',
      '项目',
    ]);
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
      () => BackupService(target, appVersionReader).parseBackup(bytes),
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
      () => BackupService(target, appVersionReader).parseBackup(bytes),
      throwsA(isA<BackupException>()),
    );
  });
}
