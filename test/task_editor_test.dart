import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/repositories/board_providers.dart';
import 'package:ddl_out/data/repositories/task_repository.dart';
import 'package:ddl_out/features/board/presentation/dialogs/task_editor.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('switching deadline input modes preserves an overdue deadline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _RecordingTaskRepository();
    final deadline = DateTime.now().subtract(const Duration(hours: 3)).toUtc();
    final task = Task(
      id: 1,
      name: 'Overdue task',
      deadlineUtc: deadline,
      categoryId: null,
      isCompleted: false,
      createdAtUtc: deadline,
      updatedAtUtc: deadline,
      completedAtUtc: null,
    );
    final snapshot = BoardSnapshot(categories: const [], tasks: [task]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TaskEditor(
              snapshot: snapshot,
              initialCategoryId: null,
              task: task,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remaining time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Date and time'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(repository.updatedDeadline, isNotNull);
    expect(
      repository.updatedDeadline!.difference(deadline).inMinutes.abs(),
      lessThanOrEqualTo(1),
    );
  });

  testWidgets('deadline editor exposes quick deadline choices', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: TaskEditor(
              snapshot: BoardSnapshot(categories: [], tasks: []),
              initialCategoryId: null,
              task: null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('In 1 hour'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('This weekend'), findsOneWidget);
  });
}

class _RecordingTaskRepository implements TaskRepository {
  DateTime? updatedDeadline;

  @override
  Future<void> clearCompletedInCategory(int? categoryId) async {}

  @override
  Future<void> clearCompleted() async {}

  @override
  Future<int> create({
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
  }) async => 1;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> move(int taskId, int? categoryId) async {}

  @override
  Future<void> setCompleted(int taskId, bool completed) async {}

  @override
  Future<void> update({
    required Task task,
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
  }) async {
    updatedDeadline = deadlineUtc;
  }
}
