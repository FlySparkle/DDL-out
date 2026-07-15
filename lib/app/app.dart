import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/board/board_page.dart';
import '../features/settings/application/settings.dart';
import '../features/settings/about_settings_page.dart';
import '../features/settings/appearance_settings_page.dart';
import '../features/settings/community_settings_page.dart';
import '../features/settings/domain/legal_document.dart';
import '../features/settings/presentation/legal_document_page.dart';
import '../features/settings/system_data_settings_page.dart';
import '../l10n/app_localizations.dart';
import 'navigation/app_navigation_shell.dart';
import 'app_shell.dart';

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          AppNavigationShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const BoardPage()),
        GoRoute(path: '/settings', redirect: (_, _) => '/settings/appearance'),
        GoRoute(
          path: '/settings/appearance',
          builder: (context, state) => const AppearanceSettingsPage(),
        ),
        GoRoute(
          path: '/settings/system-data',
          builder: (context, state) => const SystemDataSettingsPage(),
        ),
        GoRoute(
          path: '/settings/about',
          builder: (context, state) => const AboutSettingsPage(),
          routes: [
            GoRoute(
              path: 'license',
              builder: (context, state) =>
                  const LegalDocumentPage(kind: LegalDocumentKind.gpl),
            ),
            GoRoute(
              path: 'privacy',
              builder: (context, state) =>
                  const LegalDocumentPage(kind: LegalDocumentKind.privacy),
            ),
            GoRoute(
              path: 'terms',
              builder: (context, state) =>
                  const LegalDocumentPage(kind: LegalDocumentKind.terms),
            ),
          ],
        ),
        GoRoute(
          path: '/settings/community',
          builder: (context, state) => const CommunitySettingsPage(),
          routes: [
            GoRoute(
              path: 'code-of-conduct',
              builder: (context, state) => const LegalDocumentPage(
                kind: LegalDocumentKind.codeOfConduct,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

class DdlOutApp extends ConsumerWidget {
  const DdlOutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final useDynamic = settings.dynamicColorEnabled;
        final fontFamily = settings.useSystemFont ? null : 'NotoSansSC';
        return MaterialApp.router(
          title: 'DDL out!',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          themeMode: settings.themeMode,
          theme: AppTheme.light(
            dynamicScheme: useDynamic ? lightDynamic : null,
            fontFamily: fontFamily,
          ),
          darkTheme: AppTheme.dark(
            dynamicScheme: useDynamic ? darkDynamic : null,
            fontFamily: fontFamily,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (_, child) => AppShell(child: child!),
        );
      },
    );
  }
}
