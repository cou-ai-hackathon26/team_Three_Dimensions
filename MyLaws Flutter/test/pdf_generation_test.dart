import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/domain/models/draft_document.dart';
import 'package:mylaws/domain/models/fact.dart';
import 'package:mylaws/features/drafts/pdf_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PDF Export Pipeline & Typography Tests', () {
    test('Generates valid A4 PDF bytes for General Diary (GD)', () async {
      const draft = DraftDocument(
        id: 'draft_gd_test_01',
        type: DocumentType.gd,
        title: 'সাধারণ ডায়েরি আবেদন',
        recipient: 'ভারপ্রাপ্ত কর্মকর্তা, ধানমন্ডি থানা, ঢাকা',
        subject: 'মোবাইল ফোন হারানো প্রসঙ্গে সাধারণ ডায়েরি।',
        body: 'বিনীত নিবেদন এই যে, আমি নিম্নস্বাক্ষরকারী...',
        applicantName: 'মুহাম্মদ আব্দুল্লাহ',
        applicantPhone: '০১৭০০০০০০০০',
        applicantAddress: 'ধানমন্ডি, ঢাকা',
        officeName: 'ধানমন্ডি মডেল থানা',
        facts: [
          Fact(fieldId: 'device', label: 'ডিভাইস মডেল', value: 'Samsung S23'),
          Fact(fieldId: 'imei', label: 'আইএমইআই', value: '123456789012345'),
        ],
        status: DraftStatus.reviewed,
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(500),
          reason: 'PDF byte stream must contain document payload');

      // Check standard PDF file header: %PDF-
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');

      // Check standard PDF EOF marker: %%EOF
      final tail = utf8.decode(pdfBytes.sublist(pdfBytes.length - 10),
          allowMalformed: true);
      expect(tail, contains('%%EOF'));
    });

    test('Generates valid PDF for DIFE unpaid wages complaint', () async {
      const draft = DraftDocument(
        id: 'draft_dife_test_01',
        type: DocumentType.dife,
        title: 'কলকারখানা ও প্রতিষ্ঠান পরিদর্শন অধিদপ্তর অভিযোগ',
        recipient: 'মহাপরিদর্শক, ডিআইএফই',
        subject: 'বকেয়া বেতন ও সার্ভিস বেনিফিট প্রদান না করা প্রসঙ্গে।',
        body: 'যথাযথ সম্মান প্রদর্শনপূর্বক...',
        applicantName: 'শ্রমিক প্রতিনিধি',
        officeName: 'ডিআইএফই ঢাকা কার্যালয়',
        facts: [
          Fact(fieldId: 'due_wages', label: 'বকেয়া বেতন', value: '৪০,০০০ টাকা'),
          Fact(fieldId: 'months', label: 'মাসের সংখ্যা', value: '২ মাস'),
        ],
        status: DraftStatus.reviewed,
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
    });

    test('Generates valid PDF for DNCRP consumer rights complaint', () async {
      const draft = DraftDocument(
        id: 'draft_dncrp_test_01',
        type: DocumentType.dncrp,
        title: 'ভোক্তা অধিকার সংরক্ষণ অধিদপ্তর অভিযোগ',
        recipient: 'মহাপরিচালক, জাতীয় ভোক্তা-অধিকার সংরক্ষণ অধিদপ্তর',
        subject: 'ভেজাল ও মেয়াদোত্তীর্ণ পণ্য বিক্রয় প্রসঙ্গে অভিযোগ।',
        body: 'বিনীত নিবেদন...',
        applicantName: 'ভোক্তা অভিযোগকারী',
        status: DraftStatus.reviewed,
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
    });

    test(
        'Generates structured A4 PDF with court headings for Domestic Violence petition',
        () async {
      final draft = DraftDocument.createDefault(
        type: DocumentType.domestic_violence,
        id: 'draft_dv_test_01',
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
      final tail = utf8.decode(pdfBytes.sublist(pdfBytes.length - 10),
          allowMalformed: true);
      expect(tail, contains('%%EOF'));
    });

    test(
        'Generates structured A4 PDF for Family Court Maintenance & Dower suit',
        () async {
      final draft = DraftDocument.createDefault(
        type: DocumentType.family_maintenance,
        id: 'draft_fm_test_01',
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
    });

    test('Generates structured A4 PDF for AC Land Mutation application',
        () async {
      final draft = DraftDocument.createDefault(
        type: DocumentType.land_mutation,
        id: 'draft_lm_test_01',
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
    });

    test(
        'Generates structured A4 PDF for Land Crime / Topsoil Complaint to UNO',
        () async {
      final draft = DraftDocument.createDefault(
        type: DocumentType.land_crime_complaint,
        id: 'draft_lc_test_01',
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
    });

    test('Generates structured A4 PDF for Section 9 Possession Recovery plaint',
        () async {
      final draft = DraftDocument.createDefault(
        type: DocumentType.possession_recovery,
        id: 'draft_pr_test_01',
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
    });

    test(
        'Generates structured A4 PDF for Section 138 Cheque Dishonour Legal Notice',
        () async {
      final draft = DraftDocument.createDefault(
        type: DocumentType.cheque_dishonour,
        id: 'draft_cd_test_01',
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
      final tail = utf8.decode(pdfBytes.sublist(pdfBytes.length - 10),
          allowMalformed: true);
      expect(tail, contains('%%EOF'));
    });

    test(
        'Generates structured A4 PDF for Criminal Bail Petition under CrPC 496/497',
        () async {
      final draft = DraftDocument.createDefault(
        type: DocumentType.bail_petition,
        id: 'draft_bp_test_01',
      );

      final pdfBytes = await PdfExportService.generatePdf(draft);
      expect(pdfBytes.length, greaterThan(500));
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, '%PDF-');
      final tail = utf8.decode(pdfBytes.sublist(pdfBytes.length - 10),
          allowMalformed: true);
      expect(tail, contains('%%EOF'));
    });
  });
}
