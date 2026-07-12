import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DeadlineMode { relative, absolute }

enum AppFontFamily { system, sansSerif, serif, monospace }

@immutable
class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.dynamicColorEnabled = true,
    this.fontFamily = AppFontFamily.system,
    this.textScale = 1,
    this.collapsedCategoryIds = const <int>{},
    this.deadlineMode = DeadlineMode.relative,
    this.relativeDays = 1,
    this.relativeHours = 0,
    this.relativeMinutes = 0,
  });

  final ThemeMode themeMode;
  final bool dynamicColorEnabled;
  final AppFontFamily fontFamily;
  final double textScale;
  final Set<int> collapsedCategoryIds;
  final DeadlineMode deadlineMode;
  final int relativeDays;
  final int relativeHours;
  final int relativeMinutes;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? dynamicColorEnabled,
    AppFontFamily? fontFamily,
    double? textScale,
    Set<int>? collapsedCategoryIds,
    DeadlineMode? deadlineMode,
    int? relativeDays,
    int? relativeHours,
    int? relativeMinutes,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
      fontFamily: fontFamily ?? this.fontFamily,
      textScale: textScale ?? this.textScale,
      collapsedCategoryIds: collapsedCategoryIds ?? this.collapsedCategoryIds,
      deadlineMode: deadlineMode ?? this.deadlineMode,
      relativeDays: relativeDays ?? this.relativeDays,
      relativeHours: relativeHours ?? this.relativeHours,
      relativeMinutes: relativeMinutes ?? this.relativeMinutes,
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettingsState>(
      SettingsController.new,
    );

class SettingsController extends Notifier<AppSettingsState> {
  static const _themeKey = 'theme_mode';
  static const _dynamicColorKey = 'dynamic_color';
  static const _fontFamilyKey = 'font_family';
  static const _textScaleKey = 'text_scale';
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
      themeMode: _parseTheme(preferences.getString(_themeKey)),
      dynamicColorEnabled: preferences.getBool(_dynamicColorKey) ?? true,
      fontFamily: _parseFontFamily(preferences.getString(_fontFamilyKey)),
      textScale: (preferences.getDouble(_textScaleKey) ?? 1).clamp(0.8, 1.4),
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

  static AppFontFamily _parseFontFamily(String? value) =>
      AppFontFamily.values.where((font) => font.name == value).firstOrNull ??
      AppFontFamily.system;

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    state = state.copyWith(themeMode: value);
    await (await _prefs()).setString(_themeKey, value.name);
  }

  Future<void> setDynamicColorEnabled(bool value) async {
    state = state.copyWith(dynamicColorEnabled: value);
    await (await _prefs()).setBool(_dynamicColorKey, value);
  }

  Future<void> setFontFamily(AppFontFamily value) async {
    state = state.copyWith(fontFamily: value);
    await (await _prefs()).setString(_fontFamilyKey, value.name);
  }

  Future<void> setTextScale(double value) async {
    final normalized = value.clamp(0.8, 1.4);
    state = state.copyWith(textScale: normalized);
    await (await _prefs()).setDouble(_textScaleKey, normalized);
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
