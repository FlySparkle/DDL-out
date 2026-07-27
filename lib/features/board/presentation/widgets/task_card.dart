import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/time/deadline_service.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/settings.dart';
import '../dialogs/task_editor.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({
    required this.task,
    required this.snapshot,
    required this.categoryColor,
    required this.longestRemaining,
    required this.now,
    super.key,
  });

  final Task task;
  final BoardSnapshot snapshot;
  final Color categoryColor;
  final Duration longestRemaining;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final showDragHandle = ref.watch(
      settingsControllerProvider.select(
        (settings) => settings.showTaskDragHandle,
      ),
    );
    final fill = DeadlineService.urgencyColor(
      categoryColor,
      task.deadlineUtc,
      scheme,
      now: now,
    );
    final progress = DeadlineService.progress(
      task.deadlineUtc,
      longestRemaining,
      now: now,
      completed: task.isCompleted,
    );
    final feedback = Material(
      elevation: 6,
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final dragHandle = showDragHandle
        ? _dragHandle(
            context,
            feedback,
            foreground: DeadlineService.readableForeground(fill),
          )
        : null;
    final card = Semantics(
      button: true,
      label: task.name,
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _openEditor(context),
          child: Stack(
            children: [
              Positioned.fill(
                key: const ValueKey('deadline-progress-track'),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    key: const ValueKey('deadline-progress'),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    widthFactor: progress,
                    heightFactor: 1,
                    child: ColoredBox(color: fill),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 58),
                child: Row(
                  children: [
                    ?dragHandle,
                    IconButton(
                      tooltip: task.isCompleted
                          ? l10n.markIncomplete
                          : l10n.markComplete,
                      onPressed: () => _toggleCompleted(context, ref),
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                    ),
                    Expanded(child: _TaskSummary(task: task)),
                    const SizedBox(width: 8),
                    Text(
                      _remainingLabel(context, task.deadlineUtc),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (showDragHandle) return card;
    return LongPressDraggable<int>(
      data: task.id,
      feedback: feedback,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      maxSimultaneousDrags: 1,
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }

  Widget _dragHandle(
    BuildContext context,
    Widget feedback, {
    required Color foreground,
  }) {
    final l10n = AppLocalizations.of(context);
    final handle = Tooltip(
      message: l10n.moveTask,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Icon(Icons.drag_indicator, color: foreground),
        ),
      ),
    );
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      return LongPressDraggable<int>(
        data: task.id,
        feedback: feedback,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        delay: const Duration(milliseconds: 120),
        maxSimultaneousDrags: 1,
        child: handle,
      );
    }
    return Draggable<int>(
      data: task.id,
      feedback: feedback,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      maxSimultaneousDrags: 1,
      child: handle,
    );
  }

  String _remainingLabel(BuildContext context, DateTime deadline) {
    final l10n = AppLocalizations.of(context);
    final value = DeadlineService.remaining(deadline, now: now);
    if (value.isNegative) {
      final overdueMinutes = value.inMinutes.abs();
      if (overdueMinutes < 24 * 60) {
        return l10n.overdueByShort(overdueMinutes ~/ 60, overdueMinutes % 60);
      }
      return l10n.overdueByLong(
        overdueMinutes ~/ (24 * 60),
        (overdueMinutes ~/ 60) % 24,
      );
    }
    final totalMinutes = value.inMinutes;
    if (totalMinutes < 24 * 60) {
      return l10n.remainingShort(totalMinutes ~/ 60, totalMinutes % 60);
    }
    if (totalMinutes < 7 * 24 * 60) {
      return l10n.remainingLong(
        totalMinutes ~/ (24 * 60),
        (totalMinutes ~/ 60) % 24,
      );
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.MMMEd(locale).format(deadline.toLocal());
  }

  Future<void> _toggleCompleted(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final next = !task.isCompleted;
    await ref.read(taskRepositoryProvider).setCompleted(task.id, next);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            next ? l10n.taskMarkedComplete : l10n.taskMarkedIncomplete,
          ),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => ref
                .read(taskRepositoryProvider)
                .setCompleted(task.id, task.isCompleted),
          ),
        ),
      );
  }

  void _openEditor(BuildContext context) {
    showTaskEditor(
      context,
      snapshot: snapshot,
      initialCategoryId: task.categoryId,
      task: task,
    );
  }
}

class _TaskSummary extends StatelessWidget {
  const _TaskSummary({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completedColor = task.isCompleted
        ? scheme.onSurfaceVariant
        : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        task.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: completedColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
