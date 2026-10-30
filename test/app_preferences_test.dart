import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/app_preferences.dart';

void main() {
  test('preferences have useful defaults and notify on changes', () {
    final preferences = AppPreferences();
    var notifications = 0;
    preferences.addListener(() => notifications++);

    expect(preferences.darkModeEnabled, isFalse);
    expect(preferences.notificationsEnabled, isTrue);
    expect(preferences.ecoTipsEnabled, isTrue);

    preferences.setDarkModeEnabled(true);
    preferences.setNotificationsEnabled(false);
    preferences.setEcoTipsEnabled(false);

    expect(preferences.darkModeEnabled, isTrue);
    expect(preferences.notificationsEnabled, isFalse);
    expect(preferences.ecoTipsEnabled, isFalse);
    expect(notifications, 3);

    preferences.dispose();
  });
}
