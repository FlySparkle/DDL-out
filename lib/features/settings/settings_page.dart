import 'package:flutter/material.dart';

import '../../app/navigation/app_navigation_shell.dart';

class SettingsPageScaffold extends StatelessWidget {
  const SettingsPageScaffold({
    required this.destination,
    required this.title,
    required this.body,
    this.showBackButton = false,
    this.actions,
    super.key,
  });

  final AppNavigationDestinationId destination;
  final String title;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;

  static const contentPadding = EdgeInsets.fromLTRB(16, 8, 16, 32);

  @override
  Widget build(BuildContext context) {
    final fixedNavigation = AppNavigationScope.maybeOf(context)?.fixed ?? false;
    return Scaffold(
      drawer: fixedNavigation
          ? null
          : AppNavigationDrawer(selectedDestination: destination),
      drawerEnableOpenDragGesture: !fixedNavigation,
      drawerEdgeDragWidth: fixedNavigation
          ? null
          : AppNavigationLayout.floatingDrawerDragWidth(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? BackButton(
                style: AppNavigationVisuals.controlButtonStyle(context),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : fixedNavigation
            ? null
            : Builder(
                builder: (context) => DrawerButton(
                  style: AppNavigationVisuals.controlButtonStyle(context),
                ),
              ),
        title: Text(title),
        actions: actions,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListTileTheme.merge(
            shape: AppNavigationVisuals.navigationShape,
            child: SizedBox(width: double.infinity, child: body),
          ),
        ),
      ),
    );
  }
}

void showSettingsMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
