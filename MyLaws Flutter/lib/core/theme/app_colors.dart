import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppColors {
  // Light Palette - Warm Aged Parchment
  static const Color lightBackground =
      Color(0xFFF1EDE1); // Canvas Background (warm parchment)
  static const Color lightSurface = Color(0xFFFAF7F0); // Surface / Card
  static const Color lightSurfaceElevated =
      Color(0xFFFDFBFA); // Card Surface Elevated
  static const Color lightSurfaceVariant = Color(0xFFFAF7F0);
  static const Color lightText =
      Color(0xFF231F1C); // Primary Ink Text (rich slate-black)
  static const Color lightSecondaryText =
      Color(0xFF5A534A); // Secondary Muted Text
  static const Color antiqueGold = Color(0xFF9A6F32); // Antique Gold Accent
  static const Color warmBronze = Color(0xFFB68B4C); // Warm Bronze Accent
  static const Color subtleGridBorder =
      Color(0xFFDDD3C1); // Subtle Grid / Border
  static const Color lightOutline = subtleGridBorder;
  static const Color lightOutlineVariant = subtleGridBorder;
  static const Color lightPrimary = Color(
      0xFF966C2E); // Deep Antique Gold (WCAG AA compliant >= 4.5:1 against white)
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFFAF7F0);
  static const Color lightOnPrimaryContainer = Color(0xFF231F1C);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);

  // Dark Palette - Deep Charcoal Parchment
  static const Color darkBackground =
      Color(0xFF141210); // Dark Canvas Background (deep charcoal parchment)
  static const Color darkSurface = Color(0xFF1E1A17); // Dark Surface / Card
  static const Color darkSurfaceElevated =
      Color(0xFF28231E); // Dark Card Surface Elevated
  static const Color darkSurfaceVariant = Color(0xFF28231E);
  static const Color darkText = Color(0xFFF1EDE1); // Dark Primary Text
  static const Color darkSecondaryText =
      Color(0xFFA89F91); // Dark Secondary Text
  static const Color darkGold = Color(0xFFD8AE6A); // Dark Gold Accent
  static const Color darkPrimary = darkGold;
  static const Color darkOnPrimary = Color(0xFF141210);
  static const Color darkPrimaryContainer = Color(0xFF28231E);
  static const Color darkOnPrimaryContainer = Color(0xFFF1EDE1);
  static const Color darkOutline = Color(0xFF38312B);
  static const Color darkOutlineVariant = Color(0xFF2A241F);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);

  // Semantic & Verification Accents
  static const Color lightOnSurface = lightText;
  static const Color darkOnSurface = darkText;
  static const Color lightCritical = lightError;
  static const Color darkCritical = darkError;
  static const Color lightVerified = Color(0xFF1B6A34);
  static const Color darkVerified = Color(0xFF4ADE80);

  // Brand Accents
  static const Color calloutAccentLight = warmBronze;
  static const Color calloutAccentDark = darkGold;

  static ColorScheme get lightScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightSecondaryText,
        onSecondary: lightSurface,
        secondaryContainer: lightSurfaceVariant,
        onSecondaryContainer: lightText,
        surface: lightSurface,
        onSurface: lightText,
        surfaceContainerHighest: lightSurfaceElevated,
        onSurfaceVariant: lightSecondaryText,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
        error: lightError,
        onError: lightOnError,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightError,
      );

  static ColorScheme get darkScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondaryText,
        onSecondary: darkBackground,
        secondaryContainer: darkSurfaceVariant,
        onSecondaryContainer: darkText,
        surface: darkSurface,
        onSurface: darkText,
        surfaceContainerHighest: darkSurfaceElevated,
        onSurfaceVariant: darkSecondaryText,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
        error: darkError,
        onError: darkOnError,
        errorContainer: darkErrorContainer,
        onErrorContainer: darkError,
      );

  /// Calculates relative luminance for WCAG contrast ratio checks
  static double relativeLuminance(Color color) {
    double transform(double c) {
      return (c <= 0.03928)
          ? c / 12.92
          : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = transform(color.r);
    final g = transform(color.g);
    final b = transform(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates WCAG 2.1 contrast ratio between two colors (e.g. 4.5:1, 3:1)
  static double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }
}
