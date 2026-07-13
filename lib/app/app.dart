import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/board/board_page.dart';
import '../features/settings/application/settings.dart';
import '../features/settings/settings_page.dart';
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
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
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
