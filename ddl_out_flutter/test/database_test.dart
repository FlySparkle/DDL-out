import 'package:ddl_out/data/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('category deletion preserves tasks as uncategorized', () async {
    final categoryId = await database.createCategory('工作', 0xFF4A90E2);
    final taskId = await database.createTask(
      name: '提交报告',
      deadlineUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
      categoryId: categoryId,
    );

    await database.deleteCategory(categoryId);

    expect(await database.readCategories(), isEmpty);
    final tasks = await database.readTasks();
    expect(tasks.single.id, taskId);
    expect(tasks.single.categoryId, isNull);
  });

  test('clear completed only removes completed tasks', () async {
    final first = await database.createTask(
      name: '完成项',
      deadlineUtc: DateTime.now().toUtc(),
      categoryId: null,
    );
    await database.createTask(
      name: '未完成项',
      deadlineUtc: DateTime.now().toUtc(),
      categoryId: null,
    );
    await database.setTaskCompleted(first, true);

    await database.clearCompleted();

    final tasks = await database.readTasks();
    expect(tasks, hasLength(1));
    expect(tasks.single.name, '未完成项');
  });

  test('board stream emits database changes', () async {
    final emissions = <BoardSnapshot>[];
    final subscription = database.watchBoard().listen(emissions.add);
    await database.createCategory('生活', 0xFF50E3C2);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(emissions.last.categories.single.name, '生活');
    await subscription.cancel();
  });
}
