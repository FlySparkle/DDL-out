import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const brandColor = Color(0xFF4A90E2);

  static ThemeData light({
    ColorScheme? dynamicScheme,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    return _build(
      dynamicScheme ??
          ColorScheme.fromSeed(
            seedColor: brandColor,
            brightness: Brightness.light,
          ),
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );
  }

  static ThemeData dark({
    ColorScheme? dynamicScheme,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    return _build(
      dynamicScheme ??
          ColorScheme.fromSeed(
            seedColor: brandColor,
            brightness: Brightness.dark,
          ),
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );
  }

  static ThemeData _build(
    ColorScheme scheme, {
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: TextStyle(color: scheme.onInverseSurface),
      ),
    );
  }
}
