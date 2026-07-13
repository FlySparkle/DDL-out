import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'category_repository.dart';
import 'drift_category_repository.dart';
import 'drift_task_repository.dart';
import 'task_repository.dart';

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
