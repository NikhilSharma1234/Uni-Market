import 'package:flutter/material.dart';

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
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 20)),
          onPressed: () {
            // Get the current route
            var currentRoute = ModalRoute.of(context)?.settings.name;

            // Check if the current route is not the one you are trying to navigate to
            if (currentRoute != '/signUp') {
              Navigator.pushReplacementNamed(context, '/signUp');
            }
          },
          child: const Text('Sign Up'),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: Colors.white,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF041E42),
                padding: const EdgeInsets.all(16.0),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                // Get the current route
                var currentRoute = ModalRoute.of(context)?.settings.name;

                // Check if the current route is not the one you are trying to navigate to
                if (currentRoute != '/signIn') {
                  Navigator.pushReplacementNamed(context, '/signIn');
                }
              },
              child: const Text('Sign In'),
            ),
          ),
        ),
      ],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Image.asset(
              (darkModeOn) ? 'assets/logo_dark.png' : 'assets/logo_light.png',
              fit: BoxFit.contain,
              height: 48)),
    );
  }
}
