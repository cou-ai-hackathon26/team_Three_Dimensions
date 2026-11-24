import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/answer_response.dart';

class DraftOfferCard extends StatelessWidget {
  final DraftOffer offer;
  final bool isBangla;
  final VoidCallback onPrepare;

  const DraftOfferCard({
    super.key,
    required this.offer,
    required this.isBangla,
    required this.onPrepare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkPrimary.withOpacity(0.4)
              : AppColors.lightPrimary.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          .withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 20,
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  offer.documentTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            offer.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_document, size: 16),
              label: Text(isBangla
                  ? 'খসড়া তৈরি ও যাচাই করুন'
                  : 'Prepare & Review Draft'),
              onPressed: onPrepare,
            ),
          ),
        ],
      ),
    );
  }
}
