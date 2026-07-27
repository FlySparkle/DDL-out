import 'dart:convert';

import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/repositories/board_providers.dart';
import 'package:ddl_out/data/repositories/task_repository.dart';
import 'package:ddl_out/data/task_details/task_detail_document.dart';
import 'package:ddl_out/data/task_details/task_detail_image.dart';
import 'package:ddl_out/features/board/application/task_image_clipboard.dart';
import 'package:ddl_out/features/board/presentation/dialogs/task_editor.dart';
import 'package:ddl_out/features/board/presentation/widgets/task_detail_content_editor.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
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
      details: '',
      detailImagesJson: '[]',
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

    await tester.ensureVisible(find.text('Remaining time'));
    await tester.tap(find.text('Remaining time'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Date and time'));
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

  testWidgets('details accepts a pasted image and persists it with the task', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _RecordingTaskRepository();
    final image = TaskDetailImage(
      id: 'clipboard-image',
      mimeType: 'image/png',
      bytes: Uint8List.fromList(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(repository),
          taskImageClipboardProvider.overrideWithValue(
            _FakeTaskImageClipboard([image]),
          ),
        ],
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

    expect(find.byType(QuillEditor), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task name'),
      'Task with image',
    );
    final detailsField = find.byKey(const ValueKey('task-details-field'));
    await tester.tap(detailsField);
    final detailEditor = tester.state<TaskDetailContentEditorState>(
      find.byType(TaskDetailContentEditor),
    );
    detailEditor.controller.replaceText(
      0,
      0,
      'BeforeAfter',
      const TextSelection.collapsed(offset: 11),
    );
    detailEditor.controller.updateSelection(
      const TextSelection.collapsed(offset: 6),
      ChangeSource.local,
    );
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('task-detail-image-clipboard-image')),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final stored = TaskDetailImageCodec.decode(
      repository.createdDetailImagesJson!,
    );
    expect(stored, hasLength(1));
    expect(stored.single.bytes, image.bytes);
    final document = TaskDetailDocumentCodec.decode(
      details: repository.createdDetails!,
      images: stored,
    );
    expect(document.blocks, hasLength(3));
    expect((document.blocks[0] as TaskDetailTextBlock).text, 'Before');
    expect((document.blocks[1] as TaskDetailImageBlock).image.id, image.id);
    expect((document.blocks[2] as TaskDetailTextBlock).text, 'After');
  });

  testWidgets('removing an embedded image drops its persisted bytes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _RecordingTaskRepository();
    final image = TaskDetailImage(
      id: 'removed-image',
      mimeType: 'image/png',
      bytes: Uint8List.fromList(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(repository),
          taskImageClipboardProvider.overrideWithValue(
            _FakeTaskImageClipboard([image]),
          ),
        ],
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

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task name'),
      'Task without image',
    );
    await tester.tap(find.byKey(const ValueKey('task-details-field')));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('task-detail-image-removed-image')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Remove image'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('task-detail-image-removed-image')),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(
      TaskDetailImageCodec.decode(repository.createdDetailImagesJson!),
      isEmpty,
    );
    final document = TaskDetailDocumentCodec.decode(
      details: repository.createdDetails!,
      images: const [],
    );
    expect(document.images, isEmpty);
  });
}

class _RecordingTaskRepository implements TaskRepository {
  DateTime? updatedDeadline;
  String? createdDetails;
  String? createdDetailImagesJson;

  @override
  Future<void> clearCompletedInCategory(int? categoryId) async {}

  @override
  Future<void> clearCompleted() async {}

  @override
  Future<int> create({
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
    String details = '',
    String detailImagesJson = '[]',
  }) async {
    createdDetails = details;
    createdDetailImagesJson = detailImagesJson;
    return 1;
  }

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> move(int taskId, int? categoryId) async {}

  @override
  Future<void> restore(int id) async {}

  @override
  Future<void> restoreMany(Iterable<int> ids) async {}

  @override
  Future<void> setCompleted(int taskId, bool completed) async {}

  @override
  Future<void> update({
    required Task task,
    required String name,
    required DateTime deadlineUtc,
    required int? categoryId,
    String? details,
    String? detailImagesJson,
  }) async {
    updatedDeadline = deadlineUtc;
  }
}

class _FakeTaskImageClipboard implements TaskImageClipboard {
  const _FakeTaskImageClipboard(this.images);

  final List<TaskDetailImage> images;

  @override
  Future<List<TaskDetailImage>> readImages() async => images;
}
