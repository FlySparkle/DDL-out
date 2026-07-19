import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/features/board/presentation/widgets/task_card.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('only the visible handle starts desktop task dragging', (
    tester,
  ) async {
    final now = DateTime(2026, 7, 19, 12);
    final task = Task(
      id: 1,
      name: 'Ship release',
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
    final band = tester.widget<Positioned>(
      find.byKey(const ValueKey('task-drag-band')),
    );
    expect(band.width, 48);
    final progress = tester.widget<AnimatedFractionallySizedBox>(
      find.byKey(const ValueKey('deadline-progress')),
    );
    expect(progress.widthFactor, 0.5);
  });

  testWidgets('mobile task handle starts after a brief 120ms press', (
    tester,
  ) async {
    final now = DateTime(2026, 7, 19, 12);
    final task = Task(
      id: 1,
      name: 'Touch task',
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
}
