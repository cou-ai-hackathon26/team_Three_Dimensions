import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/draft_document.dart';

class DraftPreviewPage extends StatelessWidget {
  final DraftDocument document;
  final bool isBangla;

  const DraftPreviewPage({
    super.key,
    required this.document,
    required this.isBangla,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // A4 Paper Aspect Ratio: 1:1.414. Rendered with ivory paper styling.
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2429) : const Color(0xFFFCFBF7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
                ? AppColors.darkOutlineVariant
                : AppColors.lightOutlineVariant,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBangla ? 'খসড়া নথি' : 'DRAFT DOCUMENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: document.isReadyToExport
                        ? const Color(0xFF2E7D32).withOpacity(0.12)
                        : (isDark
                                ? const Color(0xFFFFB74D)
                                : const Color(0xFFEF6C00))
                            .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    document.isReadyToExport
                        ? (isBangla ? 'পর্যালোচিত' : 'Reviewed')
                        : (isBangla ? 'অসম্পূর্ণ' : 'Incomplete'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: document.isReadyToExport
                          ? const Color(0xFF2E7D32)
                          : (isDark
                              ? const Color(0xFFFFB74D)
                              : const Color(0xFFEF6C00)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // Document Paragraphs
            ...document.paragraphs.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: _buildParagraphText(p, isDark),
              );
            }),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Legal Footnote
            Text(
              isBangla
                  ? 'এই নথিটি MyLaws অ্যাপের মাধ্যমে প্রস্তুতকৃত একটি আবেদনপত্রের খসড়া। এটি কোনো সরকারি বা আদালতের দাপ্তরিক প্রত্যয়ন নয়।'
                  : 'Prepared via MyLaws as an application draft. Not an official filing or certification.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraphText(String paragraph, bool isDark) {
    // Conspicuous placeholder highlighting: [placeholder] gets underline and warning tint
    final regex = RegExp(r'\[([^\]]+)\]');
    final matches = regex.allMatches(paragraph);

    if (matches.isEmpty) {
      return Text(
        paragraph,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          fontFamily: 'NotoSansBengali',
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      );
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final m in matches) {
      if (m.start > lastIndex) {
        spans.add(TextSpan(text: paragraph.substring(lastIndex, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(0),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
            decorationColor:
                isDark ? const Color(0xFFFFB74D) : const Color(0xFFD84315),
            color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFD84315),
          ),
        ),
      );
      lastIndex = m.end;
    }

    if (lastIndex < paragraph.length) {
      spans.add(TextSpan(text: paragraph.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          fontFamily: 'NotoSansBengali',
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        children: spans,
      ),
    );
  }
}
