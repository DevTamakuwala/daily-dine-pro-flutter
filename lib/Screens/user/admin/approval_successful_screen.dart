import 'dart:async';
import 'package:flutter/material.dart';

class ApprovalSuccessfulScreen extends StatefulWidget {
  const ApprovalSuccessfulScreen({super.key});

  @override
  State<ApprovalSuccessfulScreen> createState() => _ApprovalSuccessfulScreenState();
}

class _ApprovalSuccessfulScreenState extends State<ApprovalSuccessfulScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup for the bouncy checkmark effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Start the animation
    _controller.forward();

    // After 2 seconds, navigate back to the list of verifications
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // Pop twice to remove this screen and the details screen
        Navigator.of(context)..pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Approved Successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}