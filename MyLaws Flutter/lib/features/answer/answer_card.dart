import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/legal_translation_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/source_chip.dart';
import '../../domain/models/answer_response.dart';
import '../../domain/models/checklist_step.dart';
import '../../domain/models/draft_document.dart';
import '../../domain/models/fact.dart';
import '../checklist/checklist_step_tile.dart';
import '../drafts/draft_editor_screen.dart';

/// Unified Legal Answer Card
///
/// Designed to present a seamless, single-container answer:
/// 1. Simple Plain Language Explanation & Citizen Rights (Step 3)
/// 2. Collapsible Drop-Down for Statutory Sources & Gazette Sections (Step 2)
/// 3. Sequential Action Checklist (Step 4)
/// 4. Formal Draft Preparation CTA (Step 4 Draft)
class AnswerCard extends StatefulWidget {
  final AnswerResponse response;
  final bool isBangla;
  final ValueChanged<String>? onChecklistToggled;
  final VoidCallback? onPrepareDraft;
  final bool animate;

  const AnswerCard({
    super.key,
    required this.response,
    required this.isBangla,
    this.onChecklistToggled,
    this.onPrepareDraft,
    this.animate = false,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  late bool _isBangla;
  late final bool _isOriginalBangla;
  bool _isTranslating = false;

  // Typewriter streaming state
  bool _isTypingComplete = true;
  int _displayedChars = 0;
  Timer? _typingTimer;

  // Alternate language translated fields
  String? _altMeaning;
  String? _altUnderstanding;
  String? _altWhatToDoNext;
  String? _altHeading;
  String? _altIssueTitle;
  List<String>? _altRights;
  List<String>? _altChecklist;
  String? _altDraftTitle;
  String? _altDraftDesc;
  bool _sourcesExpanded = false;
  bool _checklistExpanded = false;
  final Set<String> _completedStepIds = <String>{};

  @override
  void initState() {
    super.initState();
    final rawMeaning = widget.response.plainLanguageExplanation?.meaning ??
        (widget.response.explanation.isNotEmpty
            ? widget.response.explanation.map((e) => e.text).join('\n\n')
            : '');
    _isOriginalBangla = LegalTranslationService.hasBengali(rawMeaning);
    _isBangla = _isOriginalBangla;
    for (final s in widget.response.checklist) {
      if (s.completed) _completedStepIds.add(s.id);
    }
    if (widget.animate) {
      _isTypingComplete = false;
      _displayedChars = 0;
      _startTypewriter();
    } else {
      _isTypingComplete = true;
    }
  }

  void _startTypewriter() {
    _typingTimer?.cancel();
    final fullMeaning = _getActiveMeaning();
    if (fullMeaning.isEmpty) {
      _isTypingComplete = true;
      return;
    }
    _typingTimer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final currentFull = _getActiveMeaning();
      setState(() {
        _displayedChars += 2;
        if (_displayedChars >= currentFull.length) {
          _displayedChars = currentFull.length;
          _isTypingComplete = true;
          timer.cancel();
        }
      });
    });
  }

