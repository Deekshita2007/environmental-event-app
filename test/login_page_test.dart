import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/login_page.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/services/app_preferences.dart';

import 'support/fake_auth_backends.dart';

void main() {
  testWidgets('login rejects email addresses that are not Gmail addresses', (
    tester,
  ) async {
    final preferences = AppPreferences();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          preferences: preferences,
          authService: createFakeAuthService(),
        ),
      ),
    );

    expect(find.text('@gmail.com'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Email Address'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password',
    );
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(
      find.text('Please enter a valid Gmail address ending in @gmail.com'),
      findsOneWidget,
    );
    expect(find.text('Welcome back!'), findsOneWidget);

    preferences.dispose();
  });

  testWidgets('registration continues to require a Gmail address', (
    tester,
  ) async {
    final preferences = AppPreferences();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          preferences: preferences,
          authService: createFakeAuthService(),
        ),
      ),
    );

    await tester.ensureVisible(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('@gmail.com'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Full Name'),
      'Eco User',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email Address'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password',
    );
    await tester.ensureVisible(find.text('CREATE ACCOUNT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CREATE ACCOUNT'));
    await tester.pump();

    expect(
      find.text('Please enter a valid Gmail address ending in @gmail.com'),
      findsOneWidget,
    );
    expect(find.text('Create your account'), findsOneWidget);

    preferences.dispose();
  });

  testWidgets('login asks unregistered users to create an account', (
    tester,
  ) async {
    final preferences = AppPreferences();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          preferences: preferences,
          authService: createFakeAuthService(),
        ),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email Address'),
      'unknown@gmail.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password',
    );
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(
      find.text(
        'You don’t have an account in this app. Please create an account.',
      ),
      findsOneWidget,
    );
    expect(find.text('Welcome back!'), findsOneWidget);

    preferences.dispose();
  });

  testWidgets('forgot password sends a reset email to the entered Gmail', (
    tester,
  ) async {
    final preferences = AppPreferences();
    final authProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          preferences: preferences,
          authService: createFakeAuthService(authProvider: authProvider),
        ),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email Address'),
      'Person@gmail.com',
    );
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(authProvider.passwordResetEmail, 'person@gmail.com');
    expect(
      find.text(
        'If an account exists for this email, password reset instructions have been sent.',
      ),
      findsOneWidget,
    );

    preferences.dispose();
  });

  testWidgets(
    'full Gmail address is normalized and account creation returns to login',
    (tester) async {
      final preferences = AppPreferences();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            preferences: preferences,
            authService: createFakeAuthService(),
          ),
        ),
      );
      await tester.ensureVisible(find.text('New here? Create an account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New here? Create an account'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Full Name'),
        'Eco User',
      );
      final emailField = find.widgetWithText(TextField, 'Email Address');
      await tester.enterText(emailField, 'user@gmail.com');
      expect(tester.widget<TextField>(emailField).controller!.text, 'user');
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );
      await tester.ensureVisible(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Account created. Please log in.'), findsOneWidget);
      expect(tester.widget<TextField>(emailField).controller!.text, 'user');

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'incorrect-password',
      );
      await tester.ensureVisible(find.text('LOGIN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();
      expect(
        find.text('Incorrect email or password. Please try again.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password',
      );
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      preferences.dispose();
    },
  );
}
