// In file: lib/Screens/user/mess_owner/mess_dashboard_screen.dart

import 'dart:convert';

import 'package:dailydine/Screens/user/mess_owner/tabs/mess_owner_home_page.dart';
import 'package:dailydine/Screens/user/mess_owner/tabs/subscribers_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../credentials/api_url.dart';
import '../../../service/save_shared_preference.dart';
// Import the menu management screen we created
import 'tabs/menu_management_screen.dart';
import 'tabs/profile_page.dart';

// This is now the main widget that holds the BottomNavigationBar
class MessDashboardScreen extends StatefulWidget {
  final String token;

  const MessDashboardScreen({super.key, required this.token});

  @override
  State<MessDashboardScreen> createState() => _MessDashboardScreenState();
}

class _MessDashboardScreenState extends State<MessDashboardScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab
  Map<String, dynamic> messOwnerData = {};

  // List of the different pages for the mess owner
  List<Widget> pages = [];

  // Future to hold the result of loadUser, preventing re-fetching on rebuild
  Future<void>? _loadUserFuture;

  @override
  void initState() {
    super.initState();
    // Call the API only once when the widget is first initialized
    _loadUserFuture = loadUser();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> loadUser() async {
    int? userId = await getUserId();
    String? token = await getTokenId();
    while (userId == null && token == null) {
      userId = await getUserId();
      token = await getTokenId();
    }
    String apiUrl = '${url}mess/$userId';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      messOwnerData = jsonDecode(response.body);
      // Initialize the pages list after data is successfully fetched
      pages = <Widget>[
        MessOwnerHomePage(
          messOwnerData: messOwnerData,
        ),
        // The new dashboard UI is now the first page
        SubscribersPage(
          messOwnerData: messOwnerData,
        ),
        // Placeholder for Subscribers
        MenuManagementScreen(
          messOwnerData: messOwnerData,
        ),
        // The screen to add/update menus
        ProfilePage(
          messOwnerData: messOwnerData,
          idToken: token!,
        ),
        // Placeholder for Profile
      ];
    } else {
      // Handle non-200 responses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load user data. Please try late."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // Use the future from initState to prevent re-fetching on rebuilds
        future: _loadUserFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Display an error message if the future fails
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (pages.isEmpty) {
            // Handle the case where data loading finished but pages aren't set (e.g., API error)
            return const Center(
              child: Text("Could not load user data. Please try again."),
            );
          } else {
            return IndexedStack(
              // Using IndexedStack to keep the state of each page alive
              index: _selectedIndex,
              children: pages,
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // Ensures all labels are visible
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
