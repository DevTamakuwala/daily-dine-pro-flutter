import 'package:flutter/material.dart';

import '../../../widgets/build_section_header.dart';

class MessOwnerSettingsPage extends StatefulWidget {
  const MessOwnerSettingsPage({super.key});

  @override
  State<MessOwnerSettingsPage> createState() => _MessOwnerSettingsPageState();
}

class _MessOwnerSettingsPageState extends State<MessOwnerSettingsPage> {
  // State variable to track the status of the 2FA switch.
  bool isAvailable = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Setting the background color of the page to white.
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          if (isLoading)
            Container(
              decoration: BoxDecoration(color: Colors.grey),
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // A section header for the 2FA settings.
              buildSectionHeader("2FA"),
              Column(
                children: [
                  // A ListTile with a switch to toggle 2FA.
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text("Enable 2FA"),
                    trailing: Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        // Update the state when the switch is toggled.
                        setState(() {
                          isAvailable = value;
                          isLoading = value;
                        });
                      },
                      activeColor: Colors
                          .green, // Green color when the switch is active.
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
