import 'package:flutter/material.dart';

class CustomerPaymentsScreen extends StatelessWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Payments")),
      body: const Center(
        child: Text("Payments Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}