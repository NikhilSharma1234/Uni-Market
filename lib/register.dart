import 'package:flutter/material.dart';

Step Register(index) {
  return Step(
      title: const Text('Register'),
      content: Container(
        alignment: Alignment.centerLeft,
        child: const Text(
          'This will be the content for Registration. Full Name, Email, Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      isActive: index >= 0,
      state: index >= 0 ? StepState.complete : StepState.disabled);
}