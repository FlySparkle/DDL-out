import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../dialogs/category_editor.dart';
import 'board_states.dart';
import 'category_section.dart';

class BoardContent extends ConsumerWidget {
  const BoardContent({required this.snapshot, super.key});

  final BoardSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (snapshot.categories.isEmpty && snapshot.tasks.isEmpty) {
      return BoardEmptyState(
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
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
          buildDefaultDragHandles: false,
          header: uncategorized.isEmpty
              ? null
              : CategorySection(
                  snapshot: snapshot,
                  category: null,
                  title: l10n.uncategorized,
                  color: Theme.of(context).colorScheme.secondary,
                  tasks: uncategorized,
                ),
          itemCount: snapshot.categories.length,
          itemBuilder: (context, index) {
            final category = snapshot.categories[index];
            return CategorySection(
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
