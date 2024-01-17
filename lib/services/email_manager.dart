import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailManager {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  EmailManager(this._firebaseAuth, this._firestore);

  Future<void> submitEmail(BuildContext context, String email) async {
    if (!isValidEmail(email)) {
      _showSnackBar(context, 'Invalid email format');
      return;
    }
    
    if (!await _isEmailInFirestore(email)) {
      _showSnackBar(context, 'Email not registered');
      return;
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _showSnackBar(context, 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e, context);
    } catch (e) {
      _showSnackBar(context, 'Failed to send password reset email');
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+(\+\d+)?@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email);
}


  Future<bool> _isEmailInFirestore(String email) async {
    final querySnapshot = await _firestore.collection('users').doc(email).get();
    return querySnapshot.exists;
  }

  void _handleFirebaseAuthError(FirebaseAuthException e, BuildContext context) {
    String errorMessage = 'An error occurred';
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found with this email';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'Invalid email format';
    }
    _showSnackBar(context, errorMessage);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
