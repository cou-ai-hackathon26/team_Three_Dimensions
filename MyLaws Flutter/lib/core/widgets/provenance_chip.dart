import 'package:flutter/material.dart';
import '../../domain/models/answer_response.dart';
import '../theme/app_colors.dart';

class ProvenanceChip extends StatelessWidget {
  final ProcessingEngine provenance;
  final String sourcePackVersion;
  final bool isBangla;

  const ProvenanceChip({
    super.key,
    required this.provenance,
    required this.sourcePackVersion,
    required this.isBangla,
  });

  void _showProvenanceDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBangla
                          ? 'উত্তর কীভাবে প্রস্তুত হয়েছে'
                          : 'How this answer was produced',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _explanationText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 16,
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText),
                      const SizedBox(width: 8),
                      Text(
                        isBangla
                            ? 'আইন ভাণ্ডার সংস্করণ: $sourcePackVersion'
                            : 'Corpus version: $sourcePackVersion',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(isBangla ? 'বুঝেছি' : 'Understood'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String get _explanationText {
    switch (provenance) {
      case ProcessingEngine.onlineMeta:
        return isBangla
            ? 'এই উত্তরটি অফিসিয়াল আইনের ধারা যাচাই করার পর Meta AI মডেলের সহায়তায় সহজ ভাষায় গুছিয়ে দেওয়া হয়েছে। এটি আদালতের কোনো রায় বা আইনজীবীর পরামর্শ নয়।'
            : 'This answer was prepared by grounding statutory provisions with the Meta AI model in plain language. It is not a court ruling or legal counsel.';
      case ProcessingEngine.onlineGuidedFallback:
        return isBangla
            ? 'এই উত্তরটি সার্ভারে সংরক্ষিত যাচাইকৃত আইনি নির্দেশিকা এবং পূর্বনির্ধারিত যুক্তিকাঠামোর সাহায্যে তৈরি করা হয়েছে।'
            : 'This answer was produced by server-side deterministic legal workflow and verified statutory mapping.';
      case ProcessingEngine.offlineModel:
        return isBangla
            ? 'এই উত্তরটি আপনার ফোনের নিজস্ব মেমোরিতে থাকা এআই মডেল দিয়ে সম্পূর্ণ অফলাইনে তৈরি করা হয়েছে।'
            : 'This answer was generated entirely offline using the compact on-device model.';
      case ProcessingEngine.offlineGuided:
        return isBangla
            ? 'এই উত্তরটি কোনো ইন্টারনেট সংযোগ ছাড়াই ফোনে ইনস্টল করা আইনের ভাণ্ডার থেকে মিলিয়ে দেখানো হয়েছে।'
            : 'This answer was retrieved directly from the offline legal pack installed on your device without any network connection.';
      case ProcessingEngine.demoFixture:
        return isBangla
            ? 'এটি একটি ডেমো/নমুনা উত্তর যা প্রিভিউ ও পরীক্ষার জন্য সংরক্ষিত কৃত্রিম তথ্য দিয়ে তৈরি।'
            : 'This is a synthetic sample fixture for development and interface preview purposes only.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = isBangla ? provenance.labelBn : provenance.labelEn;

    return Semantics(
      button: true,
      label: 'Provenance: $label. Tap to learn how this answer was produced.',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProvenanceDetails(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColors.darkOutlineVariant
                  : AppColors.lightOutlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint,
                size: 13,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
