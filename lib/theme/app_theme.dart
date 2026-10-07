import 'package:flutter/material.dart';

/// Halati 2026 design system.
/// Soft Light is intentionally warm rather than pure white; Dark keeps the same visual language.
class AppColors {
  AppColors._();

  // Soft Light
  static const primary = Color(0xFF176B67);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD5EFEB);
  static const onPrimaryContainer = Color(0xFF073B39);
  static const secondary = Color(0xFF7B5E3B);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFF1E2CF);
  static const onSecondaryContainer = Color(0xFF3B2A1A);
  static const tertiary = Color(0xFF596B8A);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFDDE5F4);
  static const onTertiaryContainer = Color(0xFF17243A);
  static const error = Color(0xFFB84747);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFF8DAD7);
  static const onErrorContainer = Color(0xFF5F1112);
  static const background = Color(0xFFF4F1EB);
  static const onBackground = Color(0xFF252725);
  static const surface = Color(0xFFF4F1EB);
  static const onSurface = Color(0xFF252725);
  static const onSurfaceVariant = Color(0xFF686A66);
  static const surfaceVariant = Color(0xFFE8E3DA);
  static const surfaceContainerLowest = Color(0xFFFCFAF6);
  static const surfaceContainerLow = Color(0xFFF8F5EF);
  static const surfaceContainer = Color(0xFFEFEAE1);
  static const surfaceContainerHigh = Color(0xFFE9E4DA);
  static const surfaceContainerHighest = Color(0xFFE1DBD0);
  static const outline = Color(0xFF89877F);
  static const outlineVariant = Color(0xFFD2CDC3);
  static const inverseSurface = Color(0xFF303432);
  static const inverseOnSurface = Color(0xFFF4F1EB);

  // Dark
  static const darkBackground = Color(0xFF111716);
  static const darkSurface = Color(0xFF1A2321);
  static const darkSurfaceLow = Color(0xFF151D1C);
  static const darkSurfaceHigh = Color(0xFF24302D);
  static const darkPrimary = Color(0xFF78D0C5);
  static const darkOnSurface = Color(0xFFE7ECE9);
  static const darkOnSurfaceVariant = Color(0xFFB6C2BE);
  static const darkOutline = Color(0xFF687773);

  static const waGreenStart = Color(0xFF25D366);
  static const waGreenEnd = Color(0xFF128C7E);
}

class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const full = 999.0;
}

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = base.textTheme.apply(fontFamily: 'Cairo');
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = base.textTheme.apply(fontFamily: 'Cairo');
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: Color(0xFF073B39),
        primaryContainer: Color(0xFF174945),
        onPrimaryContainer: Color(0xFFB6E9E2),
        secondary: Color(0xFFD9B98E),
        onSecondary: Color(0xFF3B2A1A),
        secondaryContainer: Color(0xFF55432E),
        onSecondaryContainer: Color(0xFFF1E2CF),
        tertiary: Color(0xFFB9C9E8),
        onTertiary: Color(0xFF17243A),
        tertiaryContainer: Color(0xFF35445E),
        onTertiaryContainer: Color(0xFFDDE5F4),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        surfaceContainerLowest: AppColors.darkSurfaceLow,
        surfaceContainerLow: Color(0xFF18201F),
        surfaceContainer: AppColors.darkSurface,
        surfaceContainerHigh: AppColors.darkSurfaceHigh,
        surfaceContainerHighest: Color(0xFF2B3935),
        outline: AppColors.darkOutline,
        outlineVariant: Color(0xFF394743),
        inverseSurface: Color(0xFFE7ECE9),
        onInverseSurface: Color(0xFF29302E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFF394743)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFF394743)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceLow,
        elevation: 0,
        indicatorColor: Color(0xFF174945),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Color(0xFF073B39),
        elevation: 2,
      ),
    );
  }
}
