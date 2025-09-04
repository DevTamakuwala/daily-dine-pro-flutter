// In file: lib/Screens/user/mess_owner/mess_dashboard_screen.dart

import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:dailydine/Screens/user/mess_owner/tabs/mess_owner_home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dailydine/Screens/user/mess_owner/tabs/subscribers_page.dart';

// Import the menu management screen we created
import 'tabs/menu_management_screen.dart';
import 'tabs/ProfilePage.dart';

// This is now the main widget that holds the BottomNavigationBar
class MessDashboardScreen extends StatefulWidget {
  final String token;

  const MessDashboardScreen({super.key, required this.token});

  @override
  State<MessDashboardScreen> createState() => _MessDashboardScreenState();
}

class _MessDashboardScreenState extends State<MessDashboardScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab

  // List of the different pages for the mess owner
  static final List<Widget> _pages = <Widget>[
    MessOwnerHomePage(), // The new dashboard UI is now the first page
    const SubscribersPage(),   // Placeholder for Subscribers
    const MenuManagementScreen(), // The screen to add/update menus
    const ProfilePage(),       // Placeholder for Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Using IndexedStack to keep the state of each page alive
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade600,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Subscribers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
