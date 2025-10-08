import 'package:flutter/material.dart';

customToast({required message, required context}){
  ScaffoldMessenger.of(context!).showSnackBar(
    SnackBar(
      elevation: 0,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Color(0xFFFF9800),
        ),
        child: Center(child: Text(message, style: Theme.of(context!).textTheme.labelLarge,)),
      ),
    ),
  );
}