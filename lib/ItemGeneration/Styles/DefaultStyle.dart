import 'package:flutter/material.dart';
import 'Style.dart';

class DefaultStyle implements Style {
  @override
  Color backgroundColor = Colors.purple;
  @override
  Color textColor = Colors.blue;
  @override
  BuildContext context;

  DefaultStyle({required this.context});

  @override
  ThemeData getThemeData() {
    // copying base color scheme and adding differences
    ColorScheme cs =
        Theme.of(context).colorScheme.copyWith(background: backgroundColor);
    return ThemeData(colorScheme: cs);
  }
}
