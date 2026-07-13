import 'package:ddl_out/app/navigation/app_navigation_shell.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fixed sidebar persists while route content changes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'fixed'});
    await tester.binding.setSurfaceSize(const Size(1240, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_testApp(router));
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      0,
    );

    await tester.tap(find.byKey(const ValueKey('fixed-navigation-toggle')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsNothing);
    expect(find.text('settings-content'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 1);
    expect(rail.extended, isFalse);
  });

  testWidgets('floating mode replaces the whole route content', (tester) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'floating'});
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_testApp(router));
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    router.go('/settings');
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsNothing);
    expect(find.text('settings-content'), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });
}

GoRouter _router() {
  return GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppNavigationShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('board-content'))),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('settings-content'))),
          ),
        ],
      ),
    ],
  );
}

Widget _testApp(GoRouter router) {
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}
