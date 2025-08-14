import 'package:flutter/material.dart';
import '../../animations/animated_background.dart';
import '../../widgets/BuildTextFormField.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _hasEightChars = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    // Add a listener to the password controller to update validation checks in real-time.
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    // Update the state based on the password content.
    setState(() {
      _hasEightChars = password.length >= 8;
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      "Create new password",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your new password must be different from previously used passwords.",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 32),
                    const Text("New Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    // Using a standard TextFormField to add the visibility icon
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "Enter new password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter a password';
                        if (!_hasEightChars || !_hasNumber) return 'Password does not meet requirements';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildValidationRow(text: "At least 8 characters", isValid: _hasEightChars),
                    const SizedBox(height: 8),
                    _buildValidationRow(text: "Contains a number", isValid: _hasNumber),
                    const SizedBox(height: 24),
                    const Text("Confirm Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    // Using your custom widget here
                    buildTextFormField(
                      controller: _confirmPasswordController,
                      label: "Confirm new password",
                      icon: Icons.lock_outline, // Icon is required, so we add one
                      obscureText: true,
                    ),
                    const Spacer(),
                    // Using a custom-styled button to match the blue color
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: const Color(0xFFFF9800), // Blue color from the screenshot
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Implement password update logic
                          }
                        },
                        child: const Text("Reset password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
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

  // Helper widget to display the validation criteria (e.g., "At least 8 characters")
  Widget _buildValidationRow({required String text, required bool isValid}) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel_outlined,
          color: isValid ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: isValid ? Colors.black87 : Colors.red),
        ),
      ],
    );
  }
}
