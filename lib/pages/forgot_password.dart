import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart';
import 'package:uni_market/services/email_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final ValueNotifier<bool> submitEnabled = ValueNotifier<bool>(false);
  late EmailManager emailManager;

  @override
  void initState() {
    super.initState();
    // Initialize emailManager here
    emailManager = EmailManager(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );
  }


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
      await emailManager.submitEmail(context, email);
    } finally {
      submitEnabled.value = false;
    }
  }
}