import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get colorArgb => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  DateTimeColumn get deadlineUtc => dateTime()();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  DateTimeColumn get completedAtUtc => dateTime().nullable()();
}

class BoardSnapshot {
  const BoardSnapshot({required this.categories, required this.tasks});

  final List<Category> categories;
  final List<Task> tasks;

  int get completedCount => tasks.where((task) => task.isCompleted).length;
}

@DriftDatabase(tables: [Categories, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'ddl_out'));

  @override
  int get schemaVersion => 2;

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
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Stream<BoardSnapshot> watchBoard() {
    final trigger = customSelect(
      'SELECT 1 AS marker',
      readsFrom: {categories, tasks},
    );
    return trigger.watch().asyncMap((_) async {
      final categoryRows =
          await (select(categories)..orderBy([
                (row) => OrderingTerm.asc(row.sortOrder),
                (row) => OrderingTerm.asc(row.id),
              ]))
              .get();
      final taskRows =
          await (select(tasks)..orderBy([
                (row) => OrderingTerm.asc(row.isCompleted),
                (row) => OrderingTerm.asc(row.deadlineUtc),
                (row) => OrderingTerm.asc(row.id),
              ]))
              .get();
      return BoardSnapshot(categories: categoryRows, tasks: taskRows);
    });
  }

  Future<List<Category>> readCategories() =>
      (select(categories)..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.id),
          ]))
          .get();

  Future<List<Task>> readTasks() =>
      (select(tasks)..orderBy([(row) => OrderingTerm.asc(row.id)])).get();

  Future<int> createCategory(String name, int colorArgb) async {
    final now = DateTime.now().toUtc();
    final maximum = categories.sortOrder.max();
    final query = selectOnly(categories)..addColumns([maximum]);
    final lastOrder = await query.map((row) => row.read(maximum)).getSingle();
    return into(categories).insert(
      CategoriesCompanion.insert(
        name: name.trim(),
        colorArgb: colorArgb,
        sortOrder: Value((lastOrder ?? -1) + 1),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<void> updateCategory(Category category, String name, int colorArgb) {
    return (update(
      categories,
    )..where((row) => row.id.equals(category.id))).write(
      CategoriesCompanion(
        name: Value(name.trim()),
        colorArgb: Value(colorArgb),
        updatedAtUtc: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> reorderCategories(List<int> categoryIds) async {
    final now = DateTime.now().toUtc();
    await batch((batch) {
      for (final (index, id) in categoryIds.indexed) {
        batch.update(
          categories,
          CategoriesCompanion(
            sortOrder: Value(index),
            updatedAtUtc: Value(now),
          ),
          where: (row) => row.id.equals(id),
        );
      }
    });
  }

  Future<void> deleteCategory(int id) async {
    await transaction(() async {
      await (update(tasks)..where((row) => row.categoryId.equals(id))).write(
        const TasksCompanion(categoryId: Value(null)),
      );
      await (delete(categories)..where((row) => row.id.equals(id))).go();
    });
  }

  Future<void> clearCategories() async {
    await transaction(() async {
      await update(tasks).write(const TasksCompanion(categoryId: Value(null)));
      await delete(categories).go();
    });
  }

  Future<int> createTask({
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
  }) {
    final now = DateTime.now().toUtc();
    return into(tasks).insert(
      TasksCompanion.insert(
        name: name.trim(),
        deadlineUtc: deadlineUtc.toUtc(),
        categoryId: Value(categoryId),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<void> updateTask({
    required Task task,
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
  }) {
    return (update(tasks)..where((row) => row.id.equals(task.id))).write(
      TasksCompanion(
        name: Value(name.trim()),
        deadlineUtc: Value(deadlineUtc.toUtc()),
        categoryId: Value(categoryId),
        updatedAtUtc: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> moveTask(int taskId, int? categoryId) {
    return (update(tasks)..where((row) => row.id.equals(taskId))).write(
      TasksCompanion(
        categoryId: Value(categoryId),
        updatedAtUtc: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> setTaskCompleted(int taskId, bool completed) {
    final now = DateTime.now().toUtc();
    return (update(tasks)..where((row) => row.id.equals(taskId))).write(
      TasksCompanion(
        isCompleted: Value(completed),
        completedAtUtc: Value(completed ? now : null),
        updatedAtUtc: Value(now),
      ),
    );
  }

  Future<void> deleteTask(int id) =>
      (delete(tasks)..where((row) => row.id.equals(id))).go();

  Future<void> clearCompleted() =>
      (delete(tasks)..where((row) => row.isCompleted.equals(true))).go();

  Future<void> clearTasksInCategory(int? categoryId) {
    final query = delete(tasks);
    query.where(
      (row) => categoryId == null
          ? row.categoryId.isNull()
          : row.categoryId.equals(categoryId),
    );
    return query.go();
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(tasks).go();
      await delete(categories).go();
    });
  }

  Future<void> replaceAll({
    required List<CategoriesCompanion> categoryRows,
    required List<TasksCompanion> taskRows,
  }) async {
    await transaction(() async {
      await delete(tasks).go();
      await delete(categories).go();
      await batch((batch) {
        batch.insertAll(categories, categoryRows);
        batch.insertAll(tasks, taskRows);
      });
    });
  }
}
