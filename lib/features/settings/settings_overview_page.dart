import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation/app_navigation_shell.dart';
import '../../data/sync/lan_sync_service.dart';
import '../../l10n/app_localizations.dart';
import 'presentation/settings_tile_group.dart';
import 'settings_page.dart';

class SettingsOverviewPage extends ConsumerWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final conflictCount = ref.watch(syncConflictCountProvider).value ?? 0;
    return SettingsPageScaffold(
      destination: AppNavigationDestinationId.settings,
      title: l10n.settingsTitle,
      body: ListView(
        padding: SettingsPageScaffold.contentPadding,
        children: [
          SettingsTileGroup(
            children: [
              _SettingsDestinationTile(
                icon: Icons.palette_outlined,
                title: l10n.appearanceSettingsTitle,
                route: '/settings/appearance',
              ),
              _SettingsDestinationTile(
                icon: Icons.tune_outlined,
                title: l10n.systemDataSettingsTitle,
                route: '/settings/system-data',
              ),
              _SettingsDestinationTile(
                icon: Icons.sync_alt,
                title: l10n.nearbySync,
                route: '/sync',
                badgeCount: conflictCount,
              ),
              _SettingsDestinationTile(
                icon: Icons.info_outline,
                title: l10n.aboutSettingsTitle,
                route: '/settings/about',
              ),
              _SettingsDestinationTile(
                icon: Icons.groups_outlined,
                title: l10n.communitySettingsTitle,
                route: '/settings/community',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsDestinationTile extends StatelessWidget {
  const _SettingsDestinationTile({
    required this.icon,
    required this.title,
    required this.route,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String title;
  final String route;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Badge(
        isLabelVisible: badgeCount > 0,
        label: Text('$badgeCount'),
        child: Icon(icon),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}
