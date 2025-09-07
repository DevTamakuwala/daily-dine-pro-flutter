// Screen for verifying Two-Factor Authentication setup or login
// Handles both initial setup verification and ongoing login verification
import 'dart:convert';


import 'package:dailydine/Screens/user/admin/admin_dashboard_screen.dart';
import 'package:dailydine/Screens/user/mess_owner/mess_dashboard_screen.dart';
import 'package:dailydine/enums/user_types.dart';
import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../credentials/api_url.dart';
import '../../user/customer/customer_dashboard_screen.dart';
import 'backup_code_screen.dart';

class VerifyTwoFactorScreen extends StatefulWidget {
  // Authentication token for secure API calls
  final String idToken;
  // User's email for MFA verification
  final String email;
  // Whether this is the initial MFA setup or a login verification
  final bool isInitialSetup;
  // Response from the MFA setup API containing verification details
  final Map<String, dynamic> responseBody;
  // Determines the source of the navigation to this screen.
  // It can be "Disable" or other values.
  final String from;
  const VerifyTwoFactorScreen({
    super.key,
    required this.isInitialSetup,
    required this.idToken,
    required this.email,
    required this.responseBody,
    required this.from
  });

  @override
  State<VerifyTwoFactorScreen> createState() => _VerifyTwoFactorScreenState();
}

class _VerifyTwoFactorScreenState extends State<VerifyTwoFactorScreen> {
  // Controllers for the 6-digit OTP input fields
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  // Focus nodes for handling input field navigation
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    // Clean up controllers and focus nodes to prevent memory leaks
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Combines the 6 digits into a single OTP string
  String _getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Two-Factor Verification"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF4F6F8),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.security, size: 60, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              "Enter Verification Code",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Please enter the 6-digit code from your authenticator app to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),

            // --- OTP Input Fields ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.orange.shade700, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // --- Verify Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final otp = _getOtp();
                  await verifyOtp(otp);
                },
                child: const Text(
                  "Verify",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Spacer(),
            if (!widget.isInitialSetup)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Add logic for helping the user
                    },
                    child: const Text(
                      "Having trouble? • Use a backup code",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  // Verifies the provided OTP with the server.
  // Handles both enabling and disabling MFA based on the 'from' parameter.
  Future<void> verifyOtp(String otp) async {
    // If the screen was opened to disable MFA, call the disableMFA method.
    if (widget.from == "Disable") {
      await disableMFA(widget.email, otp);
      return;
    }

    // Otherwise, proceed with the standard OTP verification for enabling MFA or logging in.
    String apiUrl = '${url}mfa/verify';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.idToken}"
      },
      body: jsonEncode({
        'email': widget.email,
        'code': otp,
      }),
    );

    if (response.statusCode == 200) {
      // If this is the initial setup, navigate to the backup codes screen.
      if (widget.isInitialSetup) {
        Navigator.of(context)..pop()..pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BackupCodesScreen(
              backupCodes: widget.responseBody["backupCodes"],
              from: widget.from,
            ),
          ),
        );
      } else {
        // If it's a regular login, determine the user role and navigate to the appropriate dashboard.
        String? userRole = await getUserRole();
        while(userRole == null){
          userRole = await getUserRole();
        }
        Navigator.pop(context);
        if(userRole == UserType.MessOwner.name) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) =>
                  MessDashboardScreen(
                    token: widget.idToken,
                  ),
            ),
          );
        } else if(userRole == UserType.Customer.name){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => CustomerDashboardScreen(
                token: widget.idToken,
              ),
            ),
          );
        } else if (userRole == UserType.Admin.name) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => AdminDashboardScreen(
                token: widget.idToken,
              ),
            ),
          );
        }
      }
    } else {
      // Show an error message if the OTP is incorrect.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect Code")),
      );
    }
  }

  // Disables Multi-Factor Authentication for the user.
  Future<void> disableMFA(String email, String otp) async {
    // API endpoint for disabling MFA.
    String apiUrl = '${url}mfa/delete';
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.idToken}" // Secure token-based authentication
      },
      body: jsonEncode({
        'email': widget.email,
        'code': otp,
      }),
    );

    if (response.statusCode == 200) {
      // If successful, go back to the previous screen.
      Navigator.pop(context);
    } else {
      // Show an error message if the server encounters an issue.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text("There is some issue with the server. Try again later.")),
      );
    }
  }
}
