import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/settings_page.dart';
import 'package:flutter_application_1/services/app_preferences.dart';

void main() {
  testWidgets('settings switches update app preferences', (tester) async {
    final preferences = AppPreferences();
    await tester.pumpWidget(
      MaterialApp(home: SettingsPage(preferences: preferences)),
    );

    await tester.tap(find.byType(SwitchListTile).at(0));
    await tester.pumpAndSettle();
    expect(preferences.darkModeEnabled, isTrue);

    await tester.tap(find.byType(SwitchListTile).at(1));
    await tester.pumpAndSettle();
    expect(preferences.notificationsEnabled, isFalse);

    await tester.tap(find.byType(SwitchListTile).at(2));
    await tester.pumpAndSettle();
    expect(preferences.ecoTipsEnabled, isFalse);

    preferences.dispose();
  });
}
