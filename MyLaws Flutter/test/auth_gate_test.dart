import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylaws/core/theme/app_theme.dart';
import 'package:mylaws/features/auth/auth_gate_screen.dart';

void main() {
  group('Auth Gate & Mandatory Authentication Tests', () {
    testWidgets(
        'Renders Google Sign-In button and email inputs, no guest login',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const AuthGateScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Official Google sign-in text is present (English by default)
      expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data == 'Continue with Google' ||
                w.data == 'Google দিয়ে এগিয়ে যান')),
        findsOneWidget,
      );

      // Email and password inputs are present
      expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data == 'Email address' ||
                w.data == 'Email Address' ||
                w.data == 'ইমেইল ঠিকানা')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) =>
            w is Text && (w.data == 'Password' || w.data == 'পাসওয়ার্ড')),
        findsOneWidget,
      );

      // Crucial: Guest login button is completely removed
      expect(find.text('অ্যাকাউন্ট ছাড়াই চালিয়ে যান'), findsNothing);
      expect(find.text('Continue as Guest'), findsNothing);
      expect(find.textContaining('অতিথি মোড'), findsNothing);
      expect(find.textContaining('Guest Mode'), findsNothing);
    });

    testWidgets('Clicking Google Sign-In triggers authentication and callback',
        (tester) async {
      bool authenticated = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: AuthGateScreen(
              onAuthenticated: () => authenticated = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Google sign-in
      final googleBtn = find.byWidgetPredicate((w) =>
          w is Text &&
          (w.data == 'Continue with Google' ||
              w.data == 'Google দিয়ে এগিয়ে যান'));
      expect(googleBtn, findsOneWidget);
      await tester.tap(googleBtn);
      await tester.pumpAndSettle();

      expect(authenticated, isTrue);
    });
  });
}
