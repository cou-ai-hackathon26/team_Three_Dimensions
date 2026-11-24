import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/core/data/legal_provisions_catalog.dart';
import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/core/widgets/source_sheet.dart';
import 'package:mylaws/domain/models/answer_response.dart';
import 'package:mylaws/domain/models/checklist_step.dart';
import 'package:mylaws/domain/models/claim.dart';
import 'package:mylaws/domain/models/fact.dart';
import 'package:mylaws/features/answer/answer_card.dart';
import 'package:mylaws/features/drafts/draft_editor_screen.dart';

void main() {
  group('LegalProvisionsCatalog & SourceSheet Tests', () {
    test(
        'LegalProvisionsCatalog contains acquisition-1, acquisition-14, and sat-143',
        () {
      final acq1 = LegalProvisionsCatalog.getById('acquisition-1');
      expect(acq1, isNotNull);
      expect(acq1!.title, contains('স্থাবর সম্পত্তি অধিগ্রহণ'));
      expect(acq1.provisionPath, contains('ধারা ১'));
      expect(acq1.originalText, isNotEmpty);
      expect(acq1.plainExplanation, isNotEmpty);
      expect(acq1.officialUrl, contains('bdlaws.minlaw.gov.bd'));

      final acq14 = LegalProvisionsCatalog.getById('acquisition-14');
      expect(acq14, isNotNull);
      expect(acq14!.provisionPath, contains('ধারা ১৪'));
      expect(acq14.plainExplanation, contains('অধিগ্রহণ কার্যক্রম বাতিল'));

      final sat143 = LegalProvisionsCatalog.getById('sat-143');
      expect(sat143, isNotNull);
      expect(sat143!.title, contains('রাষ্ট্রীয় অধিগ্রহণ ও প্রজাস্বত্ব'));
      expect(sat143.provisionPath, contains('ধারা ১৪৩'));
    });

    testWidgets(
        'SourceSheet displays full statutory passage and plain explanation without blank error',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SourceSheet(
              sourceId: 'acquisition-1',
              isBangla: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title & Provision Path
      expect(find.text('স্থাবর সম্পত্তি অধিগ্রহণ ও হুকুমদখল আইন, ২০১৭'),
          findsOneWidget);
      expect(find.textContaining('ধারা ১ — সংক্ষিপ্ত শিরোনাম ও প্রবর্তন'),
          findsOneWidget);

      // Status badges
      expect(find.text('কার্যকর আইন'), findsOneWidget);
      expect(find.text('মেশিন-যাচাইকৃত'), findsOneWidget);

      // Original statutory passage - NOT blank or "not currently saved offline"
      expect(
          find.textContaining('জনস্বার্থে বা সরকারি প্রয়োজনে'), findsOneWidget);
      expect(find.textContaining('মূল ধারাটি এই মুহূর্তে অফলাইনে সংরক্ষিত নেই'),
          findsNothing);

      // Drag to reveal full sheet contents
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Plain explanation
      expect(find.textContaining('২০১৭ সালের ২১ সেপ্টেম্বর'), findsOneWidget);

      // BDLaws link button
      expect(find.text('সরকারি BDLaws পোর্টালে সম্পূর্ণ আইনটি দেখুন'),
          findsOneWidget);
    });
  });

  group('Contextual Draft Suggestions in AnswerCard', () {
    testWidgets(
        'Renders in-line draft button on checklist step and bottom contextual draft card',
        (tester) async {
      bool draftPrepared = false;

      const response = AnswerResponse(
        answerId: 'land_case_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.answered,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-30.3',
        problemSummary: ProblemSummary(
          identifiedIssue: 'জমির দখল সংক্রান্ত বিরোধ',
          understanding: 'আপনার পৈতৃক জমি প্রতিপক্ষ জোরপূর্বক দখল করে নিয়েছে।',
        ),
        plainLanguageExplanation: PlainLanguageExplanation(
          heading: 'দখল পুনরুদ্ধারের আইনি প্রতিকার',
          meaning:
              'সুনির্দিষ্ট প্রতিকার আইনের ৯ ধারা অনুযায়ী আপনি দেওয়ানি আদালতে দখল পুনরুদ্ধারের মোকদ্দমা দায়ের করতে পারেন।',
          whatToDoNext: 'প্রয়োজনীয় কাগজপত্র সংগ্রহ করে আরজি প্রস্তুত করুন।',
        ),
        explanation: [
          Claim(
            text:
                'সুনির্দিষ্ট প্রতিকার আইনের ৯ ধারা অনুযায়ী ৬ মাসের মধ্যে আরজি দাখিল করতে হবে।',
            sourceIds: ['acquisition-1', 'acquisition-14'],
          ),
        ],
        checklist: [
          ChecklistStep(
            id: 'step-1',
            text: 'জমির মূল দলিল, পরচা ও খাজনার দাখিলা গুছিয়ে রাখুন।',
            sourceIds: ['acquisition-1'],
          ),
          ChecklistStep(
            id: 'step-2',
            text:
                'দেওয়ানি আদালতে ৯ ধারায় আরজি দাখিল করার জন্য প্রয়োজনীয় খসড়া প্রস্তুত করুন।',
            sourceIds: ['acquisition-14'],
          ),
        ],
        allowedDraftOptions: ['civil_court'],
        userFacts: [
          Fact(fieldId: 'issue.category', value: 'land'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: response,
                  isBangla: true,
                  onPrepareDraft: () => draftPrepared = true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Primary bottom CTA draft offer is displayed even if draftOffer was null
      final mainCtaFinder = find.text('[ — আনুষ্ঠানিক খসড়া তৈরি করুন — ]');
      expect(mainCtaFinder, findsOneWidget);

      // Expand checklist dropdown to view in-line step draft button
      final dropdownTrigger =
          find.byKey(const ValueKey('checklist_dropdown_trigger'));
      await tester.ensureVisible(dropdownTrigger);
      await tester.tap(dropdownTrigger);
      await tester.pumpAndSettle();

      // In-line draft button on step-2 which mentions "খসড়া প্রস্তুত"
      final stepDraftFinder = find.text('খসড়া প্রস্তুত করুন (দেওয়ানি আদালত)');
      expect(stepDraftFinder, findsOneWidget);

      // Tap in-line draft button
      await tester.ensureVisible(stepDraftFinder);
      await tester.tap(stepDraftFinder);
      await tester.pumpAndSettle();

      expect(draftPrepared, isTrue);
      expect(find.byType(DraftEditorScreen), findsOneWidget);
    });

    testWidgets(
        'Tapping Police GD draft button directly opens DraftEditorScreen with prefilled GD format',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const response = AnswerResponse(
        answerId: 'theft_case_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.answered,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-30.3',
        problemSummary: ProblemSummary(
          identifiedIssue: 'বাইক চুরি ও ছিনতাইয়ের শিকার',
          understanding: 'গতরাতে বাজার থেকে আপনার মোটরসাইকেল চুরি হয়ে গেছে।',
        ),
        plainLanguageExplanation: PlainLanguageExplanation(
          heading: 'আইনি অধিকার ও পদক্ষেপ',
          meaning:
              'চুরি দণ্ডবিধির ৩৭৯ ধারার অপরাধ। থানায় দ্রুত সাধারণ ডায়েরি (GD) বা এজাহার করুন।',
          whatToDoNext:
              'কাগজপত্র ও সিসিটিভি ফুটেজসহ নিকটস্থ থানায় লিখিত অভিযোগ দিন।',
        ),
        checklist: [
          ChecklistStep(
            id: 'c-1',
            text: 'প্রমাণ সংরক্ষণ করুন - ক্রয়ের রসিদ ও রেজিস্ট্রেশন কাগজ।',
          ),
          ChecklistStep(
            id: 'c-2',
            text: 'দ্রুত থানায় যান - চুরির ঘটনা উল্লেখ করে GD বা FIR করুন।',
          ),
        ],
        allowedDraftOptions: ['gd'],
        userFacts: [
          Fact(fieldId: 'issue.category', value: 'police'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: response,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand checklist dropdown to view in-line step draft button
      final dropdownTrigger =
          find.byKey(const ValueKey('checklist_dropdown_trigger'));
      await tester.ensureVisible(dropdownTrigger);
      await tester.tap(dropdownTrigger);
      await tester.pumpAndSettle();

      // Verify in-line draft button for Police GD
      final gdButtonFinder = find.text('খসড়া প্রস্তুত করুন (থানা ও পুলিশ)');
      expect(gdButtonFinder, findsOneWidget);

      // Tap in-line draft button
      await tester.ensureVisible(gdButtonFinder);
      await tester.tap(gdButtonFinder);
      await tester.pumpAndSettle();

      // Must open DraftEditorScreen directly, NOT redirect to draft list
      expect(find.byType(DraftEditorScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data?.contains('সাধারণ ডায়েরি') == true ||
                w.data?.contains('General Diary') == true)),
        findsWidgets,
      );
    });

    testWidgets(
        'Suppresses draft card and in-line draft buttons when allowedDraftOptions is empty (e.g. Legal Aid 16699 or informational inquiry)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const response = AnswerResponse(
        answerId: 'legal_aid_16699',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.answered,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-30.3',
        problemSummary: ProblemSummary(
          identifiedIssue: 'সরকারি আইনি সহায়তা সেবা প্রাপ্তি',
          understanding: '১৬৬৯৯ হেল্পলাইনের মাধ্যমে বিনামূল্যে সরকারি আইনি সহায়তা পাওয়ার প্রক্রিয়া জানতে চেয়েছেন।',
        ),
        plainLanguageExplanation: PlainLanguageExplanation(
          heading: 'আইনি অধিকার ও সুবিধা',
          meaning: 'আইনগত সহায়তা প্রদান আইন, ২০০০ অনুযায়ী অসচ্ছল নাগরিকগণ বিনা খরচে সরকারি আইনজীবী পাওয়ার অধিকারী।',
          whatToDoNext: '১৬৬৯৯ নম্বরে কল করে বা জেলা লিগ্যাল এইড অফিসে গিয়ে আবেদন করুন।',
        ),
        checklist: [
          ChecklistStep(
            id: 'c-1',
            text: 'টোল-ফ্রি জাতীয় হেল্পলাইন ১৬৬৯৯ নম্বরে ফোন দিয়ে পরামর্শ নিন।',
          ),
          ChecklistStep(
            id: 'c-2',
            text: 'উপযুক্ত কাগজপত্রসহ জেলা জজ আদালত প্রাঙ্গণে লিগ্যাল এইড কর্মকর্তার সঙ্গে যোগাযোগ করুন।',
          ),
        ],
        allowedDraftOptions: [],
        userFacts: [
          Fact(fieldId: 'issue.category', value: 'legal_aid'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: response,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Bottom formal draft CTA MUST NOT BE RENDERED
      expect(find.text('[ — আনুষ্ঠানিক খসড়া তৈরি করুন — ]'), findsNothing);
      expect(find.textContaining('আনুষ্ঠানিক আবেদনপত্র'), findsNothing);
      expect(find.textContaining('Formal Legal Draft'), findsNothing);

      // Expand checklist dropdown to verify no draft buttons on steps
      final dropdownTrigger =
          find.byKey(const ValueKey('checklist_dropdown_trigger'));
      if (dropdownTrigger.evaluate().isNotEmpty) {
        await tester.tap(dropdownTrigger);
        await tester.pumpAndSettle();
      }

      // No in-line draft buttons should exist
      expect(find.textContaining('খসড়া প্রস্তুত করুন'), findsNothing);
    });

    testWidgets(
        'Suppresses incongruent statutory sources and GD draft for personal family distress query',
        (tester) async {
      // Replicate the exact screenshot scenario where backend returned spurious land acquisition sources and GD draft
      const response = AnswerResponse(
        answerId: 'family_distress_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.answered,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-30.3',
        problemSummary: ProblemSummary(
          identifiedIssue: 'পারিবারিক অশান্তি ও মানসিক সুরক্ষা',
          understanding:
              'আপনার মনের অবস্থাটা আমি বুঝতে পারছি, বাসায় আব্বু-আম্মুর ঝগড়া করে চলে যাওয়াটা আপনার জন্য খুব ভয়ের এবং কষ্টের।',
        ),
        plainLanguageExplanation: PlainLanguageExplanation(
          heading: 'পারিবারিক অশান্তি ও মানসিক সুরক্ষা',
          meaning:
              'আপনার মনের অবস্থাটা আমি বুঝতে পারছি, বাসায় আব্বু-আম্মুর ঝগড়া করে চলে যাওয়াটা আপনার জন্য খুব ভয়ের এবং কষ্টের। এমন সময়ে ভয় লাগা, কান্না পাওয়া, নিজেকে একা লাগা একদম স্বাভাবিক। মনে রাখবেন, এতে আপনার কোনো দোষ নেই — বড়দের ঝগড়া বড়দের বিষয়, একটু পর রাগ কমলে উনারাই ফিরে আসবেন ইনশাআল্লাহ। এখন সবচেয়ে জরুরি হলো আপনি শান্ত থেকে নিরাপদে থাকবেন।',
          whatToDoNext:
              'নিজে শান্ত থাকুন, ঘরের দরজা লাগিয়ে নিরাপদে অবস্থান করুন এবং প্রয়োজনে কোনো বিশ্বস্ত আত্মীয়ের সঙ্গে কথা বলুন।',
        ),
        explanation: [
          Claim(
            text: 'স্থাবর সম্পত্তি অধিগ্রহণ ও হুকুমদখল আইন ২০১৭ ধারা ১',
            sourceIds: ['acquisition-1'],
          ),
          Claim(
            text: 'স্থাবর সম্পত্তি অধিগ্রহণ ও হুকুমদখল আইন ২০১৭ ধারা ১০',
            sourceIds: ['acquisition-10'],
          ),
          Claim(
            text: 'স্থাবর সম্পত্তি অধিগ্রহণ ও হুকুমদখল আইন ২০১৭ ধারা ১৪',
            sourceIds: ['acquisition-14'],
          ),
        ],
        checklist: [
          ChecklistStep(
            id: 'c-1',
            text: 'নিজে শান্ত থাকুন এবং ঘরের দরজা লাগিয়ে নিরাপদে থাকুন।',
          ),
          ChecklistStep(
            id: 'c-2',
            text: 'প্রয়োজনে বিশ্বস্ত আত্মীয় বা সরকারি শিশু হেল্পলাইন ১০৯৮-এ যোগাযোগ করুন।',
          ),
        ],
        allowedDraftOptions: ['gd'],
        userFacts: [
          Fact(fieldId: 'issue.category', value: 'land'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: response,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Spurious statutory sources MUST be completely suppressed
      expect(find.textContaining('আইনি উৎস ও ধারা'), findsNothing);
      expect(find.textContaining('স্থাবর সম্পত্তি অধিগ্রহণ'), findsNothing);

      // 2. Draft preparation CTA MUST NOT be rendered
      expect(find.text('[ — আনুষ্ঠানিক খসড়া তৈরি করুন — ]'), findsNothing);
      expect(find.textContaining('থানায় সাধারণ ডায়েরি'), findsNothing);
      expect(find.textContaining('General Diary'), findsNothing);
    });
  });
}
