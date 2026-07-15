import 'package:ddl_out/features/settings/application/settings.dart';
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
}
