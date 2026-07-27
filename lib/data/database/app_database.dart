import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';

import '../sync/sync_models.dart';

part 'app_database.g.dart';
part 'sync_database.dart';

const _previewDatabase = bool.fromEnvironment('DDL_OUT_PREVIEW');

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get colorArgb => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get positionKey => text().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  DateTimeColumn get deletedAtUtc => dateTime().nullable()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncId => text().nullable()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get details => text().withDefault(const Constant(''))();
  TextColumn get detailImagesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get deadlineUtc => dateTime()();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get positionKey => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  DateTimeColumn get completedAtUtc => dateTime().nullable()();
  DateTimeColumn get deletedAtUtc => dateTime().nullable()();
}

class LocalSyncStates extends Table {
  IntColumn get id => integer()();
  TextColumn get spaceId => text()();
  TextColumn get deviceId => text()();
  TextColumn get deviceName => text()();
  IntColumn get nextSequence => integer().withDefault(const Constant(0))();
  TextColumn get vectorJson => text().withDefault(const Constant('{}'))();
  IntColumn get hlcMillis => integer().withDefault(const Constant(0))();
  IntColumn get hlcCounter => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncDevices extends Table {
  TextColumn get deviceId => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get pairedAtUtc => dateTime()();
  DateTimeColumn get lastSeenAtUtc => dateTime()();
  TextColumn get acknowledgedVectorJson =>
      text().withDefault(const Constant('{}'))();
  BoolColumn get isTrusted => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {deviceId};
}

class SyncOperations extends Table {
  TextColumn get operationId => text()();
  TextColumn get originDeviceId => text()();
  IntColumn get originSequence => integer()();
  TextColumn get contextJson => text()();
  IntColumn get hlcMillis => integer()();
  IntColumn get hlcCounter => integer()();
  TextColumn get transactionId => text().nullable()();
  IntColumn get transactionIndex => integer().nullable()();
  IntColumn get transactionCount => integer().nullable()();
  TextColumn get entityType => text()();
  TextColumn get entitySyncId => text()();
  TextColumn get operationKind => text()();
  TextColumn get changesJson => text()();
  TextColumn get resolvesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get occurredAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {operationId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {originDeviceId, originSequence},
  ];
}

class SyncFieldHeads extends Table {
  TextColumn get entityType => text()();
  TextColumn get entitySyncId => text()();
  TextColumn get fieldName => text()();
  TextColumn get candidateOperationIdsJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entitySyncId, fieldName};
}

class SyncConflicts extends Table {
  TextColumn get conflictId => text()();
  TextColumn get entityType => text()();
  TextColumn get entitySyncId => text()();
  TextColumn get fieldName => text()();
  TextColumn get candidateOperationIdsJson => text()();
  TextColumn get resolvedByOperationId => text().nullable()();
  DateTimeColumn get detectedAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {conflictId};
}

class BoardSnapshot {
  const BoardSnapshot({required this.categories, required this.tasks});

  final List<Category> categories;
  final List<Task> tasks;

  int get completedCount => tasks.where((task) => task.isCompleted).length;
}

