import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/application/settings.dart';
import '../features/update/update_prompt.dart';

/// App 级外壳：注入文字缩放、挂载更新检查。
class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: settings.textScaler),
      child: UpdateCheckOnLaunch(child: child),
    );
  }
}
