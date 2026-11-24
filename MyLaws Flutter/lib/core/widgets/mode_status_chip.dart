import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppOperationalMode {
  online,
  offlineInstalled,
  offlineUnavailable,
  sampleMode,
}

class ModeStatusChip extends StatelessWidget {
  final AppOperationalMode mode;
  final bool isBangla;
  final VoidCallback? onTap;

  const ModeStatusChip({
    super.key,
    required this.mode,
    required this.isBangla,
    this.onTap,
  });

  String get _label {
    switch (mode) {
      case AppOperationalMode.online:
        return isBangla ? 'অনলাইন সহকারী' : 'Online Assistant';
      case AppOperationalMode.offlineInstalled:
        return isBangla
            ? 'অফলাইন: আইন ভাণ্ডার সক্রিয়'
            : 'Offline: Law Pack Installed';
      case AppOperationalMode.offlineUnavailable:
        return isBangla
            ? 'অফলাইন: আইন ভাণ্ডার প্রয়োজন'
            : 'Offline: Install Law Pack';
      case AppOperationalMode.sampleMode:
        return isBangla ? 'নমুনা মোড (Dev)' : 'Sample Mode (Dev)';
    }
  }

  IconData get _icon {
    switch (mode) {
      case AppOperationalMode.online:
        return Icons.cloud_done_outlined;
      case AppOperationalMode.offlineInstalled:
        return Icons.offline_pin_outlined;
      case AppOperationalMode.offlineUnavailable:
        return Icons.cloud_off_outlined;
      case AppOperationalMode.sampleMode:
        return Icons.science_outlined;
    }
  }

  Color _badgeColor(bool isDark) {
    switch (mode) {
      case AppOperationalMode.online:
        return isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      case AppOperationalMode.offlineInstalled:
        return isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
      case AppOperationalMode.offlineUnavailable:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFEF6C00);
      case AppOperationalMode.sampleMode:
        return isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _badgeColor(isDark);

    return Semantics(
      label: 'System mode: $_label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.35), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
