import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/pages/sign_up.dart';
import 'package:uni_market/pages/posting_form.dart';

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
  updateUserState(event) {
    if (mounted && event != null && event.emailVerified) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PostingForm(),
        ),
      );
    } else if (event != null && !event.emailVerified) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              const MyHomePage(title: 'Sign Up', signUpStep: 1),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const MyHomePage(title: 'Sign Up', signUpStep: null),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
