import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BannerType {
  error,
  quota,
  offline,
  info,
}

class StateBanner extends StatelessWidget {
  final BannerType type;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const StateBanner({
    super.key,
    required this.type,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bg, Color textCol, IconData icon) = switch (type) {
      BannerType.error => (
          isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFDE8E8),
          isDark ? AppColors.darkError : AppColors.lightError,
          Icons.error_outline,
        ),
      BannerType.quota => (
          isDark ? const Color(0xFF332717) : const Color(0xFFFFF4E5),
          isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
          Icons.hourglass_empty,
        ),
      BannerType.offline => (
          isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
          Icons.wifi_off_outlined,
        ),
      BannerType.info => (
          isDark
              ? AppColors.darkPrimaryContainer
              : AppColors.lightPrimaryContainer,
          isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          Icons.info_outline,
        ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textCol.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textCol),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textCol,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: textCol,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: const Size(48, 36),
              ),
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
