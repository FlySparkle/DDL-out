import 'package:flutter/material.dart';

import '../../app/navigation/app_navigation_shell.dart';
import '../../l10n/app_localizations.dart';
import 'presentation/about_settings_section.dart';
import 'settings_page.dart';

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsPageScaffold(
      destination: AppNavigationDestinationId.about,
      title: l10n.aboutSettingsTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: const [AboutSettingsSection()],
      ),
    );
  }
}
