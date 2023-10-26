import 'package:flutter/material.dart';
import 'dialog.dart';

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
  RegisterForm({
    Key? key,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Form(
            key: _formKey,
            child: Column(children: [
              const NameContainer(),
              const SizedBox(height: 10),
              EmailContainer(),
              const SizedBox(height: 10),
              PasswordContainer(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Creating your account')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ])));
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
