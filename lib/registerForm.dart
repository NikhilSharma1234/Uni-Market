import 'package:flutter/material.dart';
import 'package:uni_market/constants.dart';

// Web Register Form
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Form(
        child: Column(children: [
      NameContainer(),
      EmailContainer(),
      PasswordContainer(),
    ]));
  }
}

// Web Email Input Field
class EmailContainer extends StatelessWidget {
  const EmailContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        cursorColor: Colors.white,
        onSaved: (email) {},
        decoration: const InputDecoration(
            hintText: "Email",
            prefixIcon: Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Icon(Icons.email_rounded),
            )));
  }
}

// Web Name Input Field
class NameContainer extends StatelessWidget {
  const NameContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        cursorColor: Colors.white,
        onSaved: (email) {},
        decoration: const InputDecoration(
            hintText: "Full Name",
            prefixIcon: Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Icon(Icons.person_2_rounded),
            )));
  }
}

// Web Password Input Field
class PasswordContainer extends StatelessWidget {
  const PasswordContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        textInputAction: TextInputAction.done,
        obscureText: true,
        cursorColor: Colors.white,
        decoration: const InputDecoration(
            hintText: "Password",
            prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock_clock_rounded))));
  }
}
