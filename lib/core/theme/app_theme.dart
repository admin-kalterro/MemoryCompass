import 'package:flutter/material.dart';
import 'package:memory_compass/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brass,
      brightness: Brightness.light,
      primary: AppColors.brass,
      onPrimary: AppColors.ink,
      secondary: AppColors.patina,
      onSecondary: AppColors.paper,
      error: AppColors.rust,
      onError: AppColors.paper,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
    );
    return _themeFrom(scheme, scaffoldBackground: const Color(0xFFF3EEE1));
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brass,
      brightness: Brightness.dark,
      primary: AppColors.brass,
      onPrimary: AppColors.ink,
      secondary: AppColors.patina,
      onSecondary: AppColors.paper,
      error: AppColors.rust,
      onError: AppColors.paper,
      surface: AppColors.ink2,
      onSurface: AppColors.paper,
    );
    return _themeFrom(scheme, scaffoldBackground: AppColors.ink);
  }

  static ThemeData _themeFrom(
    ColorScheme scheme, {
    required Color scaffoldBackground,
  }) {
    final textTheme = _textTheme(scheme);

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: scheme.surface),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: scheme.secondary.withValues(alpha: 0.22),
        checkmarkColor: scheme.secondary,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
    );
  }

  /// The instrument-plate serif carries headings and titles; body copy
  /// stays on the platform sans so interface text reads cleanly at small
  /// sizes.
  static TextTheme _textTheme(ColorScheme scheme) {
    const serif = 'serif';
    return ThemeData(colorScheme: scheme, useMaterial3: true).textTheme
        .copyWith(
          headlineSmall: const TextStyle(
            fontFamily: serif,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: const TextStyle(
            fontFamily: serif,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: const TextStyle(
            fontFamily: serif,
            fontWeight: FontWeight.w600,
          ),
        );
  }
}

/// Monospace styling for anything where digits need to line up — grid
/// coordinates, timestamps, sync log entries.
extension AppTextStyleX on TextStyle {
  TextStyle get mono => copyWith(
    fontFamily: 'monospace',
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
