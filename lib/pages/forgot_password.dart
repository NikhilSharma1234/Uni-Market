import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  // Text Editing Controller for the email field
  final TextEditingController emailController = TextEditingController();

@override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

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
                ElevatedButton(
                  onPressed: () => _submitEmail(context),
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}



  void _submitEmail(BuildContext context) {
    // Implement the logic to handle password reset
    String email = emailController.text.trim();
    // Use the email to send a password reset request
    // Show a confirmation dialog/snackbar/message
  }
}
