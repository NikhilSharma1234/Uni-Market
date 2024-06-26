import 'package:flutter/material.dart';
import 'package:uni_market/helpers/web_horizontal_scroll.dart';
import 'wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:uni_market/helpers/theme_provider.dart';
import 'package:uni_market/helpers/app_themes.dart';
import 'package:provider/provider.dart';

// NOTE - to get assets like images to work, you need to run flutter build web then use the asset in code

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(context: context), // Change Notifier
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior:
          WebHorizontalScroll(), // just allows web users to scroll horizontally via dragging when available
      home: const Wrapper(),
      title: 'Uni-Market',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
    );
  }
}
