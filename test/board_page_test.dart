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
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
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
