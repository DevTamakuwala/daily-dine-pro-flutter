import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for clipboard functionality
import 'setup_two_factor_screen.dart'; // The next screen in the flow

// A screen for users to set up two-factor authentication using an authenticator app.
class SetupMfaScreen extends StatefulWidget {
  const SetupMfaScreen({super.key});

  @override
  State<SetupMfaScreen> createState() => _SetupMfaScreenState();
}

class _SetupMfaScreenState extends State<SetupMfaScreen> {
  // --- Mock Data (In a real app, this would come from your backend API) ---
  final String _qrCodeImageUrl = "https://placehold.co/250x250/EFEFEF/333333?text=QR+Code";
  final String _secretKey = "JBSWY3DPEHPK3PXP"; // Example secret key

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Secret key copied to clipboard!")),
    );
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Image.network(
                _qrCodeImageUrl,
                width: 250,
                height: 250,
                loadingBuilder: (context, child, progress) {
                  return progress == null ? child : const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Or enter the key manually:",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            // --- Secret Key ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secretKey,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(width: 16),
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
                      builder: (context) => const VerifyTwoFactorScreen(isInitialSetup: true),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

