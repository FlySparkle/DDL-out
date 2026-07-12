import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/version/app_version.dart';
import '../../core/update/update_checker.dart';
import '../../data/backup/backup_service.dart';
import '../../data/repositories/repositories.dart';
import '../../data/settings/app_settings.dart';
import '../update/update_prompt.dart';
import '../../l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final board = ref.watch(boardProvider).value;
    final appVersion = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _SectionTitle(l10n.appearanceSection),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto),
                    label: Text(l10n.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode),
                    label: Text(l10n.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode),
                    label: Text(l10n.themeDark),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selection) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(selection.single);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.palette_outlined),
                title: Text(l10n.dynamicColor),
                subtitle: Text(l10n.dynamicColorSubtitle),
                value: settings.dynamicColorEnabled,
                onChanged: ref
                    .read(settingsControllerProvider.notifier)
                    .setDynamicColorEnabled,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 14, right: 16),
                    child: Icon(Icons.font_download_outlined),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<AppFontFamily>(
                      initialValue: settings.fontFamily,
                      decoration: InputDecoration(labelText: l10n.fontFamily),
                      items: [
                        for (final family in AppFontFamily.values)
                          DropdownMenuItem(
                            value: family,
                            child: Text(_fontLabel(l10n, family)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setFontFamily(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.format_size),
                title: Text(l10n.fontSize),
                subtitle: Slider(
                  value: settings.textScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: l10n.fontSizeValue((settings.textScale * 100).round()),
                  onChanged: ref
                      .read(settingsControllerProvider.notifier)
                      .setTextScale,
                ),
                trailing: Text(
                  l10n.fontSizeValue((settings.textScale * 100).round()),
                ),
              ),
              const Divider(height: 32),
              _SectionTitle(l10n.dataSection),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.file_upload_outlined),
                title: Text(l10n.backup),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _export(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.file_download_outlined),
                title: Text(l10n.restore),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _restore(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                leading: const Icon(Icons.delete_forever_outlined),
                title: Text(l10n.clearAllData),
                subtitle: Text(
                  l10n.dataCount(
                    board?.categories.length ?? 0,
                    board?.tasks.length ?? 0,
                  ),
                ),
                onTap: () => _clearAll(context, ref),
              ),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.system_update_outlined),
                title: Text(l10n.checkForUpdates),
                subtitle: Text(l10n.checkForUpdatesSubtitle),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _checkForUpdates(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.appTitle),
                subtitle: appVersion.when(
                  data: (value) => Text(l10n.aboutVersion(value)),
                  error: (_, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final exported = await ref
          .read(backupServiceProvider)
          .exportToFile(dialogTitle: l10n.exportDialogTitle);
      if (!context.mounted) return;
      _message(
        context,
        exported ? l10n.backupSuccess : l10n.operationCancelled,
      );
    } on Object {
      if (context.mounted) _message(context, l10n.operationFailed);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final service = ref.read(backupServiceProvider);
      final preview = await service.pickBackup(
        dialogTitle: l10n.restoreFileDialogTitle,
      );
      if (preview == null || !context.mounted) return;
      final board = ref.read(boardProvider).value;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.restoreTitle),
          content: Text(
            l10n.restoreBody(
              preview.categoryCount,
              preview.taskCount,
              board?.categories.length ?? 0,
              board?.tasks.length ?? 0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await service.restore(preview);
      if (context.mounted) _message(context, l10n.restoreSuccess);
    } on BackupException {
      if (context.mounted) _message(context, l10n.invalidBackup);
    } on Object {
      if (context.mounted) _message(context, l10n.operationFailed);
    }
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllTitle),
        content: Text(l10n.clearAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).clearAllData();
    }
  }

  Future<void> _checkForUpdates(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final update = await ref.read(updateCheckerProvider).checkForUpdate();
      if (!context.mounted) return;
      if (update == null) {
        _message(context, l10n.alreadyUpToDate);
        return;
      }
      final result = await showUpdatePrompt(context, update);
      if (result == UpdatePromptResult.downloadFailed && context.mounted) {
        _message(context, l10n.operationFailed);
      }
    } on Object {
      if (context.mounted) _message(context, l10n.operationFailed);
    }
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _fontLabel(AppLocalizations l10n, AppFontFamily family) =>
      switch (family) {
        AppFontFamily.system => l10n.fontSystem,
        AppFontFamily.sansSerif => l10n.fontSansSerif,
        AppFontFamily.serif => l10n.fontSerif,
        AppFontFamily.monospace => l10n.fontMonospace,
      };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}
