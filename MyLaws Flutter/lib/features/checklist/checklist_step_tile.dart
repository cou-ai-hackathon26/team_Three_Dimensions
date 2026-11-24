import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/legal_translation_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/scale_on_press.dart';
import '../../domain/models/checklist_step.dart';

class ChecklistStepTile extends StatelessWidget {
  final ChecklistStep step;
  final bool isBangla;
  final ValueChanged<bool> onToggle;
  final int? stepNumber;
  final VoidCallback? onDraft;
  final String? draftLabel;

  const ChecklistStepTile({
    super.key,
    required this.step,
    required this.isBangla,
    required this.onToggle,
    this.stepNumber,
    this.onDraft,
    this.draftLabel,
  });

  /// Standard numerals (0–9) are always used per typography guidelines.
  static String toBanglaDigit(int num) => '$num';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const goldAccent = Color(0xFF9A6F32);
    final lightBorder =
        isDark ? AppColors.darkOutlineVariant : AppColors.lightOutlineVariant;

    final rawTitle = isBangla
        ? step.titleBn
        : ((step.titleEn != step.text && step.titleEn.isNotEmpty)
            ? step.titleEn
            : LegalTranslationService.translate(step.text, toBangla: false));

    final displayTitle =
        LegalTranslationService.normalizeStandardDigits(rawTitle);

    return ScaleOnPress(
      pressedScale: 0.985,
      duration: const Duration(milliseconds: 120),
      child: Semantics(
        checked: step.completed,
        button: true,
        label: '$displayTitle, ${step.completed ? "completed" : "incomplete"}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              onToggle(!step.completed);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: step.completed
                    ? (isDark
                        ? const Color(0xFF2B251D)
                        : const Color(0xFFF9F5EC))
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: step.completed
                      ? goldAccent.withOpacity(0.55)
                      : (step.needsRecheck
                          ? (isDark
                              ? const Color(0xFFFFB74D)
                              : const Color(0xFFEF6C00))
                          : lightBorder),
                  width: step.completed ? 1.4 : (step.needsRecheck ? 1.5 : 1),
                ),
                boxShadow: step.completed
                    ? [
                        BoxShadow(
                          color: goldAccent.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular step index badge (standard numerals 1, 2, 3...)
                      if (stepNumber != null) ...[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: step.completed
                                ? goldAccent.withOpacity(0.2)
                                : goldAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: step.completed
                                  ? goldAccent
                                  : goldAccent.withOpacity(0.35),
                              width: 1.1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$stepNumber',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: goldAccent,
                            ),
                          ),
                        ),
                      ],
                      // Animated Checkbox Micro-Interaction
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color:
                              step.completed ? goldAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: step.completed
                                ? goldAccent
                                : (isDark
                                    ? AppColors.darkOutline
                                    : AppColors.subtleGridBorder),
                            width: 1.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: AnimatedScale(
                          scale: step.completed ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: AnimatedOpacity(
                            opacity: step.completed ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 180),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Step Title with Strikethrough & High Contrast
                      Expanded(
                        child: Text(
                          displayTitle,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            decoration: step.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: step.completed
                                ? (isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText)
                                : (isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText),
                            fontWeight: step.completed
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (step.needsRecheck) ...[
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? const Color(0xFFFFB74D)
                                    : const Color(0xFFEF6C00))
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBangla ? 'যাচাই প্রয়োজন' : 'Recheck',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFFFB74D)
                                  : const Color(0xFFEF6C00),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (step.requiredDocuments.isNotEmpty ||
                      step.helpfulEvidence.isNotEmpty) ...[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 56, top: 4, bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (step.requiredDocuments.isNotEmpty) ...[
                            Text(
                              isBangla
                                  ? 'প্রয়োজনীয় কাগজপত্র:'
                                  : 'Required Documents:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                              ),
                            ),
                            ...step.requiredDocuments.map(
                              (d) => Text('• $d',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightSecondaryText)),
                            ),
                          ],
                          if (step.helpfulEvidence.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              isBangla
                                  ? 'সহায়ক প্রমাণাদি:'
                                  : 'Helpful Evidence:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                              ),
                            ),
                            ...step.helpfulEvidence.map(
                              (e) => Text('• $e',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightSecondaryText)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  // Optional Contextual Draft Button right inside the checklist tile
                  if (onDraft != null) ...[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 56, top: 4, bottom: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            onDraft!();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: goldAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: goldAccent.withOpacity(0.45),
                                width: 1.1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_document,
                                    size: 13, color: goldAccent),
                                const SizedBox(width: 5),
                                Text(
                                  draftLabel ??
                                      (isBangla
                                          ? 'এই বিষয়ে খসড়া তৈরি করুন'
                                          : 'Prepare Draft for this'),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: goldAccent,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 10, color: goldAccent),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
