import 'package:flutter/material.dart';
import '../../domain/models/user_quota.dart';
import '../../domain/repositories/auth_repository.dart';
import '../theme/app_colors.dart';

class ProfileQuotaPill extends StatelessWidget {
  final AuthUser? user;
  final UserQuota? quota;
  final bool isBangla;
  final VoidCallback onNewConversation;
  final VoidCallback onSignOut;
  final VoidCallback? onSignIn;
  final VoidCallback? onSettings;
  final VoidCallback? onSavedConversations;

  const ProfileQuotaPill({
    super.key,
    required this.user,
    required this.quota,
    required this.isBangla,
    required this.onNewConversation,
    required this.onSignOut,
    this.onSavedConversations,
    this.onSignIn,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bronzeColor =
        isDark ? const Color(0xFFD8AE6A) : const Color(0xFF8C6735);

    final remaining = quota?.remaining ?? 30;
    final dailyLimit = quota?.dailyLimit ?? 30;
    final Color quotaColor = remaining == 0
        ? (isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626))
        : remaining <= 5
            ? const Color(0xFFF59E0B)
            : bronzeColor;

    return PopupMenuButton<String>(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 320),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? AppColors.darkOutlineVariant
              : AppColors.lightOutlineVariant,
        ),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      tooltip: isBangla ? 'প্রোফাইল ও অ্যাকাউন্ট' : 'Profile & Account',
      onSelected: (val) {
        if (val == 'new') onNewConversation();
        if (val == 'saved') onSavedConversations?.call();
        if (val == 'settings') onSettings?.call();
        if (val == 'signout') onSignOut();
        if (val == 'signin') onSignIn?.call();
      },
      itemBuilder: (ctx) => [
        // User Profile Card & Quota Details
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: bronzeColor,
                    child: user != null
                        ? Text(
                            user?.displayName?.characters.firstOrNull ??
                                user?.email?.characters.firstOrNull ??
                                'U',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ??
                              (user != null
                                  ? (user?.email?.split('@').first ?? 'Citizen')
                                  : (isBangla
                                      ? 'অতিথি নাগরিক'
                                      : 'Guest Citizen')),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ??
                              (isBangla ? 'লগইন করা নেই' : 'Not signed in'),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF28231E)
                      : const Color(0xFFF2ECE1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF38312B)
                        : const Color(0xFFE5DFD3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBangla ? 'দৈনিক আইনি কোটা' : 'Daily Legal Quota',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: bronzeColor,
                          ),
                        ),
                        Text(
                          '$remaining/$dailyLimit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: quotaColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (remaining / dailyLimit).clamp(0.0, 1.0),
                        backgroundColor:
                            isDark ? Colors.white12 : Colors.black12,
                        color: quotaColor,
                        minHeight: 4.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'new',
          child: Row(
            children: [
              Icon(Icons.add_comment_outlined, size: 17, color: bronzeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'নতুন অনুসন্ধান শুরু করুন' : 'Start New Search',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'saved',
          child: Row(
            children: [
              Icon(Icons.forum_outlined, size: 17, color: bronzeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'সংরক্ষিত কথোপকথন' : 'Saved Conversations',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.tune_rounded, size: 17, color: bronzeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'আইনি সেটিংস ও থিম' : 'Settings & Theme',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (user != null)
          PopupMenuItem(
            value: 'signout',
            child: Row(
              children: [
                const Icon(Icons.logout_rounded,
                    size: 17, color: AppColors.lightError),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBangla ? 'সাইন আউট' : 'Sign Out',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightError),
                  ),
                ),
              ],
            ),
          )
        else
          PopupMenuItem(
            value: 'signin',
            child: Row(
              children: [
                Icon(Icons.login_rounded, size: 17, color: bronzeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBangla ? 'সাইন ইন করুন' : 'Sign In',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: bronzeColor),
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF26201B) : const Color(0xFFF2ECE1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: quotaColor.withOpacity(0.45),
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: quotaColor,
              child: user != null
                  ? Text(
                      user?.displayName?.characters.firstOrNull ??
                          user?.email?.characters.firstOrNull ??
                          'U',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 13,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 5),
            Text(
              '$remaining',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: quotaColor,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: quotaColor,
            ),
          ],
        ),
      ),
    );
  }
}
