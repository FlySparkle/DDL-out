import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
import 'task_card.dart';

class ReorderableTaskList extends ConsumerStatefulWidget {
  const ReorderableTaskList({
    required this.snapshot,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryColor,
    required this.tasks,
    required this.longestRemaining,
    required this.now,
    super.key,
  });

  final BoardSnapshot snapshot;
  final int? categoryId;
  final String categoryTitle;
  final Color categoryColor;
  final List<Task> tasks;
  final Duration longestRemaining;
  final DateTime now;

  @override
  ConsumerState<ReorderableTaskList> createState() =>
      _ReorderableTaskListState();
}

class _ReorderableTaskListState extends ConsumerState<ReorderableTaskList> {
  late List<int> _taskOrder;
  List<int>? _pendingOrder;
  int? _hoverIndex;
  int? _hoverTaskId;

  @override
  void initState() {
    super.initState();
    _taskOrder = _snapshotOrder();
  }

  @override
  void didUpdateWidget(ReorderableTaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = _snapshotOrder();
    final pending = _pendingOrder;
    if (pending != null && _sameOrder(incoming, pending)) {
      _taskOrder = incoming;
      _pendingOrder = null;
      return;
    }
    if (pending == null) {
      _taskOrder = incoming;
      return;
    }
    final incomingIds = incoming.toSet();
    final localIds = _taskOrder.toSet();
    if (incomingIds.length != localIds.length ||
        !incomingIds.containsAll(localIds)) {
      _taskOrder = [
        ..._taskOrder.where(incomingIds.contains),
        ...incoming.where((id) => !localIds.contains(id)),
      ];
      _pendingOrder = List.of(_taskOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = {for (final task in widget.snapshot.tasks) task.id: task};
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: Column(
        key: ValueKey(_taskOrder.join(':')),
        children: [
          for (var index = 0; index <= _taskOrder.length; index++) ...[
            _buildInsertionTarget(context, allTasks, index),
            if (index < _taskOrder.length)
              KeyedSubtree(
                key: ValueKey('task-row-${_taskOrder[index]}'),
                child: TaskCard(
                  task: allTasks[_taskOrder[index]]!,
                  snapshot: widget.snapshot,
                  categoryColor: widget.categoryColor,
                  longestRemaining: widget.longestRemaining,
                  now: widget.now,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsertionTarget(
    BuildContext context,
    Map<int, Task> allTasks,
    int index,
  ) {
    final previewTask = _hoverTaskId == null ? null : allTasks[_hoverTaskId!];
    final active = _hoverIndex == index && previewTask != null;
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        if (!allTasks.containsKey(details.data) ||
            _sameOrder(_taskOrder, _orderAfterDrop(details.data, index))) {
          return false;
        }
        _setHover(index, details.data);
        return true;
      },
      onMove: (details) => _setHover(index, details.data),
      onLeave: (taskId) {
        if (_hoverIndex == index && _hoverTaskId == taskId) {
          _setHover(null, null);
        }
      },
      onAcceptWithDetails: (details) => _drop(details.data, index),
      builder: (context, candidates, rejected) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: active
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.24,
                      child: TaskCard(
                        task: previewTask,
                        snapshot: widget.snapshot,
                        categoryColor: widget.categoryColor,
                        longestRemaining: widget.longestRemaining,
                        now: widget.now,
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity, height: 6),
        );
      },
    );
  }

  List<int> _snapshotOrder() =>
      widget.tasks.map((task) => task.id).toList(growable: false);

  List<int> _orderAfterDrop(int taskId, int gapIndex) {
    final next = List<int>.of(_taskOrder);
    final oldIndex = next.indexOf(taskId);
    if (oldIndex >= 0) next.removeAt(oldIndex);
    var insertionIndex = gapIndex;
    if (oldIndex >= 0 && oldIndex < gapIndex) insertionIndex -= 1;
    insertionIndex = insertionIndex.clamp(0, next.length);
    next.insert(insertionIndex, taskId);
    return next;
  }

  int _insertionIndex(int taskId, int gapIndex) {
    final oldIndex = _taskOrder.indexOf(taskId);
    var insertionIndex = gapIndex;
    if (oldIndex >= 0 && oldIndex < gapIndex) insertionIndex -= 1;
    return insertionIndex.clamp(0, _taskOrder.length);
  }

  void _setHover(int? index, int? taskId) {
    if (!mounted || (_hoverIndex == index && _hoverTaskId == taskId)) return;
    setState(() {
      _hoverIndex = index;
      _hoverTaskId = taskId;
    });
  }

  Future<void> _drop(int taskId, int gapIndex) async {
    final task = widget.snapshot.tasks
        .where((candidate) => candidate.id == taskId)
        .firstOrNull;
    if (task == null) {
      _setHover(null, null);
      return;
    }
    final nextOrder = _orderAfterDrop(taskId, gapIndex);
    final insertionIndex = _insertionIndex(taskId, gapIndex);
    final previousOrder = List<int>.of(_taskOrder);
    setState(() {
      _taskOrder = nextOrder;
      _pendingOrder = List.of(nextOrder);
      _hoverIndex = null;
      _hoverTaskId = null;
    });
    try {
      await ref
          .read(taskRepositoryProvider)
          .move(taskId, widget.categoryId, index: insertionIndex);
      if (!mounted || task.categoryId == widget.categoryId) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).taskMovedTo(widget.categoryTitle),
            ),
          ),
        );
    } on Object {
      if (!mounted) return;
      setState(() {
        _taskOrder = previousOrder;
        _pendingOrder = null;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).operationFailed)),
        );
    }
  }

  bool _sameOrder(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index += 1) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}
