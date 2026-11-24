import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/confirm_sheet.dart';
import '../../domain/models/draft_document.dart';
import '../../domain/models/fact.dart';
import 'draft_preview_page.dart';
import 'pdf_export_service.dart';

class DraftEditorScreen extends ConsumerStatefulWidget {
  final DocumentType type;
  final String? existingDraftId;
  final DraftDocument? initialDraft;

  const DraftEditorScreen({
    super.key,
    required this.type,
    this.existingDraftId,
    this.initialDraft,
  });

  @override
  ConsumerState<DraftEditorScreen> createState() => _DraftEditorScreenState();
}

class _DraftEditorScreenState extends ConsumerState<DraftEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  bool _isReviewed = false;
  bool _isDirty = false;
  DraftDocument? _currentDoc;
  bool _isLoading = true;

  static const Map<String, (String bn, String en, bool required)> fieldDefs = {
    'name': ('আবেদনকারী / বাদীর নাম', 'Applicant / Plaintiff name', true),
    'contact': ('মোবাইল নম্বর', 'Phone / Contact', true),
    'address': ('বর্তমান ঠিকানা', 'Current address', true),
    'recipient': (
      'প্রাপক ও অধিক্ষেত্র (যাচাই করুন)',
      'Recipient authority & jurisdiction',
      true
    ),
    'respondent': (
      'প্রতিপক্ষ / বিবাদীর নাম ও ঠিকানা',
      'Respondent / Defendant details',
      false
    ),
    'place': (
      'ঘটনা / কর্মস্থল / নালিশি সম্পত্তির অবস্থান',
      'Place of incident / property',
      true
    ),
    'date': ('ঘটনার তারিখ ও সময়', 'Incident date & time', true),
    'khatianDag': (
      'খতিয়ান, দাগ, মৌজা ও ভূমির পরিমাণ',
      'Khatian, Dag, Mouza & area',
      false
    ),
    'chequeNo': (
      'চেকের নম্বর, তারিখ ও ব্যাংক (NI Act 138)',
      'Cheque number, date & bank',
      true
    ),
    'dishonourDate': (
      'চেক ডিজঅনারের তারিখ (NI Act 138)',
      'Date of bank dishonour memo',
      true
    ),
    'caseNo': (
      'মামলা / জিআর / এফআইআর নং (CrPC)',
      'Case / GR / FIR number',
      true
    ),
    'sections': (
      'অভিযোগের পেনাল ধারা (CrPC)',
      'Charged penal code sections',
      true
    ),
    'role': (
      'পদবী ও চাকরির সময়কাল (DIFE)',
      'Designation & employment period',
      false
    ),
    'period': (
      'বকেয়া মজুরির সময়কাল (DIFE)',
      'Period of unpaid salary',
      false
    ),
    'amount': (
      'দাবিকৃত / বকেয়া টাকার পরিমাণ',
      'Claimed / unpaid amount (BDT)',
      false
    ),
    'chronology': ('ঘটনার বিস্তারিত বিবরণ', 'Factual chronology', true),
    'assistance': (
      'কী সহায়তা / প্রতিকার চান',
      'Relief / assistance requested',
      true
    ),
    'attachments': (
      'সংযুক্ত প্রমাণাদি (যদি থাকে)',
      'List of attachments',
      false
    ),
    'applicationDate': ('আবেদনের তারিখ', 'Application date', true),
  };

  bool _isFieldApplicable(String key, DocumentType type) {
    switch (key) {
      case 'chequeNo':
      case 'dishonourDate':
        return type == DocumentType.cheque_dishonour;
      case 'caseNo':
      case 'sections':
        return type == DocumentType.bail_petition;
      case 'role':
      case 'period':
        return type == DocumentType.dife;
      case 'khatianDag':
        return type == DocumentType.land_mutation ||
            type == DocumentType.land_crime_complaint ||
            type == DocumentType.possession_recovery;
      case 'respondent':
        return type != DocumentType.land_mutation;
      case 'amount':
        return type == DocumentType.domestic_violence ||
            type == DocumentType.family_maintenance ||
            type == DocumentType.dife ||
            type == DocumentType.dncrp ||
            type == DocumentType.cheque_dishonour;
      default:
        return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialDraft();
  }

  Future<void> _loadInitialDraft() async {
    final draftRepo = ref.read(draftRepositoryProvider);
    final activeFacts = ref.read(conversationProvider).facts;

    try {
      final doc = widget.initialDraft ??
          await draftRepo.prepareDraft(
            type: widget.type,
            facts: activeFacts,
            id: widget.existingDraftId,
          );

      _currentDoc = doc;

      // Populate text controllers
      for (final entry in fieldDefs.entries) {
        final fact = doc.facts.firstOrNullWhere((f) => f.fieldId == entry.key);
        var initialText = fact?.value?.toString() ?? '';
        if (initialText.isEmpty && entry.key == 'recipient') {
          initialText = doc.recipient.isNotEmpty
              ? doc.recipient
              : widget.type.recipientDefaultBn;
        }
        _controllers[entry.key] = TextEditingController(text: initialText);
      }

      // Default application date to today if empty
      if (_controllers['applicationDate']!.text.isEmpty) {
        final now = DateTime.now();
        _controllers['applicationDate']!.text =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<Fact> _buildFactsFromInputs() {
    return _controllers.entries.map((e) {
      return Fact(
        fieldId: e.key,
        value: e.value.text.trim(),
        status: e.value.text.trim().isNotEmpty
            ? FactStatus.userConfirmed
            : FactStatus.unknown,
        provenance: 'draft_editor',
      );
    }).toList();
  }

  Future<void> _refreshDocument() async {
    final factsList = _buildFactsFromInputs();
    final factsMap = <String, String>{};
    for (final f in factsList) {
      if (f.value != null && f.value.toString().isNotEmpty) {
        factsMap[f.fieldId] = f.value.toString();
      }
    }

    final unresolved = <String>[];
    final recipientInput = _controllers['recipient']?.text.trim();
    final paragraphs = DraftDocument.getTemplateParagraphs(
      widget.type,
      factsMap: factsMap,
      recipientOverride: recipientInput,
      unresolvedCollector: unresolved,
    );

    setState(() {
      _currentDoc = (_currentDoc ??
              DraftDocument.createDefault(
                type: widget.type,
                id: widget.existingDraftId,
              ))
          .copyWith(
        facts: factsList,
        recipient: (recipientInput != null && recipientInput.isNotEmpty)
            ? recipientInput
            : widget.type.recipientDefaultBn,
        paragraphs: paragraphs,
        unresolvedPlaceholders: unresolved,
        reviewStatus: _isReviewed ? 'reviewed' : 'incomplete',
        body: paragraphs.join('\n\n'),
        subject: paragraphs.length > 5 ? paragraphs[5] : widget.type.titleBn,
        applicantName: _controllers['name']?.text.trim(),
        applicantPhone: _controllers['contact']?.text.trim(),
        applicantAddress: _controllers['address']?.text.trim(),
        officeName: recipientInput,
      );
    });
  }

  Future<void> _saveDraftLocally() async {
    await _refreshDocument();
    if (_currentDoc != null) {
      await ref.read(draftRepositoryProvider).saveDraft(_currentDoc!);
      ref.invalidate(savedDraftsProvider);
      setState(() {
        _isDirty = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'খসড়াটি ডিভাইসে সংরক্ষিত হয়েছে / Draft saved locally')),
        );
      }
    }
  }

  DraftDocument _buildUpdatedDocument() {
    final factsList = _buildFactsFromInputs();
    final factsMap = <String, String>{};
    for (final f in factsList) {
      if (f.value != null && f.value.toString().isNotEmpty) {
        factsMap[f.fieldId] = f.value.toString();
      }
    }

    final unresolved = <String>[];
    final recipientInput = _controllers['recipient']?.text.trim();
    final paragraphs = DraftDocument.getTemplateParagraphs(
      widget.type,
      factsMap: factsMap,
      recipientOverride: recipientInput,
      unresolvedCollector: unresolved,
    );

    final current = _currentDoc ??
        DraftDocument.createDefault(
          type: widget.type,
          id: widget.existingDraftId,
          recipientOverride: recipientInput,
        );

    return current.copyWith(
      facts: factsList,
      recipient: (recipientInput != null && recipientInput.isNotEmpty)
          ? recipientInput
          : widget.type.recipientDefaultBn,
      paragraphs: paragraphs,
      unresolvedPlaceholders: unresolved,
      reviewStatus: _isReviewed ? 'reviewed' : 'incomplete',
      body: paragraphs.join('\n\n'),
      subject: paragraphs.length > 5 ? paragraphs[5] : widget.type.titleBn,
      applicantName: _controllers['name']?.text.trim(),
      applicantPhone: _controllers['contact']?.text.trim(),
      applicantAddress: _controllers['address']?.text.trim(),
      officeName: recipientInput,
    );
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final discard = await ConfirmSheet.show(
      context,
      title: 'খসড়া পরিবর্তন বাতিল করবেন?',
      message: 'আপনার পরিবর্তনগুলো সংরক্ষণ না করে ফিরে গেলে তা হারিয়ে যাবে।',
      confirmLabel: 'পরিবর্তন বাতিল',
      cancelLabel: 'সম্পাদনা চালিয়ে যান',
      isDestructive: true,
    );
    return discard;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBangla = ref.watch(settingsProvider).appLanguage == 'bn';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.type.titleBn)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_isDirty,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isBangla ? widget.type.titleBn : widget.type.titleEn),
          bottom: TabBar(
            controller: _tabController,
            labelColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            indicatorColor:
                isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            tabs: [
              Tab(
                  icon: const Icon(Icons.edit_note),
                  text: isBangla ? 'তথ্য সম্পাদনা' : 'Edit Facts'),
              Tab(
                  icon: const Icon(Icons.preview_outlined),
                  text: isBangla ? 'নথি দেখুন (A4)' : 'Preview (A4)'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: isBangla ? 'সংরক্ষণ' : 'Save',
              onPressed: _saveDraftLocally,
            ),
          ],
        ),
        body: Column(
          children: [
            // Persistent Notice per Section 6 S10
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark
                  ? AppColors.darkPrimaryContainer
                  : AppColors.lightPrimaryContainer,
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBangla
                          ? 'এটি শুধু প্রস্তুতির খসড়া। এটি কোনো সরকারি দপ্তরে দাখিল করা হয়নি।'
                          : 'Preparation draft only. This has NOT been submitted to any authority.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFactsEditor(isDark, isBangla),
                  _buildPreviewTab(isDark, isBangla),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactsEditor(bool isDark, bool isBangla) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isBangla
              ? 'খসড়া সম্পন্ন করতে নিচের তথ্যগুলো যাচাই ও পূরণ করুন:'
              : 'Review and complete the following facts for the draft:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 16),
        ...fieldDefs.entries.map((entry) {
          final key = entry.key;
          if (!_isFieldApplicable(key, widget.type)) {
            return const SizedBox.shrink();
          }

          final (labelBn, labelEn, _) = entry.value;
          final isRequired = widget.type.requiredFieldKeys.contains(key);
          final label = isBangla ? labelBn : labelEn;
          final ctrl = _controllers[key]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    if (isRequired)
                      const Text(' *',
                          style: TextStyle(
                              color: AppColors.lightError,
                              fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: ctrl,
                  maxLines: key == 'chronology' ? 4 : 1,
                  onChanged: (val) {
                    setState(() {
                      _isDirty = true;
                      _isReviewed =
                          false; // Reset review checkbox on edit per Prompt 01 S10
                    });
                  },
                  decoration: InputDecoration(
                    hintText: isBangla ? '$label লিখুন...' : 'Enter $label...',
                    isDense: true,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: Text(isBangla ? 'খসড়া প্রিভিউ দেখুন' : 'View A4 Preview'),
          onPressed: () {
            _refreshDocument();
            _tabController.animateTo(1);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPreviewTab(bool isDark, bool isBangla) {
    if (_currentDoc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final doc = _currentDoc!;
    final canExport = doc.unresolvedPlaceholders.isEmpty && _isReviewed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A4 Paginated Document Container
          DraftPreviewPage(
            document: doc,
            isBangla: isBangla,
          ),
          const SizedBox(height: 16),

          // Review Checkbox
          CheckboxListTile(
            value: _isReviewed,
            activeColor:
                isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            contentPadding: EdgeInsets.zero,
            title: Text(
              isBangla
                  ? 'আমি খসড়ার সকল তথ্য, তারিখ ও প্রাপকের নাম পড়ে যাচাই করেছি।'
                  : 'I have reviewed all facts, dates, and recipient details.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            onChanged: (val) {
              setState(() {
                _isReviewed = val ?? false;
              });
            },
          ),
          const SizedBox(height: 16),

          // Export Action Buttons (Disabled until reviewed & complete per Prompt 01 S10)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(isBangla ? 'কপি' : 'Copy'),
                  onPressed: () {
                    final plain = doc.paragraphs.join('\n\n');
                    Clipboard.setData(ClipboardData(text: plain));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              isBangla ? 'টেক্সট কপি হয়েছে' : 'Text copied')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.print, size: 16),
                  label: Text(isBangla ? 'প্রিন্ট' : 'Print'),
                  onPressed: canExport
                      ? () {
                          final currentDraft = _buildUpdatedDocument();
                          PdfExportService.printPdf(currentDraft);
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: Text(isBangla ? 'পিডিএফ' : 'PDF'),
                  onPressed: canExport
                      ? () {
                          final currentDraft = _buildUpdatedDocument();
                          PdfExportService.sharePdf(currentDraft);
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

extension on List<Fact> {
  Fact? firstOrNullWhere(bool Function(Fact) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
