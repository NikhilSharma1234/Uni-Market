import 'package:flutter/material.dart';
import 'Style.dart';

class KitStyle implements Style {
  Color borderColor = Colors.black;
  @override
  Color backgroundColor = Colors.blueGrey;
  @override
  Color textColor = Colors.green;
  @override
  BuildContext context;

  KitStyle({required this.context});

  @override
  ThemeData getThemeData() {
    // copying base color scheme and adding differences
    ColorScheme cs = Theme.of(context)
        .colorScheme
        .copyWith(background: backgroundColor, onPrimary: borderColor);
    return ThemeData(colorScheme: cs);
  }
}
