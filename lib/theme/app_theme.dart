import 'package:flutter/material.dart';

/// Design tokens extracted 1:1 from the Halati DESIGN.md style guide
/// (Material 3 based, "Corporate Modern" palette).
class AppColors {
  AppColors._();

  // Light scheme
  static const primary = Color(0xFF022448);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF1E3A5F);
  static const onPrimaryContainer = Color(0xFF8AA4CF);

  static const secondary = Color(0xFF0051D5);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF316BF3);
  static const onSecondaryContainer = Color(0xFFFEFCFF);

  static const tertiary = Color(0xFF002B0E);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF00431A);
  static const onTertiaryContainer = Color(0xFF00BB56);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFF7F9FC);
  static const onBackground = Color(0xFF191C1E);
  static const surface = Color(0xFFF7F9FC);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF43474E);
  static const surfaceVariant = Color(0xFFE0E3E6);

  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F7);
  static const surfaceContainer = Color(0xFFECEEF1);
  static const surfaceContainerHigh = Color(0xFFE6E8EB);
  static const surfaceContainerHighest = Color(0xFFE0E3E6);

  static const outline = Color(0xFF74777F);
  static const outlineVariant = Color(0xFFC4C6CF);

  static const inverseSurface = Color(0xFF2D3133);
  static const inverseOnSurface = Color(0xFFEFF1F4);

  // Dedicated dark-mode secondary/body text color — deliberately *not*
  // reusing outlineVariant (meant for thin borders/dividers, not text).
  // Reusing that light-gray-on-light-gray token previously made list
  // subtitles (file size, date, timestamps) nearly unreadable against
  // Halati's dark surface colors.
  static const darkOnSurfaceVariant = Color(0xFFB8C2CC);

  // "Communication Green" gradient — reserved for WhatsApp-flavoured actions
  static const waGreenStart = Color(0xFF25D366);
  static const waGreenEnd = Color(0xFF128C7E);

  // Dark mode
  static const darkBackground = Color(0xFF111B21);
  static const darkSurface = Color(0xFF1F2C34);
}

class AppRadius {
  AppRadius._();
  static const sm = 4.0;
  static const md = 12.0;
  static const lg = 20.0;
  static const xl = 24.0;
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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
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
        primary: AppColors.onPrimaryContainer,
        onPrimary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondaryContainer,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondary,
        onSecondaryContainer: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        error: AppColors.error,
        surfaceContainerLowest: Color(0xFF16232A),
        surfaceContainerLow: Color(0xFF1A2830),
        surfaceContainer: AppColors.darkSurface,
        surfaceContainerHigh: Color(0xFF25333B),
        surfaceContainerHighest: Color(0xFF2C3B43),
        outline: AppColors.outline,
        outlineVariant: Color(0xFF3A4750),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
