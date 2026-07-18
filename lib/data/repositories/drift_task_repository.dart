import '../database/app_database.dart';
import 'task_repository.dart';

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

  @override
  Future<void> clearCompletedInCategory(int? categoryId) =>
      _database.clearCompletedInCategory(categoryId);
}
