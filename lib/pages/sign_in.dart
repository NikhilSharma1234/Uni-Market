// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart'; // Import NavBar if needed
import 'package:auto_size_text/auto_size_text.dart';
import 'package:uni_market/components/input_containers.dart';
import 'package:uni_market/pages/forgot_password.dart';
import 'package:uni_market/pages/home.dart';

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
  bool submitting = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              child: const Column(
                children: <Widget>[
                  Padding(
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
                  SignInForm(),
                  // Use SignInForm here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

// Register Form
class _SignInFormState extends State<SignInForm> {
  // Initialize controllers for Each Input Container
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late FocusNode _focusNode;
  bool submitting = false;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    void submit() {
      if (_formKey.currentState!.validate()) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        // Attempt to register user input into Firebase
        _signInUser(context, emailController, passwordController);
      }
    }

    return Form(
        key: _formKey,
        child: Column(children: [
          const SizedBox(height: 50),
          EmailContainer(
              emailController: emailController, focusNode: _focusNode),
          const SizedBox(height: 10),
          PasswordContainer(
            passwordController: passwordController,
            isSignIn: true,
            submitted: submit,
          ),
          const SizedBox(height: 25),
          submitting
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    submit();
                  },
                  child: const Text('Login'),
                ),
          // Account Recovery Gestuer
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage(),
                ),
              );
            },
            child: const Text("Forgot Password?",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
          )
        ]));
  }

  // Function to recreate Firebase User with Email and Password (Pass in Register Form Controllers)
  Future<void> _signInUser(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    setState(() => submitting = true);
    // try {
    //   // Get user input from text field controllers (Remove ending whitespaces)
    //   String userEmail = emailController.text.trim();
    //   String password = passwordController.text.trim();

    //   // Use Firebase Authentication to sign in the user
    //   await FirebaseAuth.instance
    //       .signInWithEmailAndPassword(email: userEmail, password: password);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Logging in')),
    //   );
    // } on FirebaseAuthException catch (e) {
    //   if (kDebugMode) {
    //     print(e.code);
    //   }
    //   if (e.code == 'too-many-requests') {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //           content: Text('Too many retries, please reset password')),
    //     );
    //     setState(() => submitting = false);
    //     return;
    //   }
    //   if (e.code == 'invalid-credential') {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Invalid Credentials Provided')),
    //     );
    //     setState(() => submitting = false);
    //     return;
    //   }
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Error Logging In')),
    //   );
    //   setState(() => submitting = false);
    // }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }
}
