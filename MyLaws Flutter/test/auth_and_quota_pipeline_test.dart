import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/core/widgets/profile_quota_pill.dart';
import 'package:mylaws/data/remote/online_api_client.dart';
import 'package:mylaws/data/remote/online_auth_repository.dart';
import 'package:mylaws/data/remote/online_quota_repository.dart';
import 'package:mylaws/domain/models/app_failure.dart';
import 'package:mylaws/domain/models/user_quota.dart';
import 'package:mylaws/domain/repositories/auth_repository.dart';
import 'package:mylaws/features/conversation/composer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnlineAuthRepository Lifecycle & Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Fresh launch without prior session starts unauthenticated', () async {
      final client = OnlineApiClient();
      final authRepo = OnlineAuthRepository(client);

      // Microtask wait for restore
      await Future.delayed(const Duration(milliseconds: 50));

      expect(authRepo.currentUser, isNull,
          reason:
              'Unauthenticated users must not be auto-logged into fake accounts');
    });

    test('Email sign-in validates email format and password length', () async {
      final client = OnlineApiClient();
      final authRepo = OnlineAuthRepository(client);

      // Invalid email
      expect(
        () => authRepo.signInWithEmail('notanemail', '123456'),
        throwsA(isA<AppFailure>()),
      );

      // Short password (< 6 chars)
      expect(
        () => authRepo.signInWithEmail('citizen@test.com', '123'),
        throwsA(isA<AppFailure>()),
      );
    });

    test('Email sign-in and sign-up persists across restarts', () async {
      final client = OnlineApiClient();
      final authRepo1 = OnlineAuthRepository(client);

      final user = await authRepo1.signUpWithEmail(
          'citizen.bangladesh@test.com', 'mypassword123');
      expect(user.email, 'citizen.bangladesh@test.com');
      expect(authRepo1.currentUser?.email, 'citizen.bangladesh@test.com');

      // Simulate app restart / page reload with new repository instance
      final authRepo2 = OnlineAuthRepository(client);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(authRepo2.currentUser, isNotNull);
      expect(authRepo2.currentUser?.email, 'citizen.bangladesh@test.com');
    });

    test('Explicit Sign Out clears credentials and stays signed out on restart',
        () async {
      final client = OnlineApiClient();
      final authRepo1 = OnlineAuthRepository(client);

      await authRepo1.signInWithEmail('citizen@test.com', '123456');
      expect(authRepo1.currentUser, isNotNull);

      // Citizen signs out
      await authRepo1.signOut();
      expect(authRepo1.currentUser, isNull);

      // Simulate app restart / reload
      final authRepo2 = OnlineAuthRepository(client);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(authRepo2.currentUser, isNull,
          reason: 'User must remain signed out after explicit sign-out');
    });

    test(
        'Stale or corrupted google_user_syn mock session is automatically purged',
        () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_uid', 'google_user_syn');
      await prefs.setString('auth_email', 'user@gmail.com');
      await prefs.setString('auth_display_name', 'Google Account User');

      final client = OnlineApiClient();
      final authRepo = OnlineAuthRepository(client);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(authRepo.currentUser, isNull,
          reason:
              'Corrupted fallback sessions from earlier bug must be purged');
      expect(prefs.getString('auth_uid'), isNull);
    });
  });

  group('OnlineQuotaRepository & Daily Limit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial quota starts with 30 queries remaining', () async {
      final client = OnlineApiClient();
      final quotaRepo = OnlineQuotaRepository(client);

      final quota = await quotaRepo.getQuota();
      expect(quota.dailyLimit, 30);
      expect(quota.usedToday, 0);
      expect(quota.remaining, 30);
      expect(quota.canQuery, isTrue);
    });

    test('recordQuery() dynamically decrements remaining quota and persists',
        () async {
      final client = OnlineApiClient();
      final quotaRepo = OnlineQuotaRepository(client);

      final q1 = await quotaRepo.recordQuery();
      expect(q1.usedToday, 1);
      expect(q1.remaining, 29);
      expect(q1.canQuery, isTrue);

      final q2 = await quotaRepo.recordQuery();
      expect(q2.usedToday, 2);
      expect(q2.remaining, 28);
    });

    test('Quota exhaustion enforces 0 remaining and canQuery = false',
        () async {
      final client = OnlineApiClient();
      final quotaRepo = OnlineQuotaRepository(client);

      for (int i = 0; i < 30; i++) {
        await quotaRepo.recordQuery();
      }

      final finalQuota = await quotaRepo.getQuota();
      expect(finalQuota.usedToday, 30);
      expect(finalQuota.remaining, 0);
      expect(finalQuota.canQuery, isFalse);
      expect(finalQuota.isExhausted, isTrue);
    });

    test('Midnight BST date rollover automatically resets daily limit to 30',
        () async {
      // Simulate that yesterday 30 queries were used
      SharedPreferences.setMockInitialValues({
        'quota_date': '2026-11-01',
        'quota_used_today': 30,
      });

      final client = OnlineApiClient();
      final quotaRepo = OnlineQuotaRepository(client);

      // On new day, it must automatically reset
      final quota = await quotaRepo.getQuota();
      expect(quota.usedToday, 0);
      expect(quota.remaining, 30);
      expect(quota.canQuery, isTrue);
    });
  });

  group('ProfileQuotaPill & Composer UI Integration Tests', () {
    testWidgets('ProfileQuotaPill displays standard digits 30/30 and user info',
        (tester) async {
      const quota = UserQuota(
        dailyLimit: 30,
        usedToday: 0,
        remaining: 30,
        canQuery: true,
      );

      const user = AuthUser(
        uid: 'user_123',
        email: 'karim@mylaws.bd',
        displayName: 'Karim Rahman',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              actions: [
                ProfileQuotaPill(
                  user: user,
                  quota: quota,
                  isBangla: true,
                  onNewConversation: () {},
                  onSignOut: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pill shows remaining 30 and user initial
      expect(find.text('30'), findsOneWidget);
      expect(find.text('K'), findsOneWidget);

      // Open popup menu
      await tester.tap(find.byType(ProfileQuotaPill));
      await tester.pumpAndSettle();

      // Dropdown contains user info and 30/30 quota
      expect(find.text('Karim Rahman'), findsOneWidget);
      expect(find.text('karim@mylaws.bd'), findsOneWidget);
      expect(find.text('30/30'), findsOneWidget);
      expect(find.text('দৈনিক আইনি কোটা'), findsOneWidget);
      expect(find.text('সাইন আউট'), findsOneWidget);
    });

    testWidgets('ProfileQuotaPill shows Guest & Sign In when user is null',
        (tester) async {
      const quota = UserQuota(
        dailyLimit: 30,
        usedToday: 5,
        remaining: 25,
        canQuery: true,
      );

      bool signInTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              actions: [
                ProfileQuotaPill(
                  user: null,
                  quota: quota,
                  isBangla: true,
                  onNewConversation: () {},
                  onSignOut: () {},
                  onSignIn: () => signInTapped = true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);

      // Open popup menu
      await tester.tap(find.byType(ProfileQuotaPill));
      await tester.pumpAndSettle();

      expect(find.text('অতিথি নাগরিক'), findsOneWidget);
      expect(find.text('সাইন ইন করুন'), findsOneWidget);

      await tester.tap(find.text('সাইন ইন করুন'));
      await tester.pumpAndSettle();

      expect(signInTapped, isTrue);
    });

    testWidgets('Composer disables sending when quota is exhausted',
        (tester) async {
      final controller =
          TextEditingController(text: 'আমার অধিকার সম্পর্কে বলুন');
      bool sendCalled = false;

      const exhaustedQuota = UserQuota(
        dailyLimit: 30,
        usedToday: 30,
        remaining: 0,
        canQuery: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Composer(
              controller: controller,
              isWorking: false,
              isBangla: true,
              quota: exhaustedQuota,
              onSend: () => sendCalled = true,
              onStop: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hint shows quota exhausted message
      expect(
          find.text(
              'আজকের দৈনিক 30টি কোটা পূর্ণ হয়েছে। রাত 12টায় নবায়ন হবে।'),
          findsOneWidget);

      // Tap send button
      final sendIconFinder = find.byIcon(Icons.arrow_upward_rounded);
      await tester.tap(sendIconFinder);
      await tester.pump();

      expect(sendCalled, isFalse,
          reason: 'Send must be blocked when quota is exhausted');
    });
  });
}
