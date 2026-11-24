import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/widgets/app_bar_shell.dart';
import '../../core/widgets/language_capsule.dart';
import '../../core/widgets/profile_quota_pill.dart';
import '../../core/widgets/state_banner.dart';
import '../../core/widgets/typewriter_text.dart';
import '../conversation/composer.dart';
import '../conversation/thread_view.dart';
import '../drawer/drawer_shell.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _composerController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _sendMessage(String text, String lang) {
    if (text.trim().isEmpty) return;
    ref.read(conversationProvider.notifier).sendNarrative(text, language: lang);
    _composerController.clear();
  }

  void _stopGeneration() {
    ref.read(conversationProvider.notifier).stop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ext = context.appTheme;
    final convState = ref.watch(conversationProvider);
    final quotaAsync = ref.watch(quotaStateProvider);
    final authAsync = ref.watch(authStateProvider);
    final settings = ref.watch(settingsProvider);

    final lang = settings.appLanguage;
    final isBn = lang == 'bn';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerShell(),
      appBar: AppBarShell(
        title: '',
        showBack: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: isBn ? 'মেন্যু খুলুন' : 'Open menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // 1. Language Toggle
          LanguageCapsule(
            currentLocale: lang,
            onLocaleChanged: (newLang) {
              ref.read(settingsProvider.notifier).setLocale(newLang);
            },
          ),
          const SizedBox(width: 8),
          // 2. User Profile Section (Sign in / Sign out / Account details & Settings)
          ProfileQuotaPill(
            user: authAsync.value,
            quota: quotaAsync.value,
            isBangla: isBn,
            onNewConversation: () {
              _composerController.clear();
              ref.read(conversationProvider.notifier).startNewConversation();
            },
            onSavedConversations: () => context.push('/conversations'),
            onSettings: () => context.push('/settings'),
            onSignIn: () => context.go('/auth'),
            onSignOut: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Error banner if any
            if (convState.errorMessage != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: StateBanner(
                  type: BannerType.error,
                  message: convState.errorMessage!,
                ),
              ),

            // Main body
            Expanded(
              child: convState.messages.isEmpty
                  ? _buildEmptyState(
                      context,
                      isBn,
                      ext,
                      theme,
                    )
                  : ThreadView(
                      messages: convState.messages,
                      isWorking: convState.isWorking,
                      isBangla: isBn,
                      onStop: _stopGeneration,
                      onChecklistToggled: (stepId) {
                        ref
                            .read(conversationProvider.notifier)
                            .toggleChecklistStep(stepId);
                      },
                    ),
            ),

            // Quota Exhausted Banner
            if (quotaAsync.value != null && quotaAsync.value!.remaining <= 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2E1C12)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF9A3412)
                        : const Color(0xFFFDBA74),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: isDark
                          ? const Color(0xFFFB923C)
                          : const Color(0xFFC2410C),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn
                                ? 'আজকের দৈনিক 30টি আইনি পরামর্শের কোটা পূর্ণ হয়েছে'
                                : 'Daily 30 Query Limit Reached',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: isDark
                                  ? const Color(0xFFFED7AA)
                                  : const Color(0xFF9A3412),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBn
                                ? 'বাংলাদেশ সময় প্রতিদিন রাত 12:00টায় আপনার কোটা নবায়ন হবে। জরুরি সহায়তায় 999 বা 16430 নম্বরে যোগাযোগ করুন।'
                                : 'Your quota renews daily at 12:00 AM (BST). For emergency legal aid, call 999 or 16430.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFFE5D5C5)
                                  : const Color(0xFF7C2D12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Floating Capsule Composer (Claude-style)
            Composer(
              controller: _composerController,
              isWorking: convState.isWorking,
              isBangla: isBn,
              quota: quotaAsync.value,
              onNewChat: () {
                _composerController.clear();
                ref.read(conversationProvider.notifier).startNewConversation();
              },
              onSend: () => _sendMessage(_composerController.text, lang),
              onStop: _stopGeneration,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting({bool isBn = false}) {
    if (isBn) {
      return 'স্বাগতম!';
    }
    return 'Welcome Back';
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isBn,
    AppThemeExtension ext,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final greeting = _getGreeting(isBn: isBn);

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Center Focal Emblem
            Image.asset(
              isDark
                  ? 'assets/images/mylaws_emblem_gold.png'
                  : 'assets/images/mylaws_emblem_light.png',
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                isDark
                    ? 'assets/images/mylaws_brand_logo_dark.png'
                    : 'assets/images/mylaws_brand_logo_transparent.png',
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.balance,
                  size: 54,
                  color: isDark ? ext.calloutAccent : ext.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Polished Welcoming Animated Typewriter Greeting
            TypewriterText(
              text: greeting,
              animate: true,
              charDuration: const Duration(milliseconds: 32),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: isBn ? 'Anek Bangla' : 'Newsreader',
                fontSize: 30,
                fontWeight: FontWeight.w600,
                height: 1.28,
                letterSpacing: -0.3,
                color: ext.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
