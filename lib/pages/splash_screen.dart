import 'package:flutter/material.dart';

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
    return Container(
      color: const Color(0xFF041E42),
      child: Column(
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
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Loading...',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    decoration: TextDecoration.none)),
          )
        ],
      ),
    );
  }
}
