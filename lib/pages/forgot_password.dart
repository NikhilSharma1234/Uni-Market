import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:uni_market/components/input_containers.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final ValueNotifier<bool> submitEnabled = ValueNotifier<bool>(false);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: NavBar(),
      body: Center(
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width:
                    screenWidth < 500 ? screenWidth * 0.95 : screenWidth * 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: AutoSizeText(
                        'Trouble Logging In? Enter your email to reset your password.',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w500,
                        ),
                        minFontSize: 16,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    EmailContainer(emailController: emailController),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<bool>(
                      valueListenable: submitEnabled,
                      builder: (context, isSubmitting, child) {
                        return isSubmitting
                            ? const CircularProgressIndicator() // Show loading indicator when submitting
                            : ElevatedButton(
                                onPressed: () => _submitEmail(context),
                                child: const Text('Submit'),
                              );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    submitEnabled.value = true;
    String email = emailController.text.trim();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar(context,
          'If your email: $email is registered with us, you will receive a password reset link.');
    } on FirebaseAuthException {
      // Display a generic error message
      _showSnackBar(context, 'There was a problem handling your request.');
    } finally {
      submitEnabled.value = false;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
