import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mylaws/app/providers.dart';
import 'package:mylaws/core/services/saved_conversation_service.dart';
import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/features/library/saved_conversations_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('SavedConversationService Tests', () {
    test('Loads default realistic conversations when store is empty', () async {
      final list = await SavedConversationService.getConversations();
      expect(list.length, greaterThanOrEqualTo(2));
      expect(list.any((c) => c.title.contains('সাধারণ ডায়েরি')), true);
      expect(list.any((c) => c.title.contains('বকেয়া বেতন')), true);
    });

    test('Persists and updates conversation state', () async {
      final initial = await SavedConversationService.getConversations();
      final initialCount = initial.length;

      final testState = ConversationState(
        caseId: 'test_case_999',
        messages: [
          ChatMessage(
            id: 'm1',
            role: 'user',
            text: 'জমি খারিজের আবেদন কীভাবে করতে হয়?',
            timestamp: DateTime.now(),
          ),
          ChatMessage(
            id: 'm2',
            role: 'assistant',
            text: 'ই-নামজারি সেবার মাধ্যমে অনলাইনে আবেদন করতে হয়।',
            timestamp: DateTime.now(),
          ),
        ],
      );

      await SavedConversationService.saveConversation(testState);
      final updated = await SavedConversationService.getConversations();

      expect(updated.length, initialCount + 1);
      final saved = updated.firstWhere((c) => c.id == 'test_case_999');
      expect(saved.title, contains('জমি খারিজের'));
      expect(saved.turnCount, 2);
    });

    test('Deletes conversation by ID', () async {
      final list = await SavedConversationService.getConversations();
      final target = list.first;

      await SavedConversationService.deleteConversation(target.id);
      final afterDelete = await SavedConversationService.getConversations();

      expect(afterDelete.any((c) => c.id == target.id), false);
    });
  });

  group('SavedConversationsScreen Widget Tests', () {
    testWidgets('Renders app bar, search bar, and conversation cards',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SavedConversationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // App bar title in English by default
      expect(find.text('Saved Conversations'), findsOneWidget);

      // Search bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search conversations...'), findsOneWidget);

      // Conversation cards
      expect(
          find.text('মোবাইল ফোন হারানোর সাধারণ ডায়েরি (GD)'), findsOneWidget);
      expect(find.text('বকেয়া বেতন ও শ্রম আদালত অভিযোগ'), findsOneWidget);
      expect(find.text('4 turns'), findsOneWidget);
      expect(find.text('6 turns'), findsOneWidget);
    });

    testWidgets('Live search filters conversations accurately', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SavedConversationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search for 'শ্রম'
      await tester.enterText(find.byType(TextField), 'শ্রম');
      await tester.pumpAndSettle();

      expect(find.text('বকেয়া বেতন ও শ্রম আদালত অভিযোগ'), findsOneWidget);
      expect(find.text('মোবাইল ফোন হারানোর সাধারণ ডায়েরি (GD)'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(
          find.text('মোবাইল ফোন হারানোর সাধারণ ডায়েরি (GD)'), findsOneWidget);
      expect(find.text('বকেয়া বেতন ও শ্রম আদালত অভিযোগ'), findsOneWidget);
    });
  });
}
