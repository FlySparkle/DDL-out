import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/update/update_checker.dart';
import '../../../core/version/app_version.dart';
import '../../../l10n/app_localizations.dart';
import '../../update/update_prompt.dart';

class AboutSettingsSection extends ConsumerWidget {
  const AboutSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appVersion = ref.watch(appVersionProvider);
    return Column(
      children: [
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
    );
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
}
