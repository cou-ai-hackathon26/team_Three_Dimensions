import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A legal reasoning stage data definition.
class ReasoningStage {
  final IconData icon;
  final String titleBn;
  final String titleEn;
  final String descBn;
  final String descEn;

  const ReasoningStage({
    required this.icon,
    required this.titleBn,
    required this.titleEn,
    required this.descBn,
    required this.descEn,
  });
}

/// An animated legal reasoning indicator widget displaying:
/// - Oscillating Scales of Justice sways between -8 and +8 degrees around its fulcrum
/// - Ambient circular radar pulse aura expanding and fading behind the scale
/// - Golden Shimmer Sweep Bar along the top of the card
/// - 4 sequential reasoning stages cycling every 1.5–2.0 seconds
/// - 4-segment animated stepper dots (active expands to width 24, inactive width 6)
class LegalReasoningIndicator extends StatefulWidget {
  final bool isBangla;
  final VoidCallback? onStop;

  const LegalReasoningIndicator({
    super.key,
    required this.isBangla,
    this.onStop,
  });

  static const List<ReasoningStage> stages = [
    // Stage 1 (0.0s – 1.5s)
    ReasoningStage(
      icon: Icons.search_rounded,
      titleBn: 'আইনি বিরোধ ও প্রেক্ষাপট পর্যালোচনা',
      titleEn: 'Analyzing Dispute Context & Facts',
      descBn:
          'ঘটনার উপাদান ও সংশ্লিষ্ট পক্ষসমূহের আইনগত অবস্থান নির্ণয় করা হচ্ছে...',
      descEn:
          'Determining factual elements and legal standing of parties involved...',
    ),
    // Stage 2 (1.5s – 3.2s)
    ReasoningStage(
      icon: Icons.menu_book_rounded,
      titleBn: 'বাংলাদেশ কোড ও ১২০০+ গেজেট বিধান অনুসন্ধান',
      titleEn: 'Scanning Bangladesh Code Corpus',
      descBn:
          'শ্রম আইন, দণ্ডবিধি, দেওয়ানি ও বিশেষ আইনের সংবিধিবদ্ধ ধারার সাথে মেলানো হচ্ছে...',
      descEn:
          'Cross-referencing Labour Act, Penal Code, CPC and special enactments...',
    ),
    // Stage 3 (3.2s – 5.0s)
    ReasoningStage(
      icon: Icons.balance_rounded,
      titleBn: 'ধারা যাচাই ও সুনির্দিষ্ট এখতিয়ার নির্ধারণ',
      titleEn: 'Verifying Sections & Competent Jurisdiction',
      descBn:
          'থানা, শ্রম আদালত বা সহকারী কমিশনারের এখতিয়ার ও আইনি সময়সীমা নিরূপণ...',
      descEn:
          'Assessing police station, Labour Court, or AC Land jurisdiction & limitation periods...',
    ),
    // Stage 4 (5.0s+)
    ReasoningStage(
      icon: Icons.auto_awesome_rounded,
      titleBn: '৪-ধাপ সমাধান ও খসড়া নির্দেশিকা তৈরি',
      titleEn: 'Synthesizing 4-Step Guidance & Drafts',
      descBn:
          'সহজ বাংলায় নাগরিক করণীয়, চেকলিস্ট ও অফিশিয়াল অভিযোগের ড্রাফট তৈরি হচ্ছে...',
      descEn:
          'Generating citizen-friendly checklist, plain Bangla rights, and formal drafts...',
    ),
  ];

  @override
  State<LegalReasoningIndicator> createState() =>
      _LegalReasoningIndicatorState();
}

