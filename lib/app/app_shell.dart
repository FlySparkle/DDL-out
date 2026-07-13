import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/update/update_checker.dart';
import '../features/settings/application/settings.dart';
import '../features/update/update_prompt.dart';
import '../l10n/app_localizations.dart';

/// App 级外壳：注入文字缩放、触发启动时更新检查。
class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static bool _checkScheduled = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    _scheduleUpdateCheck(context, ref);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: settings.textScaler),
      child: child,
    );
  }

  static void _scheduleUpdateCheck(BuildContext context, WidgetRef ref) {
    if (_checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final update = await ref.read(updateCheckerProvider).checkForUpdate();
        if (update == null || !context.mounted) return;
        final result = await showUpdatePrompt(context, update);
        if (result == UpdatePromptResult.downloadFailed && context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).operationFailed),
              ),
            );
        }
      } on Object {
        // Update checks are best effort so an offline launch remains uninterrupted.
      }
    });
  }
}
