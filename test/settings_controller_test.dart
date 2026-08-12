import 'package:ddl_out/features/settings/application/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to the system font', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(settingsControllerProvider);
    await pumpEventQueue();

    final settings = container.read(settingsControllerProvider);
    expect(settings.hydrated, isTrue);
    expect(settings.useSystemFont, isTrue);
  });

  test('checks for updates on startup by default', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(settingsControllerProvider);
    await pumpEventQueue();

    expect(
      container.read(settingsControllerProvider).checkForUpdatesOnStartup,
      isTrue,
    );
  });

  test('loads and persists the startup update preference', () async {
    SharedPreferences.setMockInitialValues({'check_updates_on_startup': false});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(settingsControllerProvider.notifier);
    await pumpEventQueue();

    expect(
      container.read(settingsControllerProvider).checkForUpdatesOnStartup,
      isFalse,
    );

    await controller.setCheckForUpdatesOnStartup(true);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('check_updates_on_startup'), isTrue);
    expect(
      container.read(settingsControllerProvider).checkForUpdatesOnStartup,
      isTrue,
    );
  });

  test('migrates a legacy bundled font preference', () async {
    SharedPreferences.setMockInitialValues({'font_family': 'serif'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(settingsControllerProvider);
    await pumpEventQueue();

    final settings = container.read(settingsControllerProvider);
    expect(settings.useSystemFont, isFalse);
  });

  test('persists the system font toggle', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(settingsControllerProvider.notifier);
    await pumpEventQueue();

    await controller.setUseSystemFont(false);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('use_system_font'), isFalse);
    expect(container.read(settingsControllerProvider).useSystemFont, isFalse);
  });

  test('drag handles default on and persist as one toggle', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(settingsControllerProvider.notifier);
    await pumpEventQueue();

    expect(container.read(settingsControllerProvider).showDragHandles, isTrue);

    await controller.setShowDragHandles(false);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('show_drag_handles'), isFalse);
    expect(container.read(settingsControllerProvider).showDragHandles, isFalse);
  });

  test('legacy task and category toggles migrate to one preference', () async {
    SharedPreferences.setMockInitialValues({
      'show_task_drag_handle': false,
      'show_category_drag_handle': true,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(settingsControllerProvider);
    await pumpEventQueue();

    expect(container.read(settingsControllerProvider).showDragHandles, isFalse);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('show_drag_handles'), isFalse);
    expect(preferences.containsKey('show_task_drag_handle'), isFalse);
    expect(preferences.containsKey('show_category_drag_handle'), isFalse);
  });

  test('legacy text scale migrates to the nearest font preset', () async {
    SharedPreferences.setMockInitialValues({'text_scale': 1.4});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(settingsControllerProvider);
    await pumpEventQueue();

    expect(
      container.read(settingsControllerProvider).fontSizePreset,
      FontSizePreset.extraLarge,
    );
  });

  test('font preset persists and removes the legacy scale', () async {
    SharedPreferences.setMockInitialValues({'text_scale': 0.8});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(settingsControllerProvider.notifier);
    await pumpEventQueue();

    await controller.setFontSizePreset(FontSizePreset.larger);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('font_size_preset'), 'larger');
    expect(preferences.containsKey('text_scale'), isFalse);
    expect(
      container.read(settingsControllerProvider).fontSizePreset,
      FontSizePreset.larger,
    );
  });

  test('GitHub token persists and can be cleared', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(settingsControllerProvider.notifier);
    await pumpEventQueue();

    await controller.setGithubToken('  github_pat_test  ');
    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('github_token'), 'github_pat_test');
    expect(
      container.read(settingsControllerProvider).githubToken,
      'github_pat_test',
    );

    await controller.setGithubToken('');
    preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('github_token'), isFalse);
    expect(container.read(settingsControllerProvider).githubToken, isEmpty);
  });

  test('defaults to following the system language', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(settingsControllerProvider);
    await pumpEventQueue();

    final language = container.read(settingsControllerProvider).language;
    expect(language, AppLanguage.system);
    expect(language.locale, isNull);
  });

  test('loads and persists the selected language', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'en'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(settingsControllerProvider.notifier);
    await pumpEventQueue();

    expect(
      container.read(settingsControllerProvider).language.locale,
      const Locale('en'),
    );

    await controller.setLanguage(AppLanguage.japanese);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app_language'), 'ja');
    expect(
      container.read(settingsControllerProvider).language,
      AppLanguage.japanese,
    );
  });

  test('migrates the legacy adaptive sidebar setting', () async {
    SharedPreferences.setMockInitialValues({'adaptive_desktop_sidebar': true});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(settingsControllerProvider);
    await pumpEventQueue();

    expect(
      container.read(settingsControllerProvider).sidebarMode,
      SidebarMode.fixed,
    );
  });

  test('persists the selected sidebar mode', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(settingsControllerProvider.notifier);
    await pumpEventQueue();

    await controller.setSidebarMode(SidebarMode.fixed);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('navigation_mode'), 'fixed');
    expect(
      container.read(settingsControllerProvider).sidebarMode,
      SidebarMode.fixed,
    );
  });

  test('defaults to align-between sidebar placement', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(settingsControllerProvider);
    await pumpEventQueue();

    expect(
      container.read(settingsControllerProvider).sidebarAlignment,
      SidebarAlignment.alignBetween,
    );
  });

  test('loads and persists the selected sidebar placement', () async {
    SharedPreferences.setMockInitialValues({'sidebar_alignment': 'end'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(settingsControllerProvider.notifier);
    await pumpEventQueue();

    expect(
      container.read(settingsControllerProvider).sidebarAlignment,
      SidebarAlignment.end,
    );

    await controller.setSidebarAlignment(SidebarAlignment.start);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('sidebar_alignment'), 'start');
    expect(
      container.read(settingsControllerProvider).sidebarAlignment,
      SidebarAlignment.start,
    );
  });
}
