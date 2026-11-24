import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/user_quota.dart';

class Composer extends StatefulWidget {
  final TextEditingController controller;
  final bool isWorking;
  final bool isBangla;
  final UserQuota? quota;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final VoidCallback? onNewChat;
  final ValueChanged<String>? onChanged;

  const Composer({
    super.key,
    required this.controller,
    required this.isWorking,
    required this.isBangla,
    this.quota,
    required this.onSend,
    required this.onStop,
    this.onNewChat,
    this.onChanged,
  });

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  static const int maxChars = 3000;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (mounted && _isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = widget.controller.text;
    final hasQuota = widget.quota == null ||
        (widget.quota!.canQuery && widget.quota!.remaining > 0);
    final canSend = text.trim().isNotEmpty &&
        !widget.isWorking &&
        text.length <= maxChars &&
        hasQuota;
    final showCounter = text.length > 2500;

    final warmSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderUnfocused =
        isDark ? AppColors.darkOutline : AppColors.subtleGridBorder;
    final goldAccent = isDark ? AppColors.darkGold : AppColors.antiqueGold;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: warmSurface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isFocused
                ? (isDark ? const Color(0xFFD8AE6A) : const Color(0xFF231F1C))
                : (isDark ? AppColors.darkOutline : AppColors.subtleGridBorder),
            width: _isFocused ? 1.6 : 1.2,
          ),
          boxShadow: [
            if (_isFocused)
              BoxShadow(
                color: (isDark ? const Color(0xFFD8AE6A) : Colors.black)
                    .withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showCounter) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 2, right: 14),
                child: Text(
                  '${text.length} / $maxChars',
                  style: TextStyle(
                    fontSize: 11,
                    color: text.length > maxChars
                        ? (isDark ? AppColors.darkError : AppColors.lightError)
                        : (isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Option: Start New Chat Button (Iconic speech bubble for conversation)
                if (widget.onNewChat != null) ...[
                  Tooltip(
                    message: widget.isBangla
                        ? 'নতুন আলোচনা / New Chat'
                        : 'Start New Chat',
                    child: InkWell(
                      onTap: widget.isWorking
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              widget.onNewChat?.call();
                            },
                      borderRadius: BorderRadius.circular(21),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.isWorking
                              ? (isDark
                                  ? const Color(0xFF26211C).withValues(alpha: 0.4)
                                  : const Color(0xFFEFEAE1).withValues(alpha: 0.4))
                              : (isDark
                                  ? const Color(0xFF26211C)
                                  : const Color(0xFFEFEAE1)),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: _NewChatIcon(
                          size: 21,
                          color: isDark
                              ? const Color(0xFFD8CCA8)
                              : const Color(0xFF423B33),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Center: Fully seamless transparent text input (Roomy and legible)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      focusNode: _focusNode,
                      controller: widget.controller,
                      cursorColor: isDark
                          ? const Color(0xFFD8AE6A)
                          : const Color(0xFF231F1C),
                      enabled: !widget.isWorking,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      onChanged: (val) {
                        setState(() {});
                        widget.onChanged?.call(val);
                      },
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                        color: isDark
                            ? AppColors.darkText
                            : const Color(0xFF1E1A17),
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        hintText: !hasQuota
                            ? (widget.isBangla
                                ? 'আজকের দৈনিক 30টি কোটা পূর্ণ হয়েছে। রাত 12টায় নবায়ন হবে।'
                                : 'Daily 30 query quota reached. Resets at midnight.')
                            : (widget.isBangla
                                ? 'কী সাহায্য চান? এখানে লিখুন...'
                                : 'Type or describe your situation...'),
                        hintStyle: GoogleFonts.hindSiliguri(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: !hasQuota
                              ? (isDark
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFD97706))
                              : (isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Right Option: High-Contrast Tactile Circular Send / Stop Button
                if (widget.isWorking)
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor:
                          isDark ? const Color(0xFF991B1B) : const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(42, 42),
                      padding: EdgeInsets.zero,
                    ),
                    tooltip: widget.isBangla ? 'থামান' : 'Stop',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      widget.onStop();
                    },
                    icon: const Icon(Icons.stop_rounded, size: 22),
                  )
                else
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: canSend
                          ? [
                              BoxShadow(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: isDark ? 0.2 : 0.16),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: canSend
                            ? (isDark
                                ? const Color(0xFFF1EDE1)
                                : const Color(0xFF1E1A17))
                            : (isDark
                                ? const Color(0xFF26211C)
                                : const Color(0xFFEFEAE1)),
                        foregroundColor: canSend
                            ? (isDark
                                ? const Color(0xFF141210)
                                : Colors.white)
                            : (isDark
                                ? const Color(0xFF6B6258)
                                : const Color(0xFFA59A8B)),
                        minimumSize: const Size(42, 42),
                        padding: EdgeInsets.zero,
                      ),
                      tooltip: !hasQuota
                          ? (widget.isBangla
                                ? 'আজকের দৈনিক কোটা শেষ'
                                : 'Daily quota exceeded')
                          : (widget.isBangla ? 'পাঠান' : 'Send'),
                      onPressed: canSend
                          ? () {
                              HapticFeedback.lightImpact();
                              widget.onSend();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_upward_rounded, size: 21),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Iconic speech bubble with a centered plus sign indicating "Start New Chat"
/// rather than conversation history.
class _NewChatIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _NewChatIcon({
    required this.color,
    this.size = 21,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: size,
            color: color,
          ),
          IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(bottom: size * 0.12),
              child: Icon(
                Icons.add_rounded,
                size: (size * 0.52).roundToDouble(),
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

