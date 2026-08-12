import 'package:flutter/material.dart';

enum DeadlineMode { relative, absolute, none }

enum SidebarMode { floating, fixed }

enum FontSizePreset {
  smaller('smaller', 0.85),
  standard('standard', 1),
  larger('larger', 1.15),
  extraLarge('extra-large', 1.3);

  const FontSizePreset(this.storageValue, this.scale);

  final String storageValue;
  final double scale;
}

enum AppLanguage {
  system(null),
  simplifiedChinese('zh'),
  english('en'),
  japanese('ja');

  const AppLanguage(this.languageCode);

  final String? languageCode;

  String get storageValue => languageCode ?? 'system';

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);
}

enum SidebarAlignment {
  alignBetween('align-between'),
  start('start'),
  end('end');

  const SidebarAlignment(this.storageValue);

  final String storageValue;
}

@immutable
class AppSettingsState {
  const AppSettingsState({
    this.hydrated = false,
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.system,
    this.dynamicColorEnabled = true,
    this.useSystemFont = true,
    this.showDragHandles = true,
    this.fontSizePreset = FontSizePreset.standard,
    this.sidebarMode = SidebarMode.floating,
    this.sidebarAlignment = SidebarAlignment.alignBetween,
    this.checkForUpdatesOnStartup = true,
    this.githubToken = '',
    this.largeSyncTransferEnabled = false,
    this.collapsedCategoryIds = const <int>{},
    this.deadlineMode = DeadlineMode.relative,
    this.relativeDays = 1,
    this.relativeHours = 0,
    this.relativeMinutes = 0,
  });

  final bool hydrated;
  final ThemeMode themeMode;
  final AppLanguage language;
  final bool dynamicColorEnabled;
  final bool useSystemFont;
  final bool showDragHandles;
  final FontSizePreset fontSizePreset;
  final SidebarMode sidebarMode;
  final SidebarAlignment sidebarAlignment;
  final bool checkForUpdatesOnStartup;
  final String githubToken;
  final bool largeSyncTransferEnabled;
  final Set<int> collapsedCategoryIds;
  final DeadlineMode deadlineMode;
  final int relativeDays;
  final int relativeHours;
  final int relativeMinutes;

  TextScaler get textScaler => TextScaler.linear(fontSizePreset.scale);

  AppSettingsState copyWith({
    bool? hydrated,
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? dynamicColorEnabled,
    bool? useSystemFont,
    bool? showDragHandles,
    FontSizePreset? fontSizePreset,
    SidebarMode? sidebarMode,
    SidebarAlignment? sidebarAlignment,
    bool? checkForUpdatesOnStartup,
    String? githubToken,
    bool? largeSyncTransferEnabled,
    Set<int>? collapsedCategoryIds,
    DeadlineMode? deadlineMode,
    int? relativeDays,
    int? relativeHours,
    int? relativeMinutes,
  }) {
    return AppSettingsState(
      hydrated: hydrated ?? this.hydrated,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
      useSystemFont: useSystemFont ?? this.useSystemFont,
      showDragHandles: showDragHandles ?? this.showDragHandles,
      fontSizePreset: fontSizePreset ?? this.fontSizePreset,
      sidebarMode: sidebarMode ?? this.sidebarMode,
      sidebarAlignment: sidebarAlignment ?? this.sidebarAlignment,
      checkForUpdatesOnStartup:
          checkForUpdatesOnStartup ?? this.checkForUpdatesOnStartup,
      githubToken: githubToken ?? this.githubToken,
      largeSyncTransferEnabled:
          largeSyncTransferEnabled ?? this.largeSyncTransferEnabled,
      collapsedCategoryIds: collapsedCategoryIds ?? this.collapsedCategoryIds,
      deadlineMode: deadlineMode ?? this.deadlineMode,
      relativeDays: relativeDays ?? this.relativeDays,
      relativeHours: relativeHours ?? this.relativeHours,
      relativeMinutes: relativeMinutes ?? this.relativeMinutes,
    );
  }
}
