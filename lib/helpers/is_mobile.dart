import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool isMobile(BuildContext context) {
  //  Grab screen width 
  double screenWidth = MediaQuery.of(context).size.width;

  //  If screen width is less than 
  if (screenWidth < 1000) return true;

  //  If application compiled to run on web
  if (!kIsWeb) return true;
  
  //  Return true if passes other conditions
  return false;
}