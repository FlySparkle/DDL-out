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
import 'package:ddl_out/features/settings/application/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final mode in [DeadlineMode.relative, DeadlineMode.absolute]) {
    testWidgets('new $mode deadline ignores the remembered duration', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _RecordingTaskRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(repository),
            settingsControllerProvider.overrideWith(
              () => _StoredDeadlineSettings(mode),
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
      if (mode == DeadlineMode.relative) {
        final numbers = tester
            .widgetList<TextField>(find.byType(TextField))
            .where((field) => field.keyboardType == TextInputType.number);
        expect(numbers.map((field) => field.controller!.text), ['0', '0', '0']);
      }
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Task name'),
        'Now',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(repository.createdDeadline, isNotNull);
      expect(
        repository.createdDeadline!
            .difference(DateTime.now().toUtc())
            .inSeconds
            .abs(),
        lessThan(65),
      );
    });
  }

  testWidgets(
    'preview and full screen preserve Markdown source and save edits',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = _RecordingTaskRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [taskRepositoryProvider.overrideWithValue(repository)],
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
        'Reading',
      );
      final editor = tester.state<TaskDetailContentEditorState>(
        find.byType(TaskDetailContentEditor),
      );
      const source = '# Topic\n\n**Keep this source**';
      editor.controller.replaceText(
        0,
        0,
        source,
        const TextSelection.collapsed(offset: 0),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('preview-task-markdown')),
      );
      await tester.tap(find.byKey(const ValueKey('preview-task-markdown')));
      await tester.pumpAndSettle();
      expect(find.text('Full screen'), findsOneWidget);
      expect(find.byKey(const ValueKey('task-details-field')), findsNothing);
      await tester.tap(find.text('Full screen'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('markdown-reader-scroll')),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.fullscreen_exit));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back to editing'));
      await tester.pumpAndSettle();
      expect(editor.controller.document.toPlainText().trim(), source);
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      final document = TaskDetailDocumentCodec.decode(
        details: repository.createdDetails!,
        images: [],
      );
      expect((document.blocks.single as TaskDetailTextBlock).text, source);
    },
  );

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

    expect(find.text('+1d'), findsOneWidget);
    expect(find.text('+1h'), findsOneWidget);
    expect(find.text('+15m'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    final numbers = tester
        .widgetList<TextField>(find.byType(TextField))
        .where((field) => field.keyboardType == TextInputType.number);
    expect(numbers.map((field) => field.controller!.text), ['0', '0', '0']);
    await tester.ensureVisible(find.text('+1h'));
    await tester.tap(find.text('+1h'));
    await tester.tap(find.text('+15m'));
    await tester.pumpAndSettle();
    expect(numbers.map((field) => field.controller!.text), ['0', '1', '15']);
    await tester.ensureVisible(find.text('Date and time'));
    await tester.tap(find.text('Date and time'));
    await tester.pumpAndSettle();
    expect(find.text('+1h'), findsNothing);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('This weekend'), findsOneWidget);
    final modeControl = find.byKey(const ValueKey('deadline-mode'));
    expect(
      find.descendant(of: modeControl, matching: find.text('No deadline')),
      findsOneWidget,
    );
    expect(
      tester.getCenter(find.text('Date and time')).dx,
      lessThan(tester.getCenter(find.text('No deadline')).dx),
    );
  });

  testWidgets('no-deadline mode persists a null deadline', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = _RecordingTaskRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(repository)],
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
      'Someday',
    );
    final noDeadline = find.descendant(
      of: find.byKey(const ValueKey('deadline-mode')),
      matching: find.text('No deadline'),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(noDeadline);
    await tester.pumpAndSettle();
    await tester.tap(noDeadline);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('no-deadline')), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(repository.createCalled, isTrue);
    expect(repository.createdDeadline, isNull);
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

  testWidgets('details editor follows the configured input fill color', (
    tester,
  ) async {
    const fillColor = Color(0xFFEEE2D2);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              fillColor: fillColor,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TaskDetailContentEditor(
              initialDocument: TaskDetailDocumentCodec.decode(
                details: '',
                images: const [],
              ),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(
      find.byKey(const ValueKey('task-detail-content-editor')),
    );
    expect((container.decoration! as BoxDecoration).color, fillColor);
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
  DateTime? createdDeadline;
  bool createCalled = false;
  String? createdDetails;
  String? createdDetailImagesJson;

  @override
  Future<void> clearCompletedInCategory(int? categoryId) async {}

  @override
  Future<void> clearCompleted() async {}

  @override
  Future<int> create({
    required String name,
    required DateTime? deadlineUtc,
    required int? categoryId,
    String details = '',
    String detailImagesJson = '[]',
  }) async {
    createCalled = true;
    createdDeadline = deadlineUtc;
    createdDetails = details;
    createdDetailImagesJson = detailImagesJson;
    return 1;
  }

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> move(int taskId, int? categoryId, {int? index}) async {}

  @override
  Future<void> restore(int id) async {}

  @override
  Future<void> restoreMany(Iterable<int> ids) async {}

  @override
  Future<void> setCompleted(int taskId, bool completed) async {}

  @override
  Future<void> sortByDeadline(int? categoryId) async {}

  @override
  Future<void> update({
    required Task task,
    required String name,
    required DateTime? deadlineUtc,
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

class _StoredDeadlineSettings extends SettingsController {
  _StoredDeadlineSettings(this.mode);
  final DeadlineMode mode;
  @override
  AppSettingsState build() => AppSettingsState(
    hydrated: true,
    deadlineMode: mode,
    relativeDays: 7,
    relativeHours: 4,
    relativeMinutes: 30,
  );
}