class _LegalReasoningIndicatorState extends State<LegalReasoningIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  int _currentStageIndex = 0;
  int _elapsedMs = 0;
  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();

    // Golden Shimmer Sweep Bar
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Sequential 4-Stage Clock (0.0–1.5s, 1.5–3.2s, 3.2–5.0s, 5.0s+)
    _startStageTicker();
  }

  void _startStageTicker() {
    _stageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      _elapsedMs += 100;
      int nextIndex;
      if (_elapsedMs < 1500) {
        nextIndex = 0;
      } else if (_elapsedMs < 3200) {
        nextIndex = 1;
      } else if (_elapsedMs < 5000) {
        nextIndex = 2;
      } else {
        nextIndex = 3;
      }
      if (nextIndex != _currentStageIndex) {
        setState(() {
          _currentStageIndex = nextIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _stageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1F1B18) : const Color(0xFFFAF7F0);
    final cardBorder =
        isDark ? const Color(0xFF38312B) : const Color(0xFFE5DFD3);
    final bronzePrimary =
        isDark ? const Color(0xFFD8AE6A) : const Color(0xFF8C6735);
    final goldGlow = isDark ? const Color(0xFFFFD54F) : const Color(0xFFC89234);
    final textColor =
        isDark ? const Color(0xFFF5F3ED) : const Color(0xFF1B1C18);
    final secondaryTextColor =
        isDark ? const Color(0xFFA69E93) : const Color(0xFF4E453A);

    final stage = LegalReasoningIndicator.stages[_currentStageIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Golden Shimmer Sweep Bar
            _buildGoldenShimmerSweep(
              bronzePrimary: bronzePrimary,
              goldGlow: goldGlow,
            ),

            // Main Card Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Courtroom Justice Gavel ("Order! Order!") Avatar in Black & White
                      OrderOrderGavelAvatar(
                        isDark: isDark,
                      ),

                      const SizedBox(width: 12),

                      // Reasoning Text Stage (with AnimatedSwitcher morph)
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.12),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            key: ValueKey<int>(_currentStageIndex),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    stage.icon,
                                    size: 15,
                                    color: bronzePrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.isBangla
                                          ? stage.titleBn
                                          : stage.titleEn,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.isBangla ? stage.descBn : stage.descEn,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Stop Action Button
                      if (widget.onStop != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            Icons.stop_circle_outlined,
                            size: 22,
                            color: isDark
                                ? AppColors.darkError
                                : AppColors.lightError,
                          ),
                          tooltip: widget.isBangla ? 'থামান' : 'Stop',
                          splashRadius: 18,
                          constraints:
                              const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          onPressed: widget.onStop,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 3. Stepper Dots (active expands to 24, inactive 6)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepperDots(bronzePrimary: bronzePrimary),
                      Text(
                        widget.isBangla
                            ? 'ধাপ ${_toBanglaDigit(_currentStageIndex + 1)}/৪'
                            : 'Stage ${_currentStageIndex + 1}/4',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // Golden Shimmer Sweep Bar
  // =========================================================================
  Widget _buildGoldenShimmerSweep({
    required Color bronzePrimary,
    required Color goldGlow,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Container(
          height: 3.5,
          width: double.infinity,
          decoration: BoxDecoration(
            color: bronzePrimary.withOpacity(0.12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final sweepOffset = _shimmerController.value * (w + 140) - 70;
              return Stack(
                children: [
                  Positioned(
                    left: sweepOffset,
                    top: 0,
                    bottom: 0,
                    width: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            goldGlow.withOpacity(0.35),
                            goldGlow,
                            goldGlow.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // =========================================================================
  // Stepper Dots (active width: 24, inactive width: 6)
  // =========================================================================
  Widget _buildStepperDots({required Color bronzePrimary}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index == _currentStageIndex;
        final isDone = index < _currentStageIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          height: 5,
          width: isActive ? 24 : 6,
          decoration: BoxDecoration(
            color: isActive
                ? bronzePrimary
                : (isDone
                    ? bronzePrimary.withOpacity(0.65)
                    : bronzePrimary.withOpacity(0.22)),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  static String _toBanglaDigit(int num) {
    const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return num.toString().split('').map((char) {
      final d = int.tryParse(char);
      return d != null ? digits[d] : char;
    }).join('');
  }
}

// =============================================================================
// Courtroom Justice Gavel ("Order! Order!") Avatar in Black & White
// =============================================================================

/// A high-contrast Black and White judicial gavel ("Order! Order!") animation widget.
/// Renders an authoritative courtroom gavel in rhythmic motion:
/// - Pure black/obsidian circular medallion badge with crisp white/silver perimeter
/// - Rhythmic double-strike ("Order! Order!") hammer motion onto a judicial sound block
/// - Expanding acoustic shockwave ripples emanating on each authoritative strike impact
/// - Animated expanding monochrome radar pulse ring
class OrderOrderGavelAvatar extends StatefulWidget {
  final bool isDark;
  final double size;

  const OrderOrderGavelAvatar({
    super.key,
    required this.isDark,
    this.size = 44.0,
  });

  @override
  State<OrderOrderGavelAvatar> createState() => _OrderOrderGavelAvatarState();
}

class _OrderOrderGavelAvatarState extends State<OrderOrderGavelAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gavelController;

  @override
  void initState() {
    super.initState();
    _gavelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _gavelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final totalSize = widget.size;
    final badgeSize = totalSize - 4.0;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: AnimatedBuilder(
        animation: _gavelController,
        builder: (context, _) {
          final t = _gavelController.value;

          // Pulse expansion on each strike cycle (monochrome ripple)
          final pulseProgress = (t < 0.6) ? (t / 0.6) : ((t - 0.6) / 0.4);
          final pulseScale =
              0.95 + 0.70 * Curves.easeOut.transform(pulseProgress);
          final pulseOpacity =
              (1.0 - Curves.easeOut.transform(pulseProgress)) * 0.40;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Monochrome Radar Pulse Ring in Black/White
              Transform.scale(
                scale: pulseScale,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: pulseOpacity),
                      width: 1.2,
                    ),
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: pulseOpacity * 0.08),
                  ),
                ),
              ),

              // 2. High-contrast Black & White Judicial Badge Container
              Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF0C0E11)
                      : const Color(0xFF14171B),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFE2E4E8)
                        : const Color(0xFF33383F),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.55 : 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomPaint(
                    size: Size(badgeSize, badgeSize),
                    painter: GavelOrderPainter(
                      progress: t,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Custom painter rendering the Black & White courtroom gavel, sounding block,
/// and impact sound ripples.
class GavelOrderPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final bool isDark;

  GavelOrderPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress;

    // Anchor coordinates
    const pivot = Offset(26.5, 27.0);
    const length = 13.5;
    const baseAngle = -155.0 * (math.pi / 180.0); // handle angle at rest

    // 1. Calculate dynamic strike angle ("Order! Order!" rhythm)
    double angleDeg = 0.0;
    double impact1Progress = -1.0;
    double impact2Progress = -1.0;

    if (t < 0.16) {
      // Wind-up lift: 0 to 30 degrees upward
      final p = t / 0.16;
      angleDeg = 30.0 * Curves.easeOutCubic.transform(p);
    } else if (t < 0.25) {
      // Strike 1 ("Order!"): Downward snap
      final p = (t - 0.16) / 0.09;
      angleDeg = 30.0 * (1.0 - Curves.easeInQuad.transform(p));
    } else if (t < 0.34) {
      // Bounce after Strike 1: Up to 11 degrees
      final p = (t - 0.25) / 0.09;
      angleDeg = 11.0 * math.sin(p * math.pi);
      impact1Progress = (t - 0.25) / 0.13;
    } else if (t < 0.38) {
      impact1Progress = (t - 0.25) / 0.13;
    }

    if (t >= 0.34 && t < 0.43) {
      // Strike 2 ("Order!"): Downward snap
      final p = (t - 0.34) / 0.09;
      angleDeg = 11.0 * (1.0 - Curves.easeInQuad.transform(p));
    } else if (t >= 0.43 && t < 0.52) {
      // Settle bounce: Micro bounce up to 3.5 degrees
      final p = (t - 0.43) / 0.09;
      angleDeg = 3.5 * math.sin(p * math.pi);
      impact2Progress = (t - 0.43) / 0.13;
    } else if (t >= 0.52 && t < 0.58) {
      impact2Progress = (t - 0.43) / 0.13;
    } else if (t >= 0.58) {
      // Judicial pause
      angleDeg = 0.0;
    }

    // Impact location where mallet face strikes the sound block
    const impactPoint = Offset(11.8, 26.0);

    // 2. Draw Impact Sound Ripples (crisp white arcs)
    void drawImpactRipples(double p, double maxRadius, double initialOpacity) {
      if (p < 0.0 || p > 1.0) return;
      final opacity = (1.0 - p) * initialOpacity;
      final r1 = 3.0 + (maxRadius - 3.0) * p;
      final r2 = r1 * 0.65;

      final ripplePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round;

      // Upward expanding acoustic sound arcs
      canvas.drawArc(
        Rect.fromCircle(center: impactPoint, radius: r1),
        -math.pi * 0.90,
        math.pi * 0.70,
        false,
        ripplePaint,
      );

      if (r2 > 2.5) {
        canvas.drawArc(
          Rect.fromCircle(center: impactPoint, radius: r2),
          -math.pi * 0.85,
          math.pi * 0.60,
          false,
          ripplePaint..strokeWidth = 1.0,
        );
      }
    }

    if (impact1Progress >= 0.0 && impact1Progress <= 1.0) {
      drawImpactRipples(impact1Progress, 9.5, 0.85);
    }
    if (impact2Progress >= 0.0 && impact2Progress <= 1.0) {
      drawImpactRipples(impact2Progress, 11.5, 0.95);
    }

    // 3. Draw Sounding Block (Base Stand) in Black & White
    // Base bottom lip
    final baseBottomRect = Rect.fromCenter(
      center: const Offset(13.5, 29.2),
      width: 17.0,
      height: 2.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseBottomRect, const Radius.circular(0.8)),
      Paint()..color = const Color(0xFF8A9099),
    );

    // Main sound block pedestal
    final blockRect = Rect.fromCenter(
      center: const Offset(13.5, 27.2),
      width: 14.5,
      height: 3.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect, const Radius.circular(1.2)),
      Paint()..color = Colors.white,
    );

    // 4. Draw Courtroom Gavel (Hammer)
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    // Rotating clockwise (positive degrees) lifts the mallet head up
    canvas.rotate(baseAngle + angleDeg * (math.pi / 180.0));

    // A. Handle: extends from (1.5, 0) to (length, 0)
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(1.5, 0), const Offset(length, 0), handlePaint);

    // B. Handle Pommel / Grip End
    canvas.drawCircle(
      const Offset(1.0, 0),
      1.7,
      Paint()..color = const Color(0xFFD6D9DE),
    );

    // C. Mallet Barrel (Double-ended Hammer Head at length)
    // Perpendicular to the handle
    final headRect = Rect.fromCenter(
      center: const Offset(length, 0),
      width: 5.2,
      height: 10.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(1.2)),
      Paint()..color = Colors.white,
    );

    // D. Central decorative dark band
    final bandPaint = Paint()
      ..color = const Color(0xFF1E2228)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawLine(
      const Offset(length - 2.5, 0),
      const Offset(length + 2.5, 0),
      bandPaint,
    );

    // E. Striking face rim caps:
    // Top end cap (opposing face)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: const Offset(length, -5.0), width: 6.2, height: 1.3),
        const Radius.circular(0.6),
      ),
      Paint()..color = const Color(0xFFDCE0E5),
    );

    // Bottom end cap (the striking face hitting the block)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: const Offset(length, 5.0), width: 6.2, height: 1.3),
        const Radius.circular(0.6),
      ),
      Paint()..color = const Color(0xFFE8ECF0),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GavelOrderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
