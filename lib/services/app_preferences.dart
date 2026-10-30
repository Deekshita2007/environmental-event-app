import 'package:flutter/foundation.dart';

class AppPreferences extends ChangeNotifier {
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  bool _ecoTipsEnabled = true;

  bool get darkModeEnabled => _darkModeEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get ecoTipsEnabled => _ecoTipsEnabled;

  void setDarkModeEnabled(bool value) {
    if (_darkModeEnabled == value) return;
    _darkModeEnabled = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    if (_notificationsEnabled == value) return;
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setEcoTipsEnabled(bool value) {
    if (_ecoTipsEnabled == value) return;
    _ecoTipsEnabled = value;
    notifyListeners();
  }
}
