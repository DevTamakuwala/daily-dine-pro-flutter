// In file: lib/Screens/user/mess_owner/profile_page.dart

import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password_screen.dart'; // Import the new password change screen

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Logout function to clear session and navigate to AuthScreen
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.orange,
                    child: Text("A",
                        style: TextStyle(color: Colors.white, fontSize: 40)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Annapurna Mess", // Mock Data
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Owner: Priya Sharma", // Mock Data
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader("Mess Details"),
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
                    subtitle: "123 Sunshine Apts, Kothrud, Pune"),
                _buildInfoTile(
                    icon: Icons.phone_outlined,
                    title: "Contact",
                    subtitle: "+91 98765 43210"),
                _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: "annapurna.mess@example.com"),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader("Account Settings"),
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
                  leading: const Icon(Icons.lock_outline),
                  title: const Text("Change Password"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to the new Change Password screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red.shade700),
                  title: Text("Logout",
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600)),
                  onTap: _logout,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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