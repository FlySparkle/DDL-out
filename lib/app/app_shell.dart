import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/update/update_checker.dart';
import '../features/settings/application/settings.dart';
import '../features/update/update_prompt.dart';
import '../l10n/app_localizations.dart';

/// App 级外壳：注入文字缩放、触发启动时更新检查。
class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.child, this.navigatorKey, super.key});

  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _checkScheduled = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    if (settings.hydrated && settings.checkForUpdatesOnStartup) {
      _scheduleUpdateCheck();
    }
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: settings.textScaler),
      child: widget.child,
    );
  }

  void _scheduleUpdateCheck() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final update = await ref.read(updateCheckerProvider).checkForUpdate();
        if (update == null || !mounted) return;
        final promptContext =
            widget.navigatorKey?.currentState?.overlay?.context ?? context;
        if (!promptContext.mounted) return;
        final result = await showUpdatePrompt(promptContext, update);
        if (result == UpdatePromptResult.downloadFailed &&
            mounted &&
            promptContext.mounted) {
          ScaffoldMessenger.of(promptContext)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(promptContext).operationFailed,
                ),
              ),
            );
        }
      } on Object {
        // Update checks are best effort so an offline launch remains uninterrupted.
      }
    });
  }
}
