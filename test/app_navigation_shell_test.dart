import 'package:ddl_out/app/navigation/app_navigation_shell.dart';
import 'package:ddl_out/core/theme/app_theme.dart';
import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/repositories/board_providers.dart';
import 'package:ddl_out/features/settings/settings_page.dart';
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
        of: find.byKey(const ValueKey('navigation-destination-0')),
        matching: find.byIcon(Icons.home),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('fixed-navigation-toggle')));
    await tester.pumpAndSettle();
    expect(_fixedNavigationWidth(tester), 72);

    await tester.tap(find.byKey(const ValueKey('navigation-destination-1')));
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsNothing);
    expect(find.text('settings-content'), findsOneWidget);
    expect(_fixedNavigationWidth(tester), 72);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('navigation-destination-1')),
        matching: find.byIcon(Icons.settings),
      ),
      findsOneWidget,
    );
  });

  testWidgets('floating drawer navigation keeps a route to return to', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'navigation_mode': 'floating'});
    final router = _router(realSettingsPage: true);
    addTearDown(router.dispose);

    await tester.pumpWidget(_testApp(router, mobile: true));
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('board-content'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('board-content'), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);
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

    final destination = find.byKey(const ValueKey('navigation-destination-0'));
    final destinationRect = tester.getRect(destination);
    final material = tester.widget<Material>(
      find.descendant(of: destination, matching: find.byType(Material)),
    );
    expect(destinationRect.height, 56);
    expect(destinationRect.width, greaterThan(destinationRect.height));
    expect(material.shape, AppNavigationVisuals.navigationShape);
  });
}

GoRouter _router({bool realSettingsPage = false}) {
  return GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppNavigationShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const _TestPage(selectedIndex: 0, content: 'board-content'),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => realSettingsPage
                ? const SettingsPage()
                : const _TestPage(
                    selectedIndex: 1,
                    content: 'settings-content',
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
  const _TestPage({required this.selectedIndex, required this.content});

  final int selectedIndex;
  final String content;

  @override
  Widget build(BuildContext context) {
    final fixed = AppNavigationScope.maybeOf(context)?.fixed ?? false;
    return Scaffold(
      drawer: fixed ? null : AppNavigationDrawer(selectedIndex: selectedIndex),
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
