import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/features/conversation/legal_reasoning_indicator.dart';
import 'package:mylaws/features/conversation/thread_view.dart';
import 'package:mylaws/app/providers.dart';

void main() {
  group('LegalReasoningIndicator Widget Tests', () {
    testWidgets(
        'Renders initial Stage 1 in Bengali with scale icon and stepper dots',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: LegalReasoningIndicator(
              isBangla: true,
            ),
          ),
        ),
      );

      // Verify Stage 1 initial contents
      expect(find.text('আইনি বিরোধ ও প্রেক্ষাপট পর্যালোচনা'), findsOneWidget);
      expect(
        find.text(
            'ঘটনার উপাদান ও সংশ্লিষ্ট পক্ষসমূহের আইনগত অবস্থান নির্ণয় করা হচ্ছে...'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byType(OrderOrderGavelAvatar), findsOneWidget);

      // Verify stepper count text
      expect(find.text('ধাপ ১/৪'), findsOneWidget);

      // Verify 4 stepper dot containers
      final dotFinders = find.byType(AnimatedContainer);
      expect(dotFinders, findsNWidgets(4));

      // Active dot has width 24
      final firstDot = tester.widget<AnimatedContainer>(dotFinders.at(0));
      expect(
          firstDot.constraints?.maxWidth ?? (firstDot.child == null ? 24.0 : 0),
          24.0);
    });

    testWidgets('Renders initial Stage 1 in English', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: LegalReasoningIndicator(
              isBangla: false,
            ),
          ),
        ),
      );

      expect(find.text('Analyzing Dispute Context & Facts'), findsOneWidget);
      expect(
        find.text(
            'Determining factual elements and legal standing of parties involved...'),
        findsOneWidget,
      );
      expect(find.text('Stage 1/4'), findsOneWidget);
    });

    testWidgets(
        'Transitions through all 4 stages chronologically (0.0s, 1.6s, 3.3s, 5.1s)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: LegalReasoningIndicator(
              isBangla: true,
            ),
          ),
        ),
      );

      // Stage 1 (0.0s - 1.5s)
      expect(find.text('আইনি বিরোধ ও প্রেক্ষাপট পর্যালোচনা'), findsOneWidget);

      // Advance to 1.6s -> Stage 2 (1.5s – 3.2s)
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('বাংলাদেশ কোড ও ১২০০+ গেজেট বিধান অনুসন্ধান'),
          findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
      expect(find.text('ধাপ ২/৪'), findsOneWidget);

      // Advance to 3.4s -> Stage 3 (3.2s – 5.0s)
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('ধারা যাচাই ও সুনির্দিষ্ট এখতিয়ার নির্ধারণ'),
          findsOneWidget);
      expect(find.text('ধাপ ৩/৪'), findsOneWidget);

      // Advance to 5.2s -> Stage 4 (5.0s+)
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('৪-ধাপ সমাধান ও খসড়া নির্দেশিকা তৈরি'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
      expect(find.text('ধাপ ৪/৪'), findsOneWidget);
    });

    testWidgets('Stop button is displayed and invokes onStop callback',
        (tester) async {
      bool stopCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LegalReasoningIndicator(
              isBangla: true,
              onStop: () => stopCalled = true,
            ),
          ),
        ),
      );

      final stopIconFinder = find.byIcon(Icons.stop_circle_outlined);
      expect(stopIconFinder, findsOneWidget);

      await tester.tap(stopIconFinder);
      await tester.pump();

      expect(stopCalled, true);
    });

    testWidgets('Renders correctly under Dark Theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: LegalReasoningIndicator(
              isBangla: true,
            ),
          ),
        ),
      );

      expect(find.text('আইনি বিরোধ ও প্রেক্ষাপট পর্যালোচনা'), findsOneWidget);
      expect(find.byType(OrderOrderGavelAvatar), findsOneWidget);
    });

    testWidgets(
        'Integration into ThreadView: renders LegalReasoningIndicator when isWorking is true',
        (tester) async {
      bool stopped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ThreadView(
              messages: [
                ChatMessage(
                  id: 'msg_01',
                  role: 'user',
                  text: 'আমার বেতন বকেয়া রয়েছে',
                  timestamp: DateTime.now(),
                ),
              ],
              isWorking: true,
              isBangla: true,
              onStop: () => stopped = true,
            ),
          ),
        ),
      );

      // User bubble is rendered
      expect(find.text('আমার বেতন বকেয়া রয়েছে'), findsOneWidget);

      // LegalReasoningIndicator is rendered in place of the old simple indicator
      expect(find.byType(LegalReasoningIndicator), findsOneWidget);
      expect(find.text('আইনি বিরোধ ও প্রেক্ষাপট পর্যালোচনা'), findsOneWidget);

      // Stop button inside indicator works in ThreadView
      await tester.tap(find.byIcon(Icons.stop_circle_outlined));
      await tester.pump();

      expect(stopped, true);
    });

    testWidgets(
        'Integration into ThreadView: does NOT render LegalReasoningIndicator when isWorking is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ThreadView(
              messages: [
                ChatMessage(
                  id: 'msg_01',
                  role: 'user',
                  text: 'আমার বেতন বকেয়া রয়েছে',
                  timestamp: DateTime.now(),
                ),
              ],
              isWorking: false,
              isBangla: true,
              onStop: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LegalReasoningIndicator), findsNothing);
    });
  });
}
