import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettingsState>(
      SettingsController.new,
    );

class SettingsController extends Notifier<AppSettingsState> {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'app_language';
  static const _dynamicColorKey = 'dynamic_color';
  static const _useSystemFontKey = 'use_system_font';
  static const _legacyFontFamilyKey = 'font_family';
  static const _textScaleKey = 'text_scale';
  static const _navigationModeKey = 'navigation_mode';
  static const _sidebarAlignmentKey = 'sidebar_alignment';
  static const _checkForUpdatesOnStartupKey = 'check_updates_on_startup';
  static const _legacyAdaptiveDesktopSidebarKey = 'adaptive_desktop_sidebar';
  static const _collapsedKey = 'collapsed_categories';
  static const _deadlineModeKey = 'deadline_mode';
  static const _relativeDaysKey = 'relative_days';
  static const _relativeHoursKey = 'relative_hours';
  static const _relativeMinutesKey = 'relative_minutes';

  SharedPreferences? _preferences;

  @override
  AppSettingsState build() {
    unawaited(_load());
    return const AppSettingsState();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
    if (!ref.mounted) return;

    state = AppSettingsState(
      hydrated: true,
      themeMode: _parseTheme(preferences.getString(_themeKey)),
      language: _readLanguage(preferences),
      dynamicColorEnabled: preferences.getBool(_dynamicColorKey) ?? true,
      useSystemFont: _readUseSystemFont(preferences),
      textScale: (preferences.getDouble(_textScaleKey) ?? 1).clamp(0.8, 1.4),
      sidebarMode: _readSidebarMode(preferences),
      sidebarAlignment: _readSidebarAlignment(preferences),
      checkForUpdatesOnStartup:
          preferences.getBool(_checkForUpdatesOnStartupKey) ?? true,
      collapsedCategoryIds:
          (preferences.getStringList(_collapsedKey) ?? const [])
              .map(int.tryParse)
              .whereType<int>()
              .toSet(),
      deadlineMode: preferences.getString(_deadlineModeKey) == 'absolute'
          ? DeadlineMode.absolute
          : DeadlineMode.relative,
      relativeDays: preferences.getInt(_relativeDaysKey) ?? 1,
      relativeHours: preferences.getInt(_relativeHoursKey) ?? 0,
      relativeMinutes: preferences.getInt(_relativeMinutesKey) ?? 0,
    );
  }

  static ThemeMode _parseTheme(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static AppLanguage _readLanguage(SharedPreferences preferences) {
    final value = preferences.getString(_languageKey);
    return AppLanguage.values
            .where((language) => language.storageValue == value)
            .firstOrNull ??
        AppLanguage.system;
  }

  static bool _readUseSystemFont(SharedPreferences preferences) {
    final value = preferences.getBool(_useSystemFontKey);
    if (value != null) return value;
    final legacy = preferences.getString(_legacyFontFamilyKey);
    return legacy == null || legacy == 'system';
  }

  static SidebarMode _readSidebarMode(SharedPreferences preferences) {
    final value = preferences.getString(_navigationModeKey);
    if (value != null) {
      return SidebarMode.values
              .where((mode) => mode.name == value)
              .firstOrNull ??
          SidebarMode.floating;
    }
    return preferences.getBool(_legacyAdaptiveDesktopSidebarKey) == true
        ? SidebarMode.fixed
        : SidebarMode.floating;
  }

  static SidebarAlignment _readSidebarAlignment(SharedPreferences preferences) {
    final value = preferences.getString(_sidebarAlignmentKey);
    return SidebarAlignment.values
            .where((alignment) => alignment.storageValue == value)
            .firstOrNull ??
        SidebarAlignment.alignBetween;
  }

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    state = state.copyWith(themeMode: value);
    await (await _prefs()).setString(_themeKey, value.name);
  }

  Future<void> setLanguage(AppLanguage value) async {
    state = state.copyWith(language: value);
    await (await _prefs()).setString(_languageKey, value.storageValue);
  }

  Future<void> setDynamicColorEnabled(bool value) async {
    state = state.copyWith(dynamicColorEnabled: value);
    await (await _prefs()).setBool(_dynamicColorKey, value);
  }

  Future<void> setUseSystemFont(bool value) async {
    state = state.copyWith(useSystemFont: value);
    await (await _prefs()).setBool(_useSystemFontKey, value);
  }

  Future<void> setTextScale(double value) async {
    final normalized = value.clamp(0.8, 1.4);
    state = state.copyWith(textScale: normalized);
    await (await _prefs()).setDouble(_textScaleKey, normalized);
  }

  Future<void> setSidebarMode(SidebarMode value) async {
    state = state.copyWith(sidebarMode: value);
    await (await _prefs()).setString(_navigationModeKey, value.name);
  }

  Future<void> setSidebarAlignment(SidebarAlignment value) async {
    state = state.copyWith(sidebarAlignment: value);
    await (await _prefs()).setString(_sidebarAlignmentKey, value.storageValue);
  }

  Future<void> setCheckForUpdatesOnStartup(bool value) async {
    state = state.copyWith(checkForUpdatesOnStartup: value);
    await (await _prefs()).setBool(_checkForUpdatesOnStartupKey, value);
  }

  Future<void> toggleCategory(int id) async {
    final collapsed = {...state.collapsedCategoryIds};
    if (!collapsed.add(id)) collapsed.remove(id);
    state = state.copyWith(collapsedCategoryIds: collapsed);
    await (await _prefs()).setStringList(
      _collapsedKey,
      collapsed.map((id) => id.toString()).toList(),
    );
  }

  Future<void> removeCategoryPreference(int id) async {
    if (!state.collapsedCategoryIds.contains(id)) return;
    final collapsed = {...state.collapsedCategoryIds}..remove(id);
    state = state.copyWith(collapsedCategoryIds: collapsed);
    await (await _prefs()).setStringList(
      _collapsedKey,
      collapsed.map((value) => value.toString()).toList(),
    );
  }

  Future<void> rememberDeadline({
    required DeadlineMode mode,
    required int days,
    required int hours,
    required int minutes,
  }) async {
    state = state.copyWith(
      deadlineMode: mode,
      relativeDays: days,
      relativeHours: hours,
      relativeMinutes: minutes,
    );
    final preferences = await _prefs();
    await Future.wait([
      preferences.setString(_deadlineModeKey, mode.name),
      preferences.setInt(_relativeDaysKey, days),
      preferences.setInt(_relativeHoursKey, hours),
      preferences.setInt(_relativeMinutesKey, minutes),
    ]);
  }
}
