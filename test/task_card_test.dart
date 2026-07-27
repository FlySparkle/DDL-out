import 'dart:convert';

import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/task_details/task_detail_document.dart';
import 'package:ddl_out/data/task_details/task_detail_image.dart';
import 'package:ddl_out/features/board/application/task_image_viewer.dart';
import 'package:ddl_out/features/board/presentation/widgets/task_card.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('only the visible handle starts desktop task dragging', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 7, 19, 12);
    final task = Task(
      id: 1,
      name: 'Ship release',
      details: '',
      detailImagesJson: '[]',
      deadlineUtc: now.toUtc().add(const Duration(hours: 2)),
      categoryId: null,
      isCompleted: false,
      createdAtUtc: now.toUtc(),
      updatedAtUtc: now.toUtc(),
      completedAtUtc: null,
    );
    final snapshot = BoardSnapshot(categories: const [], tasks: [task]);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TaskCard(
              task: task,
              snapshot: snapshot,
              categoryColor: Colors.blue,
              longestRemaining: const Duration(hours: 4),
              now: now,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final handle = find.byWidgetPredicate(
      (widget) => widget is Tooltip && widget.message == 'Drag to move task',
    );
    expect(handle, findsOneWidget);
    expect(
      find.ancestor(of: handle, matching: find.byType(Draggable<int>)),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Ship release'),
        matching: find.byType(Draggable<int>),
      ),
      findsNothing,
    );
    final track = tester.widget<Positioned>(
      find.byKey(const ValueKey('deadline-progress-track')),
    );
    expect(track.left, 0);
    expect(track.right, 0);
    final progress = tester.widget<AnimatedFractionallySizedBox>(
      find.byKey(const ValueKey('deadline-progress')),
    );
    expect(progress.widthFactor, 0.5);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
    expect(find.byTooltip('Task actions'), findsNothing);
  });

  testWidgets('hidden handle uses the whole row as a long-press drag target', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'show_task_drag_handle': false});
    final now = DateTime(2026, 7, 19, 12);
    final task = Task(
      id: 1,
      name: 'Long press task',
      details: '',
      detailImagesJson: '[]',
      deadlineUtc: now.toUtc().add(const Duration(hours: 2)),
      categoryId: null,
      isCompleted: false,
      createdAtUtc: now.toUtc(),
      updatedAtUtc: now.toUtc(),
      completedAtUtc: null,
    );
    final snapshot = BoardSnapshot(categories: const [], tasks: [task]);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TaskCard(
              task: task,
              snapshot: snapshot,
              categoryColor: Colors.blue,
              longestRemaining: const Duration(hours: 4),
              now: now,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.drag_indicator), findsNothing);
    expect(find.byTooltip('Drag to move task'), findsNothing);
    expect(find.byType(Draggable<int>), findsNothing);
    expect(find.byType(LongPressDraggable<int>), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Long press task'),
        matching: find.byType(LongPressDraggable<int>),
      ),
      findsOneWidget,
    );
  });

  testWidgets('mobile task handle starts after a brief 120ms press', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 7, 19, 12);
    final task = Task(
      id: 1,
      name: 'Touch task',
      details: '',
      detailImagesJson: '[]',
      deadlineUtc: now.toUtc().add(const Duration(hours: 2)),
      categoryId: null,
      isCompleted: false,
      createdAtUtc: now.toUtc(),
      updatedAtUtc: now.toUtc(),
      completedAtUtc: null,
    );
    final snapshot = BoardSnapshot(categories: const [], tasks: [task]);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TaskCard(
              task: task,
              snapshot: snapshot,
              categoryColor: Colors.blue,
              longestRemaining: const Duration(hours: 2),
              now: now,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final draggable = find.byType(LongPressDraggable<int>);
    expect(draggable, findsOneWidget);
    final gesture = await tester.startGesture(tester.getCenter(draggable));
    await tester.pump(const Duration(milliseconds: 130));
    await gesture.moveBy(const Offset(30, 30));
    await tester.pump();

    expect(find.text('Touch task'), findsNWidgets(2));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('task card separates title from persisted details', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 7, 19, 12);
    final task = Task(
      id: 1,
      name: 'Card title',
      details: 'Card details',
      detailImagesJson: '[]',
      deadlineUtc: now.toUtc().add(const Duration(hours: 2)),
      categoryId: null,
      isCompleted: false,
      createdAtUtc: now.toUtc(),
      updatedAtUtc: now.toUtc(),
      completedAtUtc: null,
      syncId: null,
      deletedAtUtc: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TaskCard(
              task: task,
              snapshot: BoardSnapshot(categories: const [], tasks: [task]),
              categoryColor: Colors.blue,
              longestRemaining: const Duration(hours: 2),
              now: now,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Card title'), findsOneWidget);
    expect(find.text('Card details'), findsOneWidget);
    expect(find.byKey(const ValueKey('task-details-block')), findsOneWidget);
  });

  testWidgets('embedded card image opens a fresh viewer on every double click', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 7, 19, 12);
    final viewer = _RecordingTaskImageViewer();
    final image = TaskDetailImage(
      id: 'embedded',
      mimeType: 'image/png',
      bytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );
    final document = TaskDetailDocument([
      const TaskDetailTextBlock('Before image'),
      TaskDetailImageBlock(image),
      const TaskDetailTextBlock('After image'),
    ]);
    final task = Task(
      id: 1,
      name: 'Mixed detail',
      details: TaskDetailDocumentCodec.encode(document),
      detailImagesJson: TaskDetailImageCodec.encode([image]),
      deadlineUtc: now.toUtc().add(const Duration(hours: 2)),
      categoryId: null,
      isCompleted: false,
      createdAtUtc: now.toUtc(),
      updatedAtUtc: now.toUtc(),
      completedAtUtc: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskImageViewerProvider.overrideWithValue(viewer)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TaskCard(
              task: task,
              snapshot: BoardSnapshot(categories: const [], tasks: [task]),
              categoryColor: Colors.blue,
              longestRemaining: const Duration(hours: 2),
              now: now,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Before image'), findsOneWidget);
    expect(find.text('After image'), findsOneWidget);
    final embeddedImage = find.byKey(
      const ValueKey('task-card-detail-image-embedded'),
    );
    await tester.ensureVisible(embeddedImage);
    final desktopImagePoint = tester.getCenter(
      find.descendant(of: embeddedImage, matching: find.byType(Image)),
    );
    await tester.tapAt(desktopImagePoint);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(desktopImagePoint);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(desktopImagePoint);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(desktopImagePoint);
    await tester.pump(const Duration(milliseconds: 400));

    expect(viewer.openedImageIds, ['embedded', 'embedded']);
  });

  testWidgets('mobile embedded image opens full-screen viewer with one tap', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 7, 19, 12);
    final viewer = _RecordingTaskImageViewer();
    final image = TaskDetailImage(
      id: 'mobile-image',
      mimeType: 'image/png',
      bytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );
    final document = TaskDetailDocument([TaskDetailImageBlock(image)]);
    final task = Task(
      id: 2,
      name: 'Mobile image',
      details: TaskDetailDocumentCodec.encode(document),
      detailImagesJson: TaskDetailImageCodec.encode([image]),
      deadlineUtc: now.toUtc().add(const Duration(hours: 2)),
      categoryId: null,
      isCompleted: false,
      createdAtUtc: now.toUtc(),
      updatedAtUtc: now.toUtc(),
      completedAtUtc: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskImageViewerProvider.overrideWithValue(viewer)],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TaskCard(
              task: task,
              snapshot: BoardSnapshot(categories: const [], tasks: [task]),
              categoryColor: Colors.blue,
              longestRemaining: const Duration(hours: 2),
              now: now,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final embeddedImage = find.byKey(
      const ValueKey('task-card-detail-image-mobile-image'),
    );
    await tester.ensureVisible(embeddedImage);
    await tester.tap(
      find.descendant(of: embeddedImage, matching: find.byType(Image)),
    );
    await tester.pump();

    expect(viewer.openedImageIds, ['mobile-image']);
  });
}

final class _RecordingTaskImageViewer implements TaskImageViewer {
  final openedImageIds = <String>[];

  @override
  Future<void> open(BuildContext context, TaskDetailImage image) async {
    openedImageIds.add(image.id);
  }
}
