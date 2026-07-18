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
  static const Duration expansionDuration = Duration(milliseconds: 220);
  static const Duration hoverExpansionDelay = Duration(milliseconds: 450);
  static const Duration hoverCollapseDelay = Duration(milliseconds: 500);

  static bool canUseFixed(double width) => width >= minimumFixedWidth;

  static double? floatingDrawerDragWidth(BuildContext context) {
    final platform = Theme.of(context).platform;
    final mobile =
        platform == TargetPlatform.android || platform == TargetPlatform.iOS;
    return mobile ? MediaQuery.sizeOf(context).width : null;
  }
}

abstract final class AppNavigationVisuals {
  static const navigationShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerLow;
  }

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
        final selectedDestination = AppNavigationDestinationId.fromLocation(
          location,
        );
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AppNavigationScope(
            fixed: fixed,
            child: fixed
                ? FixedAppNavigation(
                    selectedDestination: selectedDestination,
                    child: child,
                  )
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
    required super.child,
    super.key,
  });

  final bool fixed;

  static AppNavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppNavigationScope>();
  }

  @override
  bool updateShouldNotify(AppNavigationScope oldWidget) {
    return fixed != oldWidget.fixed;
  }
}

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({required this.selectedDestination, super.key});

  final AppNavigationDestinationId selectedDestination;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: AppNavigationLayout.expandedWidth,
      elevation: 0,
      backgroundColor: AppNavigationVisuals.backgroundColor(context),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: SafeArea(
        child: _AppNavigationPanel(
          selectedDestination: selectedDestination,
          expanded: true,
          onDestinationSelected: (destination) =>
              _selectDestination(context, destination),
        ),
      ),
    );
  }

  void _selectDestination(
    BuildContext context,
    AppNavigationDestinationId destination,
  ) {
    final router = GoRouter.maybeOf(context);
    Navigator.pop(context);
    if (router == null || destination == selectedDestination) return;
    _navigateToDestination(router, selectedDestination, destination);
  }
}

void _navigateToDestination(
  GoRouter router,
  AppNavigationDestinationId current,
  AppNavigationDestinationId destination,
) {
  if (destination == AppNavigationDestinationId.board) {
    router.go('/');
  } else if (current == AppNavigationDestinationId.board) {
    router.push(destination.route);
  } else {
    router.replace(destination.route);
  }
}

enum AppNavigationDestinationId {
  board('/'),
  appearance('/settings/appearance'),
  systemData('/settings/system-data'),
  about('/settings/about'),
  community('/settings/community');

  const AppNavigationDestinationId(this.route);

  final String route;

  static AppNavigationDestinationId fromLocation(String location) {
    if (location.startsWith('/settings/system-data')) return systemData;
    if (location.startsWith('/settings/about')) return about;
    if (location.startsWith('/settings/community')) return community;
    if (location.startsWith('/settings')) return appearance;
    return board;
  }
}

class FixedAppNavigation extends StatefulWidget {
  const FixedAppNavigation({
    required this.selectedDestination,
    required this.child,
    super.key,
  });

  final AppNavigationDestinationId selectedDestination;
  final Widget child;

  @override
  State<FixedAppNavigation> createState() => _FixedAppNavigationState();
}

