import 'dart:async';
import 'package:dailydine/Screens/user/admin/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../../service/save_shared_preference.dart';

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
  // CHANGE: initState was converted to an async Future here by the user so it can await getTokenId().
  // NOTE: Making initState async is not the recommended Flutter pattern because the framework
  // does not expect an async initState. Prefer calling an async helper (e.g., _initAsync())
  // from a non-async initState. The code remains unchanged behavior-wise to reflect the user's edits.
  Future<void> initState() async {
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

    // CHANGE: Repeatedly fetch token until available and then navigate back to Admin dashboard.
    // The user added a busy-wait loop that keeps calling getTokenId() until it returns.
    // After a short delay the screen pops twice and then pushes AdminDashboardScreen with the token.
    // Behaviour note: popping twice assumes the navigation stack contains two previous routes
    // (details screen + list). If stack differs this may cause unexpected navigation.
    String? token = await getTokenId();
    while (token == null) {
      token = await getTokenId();
    }

    // After 2 seconds, navigate back to the list of verifications and open AdminDashboard.
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // Pop twice to remove this screen and the details screen (user change)
        Navigator.of(context)..pop();
        Navigator.of(context)..pop();
        // Then push the AdminDashboardScreen with the token
        Navigator.push(context, MaterialPageRoute(builder: (builder)=>AdminDashboardScreen(token: token!)));
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