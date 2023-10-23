import 'package:flutter/material.dart';
import 'package:uni_market/constants.dart';

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

// Register Form
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

// Email Input Field
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

// Name Input Field
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

// Password Input Field
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
