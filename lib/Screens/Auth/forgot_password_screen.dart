import 'package:flutter/material.dart';
// Import the reusable animated background
import '../../animations/animated_background.dart';
import 'create_new_password_screen.dart';
// Import the reusable widgets
import '../../widgets/BuildSubmitButton.dart';
import '../../widgets/BuildTextFormField.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar provides the back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Use the self-contained animated background widget
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Enter the email address associated with your account and we'll send you a link to reset your password.",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Email Address",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    // Use the reusable BuildTextFormField widget class
                    buildTextFormField(
                      controller: _emailController,
                      label: "you@example.com",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Spacer(),
                    // Use the reusable BuildSubmitButton widget class
                    buildSubmitButton(
                      label: "Submit",
                      onPressed: () {
                        // TODO: Implement password reset email logic
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNewPasswordScreen()));
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
