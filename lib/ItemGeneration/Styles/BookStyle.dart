import 'package:flutter/material.dart';
import 'Style.dart';

class BookStyle implements Style {
  @override
  Color backgroundColor = Colors.purple;
  @override
  Color textColor = Colors.pink;
  @override
  BuildContext context;

  BookStyle({required this.context});

  @override
  ThemeData getThemeData() {
    // copying base color scheme and adding differences
    ColorScheme cs =
        Theme.of(context).colorScheme.copyWith(background: backgroundColor);
    return ThemeData(colorScheme: cs);
  }
}
