import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SupersededBanner extends StatefulWidget {
  final Widget child;
  final bool isBangla;

  const SupersededBanner({
    super.key,
    required this.child,
    required this.isBangla,
  });

  @override
  State<SupersededBanner> createState() => _SupersededBannerState();
}

class _SupersededBannerState extends State<SupersededBanner> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withOpacity(0.5)
            : AppColors.lightSurfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineVariant
              : AppColors.lightOutlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isBangla
                          ? 'আপনার সংশোধনের কারণে এই উত্তর আপডেট হয়েছে'
                          : 'Updated after your correction',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                  Text(
                    _isExpanded
                        ? (widget.isBangla ? 'লুকান' : 'Hide')
                        : (widget.isBangla
                            ? 'পূর্ববর্তী দিকনির্দেশনা দেখুন'
                            : 'Show previous'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color:
                        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Opacity(
              opacity: 0.75,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: widget.child,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
