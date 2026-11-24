import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';

class StartupScreen extends ConsumerStatefulWidget {
  final VoidCallback? onReady;

  const StartupScreen({super.key, this.onReady});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  bool _isMigrating = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Artificial brief initialization delay to simulate DB opening and settings load
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      if (widget.onReady != null) {
        widget.onReady!();
      } else {
        final authRepo = ref.read(authRepositoryProvider);
        if (authRepo.currentUser == null) {
          context.go('/auth');
        } else {
          context.go('/');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBangla = ref.watch(settingsProvider).appLanguage == 'bn';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isDark
                  ? 'assets/images/mylaws_brand_logo_dark.png'
                  : 'assets/images/mylaws_brand_logo_transparent.png',
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/mylaws_brand_logo.png',
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            if (_isMigrating) ...[
              Text(
                isBangla
                    ? 'আপনার সংরক্ষিত তথ্য নতুন অ্যাপে আনা হচ্ছে...'
                    : 'Migrating your saved data to the new app...',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
