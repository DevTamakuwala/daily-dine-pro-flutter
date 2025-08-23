import 'package:flutter/material.dart';

Widget buildFlipButton({required String label, required VoidCallback onFlip}) {
  return TextButton(
    onPressed: onFlip,
    child: Text(label, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
  );
}