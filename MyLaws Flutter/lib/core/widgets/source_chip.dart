import 'package:flutter/material.dart';
import '../../domain/models/source_record.dart';
import '../data/legal_provisions_catalog.dart';
import '../theme/app_colors.dart';
import 'source_sheet.dart';

/// Official statutory source pill / chip.
/// In default mode, renders as a capsule pill identical to the website:
/// [ Act Name (Clause/Section) → ]
class SourceChip extends StatelessWidget {
  final String sourceId;
  final SourceRecord? sourceRecord;
  final bool isBangla;
  final String? actName;
  final String? sectionNumber;
  final bool showVerifiedSeal;
  final VoidCallback? onTap;

  const SourceChip({
    super.key,
    required this.sourceId,
    this.sourceRecord,
    required this.isBangla,
    this.actName,
    this.sectionNumber,
    this.showVerifiedSeal = false,
    this.onTap,
  });

  static String resolveActName(String id, SourceRecord? record, bool isBangla) {
    if (record != null) {
      return record.getActName(isBangla);
    }
    return LegalProvisionsCatalog.resolveActName(id, isBangla);
  }

  static String resolveSectionNumber(
      String id, SourceRecord? record, bool isBangla) {
    if (record != null) {
      return record.getSection(isBangla);
    }
    return LegalProvisionsCatalog.resolveSectionNumber(id, isBangla);
  }

  void _openSheet(BuildContext context) {
    SourceSheet.show(
      context,
      sourceId: sourceId,
      sourceRecord: sourceRecord,
      isBangla: isBangla,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bronzeColor =
        isDark ? const Color(0xFFE2B872) : const Color(0xFF9A6F32);

    if (showVerifiedSeal) {
      final act = actName ?? resolveActName(sourceId, sourceRecord, isBangla);
      final sec = sectionNumber ??
          resolveSectionNumber(sourceId, sourceRecord, isBangla);
      final primaryColor =
          isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

      return Semantics(
        button: true,
        label:
            'Statutory Source: $act, $sec. Tap to read statutory text and verify official gazette seal.',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap ?? () => _openSheet(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF26211C) : const Color(0xFFF6F0E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: primaryColor.withOpacity(0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sec,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.darkVerified
                              : AppColors.lightVerified)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isDark
                                ? AppColors.darkVerified
                                : AppColors.lightVerified)
                            .withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.darkVerified
                              : AppColors.lightVerified,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isBangla ? 'গেজেট সিল' : 'Verified Seal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkVerified
                                : AppColors.lightVerified,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: primaryColor.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Default inline statutory capsule pill identical to the website
    final pillLabel = LegalProvisionsCatalog.getSourceLabel(sourceId, isBangla);

    return Semantics(
      button: true,
      label:
          'Legal source: $pillLabel. Tap to read statutory text and verify official provision.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap ?? () => _openSheet(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF382B18).withOpacity(0.4)
                  : const Color(0xFFF4ECE0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: bronzeColor.withOpacity(isDark ? 0.5 : 0.35),
                width: 1.1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    pillLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: bronzeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 11.5,
                  color: bronzeColor.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
