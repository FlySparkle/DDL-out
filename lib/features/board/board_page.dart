import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/time/deadline_service.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../data/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import 'editors.dart';

final currentTimeProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  controller.add(DateTime.now());
  final timer = Timer.periodic(
    const Duration(minutes: 1),
    (_) => controller.add(DateTime.now()),
  );
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

class BoardPage extends ConsumerWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final board = ref.watch(boardProvider);
    final settings = ref.watch(settingsControllerProvider);
    final adaptiveSidebar =
        _isDesktopPlatform && settings.adaptiveDesktopSidebar;

    return Scaffold(
      drawer: adaptiveSidebar ? null : const _BoardNavigationDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: !adaptiveSidebar,
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.clearCompleted,
            onPressed: board.value?.completedCount == 0
                ? null
                : () => _clearCompleted(context, ref, board.value!),
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.moreActions,
            onSelected: (value) {
              if (value == 'clear_categories' && board.value != null) {
                _clearCategories(context, ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_categories',
                enabled: board.value?.categories.isNotEmpty ?? false,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.layers_clear_outlined),
                  title: Text(l10n.clearCategories),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.newCategory,
        onPressed: () => showCategoryEditor(context, ref),
        child: const Icon(Icons.create_new_folder_outlined),
      ),
      body: board.when(
        data: (snapshot) {
          final content = _BoardContent(snapshot: snapshot);
          if (!adaptiveSidebar) return content;
          return _AdaptiveDesktopSidebar(child: content);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(boardProvider),
        ),
      ),
    );
  }

  Future<void> _clearCompleted(
    BuildContext context,
    WidgetRef ref,
    BoardSnapshot snapshot,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.clearCompletedTitle,
      body: l10n.clearCompletedBody(snapshot.completedCount),
      destructive: true,
    );
    if (confirmed) await ref.read(taskRepositoryProvider).clearCompleted();
  }

  Future<void> _clearCategories(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.clearCategoriesTitle,
      body: l10n.clearCategoriesBody,
      destructive: true,
    );
    if (confirmed) await ref.read(categoryRepositoryProvider).clear();
  }
}

bool get _isDesktopPlatform =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

class _BoardNavigationDrawer extends StatelessWidget {
  const _BoardNavigationDrawer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationDrawer(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        final router = GoRouter.of(context);
        Navigator.pop(context);
        if (index == 1) router.push('/settings');
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
          child: Text(
            l10n.appTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(l10n.boardTitle),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(l10n.settingsTitle),
        ),
      ],
    );
  }
}

class _AdaptiveDesktopSidebar extends StatefulWidget {
  const _AdaptiveDesktopSidebar({required this.child});

  final Widget child;

  @override
  State<_AdaptiveDesktopSidebar> createState() =>
      _AdaptiveDesktopSidebarState();
}

