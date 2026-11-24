import 'package:flutter/material.dart';
import '../../domain/repositories/settings_repository.dart';
import '../theme/theme_extension.dart';

class ThemeModeToggle extends StatelessWidget {
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;
  final bool isBangla;

  const ThemeModeToggle({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    this.isBangla = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;

    final tooltip = isDark
        ? (isBangla ? 'লাইট মোড চালু করুন' : 'Switch to Light mode')
        : (isBangla ? 'ডার্ক মোড চালু করুন' : 'Switch to Dark mode');

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          final nextMode = isDark ? AppThemeMode.light : AppThemeMode.dark;
          onThemeChanged(nextMode);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: ext.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(
              color: ext.outlineVariant,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 19,
            color: isDark ? ext.calloutAccent : ext.onSurface,
          ),
        ),
      ),
    );
  }
}
