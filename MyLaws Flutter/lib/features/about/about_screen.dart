import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/widgets/app_bar_shell.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final isBn = settings.appLanguage == 'bn';

    final bronzePrimary =
        isDark ? const Color(0xFFE0BA7A) : const Color(0xFF7A5420);
    final bronzeContainer =
        isDark ? const Color(0xFF2E2417) : const Color(0xFFF7F2E7);
    final cardBorder =
        isDark ? const Color(0xFF38312B) : const Color(0xFFE2DDD1);

    return Scaffold(
      backgroundColor: ext.surface,
      appBar: AppBarShell(
        title: isBn ? 'MyLaws সম্পর্কে' : 'About MyLaws',
        showBack: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // -----------------------------------------------------------------
            // Hero Brand Card
            // -----------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2E251A), const Color(0xFF211B14)]
                      : [const Color(0xFFFAF6EE), const Color(0xFFF1EADE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset(
                    isDark
                        ? 'assets/images/mylaws_brand_logo_dark.png'
                        : 'assets/images/mylaws_brand_logo_transparent.png',
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/mylaws_brand_logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MyLaws',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ext.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isBn
                        ? 'বাংলাদেশের নাগরিক আইনি সহায়িকা ও খসড়া প্ল্যাটফর্ম'
                        : 'Bangladesh Citizen Legal Information & Document Preparation Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ext.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: bronzePrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: bronzePrimary.withOpacity(0.3)),
                        ),
                        child: Text(
                          isBn
                              ? 'সংস্করণ ১.০.০ (পাইলট) • Build 2026.11'
                              : 'Version 1.0.0 (Pilot) • Build 2026.11',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: bronzePrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008069).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF008069).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified,
                                size: 13, color: Color(0xFF008069)),
                            const SizedBox(width: 4),
                            Text(
                              isBn
                                  ? 'Meta AI Hackathon 2026'
                                  : 'Meta AI Hackathon 2026',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF008069),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // Legal Disclaimer (Strict & Prominent)
            // -----------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ext.critical.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ext.critical.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: ext.critical, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'আইনি অস্বীকৃতি (Legal Disclaimer)'
                              : 'Important Legal Disclaimer',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ext.critical,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBn
                        ? '১. MyLaws কোনো আইনজীবী বা আইন সংস্থা নয়। এখানে প্রদত্ত তথ্য কোনো আনুষ্ঠানিক আইনি পরামর্শ (Legal Advice) নয়।\n'
                            '২. এটি কোনো সরকারি প্রতিষ্ঠান বা আদালতের প্রতিনিধিত্ব করে না এবং কোনো নথি বা অভিযোগ স্বয়ংক্রিয়ভাবে দাখিল করে না।\n'
                            '৩. যেকোনো আনুষ্ঠানিক আইনি পদক্ষেপ নেওয়ার পূর্বে বাংলাদেশ বার কাউন্সিলের তালিকাভুক্ত আইনজীবীর পরামর্শ নিন।'
                        : '1. MyLaws is not a lawyer or law firm. Information provided does not constitute legal advice.\n'
                            '2. MyLaws does not represent any court or government authority and never files documents on your behalf.\n'
                            '3. Always consult a Bangladesh Bar Council enrolled advocate before taking official legal action.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext.onSurface,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // Government Helplines & Emergency Support
            // -----------------------------------------------------------------
            _buildSectionHeader(
              context,
              bronzePrimary,
              isBn
                  ? 'জরুরি ও আইনি হেল্পলাইন'
                  : 'Official Emergency & Legal Helplines',
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bronzeContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: [
                  _buildHelplineRow(
                    number: '16430',
                    title: isBn
                        ? 'জাতীয় আইনগত সহায়তা সংস্থা (টোল-ফ্রি ২৪/৭)'
                        : 'National Legal Aid Services (Toll-Free 24/7)',
                    description: isBn
                        ? 'বিনামূল্যে সরকারি আইনি পরামর্শ ও সহায়তা'
                        : 'Free government legal counseling & aid',
                    icon: Icons.support_agent_rounded,
                    accentColor: const Color(0xFF0D6EFD),
                    isDark: isDark,
                  ),
                  const Divider(height: 16),
                  _buildHelplineRow(
                    number: '999',
                    title: isBn
                        ? 'জাতীয় জরুরি সেবা (২৪/৭)'
                        : 'National Emergency Service (24/7)',
                    description: isBn
                        ? 'পুলিশ, অ্যাম্বুলেন্স ও ফায়ার সার্ভিস'
                        : 'Emergency Police, Ambulance & Fire Service',
                    icon: Icons.emergency_rounded,
                    accentColor: const Color(0xFFDC3545),
                    isDark: isDark,
                  ),
                  const Divider(height: 16),
                  _buildHelplineRow(
                    number: '16121',
                    title: isBn
                        ? 'জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তর'
                        : 'National Consumer Rights Directorate (DNCRP)',
                    description: isBn
                        ? 'পণ্য বা সেবায় প্রতারণা প্রতিকার'
                        : 'Consumer complaints & commercial fraud redress',
                    icon: Icons.storefront_rounded,
                    accentColor: const Color(0xFF198754),
                    isDark: isDark,
                  ),
                  const Divider(height: 16),
                  _buildHelplineRow(
                    number: '16358',
                    title: isBn
                        ? 'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর'
                        : 'Department of Inspection for Factories (DIFE)',
                    description: isBn
                        ? 'শ্রমিক অধিকার, বকেয়া বেতন ও কর্মপরিবেশ অভিযোগ'
                        : 'Labour rights, wage claims & safety complaints',
                    icon: Icons.engineering_rounded,
                    accentColor: const Color(0xFFFD7E14),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // Corpus & Model Transparency
            // -----------------------------------------------------------------
            _buildSectionHeader(
              context,
              bronzePrimary,
              isBn ? 'উৎস ও প্রযুক্তিগত স্বচ্ছতা' : 'Corpus & Provenance',
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
                  _buildMetaRow(
                    isBn ? 'আইনি তথ্যভাণ্ডার সংস্করণ' : 'Corpus Version',
                    '2026.10.30-batch2.2',
                    ext,
                    theme,
                  ),
                  const Divider(height: 20),
                  _buildMetaRow(
                    isBn ? 'সংকলিত ধারা সংখ্যা' : 'Compiled Provisions',
                    isBn
                        ? '২৫৫টি যাচাইকৃত ধারা (শ্রম, ভোক্তা, দণ্ডবিধি)'
                        : '255 Verified Sections (Labour, Consumer, Penal Code)',
                    ext,
                    theme,
                  ),
                  const Divider(height: 20),
                  _buildMetaRow(
                    isBn ? 'সরকারি তথ্যসূত্র' : 'Statutory Reference',
                    isBn
                        ? 'bdlaws.minlaw.gov.bd (লেজিসলেটিভ ও সংসদ বিষয়ক বিভাগ)'
                        : 'bdlaws.minlaw.gov.bd (Legislative & Parliamentary Affairs Division)',
                    ext,
                    theme,
                  ),
                  const Divider(height: 20),
                  _buildMetaRow(
                    isBn ? 'এআই সহায়তাকারী মডেল' : 'AI Assistant Model',
                    'Meta Llama 3.3 70B Instruct / On-Device Pack',
                    ext,
                    theme,
                  ),
                  const Divider(height: 20),
                  _buildMetaRow(
                    isBn ? 'ব্যবহারকারীর গোপনীয়তা' : 'User Privacy',
                    isBn
                        ? 'ডিভাইসে সংরক্ষিত খসড়া এবং এন্ড-টু-এন্ড সুরক্ষিত'
                        : 'Local encrypted drafts and end-to-end security',
                    ext,
                    theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // Open Source & Font Licenses
            // -----------------------------------------------------------------
            _buildSectionHeader(
              context,
              bronzePrimary,
              isBn ? 'লাইসেন্স ও কৃতজ্ঞতা' : 'Licenses & Credits',
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
                    leading: const Icon(Icons.font_download_outlined),
                    title: Text(
                      isBn
                          ? 'ফন্ট লাইসেন্স (SIL Open Font License 1.1)'
                          : 'Font Licenses (SIL Open Font License 1.1)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Anek Bangla, Hind Siliguri, Newsreader, Noto Sans',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                              isBn ? 'ফন্ট লাইসেন্স' : 'Font Licenses (OFL)'),
                          content: SingleChildScrollView(
                            child: Text(
                              isBn
                                  ? 'MyLaws-এ ব্যবহৃত ফন্টসমূহ:\n\n'
                                      '• Anek Bangla (Ek Type, SIL OFL 1.1)\n'
                                      '• Hind Siliguri (Indian Type Foundry, SIL OFL 1.1)\n'
                                      '• Newsreader (Production Type, SIL OFL 1.1)\n'
                                      '• Noto Sans Bengali (Google Fonts, SIL OFL 1.1)\n\n'
                                      'সকল ফন্ট উন্মুক্ত উৎসের এবং SIL Open Font License 1.1-এর অধীনে সংরক্ষিত।'
                                  : 'Fonts used in MyLaws:\n\n'
                                      '• Anek Bangla (Ek Type, SIL OFL 1.1)\n'
                                      '• Hind Siliguri (Indian Type Foundry, SIL OFL 1.1)\n'
                                      '• Newsreader (Production Type, SIL OFL 1.1)\n'
                                      '• Noto Sans Bengali (Google Fonts, SIL OFL 1.1)\n\n'
                                      'All fonts are open-source and distributed under SIL Open Font License 1.1.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(isBn ? 'ঠিক আছে' : 'OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: Text(
                      isBn ? 'ওপেন সোর্স লাইব্রেরিসমূহ' : 'Open Source Libraries',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Flutter, Riverpod, Drift SQLite, GoRouter, PDF',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'MyLaws',
                        applicationVersion: '1.0.0-pilot',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Footer
            Center(
              child: Text(
                isBn
                    ? '© ২০২৬ MyLaws • নাগরিক আইনি অধিকার সুরক্ষা'
                    : '© 2026 MyLaws • Empowering Citizen Legal Rights',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ext.onSurfaceVariant.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, Color color, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildHelplineRow({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(
      String label, String value, AppThemeExtension ext, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: ext.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
