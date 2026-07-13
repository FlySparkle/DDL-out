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
    final navigationIndicatorShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final navigationBackground = scheme.surfaceContainerLow;
    final navigationLabelStyle = WidgetStateProperty.resolveWith<TextStyle?>(
      (states) => TextStyle(
        color: states.contains(WidgetState.selected)
            ? scheme.onSecondaryContainer
            : scheme.onSurfaceVariant,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.w500,
      ),
    );
    final navigationIconTheme = WidgetStateProperty.resolveWith<IconThemeData?>(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? scheme.onSecondaryContainer
            : scheme.onSurfaceVariant,
        size: 24,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: navigationBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: navigationIndicatorShape,
        labelTextStyle: navigationLabelStyle,
        iconTheme: navigationIconTheme,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: navigationBackground,
        elevation: 0,
        useIndicator: true,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: navigationIndicatorShape,
        unselectedLabelTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
        unselectedIconTheme: IconThemeData(
          color: scheme.onSurfaceVariant,
          size: 24,
        ),
        selectedIconTheme: IconThemeData(
          color: scheme.onSecondaryContainer,
          size: 24,
        ),
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
        textStyle: TextStyle(color: scheme.onInverseSurface),
      ),
    );
  }
}
