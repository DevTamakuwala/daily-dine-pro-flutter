import 'dart:convert';

import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../credentials/api_url.dart';
import '../../../widgets/build_section_header.dart';
import '../../Auth/two_factor/setup_mfa_screen.dart';
import '../../Auth/two_factor/verify_two_factor_screen.dart';

class MessOwnerSettingsPage extends StatefulWidget {
  final bool mfaEnabled;
  final String email;
  final Map<String, dynamic> responseBody;
  final String idToken;

  const MessOwnerSettingsPage(
      {super.key,
      required this.mfaEnabled,
      required this.email,
      required this.responseBody,
      required this.idToken});

  @override
  State<MessOwnerSettingsPage> createState() => _MessOwnerSettingsPageState();
}

class _MessOwnerSettingsPageState extends State<MessOwnerSettingsPage> {
  // State variable to track the status of the 2FA switch.
  bool isAvailable = true;
  bool isLoading = false;

  Future<void> init() async {
    String? messData = await getMessData();
    while (messData == null) {
      messData = await getMessData();
    }
    print(messData);
    isAvailable = jsonDecode(messData)['mfaEnabled'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
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
                            onChanged: (value) async {
                              // Update the state when the switch is toggled.
                              if (!widget.mfaEnabled) {
                                setState(() {
                                  isLoading = true;
                                  isAvailable = true;
                                });
                                await setUpMFA(widget.email);
                              } else {
                                // await disableMFA(widget.email);
                                setState(() {
                                  isLoading = false;
                                  isAvailable = false;
                                });
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Warning"),
                                      content: Text(
                                          "Are you sure you want to disable 2 Factor-Authentication ?"),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (builder) =>
                                                    VerifyTwoFactorScreen(
                                                        isInitialSetup: false,
                                                        idToken: widget.idToken,
                                                        email: widget.email,
                                                        responseBody:
                                                            widget.responseBody,
                                                        from: "Disable"),
                                              ),
                                            );
                                            isAvailable = false;
                                            isLoading = false;
                                          },
                                          child: Text("Yes"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            isAvailable = true;
                                            isLoading = false;
                                            Navigator.pop(context);
                                          },
                                          child: Text("No"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              }
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
      },
    );
  }

  // Initiates the MFA setup process by calling the backend API
  Future<void> setUpMFA(String email) async {
    String? idToken = await getTokenId();
    while (idToken == null) {
      idToken = await getTokenId();
    }
    // API endpoint for MFA setup initialization
    String apiUrl = '${url}mfa/setup';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken" // Secure token-based authentication
      },
      body: jsonEncode({'email': email}), // User email for MFA association
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        isAvailable = true;
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetupMfaScreen(
            idToken: idToken ?? "",
            response: responseBody,
            email: email,
            from: "Settings",
          ),
        ),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("There is some issue with the server. Try again later.")),
      );
    }
  }
}
