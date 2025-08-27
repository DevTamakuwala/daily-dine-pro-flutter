import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Auth/auth_screen.dart';

// This is the main screen that holds the BottomNavigationBar for the Admin.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required String token});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab

  // List of the different pages for the admin
  static const List<Widget> _widgetOptions = <Widget>[
    AdminHome(),
    VerifyMessOwnerScreen(),
    UpdateMessDataScreen(),
    AddLocationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Verify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory_outlined),
            activeIcon: Icon(Icons.store_mall_directory),
            label: 'Messes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt_outlined),
            activeIcon: Icon(Icons.add_location_alt),
            label: 'Locations',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo[700],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// The main content for the Admin's Home/Dashboard tab
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs =
              await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => AuthScreen(
                      screenSize: MediaQuery.of(context).size),
                ),
              );
            },
            icon: Icon(Icons.person, size: 28),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F6F8),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            "Overview",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _SummaryCard(title: "Pending Verifications", value: "12", icon: Icons.pending_actions, color: Colors.orange)),
              SizedBox(width: 16),
              Expanded(child: _SummaryCard(title: "Total Messes", value: "254", icon: Icons.store, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _SummaryCard(title: "Total Customers", value: "1,280", icon: Icons.people, color: Colors.blue)),
              SizedBox(width: 16),
              Expanded(child: _SummaryCard(title: "Reported Issues", value: "3", icon: Icons.report_problem, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Recent Activity",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const _ActivityCard(
            title: "New Mess Registration",
            subtitle: "'Shree Krishna Mess' is awaiting verification.",
            icon: Icons.storefront,
          ),
          const _ActivityCard(
            title: "Location Added",
            subtitle: "New verified location added in Hinjewadi Phase 1.",
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }
}

// --- Reusable Admin Widgets ---

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _ActivityCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}


// --- Placeholder Screens for Admin Navigation ---

class VerifyMessOwnerScreen extends StatefulWidget {
  const VerifyMessOwnerScreen({super.key});
  @override
  State<VerifyMessOwnerScreen> createState() => _VerifyMessOwnerScreenState();
}
class _VerifyMessOwnerScreenState extends State<VerifyMessOwnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Verify Mess Owners")), body: const Center(child: Text("Verification List Goes Here", style: TextStyle(fontSize: 20))));
  }
}

class UpdateMessDataScreen extends StatefulWidget {
  const UpdateMessDataScreen({super.key});
  @override
  State<UpdateMessDataScreen> createState() => _UpdateMessDataScreenState();
}
class _UpdateMessDataScreenState extends State<UpdateMessDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Manage Messes")), body: const Center(child: Text("Mess List Goes Here", style: TextStyle(fontSize: 20))));
  }
}

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});
  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}
class _AddLocationScreenState extends State<AddLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Add Verified Locations")), body: const Center(child: Text("Location Management UI Goes Here", style: TextStyle(fontSize: 20))));
  }
}
