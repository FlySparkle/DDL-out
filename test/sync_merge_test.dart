import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/sync/sync_models.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('version vector', () {
    test('joins and compares causal histories', () {
      final first = VersionVector({'phone': 2});
      final second = VersionVector({'phone': 1, 'computer': 3});

      expect(first.covers(second), isFalse);
      first.join(second);

      expect(first.toJson(), {'phone': 2, 'computer': 3});
      expect(first.covers(second), isTrue);
    });
  });

  group('two-device merge', () {
    late AppDatabase computer;
    late AppDatabase phone;

    setUp(() {
      computer = AppDatabase(NativeDatabase.memory());
      phone = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await computer.close();
      await phone.close();
    });

    test('concurrent edits of the same field require approval', () async {
      await _seedAndPair(computer, phone);
      final computerTask = (await computer.readTasks()).single;
      final phoneTask = (await phone.readTasks()).single;

      await computer.updateTask(
        task: computerTask,
        name: '电脑版本',
        deadlineUtc: computerTask.deadlineUtc,
        categoryId: computerTask.categoryId,
      );
      await phone.updateTask(
        task: phoneTask,
        name: '手机版本',
        deadlineUtc: phoneTask.deadlineUtc,
        categoryId: phoneTask.categoryId,
      );

      await _exchange(computer, phone);

      expect(await computer.openConflictCount(), 1);
      expect(await phone.openConflictCount(), 1);
      expect(
        await computer.computeSyncStateDigest(),
        await phone.computeSyncStateDigest(),
      );

      final conflict = await computer.watchOpenConflicts().first;
      final chosen = conflict.single.candidates.firstWhere(
        (candidate) => candidate.value == '电脑版本',
      );
      await computer.resolveSyncConflict(conflict.single.id, chosen.value);
      await _exchange(computer, phone);

      expect(await computer.openConflictCount(), 0);
      expect(await phone.openConflictCount(), 0);
      expect((await phone.readTasks()).single.name, '电脑版本');
    });

    test('concurrent edits of different fields merge automatically', () async {
      await _seedAndPair(computer, phone);
      final computerTask = (await computer.readTasks()).single;
      final phoneTask = (await phone.readTasks()).single;
      final changedDeadline = DateTime.utc(2026, 9, 9, 9, 9);

      await computer.updateTask(
        task: computerTask,
        name: '电脑改名',
        deadlineUtc: computerTask.deadlineUtc,
        categoryId: computerTask.categoryId,
      );
      await phone.updateTask(
        task: phoneTask,
        name: phoneTask.name,
        deadlineUtc: changedDeadline,
        categoryId: phoneTask.categoryId,
      );

      await _exchange(computer, phone);

      for (final database in [computer, phone]) {
        final task = (await database.readTasks()).single;
        expect(task.name, '电脑改名');
        expect(task.deadlineUtc.toUtc(), changedDeadline);
        expect(await database.openConflictCount(), 0);
      }
    });

    test('a concurrent deletion remains deleted after merge', () async {
      await _seedAndPair(computer, phone);
      final computerTask = (await computer.readTasks()).single;
      final phoneTask = (await phone.readTasks()).single;

      await computer.deleteTask(computerTask.id);
      await phone.updateTask(
        task: phoneTask,
        name: '离线修改',
        deadlineUtc: phoneTask.deadlineUtc,
        categoryId: phoneTask.categoryId,
      );

      await _exchange(computer, phone);

      expect(await computer.readTasks(), isEmpty);
      expect(await phone.readTasks(), isEmpty);
      expect(
        await computer.computeSyncStateDigest(),
        await phone.computeSyncStateDigest(),
      );
    });

    test('task details and pasted images sync to the paired device', () async {
      await _seedAndPair(computer, phone);
      final task = (await computer.readTasks()).single;

      await computer.updateTask(
        task: task,
        name: task.name,
        details: '同步详情',
        detailImagesJson:
            '[{"id":"sync-image","mimeType":"image/png","base64Data":"AQID"}]',
        deadlineUtc: task.deadlineUtc,
        categoryId: task.categoryId,
      );
      await _exchange(computer, phone);

      final remote = (await phone.readTasks()).single;
      expect(remote.details, '同步详情');
      expect(remote.detailImagesJson, contains('sync-image'));
      expect(
        await computer.computeSyncStateDigest(),
        await phone.computeSyncStateDigest(),
      );
    });
  });
}

Future<void> _seedAndPair(AppDatabase computer, AppDatabase phone) async {
  final categoryId = await computer.createCategory('项目', 0xFF4A90E2);
  await computer.createTask(
    name: '提交作业',
    deadlineUtc: DateTime.utc(2026, 8, 1, 12),
    categoryId: categoryId,
  );
  final computerIdentity = await computer.readSyncIdentity();
  await phone.adoptSyncSpace(computerIdentity.spaceId);
  final phoneIdentity = await phone.readSyncIdentity();
  await phone.applyRemoteOperations(
    await computer.readOperationsMissingFrom(phoneIdentity.vector),
  );
}

Future<void> _exchange(AppDatabase first, AppDatabase second) async {
  final firstIdentity = await first.readSyncIdentity();
  final secondIdentity = await second.readSyncIdentity();
  final toFirst = await second.readOperationsMissingFrom(firstIdentity.vector);
  final toSecond = await first.readOperationsMissingFrom(secondIdentity.vector);
  await first.applyRemoteOperations(toFirst);
  await second.applyRemoteOperations(toSecond);
}
