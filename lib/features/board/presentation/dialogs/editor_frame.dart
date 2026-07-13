import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class EditorFrame extends StatelessWidget {
  const EditorFrame({
    required this.title,
    required this.body,
    required this.primaryAction,
    this.leadingAction,
    super.key,
  });

  final String title;
  final Widget body;
  final Widget primaryAction;
  final Widget? leadingAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.cancel,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(child: SingleChildScrollView(child: body)),
            const SizedBox(height: 16),
            Row(
              children: [
                ?leadingAction,
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                primaryAction,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
