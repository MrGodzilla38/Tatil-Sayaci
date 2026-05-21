import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatil_sayaci/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _notifKey = 'notifications_enabled';
  static const String _themeKey = 'theme_mode';

  bool _notificationsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get notificationsEnabled => _notificationsEnabled;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notifKey) ?? true;
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
    notifyListeners();

    if (value) {
      await NotificationService().startForegroundNotification(
        summerHoliday: null,
        nextHoliday: null,
        nextCustomDate: null,
      );
    } else {
      await NotificationService().stopForegroundNotification();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }
}
