import 'package:flutter/material.dart';

// Placeholder screen for the "Locations" tab
class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});
  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}
class _AddLocationScreenState extends State<AddLocationScreen> {
  @override
  Widget build(BuildContext context) {
    // In the future, this screen would allow admins to manage verified locations.
    return const Center(child: Text("Location Management UI Goes Here", style: TextStyle(fontSize: 20)));
  }
}
