import 'package:flutter/material.dart';

enum DeadlineMode { relative, absolute }

enum SidebarMode { floating, fixed }

@immutable
class AppSettingsState {
  const AppSettingsState({
    this.hydrated = false,
    this.themeMode = ThemeMode.system,
    this.dynamicColorEnabled = true,
    this.useSystemFont = true,
    this.textScale = 1,
    this.sidebarMode = SidebarMode.floating,
    this.checkForUpdatesOnStartup = true,
    this.collapsedCategoryIds = const <int>{},
    this.deadlineMode = DeadlineMode.relative,
    this.relativeDays = 1,
    this.relativeHours = 0,
    this.relativeMinutes = 0,
  });

  final bool hydrated;
  final ThemeMode themeMode;
  final bool dynamicColorEnabled;
  final bool useSystemFont;
  final double textScale;
  final SidebarMode sidebarMode;
  final bool checkForUpdatesOnStartup;
  final Set<int> collapsedCategoryIds;
  final DeadlineMode deadlineMode;
  final int relativeDays;
  final int relativeHours;
  final int relativeMinutes;

  TextScaler get textScaler => TextScaler.linear(textScale);

  AppSettingsState copyWith({
    bool? hydrated,
    ThemeMode? themeMode,
    bool? dynamicColorEnabled,
    bool? useSystemFont,
    double? textScale,
    SidebarMode? sidebarMode,
    bool? checkForUpdatesOnStartup,
    Set<int>? collapsedCategoryIds,
    DeadlineMode? deadlineMode,
    int? relativeDays,
    int? relativeHours,
    int? relativeMinutes,
  }) {
    return AppSettingsState(
      hydrated: hydrated ?? this.hydrated,
      themeMode: themeMode ?? this.themeMode,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
      useSystemFont: useSystemFont ?? this.useSystemFont,
      textScale: textScale ?? this.textScale,
      sidebarMode: sidebarMode ?? this.sidebarMode,
      checkForUpdatesOnStartup:
          checkForUpdatesOnStartup ?? this.checkForUpdatesOnStartup,
      collapsedCategoryIds: collapsedCategoryIds ?? this.collapsedCategoryIds,
      deadlineMode: deadlineMode ?? this.deadlineMode,
      relativeDays: relativeDays ?? this.relativeDays,
      relativeHours: relativeHours ?? this.relativeHours,
      relativeMinutes: relativeMinutes ?? this.relativeMinutes,
    );
  }
}
