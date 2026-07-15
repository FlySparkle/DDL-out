import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation/app_navigation_shell.dart';
import '../../l10n/app_localizations.dart';
import 'application/settings.dart';
import 'presentation/data_settings_section.dart';
import 'presentation/settings_section_title.dart';
import 'settings_page.dart';

class SystemDataSettingsPage extends ConsumerWidget {
  const SystemDataSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return SettingsPageScaffold(
      destination: AppNavigationDestinationId.systemData,
      title: l10n.systemDataSettingsTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SettingsSectionTitle(l10n.updateSection),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.system_update_outlined),
            title: Text(l10n.checkUpdatesOnStartup),
            subtitle: Text(l10n.checkUpdatesOnStartupSubtitle),
            value: settings.checkForUpdatesOnStartup,
            onChanged: settings.hydrated
                ? controller.setCheckForUpdatesOnStartup
                : null,
          ),
          const DataSettingsSection(),
        ],
      ),
    );
  }
}
