import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class BoardEmptyState extends StatelessWidget {
  const BoardEmptyState({
    required this.onCreateTask,
    required this.onCreateCategory,
    super.key,
  });

  final VoidCallback onCreateTask;
  final VoidCallback onCreateCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.emptyTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(l10n.emptyBody, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCreateTask,
                icon: const Icon(Icons.add_task),
                label: Text(l10n.newTask),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onCreateCategory,
                icon: const Icon(Icons.create_new_folder_outlined),
                label: Text(l10n.newCategory),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoardErrorState extends StatelessWidget {
  const BoardErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.errorTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
