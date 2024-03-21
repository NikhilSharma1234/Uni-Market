import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_market/helpers/app_themes.dart';

import 'package:uni_market/helpers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);
  @override
  Widget build(BuildContext context) {
    bool darkThemeOn =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme ==
            darkTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.scale(
              scale: _controller.value * 1.2,
              child: child,
            );
          },
          child: Image.asset('assets/logo_circle.png',
              fit: BoxFit.contain, height: 300),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('Loading...',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: darkThemeOn ? Colors.white : Colors.black,
                  decoration: TextDecoration.none)),
        )
      ],
    );
  }
}
