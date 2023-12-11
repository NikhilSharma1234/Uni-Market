import 'package:flutter/material.dart';

StepState stepperState(index, stepperNumber) {
  if (stepperNumber == index) return StepState.editing;

  return StepState.disabled;
}
