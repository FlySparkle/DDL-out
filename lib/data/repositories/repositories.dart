import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

abstract interface class CategoryRepository {
  Future<int> create(String name, int colorArgb);
  Future<void> update(Category category, String name, int colorArgb);
  Future<void> reorder(List<int> categoryIds);
  Future<void> delete(int id);
  Future<void> clear();
}

abstract interface class TaskRepository {
  Future<int> create({
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
  });
  Future<void> update({
    required Task task,
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
  });
  Future<void> move(int taskId, int? categoryId);
  Future<void> setCompleted(int taskId, bool completed);
  Future<void> delete(int id);
  Future<void> clearCompleted();
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final boardProvider = StreamProvider<BoardSnapshot>((ref) {
  return ref.watch(appDatabaseProvider).watchBoard();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return DriftCategoryRepository(ref.watch(appDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return DriftTaskRepository(ref.watch(appDatabaseProvider));
});

final class DriftCategoryRepository implements CategoryRepository {
  const DriftCategoryRepository(this._database);

  final AppDatabase _database;

  @override
  Future<int> create(String name, int colorArgb) =>
      _database.createCategory(name, colorArgb);

  @override
  Future<void> update(Category category, String name, int colorArgb) =>
      _database.updateCategory(category, name, colorArgb);

  @override
  Future<void> reorder(List<int> categoryIds) =>
      _database.reorderCategories(categoryIds);

  @override
  Future<void> delete(int id) => _database.deleteCategory(id);

  @override
  Future<void> clear() => _database.clearCategories();
}

final class DriftTaskRepository implements TaskRepository {
  const DriftTaskRepository(this._database);

  final AppDatabase _database;

  @override
  Future<int> create({
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
  }) => _database.createTask(
    name: name,
    deadlineUtc: deadlineUtc,
    categoryId: categoryId,
  );

  @override
  Future<void> update({
    required Task task,
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
  }) => _database.updateTask(
    task: task,
    name: name,
    deadlineUtc: deadlineUtc,
    categoryId: categoryId,
  );

  @override
  Future<void> move(int taskId, int? categoryId) =>
      _database.moveTask(taskId, categoryId);

  @override
  Future<void> setCompleted(int taskId, bool completed) =>
      _database.setTaskCompleted(taskId, completed);

  @override
  Future<void> delete(int id) => _database.deleteTask(id);

  @override
  Future<void> clearCompleted() => _database.clearCompleted();
}
