import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/clarification_question.dart';

class ClarificationCard extends StatefulWidget {
  final List<ClarificationQuestion> questions;
  final bool isBangla;
  final ValueChanged<String> onAnswerSubmitted;

  const ClarificationCard({
    super.key,
    required this.questions,
    required this.isBangla,
    required this.onAnswerSubmitted,
  });

  @override
  State<ClarificationCard> createState() => _ClarificationCardState();
}

class _ClarificationCardState extends State<ClarificationCard> {
  final Map<String, String> _selectedAnswers = {};
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    for (final q in widget.questions) {
      if (q.answerType == 'text' ||
          q.answerType == 'amount' ||
          q.answerType == 'date') {
        _textControllers[q.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submitChoice(ClarificationQuestion q, String val) {
    widget.onAnswerSubmitted(val);
  }

  void _submitText(ClarificationQuestion q) {
    final text = _textControllers[q.id]?.text.trim() ?? '';
    if (text.isNotEmpty) {
      widget.onAnswerSubmitted(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkPrimary.withOpacity(0.5)
              : AppColors.lightPrimary.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                size: 18,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isBangla
                    ? 'সঠিক নির্দেশনার জন্য স্পষ্ট তথ্য প্রয়োজন'
                    : 'Clarification Needed',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.questions.map((q) {
            final questionText = widget.isBangla ? q.questionBn : q.questionEn;
            final importanceText =
                widget.isBangla ? q.importanceBn : q.importanceEn;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                if (importanceText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.isBangla
                        ? 'কেন জানতে চাইছি: $importanceText'
                        : 'Why we ask: $importanceText',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (q.options.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: q.options.map((opt) {
                      final label = widget.isBangla ? opt.labelBn : opt.labelEn;
                      return ChoiceChip(
                        label: Text(label),
                        selected: _selectedAnswers[q.id] == opt.value,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedAnswers[q.id] = opt.value;
                            });
                            _submitChoice(q, label);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textControllers[q.id],
                          decoration: InputDecoration(
                            hintText: widget.isBangla
                                ? 'এখানে লিখুন...'
                                : 'Enter answer...',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _submitText(q),
                        child: Text(widget.isBangla ? 'জমা' : 'Submit'),
                      ),
                    ],
                  ),
                ],
                if (q.allowUnknown) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => widget.onAnswerSubmitted(
                          widget.isBangla ? 'জানা নেই' : "I don't know",
                        ),
                        child:
                            Text(widget.isBangla ? 'জানা নেই' : "I don't know"),
                      ),
                      TextButton(
                        onPressed: () => widget.onAnswerSubmitted(
                          widget.isBangla ? 'এড়িয়ে যান' : 'Skip',
                        ),
                        child: Text(widget.isBangla ? 'এড়িয়ে যান' : 'Skip'),
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}
