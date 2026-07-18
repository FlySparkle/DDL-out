import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../dialogs/category_editor.dart';
import '../dialogs/task_editor.dart';
import 'board_states.dart';
import 'category_section.dart';

class BoardContent extends ConsumerStatefulWidget {
  const BoardContent({required this.snapshot, super.key});

  final BoardSnapshot snapshot;

  @override
  ConsumerState<BoardContent> createState() => _BoardContentState();
}

class _BoardContentState extends ConsumerState<BoardContent> {
  late List<int> _categoryOrder;
  List<int>? _pendingOrder;

  @override
  void initState() {
    super.initState();
    _categoryOrder = _snapshotOrder(widget.snapshot);
  }

  @override
  void didUpdateWidget(BoardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incomingOrder = _snapshotOrder(widget.snapshot);
    final pending = _pendingOrder;
    if (pending != null && _sameOrder(incomingOrder, pending)) {
      _pendingOrder = null;
      _categoryOrder = incomingOrder;
      return;
    }
    if (pending == null) {
      _categoryOrder = incomingOrder;
      return;
    }

    final incomingIds = incomingOrder.toSet();
    final localIds = _categoryOrder.toSet();
    if (incomingIds.length != localIds.length ||
        !incomingIds.containsAll(localIds)) {
      _categoryOrder = [
        ..._categoryOrder.where(incomingIds.contains),
        ...incomingOrder.where((id) => !localIds.contains(id)),
      ];
      _pendingOrder = List.of(_categoryOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = widget.snapshot;
    if (snapshot.categories.isEmpty && snapshot.tasks.isEmpty) {
      return BoardEmptyState(
        onCreateTask: () => showTaskEditor(
          context,
          snapshot: snapshot,
          initialCategoryId: null,
        ),
        onCreateCategory: () => showCategoryEditor(context),
      );
    }

    final uncategorized = snapshot.tasks
        .where((task) => task.categoryId == null)
        .toList(growable: false);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 96),
          children: [
            if (uncategorized.isNotEmpty)
              CategorySection(
                snapshot: snapshot,
                category: null,
                title: l10n.uncategorized,
                color: Theme.of(context).colorScheme.secondary,
                tasks: uncategorized,
              ),
            for (final categoryId in _categoryOrder)
              _buildCategoryTarget(snapshot, categoryId),
          ],
        ),
      ),
    );
  }

  List<int> _snapshotOrder(BoardSnapshot snapshot) =>
      snapshot.categories.map((category) => category.id).toList();

  bool _sameOrder(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  Widget _buildCategoryTarget(BoardSnapshot snapshot, int categoryId) {
    final category = snapshot.categories.firstWhere(
      (category) => category.id == categoryId,
    );
    return DragTarget<CategoryDragData>(
      onWillAcceptWithDetails: (details) => details.data.id != categoryId,
      onAcceptWithDetails: (details) =>
          _moveCategory(details.data.id, categoryId),
      builder: (context, candidates, rejected) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          border: Border.all(
            color: candidates.isEmpty
                ? Colors.transparent
                : Theme.of(context).colorScheme.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: CategorySection(
          key: ValueKey('category-$categoryId'),
          snapshot: snapshot,
          category: category,
          title: category.name,
          color: Color(category.colorArgb),
          tasks: snapshot.tasks
              .where((task) => task.categoryId == categoryId)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> _moveCategory(int draggedId, int targetId) async {
    final oldIndex = _categoryOrder.indexOf(draggedId);
    final targetIndex = _categoryOrder.indexOf(targetId);
    if (oldIndex < 0 || targetIndex < 0 || oldIndex == targetIndex) return;
    setState(() {
      final moved = _categoryOrder.removeAt(oldIndex);
      _categoryOrder.insert(targetIndex, moved);
      _pendingOrder = List.of(_categoryOrder);
    });
    final reordered = List<int>.of(_categoryOrder);
    try {
      await ref.read(categoryRepositoryProvider).reorder(reordered);
    } on Object {
      if (!mounted) return;
      setState(() {
        _categoryOrder = _snapshotOrder(widget.snapshot);
        _pendingOrder = null;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).operationFailed)),
        );
    }
  }
}
