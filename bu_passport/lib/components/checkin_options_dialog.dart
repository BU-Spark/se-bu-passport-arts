import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CheckInOptionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Check-in Options"),
      content: Text("Would you like to check in with a photo?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text("No"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text("Yes"),
        ),
      ],
    );
  }
}