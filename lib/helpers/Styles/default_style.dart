import 'package:flutter/material.dart';
import 'Style.dart';

class DefaultStyle implements Style {
  Color borderColor = Colors.blue;
  @override
  Color backgroundColor = Colors.black;
  Color darkBackgroundColor = Colors.blueGrey.shade200;
  Color lightBackgroundColor = Colors.blueGrey.shade300;
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
