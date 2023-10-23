import 'package:flutter/material.dart';
import 'package:uni_market/registerForm.dart';

Step Register(index) {
  return Step(
      title: const Text('Register'),
      content: Container(
        alignment: Alignment.centerLeft,
        child: const RegisterForm(),
      ),
      isActive: index >= 0,
      state: index >= 0 ? StepState.complete : StepState.disabled);
}

// Screen and Forms for Web Registering (Could habe logic for using each register screen per device)
class WebRegisterScreen extends StatelessWidget {
  // Web Register Screen Constructor
  // Check if key exists for widget others set key to superclass key
  const WebRegisterScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RegisterForm(),
      ],
    );
  }
}
