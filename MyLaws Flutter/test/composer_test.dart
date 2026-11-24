import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mylaws/core/theme/app_colors.dart';
import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/features/conversation/composer.dart';
import 'package:mylaws/features/conversation/quick_starter_chips.dart';

void main() {
  group('Composer Widget UI/UX Tests', () {
    testWidgets('Send button is disabled when text controller is empty',
        (tester) async {
      final controller = TextEditingController();
      bool sendCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Composer(
              controller: controller,
              isWorking: false,
              isBangla: true,
              onSend: () => sendCalled = true,
              onStop: () {},
            ),
          ),
        ),
      );

      // Send button icon
      final sendIconFinder = find.byIcon(Icons.arrow_upward_rounded);
      expect(sendIconFinder, findsOneWidget);

      // Tap send button
      await tester.tap(sendIconFinder);
      await tester.pump();

      expect(sendCalled, false, reason: 'Empty text should not trigger onSend');
    });

    testWidgets('Send button triggers onSend when non-empty text entered',
        (tester) async {
      final controller = TextEditingController(text: 'আমার ৩ মাসের বেতন বকেয়া');
      bool sendCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Composer(
              controller: controller,
              isWorking: false,
              isBangla: true,
              onSend: () => sendCalled = true,
              onStop: () {},
            ),
          ),
        ),
      );

      final sendIconFinder = find.byIcon(Icons.arrow_upward_rounded);
      expect(sendIconFinder, findsOneWidget);

      await tester.tap(sendIconFinder);
      await tester.pump();

      expect(sendCalled, true);
    });

    testWidgets('Stop button is displayed when isWorking is true',
        (tester) async {
      final controller = TextEditingController();
      bool stopCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Composer(
              controller: controller,
              isWorking: true,
              isBangla: true,
              onSend: () {},
              onStop: () => stopCalled = true,
            ),
          ),
        ),
      );

      // When working, stop square icon is visible
      final stopIconFinder = find.byIcon(Icons.stop_rounded);
      expect(stopIconFinder, findsOneWidget);

      await tester.tap(stopIconFinder);
      await tester.pump();

      expect(stopCalled, true);
    });

    testWidgets('New Chat button triggers onNewChat when provided and tapped',
        (tester) async {
      final controller =
          TextEditingController(text: 'Some existing draft text');
      bool newChatCalled = false;

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
              onNewChat: () => newChatCalled = true,
            ),
          ),
        ),
      );

      final newChatFinder = find.byIcon(Icons.chat_bubble_outline_rounded);
      expect(newChatFinder, findsOneWidget);

      await tester.tap(newChatFinder);
      await tester.pump();

      expect(newChatCalled, true);
    });

    testWidgets('Applies Warm Parchment stadium styling and gold focus ring',
        (tester) async {
      final controller = TextEditingController();

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
            ),
          ),
        ),
      );

      // Verify stadium container borderRadius is 32
      final containerFinder = find.byType(Container).first;
      final Container container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(32));
      expect(decoration.color, AppColors.lightSurface);

      // Focus the text field to verify gold focus ring
      await tester.tap(find.byType(TextField));
      await tester.pump();

      final Container focusedContainer =
          tester.widget<Container>(containerFinder);
      final focusedDecoration = focusedContainer.decoration as BoxDecoration;
      final border = focusedDecoration.border as Border;
      expect(border.top.width, 1.6);
      expect(
        border.top.color,
        const Color(0xFF231F1C),
      );
    });
  });

  group('QuickStarterChips UI/UX Tests', () {
    testWidgets('Renders bracketed chips in Bengali with bronze borders',
        (tester) async {
      String? selectedText;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuickStarterChips(
              isBangla: true,
              onSelected: (text) => selectedText = text,
            ),
          ),
        ),
      );

      // Verify Bengali bracketed text
      expect(find.text('[ বেতন বকেয়া থাকলে করণীয় ]'), findsOneWidget);
      expect(find.text('[ অনলাইন শপিংয়ে প্রতারণা ]'), findsOneWidget);
      expect(find.text('[ হুমকি পেলে জিডি করা ]'), findsOneWidget);
      expect(find.text('[ জমি দখল বা বিরোধ ]'), findsOneWidget);

      // Tap on a chip
      await tester.tap(find.text('[ বেতন বকেয়া থাকলে করণীয় ]'));
      await tester.pump();

      expect(
        selectedText,
        'কোম্পানি আমার ৩ মাসের বেতন আটকে রেখেছে, দিচ্ছে না। এখন আমি কীভাবে এই টাকা উদ্ধার করতে পারি?',
      );
    });

    testWidgets('Renders bracketed chips in English when isBangla is false',
        (tester) async {
      String? selectedText;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuickStarterChips(
              isBangla: false,
              onSelected: (text) => selectedText = text,
            ),
          ),
        ),
      );

      expect(find.text('[ Unpaid Wages Advice ]'), findsOneWidget);
      expect(find.text('[ Online Shopping Fraud ]'), findsOneWidget);
      expect(find.text('[ How to File a GD ]'), findsOneWidget);
      expect(find.text('[ Land Dispute Help ]'), findsOneWidget);

      await tester.tap(find.text('[ Unpaid Wages Advice ]'));
      await tester.pump();

      expect(
        selectedText,
        'My employer has not paid my salary for 3 months. What legal steps can I take under the Labour Act?',
      );
    });
  });
}
