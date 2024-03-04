import 'package:flutter/material.dart';

abstract class Style {
  late Color backgroundColor;
  late Color textColor;
  late BuildContext context;

  Style({required this.context});

  ThemeData getThemeData();
}
