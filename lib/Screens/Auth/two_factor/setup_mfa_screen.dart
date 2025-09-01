// Screen for setting up Multi-Factor Authentication using an authenticator app
// Handles both QR code scanning and manual key entry methods
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'setup_two_factor_screen.dart';

// A screen for users to set up two-factor authentication using an authenticator app.
class SetupMfaScreen extends StatefulWidget {
  // Authentication token for secure API calls
  final String idToken;
  // User's email for MFA association
  final String email;
  // Response from the MFA setup API containing QR code and setup key
  final Map<String, dynamic> response;

  const SetupMfaScreen(
      {super.key,
      required this.idToken,
      required this.response,
      required this.email});

  @override
  State<SetupMfaScreen> createState() => _SetupMfaScreenState();
}

class _SetupMfaScreenState extends State<SetupMfaScreen> {
  // QR code image URL for authenticator app scanning
  String _qrCodeImageUrl =
      "https://placehold.co/250x250/EFEFEF/333333?text=QR+Code";
  // Secret key for manual entry in authenticator app
  String _secretKey = "JBSWY3DPEHPK3PXP"; // Example secret key

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Secret key copied to clipboard!")),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize with values from the backend response
    _qrCodeImageUrl = widget.response["qrCodeUri"];
    _secretKey = widget.response["manualSetupKey"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Up Authenticator"),
      ),
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Scan the QR Code",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Use an authenticator app (like Google Authenticator) to scan this code.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            // --- QR Code Image ---
            // --- QR Code for MFA Setup ---
            Builder(
              builder: (context) {
                // TODO: Replace this with the actual value from your backend
                final String qrCodeUri = widget.response["qrCodeUri"];
                final String base64Image = qrCodeUri.split(',').last;
                try {
                  final bytes = base64Decode(base64Image);
                  return Column(
                    children: [
                      const Text(
                        'Scan this QR code with your authenticator app (Google Authenticator, etc.)',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Image.memory(
                        bytes,
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                } catch (e) {
                  return const Text('Failed to load QR code');
                }
              },
            ),
            // --- End QR Code ---
            const SizedBox(height: 24),
            Text(
              "Or enter the key manually:",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            // --- Secret Key ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secretKey,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0),
                  ),
                  const SizedBox(width: 0),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(_secretKey),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            // --- Continue Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the verification page in 'setup' mode.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerifyTwoFactorScreen(
                        isInitialSetup: true,
                        idToken: widget.idToken,
                        email: widget.email,
                        responseBody: widget.response,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Continue"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
