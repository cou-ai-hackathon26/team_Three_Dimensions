import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class UserBubble extends StatelessWidget {
  final String text;

  const UserBubble({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkPrimaryContainer
              : AppColors.lightPrimaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(
            color: isDark
                ? AppColors.darkPrimary.withOpacity(0.3)
                : AppColors.lightPrimary.withOpacity(0.3),
            width: 0.8,
          ),
        ),
        child: SelectableText(
          text,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
    );
  }
}
