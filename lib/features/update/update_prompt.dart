import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/update/update_checker.dart';
import '../../core/update/update_installer.dart';
import '../../l10n/app_localizations.dart';

enum UpdatePromptResult { dismissed, installStarted, installFailed }

Future<UpdatePromptResult> showUpdatePrompt(
  BuildContext context,
  AppUpdate update,
) async {
  return await showDialog<UpdatePromptResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _UpdatePromptDialog(update: update),
      ) ??
      UpdatePromptResult.dismissed;
}

class _UpdatePromptDialog extends ConsumerStatefulWidget {
  const _UpdatePromptDialog({required this.update});

  final AppUpdate update;

  @override
  ConsumerState<_UpdatePromptDialog> createState() =>
      _UpdatePromptDialogState();
}

class _UpdatePromptDialogState extends ConsumerState<_UpdatePromptDialog> {
  UpdateInstallProgress? _progress;
  String? _error;
  bool _installing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final installer = ref.watch(appUpdateInstallerProvider);
    return PopScope(
      canPop: !_installing,
      child: AlertDialog(
        title: Text(l10n.updateAvailableTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.updateAvailableBody(widget.update.version)),
            if (!installer.isSupported) ...[
              const SizedBox(height: 12),
              Text(
                l10n.updateUnsupported,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_installing) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _progress?.fraction),
              const SizedBox(height: 8),
              Text(_progressLabel(l10n)),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _installing
                ? null
                : () => Navigator.pop(context, UpdatePromptResult.dismissed),
            child: Text(l10n.cancel),
          ),
          if (installer.isSupported)
            FilledButton.icon(
              onPressed: _installing ? null : () => _install(installer),
              icon: const Icon(Icons.system_update_alt),
              label: Text(l10n.downloadUpdate),
            ),
        ],
      ),
    );
  }

  String _progressLabel(AppLocalizations l10n) {
    final progress = _progress;
    if (progress == null) return l10n.updateDownloading;
    return switch (progress.stage) {
      UpdateInstallStage.downloading =>
        progress.fraction == null
            ? l10n.updateDownloading
            : l10n.updateDownloadingProgress(
                (progress.fraction! * 100).clamp(0, 100).round(),
              ),
      UpdateInstallStage.verifying => l10n.updateVerifying,
      UpdateInstallStage.preparing => l10n.updatePreparing,
    };
  }

  Future<void> _install(AppUpdateInstaller installer) async {
    setState(() {
      _installing = true;
      _error = null;
      _progress = const UpdateInstallProgress(UpdateInstallStage.downloading);
    });
    try {
      final result = await installer.install(
        widget.update,
        onProgress: (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );
      if (!mounted) return;
      if (result == UpdateInstallResult.permissionRequired) {
        setState(() {
          _installing = false;
          _error = AppLocalizations.of(context).updatePermissionRequired;
        });
        return;
      }
      Navigator.pop(context, UpdatePromptResult.installStarted);
    } on UpdateInstallException catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _installing = false;
        _error = switch (error.reason) {
          UpdateInstallFailure.unsupportedPlatform => l10n.updateUnsupported,
          UpdateInstallFailure.assetUnavailable =>
            l10n.updatePackageUnavailable,
          UpdateInstallFailure.checksumUnavailable ||
          UpdateInstallFailure.checksumMismatch =>
            l10n.updateVerificationFailed,
          UpdateInstallFailure.downloadFailed ||
          UpdateInstallFailure.installFailed => l10n.updateInstallFailed,
        };
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _installing = false;
        _error = AppLocalizations.of(context).updateInstallFailed;
      });
    }
  }
}
