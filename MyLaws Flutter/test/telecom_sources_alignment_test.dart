import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/core/data/legal_provisions_catalog.dart';
import 'package:mylaws/core/services/legal_translation_service.dart';
import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/domain/models/answer_response.dart';
import 'package:mylaws/domain/models/claim.dart';
import 'package:mylaws/domain/models/fact.dart';
import 'package:mylaws/features/answer/answer_card.dart';

void main() {
  group('Telecom & SIM Sources Alignment Tests', () {
    test('Catalog contains statutory provisions for telecom-66, telecom-67, and cyber-26', () {
      final t66 = LegalProvisionsCatalog.getById('telecom-66');
      expect(t66, isNotNull);
      expect(t66!.actNameBn, contains('বাংলাদেশ টেলিযোগাযোগ নিয়ন্ত্রণ আইন, ২০০১'));
      expect(t66.section, contains('Section 66'));
      expect(t66.title, contains('টেলিফোনে আপত্তিকর, অশ্লীল, হুমকি বা উৎপাতমূলক'));

      final t67 = LegalProvisionsCatalog.getById('telecom-67');
      expect(t67, isNotNull);
      expect(t67!.actNameBn, contains('বাংলাদেশ টেলিযোগাযোগ নিয়ন্ত্রণ আইন, ২০০১'));
      expect(t67.section, contains('Section 67'));
      expect(t67.title, contains('বায়োমেট্রিক নিবন্ধনহীন বা অন্যের এনআইডিতে ভুয়া সিম'));

      final c26 = LegalProvisionsCatalog.getById('cyber-26');
      expect(c26, isNotNull);
      expect(c26!.actNameBn, contains('সাইবার নিরাপত্তা আইন, ২০২৩'));
      expect(c26.section, contains('Section 26'));
    });

    test('Resolves human-readable Act names and Section numbers accurately', () {
      expect(LegalProvisionsCatalog.resolveActName('telecom-67', true),
          contains('বাংলাদেশ টেলিযোগাযোগ নিয়ন্ত্রণ আইন'));
      expect(LegalProvisionsCatalog.resolveSectionNumber('telecom-67', true),
          equals('ধারা ৬৭'));

      expect(LegalProvisionsCatalog.resolveActName('cyber-26', true),
          contains('সাইবার নিরাপত্তা আইন'));
      expect(LegalProvisionsCatalog.resolveSectionNumber('cyber-26', true),
          equals('ধারা ২৬'));

      // Never produces empty section "ধারা "
      expect(LegalProvisionsCatalog.resolveSectionNumber('unknown-statute', true),
          isNot(equals('ধারা ')));

      // 16001 code is resolved to BTRC directive rather than "ধারা 16001"
      expect(LegalProvisionsCatalog.resolveSectionNumber('btrc-sim-16001', true),
          contains('বিটিআরসি'));
    });

    test('Preserves "বিরক্তিকর মার্কেটিং কল" without transforming into "দুশ্চিন্তার বিষয় মার্কেটিং কল"', () {
      const input = 'আর প্রমোশনাল স্প্যাম বা বারবার বিরক্তিকর মার্কেটিং কল আসলে অপারেটরের ফ্রি Do Not Disturb (DND) সার্ভিস চালু করে বন্ধ করতে পারেন।';
      final sanitized = LegalTranslationService.cleanBrandName(input);
      expect(sanitized, contains('বিরক্তিকর মার্কেটিং কল'));
      expect(sanitized, isNot(contains('দুশ্চিন্তার বিষয় মার্কেটিং কল')));
    });

    testWidgets('AnswerCard automatically aligns sources to telecom and cyber provisions for SIM queries',
        (tester) async {
      const simResponse = AnswerResponse(
        answerId: 'sim_test_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.answered,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-27.1',
        plainLanguageExplanation: PlainLanguageExplanation(
          meaning:
              'BTRC আপনার সুরক্ষার জন্য কিছু ব্যবস্থা রেখেছে। আপনি *16001# ডায়াল করে আপনার NID দিয়ে সিমের সংখ্যা চেক করতে পারেন। অচেনা সিম বা অচেনা নম্বর বন্ধ করুন।',
          whatToDoNext: 'অচেনা সিম বন্ধ করুন এবং অপারেটরে জানান।',
        ),
        // Simulate backend sending incongruent arrest remand guidelines
        explanation: [
          Claim(
            text: 'ব্লাস্ট রিমান্ড গাইডলাইন',
            sourceIds: ['blast-guidelines-remand-167', 'blast-guidelines-arrest-54'],
          ),
        ],
        userFacts: [
          Fact(fieldId: 'issue.category', value: 'threats', status: FactStatus.inferred),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: AnswerCard(
                response: simResponse,
                isBangla: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on Sources dropdown accordion
      final sourcesHeader = find.textContaining('আইনি উৎস ও ধারা');
      expect(sourcesHeader, findsOneWidget);
      await tester.tap(sourcesHeader);
      await tester.pumpAndSettle();

      // Verify that incongruent arrest sources are replaced with proper Telecom & Cyber provisions
      expect(find.textContaining('বাংলাদেশ টেলিযোগাযোগ নিয়ন্ত্রণ আইন, ২০০১'), findsWidgets);
      expect(find.textContaining('সাইবার নিরাপত্তা আইন, ২০২৩'), findsWidgets);
      expect(find.textContaining('ধারা ৬৭'), findsWidgets);
      expect(find.textContaining('ধারা ৬৬'), findsWidgets);
      expect(find.textContaining('ধারা ২৬'), findsWidgets);
    });

    test('Catalog contains accurate provisions for BSTI, BTRC Directives, and Blackmail/Extortion', () {
      final bsti1 = LegalProvisionsCatalog.getById('bsti-1');
      expect(bsti1, isNotNull);
      expect(bsti1!.actNameBn, contains('বাংলাদেশ স্ট্যান্ডার্ডস অ্যান্ড টেস্টিং ইনস্টিটিউশন আইন, ২০১৮'));
      expect(bsti1.title, contains('বাধ্যতামূলক পণ্যের গুণগত মান'));

      final bsti24 = LegalProvisionsCatalog.getById('bsti-24');
      expect(bsti24, isNotNull);
      expect(bsti24!.actNameBn, contains('বাংলাদেশ স্ট্যান্ডার্ডস অ্যান্ড টেস্টিং ইনস্টিটিউশন আইন, ২০১৮'));
      expect(bsti24.section, contains('Section 24'));

      final btrcDnd = LegalProvisionsCatalog.getById('btrc-dnd-spam');
      expect(btrcDnd, isNotNull);
      expect(btrcDnd!.actNameBn, contains('বাংলাদেশ টেলিযোগাযোগ নিয়ন্ত্রণ আইন'));
      expect(btrcDnd.title, contains('ডু নট ডিস্টার্ব (DND)'));

      final p384 = LegalProvisionsCatalog.getById('penal-384');
      expect(p384, isNotNull);
      expect(p384!.actNameBn, contains('দণ্ডবিধি, ১৮৬০'));
      expect(p384.section, contains('Section 384'));
      expect(p384.title, contains('চাঁদাবাজি ও ব্ল্যাকমেইল করার শাস্তি'));

      final porno8 = LegalProvisionsCatalog.getById('pornography-8');
      expect(porno8, isNotNull);
      expect(porno8!.actNameBn, contains('পর্নোগ্রাফি নিয়ন্ত্রণ আইন, ২০১২'));
      expect(porno8.section, contains('Section 8'));
    });

    testWidgets('AnswerCard automatically aligns sources to Penal Code and Pornography Act for Blackmail queries',
        (tester) async {
      const blackmailResponse = AnswerResponse(
        answerId: 'blackmail_test_01',
        engineProvenance: ProcessingEngine.onlineMeta,
        outcome: Outcome.answered,
        status: 'completed',
        sourcePackVersion: 'bd-pilot-2026-10-27.1',
        plainLanguageExplanation: PlainLanguageExplanation(
          meaning:
              'জিডি বা মামলা করতে পারবেন, CID এর সাইবার পুলিশ সেন্টারে অভিযোগ করতে পারবেন, আর টাকা না থাকলে সরকারি বিনামূল্যে লিগ্যাল এইডও (হেল্পলাইন ১৬৪৩০) পেতে পারেন। ভয় পেয়ে টাকা দেবেন না, এতে ব্ল্যাকমেইলার আরও সাহস পায়। গোপন ছবি দিয়ে ব্ল্যাকমেইল করা গুরুতর অপরাধ।',
          whatToDoNext: 'টাকা দেবেন না এবং সাইবার পুলিশ হেল্পলাইনে যোগাযোগ করুন।',
        ),
        // Incongruent BSTI sources that D1 returned
        explanation: [
          Claim(
            text: 'বিএসটিআই মানচিহ্ন',
            sourceIds: ['bsti-1', 'bsti-10', 'bsti-2'],
          ),
        ],
        userFacts: [
          Fact(fieldId: 'issue.category', value: 'consumer', status: FactStatus.inferred),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: AnswerCard(
                response: blackmailResponse,
                isBangla: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final sourcesHeader = find.textContaining('আইনি উৎস ও ধারা');
      expect(sourcesHeader, findsOneWidget);
      await tester.tap(sourcesHeader);
      await tester.pumpAndSettle();

      // Verify that incongruent BSTI sources are replaced with proper Penal Code & Pornography provisions
      expect(find.textContaining('দণ্ডবিধি, ১৮৬০'), findsWidgets);
      expect(find.textContaining('পর্নোগ্রাফি নিয়ন্ত্রণ আইন, ২০১২'), findsWidgets);
      expect(find.textContaining('সাইবার নিরাপত্তা আইন, ২০২৩'), findsWidgets);
      expect(find.textContaining('ধারা ৩৮৪'), findsWidgets);
      expect(find.textContaining('ধারা ৮'), findsWidgets);
      expect(find.textContaining('ধারা ২৬'), findsWidgets);
    });
  });
}
