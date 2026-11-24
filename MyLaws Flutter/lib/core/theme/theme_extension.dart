import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color calloutAccent;
  final Color parchmentTint;
  final Color userBubble;
  final Color assistantBubble;
  final Color borderSubtle;

  // Semantic & Surface Colors
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color critical;
  final Color onPrimary;
  final Color secondary;
  final Color outlineVariant;
  final Color surfaceContainerHigh;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerLowest;
  final Color verified;

  const AppThemeExtension({
    required this.calloutAccent,
    required this.parchmentTint,
    required this.userBubble,
    required this.assistantBubble,
    required this.borderSubtle,
    this.surface = AppColors.lightSurface,
    this.onSurface = AppColors.lightText,
    this.onSurfaceVariant = AppColors.lightSecondaryText,
    this.critical = AppColors.lightError,
    this.onPrimary = AppColors.lightOnPrimary,
    this.secondary = AppColors.lightSecondaryText,
    this.outlineVariant = AppColors.lightOutlineVariant,
    this.surfaceContainerHigh = AppColors.lightSurfaceVariant,
    this.surfaceContainerLow = AppColors.lightBackground,
    this.surfaceContainer = AppColors.lightSurfaceVariant,
    this.surfaceContainerLowest = AppColors.lightSurface,
    this.verified = AppColors.lightVerified,
  });

  Color get primary => calloutAccent;

  @override
  AppThemeExtension copyWith({
    Color? calloutAccent,
    Color? parchmentTint,
    Color? userBubble,
    Color? assistantBubble,
    Color? borderSubtle,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? critical,
    Color? onPrimary,
    Color? secondary,
    Color? outlineVariant,
    Color? surfaceContainerHigh,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerLowest,
    Color? verified,
  }) {
    return AppThemeExtension(
      calloutAccent: calloutAccent ?? this.calloutAccent,
      parchmentTint: parchmentTint ?? this.parchmentTint,
      userBubble: userBubble ?? this.userBubble,
      assistantBubble: assistantBubble ?? this.assistantBubble,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      critical: critical ?? this.critical,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      verified: verified ?? this.verified,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      calloutAccent: Color.lerp(calloutAccent, other.calloutAccent, t)!,
      parchmentTint: Color.lerp(parchmentTint, other.parchmentTint, t)!,
      userBubble: Color.lerp(userBubble, other.userBubble, t)!,
      assistantBubble: Color.lerp(assistantBubble, other.assistantBubble, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerLowest:
          Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
    );
  }
}

extension AppThemeBuildContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>() ??
      const AppThemeExtension(
        calloutAccent: AppColors.calloutAccentLight,
        parchmentTint: AppColors.lightPrimaryContainer,
        userBubble: AppColors.lightPrimaryContainer,
        assistantBubble: AppColors.lightSurfaceVariant,
        borderSubtle: AppColors.lightOutlineVariant,
      );
}
