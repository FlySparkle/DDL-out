import 'package:flutter/material.dart';

import '../../app/navigation/app_navigation_shell.dart';
import '../../l10n/app_localizations.dart';
import 'presentation/about_settings_section.dart';
import 'presentation/appearance_settings_section.dart';
import 'presentation/data_settings_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fixedNavigation = AppNavigationScope.maybeOf(context)?.fixed ?? false;
    return Scaffold(
      drawer: fixedNavigation
          ? null
          : const AppNavigationDrawer(selectedIndex: 1),
      drawerEnableOpenDragGesture: !fixedNavigation,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: fixedNavigation
            ? null
            : Builder(
                builder: (context) => DrawerButton(
                  style: AppNavigationVisuals.controlButtonStyle(context),
                ),
              ),
        title: Text(l10n.settingsTitle),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: const [
              AppearanceSettingsSection(),
              DataSettingsSection(),
              AboutSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
