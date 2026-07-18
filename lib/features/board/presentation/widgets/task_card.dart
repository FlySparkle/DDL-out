import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/time/deadline_service.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../dialogs/confirmation_dialog.dart';
import '../dialogs/task_editor.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({
    required this.task,
    required this.snapshot,
    required this.categoryColor,
    required this.now,
    super.key,
  });

  final Task task;
  final BoardSnapshot snapshot;
  final Color categoryColor;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final fill = DeadlineService.urgencyColor(
      categoryColor,
      task.deadlineUtc,
      scheme,
      now: now,
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
    final dragHandle = _dragHandle(context, feedback);
    return Semantics(
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
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 5,
                child: ColoredBox(color: fill),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 58),
                child: Row(
                  children: [
                    dragHandle,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _remainingLabel(context, task.deadlineUtc),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: DeadlineService.readableForeground(fill),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: l10n.taskActions,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditor(context);
                        } else if (value == 'delete') {
                          _deleteTask(context, ref);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.edit_outlined),
                            title: Text(l10n.editTask),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            textColor: scheme.error,
                            iconColor: scheme.error,
                            leading: const Icon(Icons.delete_outline),
                            title: Text(l10n.delete),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragHandle(BuildContext context, Widget feedback) {
    final l10n = AppLocalizations.of(context);
    final handle = Tooltip(
      message: l10n.moveTask,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Icon(Icons.drag_indicator),
        ),
      ),
    );
    if (Theme.of(context).platform == TargetPlatform.android) {
      return LongPressDraggable<int>(
        data: task.id,
        feedback: feedback,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        child: handle,
      );
    }
    return Draggable<int>(
      data: task.id,
      feedback: feedback,
      dragAnchorStrategy: pointerDragAnchorStrategy,
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

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.deleteTaskTitle,
      body: l10n.deleteTaskBody,
      destructive: true,
      confirmLabel: l10n.deleteTaskConfirm,
    );
    if (confirmed) await ref.read(taskRepositoryProvider).delete(task.id);
  }
}
