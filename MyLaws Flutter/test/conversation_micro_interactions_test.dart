import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/core/widgets/scale_on_press.dart';
import 'package:mylaws/core/widgets/typewriter_text.dart';
import 'package:mylaws/domain/models/checklist_step.dart';
import 'package:mylaws/features/checklist/checklist_step_tile.dart';
import 'package:mylaws/features/conversation/quick_starter_chips.dart';
import 'package:mylaws/features/conversation/thread_view.dart';
import 'package:mylaws/app/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Conversation Thread & Micro-Interactions Tests', () {
    testWidgets('ThreadMessageEntrance glides upwards and fades in over 350ms',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ThreadMessageEntrance(
              child: Text('Test Animated Message'),
            ),
          ),
        ),
      );

      // Verify text is present in the tree
      expect(find.text('Test Animated Message'), findsOneWidget);

      // On first frame (t=0), opacity is 0.0
      final opacityFinder = find.byType(Opacity);
      expect(opacityFinder, findsOneWidget);
      final initialOpacity = tester.widget<Opacity>(opacityFinder).opacity;
      expect(initialOpacity, 0.0);

      // Fast forward 175ms (halfway)
      await tester.pump(const Duration(milliseconds: 175));
      final midOpacity = tester.widget<Opacity>(opacityFinder).opacity;
      expect(midOpacity, greaterThan(0.0));
      expect(midOpacity, lessThan(1.0));

      // Settle full animation (350ms total)
      await tester.pumpAndSettle();
      final settledOpacity = tester.widget<Opacity>(opacityFinder).opacity;
      expect(settledOpacity, 1.0);
    });

    testWidgets(
        'ScaleOnPress scales to 0.96 on pointer down and springs back to 1.0',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScaleOnPress(
                pressedScale: 0.96,
                child: Container(
                  key: const ValueKey('pressable_box'),
                  width: 100,
                  height: 50,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ),
      );

      final animatedScaleFinder = find.byType(AnimatedScale);
      expect(animatedScaleFinder, findsOneWidget);
      expect(tester.widget<AnimatedScale>(animatedScaleFinder).scale, 1.0);

      // Simulate pointer down
      final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(const ValueKey('pressable_box'))));
      await tester.pump();
      expect(tester.widget<AnimatedScale>(animatedScaleFinder).scale, 0.96);

      // Simulate pointer up
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(animatedScaleFinder).scale, 1.0);
    });

    testWidgets(
        'QuickStarterChips wraps chips in ScaleOnPress and invokes onSelected',
        (tester) async {
      String? selectedQuery;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: QuickStarterChips(
              isBangla: true,
              onSelected: (query) => selectedQuery = query,
            ),
          ),
        ),
      );

      // Verify at least one Bengali chip is rendered
      expect(find.text('[ বেতন বকেয়া থাকলে করণীয় ]'), findsOneWidget);
      expect(find.byType(ScaleOnPress), findsWidgets);

      // Tap the chip
      await tester.tap(find.text('[ বেতন বকেয়া থাকলে করণীয় ]'));
      await tester.pumpAndSettle();

      expect(selectedQuery, contains('৩ মাসের বেতন আটকে রেখেছে'));
    });

    testWidgets(
        'ChecklistStepTile toggles completed state and displays animated checkmark',
        (tester) async {
      var isCompleted = false;

      final step = ChecklistStep(
        id: 'step_1',
        titleBn: 'বকেয়া বেতনের হিসাব প্রস্তুত করুন',
        titleEn: 'Calculate unpaid wages',
        completed: isCompleted,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: ChecklistStepTile(
                  step: step.copyWith(completed: isCompleted),
                  isBangla: true,
                  stepNumber: 1,
                  onToggle: (val) {
                    setState(() {
                      isCompleted = val;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Verify initial state: step number '1' per standard numerals guideline
      expect(find.text('1'), findsOneWidget);
      expect(find.text('বকেয়া বেতনের হিসাব প্রস্তুত করুন'), findsOneWidget);

      // Checkmark icon scale is 0.0 initially
      final initialScales =
          tester.widgetList<AnimatedScale>(find.byType(AnimatedScale)).toList();
      expect(initialScales.last.scale, 0.0);

      // Tap checkbox to toggle
      await tester.tap(find.text('বকেয়া বেতনের হিসাব প্রস্তুত করুন'));
      await tester.pumpAndSettle();

      expect(isCompleted, true);
      // Checkmark icon scale is now 1.0
      final completedScales =
          tester.widgetList<AnimatedScale>(find.byType(AnimatedScale)).toList();
      expect(completedScales.last.scale, 1.0);
    });

    testWidgets(
        'ThreadView renders user and assistant messages with ThreadMessageEntrance',
        (tester) async {
      final messages = [
        ChatMessage(
          id: 'user_1',
          role: 'user',
          text: 'আমার বকেয়া বেতন কীভাবে আদায় করব?',
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: 'assistant_1',
          role: 'assistant',
          text: 'বাংলাদেশ শ্রম আইন ২০০৬ অনুযায়ী আপনার অধিকার সুরক্ষিত।',
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ThreadView(
              messages: messages,
              isWorking: false,
              isBangla: true,
              onStop: () {},
            ),
          ),
        ),
      );

      // Allow entrance animations to settle
      await tester.pumpAndSettle();

      expect(find.text('আমার বকেয়া বেতন কীভাবে আদায় করব?'), findsOneWidget);
      expect(
          find.text('বাংলাদেশ শ্রম আইন ২০০৬ অনুযায়ী আপনার অধিকার সুরক্ষিত।'),
          findsOneWidget);
      expect(find.byType(ThreadMessageEntrance), findsNWidgets(2));
    });

    testWidgets(
        'TypewriterText streams characters and reveals cursor until completion',
        (tester) async {
      bool completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypewriterText(
              text: 'বাংলাদেশ আইন সহায়তা',
              animate: true,
              charDuration: const Duration(milliseconds: 20),
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      // Initially cursor is present
      await tester.pump(const Duration(milliseconds: 30));
      expect(find.textContaining('▌'), findsOneWidget);
      expect(completed, isFalse);

      // Fast-forward until complete
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(find.textContaining('▌'), findsNothing);
      expect(find.text('বাংলাদেশ আইন সহায়তা'), findsOneWidget);
    });
  });
}
