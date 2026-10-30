import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/favorites_page.dart';
import 'package:flutter_application_1/screens/edit_profile_page.dart';
import 'package:flutter_application_1/screens/profile_page.dart';
import 'package:flutter_application_1/services/app_preferences.dart';
import 'package:flutter_application_1/services/event_service.dart';
import 'support/fake_auth_backends.dart';

void main() {
  testWidgets('profile shows impact and opens Favorites', (tester) async {
    final authService = createFakeAuthService();
    final preferences = AppPreferences();
    final eventService = EventService();
    await authService.register('Deekshita', 'deekshita@email.com', 'demo');
    eventService.joinEvent('2', authService.currentUser!.id);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          authService: authService,
          preferences: preferences,
          eventService: eventService,
        ),
      ),
    );

    expect(find.text('Deekshita'), findsOneWidget);
    expect(find.text('Environmental Enthusiast 🌱'), findsOneWidget);
    expect(find.text('🌱 Your Impact'), findsOneWidget);
    expect(find.text('Events Joined'), findsOneWidget);
    expect(find.text('Events Created'), findsOneWidget);
    expect(find.text('People Reached'), findsOneWidget);

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfilePage), findsOneWidget);
    expect(find.text('Tap photo to change'), findsOneWidget);
    expect(find.text('Profile picture URL'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('My Events'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('My Events'), findsOneWidget);

    await tester.tap(find.text('My Events'));
    await tester.pumpAndSettle();
    expect(find.text('Events I’m attending'), findsOneWidget);
    expect(find.text('Events I Created'), findsOneWidget);
    expect(find.text('Past Events'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Favorites'),
      300,
      scrollable: find.byType(Scrollable),
    );

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.byType(FavoritesPage), findsOneWidget);
    expect(find.text('No favorites yet'), findsOneWidget);

    preferences.dispose();
  });
}
