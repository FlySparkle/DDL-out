import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/update/update_checker.dart';
import '../../l10n/app_localizations.dart';

enum UpdatePromptResult { dismissed, downloadOpened, downloadFailed }

Future<UpdatePromptResult> showUpdatePrompt(
  BuildContext context,
  AppUpdate update,
) async {
  final l10n = AppLocalizations.of(context);
  final shouldOpen = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.updateAvailableTitle),
      content: Text(l10n.updateAvailableBody(update.version)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.downloadUpdate),
        ),
      ],
    ),
  );
  if (shouldOpen != true) return UpdatePromptResult.dismissed;

  try {
    final opened = await launchUrl(
      githubReleasesPageUri,
      mode: LaunchMode.externalApplication,
    );
    return opened
        ? UpdatePromptResult.downloadOpened
        : UpdatePromptResult.downloadFailed;
  } on Object {
    return UpdatePromptResult.downloadFailed;
  }
}
