import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/deadline_service.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
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
    final progress = DeadlineService.progress(
      task.deadlineUtc,
      longestRemaining,
      now: now,
      completed: task.isCompleted,
    );
    final fill = DeadlineService.urgencyColor(
      categoryColor,
      task.deadlineUtc,
      scheme,
      now: now,
    );
    final card = Semantics(
      button: true,
      label: task.name,
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => showTaskEditor(
            context,
            snapshot: snapshot,
            initialCategoryId: task.categoryId,
            task: task,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 350),
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
                    IconButton(
                      tooltip: task.isCompleted
                          ? l10n.markIncomplete
                          : l10n.markComplete,
                      onPressed: () => ref
                          .read(taskRepositoryProvider)
                          .setCompleted(task.id, !task.isCompleted),
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        task.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _remainingLabel(context, task.deadlineUtc),
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

    final feedback = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(width: 320, child: card),
    );
    if (Theme.of(context).platform == TargetPlatform.android) {
      return LongPressDraggable<int>(
        data: task.id,
        feedback: feedback,
        childWhenDragging: Opacity(opacity: 0.35, child: card),
        child: card,
      );
    }
    return Draggable<int>(
      data: task.id,
      feedback: feedback,
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }

  String _remainingLabel(BuildContext context, DateTime deadline) {
    final l10n = AppLocalizations.of(context);
    final value = DeadlineService.remaining(deadline, now: now);
    if (value.isNegative) return l10n.overdue;
    final totalMinutes = value.inMinutes;
    if (totalMinutes < 24 * 60) {
      return l10n.remainingShort(totalMinutes ~/ 60, totalMinutes % 60);
    }
    return l10n.remainingLong(
      totalMinutes ~/ (24 * 60),
      (totalMinutes ~/ 60) % 24,
    );
  }
}
