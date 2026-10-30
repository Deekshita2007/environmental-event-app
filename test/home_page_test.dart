import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/screens/profile_page.dart';
import 'package:flutter_application_1/services/app_preferences.dart';

import 'support/fake_auth_backends.dart';

void main() {
  testWidgets('home menu opens profile sections without changing bottom nav', (
    tester,
  ) async {
    final authService = createFakeAuthService();
    final preferences = AppPreferences();
    await authService.register('Eco User', 'eco@example.com', 'demo');

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(authService: authService, preferences: preferences),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('Account & Full Profile'), findsOneWidget);
    expect(find.text('Activities'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('Notifications'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Account & Full Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    preferences.dispose();
  });
}