@DriftDatabase(
  tables: [
    Categories,
    Tasks,
    LocalSyncStates,
    SyncDevices,
    SyncOperations,
    SyncFieldHeads,
    SyncConflicts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: _previewDatabase ? 'ddl_out_preview' : 'ddl_out',
            ),
      );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(categories, categories.sortOrder);
        await customStatement('UPDATE categories SET sort_order = id');
      }
      if (from < 3) {
        await migrator.addColumn(categories, categories.syncId);
        await migrator.addColumn(categories, categories.positionKey);
        await migrator.addColumn(categories, categories.deletedAtUtc);
        await migrator.addColumn(tasks, tasks.syncId);
        await migrator.addColumn(tasks, tasks.deletedAtUtc);
        await migrator.createTable(localSyncStates);
        await migrator.createTable(syncDevices);
        await migrator.createTable(syncOperations);
        await migrator.createTable(syncFieldHeads);
        await migrator.createTable(syncConflicts);
      }
      if (from < 4) {
        await migrator.addColumn(tasks, tasks.details);
        await migrator.addColumn(tasks, tasks.detailImagesJson);
      }
      if (from < 5) {
        await migrator.addColumn(tasks, tasks.positionKey);
        final rows = await customSelect(
          'SELECT id, category_id FROM tasks '
          'ORDER BY category_id, is_completed, deadline_utc, id',
        ).get();
        final categoryIndexes = <int?, int>{};
        for (final row in rows) {
          final categoryId = row.readNullable<int>('category_id');
          final index = categoryIndexes[categoryId] ?? 0;
          categoryIndexes[categoryId] = index + 1;
          await customStatement(
            'UPDATE tasks SET position_key = ? WHERE id = ?',
            [_positionForIndex(index), row.read<int>('id')],
          );
        }
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await ensureSyncReady();
    },
  );

  Stream<BoardSnapshot> watchBoard() {
    final trigger = customSelect(
      'SELECT 1 AS marker',
      readsFrom: {categories, tasks},
    );
    return trigger.watch().asyncMap((_) async {
      final categoryRows =
          await (select(categories)
                ..where((row) => row.deletedAtUtc.isNull())
                ..orderBy([
                  (row) => OrderingTerm.asc(row.sortOrder),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      final taskRows =
          await (select(tasks)
                ..where((row) => row.deletedAtUtc.isNull())
                ..orderBy([
                  (row) => OrderingTerm.asc(row.positionKey),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      return BoardSnapshot(categories: categoryRows, tasks: taskRows);
    });
  }

  Future<List<Category>> readCategories() =>
      (select(categories)
            ..where((row) => row.deletedAtUtc.isNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.sortOrder),
              (row) => OrderingTerm.asc(row.id),
            ]))
          .get();

  Future<List<Task>> readTasks() =>
      (select(tasks)
            ..where((row) => row.deletedAtUtc.isNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.positionKey),
              (row) => OrderingTerm.asc(row.id),
            ]))
          .get();

  Future<int> createCategory(String name, int colorArgb) async {
    return createSyncedCategory(name, colorArgb);
  }

  Future<void> updateCategory(Category category, String name, int colorArgb) {
    return updateSyncedCategory(category, name, colorArgb);
  }

  Future<void> reorderCategories(List<int> categoryIds) async {
    await reorderSyncedCategories(categoryIds);
  }

  Future<void> deleteCategory(int id) async {
    await deleteSyncedCategory(id);
  }

  Future<void> restoreCategory(int id) => restoreSyncedCategory(id);

  Future<void> clearCategories() async {
    await clearSyncedCategories();
  }

  Future<int> createTask({
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
    String details = '',
    String detailImagesJson = '[]',
  }) {
    return createSyncedTask(
      name: name,
      deadlineUtc: deadlineUtc,
      categoryId: categoryId,
      details: details,
      detailImagesJson: detailImagesJson,
    );
  }

  Future<void> updateTask({
    required Task task,
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
    String? details,
    String? detailImagesJson,
  }) {
    return updateSyncedTask(
      task: task,
      name: name,
      deadlineUtc: deadlineUtc,
      categoryId: categoryId,
      details: details ?? task.details,
      detailImagesJson: detailImagesJson ?? task.detailImagesJson,
    );
  }

  Future<void> moveTask(int taskId, int? categoryId, {int? index}) {
    return moveSyncedTask(taskId, categoryId, index: index);
  }

  Future<void> sortTasksByDeadline(int? categoryId) =>
      sortSyncedTasksByDeadline(categoryId);

  Future<void> setTaskCompleted(int taskId, bool completed) {
    return setSyncedTaskCompleted(taskId, completed);
  }

  Future<void> deleteTask(int id) => deleteSyncedTask(id);

  Future<void> restoreTask(int id) => restoreSyncedTasks([id]);

  Future<void> restoreTasks(Iterable<int> ids) => restoreSyncedTasks(ids);

  Future<void> clearCompleted() => clearSyncedCompleted();

  Future<void> clearCompletedInCategory(int? categoryId) {
    return clearSyncedCompletedInCategory(categoryId);
  }

  Future<void> clearAllData() async {
    await clearAllSyncedData();
  }

  Future<void> restoreSnapshot(BoardSnapshot snapshot) {
    return restoreSyncedSnapshot(snapshot);
  }

  Future<void> replaceAll({
    required List<CategoriesCompanion> categoryRows,
    required List<TasksCompanion> taskRows,
  }) async {
    await prepareForWholeDatabaseRestore();
    await transaction(() async {
      await delete(tasks).go();
      await delete(categories).go();
      await batch((batch) {
        batch.insertAll(categories, categoryRows);
        batch.insertAll(tasks, taskRows);
      });
    });
    await resetSyncHistoryAfterRestore();
  }
}
