import 'package:ddl_out/app/app_shell.dart';
import 'package:ddl_out/core/update/update_checker.dart';
import 'package:ddl_out/core/version/app_version.dart';
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
  int calls = 0;

  @override
  Future<String> readLatestVersion() async {
    calls += 1;
    return '1.0.0';
  }
}
