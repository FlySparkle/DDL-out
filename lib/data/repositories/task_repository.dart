import '../database/app_database.dart';

abstract interface class TaskRepository {
  Future<int> create({
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
    String details = '',
    String detailImagesJson = '[]',
  });

  Future<void> update({
    required Task task,
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
    String? details,
    String? detailImagesJson,
  });

  Future<void> move(int taskId, int? categoryId, {int? index});
  Future<void> sortByDeadline(int? categoryId);
  Future<void> setCompleted(int taskId, bool completed);
  Future<void> delete(int id);
  Future<void> restore(int id);
  Future<void> restoreMany(Iterable<int> ids);
  Future<void> clearCompleted();
  Future<void> clearCompletedInCategory(int? categoryId);
}
