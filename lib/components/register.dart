import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/helpers/stepper_states.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_market/helpers/profile_pic_shuffler.dart';
import 'package:uni_market/components/input_containers.dart';
import 'package:url_launcher/url_launcher.dart';

Step register(index, tapped, [focusNode]) {
  focusNode = focusNode ?? focusNode;
  return Step(
      title: const Text('Register'),
      content: Container(
        alignment: Alignment.centerLeft,
        child: Registiration(
          tapped: tapped,
          focusNode: focusNode,
        ),
      ),
      isActive: index == 0,
      state: stepperState(index, 0));
}

class Registiration extends StatefulWidget {
  final Function() tapped;
  final FocusNode? focusNode;
  const Registiration({required this.tapped, this.focusNode, Key? key})
      : super(key: key);
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
        key: _formKey,
        child: Column(children: [
          NameContainer(
            nameController: nameController,
            focusNode: widget.focusNode ?? widget.focusNode,
          ),
          const SizedBox(height: 10),
          EmailContainer(emailController: emailController),
          const SizedBox(height: 10),
          PasswordContainer(
            passwordController: passwordController,
            isSignIn: false,
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      'By continuing, you acknowledge that you have read, understood, and agree with our ',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchURL(
                            'https://sites.google.com/view/uni-market-privacy-policy/eula');
                      },
                    text: 'End User License Agreement.',
                    style: const TextStyle(color: Colors.blue)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: submitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        // Attempt to register user input into Firebase
                        _createUser(context, nameController, emailController,
                            passwordController, widget.tapped);
                      }
                    },
                    child: const Text('Submit'),
                  ),
          ),
        ]));
  }

  _launchURL(link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
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
      setState(() => submitting = true);
      // Get user input from text field controllers (Remove ending whitespaces)
      String userEmail = emailController.text.trim().toLowerCase();
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

      // Set starting profile picture
      String? chosenProfilePicPath =
          "profile_pics/${const ProfilePicShuffler().reveal()}";

      final user = <String, dynamic>{
        "blockedUsers": [],
        "createdAt": Timestamp.now(),
        "updatedAt": Timestamp.now(),
        "deletedAt": null,
        "name": displayName,
        "email": userEmail,
        "schoolId": null,
        "marketplaceId": null,
        "darkMode": 0,
        "emailVerified": false,
        "verificationDocsUploaded": false,
        "verifiedUniStudent": false,
        "verifiedBy": null,
        "verifiedAt": null,
        "assignable_profile_pic": null,
        "starting_profile_pic": chosenProfilePicPath,
        "wishlist": []
      };

      // Add user to users database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .set(user);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating your account')),
      );
      Timer(const Duration(seconds: 2), () async {
        submitting = false;
        tapped();
      });
    } catch (e) {
      // Handling Create User Errors (Currently Not Viable for Production using print)
      if (kDebugMode) {
        print("Error creating user: $e");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error creating user or account may already exist')),
      );
      setState(() => submitting = false);
    }
  }
}
