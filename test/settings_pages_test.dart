import 'package:ddl_out/app/navigation/app_navigation_shell.dart';
import 'package:ddl_out/core/links/external_link_launcher.dart';
import 'package:ddl_out/core/version/app_version.dart';
import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/repositories/board_providers.dart';
import 'package:ddl_out/features/settings/about_settings_page.dart';
import 'package:ddl_out/features/settings/application/settings.dart';
import 'package:ddl_out/features/settings/appearance_settings_page.dart';
import 'package:ddl_out/features/settings/community_settings_page.dart';
import 'package:ddl_out/features/settings/domain/legal_document.dart';
import 'package:ddl_out/features/settings/presentation/legal_document_page.dart';
import 'package:ddl_out/features/settings/presentation/settings_tile_group.dart';
import 'package:ddl_out/features/settings/settings_page.dart';
import 'package:ddl_out/features/settings/settings_overview_page.dart';
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

  testWidgets('settings hub groups all low-frequency destinations', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      _app(const SettingsOverviewPage(), _FakeLauncher(true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appearance & personalization'), findsOneWidget);
    expect(find.text('System & data'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Community & support'), findsOneWidget);
  });

  testWidgets('content tiles use the navigation shape and edge inset', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final launcher = _FakeLauncher(true);
    await tester.pumpWidget(_app(const AppearanceSettingsPage(), launcher));
    await tester.pumpAndSettle();

    final tile = find.widgetWithText(SwitchListTile, 'Use system default font');
    final inkWell = find.descendant(of: tile, matching: find.byType(InkWell));
    final scrollable = find.byType(ListView);

    expect(tile, findsOneWidget);
    expect(inkWell, findsOneWidget);
    expect(
      tester.widget<InkWell>(inkWell).customBorder,
      AppNavigationVisuals.navigationShape,
    );
    expect(
      tester.getTopLeft(tile).dx - tester.getTopLeft(scrollable).dx,
      SettingsPageScaffold.contentPadding.left,
    );
    expect(
      tester.getTopRight(scrollable).dx - tester.getTopRight(tile).dx,
      SettingsPageScaffold.contentPadding.right,
    );
  });

  testWidgets('appearance settings persist the selected language', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final launcher = _FakeLauncher(true);
    await tester.pumpWidget(_app(const AppearanceSettingsPage(), launcher));
    await tester.pumpAndSettle();

    final languageTile = find.widgetWithText(ListTile, 'Language');
    expect(languageTile, findsOneWidget);

    await tester.tap(
      find.descendant(
        of: languageTile,
        matching: find.byType(DropdownButton<AppLanguage>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('日本語').last);
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app_language'), 'ja');
  });

  testWidgets('content tiles keep vertical space between hover surfaces', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final launcher = _FakeLauncher(true);
    await tester.pumpWidget(_app(const CommunitySettingsPage(), launcher));
    await tester.pumpAndSettle();

    final sourceCode = find.widgetWithText(ListTile, 'Source code');
    final reportBug = find.widgetWithText(ListTile, 'Report a bug');

    expect(sourceCode, findsOneWidget);
    expect(reportBug, findsOneWidget);
    expect(
      tester.getTopLeft(reportBug).dy - tester.getBottomLeft(sourceCode).dy,
      SettingsTileGroup.spacing,
    );
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

  testWidgets('code of conduct opens the online source', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final launcher = _FakeLauncher(true);
    await tester.pumpWidget(_app(const CommunitySettingsPage(), launcher));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Community code of conduct'));
    await tester.tap(find.text('Community code of conduct'));
    await tester.pump();

    expect(
      launcher.lastUri,
      Uri.parse(
        'https://github.com/FlySparkle/DDL-out/blob/main/docs/CODE_OF_CONDUCT.md',
      ),
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
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.widgetWithText(OutlinedButton, 'View source'),
      ),
      findsOneWidget,
    );
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
