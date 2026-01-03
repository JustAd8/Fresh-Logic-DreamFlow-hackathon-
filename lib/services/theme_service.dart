import 'package:flutter/material.dart';
import 'package:fridgeflow/services/user_service.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    try {
      await UserService().initialize();
      final user = UserService().currentUser;
      
      if (user != null) {
        switch (user.themeMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to initialize theme: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      notifyListeners();

      // Save to user preferences
      final user = UserService().currentUser;
      if (user != null) {
        String themeModeString;
        switch (mode) {
          case ThemeMode.light:
            themeModeString = 'light';
            break;
          case ThemeMode.dark:
            themeModeString = 'dark';
            break;
          case ThemeMode.system:
            themeModeString = 'system';
            break;
        }

        final updatedUser = user.copyWith(themeMode: themeModeString);
        await UserService().updateUser(updatedUser);
        debugPrint('Theme mode changed to: $themeModeString');
      }
    } catch (e) {
      debugPrint('Failed to set theme mode: $e');
      rethrow;
    }
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // System mode - check platform brightness
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }
}
