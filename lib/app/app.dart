import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../data/settings/app_settings.dart';
import '../features/board/board_page.dart';
import '../features/settings/settings_page.dart';
import '../features/update/update_prompt.dart';
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
        final typography = _typographyFor(settings.fontFamily);
        return MaterialApp.router(
          title: 'DDL out!',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          themeMode: settings.themeMode,
          theme: AppTheme.light(
            dynamicScheme: useDynamic ? lightDynamic : null,
            fontFamily: typography.fontFamily,
            fontFamilyFallback: typography.fallback,
          ),
          darkTheme: AppTheme.dark(
            dynamicScheme: useDynamic ? darkDynamic : null,
            fontFamily: typography.fontFamily,
            fontFamilyFallback: typography.fallback,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(settings.textScale),
              ),
              child: UpdateCheckOnLaunch(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}

({String? fontFamily, List<String>? fallback}) _typographyFor(
  AppFontFamily family,
) {
  if (family == AppFontFamily.system) {
    return Platform.isWindows
        ? (fontFamily: 'Segoe UI', fallback: const ['Microsoft YaHei UI'])
        : (fontFamily: null, fallback: null);
  }
  return switch (family) {
    AppFontFamily.sansSerif => (
      fontFamily: Platform.isWindows ? 'Arial' : 'sans-serif',
      fallback: Platform.isWindows ? const ['Microsoft YaHei UI'] : null,
    ),
    AppFontFamily.serif => (
      fontFamily: Platform.isWindows ? 'Times New Roman' : 'serif',
      fallback: Platform.isWindows ? const ['SimSun'] : null,
    ),
    AppFontFamily.monospace => (
      fontFamily: Platform.isWindows ? 'Consolas' : 'monospace',
      fallback: Platform.isWindows ? const ['Microsoft YaHei UI'] : null,
    ),
    AppFontFamily.system => throw StateError('Handled above'),
  };
}
