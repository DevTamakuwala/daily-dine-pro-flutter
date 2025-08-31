import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the new, separate screen files for each tab
import 'tabs/admin_home_screen.dart';
import 'tabs/verify_mess_owner_screen.dart';
import 'tabs/update_mess_data_screen.dart';
import 'tabs/add_location_screen.dart';
import 'package:dailydine/Screens/Auth/auth_screen.dart';


// This is the main screen that holds the BottomNavigationBar for the Admin.
class AdminDashboardScreen extends StatefulWidget {
  final String token;
  const AdminDashboardScreen({super.key, required this.token});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab

  // List of the different pages for the admin, now referencing the imported screens
  static const List<Widget> _widgetOptions = <Widget>[
    AdminHomeScreen(),
    VerifyMessOwnerScreen(),
    UpdateMessDataScreen(),
    AddLocationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigate back to the login screen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthScreen(screenSize: MediaQuery.of(context).size)),
          (Route<dynamic> route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 24),
          ),
        ],
      ),
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
