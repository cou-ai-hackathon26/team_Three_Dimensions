import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/widgets/app_bar_shell.dart';
import '../../core/widgets/confirm_sheet.dart';
import '../../domain/models/pack_state.dart';
import 'local_model_provider.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  bool _isCheckingUpdate = false;

  void _checkForUpdates() async {
    setState(() => _isCheckingUpdate = true);
    try {
      await ref.read(packRepositoryProvider).checkForUpdates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('আইন প্যাকেজ হালনাগাদ যাচাই সম্পন্ন হয়েছে।'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdate = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final settings = ref.watch(settingsProvider);
    final isBn = settings.appLanguage == 'bn';
    final packAsync = ref.watch(packStateProvider);

    final pack = packAsync.value ??
        const PackState(
          id: 'bd-pilot-2026-10-27.1',
          legalVersion: '2026-10-26-corpus-v1',
          status: InstallStatus.ready,
          coverage: ['labour', 'cyber', 'consumer', 'property'],
          sizeBytes: 35 * 1024 * 1024,
          completedBytes: 35 * 1024 * 1024,
        );

    final isLegalPackReady = pack.status == InstallStatus.ready;
    final localModel = ref.watch(localAiModelProvider);
    final isLocalModelReady = localModel.status == InstallStatus.ready;

    return Scaffold(
      appBar: AppBarShell(
        title: isBn ? 'ডাউনলোড ও অফলাইন সেন্টার' : 'Downloads & Offline Center',
        showBack: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ext.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLocalModelReady
                      ? ext.verified.withValues(alpha: 0.4)
                      : ext.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isLocalModelReady || isLegalPackReady
                        ? Icons.offline_pin
                        : Icons.cloud_download_outlined,
                    color: isLocalModelReady || isLegalPackReady
                        ? ext.verified
                        : ext.secondary,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLocalModelReady && isLegalPackReady
                              ? (isBn
                                  ? 'অফলাইন এআই ও আইনি ডেটাবেজ প্রস্তুত'
                                  : 'Offline AI & Legal Database Ready')
                              : (isBn
                                  ? 'অফলাইন অনুসন্ধান প্রস্তুতি'
                                  : 'Offline Readiness'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ext.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLocalModelReady && isLegalPackReady
                              ? (isBn
                                  ? 'লোকাল এআই মডেল সক্রিয়। ইন্টারনেট ছাড়াই স্বাভাবিক ভাষায় আইনি সমাধান ও আবেদনপত্র প্রস্তুত হবে।'
                                  : 'Local AI Model active. Conversational advice & drafted complaints work completely offline.')
                              : (isLegalPackReady
                                  ? (isBn
                                      ? 'আইনি ডেটাবেজ সংরক্ষিত। ইন্টারনেট ছাড়া ধারা ও অফিস পাওয়া যাবে।'
                                      : 'Legal database ready. Sections and offices work offline.')
                                  : (isBn
                                      ? 'আইন প্যাকেজ ডাউনলোড করা হয়নি।'
                                      : 'Legal pack is not downloaded yet.')),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ext.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 1: Legal Pack (~35 MB)
            _buildCard(
              context: context,
              ext: ext,
              theme: theme,
              title: isBn
                  ? 'বাংলাদেশ আইনি প্যাকেজ (কোর)'
                  : 'Bangladesh Legal Pack (Core)',
              subtitle: isBn
                  ? 'শ্রম আইন, দণ্ডবিধি, ভোক্তা অধিকার, সাইবার আইন ও সরকারি অফিসের সম্পূর্ণ ডিরেক্টরি।'
                  : 'Labour law, Penal Code, Consumer Protection, Cyber Act & official directory.',
              sizeLabel: isLegalPackReady ? '৩৫.৪ মেগাবাইট (MB)' : '৩৫.৪ MB',
              versionLabel: 'সংস্করণ ${pack.legalVersion}',
              isInstalled: isLegalPackReady,
              isDownloading: pack.status == InstallStatus.downloading,
              downloadProgress: pack.downloadProgress,
              onInstall: () => ref.read(packRepositoryProvider).installPack(),
              onRemove: () async {
                final confirmed = await ConfirmSheet.show(
                  context,
                  title:
                      isBn ? 'আইন প্যাকেজ অপসারণ করবেন?' : 'Remove Legal Pack?',
                  description: isBn
                      ? 'অফলাইনে ধারা ও সরকারি অফিসের তথ্য আর দেখা যাবে না।'
                      : 'Statutory sections and office data will not be available offline.',
                  confirmLabel: isBn ? 'অপসারণ করুন' : 'Remove',
                  isDestructive: true,
                );
                if (confirmed) {
                  await ref.read(packRepositoryProvider).removePack();
                }
              },
            ),
            const SizedBox(height: 16),

            // Card 2: Local AI Model (808 MB)
            _buildLocalModelCard(
              context: context,
              ext: ext,
              theme: theme,
              localModel: localModel,
              isBn: isBn,
            ),
            const SizedBox(height: 16),

            // Storage & Offline Transparency Info Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ext.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: ext.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: ext.primary),
                      const SizedBox(width: 8),
                      Text(
                        isBn
                            ? 'স্টোরেজ ও অফলাইন স্বচ্ছতা'
                            : 'Storage & Offline Transparency',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ext.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn
                        ? '• মূল অ্যাপ (~৯০ MB): এতে বাংলাদেশ শ্রম আইন, দণ্ডবিধি, ভোক্তা অধিকার, সাইবার নিরাপত্তা, জমি ও পারিবারিক আইনের সম্পূর্ণ সংবিধিবদ্ধ ধারা এবং অভিযোগ ড্রাফটিং ইঞ্জিন অন্তর্ভুক্ত রয়েছে, যা কোনো অতিরিক্ত ডাউনলোড ছাড়াই ১০০% অফলাইনে নিখুঁত কাজ করে।\n• অন-ডিভাইস LLM মডেল: এটি মুক্ত স্বাভাবিক ভাষার কথোপকথনের জন্য একটি ঐচ্ছিক সুবিধা। সম্পূর্ণ ডাউনলোড সম্পন্ন হলে তবেই ফোনের মেমোরিতে (~৪৬৮ MB) যোগ হবে এবং যেকোনো সময় "অপসারণ" চেপে মেমোরি খালি করা যায়।'
                        : '• Base App (~90 MB): Includes the entire Bangladesh legal statutory provisions and complaint drafting engine, working 100% offline with zero additional downloads.\n• On-Device LLM Model: Optional for open-ended conversational AI. Only takes phone storage (~468 MB) when downloaded to ROM, and can be removed at any time.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Wi-Fi Only Policy Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ext.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ext.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi, size: 20, color: ext.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'সেটিংসে "শুধুমাত্র ওয়াইফাই" চালু থাকলে মোবাইল ডেটায় বড় ফাইল ডাউনলোড হবে না।'
                          : 'Large downloads will not run over mobile data when "Wi-Fi only" is enabled in Settings.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Check for updates button
            OutlinedButton.icon(
              icon: _isCheckingUpdate
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                isBn ? 'হালনাগাদ যাচাই করুন' : 'Check for Updates',
              ),
              onPressed: _isCheckingUpdate ? null : _checkForUpdates,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalModelCard({
    required BuildContext context,
    required AppThemeExtension ext,
    required ThemeData theme,
    required LocalAiModelState localModel,
    required bool isBn,
  }) {
    final isReady = localModel.status == InstallStatus.ready;
    final isDownloading = localModel.status == InstallStatus.downloading;
    final isPaused = localModel.status == InstallStatus.paused;
    final isPro = localModel.modelId == AppConfig.localModelProId;
    final modelSizeMb = (localModel.totalBytes / (1024 * 1024)).toStringAsFixed(0);

    Color badgeBg;
    Color badgeFg;
    String badgeText;

    if (isReady) {
      badgeBg = ext.verified.withValues(alpha: 0.15);
      badgeFg = ext.verified;
      badgeText = isBn ? '✓ ইনস্টল ও সক্রিয়' : '✓ Installed & Active';
    } else if (isDownloading) {
      badgeBg = ext.primary.withValues(alpha: 0.15);
      badgeFg = ext.primary;
      badgeText = isBn ? 'ডাউনলোড হচ্ছে...' : 'Downloading...';
    } else if (isPaused) {
      badgeBg = const Color(0xFFD97706).withValues(alpha: 0.15);
      badgeFg = const Color(0xFFD97706);
      badgeText = isBn ? 'স্থগিত (পজ)' : 'Paused';
    } else {
      badgeBg = ext.surfaceContainer;
      badgeFg = ext.secondary;
      badgeText = isBn ? 'ঐচ্ছিক • অন-ডিভাইস' : 'Optional • On-Device';
    }

    return Card(
      elevation: 0,
      color: ext.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ext.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Status Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    isBn
                        ? 'লোকাল এআই মডেল (অন-ডিভাইস LLM)'
                        : 'Local AI Model (On-Device LLM)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ext.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: badgeFg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              isBn
                  ? 'ইন্টারনেট সংযোগ সম্পূর্ণ বন্ধ থাকলেও সরাসরি আপনার ফোনের নিউরাল প্রসেসিং দিয়ে স্বাভাবিক ভাষায় আইনি বিশ্লেষণ ও আবেদনপত্র তৈরি করবে।'
                  : 'Generates conversational legal answers and drafted complaints completely offline using local on-device neural processing.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ext.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // Model Tier Selector (Light vs Pro)
            if (!isDownloading && !isPaused) ...[
              Text(
                isBn ? 'আপনার ডিভাইসের মডেল নির্বাচন করুন:' : 'Select Model Tier for Your Device:',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ext.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Light Model (Qwen 2.5) Option
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => ref
                          .read(localAiModelProvider.notifier)
                          .selectModelTier(isPro: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: !isPro
                              ? ext.primary.withValues(alpha: 0.12)
                              : ext.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: !isPro ? ext.primary : ext.outlineVariant,
                            width: !isPro ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  !isPro
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 15,
                                  color: !isPro ? ext.primary : ext.secondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isBn ? 'লাইট (Qwen 2.5)' : 'Light (Qwen 2.5)',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: !isPro ? ext.primary : ext.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isBn ? '৪৬৮ MB • ২-৪ GB RAM' : '468 MB • 2-4 GB RAM',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: ext.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Pro Model (LLaMA 3.2) Option
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => ref
                          .read(localAiModelProvider.notifier)
                          .selectModelTier(isPro: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isPro
                              ? ext.primary.withValues(alpha: 0.12)
                              : ext.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPro ? ext.primary : ext.outlineVariant,
                            width: isPro ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPro
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 15,
                                  color: isPro ? ext.primary : ext.secondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isBn ? 'প্রো (LLaMA 3.2)' : 'Pro (LLaMA 3.2)',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isPro ? ext.primary : ext.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isBn ? '৮০৮ MB • ৬+ GB RAM' : '808 MB • 6+ GB RAM',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: ext.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Detailed Specs & Metadata
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storage_outlined,
                        size: 15, color: ext.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Text(
                      isBn ? '$modelSizeMb মেগাবাইট (MB)' : '$modelSizeMb MB',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ext.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isReady
                          ? Icons.check_circle_outline
                          : (localModel.diskSizeBytes > 0
                              ? Icons.hourglass_top_outlined
                              : Icons.sd_storage_outlined),
                      size: 15,
                      color: isReady
                          ? ext.verified
                          : (localModel.diskSizeBytes > 0
                              ? const Color(0xFFD97706)
                              : ext.onSurfaceVariant),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isReady
                          ? (isBn
                              ? 'স্টোরেজ: ${(localModel.diskSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB সংরক্ষিত'
                              : 'Storage: ${(localModel.diskSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB on disk')
                          : (localModel.diskSizeBytes > 0
                              ? (isBn
                                  ? 'আংশিক সংরক্ষিত: ${(localModel.diskSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
                                  : 'Partially saved: ${(localModel.diskSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB')
                              : (isBn
                                  ? 'মেমোরি ব্যবহৃত: ০ MB'
                                  : 'Storage used: 0 MB')),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isReady
                            ? ext.verified
                            : (localModel.diskSizeBytes > 0
                                ? const Color(0xFFD97706)
                                : ext.onSurfaceVariant),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology_outlined,
                        size: 15, color: ext.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Text(
                      localModel.modelName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ext.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.memory_outlined,
                        size: 15, color: ext.onSurfaceVariant),
                    const SizedBox(width: 5),
                    Text(
                      localModel.ramRequirement,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ext.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Auto-Setup Confirmation Card (When ready)
            if (isReady) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: ext.verified.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ext.verified.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: ext.verified),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isBn
                            ? 'মডেলটি সফলভাবে সেটআপ ও সক্রিয় হয়েছে। এখন ইন্টারনেট ছাড়াই স্বাভাবিক কথ্য ভাষায় আইনি পরামর্শ ও খসড়া আবেদন তৈরি হবে।'
                            : 'Model is active. On-device conversational legal advice and drafts work completely offline.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ext.verified,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error notice banner
            if (localModel.errorMessage != null && localModel.errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localModel.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF991B1B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Progress & Speed Indicators (When downloading or paused)
            if (isDownloading || isPaused) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localModel.getProgressSummary(isBn: isBn),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPaused ? const Color(0xFFD97706) : ext.primary,
                    ),
                  ),
                  Text(
                    '${(localModel.progress * 100).toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPaused ? const Color(0xFFD97706) : ext.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: localModel.progress > 0 ? localModel.progress : null,
                  backgroundColor: ext.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation(
                    isPaused ? const Color(0xFFD97706) : ext.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                localModel.getRemainingText(isBn: isBn),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ext.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons: Download, Pause, Resume, Cancel, Remove
            Row(
              children: [
                // State: Not installed -> Start Download
                if (!isReady && !isDownloading && !isPaused)
                  FilledButton.icon(
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(isBn
                        ? 'ডাউনলোড শুরু করুন ($modelSizeMb MB)'
                        : 'Download ($modelSizeMb MB)'),
                    onPressed: () =>
                        ref.read(localAiModelProvider.notifier).startDownload(),
                  ),

                // State: Downloading -> Pause & Cancel options
                if (isDownloading) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.pause, size: 18),
                    label: Text(isBn ? 'বিরতি (পজ)' : 'Pause'),
                    onPressed: () =>
                        ref.read(localAiModelProvider.notifier).pauseDownload(),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: Icon(Icons.close, size: 18, color: ext.critical),
                    label: Text(
                      isBn ? 'বাতিল' : 'Cancel',
                      style: TextStyle(color: ext.critical),
                    ),
                    onPressed: () => ref
                        .read(localAiModelProvider.notifier)
                        .cancelDownload(),
                  ),
                ],

                // State: Paused -> Resume & Cancel options
                if (isPaused) ...[
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(isBn ? 'পুনরায় চালু (রিজিউম)' : 'Resume'),
                    onPressed: () => ref
                        .read(localAiModelProvider.notifier)
                        .resumeDownload(),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: Icon(Icons.close, size: 18, color: ext.critical),
                    label: Text(
                      isBn ? 'বাতিল' : 'Cancel',
                      style: TextStyle(color: ext.critical),
                    ),
                    onPressed: () => ref
                        .read(localAiModelProvider.notifier)
                        .cancelDownload(),
                  ),
                ],

                // State: Ready -> Installed badge + Remove button
                if (isReady) ...[
                  OutlinedButton.icon(
                    icon: Icon(Icons.check, size: 18, color: ext.verified),
                    label: Text(
                      isBn ? 'ইনস্টল সম্পন্ন' : 'Installed',
                      style: TextStyle(color: ext.verified),
                    ),
                    onPressed: null,
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: ext.critical),
                    label: Text(
                      isBn ? 'অপসারণ' : 'Remove',
                      style: TextStyle(color: ext.critical),
                    ),
                    onPressed: () async {
                      final confirmed = await ConfirmSheet.show(
                        context,
                        title: isBn
                            ? 'লোকাল এআই মডেল অপসারণ করবেন?'
                            : 'Remove Local AI Model?',
                        description: isBn
                            ? 'অফলাইনে স্বাভাবিক ভাষার কৃত্রিম বুদ্ধিমত্তা জেনারেশন আর কাজ করবে না। $modelSizeMb MB স্টোরেজ খালি হবে।'
                            : 'Offline natural AI generation will no longer be available. $modelSizeMb MB storage will be freed.',
                        confirmLabel: isBn ? 'অপসারণ করুন' : 'Remove',
                        isDestructive: true,
                      );
                      if (confirmed) {
                        ref.read(localAiModelProvider.notifier).removeModel();
                      }
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required AppThemeExtension ext,
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String sizeLabel,
    required String versionLabel,
    required bool isInstalled,
    required bool isDownloading,
    required double downloadProgress,
    String? badgeText,
    required VoidCallback onInstall,
    VoidCallback? onRemove,
  }) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.appLanguage == 'bn';

    return Card(
      elevation: 0,
      color: ext.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ext.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ext.onSurface,
                    ),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ext.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ext.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ext.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.storage_outlined,
                    size: 14, color: ext.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  sizeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ext.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.tag, size: 14, color: ext.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  versionLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ext.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (isDownloading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: downloadProgress > 0 ? downloadProgress : null,
                backgroundColor: ext.surfaceContainer,
                valueColor: AlwaysStoppedAnimation(ext.primary),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isInstalled && !isDownloading)
                  FilledButton.icon(
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(isBn ? 'ডাউনলোড করুন' : 'Download'),
                    onPressed: onInstall,
                  ),
                if (isInstalled)
                  OutlinedButton.icon(
                    icon: Icon(Icons.check, size: 18, color: ext.verified),
                    label: Text(
                      isBn ? 'ইনস্টল সম্পন্ন' : 'Installed',
                      style: TextStyle(color: ext.verified),
                    ),
                    onPressed: null,
                  ),
                if (isInstalled && onRemove != null) ...[
                  const SizedBox(width: 10),
                  TextButton.icon(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: ext.critical),
                    label: Text(
                      isBn ? 'অপসারণ' : 'Remove',
                      style: TextStyle(color: ext.critical),
                    ),
                    onPressed: onRemove,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
