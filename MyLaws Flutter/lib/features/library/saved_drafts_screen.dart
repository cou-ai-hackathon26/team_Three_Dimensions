import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/widgets/app_bar_shell.dart';
import '../../core/widgets/confirm_sheet.dart';
import '../../domain/models/draft_document.dart';
import '../drafts/draft_editor_screen.dart';

/// Comprehensive Bangladesh Legal Drafts & Applications Hub
///
/// Features:
/// 1. Tab 0: 10 Official Bangladesh Legal Draft Templates with categories & 1-click creation
/// 2. Tab 1: User's Saved Drafts & Applications from local encrypted database
class SavedDraftsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const SavedDraftsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<SavedDraftsScreen> createState() => _SavedDraftsScreenState();
}

class _SavedDraftsScreenState extends ConsumerState<SavedDraftsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.gd:
        return Icons.local_police_outlined;
      case DocumentType.cheque_dishonour:
        return Icons.receipt_long_outlined;
      case DocumentType.dife:
        return Icons.work_outline_rounded;
      case DocumentType.dncrp:
        return Icons.shopping_bag_outlined;
      case DocumentType.domestic_violence:
        return Icons.health_and_safety_outlined;
      case DocumentType.family_maintenance:
        return Icons.favorite_border_rounded;
      case DocumentType.land_mutation:
        return Icons.edit_location_alt_outlined;
      case DocumentType.land_crime_complaint:
        return Icons.warning_amber_rounded;
      case DocumentType.possession_recovery:
        return Icons.home_work_outlined;
      case DocumentType.bail_petition:
        return Icons.gavel_rounded;
    }
  }

  void _startDrafting(BuildContext context, DocumentType type) {
    HapticFeedback.lightImpact();
    final freshDraft = DraftDocument.createDefault(type: type);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DraftEditorScreen(
          type: type,
          initialDraft: freshDraft,
        ),
      ),
    );
  }

  List<DocumentType> _getFilteredTemplates() {
    if (_selectedCategory == 'all') {
      return DocumentType.values;
    }
    switch (_selectedCategory) {
      case 'court':
        return [
          DocumentType.bail_petition,
          DocumentType.domestic_violence,
          DocumentType.family_maintenance,
          DocumentType.possession_recovery,
        ];
      case 'land':
        return [
          DocumentType.land_mutation,
          DocumentType.land_crime_complaint,
          DocumentType.possession_recovery,
        ];
      case 'notice':
        return [
          DocumentType.cheque_dishonour,
        ];
      case 'labour_consumer':
        return [
          DocumentType.dife,
          DocumentType.dncrp,
        ];
      case 'police':
        return [
          DocumentType.gd,
        ];
      default:
        return DocumentType.values;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final isBn = settings.appLanguage == 'bn';
    final draftsAsync = ref.watch(savedDraftsProvider);

    final bronzePrimary =
        isDark ? const Color(0xFFE0BA7A) : const Color(0xFF7A5420);
    final bronzeContainer =
        isDark ? const Color(0xFF2E2417) : const Color(0xFFF7F2E7);
    final cardBorder =
        isDark ? const Color(0xFF38312B) : const Color(0xFFE2DDD1);

    return Scaffold(
      backgroundColor: ext.surface,
      appBar: AppBarShell(
        title: isBn ? 'আইনি খসড়া ও আবেদন' : 'Legal Drafts & Applications',
        showBack: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Styled Dual-Tab Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bronzeContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3D3222)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: bronzePrimary,
                unselectedLabelColor: ext.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Anek Bangla',
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description_outlined, size: 15),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isBn ? 'টেমপ্লেট (১০)' : 'Templates (10)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_outline_rounded, size: 15),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isBn ? 'সংরক্ষিত খসড়া' : 'Saved Drafts',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: All 10 Standardized Legal Draft Templates
                  _buildTemplatesTab(
                    context: context,
                    isDark: isDark,
                    isBn: isBn,
                    bronzePrimary: bronzePrimary,
                    bronzeContainer: bronzeContainer,
                    cardBorder: cardBorder,
                  ),

                  // Tab 1: Saved User Drafts
                  _buildSavedDraftsTab(
                    context: context,
                    draftsAsync: draftsAsync,
                    isDark: isDark,
                    isBn: isBn,
                    bronzePrimary: bronzePrimary,
                    cardBorder: cardBorder,
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
  // TAB 0: ALL 10 OFFICIAL LEGAL DRAFT TEMPLATES
  // =========================================================================

  Widget _buildTemplatesTab({
    required BuildContext context,
    required bool isDark,
    required bool isBn,
    required Color bronzePrimary,
    required Color bronzeContainer,
    required Color cardBorder,
  }) {
    final ext = context.appTheme;
    final templates = _getFilteredTemplates();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // Informative Hero Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF2E261E), const Color(0xFF221D17)]
                  : [const Color(0xFFF7F2E7), const Color(0xFFEEE6D5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: bronzePrimary.withOpacity(0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bronzePrimary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.gavel_rounded, color: bronzePrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'বাংলাদেশ সংবিধিবদ্ধ ১০টি অফিসিয়াল আইনি ড্রাফট'
                          : '10 Statutory Bangladesh Legal Draft Templates',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFF7F5F0)
                            : const Color(0xFF161512),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBn
                          ? 'যেকোনো আইনি নোটিশ, দরখাস্ত বা আরজি নির্বাচন করে এখনই ড্রাফট প্রস্তুত করুন। তথ্য পূরণ শেষে সরাসরি প্রিন্ট-রেডি A4 PDF ডাউনলোড করা যাবে।'
                          : 'Select any standardized legal draft, fill in factual details, and export directly as a print-ready A4 PDF.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: ext.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', isBn ? 'সকল ড্রাফট (১০)' : 'All (10)',
                  bronzePrimary, isDark),
              _buildFilterChip(
                  'court',
                  isBn ? 'আদালত ও জামিন (৪)' : 'Court & Bail (4)',
                  bronzePrimary,
                  isDark),
              _buildFilterChip(
                  'land',
                  isBn ? 'জমিজমা ও নামজারি (৩)' : 'Land & Mutation (3)',
                  bronzePrimary,
                  isDark),
              _buildFilterChip(
                  'notice',
                  isBn ? 'আইনি নোটিশ (১)' : 'Legal Notice (1)',
                  bronzePrimary,
                  isDark),
              _buildFilterChip(
                  'labour_consumer',
                  isBn ? 'শ্রম ও ভোক্তা (২)' : 'Labour & Consumer (2)',
                  bronzePrimary,
                  isDark),
              _buildFilterChip(
                  'police',
                  isBn ? 'থানা ও জিডি (১)' : 'Police GD (1)',
                  bronzePrimary,
                  isDark),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // List of Templates
        ...templates.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          final icon = _getDocumentIcon(type);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E1A17) : const Color(0xFFFCF9F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: cardBorder),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _startDrafting(context, type),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Category Pill & Template Number
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: bronzePrimary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: bronzePrimary.withOpacity(0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 13, color: bronzePrimary),
                                const SizedBox(width: 5),
                                Text(
                                  isBn
                                      ? type.categoryLabelBn
                                      : type.categoryLabelEn,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: bronzePrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '#0${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ext.onSurfaceVariant.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Draft Title
                      Text(
                        isBn ? type.titleBn : type.titleEn,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          color: isDark
                              ? const Color(0xFFF7F5F0)
                              : const Color(0xFF161512),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Short Purpose Description
                      Text(
                        isBn ? type.shortDescBn : type.shortDescEn,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: ext.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Official Recipient Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.account_balance_outlined,
                              size: 14, color: ext.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isBn
                                  ? 'প্রাপক: ${type.recipientDefaultBn}'
                                  : 'Recipient: ${type.recipientDefaultEn}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: ext.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: bronzePrimary,
                            side: BorderSide(
                              color: bronzePrimary.withOpacity(0.8),
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.edit_document, size: 15),
                          label: Text(
                            isBn
                                ? '[ — খসড়া তৈরি শুরু করুন — ]'
                                : '[ — Start Drafting — ]',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          onPressed: () => _startDrafting(context, type),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip(
      String key, String label, Color bronzePrimary, bool isDark) {
    final isSelected = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? (isDark ? const Color(0xFF1E1A17) : Colors.white)
              : bronzePrimary,
        ),
        backgroundColor: Colors.transparent,
        selectedColor: bronzePrimary,
        side: BorderSide(
          color: isSelected ? bronzePrimary : bronzePrimary.withOpacity(0.35),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategory = key;
          });
        },
      ),
    );
  }

  // =========================================================================
  // TAB 1: USER'S SAVED DRAFTS
  // =========================================================================

  Widget _buildSavedDraftsTab({
    required BuildContext context,
    required AsyncValue<List<DraftDocument>> draftsAsync,
    required bool isDark,
    required bool isBn,
    required Color bronzePrimary,
    required Color cardBorder,
  }) {
    final ext = context.appTheme;

    return draftsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            err.toString(),
            style: TextStyle(color: ext.critical),
          ),
        ),
      ),
      data: (drafts) {
        if (drafts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: bronzePrimary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      size: 40,
                      color: bronzePrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isBn
                        ? 'আপনার এখনও কোনো সংরক্ষিত খসড়া নেই'
                        : 'No Saved Drafts Yet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn
                        ? 'আপনার তৈরি করা সব খসড়া ও আবেদন এখানে সুরক্ষিত থাকবে। ১০টি অফিসিয়াল টেমপ্লেট থেকে যেকোনো একটি বেছে নিয়ে এখনই তৈরি শুরু করুন।'
                        : 'All your custom drafts will be saved here securely. Select any of the 10 official templates to begin drafting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: ext.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bronzePrimary,
                      foregroundColor:
                          isDark ? const Color(0xFF1E1A17) : Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: Text(
                      isBn
                          ? '১০টি অফিসিয়াল টেমপ্লেট ব্রাউজ করুন'
                          : 'Browse 10 Official Templates',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => _tabController.animateTo(0),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: drafts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final draft = drafts[index];
            final isReviewed = draft.status == DraftStatus.reviewed;
            final icon = _getDocumentIcon(draft.type);

            return Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E1A17) : const Color(0xFFFCF9F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: cardBorder),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DraftEditorScreen(
                        initialDraft: draft,
                        type: draft.type,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: bronzePrimary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 13, color: bronzePrimary),
                                const SizedBox(width: 4),
                                Text(
                                  isBn
                                      ? draft.type.categoryLabelBn
                                      : draft.type.categoryLabelEn,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: bronzePrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isReviewed
                                  ? ext.verified.withOpacity(0.15)
                                  : ext.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isReviewed
                                      ? Icons.check_circle_outline
                                      : Icons.edit_note,
                                  size: 14,
                                  color:
                                      isReviewed ? ext.verified : ext.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isReviewed
                                      ? (isBn ? 'পর্যালোচিত' : 'Reviewed')
                                      : (isBn ? 'খসড়া চলমান' : 'In Progress'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isReviewed
                                        ? ext.verified
                                        : ext.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: ext.onSurfaceVariant,
                            onPressed: () async {
                              final confirmed = await ConfirmSheet.show(
                                context,
                                title: isBn
                                    ? 'খসড়া মুছে ফেলবেন?'
                                    : 'Delete draft document?',
                                description: isBn
                                    ? 'এই খসড়া আবেদনটি স্থায়ীভাবে মুছে ফেলা হবে।'
                                    : 'This draft document will be permanently deleted.',
                                confirmLabel: isBn ? 'মুছে ফেলুন' : 'Delete',
                                isDestructive: true,
                              );
                              if (confirmed) {
                                await ref
                                    .read(draftRepositoryProvider)
                                    .deleteDraft(draft.id);
                                ref.invalidate(savedDraftsProvider);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        draft.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        draft.subject,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: ext.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (draft.officeName.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.account_balance_outlined,
                                size: 14, color: ext.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                draft.officeName,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: ext.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