  void _skipTypewriter() {
    if (_isTypingComplete) return;
    _typingTimer?.cancel();
    setState(() {
      _isTypingComplete = true;
      _displayedChars = _getActiveMeaning().length;
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnswerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBangla != widget.isBangla && widget.isBangla != _isBangla) {
      _skipTypewriter();
      _toggleLanguage();
    }
    if (oldWidget.response.answerId != widget.response.answerId) {
      _sourcesExpanded = false;
      _checklistExpanded = false;
      _completedStepIds.clear();
      for (final s in widget.response.checklist) {
        if (s.completed) _completedStepIds.add(s.id);
      }
      if (widget.animate) {
        _isTypingComplete = false;
        _displayedChars = 0;
        _startTypewriter();
      } else {
        _isTypingComplete = true;
      }
    }
  }

  void _toggleChecklistStep(String stepId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_completedStepIds.contains(stepId)) {
        _completedStepIds.remove(stepId);
      } else {
        _completedStepIds.add(stepId);
      }
    });
    widget.onChecklistToggled?.call(stepId);
  }

  Future<void> _toggleLanguage() async {
    if (_isTranslating) return;
    HapticFeedback.selectionClick();
    final targetToBangla = !_isBangla;

    setState(() {
      _isTranslating = true;
    });

    try {
      final ple = widget.response.plainLanguageExplanation;
      final rawMeaning = ple?.meaning ??
          (widget.response.explanation.isNotEmpty
              ? widget.response.explanation.map((e) => e.text).join('\n\n')
              : '');
      final rawUnderstanding =
          widget.response.problemSummary?.understanding ?? '';
      final rawWhat = ple?.whatToDoNext ?? '';
      final rawHeading = ple?.heading ?? '';
      final rawRights = ple?.userRightsAndOptions ?? const <String>[];
      final rawChecklist =
          widget.response.checklist.map((c) => c.text).toList();
      final rawDraftTitle = widget.response.draftOffer?.documentTitle ?? '';
      final rawDraftDesc = widget.response.draftOffer?.description ?? '';
      final rawIssueTitle =
          widget.response.problemSummary?.identifiedIssue ?? '';

      final results = await Future.wait([
        if (rawMeaning.isNotEmpty)
          LegalTranslationService.translateAsync(rawMeaning,
              toBangla: targetToBangla)
        else
          Future.value(''),
        if (rawUnderstanding.isNotEmpty)
          LegalTranslationService.translateAsync(rawUnderstanding,
              toBangla: targetToBangla)
        else
          Future.value(''),
        if (rawWhat.isNotEmpty)
          LegalTranslationService.translateAsync(rawWhat,
              toBangla: targetToBangla)
        else
          Future.value(''),
        if (rawHeading.isNotEmpty)
          LegalTranslationService.translateAsync(rawHeading,
              toBangla: targetToBangla)
        else
          Future.value(''),
        if (rawDraftTitle.isNotEmpty)
          LegalTranslationService.translateAsync(rawDraftTitle,
              toBangla: targetToBangla)
        else
          Future.value(''),
        if (rawDraftDesc.isNotEmpty)
          LegalTranslationService.translateAsync(rawDraftDesc,
              toBangla: targetToBangla)
        else
          Future.value(''),
        if (rawIssueTitle.isNotEmpty)
          LegalTranslationService.translateAsync(rawIssueTitle,
              toBangla: targetToBangla)
        else
          Future.value(''),
      ]);

      List<String>? translatedRights;
      if (rawRights.isNotEmpty) {
        translatedRights = await Future.wait(rawRights.map((r) =>
            LegalTranslationService.translateAsync(r,
                toBangla: targetToBangla)));
      }

      List<String>? translatedChecklist;
      if (rawChecklist.isNotEmpty) {
        translatedChecklist = await Future.wait(rawChecklist.map((c) =>
            LegalTranslationService.translateAsync(c,
                toBangla: targetToBangla)));
      }

      if (mounted) {
        setState(() {
          _isBangla = targetToBangla;
          _isTranslating = false;
          _altMeaning = results[0].isNotEmpty ? results[0] : null;
          _altUnderstanding = results[1].isNotEmpty ? results[1] : null;
          _altWhatToDoNext = results[2].isNotEmpty ? results[2] : null;
          _altHeading = results[3].isNotEmpty ? results[3] : null;
          _altDraftTitle = results[4].isNotEmpty ? results[4] : null;
          _altDraftDesc = results[5].isNotEmpty ? results[5] : null;
          _altIssueTitle = results[6].isNotEmpty ? results[6] : null;
          _altRights = translatedRights;
          _altChecklist = translatedChecklist;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isBangla = targetToBangla;
          _isTranslating = false;
        });
      }
    }
  }

  static String _toBanglaDigit(int num) => '$num';

  String get _formattedTimestamp {
    final now = DateTime.now().toUtc().add(const Duration(hours: 6));
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    if (_isBangla) {
      String bnPeriod;
      if (hour >= 20 || hour < 4) {
        bnPeriod = 'রাত';
      } else if (hour >= 4 && hour < 6) {
        bnPeriod = 'ভোর';
      } else if (hour >= 6 && hour < 12) {
        bnPeriod = 'সকাল';
      } else if (hour >= 12 && hour < 15) {
        bnPeriod = 'দুপুর';
      } else if (hour >= 15 && hour < 18) {
        bnPeriod = 'বিকাল';
      } else {
        bnPeriod = 'সন্ধ্যা';
      }
      return '$bnPeriod $displayHour:$minute';
    } else {
      final period = isPm ? 'PM' : 'AM';
      return '$displayHour:$minute $period';
    }
  }

  String _cleanBrandName(String text) {
    return LegalTranslationService.cleanBrandName(text);
  }

  String _getActiveMeaning() {
    final ple = widget.response.plainLanguageExplanation;
    final rawMeaning = ple?.meaning ??
        (widget.response.explanation.isNotEmpty
            ? widget.response.explanation.map((e) => e.text).join('\n\n')
            : (_isBangla
                ? 'আইন অনুযায়ী চুক্তি মোতাবেক কাজ করার পর যথাসময়ে পারিশ্রমিক পাওয়া কর্মীর অলঙ্ঘনীয় অধিকার।'
                : 'Under statutory law, timely payment following completion of work is an inviolable right.'));
    final active = (_isBangla != _isOriginalBangla && _altMeaning != null)
        ? _altMeaning!
        : (_isBangla == _isOriginalBangla
            ? rawMeaning
            : LegalTranslationService.translate(rawMeaning,
                toBangla: _isBangla));
    return _cleanBrandName(active);
  }

  String? _getActiveUnderstanding() {
    final rawUnderstanding = widget.response.problemSummary?.understanding;
    if (rawUnderstanding == null || rawUnderstanding.isEmpty) return null;
    final active = (_isBangla != _isOriginalBangla && _altUnderstanding != null)
        ? _altUnderstanding!
        : (_isBangla == _isOriginalBangla
            ? rawUnderstanding
            : LegalTranslationService.translate(rawUnderstanding,
                toBangla: _isBangla));
    return _cleanBrandName(active);
  }

  String _getActiveWhatToDoNext() {
    final rawWhat =
        widget.response.plainLanguageExplanation?.whatToDoNext ?? '';
    if (rawWhat.isEmpty) return '';
    final active = (_isBangla != _isOriginalBangla && _altWhatToDoNext != null)
        ? _altWhatToDoNext!
        : (_isBangla == _isOriginalBangla
            ? rawWhat
            : LegalTranslationService.translate(rawWhat, toBangla: _isBangla));
    return _cleanBrandName(active);
  }

  String? _getActiveHeading() {
    final rawHeading = widget.response.plainLanguageExplanation?.heading;
    if (rawHeading == null || rawHeading.isEmpty) return null;
    final active = (_isBangla != _isOriginalBangla && _altHeading != null)
        ? _altHeading!
        : (_isBangla == _isOriginalBangla
            ? rawHeading
            : LegalTranslationService.translate(rawHeading,
                toBangla: _isBangla));
    return _cleanBrandName(active);
  }

  String? _getActiveIssueTitle() {
    final rawIssue = widget.response.problemSummary?.identifiedIssue;
    if (rawIssue == null || rawIssue.trim().isEmpty) return null;
    final active = (_isBangla != _isOriginalBangla && _altIssueTitle != null)
        ? _altIssueTitle!
        : (_isBangla == _isOriginalBangla
            ? rawIssue
            : LegalTranslationService.translate(rawIssue,
                toBangla: _isBangla));
    return _cleanBrandName(active);
  }

  List<String> _getActiveRights() {
    final rawRights =
        widget.response.plainLanguageExplanation?.userRightsAndOptions ??
            const <String>[];
    if (rawRights.isEmpty) return const [];
    final active = (_isBangla != _isOriginalBangla && _altRights != null)
        ? _altRights!
        : (_isBangla == _isOriginalBangla
            ? rawRights
            : rawRights
                .map((r) =>
                    LegalTranslationService.translate(r, toBangla: _isBangla))
                .toList());
    return active.map((r) => _cleanBrandName(r)).toList();
  }

  List<ChecklistStep> _getActiveChecklist() {
    return widget.response.checklist.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final isCompleted = _completedStepIds.contains(step.id);
      final activeText = (_altChecklist != null &&
              index < _altChecklist!.length &&
              _isBangla != _isOriginalBangla)
          ? _altChecklist![index]
          : (_isBangla == _isOriginalBangla
              ? step.text
              : LegalTranslationService.translate(step.text,
                  toBangla: _isBangla));
      return step.copyWith(
        text: _cleanBrandName(activeText),
        completed: isCompleted,
      );
    }).toList();
  }

  String _getActiveDraftTitle() {
    final draftOffer = widget.response.draftOffer;
    if (draftOffer == null) return '';
    final active = (_isBangla != _isOriginalBangla && _altDraftTitle != null)
        ? _altDraftTitle!
        : (_isBangla == _isOriginalBangla
            ? draftOffer.documentTitle
            : LegalTranslationService.translate(draftOffer.documentTitle,
                toBangla: _isBangla));
    return _cleanBrandName(active);
  }

  String _getActiveDraftDesc() {
    final draftOffer = widget.response.draftOffer;
    if (draftOffer == null || draftOffer.description.isEmpty) return '';
    final active = (_isBangla != _isOriginalBangla && _altDraftDesc != null)
        ? _altDraftDesc!
        : (_isBangla == _isOriginalBangla
            ? draftOffer.description
            : LegalTranslationService.translate(draftOffer.description,
                toBangla: _isBangla));
    return _cleanBrandName(active);
  }

  void _copyAnswer(BuildContext context) {
    final buffer = StringBuffer();
    final bn = _isBangla;

    buffer.writeln(bn
        ? '— MyLaws আইনি সমাধান ও নির্দেশনা —'
        : '— MyLaws Legal Guidance & Action Roadmap —');
    buffer.writeln();

    final understanding = _getActiveUnderstanding();
    if (understanding != null && understanding.isNotEmpty) {
      buffer.writeln(understanding);
      buffer.writeln();
    }

    final meaning = _getActiveMeaning();
    if (meaning.isNotEmpty) {
      buffer.writeln(meaning);
      final what = _getActiveWhatToDoNext();
      if (what.isNotEmpty) {
        buffer.writeln('${bn ? 'জরুরি করণীয়' : 'What to do next'}: $what');
      }
      buffer.writeln();
    }

    final checklist = _getActiveChecklist();
    if (checklist.isNotEmpty) {
      buffer.writeln(bn ? '【করণীয় পদক্ষেপ】' : '【Action Checklist】');
      for (var i = 0; i < checklist.length; i++) {
        final step = checklist[i];
        final numStr = bn ? _toBanglaDigit(i + 1) : '${i + 1}';
        buffer.writeln('$numStr. ${step.text}');
      }
      buffer.writeln();
    }

    final draftTitle = _getActiveDraftTitle();
    if (draftTitle.isNotEmpty) {
      buffer.writeln('${bn ? 'খসড়া প্রস্তুত' : 'Legal Draft'}: $draftTitle');
    }

    buffer.writeln('\n-- MyLaws · verified statutory guidance');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(bn
            ? 'সম্পূর্ণ আইনি উত্তর কপি করা হয়েছে'
            : 'Full legal answer copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  DocumentType _resolvePrimaryDraftType() {
    // 0. Prioritize allowedDraftOptions from backend
    if (widget.response.allowedDraftOptions.isNotEmpty) {
      final firstOpt = widget.response.allowedDraftOptions.first.trim();
      if (firstOpt.isNotEmpty) {
        return DocumentType.fromString(firstOpt);
      }
    }

    final offerType = widget.response.draftOffer?.documentType;
    if (offerType != null && offerType.trim().isNotEmpty) {
      return DocumentType.fromString(offerType);
    }

    final cat = widget.response.userFacts
            .where((f) => f.fieldId == 'issue.category')
            .map((f) => f.value.toLowerCase())
            .firstOrNull ??
        '';
    final combined = '${widget.response.problemSummary?.identifiedIssue ?? ''} '
            '${widget.response.problemSummary?.understanding ?? ''} '
            '${widget.response.explanation.map((e) => e.text).join(' ')} '
            '${widget.response.plainLanguageExplanation?.meaning ?? ''} '
            '${widget.response.checklist.map((c) => c.text).join(' ')}'
        .toLowerCase();

    // 1. Cheque Dishonour (NI Act 138)
    if (combined.contains('চেক') ||
        combined.contains('cheque') ||
        combined.contains('check') ||
        combined.contains('dishonour') ||
        combined.contains('dishonor') ||
        combined.contains('বাউন্স') ||
        combined.contains('bounce') ||
        combined.contains('138') ||
        combined.contains('১৩৮') ||
        combined.contains('ni act') ||
        combined.contains('এনআই এক্ট') ||
        combined.contains('ডিজঅনার') ||
        combined.contains('তহবিল নেই') ||
        combined.contains('insufficient funds')) {
      return DocumentType.cheque_dishonour;
    }

    // 2. Criminal Regular / Urgent Bail Petition (CrPC 496/497)
    if (combined.contains('জামিন') ||
        combined.contains('bail') ||
        combined.contains('গ্রেপ্তার') ||
        combined.contains('আটক') ||
        combined.contains('হাজত') ||
        combined.contains('জেলে') ||
        combined.contains('কারাগার') ||
        combined.contains('arrest') ||
        combined.contains('custody') ||
        combined.contains('remand') ||
        combined.contains('রিমান্ড') ||
        combined.contains('496') ||
        combined.contains('497') ||
        combined.contains('৪৯৬') ||
        combined.contains('৪৯৭') ||
        combined.contains('crpc')) {
      return DocumentType.bail_petition;
    }

    // 3. Land / Possession / Topsoil / Mutation
    if (combined.contains('অধিগ্রহণ') ||
        combined.contains('acquisition') ||
        combined.contains('বেদখল') ||
        combined.contains('দখল উদ্ধার') ||
        combined.contains('দখল') ||
        combined.contains('possession') ||
        combined.contains('sra-9') ||
        combined.contains('sra-54')) {
      return DocumentType.possession_recovery;
    }
    if (combined.contains('নামজারি') ||
        combined.contains('জমাভাগ') ||
        combined.contains('mutation') ||
        combined.contains('sat-143') ||
        combined.contains('ওয়ারিশ')) {
      return DocumentType.land_mutation;
    }
    if (combined.contains('অবৈধ মাটি') ||
        combined.contains('টপসয়েল') ||
        combined.contains('landcrime') ||
        combined.contains('ইউএনও') ||
        combined.contains('সহকারী কমিশনার (ভূমি)')) {
      return DocumentType.land_crime_complaint;
    }

    // 4. Consumer Protection (DNCRP)
    if (combined.contains('ভোক্তা') ||
        combined.contains('dncrp') ||
        combined.contains('প্রতারণা') ||
        combined.contains('দোকান') ||
        combined.contains('পণ্য') ||
        combined.contains('বিক্রেতা') ||
        combined.contains('consumer') ||
        cat == 'consumer') {
      return DocumentType.dncrp;
    }

    // 5. Labour Rights / Unpaid Wages (DIFE)
    if (combined.contains('মজুরি') ||
        combined.contains('শ্রম') ||
        combined.contains('dife') ||
        combined.contains('বেতন') ||
        combined.contains('বরখাস্ত') ||
        combined.contains('labour') ||
        combined.contains('wage') ||
        cat == 'labour') {
      return DocumentType.dife;
    }

    // 6. Domestic Violence
    if (combined.contains('যৌতুক') ||
        combined.contains('মারধর') ||
        combined.contains('সহিংসতা') ||
        combined.contains('নির্যাতন') ||
        combined.contains('domestic')) {
      return DocumentType.domestic_violence;
    }

    // 7. Family Maintenance / Dower
    if (combined.contains('দেনমোহর') ||
        combined.contains('ভরণপোষণ') ||
        combined.contains('খোরপোশ') ||
        combined.contains('maintenance') ||
        cat == 'family') {
      return DocumentType.family_maintenance;
    }

    // 8. Police / GD
    if (combined.contains('জিডি') ||
        combined.contains('gd') ||
        combined.contains('থানা') ||
        combined.contains('হুমকি') ||
        combined.contains('নিখোঁজ') ||
        combined.contains('হারানো') ||
        combined.contains('general diary') ||
        cat == 'police') {
      return DocumentType.gd;
    }

    if (cat == 'land') return DocumentType.possession_recovery;
    return DocumentType.gd;
  }

  bool _isDraftWarrantedForContext(
      DocumentType type, String fullTextContext) {
    // 1. Personal, family emotional distress or domestic quarrels never warrant formal court/GD drafts
    final isPersonalOrFamilyDistress = fullTextContext.contains('ঝগড়া') ||
        fullTextContext.contains('মনের অবস্থা') ||
        fullTextContext.contains('ভয় লাগছে') ||
        fullTextContext.contains('কান্না পাওয়া') ||
        fullTextContext.contains('আব্বু-আম্মু') ||
        fullTextContext.contains('আব্বু আম্মু') ||
        fullTextContext.contains('পিতা-মাতা') ||
        fullTextContext.contains('একা লাগছে') ||
        fullTextContext.contains('শান্ত থেকে') ||
        fullTextContext.contains('abbu') ||
        fullTextContext.contains('ammu') ||
        fullTextContext.contains('jogra');
    if (isPersonalOrFamilyDistress) {
      return false;
    }

    // 2. Administrative procedures (Driving license, passport) apply at official portals, not legal drafts
    final isAdministrative = fullTextContext.contains('driving') ||
        fullTextContext.contains('ড্রাইভিং') ||
        fullTextContext.contains('বিআরটিএ') ||
        fullTextContext.contains('brta') ||
        fullTextContext.contains('passport') ||
        fullTextContext.contains('পাসপোর্ট');
    if (isAdministrative) {
      return false;
    }

    // 3. Strict verification of substantive actionable grounds for each draft type
    switch (type) {
      case DocumentType.gd:
        return fullTextContext.contains('মানিব্যাগ') ||
            fullTextContext.contains('wallet') ||
            fullTextContext.contains('হারিয়ে') ||
            fullTextContext.contains('হারানো') ||
            fullTextContext.contains('lost') ||
            fullTextContext.contains('stolen') ||
            fullTextContext.contains('চুরি') ||
            fullTextContext.contains('ছিনতাই') ||
            fullTextContext.contains('নিখোঁজ') ||
            fullTextContext.contains('এনআইডি') ||
            fullTextContext.contains('nid') ||
            fullTextContext.contains('পাসপোর্ট হারানো') ||
            fullTextContext.contains('লাইসেন্স হারানো') ||
            fullTextContext.contains('সার্টিফিকেট হারানো') ||
            fullTextContext.contains('হুমকি') ||
            fullTextContext.contains('মারধর') ||
            fullTextContext.contains('চাঁদাবাজি') ||
            fullTextContext.contains('ব্ল্যাকমেইল') ||
            fullTextContext.contains('threat') ||
            fullTextContext.contains('extortion') ||
            fullTextContext.contains('blackmail') ||
            fullTextContext.contains('থানায় জিডি');

      case DocumentType.dife:
        return fullTextContext.contains('বেতন') ||
            fullTextContext.contains('মজুরি') ||
            fullTextContext.contains('বকেয়া') ||
            fullTextContext.contains('ছাঁটাই') ||
            fullTextContext.contains('বরখাস্ত') ||
            fullTextContext.contains('salary') ||
            fullTextContext.contains('wage') ||
            fullTextContext.contains('dife') ||
            fullTextContext.contains('শ্রমিক') ||
            fullTextContext.contains('কারখানা');

      case DocumentType.dncrp:
        return fullTextContext.contains('ভোক্তা') ||
            fullTextContext.contains('পণ্য') ||
            fullTextContext.contains('প্রতারণা') ||
            fullTextContext.contains('মেয়াদোত্তীর্ণ') ||
            fullTextContext.contains('ভেজাল') ||
            fullTextContext.contains('ওজনে কম') ||
            fullTextContext.contains('রিফান্ড') ||
            fullTextContext.contains('dncrp') ||
            fullTextContext.contains('fake') ||
            fullTextContext.contains('defective');

      case DocumentType.cheque_dishonour:
        return fullTextContext.contains('চেক') ||
            fullTextContext.contains('cheque') ||
            fullTextContext.contains('ডিজঅনার') ||
            fullTextContext.contains('dishonour') ||
            fullTextContext.contains('বাউন্স') ||
            fullTextContext.contains('bounce') ||
            fullTextContext.contains('১৩৮') ||
            fullTextContext.contains('138');

      case DocumentType.bail_petition:
        return fullTextContext.contains('জামিন') ||
            fullTextContext.contains('bail') ||
            fullTextContext.contains('গ্রেপ্তার') ||
            fullTextContext.contains('আটক') ||
            fullTextContext.contains('কারাগার') ||
            fullTextContext.contains('হাজত') ||
            fullTextContext.contains('arrest') ||
            fullTextContext.contains('custody') ||
            fullTextContext.contains('রিমান্ড');

      case DocumentType.possession_recovery:
        return fullTextContext.contains('বেদখল') ||
            fullTextContext.contains('দখল উদ্ধার') ||
            fullTextContext.contains('জমি দখল') ||
            fullTextContext.contains('দখল') ||
            fullTextContext.contains('উচ্ছেদ') ||
            fullTextContext.contains('দেওয়ানি আদালত');

      case DocumentType.land_mutation:
        return fullTextContext.contains('নামজারি') ||
            fullTextContext.contains('জমাভাগ') ||
            fullTextContext.contains('mutation') ||
            fullTextContext.contains('খারিজ');

      case DocumentType.land_crime_complaint:
        return fullTextContext.contains('অবৈধ মাটি') ||
            fullTextContext.contains('টপসয়েল') ||
            fullTextContext.contains('বালু উত্তোলন') ||
            fullTextContext.contains('ভূমি অপরাধ');

      case DocumentType.domestic_violence:
        return fullTextContext.contains('যৌতুক') ||
            fullTextContext.contains('নির্যাতন') ||
            fullTextContext.contains('সহিংসতা') ||
            fullTextContext.contains('শারীরিক নির্যাতন');

      case DocumentType.family_maintenance:
        return fullTextContext.contains('দেনমোহর') ||
            fullTextContext.contains('ভরণপোষণ') ||
            fullTextContext.contains('খোরপোশ') ||
            fullTextContext.contains('পারিবারিক আদালত');
    }
  }

  DocumentType? _detectStepDraftType(
      ChecklistStep step, DocumentType primaryDocType) {
    final text = step.text.toLowerCase();

    // Check specific explicit authorities and remedies first
    if (text.contains('চেক') ||
        text.contains('cheque') ||
        text.contains('ডিজঅনার') ||
        text.contains('১৩৮ ধারা')) {
      return DocumentType.cheque_dishonour;
    }
    if (text.contains('জামিন') ||
        text.contains('bail') ||
        text.contains('জামিনের আবেদন') ||
        text.contains('৪৯৬') ||
        text.contains('৪৯৭')) {
      return DocumentType.bail_petition;
    }
    final isMereGdRef = text.contains('জিডি নম্বর') ||
        text.contains('জিডির কপি') ||
        text.contains('জিডি কপি') ||
        text.contains('জিডি নং') ||
        text.contains('gd number') ||
        text.contains('gd copy') ||
        text.contains('copy of gd') ||
        text.contains('প্রমাণ হিসাবে') ||
        text.contains('ফটো সংরক্ষণ') ||
        text.contains('কপি সংরক্ষণ') ||
        text.contains('সংরক্ষণ করুন') ||
        text.contains('ব্যবহার করুন') ||
        text.contains('ব্যবহার করে');

    final isGdFilingAction = !isMereGdRef &&
        (text.contains('জিডি ফাইল') ||
            text.contains('জিডি দায়ের') ||
            text.contains('জিডি দায়ের') ||
            text.contains('জিডি দাখিল') ||
            text.contains('জিডি করুন') ||
            text.contains('অনলাইন জিডি') ||
            text.contains('file a gd') ||
            text.contains('lodge a gd') ||
            text.contains('file a general diary') ||
            text.contains('lodge a general diary') ||
            ((text.contains('জিডি') ||
                    text.contains('gd') ||
                    text.contains('সাধারণ ডায়েরি') ||
                    text.contains('সাধারণ ডায়েরি')) &&
                (text.contains('করুন') ||
                    text.contains('যান') ||
                    text.contains('ফাইল') ||
                    text.contains('দাখিল') ||
                    text.contains('দায়ের') ||
                    text.contains('lodge') ||
                    text.contains('file') ||
                    text.contains('register'))) ||
            (text.contains('থানায়') &&
                (text.contains('অভিযোগ দায়ের') ||
                    text.contains('অভিযোগ দাখিল') ||
                    text.contains('লিখিত অভিযোগ'))));

    if (isGdFilingAction) {
      return DocumentType.gd;
    }
    if (text.contains('dncrp') ||
        text.contains('ভোক্তা অধিকার') ||
        text.contains('ভোক্তা অধিদপ্তরে') ||
        text.contains('জাতীয় ভোক্তা অধিকার')) {
      return DocumentType.dncrp;
    }
    if (text.contains('dife') ||
        text.contains('কলকারখানা') ||
        text.contains('শ্রম আদালত') ||
        text.contains('শ্রম পরিদর্শক') ||
        text.contains('শ্রম অধিদপ্তর')) {
      return DocumentType.dife;
    }
    if (text.contains('নামজারি') ||
        text.contains('ই-নামজারি') ||
        text.contains('mutation') ||
        text.contains('জমাভাগ')) {
      return DocumentType.land_mutation;
    }
    if (text.contains('দখল উদ্ধার') ||
        text.contains('আরজি দাখিল') ||
        text.contains('নিষেধাজ্ঞা') ||
        text.contains('দেওয়ানি আদালত') ||
        text.contains('দেওয়ানি মোকদ্দমা') ||
        text.contains('অস্থায়ী নিষেধাজ্ঞা')) {
      return DocumentType.possession_recovery;
    }
    if (text.contains('ইউএনও') ||
        text.contains('সহকারী কমিশনার (ভূমি)') ||
        text.contains('অবৈধ মাটি') ||
        text.contains('ভূমি অপরাধ')) {
      return DocumentType.land_crime_complaint;
    }
    if (text.contains('সুরক্ষা আদেশ') ||
        text.contains('পারিবারিক সহিংসতা') ||
        text.contains('নির্যাতন বন্ধ')) {
      return DocumentType.domestic_violence;
    }
    if (text.contains('ভরণপোষণ') ||
        text.contains('দেনমোহর') ||
        text.contains('খোরপোশ দাবি')) {
      return DocumentType.family_maintenance;
    }

    // Generic drafting cues
    if (text.contains('খসড়া') ||
        text.contains('আবেদন প্রস্তুত') ||
        text.contains('দরখাস্ত দাখিল') ||
        text.contains('লিখিত অভিযোগ') ||
        text.contains('নোটিশ পাঠান') ||
        text.contains('আরজি প্রস্তুত') ||
        text.contains('ড্রাফট') ||
        text.contains('draft')) {
      return primaryDocType;
    }

    return null;
  }

  String _getContextualDraftDescription(DocumentType type, bool isBangla) {
    switch (type) {
      case DocumentType.cheque_dishonour:
        return isBangla
            ? 'ব্যাংক চেক বাউন্স বা তহবিলের অপর্যাপ্ততার কারণে এনআই অ্যাক্টের ১৩৮ ধারা অনুযায়ী ৩০ দিনের মধ্যে টাকা পরিশোধের সংবিধিবদ্ধ আইনি নোটিশ।'
            : 'Statutory 30-day legal demand notice served under Section 138 of the Negotiable Instruments Act 1881 for dishonoured cheque.';
      case DocumentType.bail_petition:
        return isBangla
            ? 'বিজ্ঞ ম্যাজিস্ট্রেট আদালতে ফৌজদারি কার্যবিধির ৪৯৬/৪৯৭ ধারা অনুযায়ী গ্রেপ্তারকৃত আসামির নিয়মিত জামিনের আবেদন।'
            : 'Petition for criminal regular or urgent bail under Section 496/497 CrPC for an accused remanded to judicial custody.';
      case DocumentType.possession_recovery:
        return isBangla
            ? 'জমির বৈধ দলিল ও পূর্ববর্তী দখল প্রমাণসহ দেওয়ানি আদালতে সুনির্দিষ্ট প্রতিকার আইনের ৯ ধারা অনুযায়ী দখল পুনরুদ্ধারের আনুষ্ঠানিক আরজি প্রস্তুত করুন।'
            : 'Prepare a formal summary plaint for recovery of dispossessed land under Section 9 of the Specific Relief Act 1877.';
      case DocumentType.land_mutation:
        return isBangla
            ? 'সহকারী কমিশনার (ভূমি) ও উপজেলা ভূমি অফিসে উত্তরাধিকার বা ক্রয়সূত্রে ই-নামজারি ও জমাভাগ আবেদনের পূর্ণাঙ্গ খসড়া।'
            : 'Complete application draft for inheritance land mutation and separate khatiyan at the Upazila Land Office.';
      case DocumentType.land_crime_complaint:
        return isBangla
            ? 'কৃষিজমির ক্ষতিসাধন বা অবৈধ মাটি কাটা বন্ধে ভূমি অপরাধ প্রতিরোধ ও প্রতিকার আইন ২০২৩ অনুযায়ী ইউএনও/এসি ল্যান্ড বরাবর লিখিত অভিযোগ।'
            : 'Formal complaint to AC Land/UNO against illegal topsoil removal under Land Crime Prevention and Redress Act 2023.';
      case DocumentType.dncrp:
        return isBangla
            ? 'জাতীয় ভোক্তা অধিকার সংরক্ষণ অধিদপ্তরে পণ্য বা সেবা সংক্রান্ত প্রতারণার প্রতিকার ও ২৫% পুরস্কার আদায়ের লিখিত অভিযোগ খসড়া।'
            : 'Official written complaint to DNCRP for consumer redress and 25% statutory penalty reward.';
      case DocumentType.dife:
        return isBangla
            ? 'বাংলাদেশ শ্রম আইন ২০০৬ অনুযায়ী বকেয়া বেতন ও ক্ষতিপূরণ আদায়ে কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর (DIFE) বরাবর আনুষ্ঠানিক অভিযোগ।'
            : 'Formal legal complaint to DIFE for unpaid wages and statutory delayed payment compensation.';
      case DocumentType.gd:
        return isBangla
            ? 'নিকটস্থ মডেল থানায় হারানো বা সাধারণ আইনি নিরাপত্তার জন্য ডিজিটাল জিডি বা আনুষ্ঠানিক সাধারণ ডায়েরি আবেদন।'
            : 'Formal application for Police General Diary (GD) entry at the local police station.';
      case DocumentType.domestic_violence:
        return isBangla
            ? 'পারিবারিক সহিংসতা প্রতিরোধ ও সুরক্ষা আইন অনুযায়ী জুডিশিয়াল ম্যাজিস্ট্রেট আদালতে জরুরি সুরক্ষা আদেশ ও ক্ষতিপূরণের দরখাস্ত।'
            : 'Urgent court application for protection order and maintenance under Domestic Violence Act 2010.';
      case DocumentType.family_maintenance:
        return isBangla
            ? 'পারিবারিক আদালত আইন ২০২৩ অনুযায়ী দেনমোহর ও স্ত্রী-সন্তানের নিয়মিত খোরপোশ আদায়ের জন্য প্রস্তুতকৃত আরজি।'
            : 'Plaint for prompt/deferred dower and past/future spousal maintenance in Family Court.';
    }
  }

  DraftDocument _buildPrefilledDraft(DocumentType type) {
    final values = <String, String>{};

    // 1. Gather all existing facts from response
    for (final fact in widget.response.userFacts) {
      if (fact.value != null && fact.value.toString().trim().isNotEmpty) {
        values[fact.fieldId] = fact.value.toString().trim();
      }
    }

    // Map common aliases
    if (!values.containsKey('name') && values.containsKey('applicant_name')) {
      values['name'] = values['applicant_name']!;
    }
    if (!values.containsKey('contact') &&
        values.containsKey('applicant_phone')) {
      values['contact'] = values['applicant_phone']!;
    }
    if (!values.containsKey('address') &&
        values.containsKey('applicant_address')) {
      values['address'] = values['applicant_address']!;
    }
    if (!values.containsKey('respondent') &&
        values.containsKey('employer_name')) {
      values['respondent'] = values['employer_name']!;
    }
    if (!values.containsKey('amount') && values.containsKey('wage_amount')) {
      values['amount'] = values['wage_amount']!;
    }
    if (!values.containsKey('amount') && values.containsKey('cheque_amount')) {
      values['amount'] = values['cheque_amount']!;
    }

    // 2. Extract from problem summary & explanation if missing
    final understanding = widget.response.problemSummary?.understanding ?? '';
    final issue = widget.response.problemSummary?.identifiedIssue ?? '';
    final meaning = widget.response.plainLanguageExplanation?.meaning ?? '';
    final whatToDo =
        widget.response.plainLanguageExplanation?.whatToDoNext ?? '';
    final allText =
        '$understanding $issue $meaning $whatToDo ${widget.response.explanation.map((e) => e.text).join(' ')}';

    // Chronology fallback
    if (!values.containsKey('chronology') || values['chronology']!.isEmpty) {
      if (understanding.isNotEmpty) {
        values['chronology'] = understanding;
      } else if (issue.isNotEmpty) {
        values['chronology'] = issue;
      }
    }

    // Assistance / relief fallback
    if (!values.containsKey('assistance') || values['assistance']!.isEmpty) {
      if (whatToDo.isNotEmpty) {
        values['assistance'] = whatToDo;
      }
    }

    // Amount extraction
    if (!values.containsKey('amount') || values['amount']!.isEmpty) {
      final match = RegExp(r'(\d+[\d,]*(?:\.\d+)?)\s*(?:টাকা|টাকার|bdt|tk|\/-)',
              caseSensitive: false)
          .firstMatch(allText);
      if (match != null) {
        values['amount'] = '${match.group(1)} টাকা';
      }
    }

    // Cheque number extraction
    if (type == DocumentType.cheque_dishonour &&
        (!values.containsKey('chequeNo') || values['chequeNo']!.isEmpty)) {
      final match = RegExp(
              r'(?:চেক\s*(?:নং|নম্বর)?|cheque\s*(?:no\.?)?)[:\s]*([a-zA-Z0-9\-_/]+)',
              caseSensitive: false)
          .firstMatch(allText);
      if (match != null) {
        values['chequeNo'] = match.group(1)!;
      }
    }

    // Case number extraction
    if (type == DocumentType.bail_petition &&
        (!values.containsKey('caseNo') || values['caseNo']!.isEmpty)) {
      final match = RegExp(
              r'(?:মামলা\s*(?:নং|নম্বর)?|জিআর\s*(?:নং)?|case\s*(?:no\.?)?|gr\s*(?:no\.?)?)[:\s]*([a-zA-Z0-9\-_/]+)',
              caseSensitive: false)
          .firstMatch(allText);
      if (match != null) {
        values['caseNo'] = match.group(1)!;
      }
    }

    // Application date default: today
    if (!values.containsKey('applicationDate') ||
        values['applicationDate']!.isEmpty) {
      final now = DateTime.now();
      values['applicationDate'] = '${now.day}/${now.month}/${now.year}';
    }

    // Convert values map back into Fact list
    final factsList = <Fact>[];
    values.forEach((key, val) {
      factsList.add(Fact(
        fieldId: key,
        value: val,
        isExtracted: true,
      ));
    });

    return DraftDocument.createDefault(
      type: type,
      facts: factsList,
    );
  }

  void _openDraftEditor(BuildContext context, [DocumentType? type]) {
    final docType = type ?? _resolvePrimaryDraftType();
    final prefilled = _buildPrefilledDraft(docType);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DraftEditorScreen(
          type: docType,
          initialDraft: prefilled,
        ),
      ),
    );
    widget.onPrepareDraft?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Palette tokens for warm aged parchment & deep dark mode with optimal legibility
    final cardBg = isDark ? const Color(0xFF1E1A17) : const Color(0xFFFCF9F3);
    final cardBorder =
        isDark ? const Color(0xFF38312B) : const Color(0xFFE2DDD1);
    final bronzePrimary =
        isDark ? const Color(0xFFE0BA7A) : const Color(0xFF7A5420);
    final bronzeContainer =
        isDark ? const Color(0xFF382B18) : const Color(0xFFF4ECE0);
    final textColor =
        isDark ? const Color(0xFFF7F5F0) : const Color(0xFF161512);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0A89C) : const Color(0xFF564E43);

    // 1. Emergency Referral Outcome
    if (widget.response.outcome == Outcome.emergencyReferral) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lightError.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.lightError, size: 24),
                const SizedBox(width: 8),
                Text(
                  _isBangla ? 'জরুরি সহায়তা' : 'Emergency Referral',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightError,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.response.explanation.firstOrNull?.text ??
                  (_isBangla
                      ? 'তাত্ক্ষণিক শারীরিক বিপদে অবিলম্বে জাতীয় জরুরি সেবা ৯৯৯ নম্বরে যোগাযোগ করুন।'
                      : 'For immediate emergency assistance, contact national helpline 999.'),
              style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppColors.darkText : AppColors.lightText),
            ),
            const SizedBox(height: 16),
            ...widget.response.checklist.map((c) => ChecklistStepTile(
                  step: c,
                  isBangla: _isBangla,
                  onToggle: (_) {},
                )),
          ],
        ),
      );
    }

    // 2. Insufficient Sources Outcome
    if (widget.response.outcome == Outcome.insufficientSources) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isDark
                  ? AppColors.darkOutlineVariant
                  : AppColors.lightOutlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.search_off_outlined,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.response.explanation.firstOrNull?.text ??
                    (_isBangla
                        ? 'এই বিষয়ে আমাদের তথ্যভাণ্ডারে যথেষ্ট নির্ভরযোগ্য আইনি উৎস পাওয়া যায়নি, তাই অনুমান করে কিছু বলা হচ্ছে না।'
                        : 'We could not find enough reliable legal sources for this situation, so we will not guess.'),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Unified Single Response Card (Everything in ONE cohesive flow)
    final displayMeaning = _getActiveMeaning();
    final displayWhatToDoNext = _getActiveWhatToDoNext();
    final displayUnderstanding = _getActiveUnderstanding();
    final displayHeading = _getActiveHeading();
    final displayRights = _getActiveRights();
    final displayChecklist = _getActiveChecklist();
    final displayDraftTitle = _getActiveDraftTitle();
    final displayDraftDesc = _getActiveDraftDesc();

    // Collect all statutory sources
    final allSourceIds = <String>{
      ...widget.response.explanation.expand((e) => e.sourceIds),
      ...widget.response.checklist.expand((c) => c.sourceIds),
    }.where((id) => id.isNotEmpty).toList();

    // Contextual Source Validation & Alignment:
    // If backend returned incongruent arrest/remand or arms guidelines due to generic default categories,
    // dynamically align sources with authoritative Bangladesh statutory provisions for the specific citizen situation.
    final fullTextContext = ((widget.response.plainLanguageExplanation?.meaning ?? '') +
            ' ' +
            (widget.response.problemSummary?.understanding ?? '') +
            ' ' +
            (widget.response.problemSummary?.identifiedIssue ?? ''))
        .toLowerCase();

    final isSimOrTelecomIssue = fullTextContext.contains('সিম') ||
        fullTextContext.contains('sim') ||
        fullTextContext.contains('btrc') ||
        fullTextContext.contains('বিটিআরসি') ||
        fullTextContext.contains('16001') ||
        fullTextContext.contains('১৬০০১') ||
        fullTextContext.contains('dnd') ||
        fullTextContext.contains('অপারেটর') ||
        fullTextContext.contains('মার্কেটিং কল') ||
        fullTextContext.contains('স্প্যাম') ||
        fullTextContext.contains('হয়রানি কল') ||
        fullTextContext.contains('হুমকি কল');

    final isBlackmailOrExtortionIssue = fullTextContext.contains('ব্ল্যাকমেইল') ||
        fullTextContext.contains('blackmail') ||
        fullTextContext.contains('চাঁদাবাজি') ||
        fullTextContext.contains('extortion') ||
        fullTextContext.contains('ছবি দিয়ে') ||
        fullTextContext.contains('গোপন ছবি') ||
        fullTextContext.contains('ভিডিও দিয়ে') ||
        fullTextContext.contains('ভাইরাল') ||
        fullTextContext.contains('টাকা দাবি') ||
        fullTextContext.contains('টাকা চাচ্ছে') ||
        fullTextContext.contains('সাইবার পুলিশ') ||
        fullTextContext.contains('লিগ্যাল এইড ১৬৪৩০');

    final hasIncongruentTelecomSources = allSourceIds.any((id) {
      final lower = id.toLowerCase();
      return lower.contains('blast') ||
          lower.contains('remand') ||
          lower.contains('arrest-54') ||
          lower.contains('constitution-102') ||
          lower.contains('arms') ||
          lower.contains('sample') ||
          lower.contains('16001');
    }) || allSourceIds.isEmpty;

    final hasIncongruentBlackmailSources = allSourceIds.any((id) {
      final lower = id.toLowerCase();
      return lower.contains('bsti') ||
          lower.contains('arms') ||
          lower.contains('blast') ||
          lower.contains('remand') ||
          lower.contains('arrest-54') ||
          lower.contains('sample');
    });

    final isAdministrativeProcedure = fullTextContext.contains('driving') ||
        fullTextContext.contains('ড্রাইভিং') ||
        fullTextContext.contains('লাইসেন্স') ||
        fullTextContext.contains('license') ||
        fullTextContext.contains('বিআরটিএ') ||
        fullTextContext.contains('brta') ||
        fullTextContext.contains('passport') ||
        fullTextContext.contains('পাসপোর্ট');

    final isPersonalOrFamilyDistress = fullTextContext.contains('ঝগড়া') ||
        fullTextContext.contains('মনের অবস্থা') ||
        fullTextContext.contains('ভয় লাগছে') ||
        fullTextContext.contains('কান্না পাওয়া') ||
        fullTextContext.contains('আব্বু-আম্মু') ||
        fullTextContext.contains('আব্বু আম্মু') ||
        fullTextContext.contains('পিতা-মাতা') ||
        fullTextContext.contains('একা লাগছে') ||
        fullTextContext.contains('শান্ত থেকে') ||
        fullTextContext.contains('abbu') ||
        fullTextContext.contains('ammu') ||
        fullTextContext.contains('jogra');

    if (isAdministrativeProcedure || isPersonalOrFamilyDistress) {
      allSourceIds.clear();
    } else if (isBlackmailOrExtortionIssue &&
        (hasIncongruentBlackmailSources || allSourceIds.isEmpty)) {
      allSourceIds.clear();
      final hasPrivateMedia = fullTextContext.contains('ছবি') ||
          fullTextContext.contains('ভিডিও') ||
          fullTextContext.contains('photo') ||
          fullTextContext.contains('video');
      if (hasPrivateMedia) {
        allSourceIds.addAll(['penal-384', 'pornography-8', 'cyber-26']);
      } else {
        allSourceIds.addAll(['penal-384', 'penal-383', 'penal-506']);
      }
    } else if (isSimOrTelecomIssue && hasIncongruentTelecomSources) {
      allSourceIds.clear();
      allSourceIds.addAll(['telecom-67', 'telecom-66', 'cyber-26']);
    } else {
      final isConsumerProductIssue = fullTextContext.contains('নষ্ট পণ্য') ||
          fullTextContext.contains('খারাপ পণ্য') ||
          fullTextContext.contains('ভেজাল') ||
          fullTextContext.contains('মেয়াদোত্তীর্ণ') ||
          fullTextContext.contains('অনলাইন শপিং') ||
          fullTextContext.contains('পণ্য ফেরত') ||
          fullTextContext.contains('রিফান্ড');

      final hasIncongruentConsumerSources = allSourceIds.any((id) {
        final lower = id.toLowerCase();
        return lower.contains('blast') ||
            lower.contains('arms') ||
            lower.contains('remand') ||
            lower.contains('sample');
      });

      if (isConsumerProductIssue &&
          (hasIncongruentConsumerSources || allSourceIds.isEmpty)) {
        allSourceIds.clear();
        allSourceIds.addAll(['consumer-51', 'consumer-60', 'consumer-76']);
      } else {
        final isLostOrStolenIssue = fullTextContext.contains('মানিব্যাগ') ||
            fullTextContext.contains('wallet') ||
            fullTextContext.contains('হারিয়ে') ||
            fullTextContext.contains('হারানো') ||
            fullTextContext.contains('lost') ||
            fullTextContext.contains('stolen') ||
            fullTextContext.contains('চুরি') ||
            fullTextContext.contains('ছিনতাই') ||
            fullTextContext.contains('নিখোঁজ') ||
            fullTextContext.contains('এনআইডি') ||
            fullTextContext.contains('nid') ||
            fullTextContext.contains('জিডি') ||
            fullTextContext.contains('gd');

        final hasIncongruentArrestSources = allSourceIds.any((id) {
          final lower = id.toLowerCase();
          return lower.contains('blast') ||
              lower.contains('remand') ||
              lower.contains('arrest-54') ||
              lower.contains('constitution-102');
        });

        if (isLostOrStolenIssue && hasIncongruentArrestSources) {
          allSourceIds.clear();
          allSourceIds.addAll(['police-44-gd', 'penal-379', 'cyber-24']);
        }
      }
    }

    // Prune any sources that are completely incongruent with the actual issue context
    allSourceIds.removeWhere((id) {
      final lower = id.toLowerCase();
      if (lower.contains('acquisition')) {
        final isAcquisitionContext = fullTextContext.contains('অধিগ্রহণ') ||
            fullTextContext.contains('acquisition') ||
            fullTextContext.contains('স্থাবর সম্পত্তি অধিগ্রহণ') ||
            fullTextContext.contains('জমি অধিগ্রহণ') ||
            fullTextContext.contains('ডিসি অফিস');
        return !isAcquisitionContext;
      }
      if (lower.contains('labour') || lower.contains('labor')) {
        final isLabourContext = fullTextContext.contains('শ্রম') ||
            fullTextContext.contains('বেতন') ||
            fullTextContext.contains('মজুরি') ||
            fullTextContext.contains('ছাঁটাই') ||
            fullTextContext.contains('বরখাস্ত') ||
            fullTextContext.contains('চাকরি') ||
            fullTextContext.contains('dife') ||
            fullTextContext.contains('salary') ||
            fullTextContext.contains('wage');
        return !isLabourContext;
      }
      if (lower.contains('consumer') || lower.contains('dncrp')) {
        final isConsumerContext = fullTextContext.contains('ভোক্তা') ||
            fullTextContext.contains('পণ্য') ||
            fullTextContext.contains('মেয়াদোত্তীর্ণ') ||
            fullTextContext.contains('ভেজাল') ||
            fullTextContext.contains('ওজনে কম') ||
            fullTextContext.contains('রিফান্ড') ||
            fullTextContext.contains('fake') ||
            fullTextContext.contains('defective');
        return !isConsumerContext;
      }
      if (lower.contains('police-44') || lower.contains('penal-379')) {
        final isTheftOrLost = fullTextContext.contains('মানিব্যাগ') ||
            fullTextContext.contains('wallet') ||
            fullTextContext.contains('হারিয়ে') ||
            fullTextContext.contains('হারানো') ||
            fullTextContext.contains('lost') ||
            fullTextContext.contains('stolen') ||
            fullTextContext.contains('চুরি') ||
            fullTextContext.contains('ছিনতাই') ||
            fullTextContext.contains('নিখোঁজ') ||
            fullTextContext.contains('এনআইডি') ||
            fullTextContext.contains('nid') ||
            fullTextContext.contains('পাসপোর্ট হারানো') ||
            fullTextContext.contains('সার্টিফিকেট') ||
            fullTextContext.contains('হুমকি') ||
            fullTextContext.contains('জিডি') ||
            fullTextContext.contains('থানায়');
        return !isTheftOrLost;
      }
      if (lower.contains('blast') || lower.contains('remand') || lower.contains('arrest-54')) {
        final isArrestContext = fullTextContext.contains('গ্রেপ্তার') ||
            fullTextContext.contains('আটক') ||
            fullTextContext.contains('রিমান্ড') ||
            fullTextContext.contains('হেফাজত') ||
            fullTextContext.contains('arrest');
        return !isArrestContext;
      }
      return false;
    });

    return GestureDetector(
      onTap: _skipTypewriter,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.28 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Action Bar inside the card
            _buildTopActionBar(
              context: context,
              isDark: isDark,
              bronzePrimary: bronzePrimary,
              bronzeContainer: bronzeContainer,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),

            Divider(
              height: 22,
              thickness: 1,
              color: cardBorder.withOpacity(0.65),
            ),

            // Empathetic Header Card with issueTitle & understanding
            Builder(
              builder: (context) {
                final issueTitle = _getActiveIssueTitle();
                final hasIssueTitle = issueTitle != null &&
                    issueTitle.trim().isNotEmpty &&
                    issueTitle != 'আইনি পরামর্শ' &&
                    issueTitle != 'Legal Advice';
                final hasUnderstanding = displayUnderstanding != null &&
                    displayUnderstanding.trim().isNotEmpty &&
                    displayUnderstanding.trim() != displayMeaning.trim() &&
                    !displayMeaning.contains(displayUnderstanding.trim());

                // If understanding is already part of displayMeaning or there is no standalone note,
                // do not render a redundant empty title card.
                if (!hasUnderstanding) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF26201A)
                        : const Color(0xFFF9F5EC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: bronzePrimary.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasIssueTitle) ...[
                        Row(
                          children: [
                            Icon(Icons.gavel_rounded, size: 16, color: bronzePrimary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                issueTitle,
                                style: GoogleFonts.anekBangla(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFFE2B872)
                                      : const Color(0xFF6B4E1B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        displayUnderstanding,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14.5,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFF0ECE1)
                              : const Color(0xFF26221E),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Plain Language Explanation & Meaning
            Builder(
              builder: (context) {
                final issueTitle = _getActiveIssueTitle();
                final hasUnderstanding = displayUnderstanding != null &&
                    displayUnderstanding.trim().isNotEmpty &&
                    displayUnderstanding.trim() != displayMeaning.trim() &&
                    !displayMeaning.contains(displayUnderstanding.trim());

                final showHeading = displayHeading != null &&
                    displayHeading.trim().isNotEmpty &&
                    displayHeading != 'আইনি পরামর্শ' &&
                    displayHeading != 'Legal Advice' &&
                    (!hasUnderstanding ||
                        issueTitle == null ||
                        displayHeading.trim().toLowerCase() !=
                            issueTitle.trim().toLowerCase()) &&
                    !displayMeaning.startsWith(displayHeading.trim());

                if (!showHeading) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    displayHeading,
                    style: GoogleFonts.anekBangla(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: isDark
                          ? const Color(0xFFFAF7F0)
                          : const Color(0xFF1A1815),
                    ),
                  ),
                );
              },
            ),

            _buildLegalRichText(
              text: _isTypingComplete
                  ? displayMeaning
                  : displayMeaning.substring(
                      0, _displayedChars.clamp(0, displayMeaning.length)),
              showCursor: !_isTypingComplete,
              cursorColor: bronzePrimary,
              baseStyle: GoogleFonts.hindSiliguri(
                fontSize: _isBangla ? 16.0 : 15.5,
                fontWeight: FontWeight.w500,
                height: 1.68,
                letterSpacing: 0.1,
                color: isDark
                    ? const Color(0xFFF7F5F0)
                    : const Color(0xFF1E1A17),
              ),
              boldStyle: GoogleFonts.hindSiliguri(
                fontSize: _isBangla ? 16.0 : 15.5,
                height: 1.68,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                color:
                    isDark ? const Color(0xFFE8C280) : const Color(0xFF8C5E24),
              ),
            ),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Citizen Rights & Legal Protections
                  if (displayRights.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      _isBangla
                          ? 'আপনার আইনি অধিকার ও সুরক্ষা:'
                          : 'Your Statutory Rights & Protections:',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: bronzePrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...displayRights.map(
                      (right) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                              color: bronzePrimary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                right,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.55,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Collapsible Dropdown for Statutory Sources & Gazette Sections
                  if (allSourceIds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          setState(() => _sourcesExpanded = !_sourcesExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF26211C)
                              : const Color(0xFFF7F2E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: bronzePrimary
                                .withOpacity(_sourcesExpanded ? 0.6 : 0.35),
                            width: 1.1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.menu_book_rounded,
                                size: 16, color: bronzePrimary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isBangla
                                    ? 'আইনি উৎস ও ধারা (${allSourceIds.length}টি সংবিধিবদ্ধ বিধান)'
                                    : 'Statutory Sources & Citations (${allSourceIds.length} cited)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFFE2B872)
                                      : const Color(0xFF6B4E1B),
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _sourcesExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: bronzePrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_sourcesExpanded) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1A16)
                              : const Color(0xFFFAF7F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: bronzePrimary.withOpacity(0.25),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isBangla
                                  ? 'উক্ত আইনি অধিকার নিশ্চিত করতে নিম্নলিখিত সংবিধিবদ্ধ আইন ও সরকারি গেজেট ধারা প্রযোজ্য:'
                                  : 'The following statutory provisions and official gazette sections govern these rights:',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...allSourceIds.map((sid) => SourceChip(
                                  sourceId: sid,
                                  isBangla: _isBangla,
                                  showVerifiedSeal: true,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],

                  // Immediate Action Callout Banner
                  if (displayWhatToDoNext.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF332A1C)
                            : const Color(0xFFFBF4E7),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: bronzePrimary.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_circle_right_rounded,
                              size: 16, color: bronzePrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayWhatToDoNext,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Collapsible Action Checklist Drop-down
                  if (widget.response.checklist.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      key: const ValueKey('checklist_dropdown_trigger'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(
                          () => _checklistExpanded = !_checklistExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF26211C)
                              : const Color(0xFFF7F2E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: bronzePrimary.withValues(
                                alpha: _checklistExpanded ? 0.6 : 0.35),
                            width: 1.1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.checklist_rounded,
                                size: 18, color: bronzePrimary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isBangla
                                    ? 'পরবর্তী করণীয় পদক্ষেপ ও চেকলিস্ট'
                                    : 'Action Checklist & Next Steps',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFFE2B872)
                                      : const Color(0xFF6B4E1B),
                                ),
                              ),
                            ),
                            if (displayChecklist.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (_completedStepIds.length ==
                                          displayChecklist.length)
                                      ? const Color(0xFF2E7D32)
                                          .withValues(alpha: 0.15)
                                      : const Color(0xFF9A6F32)
                                          .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: (_completedStepIds.length ==
                                            displayChecklist.length)
                                        ? const Color(0xFF2E7D32)
                                            .withValues(alpha: 0.4)
                                        : const Color(0xFF9A6F32)
                                            .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  _isBangla
                                      ? '${_completedStepIds.length}/${displayChecklist.length} সম্পন্ন'
                                      : '${_completedStepIds.length}/${displayChecklist.length} done',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: (_completedStepIds.length ==
                                            displayChecklist.length)
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFF9A6F32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Icon(
                              _checklistExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: bronzePrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_checklistExpanded) ...[
                      if (displayChecklist.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(
                              begin: 0.0,
                              end: (_completedStepIds.length /
                                  displayChecklist.length),
                            ),
                            builder: (context, val, _) =>
                                LinearProgressIndicator(
                              value: val,
                              minHeight: 4,
                              backgroundColor: isDark
                                  ? const Color(0xFF2C2720)
                                  : const Color(0xFFE8E0D2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                (_completedStepIds.length ==
                                        displayChecklist.length)
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF9A6F32),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Builder(
                        builder: (context) {
                          final primaryDraftType = _resolvePrimaryDraftType();
                          final isDraftWarranted = _isDraftWarrantedForContext(primaryDraftType, fullTextContext);
                          final hasAllowedDraft =
                              (widget.response.allowedDraftOptions.isNotEmpty ||
                                      widget.response.draftOffer != null) &&
                                  isDraftWarranted;
                          final assignedDraftTypes = <DocumentType>{};

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: displayChecklist.asMap().entries.map((entry) {
                              final index = entry.key;
                              final step = entry.value;
                              var stepDraftType = hasAllowedDraft
                                  ? _detectStepDraftType(step, primaryDraftType)
                                  : null;

                              // Only show draft CTA on at most one step per document type to avoid redundant button flooding
                              if (stepDraftType != null) {
                                if (assignedDraftTypes.contains(stepDraftType)) {
                                  stepDraftType = null;
                                } else {
                                  assignedDraftTypes.add(stepDraftType);
                                }
                              }

                              return ChecklistStepTile(
                                step: step,
                                isBangla: _isBangla,
                                stepNumber: index + 1,
                                onToggle: (_) => _toggleChecklistStep(step.id),
                                onDraft: stepDraftType != null
                                    ? () => _openDraftEditor(context, stepDraftType!)
                                    : null,
                                draftLabel: stepDraftType != null
                                    ? (_isBangla
                                        ? 'খসড়া প্রস্তুত করুন (${stepDraftType.categoryLabelBn})'
                                        : 'Prepare Draft (${stepDraftType.name.toUpperCase()})')
                                    : null,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ],

                  // Formal Draft Preparation Section (Contextual Legal Draft)
                  // Only offer draft when permitted by backend AND genuinely warranted by the citizen's context
                  if ((widget.response.allowedDraftOptions.isNotEmpty ||
                          widget.response.draftOffer != null) &&
                      _isDraftWarrantedForContext(_resolvePrimaryDraftType(), fullTextContext)) ...[
                    Builder(
                      builder: (context) {
                        final primaryDraftType = _resolvePrimaryDraftType();
                        final effectiveDraftTitle = displayDraftTitle.isNotEmpty
                            ? displayDraftTitle
                            : (_isBangla
                                ? '${primaryDraftType.categoryLabelBn} সংক্রান্ত আনুষ্ঠানিক আবেদনপত্র'
                                : 'Formal Legal Draft (${primaryDraftType.name.toUpperCase()})');
                        final effectiveDraftDesc = displayDraftDesc.isNotEmpty
                            ? displayDraftDesc
                            : _getContextualDraftDescription(
                                primaryDraftType, _isBangla);

                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF2E261E),
                                        const Color(0xFF221D17)
                                      ]
                                    : [
                                        const Color(0xFFF7F2E7),
                                        const Color(0xFFEEE6D5)
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: bronzePrimary.withOpacity(0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isBangla
                                      ? 'এই বিষয়ের আনুষ্ঠানিক আইনি খসড়া ও আবেদনপত্র প্রস্তুত করতে চান?'
                                      : 'Ready to prepare a formal legal draft?',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: bronzePrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: bronzePrimary.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.description_outlined,
                                        size: 18,
                                        color: bronzePrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        effectiveDraftTitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (effectiveDraftDesc.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    effectiveDraftDesc,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.45,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: bronzePrimary,
                                      side: BorderSide(
                                          color: bronzePrimary, width: 1.3),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 11),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon:
                                        const Icon(Icons.edit_document, size: 16),
                                    label: Text(
                                      _isBangla
                                          ? '[ — আনুষ্ঠানিক খসড়া তৈরি করুন — ]'
                                          : '[ — PREPARE FORMAL DRAFT — ]',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    onPressed: () => _openDraftEditor(
                                        context, primaryDraftType),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // Subtle Attribution
                  const SizedBox(height: 14),
                  Text(
                    widget.response.engineProvenance ==
                            ProcessingEngine.offlineModel
                        ? (_isBangla
                            ? '— MyLaws · সম্পূর্ণ অফলাইনে লোকাল Llama 3.2 1B ও সংবিধিবদ্ধ ধারা দ্বারা প্রস্তুত'
                            : '— MyLaws · Generated completely offline by local Llama 3.2 1B & statutory pack')
                        : widget.response.engineProvenance ==
                                ProcessingEngine.offlineGuided
                            ? (_isBangla
                                ? '— MyLaws · অফলাইন সংবিধিবদ্ধ আইনি ধারা দ্বারা যাচাইকৃত'
                                : '— MyLaws · Verified by offline statutory pack')
                            : (_isBangla
                                ? '— MyLaws · ১২০০+ গেজেট ও সংবিধিবদ্ধ ধারা দ্বারা যাচাইকৃত'
                                : '— MyLaws · Verified against Bangladesh Code statutory provisions'),
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: secondaryTextColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              crossFadeState: _isTypingComplete
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // Top Action Bar inside the unified card
  // =========================================================================
  Widget _buildTopActionBar({
    required BuildContext context,
    required bool isDark,
    required Color bronzePrimary,
    required Color bronzeContainer,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Persona Avatar: Official MyLaws Brand Emblem Logo
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF26201B) : const Color(0xFFF2ECE1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: bronzePrimary.withOpacity(0.4),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4.5),
          child: Image.asset(
            isDark
                ? 'assets/images/mylaws_emblem_gold.png'
                : 'assets/images/mylaws_emblem_light.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              isDark
                  ? 'assets/images/mylaws_brand_logo_dark.png'
                  : 'assets/images/mylaws_brand_logo_transparent.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.balance_rounded,
                size: 18,
                color: bronzePrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Persona Title and Timestamp: "MyLaws"
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MyLaws',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 2,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 3.5),
                      Text(
                        _formattedTimestamp,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      final isOfflineModel = widget.response.engineProvenance ==
                          ProcessingEngine.offlineModel;
                      final isOfflineGuided =
                          widget.response.engineProvenance ==
                              ProcessingEngine.offlineGuided;

                      if (isOfflineModel) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.memory_rounded,
                              size: 12.5,
                              color: bronzePrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _isBangla
                                  ? 'অফলাইন Llama 3.2'
                                  : 'Offline Llama 3.2',
                              style: TextStyle(
                                fontSize: 11,
                                color: bronzePrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      }

                      if (isOfflineGuided) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.offline_pin_rounded,
                              size: 12.5,
                              color: bronzePrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _isBangla
                                  ? 'অফলাইন ডেটাবেজ'
                                  : 'Offline Database',
                              style: TextStyle(
                                fontSize: 11,
                                color: bronzePrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: bronzePrimary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _isBangla ? 'যাচাইকৃত' : 'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Action Buttons Row (Unified Height and Symmetrical Midline Alignment)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // In-place Dynamic Translation Action Pill
            Tooltip(
              message: _isBangla
                  ? (_isTranslating
                      ? 'Translating to English...'
                      : 'Translate to English')
                  : (_isTranslating
                      ? 'বাংলায় অনুবাদ হচ্ছে...'
                      : 'বাংলায় অনুবাদ করুন'),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: _isTranslating ? null : _toggleLanguage,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFE4E4E7)
                            : const Color(0xFF09090B),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isTranslating)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: isDark
                                  ? const Color(0xFF18181B)
                                  : Colors.white,
                            ),
                          )
                        else
                          Icon(
                            Icons.translate_rounded,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF18181B)
                                : Colors.white,
                          ),
                        const SizedBox(width: 5),
                        Text(
                          _isTranslating
                              ? (_isBangla ? 'অনুবাদ...' : 'English...')
                              : (_isBangla ? 'English' : 'বাংলা'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: isDark
                                ? const Color(0xFF18181B)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),

            // Copy Button
            Tooltip(
              message: _isBangla ? 'উত্তর কপি করুন' : 'Copy answer',
              child: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 17),
                color: secondaryTextColor,
                visualDensity: VisualDensity.compact,
                splashRadius: 16,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
                onPressed: () => _copyAnswer(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // Typography: Rich text formatter with headings, steps, and legal terms
  // =========================================================================
  static Widget _buildLegalRichText({
    required String text,
    required TextStyle baseStyle,
    required TextStyle boldStyle,
    bool showCursor = false,
    Color? cursorColor,
  }) {
    if (text.isEmpty && !showCursor) return const SizedBox.shrink();

    final spans = <TextSpan>[];
    final lines = text.split('\n');

    final headingStyle = boldStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 15) + 1.8,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      height: 1.5,
    );

    final stepTitleStyle = boldStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 15) + 0.6,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.15,
      height: 1.5,
    );

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];

      // 1. Check for Markdown Headings: #, ##, ###, ####
      final headingMatch = RegExp(r'^(#{1,4})\s*(.*)$').firstMatch(rawLine);
      if (headingMatch != null) {
        final headingText = headingMatch.group(2)!.trim();
        if (headingText.isNotEmpty) {
          if (spans.isNotEmpty &&
              spans.last.text?.endsWith('\n\n') != true &&
              spans.last.text?.endsWith('\n') != true) {
            spans.add(const TextSpan(text: '\n\n'));
          } else if (spans.isNotEmpty && spans.last.text?.endsWith('\n') == true) {
            spans.add(const TextSpan(text: '\n'));
          }
          spans.add(TextSpan(text: headingText, style: headingStyle));
          if (i < lines.length - 1) {
            spans.add(const TextSpan(text: '\n\n'));
          }
        }
        continue;
      }

      // 2. Check for empty line (paragraph separation)
      if (rawLine.trim().isEmpty) {
        if (i < lines.length - 1 &&
            spans.isNotEmpty &&
            spans.last.text?.endsWith('\n\n') != true) {
          spans.add(const TextSpan(text: '\n\n'));
        }
        continue;
      }

      // 3. Process line content with inline bold and keyword highlighting
      String lineContent = rawLine;
      if (RegExp(r'^\s*[-*•]\s+').hasMatch(lineContent)) {
        lineContent = lineContent.replaceFirst(RegExp(r'^\s*[-*•]\s+'), '• ');
      }

      final regex = RegExp(r'(\*\*([^*]+)\*\*|<strong>([^<]+)</strong>)');
      int lastMatchEnd = 0;

      for (final match in regex.allMatches(lineContent)) {
        if (match.start > lastMatchEnd) {
          final sub = lineContent.substring(lastMatchEnd, match.start);
          spans.addAll(_highlightKeywords(sub, baseStyle, boldStyle));
        }
        final boldContent = match.group(2) ?? match.group(3) ?? '';
        final isNumberedStep =
            RegExp(r'^(\d+|[০-৯]+)\.\s*').hasMatch(boldContent);
        spans.add(TextSpan(
          text: boldContent,
          style: isNumberedStep ? stepTitleStyle : boldStyle,
        ));
        lastMatchEnd = match.end;
      }

      if (lastMatchEnd < lineContent.length) {
        final remaining = lineContent.substring(lastMatchEnd);
        spans.addAll(_highlightKeywords(remaining, baseStyle, boldStyle));
      }

      // Add line break if not the last line and didn't just end with a newline
      if (i < lines.length - 1 &&
          spans.isNotEmpty &&
          spans.last.text?.endsWith('\n') != true) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    if (showCursor) {
      spans.add(
        TextSpan(
          text: ' ▌',
          style: TextStyle(
            color: cursorColor ?? boldStyle.color,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }

  static List<TextSpan> _highlightKeywords(
      String raw, TextStyle base, TextStyle bold) {
    const keywords = [
      'বাংলাদেশ শ্রম আইন, ২০০৬',
      'বাংলাদেশ শ্রম আইন',
      'শ্রম আদালত',
      'ধারা ১৩২',
      'ধারা ১২৩',
      'ধারা ১২৪ক',
      'ধারা ৫',
      'বকেয়া মজুরি',
      '২৫% অতিরিক্ত ক্ষতিপূরণ',
      '২৫% জরিমানা',
      'ডিআইএফই (DIFE)',
      'ডিআইএফই',
      'ভোক্তা অধিকার সংরক্ষণ অধিদপ্তর',
      'ভোক্তা অধিকার',
      'সাধারণ ডায়েরি (GD)',
      'সাধারণ ডায়েরি',
      'ফৌজদারি কার্যবিধি',
      'আইনি নোটিশ',
      '৭ কর্মদিবস',
      '১২ মাস',
      'Bangladesh Labour Act, 2006',
      'Bangladesh Labour Act',
      'Labour Court',
      'Section 132',
      'Section 123',
      'Section 124A',
      'Section 5',
      'unpaid wages',
      '25% statutory compensation',
      '25% penalty',
      'DIFE',
      'DNCRP',
      'General Diary (GD)',
      'General Diary',
      'CrPC',
      '7 working days',
      '12 months',
    ];

    final escaped = keywords.map(RegExp.escape).join('|');
    final pattern = RegExp('($escaped)', caseSensitive: false);

    final result = <TextSpan>[];
    int lastIndex = 0;
    for (final m in pattern.allMatches(raw)) {
      if (m.start > lastIndex) {
        result.add(
            TextSpan(text: raw.substring(lastIndex, m.start), style: base));
      }
      result.add(TextSpan(text: raw.substring(m.start, m.end), style: bold));
      lastIndex = m.end;
    }
    if (lastIndex < raw.length) {
      result.add(TextSpan(text: raw.substring(lastIndex), style: base));
    }
    return result;
  }
}
