import 'package:flutter/material.dart';
import 'Style.dart';

class BookStyle implements Style {
  Color borderColor = Colors.blue;
  @override
  Color backgroundColor = Colors.blueGrey;
  @override
  Color textColor = Colors.pink;
  @override
  BuildContext context;

  BookStyle({required this.context});

  @override
  ThemeData getThemeData() {
    // copying base color scheme and adding differences
    ColorScheme cs = Theme.of(context)
        .colorScheme
        .copyWith(background: backgroundColor, onPrimary: borderColor);
    return ThemeData(colorScheme: cs);
  }
}
