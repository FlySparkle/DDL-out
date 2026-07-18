import 'package:flutter/material.dart';

class SettingsTileGroup extends StatelessWidget {
  const SettingsTileGroup({required this.children, super.key});

  static const double spacing = 8;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: spacing),
          children[index],
        ],
      ],
    );
  }
}
