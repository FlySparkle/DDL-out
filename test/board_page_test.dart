import 'dart:ui';

import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/repositories/repositories.dart';
import 'package:ddl_out/features/board/board_page.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('empty board offers category creation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    const snapshot = BoardSnapshot(categories: [], tasks: []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          boardProvider.overrideWith((ref) => Stream.value(snapshot)),
          currentTimeProvider.overrideWith(
            (ref) => Stream.value(DateTime.now()),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
          home: const BoardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有截止事项'), findsOneWidget);
    expect(find.text('新建分类'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('截止事项'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('adaptive desktop sidebar expands from the window edge', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'adaptive_desktop_sidebar': true});
    const snapshot = BoardSnapshot(categories: [], tasks: []);
    await tester.binding.setSurfaceSize(const Size(720, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          boardProvider.overrideWith((ref) => Stream.value(snapshot)),
          currentTimeProvider.overrideWith(
            (ref) => Stream.value(DateTime.now()),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const BoardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.byIcon(Icons.view_sidebar_outlined), findsOneWidget);
    expect(find.text('No deadlines yet'), findsOneWidget);
    expect(find.text('Deadlines'), findsNothing);

    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: const Offset(8, 120));
    await gesture.moveTo(const Offset(24, 120));
    await tester.pumpAndSettle();

    expect(find.text('Deadlines'), findsOneWidget);
    await gesture.removePointer();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'adaptive desktop sidebar keeps board content visible when narrow',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'adaptive_desktop_sidebar': true,
      });
      final snapshot = _snapshotWithTask(DateTime(2026, 7, 13, 8));
      await tester.binding.setSurfaceSize(const Size(720, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            boardProvider.overrideWith((ref) => Stream.value(snapshot)),
            currentTimeProvider.overrideWith(
              (ref) => Stream.value(DateTime(2026, 7, 13, 8)),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const BoardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Ship release'), findsOneWidget);
    },
  );

  testWidgets(
    'adaptive desktop sidebar keeps board content visible when wide',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'adaptive_desktop_sidebar': true,
      });
      final snapshot = _snapshotWithTask(DateTime(2026, 7, 13, 8));
      await tester.binding.setSurfaceSize(const Size(1240, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            boardProvider.overrideWith((ref) => Stream.value(snapshot)),
            currentTimeProvider.overrideWith(
              (ref) => Stream.value(DateTime(2026, 7, 13, 8)),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const BoardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.text('Deadlines'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Ship release'), findsOneWidget);
    },
  );

  testWidgets('empty board renders English strings for an English locale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const snapshot = BoardSnapshot(categories: [], tasks: []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          boardProvider.overrideWith((ref) => Stream.value(snapshot)),
          currentTimeProvider.overrideWith(
            (ref) => Stream.value(DateTime.now()),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const BoardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No deadlines yet'), findsOneWidget);
    expect(find.text('New category'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('uncategorized group appears for orphan tasks', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime.now();
    final snapshot = BoardSnapshot(
      categories: const [],
      tasks: [
        Task(
          id: 1,
          name: '孤立事项',
          deadlineUtc: now.toUtc().add(const Duration(hours: 2)),
          categoryId: null,
          isCompleted: false,
          createdAtUtc: now.toUtc(),
          updatedAtUtc: now.toUtc(),
          completedAtUtc: null,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          boardProvider.overrideWith((ref) => Stream.value(snapshot)),
          currentTimeProvider.overrideWith((ref) => Stream.value(now)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
          home: const BoardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('未分类'), findsOneWidget);
    expect(find.text('孤立事项'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

BoardSnapshot _snapshotWithTask(DateTime now) {
  final utc = now.toUtc();
  return BoardSnapshot(
    categories: [
      Category(
        id: 1,
        name: 'Work',
        colorArgb: 0xFF4A90E2,
        sortOrder: 0,
        createdAtUtc: utc,
        updatedAtUtc: utc,
      ),
    ],
    tasks: [
      Task(
        id: 1,
        name: 'Ship release',
        deadlineUtc: utc.add(const Duration(hours: 2)),
        categoryId: 1,
        isCompleted: false,
        createdAtUtc: utc,
        updatedAtUtc: utc,
        completedAtUtc: null,
      ),
    ],
  );
}
