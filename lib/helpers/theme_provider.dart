import 'package:flutter/material.dart';
import 'package:uni_market/helpers/app_themes.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  bool _isDark = ThemeMode.system == ThemeMode.dark ? true : false;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  bool getThemeToggleSwitch() {
    return _themeMode == ThemeMode.dark;
  }

  bool setThemeToggleSwitch() {
    if (_themeMode == ThemeMode.light) {
      _isDark = true;
      return false;
    } else if (_themeMode == ThemeMode.dark) {
      _isDark = false;
      return true;
    } else {
      // Use system theme
      final Brightness platformBrightness =
          WidgetsBinding.instance.window.platformBrightness;
      _isDark = (platformBrightness == Brightness.dark);
      return platformBrightness == Brightness.dark;
    }
  }

  ThemeData _currentTheme = lightTheme;

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _currentTheme = darkTheme;

      _themeMode = ThemeMode.dark;
    } else {
      _currentTheme = lightTheme;
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}
