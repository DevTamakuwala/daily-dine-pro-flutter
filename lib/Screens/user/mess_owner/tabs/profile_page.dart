import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:dailydine/Screens/user/mess_owner/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../widgets/build_section_header.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> messOwnerData;
  final String idToken;

  const ProfilePage({super.key, required this.messOwnerData, required this.idToken});

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

  @override
  Widget build(BuildContext context) {
    String avatar =
        "${widget.messOwnerData['firstName'][0]}${widget.messOwnerData['lastName'][0]}";
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        style: TextStyle(color: Colors.white, fontSize: 40)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.messOwnerData['mess']['messName'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${widget.messOwnerData['firstName']} ${widget.messOwnerData['lastName']}",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          buildSectionHeader("Mess Details"),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.location_on_outlined,
                  title: "Address",
                  subtitle: widget.messOwnerData['mess']['address'],
                ),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  title: "Contact",
                  subtitle:
                      "+91 ${widget.messOwnerData['mess']['messPhoneNo']}",
                ),
                _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: widget.messOwnerData['email']),
              ],
            ),
          ),
          const SizedBox(height: 24),

          buildSectionHeader("Actions"),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text("Edit Profile"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to an Edit Profile screen
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
                          mfaEnabled: widget.messOwnerData['mfaEnabled'],
                          email: widget.messOwnerData['email'],
                          idToken: widget.idToken,
                          responseBody: widget.messOwnerData,
                        ),
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
