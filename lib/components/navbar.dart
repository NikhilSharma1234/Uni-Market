import 'package:flutter/material.dart';
import 'package:uni_market/pages/sign_up.dart';
import 'package:uni_market/pages/sign_in.dart';

// if you make this extend and return an AppBar widget, you can use it as the appBar: in other widgets
class NavBar extends AppBar {
  NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    return AppBar(
      automaticallyImplyLeading: false,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor:
                darkModeOn ? Colors.white : const Color(0xFF041E42),
            padding: const EdgeInsets.all(16.0),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    const MyHomePage(title: 'SignUp', signUpStep: null),
              ),
            );
          },
          child: const Text('Sign Up'),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: darkModeOn ? Colors.white : const Color(0xFF041E42),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    darkModeOn ? const Color(0xFF041E42) : Colors.white,
                padding: const EdgeInsets.all(16.0),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SignInPage(title: 'Sign In'),
                  ),
                );
              },
              child: const Text('Sign In'),
            ),
          ),
        ),
      ],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Image.asset(
          (darkModeOn) ? 'assets/logo_dark.png' : 'assets/logo_light.png',
          fit: BoxFit.contain,
          height: 48),
    );
  }
}
