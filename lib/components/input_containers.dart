import 'package:flutter/material.dart';
import 'dialog.dart';

// Email Input Field
class EmailContainer extends StatefulWidget {
  final TextEditingController emailController;
  final FocusNode? focusNode;

  const EmailContainer({
    Key? key,
    required this.emailController,
    this.focusNode,
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
      focusNode: widget.focusNode ?? widget.focusNode,
      controller: widget.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
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
  final FocusNode? focusNode;

  const NameContainer({
    Key? key,
    required this.nameController,
    this.focusNode,
  }) : super(key: key);

  @override
  State<NameContainer> createState() => _NameContainerState();
}

class _NameContainerState extends State<NameContainer> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        focusNode: widget.focusNode ?? widget.focusNode,
        controller: widget.nameController,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
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
  final bool isSignIn;
  // function to handle enter press
  final Function()? submitted;

  const PasswordContainer(
      {Key? key,
      required this.passwordController,
      required this.isSignIn,
      this.submitted})
      : super(key: key);

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
        onFieldSubmitted: (value) {
          if (widget.submitted != null) {
            widget.submitted!();
          }
        },
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
                  widget.isSignIn
                      ? const SizedBox
                          .shrink() // Empty (Don't show this when in sign in)
                      : IconButton(
                          onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => appDialog(
                                  context,
                                  'Password Input',
                                  'Please input a password that is at least 8 characters and includes one uppercase letter, one lowercase letter, one number and one special character.',
                                  'Ok')),
                          icon: const Icon(Icons.info_outlined)),
                ])),
        validator: widget.isSignIn
            ? null
            : validatePassword); // No validation while in sign in
  }
}
