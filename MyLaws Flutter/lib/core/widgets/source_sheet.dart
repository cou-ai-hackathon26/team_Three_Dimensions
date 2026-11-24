import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/source_record.dart';
import '../data/legal_provisions_catalog.dart';
import '../theme/app_colors.dart';

/// Authoritative Legal Provision Modal matching the official website SourceDrawer.
class SourceSheet extends StatelessWidget {
  final String sourceId;
  final SourceRecord? sourceRecord;
  final bool isBangla;
  final bool isDialog;

  const SourceSheet({
    super.key,
    required this.sourceId,
    this.sourceRecord,
    required this.isBangla,
    this.isDialog = false,
  });

  /// Intelligently displays the verified provision modal:
  /// - Centered responsive Dialog on desktop / tablet / web (> 600px)
  /// - Drag-friendly rounded BottomSheet on mobile devices
  static void show(
    BuildContext context, {
    String? sourceId,
    SourceRecord? sourceRecord,
    bool isBangla = true,
  }) {
    final effectiveId = sourceRecord?.id ?? sourceId ?? 'sample-provision-1';
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 760),
            child: SourceSheet(
              sourceId: effectiveId,
              sourceRecord: sourceRecord,
              isBangla: isBangla,
              isDialog: true,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SourceSheet(
            sourceId: effectiveId,
            sourceRecord: sourceRecord,
            isBangla: isBangla,
            isDialog: false,
          ),
        ),
      );
    }
  }

  Future<void> _openOfficialLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = sourceRecord ?? LegalProvisionsCatalog.getById(sourceId);

    // Color tokens matching the web SourceDrawer & AppTheme
    final surfaceColor =
        isDark ? const Color(0xFF1E1A17) : const Color(0xFFFCF9F3);
    final cardBorder =
        isDark ? const Color(0xFF38312B) : const Color(0xFFE2DDD1);
    final bronzeColor =
        isDark ? const Color(0xFFE2B872) : const Color(0xFF9A6F32);
    final textColor =
        isDark ? const Color(0xFFF7F5F0) : const Color(0xFF161512);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0A89C) : const Color(0xFF564E43);

    final actName = r?.getActName(isBangla) ??
        LegalProvisionsCatalog.resolveActName(sourceId, isBangla);
    final sectionStr = r?.getSection(isBangla) ??
        LegalProvisionsCatalog.resolveSectionNumber(sourceId, isBangla);
    final titleStr = r?.getTitle(isBangla) ?? actName;
    final plainExp = r?.getPlainExplanation(isBangla) ?? '';
    final cautionStr = r?.getCaution(isBangla) ?? '';
    final origText = r?.originalText.trim() ?? '';
    final officialUrl = r?.officialUrl ?? 'https://bdlaws.minlaw.gov.bd';
    final checkedDate = r?.verifiedDate ?? '2026-11-01';

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: isDialog
            ? BorderRadius.circular(20)
            : const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar with Shield Icon, Verified Title, and Close Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF26201B)
                  : const Color(0xFFF5EFE3).withOpacity(0.65),
              border: Border(
                  bottom: BorderSide(color: cardBorder.withOpacity(0.7))),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 20,
                  color: bronzeColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBangla
                        ? 'যাচাইকৃত মূল আইনি বিধান'
                        : 'Verified Legal Provision',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 20, color: secondaryTextColor),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),

          // Scrollable Body using ListView
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              children: [
                // Eyebrow Instrument Name
                Text(
                  actName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: bronzeColor,
                  ),
                ),
                const SizedBox(height: 4),

                // Section Title Heading (matches provisionPath / section + title)
                Text(
                  (r != null && r.provisionPath.isNotEmpty)
                      ? r.provisionPath
                      : (titleStr.contains(sectionStr)
                          ? titleStr
                          : '$sectionStr — $titleStr'),
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 14),

                // Status Badges (In Force & Machine Verified)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        isBangla ? 'কার্যকর আইন' : 'In Force',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkOutline
                              : AppColors.lightOutlineVariant,
                        ),
                      ),
                      child: Text(
                        isBangla ? 'মেশিন-যাচাইকৃত' : 'Machine-checked',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Verbatim Excerpt Card (with 4px golden left border and ClipRRect)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF231E18)
                          : const Color(0xFFFAF7F0),
                      border: Border(
                        left: BorderSide(color: bronzeColor, width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBangla
                              ? 'সরকারি গেজেট/পোর্টাল থেকে মূল উদ্ধৃতি (Verbatim Excerpt):'
                              : 'VERBATIM EXCERPT FROM OFFICIAL PORTAL:',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: bronzeColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          origText.startsWith('“') ? origText : '“$origText”',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Plain Language Explanation Section
                if (plainExp.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    isBangla
                        ? 'সহজ ভাষার বিশ্লেষণ:'
                        : 'Plain Language Explanation:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plainExp,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: secondaryTextColor,
                    ),
                  ),
                ],

                // Legal Boundary & Caution Card
                if (cautionStr.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: bronzeColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: bronzeColor.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 17,
                          color: bronzeColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBangla
                                    ? 'আইনি সীমাবদ্ধতা ও সতর্কতা:'
                                    : 'Legal Boundary & Caveat:',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                cautionStr,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.48,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Divider(color: cardBorder.withOpacity(0.65), height: 1),
                const SizedBox(height: 14),

                // Verification Date & Portal External Link
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13.5,
                          color: bronzeColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isBangla
                              ? 'সরকারি পোর্টাল দেখার তারিখ: $checkedDate'
                              : 'Source consulted: $checkedDate',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        side: BorderSide(color: bronzeColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.open_in_new_rounded,
                          size: 13, color: bronzeColor),
                      label: Text(
                        isBangla
                            ? 'সরকারি BDLaws পোর্টালে সম্পূর্ণ আইনটি দেখুন'
                            : 'View on official BDLaws portal ↗',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: bronzeColor,
                        ),
                      ),
                      onPressed: () => _openOfficialLink(officialUrl),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
