import 'package:flutter/material.dart';


class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({
    required this.text,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onClicked,

    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll<Color>(Colors.redAccent),

    ),

    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}