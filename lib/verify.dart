import 'package:flutter/material.dart';

Step Verify(index) {
  return Step(
    title: const Text('Verify'),
    content: const Text(
      'This will be the multi-factor authentication step where they enter a code from their email',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    isActive: index >= 0,
    state: index >= 1 ? StepState.complete : StepState.disabled,
  );
}
