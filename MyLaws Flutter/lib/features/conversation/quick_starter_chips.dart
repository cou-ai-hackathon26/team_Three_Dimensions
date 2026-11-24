import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/scale_on_press.dart';

class QuickStarterChipData {
  final String labelBn;
  final String labelEn;
  final String textBn;
  final String textEn;
  final IconData icon;

  const QuickStarterChipData({
    required this.labelBn,
    required this.labelEn,
    required this.textBn,
    required this.textEn,
    required this.icon,
  });
}

class QuickStarterChips extends StatelessWidget {
  final bool isBangla;
  final ValueChanged<String> onSelected;

  const QuickStarterChips({
    super.key,
    required this.isBangla,
    required this.onSelected,
  });

  static const List<QuickStarterChipData> starters = [
    QuickStarterChipData(
      labelBn: 'বেতন বকেয়া থাকলে করণীয়',
      labelEn: 'Unpaid Wages Advice',
      textBn:
          'কোম্পানি আমার ৩ মাসের বেতন আটকে রেখেছে, দিচ্ছে না। এখন আমি কীভাবে এই টাকা উদ্ধার করতে পারি?',
      textEn:
          'My employer has not paid my salary for 3 months. What legal steps can I take under the Labour Act?',
      icon: Icons.work_outline,
    ),
    QuickStarterChipData(
      labelBn: 'অনলাইন শপিংয়ে প্রতারণা',
      labelEn: 'Online Shopping Fraud',
      textBn:
          'অনলাইনে অর্ডার করে খারাপ পণ্য পেয়েছি, সেলার টাকা ফেরত দিচ্ছে না। কীভাবে অভিযোগ করব?',
      textEn:
          'I received a defective product from an online seller who refuses a refund. How can I file a DNCRP consumer complaint?',
      icon: Icons.shopping_bag_outlined,
    ),
    QuickStarterChipData(
      labelBn: 'হুমকি পেলে জিডি করা',
      labelEn: 'How to File a GD',
      textBn:
          'ফোনে বা সামনাসামনি আমাকে হুমকি দেওয়া হচ্ছে। নিরাপত্তার জন্য থানায় কীভাবে জিডি করব?',
      textEn:
          'I am receiving threats over the phone. How do I file a General Diary (GD) with the local police station?',
      icon: Icons.local_police_outlined,
    ),
    QuickStarterChipData(
      labelBn: 'জমি দখল বা বিরোধ',
      labelEn: 'Land Dispute Help',
      textBn:
          'আমার জমিতে জোর করে দখল নেওয়ার চেষ্টা করছে। এই পরিস্থিতিতে আইনের কী সাহায্য পাব?',
      textEn:
          'Someone is unlawfully trying to claim possession of my registered land. What protection does the law provide?',
      icon: Icons.home_work_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: starters.map((starter) {
            final label = isBangla ? starter.labelBn : starter.labelEn;
            final insertText = isBangla ? starter.textBn : starter.textEn;

            final bronzeColor =
                isDark ? AppColors.darkGold : AppColors.warmBronze;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ScaleOnPress(
                pressedScale: 0.96,
                child: ActionChip(
                  avatar: Icon(
                    starter.icon,
                    size: 16,
                    color: bronzeColor,
                  ),
                  label: Text(
                    '[ $label ]',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  backgroundColor:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  side: BorderSide(
                    color: bronzeColor.withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Bracketed corner styling
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Inserts text into composer; NEVER auto-sends per Section 6 S4
                    onSelected(insertText);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
