import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';

abstract final class BoardNavigationLayout {
  static const double minimumFixedWidth = 800;
  static const double automaticExpansionWidth = 1100;
  static const double collapsedWidth = 72;
  static const double expandedWidth = 256;

  static bool canUseFixed(double width) => width >= minimumFixedWidth;
}

class BoardNavigationDrawer extends StatelessWidget {
  const BoardNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationDrawer(
      selectedIndex: 0,
      onDestinationSelected: (index) => _selectDestination(context, index),
      children: [
        const SizedBox(height: 12),
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

  void _selectDestination(BuildContext context, int index) {
    final router = GoRouter.maybeOf(context);
    Navigator.pop(context);
    if (index == 1) router?.push('/settings');
  }
}

class FixedBoardNavigation extends StatefulWidget {
  const FixedBoardNavigation({required this.child, super.key});

  final Widget child;

  @override
  State<FixedBoardNavigation> createState() => _FixedBoardNavigationState();
}

class _FixedBoardNavigationState extends State<FixedBoardNavigation> {
  static const _animationDuration = Duration(milliseconds: 220);

  bool? _manuallyExpanded;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final automaticallyExpanded =
            constraints.maxWidth >=
            BoardNavigationLayout.automaticExpansionWidth;
        final expanded = _manuallyExpanded ?? automaticallyExpanded;
        final visuallyExpanded = expanded || _hovered;
        final contentInset = expanded
            ? BoardNavigationLayout.expandedWidth
            : BoardNavigationLayout.collapsedWidth;

        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedPositioned(
              duration: _animationDuration,
              curve: Curves.easeInOutCubicEmphasized,
              left: contentInset,
              top: 0,
              right: 0,
              bottom: 0,
              child: widget.child,
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                onEnter: (_) {
                  if (!expanded) setState(() => _hovered = true);
                },
                onExit: (_) {
                  if (_hovered) setState(() => _hovered = false);
                },
                child: AnimatedPhysicalModel(
                  duration: _animationDuration,
                  curve: Curves.easeInOutCubicEmphasized,
                  elevation: _hovered && !expanded ? 8 : 0,
                  shadowColor: Theme.of(context).colorScheme.shadow,
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  child: _BoardNavigationRail(
                    expanded: visuallyExpanded,
                    pinnedExpanded: expanded,
                    onToggle: () {
                      setState(() {
                        _manuallyExpanded = !expanded;
                        _hovered = false;
                      });
                    },
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

class _BoardNavigationRail extends StatelessWidget {
  const _BoardNavigationRail({
    required this.expanded,
    required this.pinnedExpanded,
    required this.onToggle,
  });

  final bool expanded;
  final bool pinnedExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationRail(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      selectedIndex: 0,
      extended: expanded,
      minWidth: BoardNavigationLayout.collapsedWidth,
      minExtendedWidth: BoardNavigationLayout.expandedWidth,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconButton(
          key: const ValueKey('fixed-navigation-toggle'),
          tooltip: pinnedExpanded ? l10n.collapseSidebar : l10n.expandSidebar,
          onPressed: onToggle,
          icon: AnimatedRotation(
            turns: pinnedExpanded ? 0.5 : 0,
            duration: _FixedBoardNavigationState._animationDuration,
            child: const Icon(Icons.chevron_right),
          ),
        ),
      ),
      onDestinationSelected: (index) {
        if (index == 1) GoRouter.maybeOf(context)?.push('/settings');
      },
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(l10n.boardTitle),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(l10n.settingsTitle),
        ),
      ],
    );
  }
}
