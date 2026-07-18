import 'package:ddl_out/app/navigation/app_navigation_shell.dart';
import 'package:ddl_out/core/theme/app_theme.dart';
import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/repositories/board_providers.dart';
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
    expect(_fixedNavigationWidth(tester), 256);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('navigation-destination-board')),
        matching: find.byIcon(Icons.home),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('fixed-navigation-toggle')));
    await tester.pumpAndSettle();
    expect(_fixedNavigationWidth(tester), 72);

    await tester.tap(
      find.byKey(const ValueKey('navigation-destination-appearance')),
    );
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsNothing);
    expect(find.text('appearance-content'), findsOneWidget);
    expect(_fixedNavigationWidth(tester), 72);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('navigation-destination-appearance')),
        matching: find.byIcon(Icons.palette),
      ),
      findsOneWidget,
    );
  });

  testWidgets('floating drawer navigation keeps a route to return to', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'floating'});
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_testApp(router, mobile: true));
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appearance & personalization'));
    await tester.pumpAndSettle();

    expect(find.text('appearance-content'), findsOneWidget);
    expect(find.text('board-content'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsOneWidget);
    expect(find.text('appearance-content'), findsNothing);
  });

  testWidgets('switching settings destinations does not stack settings pages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'floating'});
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_testApp(router, mobile: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appearance & personalization'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('about-content'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsOneWidget);
    expect(find.text('appearance-content'), findsNothing);
  });

  testWidgets('legacy settings route redirects to appearance', (tester) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'floating'});
    final router = _router(initialLocation: '/settings');
    addTearDown(router.dispose);

    await tester.pumpWidget(_testApp(router, mobile: true));
    await tester.pumpAndSettle();

    expect(find.text('appearance-content'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      '/settings/appearance',
    );
  });

  testWidgets('sidebar labels use the global font', (tester) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'floating'});
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      _testApp(router, theme: AppTheme.light(fontFamily: 'NotoSansSC')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    final label = tester.widget<Text>(find.text('Settings'));
    expect(label.style?.fontFamily, 'NotoSansSC');

    final destination = find.byKey(
      const ValueKey('navigation-destination-board'),
    );
    final destinationRect = tester.getRect(destination);
    final material = tester.widget<Material>(
      find.descendant(of: destination, matching: find.byType(Material)),
    );
    expect(destinationRect.height, 56);
    expect(destinationRect.width, greaterThan(destinationRect.height));
    expect(material.shape, AppNavigationVisuals.navigationShape);
  });

  testWidgets('sidebar placement supports between, start, and end', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1240, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final positions = <String, ({Rect board, Rect appearance})>{};

    for (final alignment in ['align-between', 'start', 'end']) {
      SharedPreferences.setMockInitialValues({
        'navigation_mode': 'fixed',
        'sidebar_alignment': alignment,
      });
      final router = _router();
      await tester.pumpWidget(_testApp(router));
      await tester.pumpAndSettle();

      positions[alignment] = (
        board: tester.getRect(
          find.byKey(const ValueKey('navigation-destination-board')),
        ),
        appearance: tester.getRect(
          find.byKey(const ValueKey('navigation-destination-appearance')),
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    }

    final between = positions['align-between']!;
    final start = positions['start']!;
    final end = positions['end']!;
    expect(between.board.top, closeTo(start.board.top, 0.01));
    expect(between.appearance.top, greaterThan(start.appearance.top + 100));
    expect(end.board.top, greaterThan(between.board.top + 100));
    expect(end.appearance.bottom, closeTo(between.appearance.bottom, 0.01));
  });
}

GoRouter _router({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppNavigationShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const _TestPage(
              selectedDestination: AppNavigationDestinationId.board,
              content: 'board-content',
            ),
          ),
          GoRoute(
            path: '/settings',
            redirect: (_, _) => '/settings/appearance',
          ),
          GoRoute(
            path: '/settings/appearance',
            builder: (context, state) => const _TestPage(
              selectedDestination: AppNavigationDestinationId.appearance,
              content: 'appearance-content',
            ),
          ),
          GoRoute(
            path: '/settings/system-data',
            builder: (context, state) => const _TestPage(
              selectedDestination: AppNavigationDestinationId.systemData,
              content: 'system-data-content',
            ),
          ),
          GoRoute(
            path: '/settings/about',
            builder: (context, state) => const _TestPage(
              selectedDestination: AppNavigationDestinationId.about,
              content: 'about-content',
            ),
          ),
          GoRoute(
            path: '/settings/community',
            builder: (context, state) => const _TestPage(
              selectedDestination: AppNavigationDestinationId.community,
              content: 'community-content',
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _testApp(GoRouter router, {ThemeData? theme, bool mobile = false}) {
  return ProviderScope(
    overrides: [
      boardProvider.overrideWith(
        (ref) => Stream.value(const BoardSnapshot(categories: [], tasks: [])),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme:
          theme ??
          (mobile ? ThemeData(platform: TargetPlatform.android) : null),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

class _TestPage extends StatelessWidget {
  const _TestPage({required this.selectedDestination, required this.content});

  final AppNavigationDestinationId selectedDestination;
  final String content;

  @override
  Widget build(BuildContext context) {
    final fixed = AppNavigationScope.maybeOf(context)?.fixed ?? false;
    return Scaffold(
      drawer: fixed
          ? null
          : AppNavigationDrawer(selectedDestination: selectedDestination),
      drawerEnableOpenDragGesture: !fixed,
      drawerEdgeDragWidth: fixed
          ? null
          : AppNavigationLayout.floatingDrawerDragWidth(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: fixed
            ? null
            : Builder(builder: (context) => const DrawerButton()),
      ),
      body: Center(child: Text(content)),
    );
  }
}

double _fixedNavigationWidth(WidgetTester tester) {
  return tester
      .getSize(find.byKey(const ValueKey('fixed-navigation-panel')))
      .width;
}
