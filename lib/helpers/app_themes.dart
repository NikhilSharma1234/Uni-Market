import 'package:flutter/material.dart';

// Light and Dark Theme [ThemeData] Objects for Theme Provider

ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF041E42),
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      bodySmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFAF96FF),
  fontFamily: "Ubuntu",
  hoverColor: Colors.transparent,
  shadowColor: Colors.transparent,
  canvasColor: Colors.white,
);

ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: Colors.white,
    secondary: Colors.white,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF041E42),
  fontFamily: 'Ubuntu',
  textTheme: const TextTheme(bodySmall: TextStyle(color: Colors.white)).apply(
    bodyColor: Colors.white,
  ),
  hoverColor: Colors.transparent,
  shadowColor: const Color.fromARGB(0, 40, 34, 34),
  canvasColor: const Color(0xFF041E42),
);
