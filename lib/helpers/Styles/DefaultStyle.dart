import 'package:flutter/material.dart';
import 'Style.dart';

class DefaultStyle implements Style {
  Color borderColor = Colors.blue;
  @override
  Color backgroundColor = Colors.black; // temp, will be overwritten
  Color darkBackgroundColor = Colors.blueGrey.shade700;
  Color lightBackgroundColor = Colors.blueGrey;
  @override
  Color textColor = Colors.blue;
  @override
  BuildContext context;

  DefaultStyle({required this.context});

  @override
  ThemeData getThemeData() {
    // copying base color scheme and adding differences
    if (Theme.of(context).brightness == Brightness.dark) {
      backgroundColor = darkBackgroundColor;
    } else {
      backgroundColor = lightBackgroundColor;
    }
    ColorScheme cs = Theme.of(context)
        .colorScheme
        .copyWith(background: backgroundColor, onPrimary: borderColor);
    return ThemeData(colorScheme: cs);
  }
}
