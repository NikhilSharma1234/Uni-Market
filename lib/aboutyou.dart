import 'package:flutter/material.dart';

Step AboutYou(index) {
  return Step(
    title: const Text('About You'),
    content: Container(
      alignment: Alignment.centerLeft,
      child: const Text(
        'Upload documents and select their school in this step.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    isActive: index >= 0,
    state: index >= 2 ? StepState.complete : StepState.disabled,
  );
}
