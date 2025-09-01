import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../user/customer/customer_dashboard_screen.dart';

// A screen to display the user's generated backup codes after setting up 2FA.
class BackupCodesScreen extends StatelessWidget {
  final List<dynamic> backupCodes;

  const BackupCodesScreen({super.key, required this.backupCodes});

  void _copyCodesToClipboard(BuildContext context) {
    final allCodes = backupCodes.join('\n');
    Clipboard.setData(ClipboardData(text: allCodes));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All backup codes copied to clipboard!")),
    );
  }

  Future<void> _finishSetup(BuildContext context) async {
    // In a real app, you would navigate the user to their dashboard or settings page.
    // For now, we'll just pop back twice to exit the 2FA setup flow.
    String? idToken = await getTokenId();
    Navigator.of(context)
      ..pop()
      ..pop();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (builder) => CustomerDashboardScreen(
              token: idToken ?? "",
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Backup Codes"),
        automaticallyImplyLeading: false, // Prevents user from going back
      ),
      backgroundColor: const Color(0xFFF4F6F8),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              "Save Your Backup Codes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Store these codes in a safe place. They can be used to log in if you lose access to your authenticator app.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            // --- Codes Display ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: backupCodes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      backupCodes[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text("Copy Codes"),
              onPressed: () => _copyCodesToClipboard(context),
            ),
            const Spacer(),
            // --- Done Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _finishSetup(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
