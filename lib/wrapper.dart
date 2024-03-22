import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:uni_market/helpers/functions.dart';
import 'package:uni_market/helpers/theme_provider.dart';
import 'package:uni_market/pages/home.dart';
import 'package:uni_market/pages/sign_up.dart';
import 'package:uni_market/data_store.dart' as data_store;
import 'package:uni_market/pages/splash_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User? user;
  @override
  void initState() {
    super.initState();
    //Listen to Auth State changes
    FirebaseAuth.instance
        .authStateChanges()
        .listen((event) => updateUserState(event));
  }

  //Updates state when user state changes in the app
  updateUserState(event) async {
    if (mounted && event != null && event.emailVerified) {
      await loadCurrentUser(event.email);
      await Future.delayed(const Duration(seconds: 3));
      bool verificationDocsUploaded = data_store.user.verificationDocsUploaded;
      if (verificationDocsUploaded == false) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                const SignUpPage(title: 'Sign Up', signUpStep: 2),
          ),
        );
        return;
      }
      await search("", 10, context, Filters.none());
      int darkMode = data_store.user.darkMode;
      switch (darkMode) {
        case 1:
          Provider.of<ThemeProvider>(context, listen: false)
              .setThemeMode(ThemeMode.dark);
          break;
        case 2:
          Provider.of<ThemeProvider>(context, listen: false)
              .setThemeMode(ThemeMode.light);
          break;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else if (event != null && !event.emailVerified) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              const SignUpPage(title: 'Sign Up', signUpStep: 1),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              const SignUpPage(title: 'Sign Up', signUpStep: null),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: const SplashScreen(),
    );
  }
}
