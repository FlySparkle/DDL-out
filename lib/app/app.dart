import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../data/settings/app_settings.dart';
import '../features/board/board_page.dart';
import '../features/settings/settings_page.dart';
import '../l10n/app_localizations.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const BoardPage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
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
        final useDynamic = settings.dynamicColorEnabled && Platform.isAndroid;
        return MaterialApp.router(
          title: 'DDL out!',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          themeMode: settings.themeMode,
          theme: AppTheme.light(useDynamic ? lightDynamic : null),
          darkTheme: AppTheme.dark(useDynamic ? darkDynamic : null),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
