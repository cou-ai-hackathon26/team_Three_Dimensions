import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/data/fixtures/demo_fixture_adapter.dart';
import 'package:mylaws/domain/models/answer_request.dart';
import 'package:mylaws/domain/models/answer_response.dart';
import 'package:mylaws/domain/models/draft_document.dart';
import 'package:mylaws/domain/models/pack_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DemoFixtureAdapter Execution & Integrity Tests', () {
    late DemoFixtureAdapter adapter;

    setUp(() {
      adapter = DemoFixtureAdapter();
    });

    test(
        'Default query returns answered.json with valid checklist and provenance',
        () async {
      const req = AnswerRequest(
        requestId: 'req_test_01',
        caseId: 'case_test_01',
        originalMessage: 'আমার বেতন বকেয়া রয়েছে',
        language: 'bn',
      );

      final res = await adapter.sendTurn(req);

      expect(res.outcome, Outcome.answered);
      expect(res.engineProvenance, ProcessingEngine.demoFixture);
      expect(res.checklist, isNotEmpty);
      expect(res.explanation, isNotEmpty);
    });

    test('EPZ sector inquiry routes to clarification.json fixture', () async {
      const req = AnswerRequest(
        requestId: 'req_test_02',
        caseId: 'case_test_01',
        originalMessage: 'প্রতিষ্ঠানটি ইপিজেড (EPZ) এলাকায় অবস্থিত',
        language: 'bn',
      );

      final res = await adapter.sendTurn(req);

      expect(res.outcome, Outcome.clarificationNeeded);
      expect(res.clarificationQuestions, isNotEmpty);
    });

    test('Correction keywords route to correction_superseded.json fixture',
        () async {
      const req = AnswerRequest(
        requestId: 'req_test_03',
        caseId: 'case_test_01',
        originalMessage: 'আসলে বকেয়া টাকা ৫০,০০০ নয়, ৩০,০০০ টাকা',
        language: 'bn',
      );

      final res = await adapter.sendTurn(req);

      expect(res.supersedesAnswerId, isNotNull);
    });

    test('Emergency keywords route to emergency_referral.json fixture',
        () async {
      const req = AnswerRequest(
        requestId: 'req_test_04',
        caseId: 'case_test_01',
        originalMessage: 'জরুরি সাহায্য প্রয়োজন',
        language: 'bn',
      );

      final res = await adapter.sendTurn(req);

      expect(res.outcome, Outcome.emergencyReferral);
      expect(res.limitations, isNotEmpty);
    });

    test(
        'Draft preparation returns valid DraftDocument for GD, DIFE, and DNCRP',
        () async {
      final gdDraft = await adapter.prepareDraft(
        type: DocumentType.gd,
        facts: const [],
      );
      expect(gdDraft.type, DocumentType.gd);
      expect(gdDraft.title, isNotEmpty);

      final difeDraft = await adapter.prepareDraft(
        type: DocumentType.dife,
        facts: const [],
      );
      expect(difeDraft.type, DocumentType.dife);
      expect(difeDraft.subject, isNotEmpty);

      final dncrpDraft = await adapter.prepareDraft(
        type: DocumentType.dncrp,
        facts: const [],
      );
      expect(dncrpDraft.type, DocumentType.dncrp);
      expect(dncrpDraft.body, isNotEmpty);
    });

    test('Quota repository returns valid daily quota numbers', () async {
      final quota = await adapter.getQuota();

      expect(quota.dailyLimit, 30);
      expect(quota.canQuery, true);
      expect(quota.remaining, 29);
      expect(quota.store, 'demo_fixture');
    });

    test('Pack repository reports ready status for bundled core pack',
        () async {
      final pack = await adapter.checkForUpdates();

      expect(pack.status, InstallStatus.ready);
      expect(pack.isInstalled, true);
      expect(pack.coverage, contains('labour'));
    });
  });
}
