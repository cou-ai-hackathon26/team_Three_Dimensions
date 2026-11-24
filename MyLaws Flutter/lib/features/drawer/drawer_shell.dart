import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extension.dart';

class DrawerShell extends ConsumerWidget {
  final VoidCallback? onNewConversation;
  final VoidCallback? onSavedConversations;
  final VoidCallback? onDrafts;
  final VoidCallback? onLegalSources;
  final VoidCallback? onDownloads;
  final VoidCallback? onSettings;
  final VoidCallback? onAbout;
  final VoidCallback? onSignIn;

  const DrawerShell({
    super.key,
    this.onNewConversation,
    this.onSavedConversations,
    this.onDrafts,
    this.onLegalSources,
    this.onDownloads,
    this.onSettings,
    this.onAbout,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final bronzeColor =
        isDark ? const Color(0xFFD8AE6A) : const Color(0xFF8C6735);
    final settings = ref.watch(settingsProvider);
    final isBangla = settings.appLanguage == 'bn';

    return Drawer(
      backgroundColor: ext.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Official Brand Logo & Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  isDark
                      ? 'assets/images/mylaws_brand_logo_dark.png'
                      : 'assets/images/mylaws_brand_logo_transparent.png',
                  height: 46,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Row(
                    children: [
                      Image.asset(
                        isDark
                            ? 'assets/images/mylaws-symbol-reversed.png'
                            : 'assets/images/mylaws-symbol-transparent.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MyLaws',
                            style: GoogleFonts.anekBangla(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ext.onSurface,
                              textStyle: const TextStyle(
                                  fontFamilyFallback: AppTheme.fontFallbacks),
                            ),
                          ),
                          Text(
                            isBangla
                                ? 'লিগ্যাল অ্যাসিস্ট্যান্ট'
                                : 'Legal Assistant',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: ext.calloutAccent,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              textStyle: const TextStyle(
                                  fontFamilyFallback: AppTheme.fontFallbacks),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: ext.outlineVariant.withValues(alpha: 0.4),
            ),

            // Animated Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                children: [
                  // Prominent Hero Action: Start New Conversation
                  _AnimatedDrawerTile(
                    index: 0,
                    icon: Icons.chat_bubble_outline_rounded,
                    title:
                        isBangla ? 'নতুন আলাপ শুরু করুন' : 'New conversation',
                    isPrimary: true,
                    isBangla: isBangla,
                    onTap: () {
                      Navigator.pop(context);
                      if (onNewConversation != null) {
                        onNewConversation!();
                      } else {
                        ref
                            .read(conversationProvider.notifier)
                            .startNewConversation();
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(height: 6),

                  _AnimatedDrawerTile(
                    index: 1,
                    icon: Icons.forum_outlined,
                    title: isBangla ? 'সংরক্ষিত আলাপ' : 'Saved conversations',
                    isBangla: isBangla,
                    onTap: () {
                      Navigator.pop(context);
                      if (onSavedConversations != null) {
                        onSavedConversations!();
                      } else {
                        context.push('/conversations');
                      }
                    },
                  ),
                  _AnimatedDrawerTile(
                    index: 2,
                    icon: Icons.description_outlined,
                    title: isBangla
                        ? 'আইনি খসড়া ও আবেদন'
                        : 'Legal Drafts & Applications',
                    badge: isBangla ? '১০টি ফরম্যাট' : '10 Formats',
                    isBangla: isBangla,
                    onTap: () {
                      Navigator.pop(context);
                      if (onDrafts != null) {
                        onDrafts!();
                      } else {
                        context.push('/drafts');
                      }
                    },
                  ),
                  _AnimatedDrawerTile(
                    index: 3,
                    icon: Icons.auto_stories_outlined,
                    title: isBangla
                        ? 'আইন ও ধারা সংগ্রহশালা'
                        : 'Statutory sources library',
                    isBangla: isBangla,
                    onTap: () {
                      Navigator.pop(context);
                      if (onLegalSources != null) {
                        onLegalSources!();
                      } else {
                        context.push('/sources');
                      }
                    },
                  ),
                  _AnimatedDrawerTile(
                    index: 4,
                    icon: Icons.download_for_offline_outlined,
                    title: isBangla
                        ? 'ডাউনলোড ও অফলাইন সেন্টার'
                        : 'Downloads & offline center',
                    isBangla: isBangla,
                    onTap: () {
                      Navigator.pop(context);
                      if (onDownloads != null) {
                        onDownloads!();
                      } else {
                        context.push('/downloads');
                      }
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Divider(
                      height: 1,
                      thickness: 0.8,
                      color: ext.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),

                  _AnimatedDrawerTile(
                    index: 5,
                    icon: Icons.tune_rounded,
                    title: isBangla ? 'সেটিংস' : 'Settings',
                    isBangla: isBangla,
                    onTap: () {
                      Navigator.pop(context);
                      if (onSettings != null) {
                        onSettings!();
                      } else {
                        context.push('/settings');
                      }
                    },
                  ),
                  _AnimatedDrawerTile(
                    index: 6,
                    icon: Icons.verified_user_outlined,
                    title: isBangla
                        ? 'অ্যাপ সম্পর্কে ও লাইসেন্স'
                        : 'About & licenses',
                    isBangla: isBangla,
                    onTap: () {
                      Navigator.pop(context);
                      if (onAbout != null) {
                        onAbout!();
                      } else {
                        context.push('/about');
                      }
                    },
                  ),
                ],
              ),
            ),

            // Minimal Legal Protection Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 15,
                    color: bronzeColor.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBangla
                          ? 'MyLaws · নাগরিক আইনি অধিকার সুরক্ষা'
                          : 'MyLaws · Citizen Legal Protection',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11.5,
                        color: ext.onSurfaceVariant.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        textStyle: const TextStyle(
                            fontFamilyFallback: AppTheme.fontFallbacks),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// High-performance animated drawer tile with micro-scale physics,
/// tactile rounded icon container, inline badge alignment, and smooth hover state.
class _AnimatedDrawerTile extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final String? badge;
  final bool isPrimary;
  final bool isBangla;
  final VoidCallback onTap;

  const _AnimatedDrawerTile({
    required this.index,
    required this.icon,
    required this.title,
    this.badge,
    this.isPrimary = false,
    required this.isBangla,
    required this.onTap,
  });

  @override
  State<_AnimatedDrawerTile> createState() => _AnimatedDrawerTileState();
}

class _AnimatedDrawerTileState extends State<_AnimatedDrawerTile> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final bronzeColor =
        isDark ? const Color(0xFFD8AE6A) : const Color(0xFF8C6735);

    // Dynamic background colors
    final Color tileBackground;
    final Border? tileBorder;

    if (widget.isPrimary) {
      tileBackground = isDark
          ? const Color(0xFF2E2419)
          : const Color(0xFFF1EAE0);
      tileBorder = Border.all(
        color: isDark
            ? bronzeColor.withValues(alpha: 0.35)
            : const Color(0xFFE2D6C5),
        width: 1.0,
      );
    } else if (_isHovered) {
      tileBackground = isDark
          ? const Color(0xFF26201B)
          : const Color(0xFFF4EEE5);
      tileBorder = Border.all(
        color: ext.outlineVariant.withValues(alpha: 0.35),
        width: 1.0,
      );
    } else {
      tileBackground = Colors.transparent;
      tileBorder = null;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 180 + widget.index * 25),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(10 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.5),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            child: AnimatedScale(
              scale: _isPressed ? 0.97 : (_isHovered ? 1.008 : 1.0),
              duration: const Duration(milliseconds: 130),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
                decoration: BoxDecoration(
                  color: tileBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: tileBorder,
                ),
                child: Row(
                  children: [
                    // Refined Icon Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: widget.isPrimary
                            ? (isDark
                                ? bronzeColor.withValues(alpha: 0.2)
                                : const Color(0xFFE5DACB))
                            : (isDark
                                ? const Color(0xFF26201B)
                                : const Color(0xFFEFE8DC)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.isPrimary
                              ? bronzeColor.withValues(alpha: 0.45)
                              : (isDark
                                  ? const Color(0xFF38312B)
                                  : const Color(0xFFDDD3C1)),
                          width: 0.8,
                        ),
                        boxShadow: widget.isPrimary || _isHovered
                            ? [
                                BoxShadow(
                                  color: bronzeColor.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1.5),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: widget.isPrimary
                            ? (isDark ? bronzeColor : const Color(0xFF6B4B1B))
                            : (_isHovered ? bronzeColor : ext.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 13),

                    // Title Text with high legibility in Bangla & English
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: widget.isBangla ? 15.0 : 14.5,
                          fontWeight: widget.isPrimary
                              ? FontWeight.w700
                              : (_isHovered
                                  ? FontWeight.w600
                                  : FontWeight.w500),
                          height: 1.25,
                          color: widget.isPrimary
                              ? (isDark
                                  ? const Color(0xFFFFD599)
                                  : const Color(0xFF4A2F08))
                              : ext.onSurface,
                          textStyle: const TextStyle(
                              fontFamilyFallback: AppTheme.fontFallbacks),
                        ),
                      ),
                    ),

                    // Right trailing element: Badge pill or subtle chevron
                    if (widget.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: bronzeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: bronzeColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          widget.badge!,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: bronzeColor,
                            height: 1.2,
                            textStyle: const TextStyle(
                                fontFamilyFallback: AppTheme.fontFallbacks),
                          ),
                        ),
                      )
                    else if (!widget.isPrimary)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _isHovered ? 0.8 : 0.3,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 17,
                          color: _isHovered
                              ? bronzeColor
                              : ext.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
