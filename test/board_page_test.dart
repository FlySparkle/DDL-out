import 'dart:ui';

import 'package:ddl_out/app/navigation/app_navigation_shell.dart';
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
          home: const AppNavigationShell(location: '/', child: BoardPage()),
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
    expect(find.text('DDL out!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('fixed sidebar expands on hover when space is moderate', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'fixed'});
    const snapshot = BoardSnapshot(categories: [], tasks: []);
    await tester.binding.setSurfaceSize(const Size(900, 900));
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
          home: const AppNavigationShell(location: '/', child: BoardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('fixed-navigation-toggle')),
      findsOneWidget,
    );
    expect(find.text('No deadlines yet'), findsOneWidget);
    expect(_fixedNavigationWidth(tester), 72);

    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: const Offset(8, 160));
    await gesture.moveTo(const Offset(24, 160));
    await tester.pump(const Duration(milliseconds: 400));

    expect(_fixedNavigationWidth(tester), 72);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(_fixedNavigationWidth(tester), 256);
    await gesture.moveTo(const Offset(500, 160));
    await tester.pump(const Duration(milliseconds: 450));
    expect(_fixedNavigationWidth(tester), 256);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
    expect(_fixedNavigationWidth(tester), 72);
    await gesture.removePointer();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'fixed mode falls back to a floating drawer when width is narrow',
    (tester) async {
      SharedPreferences.setMockInitialValues({'navigation_mode': 'fixed'});
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
            home: const AppNavigationShell(location: '/', child: BoardPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(
        find.byKey(const ValueKey('fixed-navigation-toggle')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('fixed-navigation-panel')),
        findsNothing,
      );
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Ship release'), findsOneWidget);
    },
  );

  testWidgets('fixed sidebar automatically expands when width is sufficient', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'fixed'});
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
          home: const AppNavigationShell(location: '/', child: BoardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toggle = find.byKey(const ValueKey('fixed-navigation-toggle'));
    expect(toggle, findsOneWidget);
    final navigationModel = find.ancestor(
      of: toggle,
      matching: find.byType(AnimatedPhysicalModel),
    );
    expect(navigationModel, findsOneWidget);
    expect(
      tester.widget<AnimatedPhysicalModel>(navigationModel).borderRadius,
      BorderRadius.zero,
    );
    expect(_fixedNavigationWidth(tester), 256);
    expect(find.text('Deadlines'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Collapse sidebar'), findsOneWidget);
    final destination = find.byKey(
      const ValueKey('navigation-destination-board'),
    );
    final destinationRect = tester.getRect(destination);
    final toggleRect = tester.getRect(toggle);
    expect(destinationRect.size, toggleRect.size);
    expect(destinationRect.height, 56);
    expect(destinationRect.width, greaterThan(destinationRect.height));
    expect(
      tester
          .widget<Material>(
            find.descendant(of: destination, matching: find.byType(Material)),
          )
          .shape,
      tester
          .widget<Material>(
            find.descendant(of: toggle, matching: find.byType(Material)),
          )
          .shape,
    );
    final secondDestination = tester.getRect(
      find.byKey(const ValueKey('navigation-destination-appearance')),
    );
    expect(secondDestination.top, greaterThan(destinationRect.bottom));
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Ship release'), findsOneWidget);
  });

  testWidgets('fixed sidebar can be collapsed and expanded manually', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'fixed'});
    const snapshot = BoardSnapshot(categories: [], tasks: []);
    await tester.binding.setSurfaceSize(const Size(1240, 900));
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
          home: const AppNavigationShell(location: '/', child: BoardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('fixed-navigation-toggle')),
        matching: find.byIcon(Icons.menu),
      ),
      findsOneWidget,
    );
    final toggleRect = tester.getRect(
      find.byKey(const ValueKey('fixed-navigation-toggle')),
    );
    expect(toggleRect.left, lessThan(16));
    expect(toggleRect.bottom, greaterThan(830));

    await tester.tap(find.byKey(const ValueKey('fixed-navigation-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    final labelTransition = find.byKey(
      const ValueKey('navigation-label-transition-board'),
    );
    final labelOpacity = tester.widget<Opacity>(labelTransition);
    final labelTransform = tester.widget<Transform>(
      find.descendant(of: labelTransition, matching: find.byType(Transform)),
    );
    expect(labelOpacity.opacity, inExclusiveRange(0, 1));
    expect(labelTransform.transform.getTranslation().x, lessThan(0));

    await tester.pumpAndSettle();
    expect(_fixedNavigationWidth(tester), 72);
    expect(labelTransition, findsNothing);

    await tester.tap(find.byKey(const ValueKey('fixed-navigation-toggle')));
    await tester.pumpAndSettle();
    expect(_fixedNavigationWidth(tester), 256);
  });

  testWidgets('mobile floating drawer opens with a swipe from mid-screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'floating'});
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
          theme: ThemeData(platform: TargetPlatform.android),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const AppNavigationShell(location: '/', child: BoardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragFrom(const Offset(300, 300), const Offset(320, 0));
    await tester.pumpAndSettle();

    expect(find.text('Deadlines'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

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
          home: const AppNavigationShell(location: '/', child: BoardPage()),
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
          home: const AppNavigationShell(location: '/', child: BoardPage()),
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

double _fixedNavigationWidth(WidgetTester tester) {
  return tester
      .getSize(find.byKey(const ValueKey('fixed-navigation-panel')))
      .width;
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
