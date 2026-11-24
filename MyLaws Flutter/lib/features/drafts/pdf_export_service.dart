import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/models/draft_document.dart';

class PdfExportService {
  static const String _banglaFontPath = 'assets/fonts/bangla.ttf';
  static const String _hindRegularPath = 'assets/fonts/hind_regular.ttf';
  static const String _hindSemiboldPath = 'assets/fonts/hind_semibold.ttf';
  static const String _anekBoldPath = 'assets/fonts/anek_600.ttf';

  /// Generates a formal A4 Bangladesh legal petition / draft document PDF bytes
  /// with authentic margins, clear Unicode Bengali typography, and court heading hierarchy.
  static Future<Uint8List> generatePdf(DraftDocument draft) async {
    AppLogger.i('Generating PDF for draft: ${draft.id} (${draft.type.name})');

    final doc = pw.Document(
      title: draft.title,
      author: 'MyLaws Bangladesh',
    );

    // Load Bengali-compatible TrueType fonts
    pw.Font? regularFont;
    pw.Font? boldFont;

    try {
      final regData = await rootBundle.load(_hindRegularPath);
      regularFont = pw.Font.ttf(regData);
    } catch (_) {
      try {
        final fontData = await rootBundle.load(_banglaFontPath);
        regularFont = pw.Font.ttf(fontData);
      } catch (e) {
        AppLogger.w('Could not load base TTF font: $e');
      }
    }

    try {
      final boldData = await rootBundle.load(_hindSemiboldPath);
      boldFont = pw.Font.ttf(boldData);
    } catch (_) {
      try {
        final anekData = await rootBundle.load(_anekBoldPath);
        boldFont = pw.Font.ttf(anekData);
      } catch (_) {
        boldFont = regularFont;
      }
    }

    final theme = regularFont != null
        ? pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont ?? regularFont,
          )
        : pw.ThemeData.base();

