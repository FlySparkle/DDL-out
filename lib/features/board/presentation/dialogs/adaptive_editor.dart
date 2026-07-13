import 'package:flutter/material.dart';

Future<void> showAdaptiveEditor(
  BuildContext context, {
  required Widget child,
}) async {
  final isAndroid = Theme.of(context).platform == TargetPlatform.android;
  if (isAndroid) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: child,
      ),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 760),
        child: child,
      ),
    ),
  );
}
