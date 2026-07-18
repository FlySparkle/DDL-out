import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation/app_navigation_shell.dart';
import '../../core/links/external_link_launcher.dart';
import '../../l10n/app_localizations.dart';
import 'presentation/settings_section_title.dart';
import 'presentation/settings_tile_group.dart';
import 'settings_page.dart';

class CommunitySettingsPage extends ConsumerWidget {
  const CommunitySettingsPage({super.key});

  static final _repository = Uri.parse('https://github.com/FlySparkle/DDL-out');
  static final _bugReport = Uri.parse(
    'https://github.com/FlySparkle/DDL-out/issues/new?template=bug-report.yml',
  );
  static final _featureRequest = Uri.parse(
    'https://github.com/FlySparkle/DDL-out/issues/new?template=feature-request.yml',
  );
  static final _discussions = Uri.parse(
    'https://github.com/FlySparkle/DDL-out/discussions',
  );
  static final _contributing = Uri.parse(
    'https://github.com/FlySparkle/DDL-out/blob/main/docs/CONTRIBUTING.md',
  );
  static final _security = Uri.parse(
    'https://github.com/FlySparkle/DDL-out/security/advisories/new',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SettingsPageScaffold(
      destination: AppNavigationDestinationId.settings,
      showBackButton: true,
      title: l10n.communitySettingsTitle,
      body: ListView(
        padding: SettingsPageScaffold.contentPadding,
        children: [
          SettingsSectionTitle(l10n.projectSection),
          const SizedBox(height: 8),
          SettingsTileGroup(
            children: [
              _externalTile(
                context,
                ref,
                icon: Icons.code,
                title: l10n.sourceCode,
                uri: _repository,
              ),
              _externalTile(
                context,
                ref,
                icon: Icons.bug_report_outlined,
                title: l10n.reportBug,
                uri: _bugReport,
              ),
              _externalTile(
                context,
                ref,
                icon: Icons.lightbulb_outline,
                title: l10n.requestFeature,
                uri: _featureRequest,
              ),
              _externalTile(
                context,
                ref,
                icon: Icons.forum_outlined,
                title: l10n.discussions,
                uri: _discussions,
              ),
            ],
          ),
          const Divider(height: 32),
          SettingsSectionTitle(l10n.communityGuidelinesSection),
          const SizedBox(height: 8),
          SettingsTileGroup(
            children: [
              _externalTile(
                context,
                ref,
                icon: Icons.volunteer_activism_outlined,
                title: l10n.contributingGuide,
                uri: _contributing,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.groups_outlined),
                title: Text(l10n.codeOfConduct),
                subtitle: Text(l10n.codeOfConductSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push('/settings/community/code-of-conduct'),
              ),
              _externalTile(
                context,
                ref,
                icon: Icons.security_outlined,
                title: l10n.reportSecurityIssue,
                subtitle: l10n.reportSecurityIssueSubtitle,
                uri: _security,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _externalTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required Uri uri,
    String? subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => openExternalLink(context, ref, uri),
    );
  }
}
