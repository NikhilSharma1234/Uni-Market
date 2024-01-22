import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final ValueNotifier<bool> submitEnabled = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: NavBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: screenWidth < 500 ? screenWidth * 0.95 : screenWidth * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: submitEnabled,
                    builder: (context, isSubmitting, child) {
                      return isSubmitting
                        ? CircularProgressIndicator() // Show loading indicator when submitting
                        : ElevatedButton(
                            onPressed: () => _submitEmail(context),
                            child: Text('Submit'),
                          );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitEmail(BuildContext context) async {
    submitEnabled.value = true;
    String email = emailController.text.trim();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar(context, 'A password reset email will be sent to $email if it has an account');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        _showSnackBar(context, 'Invalid email format');
      } else {
        _showSnackBar(context, 'Failed to send password reset email');
      }
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