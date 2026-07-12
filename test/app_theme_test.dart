import 'package:ddl_out/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final theme in [AppTheme.light(), AppTheme.dark()]) {
    test('${theme.brightness} input fields remain distinct', () {
      final decoration = theme.inputDecorationTheme;

      expect(decoration.filled, isTrue);
      expect(decoration.fillColor, theme.colorScheme.surfaceContainerHighest);
      expect(decoration.enabledBorder, isA<OutlineInputBorder>());
      expect(
        (decoration.enabledBorder! as OutlineInputBorder).borderSide,
        isNot(BorderSide.none),
      );
      expect(
        (decoration.focusedBorder! as OutlineInputBorder).borderSide.width,
        2,
      );
    });
  }
}
