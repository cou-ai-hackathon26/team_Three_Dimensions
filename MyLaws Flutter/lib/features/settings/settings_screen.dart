import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/widgets/app_bar_shell.dart';
import '../../core/widgets/confirm_sheet.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final settings = ref.watch(settingsProvider);
    final authAsync = ref.watch(authStateProvider);
    final isBn = settings.appLanguage == 'bn';
    final user = authAsync.value;

    return Scaffold(
      appBar: AppBarShell(
        title: isBn ? 'সেটিংস' : 'Settings',
        showBack: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // User Account Section
            _buildSectionHeader(
              context,
              ext,
              isBn ? 'অ্যাকাউন্ট ও প্রোফাইল' : 'Account & Profile',
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ext.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ext.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: ext.primary.withOpacity(0.15),
                        child: Icon(Icons.person, color: ext.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ??
                                  (isBn ? 'MyLaws ব্যবহারকারী' : 'MyLaws User'),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ext.onSurface,
                              ),
                            ),
                            Text(
                              user?.email ??
                                  (isBn
                                      ? 'সুরক্ষিত অ্যাকাউন্ট'
                                      : 'Verified Account'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: ext.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (user != null) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            final confirmed = await ConfirmSheet.show(
                              context,
                              title: isBn ? 'লগআউট করবেন?' : 'Sign out?',
                              description: isBn
                                  ? 'আপনি নিশ্চিত যে আপনি অ্যাকাউন্ট থেকে বের হতে চান?'
                                  : 'Are you sure you want to sign out?',
                              confirmLabel: isBn ? 'লগআউট' : 'Sign out',
                            );
                            if (confirmed) {
                              await ref.read(authRepositoryProvider).signOut();
                              if (context.mounted) {
                                context.go('/auth');
                              }
                            }
                          },
                          child: Text(isBn ? 'লগআউট' : 'Sign out'),
                        ),
                        const Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: ext.critical),
                          onPressed: () async {
                            final confirmed = await ConfirmSheet.show(
                              context,
                              title: isBn
                                  ? 'অ্যাকাউন্ট মুছে ফেলবেন?'
                                  : 'Delete Account?',
                              description: isBn
                                  ? 'আপনার অ্যাকাউন্ট এবং সমস্ত সার্ভার ডেটা স্থায়ীভাবে মুছে ফেলা হবে। এই কাজটি আর পূর্বাবস্থায় ফিরিয়ে আনা যাবে না।'
                                  : 'Your account and all associated server data will be permanently deleted. This action cannot be undone.',
                              confirmLabel: isBn
                                  ? 'স্থায়ীভাবে মুছুন'
                                  : 'Delete Permanently',
                              isDestructive: true,
                            );
                            if (confirmed) {
                              await ref
                                  .read(authRepositoryProvider)
                                  .deleteAccount();
                              if (context.mounted) {
                                context.go('/auth');
                              }
                            }
                          },
                          child: Text(
                              isBn ? 'অ্যাকাউন্ট মুছুন' : 'Delete Account'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance & Theme Section
            _buildSectionHeader(
              context,
              ext,
              isBn ? 'দৃশ্যমানতা ও থিম' : 'Appearance & Theme',
            ),
            Container(
              decoration: BoxDecoration(
                color: ext.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ext.outlineVariant),
              ),
              child: Column(
                children: [
                  RadioListTile<AppThemeMode>(
                    title: Text(isBn ? 'সিস্টেম ডিফল্ট' : 'System Default'),
                    value: AppThemeMode.system,
                    groupValue: settings.themeMode,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setTheme(val);
                      }
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(isBn ? 'লাইট থিম' : 'Light Theme'),
                    value: AppThemeMode.light,
                    groupValue: settings.themeMode,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setTheme(val);
                      }
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(isBn ? 'ডার্ক থিম' : 'Dark Theme'),
                    value: AppThemeMode.dark,
                    groupValue: settings.themeMode,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setTheme(val);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title:
                        Text(isBn ? 'বড় হরফ (সহজ পাঠ্য)' : 'Larger Text Mode'),
                    subtitle: Text(
                      isBn
                          ? 'আইনি ধারা ও খসড়ায় লেখার আকার বড় করুন'
                          : 'Increase reading font size',
                    ),
                    value: settings.largerText,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .update(settings.copyWith(largerText: val));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Language Section
            _buildSectionHeader(
              context,
              ext,
              isBn ? 'ভাষা নির্বাচন' : 'Language Selection',
            ),
            Container(
              decoration: BoxDecoration(
                color: ext.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ext.outlineVariant),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('বাংলা (Bangla)'),
                    subtitle: const Text('নম্র "আপনি" সম্বোধন'),
                    value: 'bn',
                    groupValue: settings.appLanguage,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setLocale(val);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('English'),
                    subtitle: const Text('Plain legal English'),
                    value: 'en',
                    groupValue: settings.appLanguage,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setLocale(val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data, Network & Offline Section
            _buildSectionHeader(
              context,
              ext,
              isBn ? 'নেটওয়ার্ক ও ডেটা সেটিং' : 'Network & Data Settings',
            ),
            Container(
              decoration: BoxDecoration(
                color: ext.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ext.outlineVariant),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(isBn
                        ? 'শুধুমাত্র ওয়াইফাই ব্যবহার'
                        : 'Wi-Fi Only Downloads'),
                    subtitle: Text(
                      isBn
                          ? 'প্যাকেজ ডাউনলোড মোবাইল ডেটায় সীমাবদ্ধ রাখুন'
                          : 'Download packages only when connected to Wi-Fi',
                    ),
                    value: settings.wifiOnly,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .update(settings.copyWith(wifiOnly: val));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(isBn
                        ? 'আইন প্যাকেজ স্বয়ংক্রিয় হালনাগাদ'
                        : 'Auto-update Law Packs'),
                    subtitle: Text(
                      isBn
                          ? 'নতুন সংশোধনী স্বয়ংক্রিয়ভাবে ডাউনলোড করুন'
                          : 'Keep statutory provisions automatically current',
                    ),
                    value: settings.autoUpdateLaws,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .update(settings.copyWith(autoUpdateLaws: val));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(isBn
                        ? 'অফলাইন অনুসন্ধানকে অগ্রাধিকার'
                        : 'Prefer Offline Search'),
                    subtitle: Text(
                      isBn
                          ? 'উপলব্ধ থাকলে ইন্টারনেটের বদলে লোকাল ডেটাবেজ ব্যবহার করুন'
                          : 'Prioritize local SQLite database when available',
                    ),
                    value: settings.preferOffline,
                    activeColor: ext.primary,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .update(settings.copyWith(preferOffline: val));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy & Scoped Deletion
            _buildSectionHeader(
              context,
              ext,
              isBn
                  ? 'গোপনীয়তা ও লোকাল ডেটা ব্যবস্থাপনা'
                  : 'Privacy & Local Data Management',
            ),
            Container(
              decoration: BoxDecoration(
                color: ext.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ext.outlineVariant),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.delete_sweep_outlined, color: ext.critical),
                    title: Text(isBn
                        ? 'কথোপকথনের ইতিহাস মুছুন'
                        : 'Clear Conversation History'),
                    subtitle: Text(
                      isBn
                          ? 'ডিভাইসে সংরক্ষিত সকল চ্যাট মুছে যাবে'
                          : 'Permanently remove all local chats',
                    ),
                    onTap: () async {
                      final confirmed = await ConfirmSheet.show(
                        context,
                        title: isBn
                            ? 'কথোপকথন মুছে ফেলবেন?'
                            : 'Clear conversations?',
                        description: isBn
                            ? 'ডিভাইসে সংরক্ষিত সব কথোপকথন স্থায়ীভাবে মুছে ফেলা হবে।'
                            : 'All locally stored conversations will be permanently cleared.',
                        confirmLabel: isBn ? 'মুছে ফেলুন' : 'Clear',
                        isDestructive: true,
                      );
                      if (confirmed && context.mounted) {
                        ref
                            .read(conversationProvider.notifier)
                            .startNewConversation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isBn
                                ? 'ইতিহাস মুছে ফেলা হয়েছে'
                                : 'History cleared'),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        Icon(Icons.description_outlined, color: ext.critical),
                    title: Text(
                        isBn ? 'সংরক্ষিত খসড়া মুছুন' : 'Clear Saved Drafts'),
                    subtitle: Text(
                      isBn
                          ? 'সকল খসড়া জিডি ও অভিযোগ মুছে যাবে'
                          : 'Remove all locally saved drafts',
                    ),
                    onTap: () async {
                      final confirmed = await ConfirmSheet.show(
                        context,
                        title: isBn
                            ? 'সকল খসড়া মুছে ফেলবেন?'
                            : 'Clear all drafts?',
                        description: isBn
                            ? 'আপনার ডিভাইসে সংরক্ষিত সমস্ত খসড়া স্থায়ীভাবে মুছে ফেলা হবে।'
                            : 'All draft applications will be deleted from this device.',
                        confirmLabel: isBn ? 'মুছে ফেলুন' : 'Clear',
                        isDestructive: true,
                      );
                      if (confirmed && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isBn
                                ? 'খসড়াসমূহ মুছে ফেলা হয়েছে'
                                : 'Drafts cleared'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    AppThemeExtension ext,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ext.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