    // Standard Bangladesh A4 legal filing margin:
    // Left: 48pt (~1.25 in) for binding/clip, Right: 36pt, Top: 40pt, Bottom: 40pt
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(48, 40, 36, 40),
        theme: theme,
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.only(bottom: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'MyLaws Draft • ${draft.type.titleBn}',
                  style:
                      const pw.TextStyle(color: PdfColors.grey700, fontSize: 8),
                ),
                pw.Text(
                  'নথি আইডি: ${draft.id}',
                  style:
                      const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 20),
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'MyLaws দ্বারা প্রস্তুতকৃত আইনি খসড়া • আদালতে বা দপ্তরে দাখিলের পূর্বে যাচাই করুন',
                  style:
                      const pw.TextStyle(color: PdfColors.grey700, fontSize: 8),
                ),
                pw.Text(
                  'পৃষ্ঠা ${context.pageNumber} / ${context.pagesCount}',
                  style:
                      const pw.TextStyle(color: PdfColors.grey700, fontSize: 8),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          // If the draft contains full pre-assembled legal paragraphs,
          // render them with official court/administrative formatting.
          if (draft.paragraphs.isNotEmpty) {
            return _buildParagraphsLayout(draft);
          }

          // Fallback legacy layout for custom body drafts
          return _buildLegacyLayout(draft);
        },
      ),
    );

    return doc.save();
  }

  /// Builds authentic structured layout when paragraphs are populated
  static List<pw.Widget> _buildParagraphsLayout(DraftDocument draft) {
    final widgets = <pw.Widget>[];

    for (final p in draft.paragraphs) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) continue;

      // 1. Court / Authority Header (e.g., মোকাম: বিজ্ঞ ...)
      if (trimmed.startsWith('মোকাম:')) {
        widgets.add(
          pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(
              trimmed,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
            ),
          ),
        );
      }
      // 2. Case Number Header
      else if (trimmed.contains('মোকদ্দমা নং:')) {
        widgets.add(
          pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Text(
              trimmed,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
        );
      }
      // 3. Versus divider
      else if (trimmed == 'বনাম') {
        widgets.add(
          pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Text(
              '— বনাম —',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
        );
      }
      // 4. Subject Line
      else if (trimmed.startsWith('বিষয়:')) {
        widgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 8),
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: pw.Text(
              trimmed,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5),
            ),
          ),
        );
      }
      // 5. Valuation
      else if (trimmed.startsWith('মোকদ্দমার মূল্যায়ন:')) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(
              trimmed,
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.grey800),
            ),
          ),
        );
      }
      // 6. Verification / Affidavit Clause
      else if (trimmed.startsWith('হলফনামা') || trimmed.startsWith('সত্যপাঠ')) {
        widgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 12, bottom: 8),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              trimmed,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 3),
            ),
          ),
        );
      }
      // 7. Signature / Closing Line
      else if (trimmed.contains('স্বাক্ষর:') ||
          trimmed.startsWith('বিনীত নিবেদক:')) {
        widgets.add(
          pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Container(
              margin: const pw.EdgeInsets.only(top: 20, bottom: 10),
              child: pw.Text(
                trimmed,
                textAlign: pw.TextAlign.right,
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
            ),
          ),
        );
      }
      // 8. General Paragraphs (Facts, Prayer, Attachments)
      else {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(
              trimmed,
              textAlign: pw.TextAlign.justify,
              style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 4),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  /// Builds legacy fallback layout for drafts where paragraphs are not populated
  static List<pw.Widget> _buildLegacyLayout(DraftDocument draft) {
    return [
      // Top Date
      pw.Align(
        alignment: pw.Alignment.topRight,
        child: pw.Text(
          'তারিখ: ${DateTime.now().toLocal().toString().split(' ').first}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ),
      pw.SizedBox(height: 12),

      // Recipient & Office
      pw.Text('বরাবর,',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      pw.SizedBox(height: 4),
      pw.Text(draft.recipient, style: const pw.TextStyle(fontSize: 11)),
      if (draft.officeName.isNotEmpty && draft.officeName != draft.recipient) ...[
        pw.SizedBox(height: 2),
        pw.Text(draft.officeName, style: const pw.TextStyle(fontSize: 11)),
      ],
      pw.SizedBox(height: 16),

      // Subject Line
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Text(
          'বিষয়: ${draft.subject}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
      ),
      pw.SizedBox(height: 14),

      // Salutation
      pw.Text('মহোদয়,', style: const pw.TextStyle(fontSize: 11)),
      pw.SizedBox(height: 8),

      // Body Paragraphs
      pw.Paragraph(
        text: draft.body,
        style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 4),
      ),
      pw.SizedBox(height: 16),

      // Fact Details Table (if any)
      if (draft.facts.isNotEmpty) ...[
        pw.Text(
          'ঘটনাবলির সারসংক্ষেপ:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['বিষয় / বিবরণ', 'তথ্য'],
          data: draft.facts.map((f) => [f.label, f.value]).toList(),
          headerStyle:
              pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellHeight: 20,
        ),
        pw.SizedBox(height: 20),
      ],

      // Closing & Signature Block
      pw.SizedBox(height: 24),
      pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('বিনীত নিবেদক,', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 36),
            pw.Container(
              width: 140,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.black, width: 0.8)),
              ),
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    draft.applicantName.isNotEmpty
                        ? draft.applicantName
                        : '[আবেদনকারীর নাম ও স্বাক্ষর]',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                  if (draft.applicantPhone.isNotEmpty)
                    pw.Text('মোবাইল: ${draft.applicantPhone}',
                        style: const pw.TextStyle(fontSize: 9)),
                  if (draft.applicantAddress.isNotEmpty)
                    pw.Text('ঠিকানা: ${draft.applicantAddress}',
                        style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  /// Direct print or PDF viewer dialog via system print spooler
  static Future<void> printPdf(DraftDocument draft) async {
    final pdfBytes = await generatePdf(draft);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${draft.type.name}_${draft.id}.pdf',
    );
  }

  /// System share sheet intent for the exported PDF file
  static Future<void> sharePdf(DraftDocument draft) async {
    final pdfBytes = await generatePdf(draft);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${draft.type.name}_${draft.id}.pdf',
    );
  }
}
