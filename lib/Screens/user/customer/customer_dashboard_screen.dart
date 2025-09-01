import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Auth/auth_screen.dart';

// This is the main screen that holds the BottomNavigationBar for the customer.
class CustomerDashboardScreen extends StatefulWidget {
  final String token;
  const CustomerDashboardScreen({super.key, required this.token});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab

  // List of the different pages for the customer
  static const List<Widget> _widgetOptions = <Widget>[
    CustomerHome(),
    CustomerMenuScreen(), // Placeholder screen
    CustomerPaymentsScreen(), // Placeholder screen
    CustomerProfileScreen(), // Placeholder screen
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
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payments',
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

// The main content for the Customer's Home tab
class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  String customerName = "Priya Sharma";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // --- Welcome Header ---
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello,",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
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
            const SizedBox(height: 24),

            // --- Subscription Status Card ---
            const _SubscriptionStatusCard(
              planName: "Monthly Tiffin",
              daysLeft: 18,
            ),
            const SizedBox(height: 24),

            // --- Today's Menu Section ---
            const _TodayMenuSection(),
            const SizedBox(height: 24),

            // --- Quick Actions Section ---
            Text(
              "Quick Actions",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(
                    label: "Weekly Menu",
                    icon: Icons.calendar_month_outlined,
                    color: Color(0xFF0288D1)),
                _QuickActionButton(
                    label: "Make Payment",
                    icon: Icons.currency_rupee,
                    color: Color(0xFF388E3C)),
                _QuickActionButton(
                    label: "Pause Tiffin",
                    icon: Icons.pause_circle_outline,
                    color: Color(0xFFD32F2F)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Reusable Customer Dashboard Widgets ---

class _SubscriptionStatusCard extends StatelessWidget {
  final String planName;
  final int daysLeft;

  const _SubscriptionStatusCard(
      {required this.planName, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[700],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 15)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SUBSCRIPTION STATUS",
            style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            planName,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                "$daysLeft Days Left",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayMenuSection extends StatelessWidget {
  const _TodayMenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Menu",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800),
        ),
        const SizedBox(height: 12),
        const _MenuCard(
          meal: "Breakfast",
          items: "Poha, Jalebi, Tea",
          icon: Icons.free_breakfast_outlined,
          color: Colors.lightBlue,
        ),
        const SizedBox(height: 12),
        const _MenuCard(
          meal: "Lunch",
          items: "Roti, Dal Fry, Rice, Aloo Gobi",
          icon: Icons.lunch_dining_outlined,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        const _MenuCard(
          meal: "Dinner",
          items: "Roti, Paneer Masala, Jeera Rice",
          icon: Icons.dinner_dining_outlined,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String meal;
  final String items;
  final IconData icon;
  final Color color;

  const _MenuCard(
      {required this.meal,
      required this.items,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(items, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _QuickActionButton(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// --- Placeholder Screens for Customer Navigation ---

class CustomerMenuScreen extends StatefulWidget {
  const CustomerMenuScreen({super.key});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body:
            Center(child: Text("Menu Screen", style: TextStyle(fontSize: 24))));
  }
}

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Text("Payments Screen", style: TextStyle(fontSize: 24))));
  }
}

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Text("Profile Screen", style: TextStyle(fontSize: 24))));
  }
}
