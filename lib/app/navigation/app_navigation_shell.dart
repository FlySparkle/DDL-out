import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/settings/application/settings.dart';
import '../../l10n/app_localizations.dart';

abstract final class AppNavigationLayout {
  static const double minimumFixedWidth = 800;
  static const double automaticExpansionWidth = 1100;
  static const double collapsedWidth = 72;
  static const double expandedWidth = 256;
  static const Duration hoverExpansionDelay = Duration(milliseconds: 450);
  static const Duration hoverCollapseDelay = Duration(milliseconds: 500);

  static bool canUseFixed(double width) => width >= minimumFixedWidth;
}

abstract final class AppNavigationVisuals {
  static ButtonStyle controlButtonStyle(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return IconButton.styleFrom(
      foregroundColor: color,
      hoverColor: color.withValues(alpha: 0.08),
      focusColor: color.withValues(alpha: 0.10),
      highlightColor: color.withValues(alpha: 0.12),
    );
  }
}

class AppNavigationShell extends ConsumerWidget {
  const AppNavigationShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarMode = ref.watch(
      settingsControllerProvider.select((settings) => settings.sidebarMode),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final fixed =
            sidebarMode == SidebarMode.fixed &&
            AppNavigationLayout.canUseFixed(constraints.maxWidth);
        final selectedIndex = location.startsWith('/settings') ? 1 : 0;
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AppNavigationScope(
            fixed: fixed,
            selectedIndex: selectedIndex,
            child: fixed
                ? FixedAppNavigation(selectedIndex: selectedIndex, child: child)
                : child,
          ),
        );
      },
    );
  }
}

class AppNavigationScope extends InheritedWidget {
  const AppNavigationScope({
    required this.fixed,
    required this.selectedIndex,
    required super.child,
    super.key,
  });

  final bool fixed;
  final int selectedIndex;

  static AppNavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppNavigationScope>();
  }

  @override
  bool updateShouldNotify(AppNavigationScope oldWidget) {
    return fixed != oldWidget.fixed || selectedIndex != oldWidget.selectedIndex;
  }
}

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationDrawer(
      selectedIndex: selectedIndex,
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
    if (router == null || index == selectedIndex) return;
    router.go(index == 0 ? '/' : '/settings');
  }
}

class FixedAppNavigation extends StatefulWidget {
  const FixedAppNavigation({
    required this.selectedIndex,
    required this.child,
    super.key,
  });

  final int selectedIndex;
  final Widget child;

  @override
  State<FixedAppNavigation> createState() => _FixedAppNavigationState();
}

class _FixedAppNavigationState extends State<FixedAppNavigation> {
  static const _animationDuration = Duration(milliseconds: 220);

  bool? _manuallyExpanded;
  bool _hovered = false;
  Timer? _hoverTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationBackground =
        theme.navigationRailTheme.backgroundColor ??
        theme.colorScheme.surfaceContainerLow;
    return LayoutBuilder(
      builder: (context, constraints) {
        final automaticallyExpanded =
            constraints.maxWidth >= AppNavigationLayout.automaticExpansionWidth;
        final expanded = _manuallyExpanded ?? automaticallyExpanded;
        final visuallyExpanded = expanded || _hovered;
        final contentInset = expanded
            ? AppNavigationLayout.expandedWidth
            : AppNavigationLayout.collapsedWidth;

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
                onEnter: (_) => _scheduleHover(expanded: expanded, value: true),
                onExit: (_) => _scheduleHover(expanded: expanded, value: false),
                child: AnimatedPhysicalModel(
                  duration: _animationDuration,
                  curve: Curves.easeInOutCubicEmphasized,
                  elevation: _hovered && !expanded ? 8 : 0,
                  shadowColor: theme.colorScheme.shadow,
                  color: navigationBackground,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _AppNavigationRail(
                    selectedIndex: widget.selectedIndex,
                    expanded: visuallyExpanded,
                    pinnedExpanded: expanded,
                    onToggle: () {
                      _hoverTimer?.cancel();
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

  void _scheduleHover({required bool expanded, required bool value}) {
    _hoverTimer?.cancel();
    if (expanded || _hovered == value) return;
    final delay = value
        ? AppNavigationLayout.hoverExpansionDelay
        : AppNavigationLayout.hoverCollapseDelay;
    _hoverTimer = Timer(delay, () {
      if (mounted) setState(() => _hovered = value);
    });
  }
}

class _AppNavigationRail extends StatelessWidget {
  const _AppNavigationRail({
    required this.selectedIndex,
    required this.expanded,
    required this.pinnedExpanded,
    required this.onToggle,
  });

  final int selectedIndex;
  final bool expanded;
  final bool pinnedExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final navigationBackground =
        theme.navigationRailTheme.backgroundColor ??
        theme.colorScheme.surfaceContainerLow;
    return ColoredBox(
      color: navigationBackground,
      child: Stack(
        children: [
          NavigationRail(
            backgroundColor: navigationBackground,
            selectedIndex: selectedIndex,
            extended: expanded,
            minWidth: AppNavigationLayout.collapsedWidth,
            minExtendedWidth: AppNavigationLayout.expandedWidth,
            onDestinationSelected: (index) {
              if (index == selectedIndex) return;
              GoRouter.of(context).go(index == 0 ? '/' : '/settings');
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
          ),
          Positioned(
            left: 8,
            bottom: 12,
            child: IconButton(
              key: const ValueKey('fixed-navigation-toggle'),
              tooltip: pinnedExpanded
                  ? l10n.collapseSidebar
                  : l10n.expandSidebar,
              style: AppNavigationVisuals.controlButtonStyle(context),
              onPressed: onToggle,
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
    );
  }
}
