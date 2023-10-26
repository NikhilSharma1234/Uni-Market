import 'package:flutter/material.dart';

AlertDialog appDialog(BuildContext context, title, description, firstButton) {
  return AlertDialog(
    backgroundColor: Color(0xFF041E42),
    title: Text(title),
    content: Text(description),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, firstButton),
        child: Text(firstButton),
      ),
    ],
  );
}
