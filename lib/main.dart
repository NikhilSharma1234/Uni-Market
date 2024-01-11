import 'package:flutter/material.dart';
import 'wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// NOTE - to get assets like images to work, you need to run flutter build web then use the asset in code

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const Wrapper(),
        title: 'Uni-Market',
        theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF041E42),
              brightness: Brightness.light,
            ),
            textTheme: const TextTheme(
                bodyMedium: TextStyle(
                    color: Color(0xFF041E42), fontWeight: FontWeight.w500)),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFAF9F6FF),
            fontFamily: 'Ubuntu',
            hoverColor: Colors.transparent,
            shadowColor: Colors.transparent,
            canvasColor: Colors.white),
        darkTheme: ThemeData(
            colorScheme: const ColorScheme.dark(
                brightness: Brightness.dark,
                primary: Colors.white,
                secondary: Colors.white),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF041E42),
            fontFamily: 'Ubuntu',
            textTheme: const TextTheme().apply(bodyColor: Colors.white),
            hoverColor: Colors.transparent,
            shadowColor: Colors.transparent,
            canvasColor: const Color(0xFF041E42)),
        themeMode: ThemeMode.system);
  }
}
