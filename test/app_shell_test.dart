import 'package:ddl_out/app/app_shell.dart';
import 'package:ddl_out/core/update/update_checker.dart';
import 'package:ddl_out/core/version/app_version.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('disabled startup checks never contact the release reader', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'check_updates_on_startup': false});
    final latest = _CountingLatestReleaseReader();

    await tester.pumpWidget(_app(latest));
    await tester.pumpAndSettle();

    expect(latest.calls, 0);
  });

  testWidgets('enabled startup checks run once after settings hydrate', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'check_updates_on_startup': true});
    final latest = _CountingLatestReleaseReader();

    await tester.pumpWidget(_app(latest));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(latest.calls, 1);
  });

  testWidgets('startup update prompt uses the router navigator', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'check_updates_on_startup': true});
    final latest = _CountingLatestReleaseReader(version: '2.0.0');
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          updateCheckerProvider.overrideWithValue(
            AppUpdateChecker(
              currentVersionReader: const _FakeVersionReader(),
              latestReleaseReader: latest,
            ),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Text('content'),
          builder: (_, child) =>
              AppShell(navigatorKey: navigatorKey, child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(latest.calls, 1);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Update available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(_CountingLatestReleaseReader latest) {
  return ProviderScope(
    overrides: [
      updateCheckerProvider.overrideWithValue(
        AppUpdateChecker(
          currentVersionReader: const _FakeVersionReader(),
          latestReleaseReader: latest,
        ),
      ),
    ],
    child: const MaterialApp(home: AppShell(child: Text('content'))),
  );
}

class _FakeVersionReader implements AppVersionReader {
  const _FakeVersionReader();

  @override
  Future<String> read() async => '1.0.0';
}

class _CountingLatestReleaseReader implements LatestReleaseReader {
  _CountingLatestReleaseReader({this.version = '1.0.0'});

  final String version;
  int calls = 0;

  @override
  Future<String> readLatestVersion() async {
    calls += 1;
    return version;
  }
}
