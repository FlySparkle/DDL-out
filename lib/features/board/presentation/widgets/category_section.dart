import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/deadline_service.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/current_time_provider.dart';
import '../dialogs/category_editor.dart';
import '../dialogs/confirmation_dialog.dart';
import '../dialogs/task_editor.dart';
import 'task_card.dart';

@immutable
class CategoryDragData {
  const CategoryDragData(this.id);

  final int id;
}

class CategorySection extends ConsumerWidget {
  const CategorySection({
    required this.snapshot,
    required this.category,
    required this.title,
    required this.color,
    required this.tasks,
    super.key,
  });

  final BoardSnapshot snapshot;
  final Category? category;
  final String title;
  final Color color;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final collapsed =
        category != null &&
        settings.collapsedCategoryIds.contains(category!.id);
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now();
    final completedCount = tasks.where((task) => task.isCompleted).length;
    final activeDurations = tasks
        .where((task) => !task.isCompleted)
        .map((task) => DeadlineService.remaining(task.deadlineUtc, now: now))
        .where((duration) => duration > Duration.zero);
    final longestRemaining = activeDurations.fold<Duration>(
      Duration.zero,
      (longest, duration) => duration > longest ? duration : longest,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          final task = snapshot.tasks
              .where((task) => task.id == details.data)
              .firstOrNull;
          return task != null && task.categoryId != category?.id;
        },
        onAcceptWithDetails: (details) => _moveTask(context, ref, details.data),
        builder: (context, candidates, rejects) {
          final scheme = Theme.of(context).colorScheme;
          final cardColor = Color.alphaBlend(
            color.withValues(alpha: 0.16),
            scheme.surfaceContainerLow,
          );
          return Card(
            color: candidates.isEmpty ? cardColor : scheme.secondaryContainer,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: candidates.isEmpty ? 0 : 4,
                  color: scheme.secondary,
                ),
                _buildHeader(context, ref, collapsed, completedCount),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: collapsed
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: tasks.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                              l10n.noTasks,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : Column(
                            children: [
                              for (final task in tasks)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: TaskCard(
                                    task: task,
                                    snapshot: snapshot,
                                    categoryColor: color,
                                    longestRemaining: longestRemaining,
                                    now: now,
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool collapsed,
    int completedCount,
  ) {
    final l10n = AppLocalizations.of(context);
    void toggle() => ref
        .read(settingsControllerProvider.notifier)
        .toggleCategory(category!.id);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          if (category != null)
            IconButton(
              tooltip: collapsed ? l10n.expandCategory : l10n.collapseCategory,
              onPressed: toggle,
              icon: AnimatedRotation(
                turns: collapsed ? -0.25 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(Icons.expand_more),
              ),
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: category == null ? null : toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l10n.taskCount(tasks.length),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.addTask,
            onPressed: () => showTaskEditor(
              context,
              snapshot: snapshot,
              initialCategoryId: category?.id,
            ),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: l10n.clearCategoryTasks,
            onPressed: completedCount == 0
                ? null
                : () => _clearTasks(context, ref, completedCount),
            icon: const Icon(Icons.playlist_remove),
          ),
          if (category != null)
            PopupMenuButton<String>(
              tooltip: l10n.categoryActions,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    showCategoryEditor(
                      context,
                      category: category,
                      taskCount: tasks.length,
                    );
                    break;
                  case 'delete':
                    _deleteCategory(context, ref);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (category != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.editCategory),
                    ),
                  ),
                if (category != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      textColor: Theme.of(context).colorScheme.error,
                      iconColor: Theme.of(context).colorScheme.error,
                      leading: const Icon(Icons.delete_outline),
                      title: Text(l10n.deleteCategory),
                    ),
                  ),
              ],
            ),
          if (category != null) _categoryDragHandle(context),
        ],
      ),
    );
  }

  Future<void> _clearTasks(
    BuildContext context,
    WidgetRef ref,
    int completedCount,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.clearCategoryTasksTitle,
      body: l10n.clearCategoryTasksBody(completedCount),
      destructive: true,
      confirmLabel: l10n.clearCategoryTasksConfirm,
    );
    if (confirmed) {
      await ref
          .read(taskRepositoryProvider)
          .clearCompletedInCategory(category?.id);
    }
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final currentCategory = category;
    if (currentCategory == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.deleteCategoryTitle,
      body: l10n.deleteCategoryBody(tasks.length),
      destructive: true,
      confirmLabel: l10n.deleteCategoryConfirm,
    );
    if (!confirmed) return;
    await ref.read(categoryRepositoryProvider).delete(currentCategory.id);
    await ref
        .read(settingsControllerProvider.notifier)
        .removeCategoryPreference(currentCategory.id);
  }

  Future<void> _moveTask(
    BuildContext context,
    WidgetRef ref,
    int taskId,
  ) async {
    final task = snapshot.tasks.where((task) => task.id == taskId).firstOrNull;
    if (task == null || task.categoryId == category?.id) return;
    final previousCategoryId = task.categoryId;
    await ref.read(taskRepositoryProvider).move(taskId, category?.id);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.taskMovedTo(title)),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => ref
                .read(taskRepositoryProvider)
                .move(taskId, previousCategoryId),
          ),
        ),
      );
  }

  Widget _categoryDragHandle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final handle = Tooltip(
      message: l10n.reorderCategory,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Icon(Icons.drag_indicator),
        ),
      ),
    );
    final feedback = Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.drag_indicator),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final data = CategoryDragData(category!.id);
    return Draggable<CategoryDragData>(
      data: data,
      feedback: feedback,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      maxSimultaneousDrags: 1,
      child: handle,
    );
  }
}
