import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart'; // Import NavBar if needed
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:uni_market/components/register.dart';
import 'package:uni_market/pages/forgot_password.dart';
// import 'package:uni_market/pages/forgot_password.dart';

class SignInPage extends StatefulWidget {
  final String title;

  const SignInPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenWidth * 0.25, 110),
        child: NavBar(), // Include NavBar if needed
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width:
                  screenWidth < 500 ? screenWidth * 0.95 : screenWidth * 0.45,
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: AutoSizeText(
                      'Welcome back to the marketplace made for students.',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w500,
                      ),
                      minFontSize: 16,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                      height: (screenHeight * 0.6),
                    ),
                    child: SignInForm(),
                    // Use SignInForm here
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to reate Firebase User with Email and Password (Pass in Register Form Controllers)
Future<void> _signInUser(
  BuildContext context,
  TextEditingController emailController,
  TextEditingController passwordController,
) async {
  try {
    // Get user input from text field controllers (Remove ending whitespaces)
    String userEmail = emailController.text.trim();
    String password = passwordController.text.trim();

    // Use Firebase Authentication to sign in the user
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: userEmail, password: password);
  } on FirebaseAuthException catch (e) {
    // Handling Create User Errors (Currently Not Viable for Production using print)
    if (e.code == 'user-not-found') {
      print('No user found for given email');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  }
}

// Register Form
class SignInForm extends StatelessWidget {
  // Initialize controllers for Each Input Container

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInForm({
    Key? key,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Form(
            key: _formKey,
            child: Column(children: [
              const SizedBox(height: 50),
              EmailContainer(emailController: emailController),
              const SizedBox(height: 10),
              PasswordContainer(
                  passwordController: passwordController, isSignIn: true),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Logging in to your account')),
                    );
                    // Attempt to register user input into Firebase
                    _signInUser(context, emailController, passwordController);
                  }
                },
                child: const Text('Login'),
              ),
              // Account Recovery Gestuer
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text("Forgot Password?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              )
            ])));
  }
}
