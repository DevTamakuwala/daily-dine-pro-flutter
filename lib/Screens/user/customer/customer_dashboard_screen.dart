import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Auth/auth_screen.dart';
// Import all the new, separate screen files
import 'CustomerHomeScreen.dart';
import 'CustomerProfileScreen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final String token;
  const CustomerDashboardScreen({super.key, required this.token});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab

  // List of the separate page widgets
  static const List<Widget> _widgetOptions = <Widget>[
    CustomerHomeScreen(token: '',),
    CustomerProfileScreen(),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange[800],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}