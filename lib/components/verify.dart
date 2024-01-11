import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uni_market/helpers/stepper_states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Step verify(index, tapped) {
  return Step(
    title: const Text('Verify'),
    content: Center(child: Verification(tapped: tapped)),
    isActive: index == 1,
    state: stepperState(index, 1),
  );
}

// verification code needs to have a state, which step doesnt have.
// this means it needs it's own class that gets made in the return of the step
class Verification extends StatefulWidget {
  final Function() tapped;
  const Verification({required this.tapped, Key? key}) : super(key: key);
  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification>
    with TickerProviderStateMixin {
  bool buttonPressed = false;
  bool userVerified = false;

  toggleVerification() {
    setState(() => buttonPressed = !buttonPressed);
  }

  setVerified() {
    setState(() => userVerified = true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 32),
            child: Text(
              'Please check your email for a verification link.\n Once you\'ve clicked the link, come back here and press the button below!',
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              toggleVerification();
              Timer(const Duration(seconds: 4), () async {
                await FirebaseAuth.instance.currentUser?.reload();
                bool isVerified =
                    FirebaseAuth.instance.currentUser!.emailVerified;
                if (isVerified) {
                  // Update user to email verified in db
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .update({"emailVerified": true});
                  setVerified();
                  toggleVerification();
                  Timer(const Duration(seconds: 2), () async {
                    widget.tapped();
                  });
                  return;
                }
                toggleVerification();
              });
            },
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: !buttonPressed && !userVerified
                    ? Colors.red
                    : buttonPressed && !userVerified
                        ? Colors.black
                        : Colors.green,
                foregroundColor: Colors.white),
            child: buttonPressed && !userVerified
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
                : userVerified
                    ? const Icon(Icons.check, color: Colors.white)
                    : const Icon(Icons.close, color: Colors.white),
          )
        ],
      ),
    );
  }
}
