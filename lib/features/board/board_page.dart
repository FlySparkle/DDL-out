import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation/app_navigation_shell.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/board_providers.dart';
import '../../l10n/app_localizations.dart';
import 'presentation/dialogs/category_editor.dart';
import 'presentation/dialogs/confirmation_dialog.dart';
import 'presentation/dialogs/task_editor.dart';
import 'presentation/widgets/board_content.dart';
import 'presentation/widgets/board_states.dart';

export 'application/current_time_provider.dart';

class BoardPage extends ConsumerWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final board = ref.watch(boardProvider);
    final fixedNavigation = AppNavigationScope.maybeOf(context)?.fixed ?? false;
    return Scaffold(
      drawer: fixedNavigation
          ? null
          : const AppNavigationDrawer(
              selectedDestination: AppNavigationDestinationId.board,
            ),
      drawerEnableOpenDragGesture: !fixedNavigation,
      drawerEdgeDragWidth: fixedNavigation
          ? null
          : AppNavigationLayout.floatingDrawerDragWidth(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: fixedNavigation
            ? null
            : Builder(
                builder: (context) => DrawerButton(
                  style: AppNavigationVisuals.controlButtonStyle(context),
                ),
              ),
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.newCategory,
            onPressed: () => showCategoryEditor(context),
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          IconButton(
            tooltip: l10n.clearCompleted,
            onPressed: (board.value?.completedCount ?? 0) == 0
                ? null
                : () => _clearCompleted(context, ref, board.value!),
            icon: const Icon(Icons.playlist_remove),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.newTask,
        onPressed: board.value == null
            ? null
            : () => showTaskEditor(
                context,
                snapshot: board.value!,
                initialCategoryId: null,
              ),
        child: const Icon(Icons.add_task),
      ),
      body: board.when(
        data: (snapshot) => BoardContent(snapshot: snapshot),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => BoardErrorState(
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
      confirmLabel: l10n.clearCompletedConfirm,
    );
    if (confirmed) await ref.read(taskRepositoryProvider).clearCompleted();
  }
}
