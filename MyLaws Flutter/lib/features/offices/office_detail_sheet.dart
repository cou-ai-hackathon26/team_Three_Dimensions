import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/office_record.dart';
import '../../core/theme/app_colors.dart';

class OfficeDetailSheet extends StatelessWidget {
  final OfficeRecord office;
  final bool isBangla;

  const OfficeDetailSheet({
    super.key,
    required this.office,
    required this.isBangla,
  });

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    office.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (office.address != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      office.address!,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (office.territory != null) ...[
              Row(
                children: [
                  Icon(Icons.map_outlined,
                      size: 16,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText),
                  const SizedBox(width: 6),
                  Text(
                    isBangla
                        ? 'এখতিয়ার: ${office.territory}'
                        : 'Jurisdiction: ${office.territory}',
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (office.phone != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text(
                      '${isBangla ? "কল করুন" : "Call"} (${office.phone})'),
                  onPressed: () => _callPhone(office.phone!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