class _FixedAppNavigationState extends State<FixedAppNavigation> {
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
    final navigationBackground = AppNavigationVisuals.backgroundColor(context);
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
              duration: AppNavigationLayout.expansionDuration,
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
                  duration: AppNavigationLayout.expansionDuration,
                  curve: Curves.easeInOutCubicEmphasized,
                  elevation: _hovered && !expanded ? 8 : 0,
                  shadowColor: theme.colorScheme.shadow,
                  color: navigationBackground,
                  borderRadius: const BorderRadius.all(Radius.zero),
                  clipBehavior: Clip.antiAlias,
                  child: _AppNavigationPanel(
                    selectedDestination: widget.selectedDestination,
                    expanded: visuallyExpanded,
                    onDestinationSelected: (destination) {
                      if (destination == widget.selectedDestination) return;
                      _navigateToDestination(
                        GoRouter.of(context),
                        widget.selectedDestination,
                        destination,
                      );
                    },
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

class _AppNavigationPanel extends StatelessWidget {
  const _AppNavigationPanel({
    required this.selectedDestination,
    required this.expanded,
    required this.onDestinationSelected,
    this.pinnedExpanded,
    this.onToggle,
  });

  final AppNavigationDestinationId selectedDestination;
  final bool expanded;
  final ValueChanged<AppNavigationDestinationId> onDestinationSelected;
  final bool? pinnedExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = _destinations(l10n);
    final targetWidth = expanded
        ? AppNavigationLayout.expandedWidth
        : AppNavigationLayout.collapsedWidth;
    return TweenAnimationBuilder<double>(
      key: onToggle == null
          ? const ValueKey('floating-navigation-panel')
          : const ValueKey('fixed-navigation-panel'),
      tween: Tween(end: targetWidth),
      duration: AppNavigationLayout.expansionDuration,
      curve: Curves.easeInOutCubicEmphasized,
      builder: (context, width, _) {
        final expansionProgress =
            ((width - AppNavigationLayout.collapsedWidth) /
                    (AppNavigationLayout.expandedWidth -
                        AppNavigationLayout.collapsedWidth))
                .clamp(0.0, 1.0);
        return SizedBox(
          width: width,
          child: ColoredBox(
            color: AppNavigationVisuals.backgroundColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                _AppNavigationButton(
                  key: ValueKey(
                    'navigation-destination-${destinations.first.id.name}',
                  ),
                  labelTransitionKey: ValueKey(
                    'navigation-label-transition-${destinations.first.id.name}',
                  ),
                  destination: destinations.first,
                  selected: destinations.first.id == selectedDestination,
                  expansionProgress: expansionProgress,
                  onPressed: () => onDestinationSelected(destinations.first.id),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 + (4 * expansionProgress),
                  ),
                  child: const Divider(height: 1),
                ),
                SizedBox(
                  height: 36,
                  child: Opacity(
                    opacity: expansionProgress,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 12),
                      child: Text(
                        l10n.settingsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
                for (final destination in destinations.skip(1)) ...[
                  _AppNavigationButton(
                    key: ValueKey(
                      'navigation-destination-${destination.id.name}',
                    ),
                    labelTransitionKey: ValueKey(
                      'navigation-label-transition-${destination.id.name}',
                    ),
                    destination: destination,
                    selected: destination.id == selectedDestination,
                    expansionProgress: expansionProgress,
                    onPressed: () => onDestinationSelected(destination.id),
                  ),
                  if (destination != destinations.last)
                    const SizedBox(height: 8),
                ],
                if (onToggle != null) ...[
                  const Spacer(),
                  _AppNavigationButton(
                    key: const ValueKey('fixed-navigation-toggle'),
                    labelTransitionKey: const ValueKey(
                      'fixed-navigation-toggle-label-transition',
                    ),
                    destination: _AppNavigationDestination(
                      id: AppNavigationDestinationId.board,
                      label: pinnedExpanded!
                          ? l10n.collapseSidebar
                          : l10n.expandSidebar,
                      icon: Icons.menu,
                      selectedIcon: Icons.menu,
                    ),
                    selected: false,
                    expansionProgress: expansionProgress,
                    onPressed: onToggle!,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppNavigationButton extends StatelessWidget {
  const _AppNavigationButton({
    required this.destination,
    required this.selected,
    required this.expansionProgress,
    required this.onPressed,
    this.labelTransitionKey,
    super.key,
  });

  final _AppNavigationDestination destination;
  final bool selected;
  final double expansionProgress;
  final VoidCallback onPressed;
  final Key? labelTransitionKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: foreground,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
    );
    final labelOpacity = Curves.easeOutCubic.transform(expansionProgress);
    final horizontalMargin = 8 + (4 * expansionProgress);
    final button = Material(
      color: selected ? scheme.secondaryContainer : Colors.transparent,
      shape: AppNavigationVisuals.navigationShape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: AppNavigationVisuals.navigationShape,
        onTap: onPressed,
        child: SizedBox(
          height: 56,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final labelWidth = (constraints.maxWidth - 68).clamp(
                0.0,
                double.infinity,
              );
              return Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        selected ? destination.selectedIcon : destination.icon,
                        color: foreground,
                        size: 24,
                      ),
                    ),
                  ),
                  if (expansionProgress > 0 && labelWidth > 0)
                    Positioned(
                      left: 52,
                      top: 0,
                      bottom: 0,
                      width: labelWidth,
                      child: Opacity(
                        key: labelTransitionKey,
                        opacity: labelOpacity,
                        child: Transform.translate(
                          offset: Offset(-12 * (1 - expansionProgress), 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              destination.label,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              softWrap: false,
                              style: labelStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
    final padded = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: button,
    );
    return expansionProgress > 0
        ? padded
        : Tooltip(message: destination.label, child: padded);
  }
}

class _AppNavigationDestination {
  const _AppNavigationDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final AppNavigationDestinationId id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

List<_AppNavigationDestination> _destinations(AppLocalizations l10n) => [
  _AppNavigationDestination(
    id: AppNavigationDestinationId.board,
    label: l10n.boardTitle,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  _AppNavigationDestination(
    id: AppNavigationDestinationId.appearance,
    label: l10n.appearanceSettingsTitle,
    icon: Icons.palette_outlined,
    selectedIcon: Icons.palette,
  ),
  _AppNavigationDestination(
    id: AppNavigationDestinationId.systemData,
    label: l10n.systemDataSettingsTitle,
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune,
  ),
  _AppNavigationDestination(
    id: AppNavigationDestinationId.about,
    label: l10n.aboutSettingsTitle,
    icon: Icons.info_outline,
    selectedIcon: Icons.info,
  ),
  _AppNavigationDestination(
    id: AppNavigationDestinationId.community,
    label: l10n.communitySettingsTitle,
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
  ),
];
