import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/backup/backup_service.dart';
import '../../../data/repositories/board_providers.dart';
import '../../../l10n/app_localizations.dart';
import 'settings_section_title.dart';
import 'settings_tile_group.dart';

class DataSettingsSection extends ConsumerWidget {
  const DataSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final board = ref.watch(boardProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 32),
        SettingsSectionTitle(l10n.dataSection),
        const SizedBox(height: 8),
        SettingsTileGroup(
          children: [
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
          ],
        ),
      ],
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
              child: Text(l10n.restoreConfirm),
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.clearAllConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).clearAllData();
    }
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
