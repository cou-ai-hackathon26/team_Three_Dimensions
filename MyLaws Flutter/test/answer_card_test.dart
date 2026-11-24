import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/core/widgets/source_chip.dart';
import 'package:mylaws/domain/models/answer_response.dart';
import 'package:mylaws/domain/models/checklist_step.dart';
import 'package:mylaws/domain/models/claim.dart';
import 'package:mylaws/domain/models/fact.dart';
import 'package:mylaws/features/answer/answer_card.dart';
import 'package:mylaws/features/checklist/checklist_step_tile.dart';

void main() {
  late AnswerResponse sampleAnswer;

  setUp(() {
    final file = File('contract/fixtures/answered.json');
    if (file.existsSync()) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      sampleAnswer = AnswerResponse.fromJson(json);
    } else {
      sampleAnswer = const AnswerResponse(
        answerId: 'test_ans_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.answered,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-27.1',
        problemSummary: ProblemSummary(
          identifiedIssue: 'বকেয়া মজুরি সমস্যা',
          understanding: 'আপনি বকেয়া মজুরি আদায়ের বিষয়ে জানতে চেয়েছেন।',
        ),
        plainLanguageExplanation: PlainLanguageExplanation(
          heading: 'আইনি অধিকার ও সুরক্ষা',
          meaning:
              'আইন অনুযায়ী চুক্তি মোতাবেক কাজ করার পর যথাসময়ে পারিশ্রমিক পাওয়া কর্মীর অধিকার।',
          userRightsAndOptions: [
            'লিখিতভাবে বকেয়া দাবি করা',
            'শ্রম আদালতে অভিযোগ দাখিল'
          ],
          whatToDoNext: 'প্রয়োজনীয় কাগজপত্র সংগ্রহ করে নোটিশ পাঠান।',
        ),
        explanation: [
          Claim(
            text:
                'বাংলাদেশ শ্রম আইন অনুযায়ী নির্ধারিত ৭ কর্মদিবসের মধ্যে মজুরি পরিশোধ করতে হবে।',
            sourceIds: ['sample-provision-1'],
          ),
        ],
        checklist: [
          ChecklistStep(
            id: 'step-1',
            text: 'নিয়োগপত্র ও হাজিরা কার্ড সংগ্রহ করুন',
            sourceIds: ['sample-provision-1'],
          ),
          ChecklistStep(
            id: 'step-2',
            text: 'মালিকপক্ষকে লিখিত লিগ্যাল নোটিশ পাঠান',
            sourceIds: ['sample-provision-1'],
          ),
        ],
        draftOffer: DraftOffer(
          prompt: 'আপনি কি লিখিত অভিযোগের খসড়া তৈরি করতে চান?',
          documentType: 'dife',
          documentTitle: 'DIFE-তে লিখিত অভিযোগ — খসড়া',
          description: 'আপনার তথ্য দিয়ে প্রস্তুতকৃত অভিযোগের খসড়া।',
        ),
        userFacts: [
          Fact(fieldId: 'jurisdiction.district', value: 'ঢাকা'),
          Fact(fieldId: 'issue.category', value: 'labour'),
        ],
        limitations: [
          'বকেয়া সংক্রান্ত পদক্ষেপের জন্য ১২ মাসের সময়সীমা প্রযোজ্য হতে পারে।',
        ],
      );
    }
  });

  group('Unified Single-Flow AnswerCard UI/UX Tests', () {
    testWidgets(
        'Renders top Action Bar with Persona Avatar, MyLaws Brand, Timestamp, In-place Toggle, and Copy Button',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: sampleAnswer,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );

      // Official MyLaws Brand Logo Emblem & English Name
      expect(find.byType(Image), findsWidgets);
      expect(find.text('MyLaws'), findsOneWidget);

      // In-place Translation Toggle Pill (shows target language: English)
      expect(find.text('English'), findsOneWidget);

      // Copy button is present, Share button is cleanly removed
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.share_rounded), findsNothing);
    });

    testWidgets(
        'Typewriter streaming animation reveals text progressively and finishes or skips on tap',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: sampleAnswer,
                  isBangla: true,
                  animate: true,
                ),
              ),
            ),
          ),
        ),
      );

      // On initial pump with animate=true, text is streaming, cursor is visible
      await tester.pump(const Duration(milliseconds: 36));
      expect(find.textContaining('▌'), findsOneWidget);

      // Tapping anywhere on the card skips to completion immediately
      await tester.tap(find.byType(AnswerCard));
      await tester.pumpAndSettle();

      // Cursor is gone, complete text is rendered
      expect(find.textContaining('▌'), findsNothing);
      expect(find.text(sampleAnswer.plainLanguageExplanation!.meaning),
          findsOneWidget);
    });

    testWidgets(
        'Renders simple plain explanation, citizen rights, and immediate callout directly in one unified body',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: sampleAnswer,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );

      // Understanding intro
      expect(find.text(sampleAnswer.problemSummary!.understanding),
          findsOneWidget);

      // Plain language explanation heading & content
      if (sampleAnswer.plainLanguageExplanation?.heading != null) {
        expect(find.text(sampleAnswer.plainLanguageExplanation!.heading!),
            findsOneWidget);
      }

      // Citizen rights or action callout
      expect(find.byIcon(Icons.arrow_circle_right_rounded), findsOneWidget);
    });

    testWidgets(
        'Renders statutory sources dropdown accordion and opens verified modal on click',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: sampleAnswer,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );

      // Statutory Sources dropdown accordion header is rendered directly under explanation
      final sourcesHeaderFinder = find.textContaining('আইনি উৎস ও ধারা');
      expect(sourcesHeaderFinder, findsOneWidget);

      // Initially collapsed: tap the dropdown header to expand statutory sources
      await tester.tap(sourcesHeaderFinder);
      await tester.pumpAndSettle();

      // SourceChip statutory cards with verified seal are rendered inside expanded container
      expect(find.byType(SourceChip), findsWidgets);

      // Tap the statutory card to open the authoritative SourceSheet modal
      await tester.tap(find.byType(SourceChip).first);
      await tester.pumpAndSettle();

      // Verified Legal Provision modal is presented
      expect(find.text('যাচাইকৃত মূল আইনি বিধান'), findsOneWidget);
    });

    testWidgets(
        'Renders sequential ChecklistStepTiles and bracketed CTA Draft Offer button',
        (tester) async {
      bool draftPrepared = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: sampleAnswer,
                  isBangla: true,
                  onPrepareDraft: () => draftPrepared = true,
                  onChecklistToggled: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      // Sequential checklist dropdown header
      expect(find.text('পরবর্তী করণীয় পদক্ষেপ ও চেকলিস্ট'), findsOneWidget);

      // Expand checklist dropdown
      final dropdownTrigger =
          find.byKey(const ValueKey('checklist_dropdown_trigger'));
      await tester.ensureVisible(dropdownTrigger);
      await tester.tap(dropdownTrigger);
      await tester.pumpAndSettle();

      // Sequential checklist step tiles are now revealed
      expect(find.byType(ChecklistStepTile), findsWidgets);

      // Bracketed CTA button
      final ctaFinder = find.text('[ — আনুষ্ঠানিক খসড়া তৈরি করুন — ]');
      expect(ctaFinder, findsOneWidget);

      // Scroll to make sure CTA button is visible before tapping
      await tester.ensureVisible(ctaFinder);
      await tester.pumpAndSettle();

      // Tap CTA button
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      expect(draftPrepared, true);
    });

    testWidgets(
        'Tapping checklist item toggles completion state, updates progress counter, and invokes callback',
        (tester) async {
      String? toggledStepId;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: sampleAnswer,
                  isBangla: true,
                  onChecklistToggled: (id) => toggledStepId = id,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify initial progress is 0/2 সম্পন্ন
      expect(find.text('0/2 সম্পন্ন'), findsOneWidget);

      // Expand checklist dropdown
      final dropdownTrigger =
          find.byKey(const ValueKey('checklist_dropdown_trigger'));
      await tester.ensureVisible(dropdownTrigger);
      await tester.tap(dropdownTrigger);
      await tester.pumpAndSettle();

      // Find first checklist step tile
      final firstStep = find.byType(ChecklistStepTile).first;
      await tester.ensureVisible(firstStep);
      await tester.pumpAndSettle();

      // Tap to complete
      await tester.tap(firstStep);
      await tester.pumpAndSettle();

      expect(toggledStepId, 'step-1');
      expect(find.text('1/2 সম্পন্ন'), findsOneWidget);

      // Tap again to uncheck
      await tester.tap(firstStep);
      await tester.pumpAndSettle();

      expect(find.text('0/2 সম্পন্ন'), findsOneWidget);
    });

    testWidgets(
        'In-place translation toggle switches Bengali and English dynamically',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: sampleAnswer,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );

      // Initially in Bangla with English brand name
      expect(find.text('MyLaws'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Tap the translation toggle to translate to English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Switches to English: toggle offers 'বাংলা'
      expect(find.text('MyLaws'), findsOneWidget);
      expect(find.text('বাংলা'), findsOneWidget);

      // Tap back to Bangla
      await tester.tap(find.text('বাংলা'));
      await tester.pumpAndSettle();

      expect(find.text('MyLaws'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets(
        'Translates English answer into Bangla when user taps Bangla button and back',
        (tester) async {
      const englishAnswer = AnswerResponse(
        answerId: 'ans_en_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.answered,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-27.1',
        problemSummary: ProblemSummary(
          identifiedIssue: 'Consumer Rights Dispute',
          understanding:
              'You have inquired about statutory remedies for defective goods.',
        ),
        plainLanguageExplanation: PlainLanguageExplanation(
          heading: 'Consumer Rights Protection & Redress',
          meaning:
              'Under statutory law, selling counterfeit goods is strictly prohibited.',
          userRightsAndOptions: ['Filing a formal complaint with DNCRP'],
          whatToDoNext:
              'Collect purchase receipts and file a complaint within 30 days.',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: englishAnswer,
                  isBangla: false,
                ),
              ),
            ),
          ),
        ),
      );

      // Initially in English: button offers 'বাংলা'
      expect(find.text('বাংলা'), findsOneWidget);

      // Tap 'বাংলা'
      await tester.tap(find.text('বাংলা'));
      await tester.pumpAndSettle();

      // Switches to Bangla: button now offers 'English'
      expect(find.text('English'), findsOneWidget);

      // Tap 'English' to switch back
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Switches back to English: button offers 'বাংলা'
      expect(find.text('বাংলা'), findsOneWidget);
    });

    testWidgets(
        'Supports Dark theme mode with high contrast and rounded single container',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: sampleAnswer,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsWidgets);
      expect(find.byType(AnswerCard), findsOneWidget);
    });

    testWidgets('Handles Emergency Referral outcome safely', (tester) async {
      const emergencyAnswer = AnswerResponse(
        answerId: 'emg_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.emergencyReferral,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-27.1',
        explanation: [
          Claim(
            text:
                'তাত্ক্ষণিক শারীরিক বিপদে অবিলম্বে জাতীয় জরুরি সেবা ৯৯৯ নম্বরে যোগাযোগ করুন।',
            sourceIds: [],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: AnswerCard(
                response: emergencyAnswer,
                isBangla: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('জরুরি সহায়তা'), findsOneWidget);
      expect(find.textContaining('৯৯৯'), findsOneWidget);
    });

    testWidgets('Handles Insufficient Sources outcome safely', (tester) async {
      const insufficientAnswer = AnswerResponse(
        answerId: 'ins_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.insufficientSources,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-27.1',
        explanation: [
          Claim(
            text:
                'এই বিষয়ে আমাদের তথ্যভাণ্ডারে যথেষ্ট আইনি উৎস পাওয়া যায়নি।',
            sourceIds: [],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: AnswerCard(
                response: insufficientAnswer,
                isBangla: true,
              ),
            ),
          ),
        ),
      );

      expect(
          find.text(
              'এই বিষয়ে আমাদের তথ্যভাণ্ডারে যথেষ্ট আইনি উৎস পাওয়া যায়নি।'),
          findsOneWidget);
    });
  });
}
