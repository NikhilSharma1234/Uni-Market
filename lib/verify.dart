import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';

Step Verify(index) {
  return Step(
    title: const Text('Verify'),
    content: const Center(child: Verification()),
    isActive: index >= 0,
    state: index >= 1 ? StepState.complete : StepState.disabled,
  );
}

// verification code needs to have a state, which step doesnt have.
// this means it needs it's own class that gets made in the return of the step
class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    bool onEditing = true;
    String? code;

    return VerificationCode(
      textStyle: TextStyle(fontSize: 20.0, color: Colors.red[900]),
      keyboardType: TextInputType.number,
      underlineColor: Colors
          .amber, // If this is null it will use primaryColor: Colors.red from Theme
      length: 6,
      cursorColor:
          Colors.blue, // If this is null it will default to the ambient
      // clearAll is NOT required, you can delete it
      // takes any widget, so you can implement your design
      clearAll: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'clear all',
          style: TextStyle(
              fontSize: 14.0,
              decoration: TextDecoration.underline,
              color: Colors.blue[700]),
        ),
      ),
      onCompleted: (String value) {
        setState(() {
          code = value;
        });
      },
      onEditing: (bool value) {
        setState(() {
          onEditing = value;
        });
        if (!onEditing) FocusScope.of(context).unfocus();
      },
    );
  }
}
