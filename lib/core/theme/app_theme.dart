import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const brandColor = Color.fromARGB(255, 250, 180, 17);

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
        surfaceTintColor: Colors.transparent,
        backgroundColor: scheme.surfaceContainerLow,
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
        fillColor: scheme.surfaceContainerHighest,
        hoverColor: scheme.primary.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: base.textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
    );
  }
}
