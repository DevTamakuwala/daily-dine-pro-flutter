import 'dart:convert';

import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:dailydine/Screens/user/mess_owner/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../service/save_shared_preference.dart';
import '../../../../widgets/build_section_header.dart';
import '../../../change_password_screen.dart';
import '../edit_profile_screen.dart';

class ProfilePage extends StatefulWidget {
  final String idToken;

  const ProfilePage({super.key, required this.idToken});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Logout function to clear session and navigate to AuthScreen
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                AuthScreen(screenSize: MediaQuery.of(context).size)),
        (Route<dynamic> route) => false,
      );
    }
  }

  Map<String, dynamic> messOwnerData = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: messData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          String avatar =
              "${messOwnerData['firstName'][0]}${messOwnerData['lastName'][0]}";
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Text("My Profile"),
              backgroundColor: Colors.white,
              elevation: 1,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Header Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.orange,
                          child: Text(avatar,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 40)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          messOwnerData['mess']['messName'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${messOwnerData['firstName']} ${messOwnerData['lastName']}",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                buildSectionHeader("Mess Details"),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.location_on_outlined,
                        title: "Address",
                        subtitle: messOwnerData['mess']['address'],
                      ),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        title: "Contact",
                        subtitle: "+91 ${messOwnerData['mess']['messPhoneNo']}",
                      ),
                      _buildInfoTile(
                          icon: Icons.email_outlined,
                          title: "Email",
                          subtitle: messOwnerData['email']),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                buildSectionHeader("Actions"),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: const Text("Edit Profile"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text("Settings"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Navigate to a Settings screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => MessOwnerSettingsPage(
                                mfaEnabled: messOwnerData['mfaEnabled'],
                                email: messOwnerData['email'],
                                idToken: widget.idToken,
                                responseBody: messOwnerData,
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text("Change Password"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red.shade700),
                        title: Text("Logout",
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600)),
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> messData() async {
    String? messData = await getMessData();
    while (messData == null) {
      messData = await getMessData();
    }
    print(jsonDecode(messData)["mess"]);
    messOwnerData = jsonDecode(messData);
  }

  Widget _buildInfoTile(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange.shade700),
      title: Text(title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500)),
    );
  }
}
