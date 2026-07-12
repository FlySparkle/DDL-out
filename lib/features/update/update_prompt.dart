import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/update/update_checker.dart';
import '../../l10n/app_localizations.dart';

class UpdateCheckOnLaunch extends ConsumerStatefulWidget {
  const UpdateCheckOnLaunch({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<UpdateCheckOnLaunch> createState() =>
      _UpdateCheckOnLaunchState();
}

class _UpdateCheckOnLaunchState extends ConsumerState<UpdateCheckOnLaunch> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkForUpdate());
    });
  }

  Future<void> _checkForUpdate() async {
    try {
      final update = await ref.read(updateCheckerProvider).checkForUpdate();
      if (update == null || !mounted) return;
      final result = await showUpdatePrompt(context, update);
      if (result == UpdatePromptResult.downloadFailed && mounted) {
        _message(AppLocalizations.of(context).operationFailed);
      }
    } on Object {
      // Update checks are best effort so an offline launch remains uninterrupted.
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

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
