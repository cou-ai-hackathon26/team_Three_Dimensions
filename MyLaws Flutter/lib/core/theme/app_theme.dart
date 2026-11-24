import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'theme_extension.dart';

class AppTheme {
  static const List<String> fontFallbacks = [
    'AnekBangla',
    'Hind',
    'NotoSansBengali',
    'sans-serif',
  ];

  static TextStyle _anek({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    Color? color,
  }) {
    return GoogleFonts.anekBangla(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      textStyle: const TextStyle(fontFamilyFallback: fontFallbacks),
    );
  }

  static TextStyle _hind({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    Color? color,
  }) {
    return GoogleFonts.hindSiliguri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      textStyle: const TextStyle(fontFamilyFallback: fontFallbacks),
    );
  }

  static TextStyle getDisplayStyle({
    required bool isDark,
    required bool isBangla,
  }) {
    return _anek(
      fontSize: isBangla ? 30 : 32,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    );
  }

  static TextStyle getHeadlineStyle({
    required bool isDark,
    required bool isBangla,
  }) {
    return _anek(
      fontSize: isBangla ? 22 : 24,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    );
  }

  static TextStyle getTitleStyle({
    required bool isDark,
    required bool isBangla,
  }) {
    return _anek(
      fontSize: isBangla ? 17 : 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    );
  }

  static TextStyle getBodyLargeStyle({
    required bool isDark,
    required bool isBangla,
  }) {
    return _hind(
      fontSize: isBangla ? 17 : 16,
      fontWeight: FontWeight.w400,
      height:
          1.6, // Adequate line height to prevent vowel sign (matra) collisions
      color: isDark ? AppColors.darkText : AppColors.lightText,
    );
  }

  static TextStyle getBodyMediumStyle({
    required bool isDark,
    required bool isBangla,
  }) {
    return _hind(
      fontSize: isBangla ? 16 : 15,
      fontWeight: FontWeight.w400,
      height: 1.6, // Adequate line height
      color: isDark ? AppColors.darkText : AppColors.lightText,
    );
  }

  static TextStyle getBodySmallStyle({
    required bool isDark,
    required bool isBangla,
  }) {
    return _hind(
      fontSize: isBangla ? 14 : 13,
      fontWeight: FontWeight.w400,
      height: 1.6, // Adequate line height
      color:
          isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
    );
  }

  static TextStyle getLabelStyle({
    required bool isDark,
    required bool isBangla,
  }) {
    return _hind(
      fontSize: isBangla ? 13 : 12,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
    );
  }

  static TextTheme _buildTextTheme(bool isDark) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final secondary =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return TextTheme(
      displayLarge: _anek(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: text,
      ),
      displayMedium: _anek(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: text,
      ),
      displaySmall: _anek(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: text,
      ),
      headlineLarge: _anek(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: text,
      ),
      headlineMedium: _anek(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: text,
      ),
      headlineSmall: _anek(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: text,
      ),
      titleLarge: _anek(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: text,
      ),
      titleMedium: _anek(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: text,
      ),
      titleSmall: _anek(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: text,
      ),
      bodyLarge: _hind(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6, // Matra collision prevention
        color: text,
      ),
      bodyMedium: _hind(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6, // Matra collision prevention
        color: text,
      ),
      bodySmall: _hind(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.6, // Matra collision prevention
        color: secondary,
      ),
      labelLarge: _hind(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: text,
      ),
      labelMedium: _hind(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: secondary,
      ),
      labelSmall: _hind(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: secondary,
      ),
    );
  }

  static ThemeData get lightTheme {
    final scheme = AppColors.lightScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _buildTextTheme(false),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.subtleGridBorder, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        disabledColor: AppColors.lightBackground,
        selectedColor: AppColors.antiqueGold.withValues(alpha: 0.18),
        secondarySelectedColor: AppColors.antiqueGold,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: _hind(
          color: AppColors.lightText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        secondaryLabelStyle: _hind(
          color: AppColors.antiqueGold,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10), // Bracketed corner appearance
          side: const BorderSide(
            color: AppColors.subtleGridBorder,
            width: 1.2,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightSurfaceElevated,
        foregroundColor: AppColors.antiqueGold,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 3,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // Bracketed corner styling
          side: BorderSide(
            color: AppColors.warmBronze.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.subtleGridBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.subtleGridBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.antiqueGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightError, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _hind(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.subtleGridBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      extensions: const [
        AppThemeExtension(
          calloutAccent: AppColors.calloutAccentLight,
          parchmentTint: AppColors.lightSurfaceElevated,
          userBubble: AppColors.lightSurfaceElevated,
          assistantBubble: AppColors.lightSurface,
          borderSubtle: AppColors.subtleGridBorder,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightText,
          onSurfaceVariant: AppColors.lightSecondaryText,
          critical: AppColors.lightError,
          onPrimary: AppColors.lightOnPrimary,
          secondary: AppColors.lightSecondaryText,
          outlineVariant: AppColors.subtleGridBorder,
          surfaceContainerHigh: AppColors.lightSurfaceElevated,
          surfaceContainerLow: AppColors.lightBackground,
          surfaceContainer: AppColors.lightSurface,
          surfaceContainerLowest: AppColors.lightSurface,
          verified: AppColors.lightVerified,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    final scheme = AppColors.darkScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(true),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.darkOutline, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        disabledColor: AppColors.darkBackground,
        selectedColor: AppColors.darkGold.withValues(alpha: 0.18),
        secondarySelectedColor: AppColors.darkGold,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: _hind(
          color: AppColors.darkText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        secondaryLabelStyle: _hind(
          color: AppColors.darkGold,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10), // Bracketed corner appearance
          side: const BorderSide(
            color: AppColors.darkOutline,
            width: 1.2,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        foregroundColor: AppColors.darkGold,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 3,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // Bracketed corner styling
          side: BorderSide(
            color: AppColors.darkGold.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.darkOutline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.darkOutline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkError, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _hind(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.darkOutline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      extensions: const [
        AppThemeExtension(
          calloutAccent: AppColors.calloutAccentDark,
          parchmentTint: AppColors.darkSurfaceElevated,
          userBubble: AppColors.darkSurfaceElevated,
          assistantBubble: AppColors.darkSurface,
          borderSubtle: AppColors.darkOutline,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          onSurfaceVariant: AppColors.darkSecondaryText,
          critical: AppColors.darkError,
          onPrimary: AppColors.darkOnPrimary,
          secondary: AppColors.darkSecondaryText,
          outlineVariant: AppColors.darkOutlineVariant,
          surfaceContainerHigh: AppColors.darkSurfaceElevated,
          surfaceContainerLow: AppColors.darkBackground,
          surfaceContainer: AppColors.darkSurface,
          surfaceContainerLowest: AppColors.darkBackground,
          verified: AppColors.darkVerified,
        ),
      ],
    );
  }
}
