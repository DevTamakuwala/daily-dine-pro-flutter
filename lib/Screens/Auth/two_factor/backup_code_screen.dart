import 'package:flutter/material.dart';

// This screen allows a user to log in using one of their single-use backup codes.
class BackupCodeScreen extends StatefulWidget {
  const BackupCodeScreen({super.key});

  @override
  State<BackupCodeScreen> createState() => _BackupCodeScreenState();
}

class _BackupCodeScreenState extends State<BackupCodeScreen> {
  final TextEditingController _backupCodeController = TextEditingController();

  @override
  void dispose() {
    _backupCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Use a Backup Code"),
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
            const Icon(Icons.password_rounded, size: 60, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              "Enter Backup Code",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Please enter one of your 6-digit backup codes to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),

            // --- Backup Code Input Field ---
            TextField(
              controller: _backupCodeController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                counterText: "",
                hintText: "••••••",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                ),
              ),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final backupCode = _backupCodeController.text;
                  // TODO: Add logic to verify the backup code with your backend.
                  print("Entered Backup Code: $backupCode");
                },
                child: const Text(
                  "Verify & Log In",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
