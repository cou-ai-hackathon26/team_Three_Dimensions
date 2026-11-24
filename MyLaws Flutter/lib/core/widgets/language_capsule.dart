import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LanguageCapsule extends StatelessWidget {
  final String currentLocale;
  final ValueChanged<String> onLocaleChanged;

  const LanguageCapsule({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = currentLocale == 'bn';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // When in Bangla, button prompts to switch to "English".
    // When in English, button prompts to switch to "বাংলা".
    final targetLabel = isBangla ? 'English' : 'বাংলা';
    final tooltip =
        isBangla ? 'Switch language to English' : 'ভাষা পরিবর্তন করুন: বাংলা';

    return Semantics(
      label: tooltip,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            onLocaleChanged(isBangla ? 'en' : 'bn');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isDark ? const Color(0xFF2C3540) : const Color(0xFFE2DDD2),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(20),
              color: isDark ? const Color(0xFF1E232A) : const Color(0xFFF3EFE6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 15,
                  color:
                      isDark ? const Color(0xFFD4A853) : AppColors.lightPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  targetLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFEDE8DE)
                        : const Color(0xFF1A1D20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
