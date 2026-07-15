import 'package:ddl_out/app/navigation/app_navigation_shell.dart';
import 'package:ddl_out/core/links/external_link_launcher.dart';
import 'package:ddl_out/core/version/app_version.dart';
import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/repositories/board_providers.dart';
import 'package:ddl_out/features/settings/about_settings_page.dart';
import 'package:ddl_out/features/settings/appearance_settings_page.dart';
import 'package:ddl_out/features/settings/community_settings_page.dart';
import 'package:ddl_out/features/settings/domain/legal_document.dart';
import 'package:ddl_out/features/settings/presentation/legal_document_page.dart';
import 'package:ddl_out/features/settings/system_data_settings_page.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders all four settings destinations', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final launcher = _FakeLauncher(true);
    for (final entry in <(Widget, String)>[
      (const AppearanceSettingsPage(), 'Appearance & personalization'),
      (const SystemDataSettingsPage(), 'System & data'),
      (const AboutSettingsPage(), 'About'),
      (const CommunitySettingsPage(), 'Community & support'),
    ]) {
      await tester.pumpWidget(_app(entry.$1, launcher));
      await tester.pumpAndSettle();
      expect(find.text(entry.$2), findsOneWidget);
    }
  });

  testWidgets('author links use the shared external launcher', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final launcher = _FakeLauncher(true);
    await tester.pumpWidget(_app(const AboutSettingsPage(), launcher));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('FlySparkle'));
    await tester.tap(find.text('FlySparkle'));
    await tester.pump();

    expect(launcher.lastUri, Uri.parse('https://github.com/FlySparkle'));
  });

  testWidgets('failed community links show a localized message', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final launcher = _FakeLauncher(false);
    await tester.pumpWidget(_app(const CommunitySettingsPage(), launcher));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Source code'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not open the link. Try again later.'),
      findsOneWidget,
    );
  });

  testWidgets('legal document load failures are non-fatal', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final launcher = _FakeLauncher(true);
    await tester.pumpWidget(
      _app(
        DefaultAssetBundle(
          bundle: _FailingAssetBundle(),
          child: const LegalDocumentPage(kind: LegalDocumentKind.privacy),
        ),
        launcher,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Could not load this document'), findsOneWidget);
  });
}

Widget _app(Widget page, _FakeLauncher launcher) {
  return ProviderScope(
    overrides: [
      boardProvider.overrideWith(
        (ref) => Stream.value(const BoardSnapshot(categories: [], tasks: [])),
      ),
      appVersionReaderProvider.overrideWithValue(const _FakeVersionReader()),
      externalLinkLauncherProvider.overrideWithValue(launcher),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: AppNavigationScope(fixed: true, child: page),
    ),
  );
}

class _FakeVersionReader implements AppVersionReader {
  const _FakeVersionReader();

  @override
  Future<String> read() async => '1.2.3+abc1234';
}

class _FakeLauncher implements ExternalLinkLauncher {
  _FakeLauncher(this.result);

  final bool result;
  Uri? lastUri;

  @override
  Future<bool> open(Uri uri) async {
    lastUri = uri;
    return result;
  }
}

class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    throw StateError('Missing asset: $key');
  }
}
