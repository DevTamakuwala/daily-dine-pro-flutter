import 'package:flutter/material.dart';

Widget buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}