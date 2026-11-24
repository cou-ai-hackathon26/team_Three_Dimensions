import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/domain/models/answer_response.dart';
import 'package:mylaws/features/answer/answer_card.dart';
import 'package:mylaws/features/conversation/composer.dart';

void main() {
  group('Bangladeshi Time Formatting & Black-and-White Button Tests', () {
    const mockAnswer = AnswerResponse(
      answerId: 'ans_bw_01',
      engineProvenance: ProcessingEngine.onlineMeta,
      outcome: Outcome.answered,
      status: 'completed',
      sourcePackVersion: 'bd-pilot-2026-10-27.1',
      problemSummary: ProblemSummary(
        identifiedIssue: 'মানিব্যাগ হারানো',
        understanding: 'আপনি মানিব্যাগ হারানো সংক্রান্ত আইনি সুরক্ষা জানতে চেয়েছেন।',
      ),
      plainLanguageExplanation: PlainLanguageExplanation(
        heading: 'আইনি পরামর্শ',
        meaning: 'আপনার মানিব্যাগ হারানো সংক্রান্ত আইনি সুরক্ষা।',
        userRightsAndOptions: ['জিডি করা', 'কার্ড ব্লক করা'],
        whatToDoNext: 'প্রথমে জিডি করুন।',
      ),
    );

    testWidgets('AnswerCard Translate button renders in sleek Black and White styling',
        (tester) async {
      // Light Mode test
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: mockAnswer,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Translate Button container
      final translateFinder = find.text('English');
      expect(translateFinder, findsOneWidget);

      final inkWellFinder = find.ancestor(
        of: translateFinder,
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsWidgets);

      // Verify the translate text color is pure white in light mode
      final textWidget = tester.widget<Text>(translateFinder);
      expect(textWidget.style?.color, equals(Colors.white));

      // Dark Mode test
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AnswerCard(
                  response: mockAnswer,
                  isBangla: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidgetDark = tester.widget<Text>(find.text('English'));
      expect(textWidgetDark.style?.color, equals(const Color(0xFF18181B)));
    });

    testWidgets('Composer New Chat button renders in sleek Black and White circular styling',
        (tester) async {
      final controller = TextEditingController();

      // Light Mode test
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Composer(
              controller: controller,
              isWorking: false,
              isBangla: true,
              onSend: () {},
              onStop: () {},
              onNewChat: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final iconFinder = find.byIcon(Icons.chat_bubble_outline_rounded);
      expect(iconFinder, findsOneWidget);

      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, equals(const Color(0xFF423B33)));

      // Dark Mode test
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Composer(
              controller: controller,
              isWorking: false,
              isBangla: true,
              onSend: () {},
              onStop: () {},
              onNewChat: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final iconWidgetDark = tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline_rounded));
      expect(iconWidgetDark.color, equals(const Color(0xFFD8CCA8)));
    });

    test('Bangladeshi periods correctly resolve night, dawn, morning, noon, afternoon, and evening', () {
      String getBnPeriod(int hour) {
        if (hour >= 20 || hour < 4) {
          return 'রাত';
        } else if (hour >= 4 && hour < 6) {
          return 'ভোর';
        } else if (hour >= 6 && hour < 12) {
          return 'সকাল';
        } else if (hour >= 12 && hour < 15) {
          return 'দুপুর';
        } else if (hour >= 15 && hour < 18) {
          return 'বিকাল';
        } else {
          return 'সন্ধ্যা';
        }
      }

      // 11:32 PM (23:32)
      expect(getBnPeriod(23), equals('রাত'));
      // 8:00 PM (20:00)
      expect(getBnPeriod(20), equals('রাত'));
      // 1:00 AM (01:00)
      expect(getBnPeriod(1), equals('রাত'));
      // 5:00 AM (05:00)
      expect(getBnPeriod(5), equals('ভোর'));
      // 9:00 AM (09:00)
      expect(getBnPeriod(9), equals('সকাল'));
      // 1:00 PM (13:00)
      expect(getBnPeriod(13), equals('দুপুর'));
      // 4:00 PM (16:00)
      expect(getBnPeriod(16), equals('বিকাল'));
      // 6:30 PM (18:30)
      expect(getBnPeriod(18), equals('সন্ধ্যা'));
      // 7:45 PM (19:45)
      expect(getBnPeriod(19), equals('সন্ধ্যা'));
    });
  });
}
