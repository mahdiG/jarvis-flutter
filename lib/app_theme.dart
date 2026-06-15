import 'package:flutter/material.dart';

/// Custom Zen color palette matching the Stitch design
class ZenColors {
  static const Color background = Color(0xFFFAF9F6);
  static const Color paperBg = Color(0xFFFCFBF8);
  static const Color ink = Color(0xFF1B1C1A);
  static const Color paperSheet = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F1);
  static const Color surfaceContainer = Color(0xFFEFEEEB);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E5);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);
  static const Color onSurfaceVariant = Color(0xFF454743);
  static const Color outline = Color(0xFF767872);
  static const Color outlineVariant = Color(0xFFC6C7C1);
  static const Color secondaryContainer = Color(0xFFDEE5CE);
  static const Color onSecondaryContainer = Color(0xFF606755);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color surfaceDim = Color(0xFFDBDAD7);
  static const Color surfaceBright = Color(0xFFFAF9F6);
  static const Color surfaceVariant = Color(0xFFE3E2E0);
}

class ZenTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: ZenColors.ink,
      onPrimary: ZenColors.paperSheet,
      primaryContainer: ZenColors.ink,
      onPrimaryContainer: const Color(0xFF848481),
      secondary: const Color(0xFF5A614F),
      onSecondary: Colors.white,
      secondaryContainer: ZenColors.secondaryContainer,
      onSecondaryContainer: ZenColors.onSecondaryContainer,
      tertiary: const Color(0xFF020000),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF331203),
      onTertiaryContainer: const Color(0xFFAD7860),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF93000A),
      surface: ZenColors.background,
      onSurface: ZenColors.onSurface,
      surfaceContainerHighest: ZenColors.surfaceContainerHighest,
      onSurfaceVariant: ZenColors.onSurfaceVariant,
      outline: ZenColors.outline,
      outlineVariant: ZenColors.outlineVariant,
      inverseSurface: const Color(0xFF2F312F),
      inversePrimary: const Color(0xFFC7C6C3),
      surfaceTint: const Color(0xFF5E5E5C),
    );

    final textTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        height: 38 / 30,
        letterSpacing: -0.01,
        color: ZenColors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: ZenColors.ink,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 28 / 20,
        color: ZenColors.ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: ZenColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: ZenColors.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 16 / 13,
        letterSpacing: 0.05,
        color: ZenColors.ink,
      ),
      labelMedium: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        letterSpacing: 0.02,
        color: ZenColors.outline,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: ZenColors.paperBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: ZenColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}