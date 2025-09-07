// This screen handles the initial MFA setup choice for users
// It presents options to either enable or skip Two-Factor Authentication
import 'dart:convert';

import 'package:dailydine/Screens/Auth/two_factor/setup_mfa_screen.dart';
import 'package:dailydine/Screens/user/customer/customer_dashboard_screen.dart';
import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../credentials/api_url.dart';

// Widget that allows users to choose whether to enable Two-Factor Authentication
class EnableTwoFactor extends StatefulWidget {
  // ID token received after successful registration/login
  final String idToken;

  const EnableTwoFactor({super.key, required this.idToken});

  @override
  State<EnableTwoFactor> createState() => _EnableTwoFactorState();
}

class _EnableTwoFactorState extends State<EnableTwoFactor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enable Two-Factor Authentication"),
      ),
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- UI Elements for User Prompt ---
            const Text(
              "For your account safety we request you to enable two-factor authentication.",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Would you like to proceed with two-factor authentication ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            // --- Continue Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Retrieve user email for MFA setup
                  String? email = await getEmail();
                  // Navigate to the verification page in 'setup' mode.
                  await setUpMFA(email ?? "");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Continue"),
              ),
            ),
            const SizedBox(height: 24),
            // --- Not Now Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // If user skips, navigate to the customer dashboard
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerDashboardScreen(
                        token: widget.idToken,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Not Now"),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Initiates the MFA setup process by calling the backend API
  Future<void> setUpMFA(String email) async {
    // API endpoint for MFA setup initialization
    String apiUrl = '${url}mfa/setup';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.idToken}" // Secure token-based authentication
      },
      body: jsonEncode({'email': email}), // User email for MFA association
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // On successful API call, navigate to the MFA setup screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetupMfaScreen(
            idToken: widget.idToken,
            response: responseBody,
            from: "Login",
            email: email
          ),
        ),
      );
    } else {
      // Show a generic error message if the setup fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Secret key copied to clipboard!")),
      );
    }
  }
}
