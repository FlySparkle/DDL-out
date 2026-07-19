import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/links/external_link_launcher.dart';
import '../../../core/update/update_checker.dart';
import '../../../core/version/app_version.dart';
import '../../../l10n/app_localizations.dart';
import '../../update/update_prompt.dart';
import '../settings_page.dart';
import 'settings_section_title.dart';
import 'settings_tile_group.dart';

class AboutSettingsSection extends ConsumerWidget {
  const AboutSettingsSection({super.key});

  static final _authors = [
    ('FlySparkle', Uri.parse('https://github.com/FlySparkle')),
    ('Churk-Ben', Uri.parse('https://github.com/Churk-Ben')),
    ('haha-ha-cuo', Uri.parse('https://github.com/haha-ha-cuo')),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appVersion = ref.watch(appVersionProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              Image.asset('assets/logo.png', width: 88, height: 88),
              const SizedBox(height: 12),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              appVersion.when(
                data: (value) => Text(l10n.aboutVersion(value)),
                error: (_, _) => const SizedBox.shrink(),
                loading: () => const SizedBox(height: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.system_update_outlined),
          title: Text(l10n.checkForUpdates),
          subtitle: Text(l10n.checkForUpdatesSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _checkForUpdates(context, ref),
        ),
        const Divider(height: 32),
        SettingsSectionTitle(l10n.authorsSection),
        const SizedBox(height: 8),
        SettingsTileGroup(
          children: [
            for (final author in _authors)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(author.$1),
                subtitle: Text(author.$2.toString()),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => openExternalLink(context, ref, author.$2),
              ),
          ],
        ),
        const Divider(height: 32),
        SettingsSectionTitle(l10n.legalSection),
        const SizedBox(height: 8),
        SettingsTileGroup(
          children: [
            _documentTile(
              context,
              icon: Icons.balance_outlined,
              title: l10n.openSourceLicense,
              subtitle: l10n.openSourceLicenseSubtitle,
              route: '/settings/about/license',
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(l10n.thirdPartyLicenses),
              subtitle: Text(l10n.thirdPartyLicensesSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: appVersion.value,
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/logo.png', width: 64, height: 64),
                ),
              ),
            ),
            _documentTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyPolicy,
              route: '/settings/about/privacy',
            ),
            _documentTile(
              context,
              icon: Icons.description_outlined,
              title: l10n.termsOfService,
              route: '/settings/about/terms',
            ),
          ],
        ),
      ],
    );
  }

  Widget _documentTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    String? subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }

  Future<void> _checkForUpdates(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final update = await ref.read(updateCheckerProvider).checkForUpdate();
      if (!context.mounted) return;
      if (update == null) {
        showSettingsMessage(context, l10n.alreadyUpToDate);
        return;
      }
      final result = await showUpdatePrompt(context, update);
      if (result == UpdatePromptResult.installFailed && context.mounted) {
        showSettingsMessage(context, l10n.operationFailed);
      }
    } on Object {
      if (context.mounted) {
        showSettingsMessage(context, l10n.operationFailed);
      }
    }
  }
}
