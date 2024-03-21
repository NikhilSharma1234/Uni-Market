import 'package:flutter/material.dart';

// Light and Dark Theme [ThemeData] Objects for Theme Provider

ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
    primary: Color(0xFF041E42),
    secondary: Colors.white,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xffD9D9D9),
  fontFamily: "Ubuntu",
  textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      bodySmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
  ).apply(bodyColor: Colors.black),
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
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
  ).apply(bodyColor: Colors.white),
  hoverColor: Colors.transparent,
  shadowColor: Colors.transparent,
  canvasColor: const Color(0xFF041E42),
);
