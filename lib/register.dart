import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dialog.dart';
import 'helpers/stepper_states.dart';
import 'dart:async';

Step register(index, tapped) {
  return Step(
      title: const Text('Register'),
      content: Container(
        alignment: Alignment.centerLeft,
        child: Registiration(tapped: tapped),
      ),
      isActive: index == 0,
      state: stepperState(index, 0));
}

class Registiration extends StatefulWidget {
  final Function() tapped;
  const Registiration({required this.tapped, Key? key}) : super(key: key);
  @override
  State<Registiration> createState() => _RegistirationState();
}

// Register Form
class _RegistirationState extends State<Registiration> {
  // Initialize controllers for Each Input Container
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool submitting = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Form(
            key: _formKey,
            child: Column(children: [
              NameContainer(nameController: nameController),
              const SizedBox(height: 10),
              EmailContainer(emailController: emailController),
              const SizedBox(height: 10),
              PasswordContainer(
                passwordController: passwordController,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: submitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            // Attempt to register user input into Firebase
                            _createUser(
                                context,
                                nameController,
                                emailController,
                                passwordController,
                                widget.tapped);
                          }
                        },
                        child: const Text('Submit'),
                      ),
              ),
            ])));
  }

  // Function to reate Firebase User with Email and Password (Pass in Register Form Controllers)
  Future<void> _createUser(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    Function() tapped,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating your account')),
      );
      setState(() => submitting = true);
      // Get user input from text field controllers (Remove ending whitespaces)
      String userEmail = emailController.text.trim();
      String password = passwordController.text.trim();
      String displayName = nameController.text.trim();

      // Use Firebase Authentification to create a user with email and password
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: userEmail, password: password);

      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.

      // Add Users' Display Name
      await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);

      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: userEmail, password: password);
      Timer(const Duration(seconds: 2), () async {
        submitting = false;
        tapped();
      });
    } catch (e) {
      // Handling Create User Errors (Currently Not Viable for Production using print)
      print("Error creating user: $e");
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error Creating User')),
      );
      setState(() => submitting = false);
    }
  }
}

// Email Input Field
class EmailContainer extends StatefulWidget {
  final TextEditingController emailController;

  const EmailContainer({
    Key? key,
    required this.emailController,
  }) : super(key: key);

  @override
  State<EmailContainer> createState() => _EmailContainerState();
}

class _EmailContainerState extends State<EmailContainer> {
  String? validateEmail(String? value) {
    const pattern = r"^[A-Za-z0-9._%+-]+@nevada\.unr\.edu$";
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address.'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      cursorColor: Colors.white,
      onSaved: (email) {},
      decoration: InputDecoration(
        prefixIconConstraints:
            const BoxConstraints(minWidth: 23, maxHeight: 20),
        hintText: "johndoe@exampleschool.edu",
        labelText: "Email",
        prefixIcon: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.email_rounded),
        ),
        suffixIcon: IconButton(
            onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => appDialog(
                    context,
                    'Email Input',
                    'Please input your email with a .\'edu\' domain',
                    'Ok')),
            icon: const Icon(Icons.info_outlined)),
      ),
      validator: validateEmail,
    );
  }
}

// Name Input Field
class NameContainer extends StatefulWidget {
  final TextEditingController nameController;
  const NameContainer({
    Key? key,
    required this.nameController,
  }) : super(key: key);

  @override
  State<NameContainer> createState() => _NameContainerState();
}

class _NameContainerState extends State<NameContainer> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.nameController,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        cursorColor: Colors.white,
        onSaved: (email) {},
        decoration: InputDecoration(
          prefixIconConstraints:
              const BoxConstraints(minWidth: 23, maxHeight: 20),
          hintText: "John Doe",
          labelText: "Full Name",
          prefixIcon: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.person_2_rounded)),
          suffixIcon: IconButton(
              onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => appDialog(context,
                      'Name Input', 'Please input your full name', 'Ok')),
              icon: const Icon(Icons.info_outlined)),
        ));
  }
}

class PasswordContainer extends StatefulWidget {
  final TextEditingController passwordController;
  const PasswordContainer({
    Key? key,
    required this.passwordController,
  }) : super(key: key);

  @override
  State<PasswordContainer> createState() => _MyPasswordContainerState();
}

// Password Input Field
class _MyPasswordContainerState extends State<PasswordContainer> {
  bool _passwordVisible = false;
  String? validatePassword(String? value) {
    const pattern =
        r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$";
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a stronger password.'
        : null;
  }

  void togglePassword() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.passwordController,
        textInputAction: TextInputAction.done,
        obscureText: !_passwordVisible,
        cursorColor: Colors.white,
        decoration: InputDecoration(
            prefixIconConstraints:
                const BoxConstraints(minWidth: 23, maxHeight: 20),
            hintText: "Password@123",
            labelText: "Password",
            prefixIcon: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.lock_clock_rounded)),
            suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // added line
                mainAxisSize: MainAxisSize.min, // added line
                children: <Widget>[
                  IconButton(
                      onPressed: togglePassword,
                      icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off)),
                  IconButton(
                      onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => appDialog(
                              context,
                              'Password Input',
                              'Please input a password that is at least 8 characters and includes one uppercase letter, one lowercase letter, one number and one special character.',
                              'Ok')),
                      icon: const Icon(Icons.info_outlined)),
                ])),
        validator: validatePassword);
  }
}
