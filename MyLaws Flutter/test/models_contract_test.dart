import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/domain/models/answer_response.dart';
import 'package:mylaws/domain/models/checklist_step.dart';
import 'package:mylaws/domain/models/draft_document.dart';
import 'package:mylaws/domain/models/fact.dart';
import 'package:mylaws/domain/models/user_quota.dart';

void main() {
  group('Domain Models & JSON Serialization Tests', () {
    test('Fact model round-trips cleanly', () {
      const fact = Fact(
        fieldId: 'wage_amount',
        label: 'দাবিকৃত বকেয়া টাকা',
        value: '৫০,০০০ টাকা',
        isExtracted: true,
      );

      final json = fact.toJson();
      expect(json['fieldId'], 'wage_amount');
      expect(json['label'], 'দাবিকৃত বকেয়া টাকা');
      expect(json['value'], '৫০,০০০ টাকা');

      final reconstructed = Fact.fromJson(json);
      expect(reconstructed.fieldId, fact.fieldId);
      expect(reconstructed.value, fact.value);
      expect(reconstructed.isExtracted, true);
    });

    test('UserQuota handles boundary and boolean calculations', () {
      const quota = UserQuota(
        dailyLimit: 30,
        usedToday: 30,
        remaining: 0,
        canQuery: false,
        store: 'cloudflare_d1',
      );

      expect(quota.canQuery, false);
      expect(quota.remaining, 0);

      final next = quota.copyWith(usedToday: 29, remaining: 1, canQuery: true);
      expect(next.canQuery, true);
      expect(next.remaining, 1);
    });

    test('ChecklistStep maintains completion state', () {
      const step = ChecklistStep(
        id: 'step_police_gd',
        titleBn: 'নিকটস্থ থানায় যোগাযোগ করুন',
        titleEn: 'Contact Nearest Police Station',
        completed: false,
        requiredDocuments: ['এনআইডি কার্ডের ফটোকপি'],
      );

      expect(step.completed, false);
      final toggled = step.copyWith(completed: true);
      expect(toggled.completed, true);
      expect(toggled.requiredDocuments.length, 1);
    });

    test(
        'DraftDocument supports all 10 canonical document types with verbatim templates',
        () {
      final types = [
        DocumentType.domestic_violence,
        DocumentType.family_maintenance,
        DocumentType.land_mutation,
        DocumentType.land_crime_complaint,
        DocumentType.possession_recovery,
        DocumentType.gd,
        DocumentType.dncrp,
        DocumentType.dife,
        DocumentType.cheque_dishonour,
        DocumentType.bail_petition,
      ];

      expect(DocumentType.values.length, 10);

      for (final type in types) {
        expect(type.titleBn.isNotEmpty, true);
        expect(type.titleEn.isNotEmpty, true);
        expect(type.recipientDefaultBn.isNotEmpty, true);
        expect(type.recipientDefaultEn.isNotEmpty, true);
        expect(type.category.isNotEmpty, true);

        // Verify DraftDocument.getTemplateText produces verbatim format
        final template = DraftDocument.getTemplateText(type);
        expect(template.contains('বিষয়:'), true);
        expect(template.contains('তারিখ'), true);
        expect(
            template.contains('স্বাক্ষর') || template.contains('নিবেদক'), true);
        expect(
            template.contains('প্রার্থনা') ||
                template.contains('প্রার্থিত প্রতিকার') ||
                template.contains('আলটিমেটাম') ||
                template.contains('আল্টিমেটাম'),
            true);

        final doc = DraftDocument.createDefault(type: type);
        expect(doc.type, type);
        expect(doc.paragraphs.isNotEmpty, true);
        expect(doc.recipient.isNotEmpty, true);
      }

      // Verify specific court vs administrative authority headers
      final dvText =
          DraftDocument.getTemplateText(DocumentType.domestic_violence);
      expect(dvText.contains('মোকাম:'), true);
      expect(dvText.contains('পারিবারিক সহিংসতা'), true);
      expect(dvText.contains('হলফনামা / সত্যপাঠ:'), true);

      final fmText =
          DraftDocument.getTemplateText(DocumentType.family_maintenance);
      expect(fmText.contains('মোকাম:'), true);
      expect(fmText.contains('পারিবারিক আদালত আইন, ২০২৩'), true);
      expect(fmText.contains('দেনমোহর'), true);

      final lmText = DraftDocument.getTemplateText(DocumentType.land_mutation);
      expect(lmText.contains('বরাবর'), true);
      expect(lmText.contains('ই-নামজারি'), true);

      final lcText =
          DraftDocument.getTemplateText(DocumentType.land_crime_complaint);
      expect(lcText.contains('ভূমি অপরাধ প্রতিরোধ ও প্রতিকার আইন, ২০২৩'), true);
      expect(lcText.contains('টপসয়েল'), true);

      final prText =
          DraftDocument.getTemplateText(DocumentType.possession_recovery);
      expect(prText.contains('সুনির্দিষ্ট প্রতিকার আইন, ১৮৭৭'), true);
      expect(prText.contains('ধারা ৯'), true);

      final cdText =
          DraftDocument.getTemplateText(DocumentType.cheque_dishonour);
      expect(cdText.contains('ধারা ১৩৮'), true);
      expect(cdText.contains('৩০ (ত্রিশ) দিনের আইনি নোটিশ'), true);
      expect(cdText.contains('Negotiable Instruments Act'), true);

      final bpText = DraftDocument.getTemplateText(DocumentType.bail_petition);
      expect(bpText.contains('মোকাম:'), true);
      expect(bpText.contains('ধারা ৪৯৬ ও ৪৯৭'), true);
      expect(bpText.contains('জামিন মঞ্জুরের'), true);
    });
  });

  group('Contract Synthetic Fixtures Deserialization', () {
    test('Parses answered.json synthetic fixture', () {
      final file = File('contract/fixtures/answered.json');
      expect(file.existsSync(), true,
          reason: 'answered.json fixture must exist');

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final response = AnswerResponse.fromJson(json);

      expect(response.answerId, isNotEmpty);
      expect(response.outcome, Outcome.answered);
      expect(response.engineProvenance, ProcessingEngine.demoFixture);
      expect(response.checklist.length, greaterThan(0));
      expect(response.explanation.length, greaterThan(0));
    });

    test('Parses clarification.json synthetic fixture', () {
      final file = File('contract/fixtures/clarification.json');
      expect(file.existsSync(), true);

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final response = AnswerResponse.fromJson(json);

      expect(response.outcome, Outcome.clarificationNeeded);
      expect(response.clarificationQuestions.length, greaterThan(0));
      expect(response.clarificationQuestions.first.questionText, isNotEmpty);
    });

    test('Parses correction_superseded.json synthetic fixture', () {
      final file = File('contract/fixtures/correction_superseded.json');
      expect(file.existsSync(), true);

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final response = AnswerResponse.fromJson(json);

      expect(response.supersedesAnswerId, isNotNull);
      expect(response.outcome, Outcome.answered);
    });

    test('Parses insufficient_sources.json synthetic fixture', () {
      final file = File('contract/fixtures/insufficient_sources.json');
      expect(file.existsSync(), true);

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final response = AnswerResponse.fromJson(json);

      expect(response.outcome, Outcome.insufficientSources);
      expect(response.limitations.length, greaterThan(0));
    });

    test('Parses emergency_referral.json synthetic fixture', () {
      final file = File('contract/fixtures/emergency_referral.json');
      expect(file.existsSync(), true);

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final response = AnswerResponse.fromJson(json);

      expect(response.outcome, Outcome.emergencyReferral);
      expect(response.limitations.length, greaterThan(0));
    });
  });
}
