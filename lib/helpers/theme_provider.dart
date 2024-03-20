import 'package:flutter/material.dart';
import 'package:uni_market/helpers/app_themes.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  BuildContext context;

  ThemeProvider({required this.context});
  ThemeMode _themeMode = ThemeMode.dark;

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
      return false;
    } else if (_themeMode == ThemeMode.dark) {
      return true;
    } else {
      // Use system theme
      final Brightness platformBrightness =
          MediaQuery.of(context).platformBrightness;
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