class _AdaptiveDesktopSidebarState extends State<_AdaptiveDesktopSidebar> {
  static const double _collapsedWidth = 56;
  static const double _expandedWidth = 280;
  static const double _pinnedBreakpoint = 920;

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pinned = constraints.maxWidth >= _pinnedBreakpoint;
        if (pinned) {
          return Row(
            children: [
              const SizedBox(
                width: _expandedWidth,
                child: _DesktopSidebar(expanded: true),
              ),
              VerticalDivider(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(child: widget.child),
            ],
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(left: _collapsedWidth, child: widget.child),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _hovered ? _expandedWidth : _collapsedWidth,
              child: MouseRegion(
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: SizedBox.expand(
                  child: Material(
                    elevation: _hovered ? 8 : 0,
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.18),
                    borderRadius: _hovered
                        ? const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          )
                        : BorderRadius.zero,
                    clipBehavior: Clip.antiAlias,
                    child: _DesktopSidebar(expanded: _hovered),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(expanded ? 12 : 8, 12, 8, 12),
          child: Column(
            crossAxisAlignment: expanded
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 44,
                child: expanded
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            l10n.appTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.view_sidebar_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              _DesktopSidebarDestination(
                expanded: expanded,
                selected: true,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: l10n.boardTitle,
                onTap: () {},
              ),
              const SizedBox(height: 4),
              _DesktopSidebarDestination(
                expanded: expanded,
                selected: false,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: l10n.settingsTitle,
                onTap: () => GoRouter.of(context).push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSidebarDestination extends StatelessWidget {
  const _DesktopSidebarDestination({
    required this.expanded,
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool expanded;
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    final tile = Material(
      color: selected ? scheme.secondaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: expanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              SizedBox(
                width: expanded ? 44 : 36,
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: foreground,
                  size: 22,
                ),
              ),
              if (expanded) ...[
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ),
    );

    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 500),
      child: tile,
    );
  }
}

class _BoardContent extends ConsumerWidget {
  const _BoardContent({required this.snapshot});

  final BoardSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (snapshot.categories.isEmpty && snapshot.tasks.isEmpty) {
      return _EmptyState(
        onCreateCategory: () => showCategoryEditor(context, ref),
      );
    }

    final uncategorized = snapshot.tasks
        .where((task) => task.categoryId == null)
        .toList(growable: false);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
          buildDefaultDragHandles: false,
          header: uncategorized.isEmpty
              ? null
              : _CategorySection(
                  snapshot: snapshot,
                  category: null,
                  title: l10n.uncategorized,
                  color: Theme.of(context).colorScheme.secondary,
                  tasks: uncategorized,
                ),
          itemCount: snapshot.categories.length,
          itemBuilder: (context, index) {
            final category = snapshot.categories[index];
            return _CategorySection(
              key: ValueKey('category-${category.id}'),
              snapshot: snapshot,
              category: category,
              title: category.name,
              color: Color(category.colorArgb),
              tasks: snapshot.tasks
                  .where((task) => task.categoryId == category.id)
                  .toList(growable: false),
              reorderIndex: index,
            );
          },
          onReorderItem: (oldIndex, newIndex) {
            if (oldIndex == newIndex) return;
            final reordered = snapshot.categories
                .map((category) => category.id)
                .toList();
            final moved = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, moved);
            ref.read(categoryRepositoryProvider).reorder(reordered);
          },
        ),
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    super.key,
    required this.snapshot,
    required this.category,
    required this.title,
    required this.color,
    required this.tasks,
    this.reorderIndex,
  });

  final BoardSnapshot snapshot;
  final Category? category;
  final String title;
  final Color color;
  final List<Task> tasks;
  final int? reorderIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final collapsed =
        category != null &&
        settings.collapsedCategoryIds.contains(category!.id);
    final now = ref.watch(currentTimeProvider).value ?? DateTime.now();
    final activeDurations = tasks
        .where((task) => !task.isCompleted)
        .map((task) => DeadlineService.remaining(task.deadlineUtc, now: now))
        .where((duration) => duration > Duration.zero);
    final longest = activeDurations.fold<Duration>(
      Duration.zero,
      (current, value) => value > current ? value : current,
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
        onAcceptWithDetails: (details) {
          ref.read(taskRepositoryProvider).move(details.data, category?.id);
        },
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
                _reorderableHeader(
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: category == null
                        ? null
                        : () => ref
                              .read(settingsControllerProvider.notifier)
                              .toggleCategory(category!.id),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Row(
                        children: [
                          if (category != null)
                            IconButton(
                              tooltip: collapsed
                                  ? l10n.expandCategory
                                  : l10n.collapseCategory,
                              onPressed: () => ref
                                  .read(settingsControllerProvider.notifier)
                                  .toggleCategory(category!.id),
                              icon: AnimatedRotation(
                                turns: collapsed ? -0.25 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: const Icon(Icons.expand_more),
                              ),
                            )
                          else
                            const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  l10n.taskCount(tasks.length),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.clearCategoryTasks,
                            onPressed: tasks.isEmpty
                                ? null
                                : () => _clearTasks(context, ref),
                            icon: const Icon(Icons.cleaning_services_outlined),
                          ),
                          if (category != null)
                            IconButton(
                              tooltip: l10n.editCategory,
                              onPressed: () => showCategoryEditor(
                                context,
                                ref,
                                category: category,
                                taskCount: tasks.length,
                              ),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          IconButton(
                            tooltip: l10n.addTask,
                            onPressed: () => showTaskEditor(
                              context,
                              ref,
                              snapshot: snapshot,
                              initialCategoryId: category?.id,
                            ),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                                  child: _TaskCard(
                                    task: task,
                                    snapshot: snapshot,
                                    categoryColor: color,
                                    longestRemaining: longest,
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

  Widget _reorderableHeader(Widget child) {
    final index = reorderIndex;
    if (index == null) return child;
    return ReorderableDelayedDragStartListener(index: index, child: child);
  }

  Future<void> _clearTasks(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.clearCategoryTasksTitle,
      body: l10n.clearCategoryTasksBody(tasks.length),
      destructive: true,
    );
    if (confirmed) {
      await ref.read(taskRepositoryProvider).clearCategory(category?.id);
    }
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({
    required this.task,
    required this.snapshot,
    required this.categoryColor,
    required this.longestRemaining,
    required this.now,
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
          onTap: () => showTaskEditor(
            context,
            ref,
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
                      _remainingLabel(context, task.deadlineUtc, now),
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

    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final feedback = Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(width: 320, child: card),
    );
    if (isAndroid) {
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

  String _remainingLabel(
    BuildContext context,
    DateTime deadline,
    DateTime current,
  ) {
    final l10n = AppLocalizations.of(context);
    final value = DeadlineService.remaining(deadline, now: current);
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateCategory});

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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showConfirmation(
  BuildContext context, {
  required String title,
  required String body,
  bool destructive = false,
}) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ) ??
      false;
}
