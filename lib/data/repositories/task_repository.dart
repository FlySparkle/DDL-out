import '../database/app_database.dart';

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
  Future<void> clearCategory(int? categoryId);
}
