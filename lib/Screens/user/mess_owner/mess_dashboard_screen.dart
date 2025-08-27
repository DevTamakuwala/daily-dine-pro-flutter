import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../animations/animated_background.dart';

// The main dashboard screen widget, now a StatefulWidget
class MessDashboardScreen extends StatefulWidget {
  final String token;

  const MessDashboardScreen({super.key, required this.token});

  @override
  State<MessDashboardScreen> createState() => _MessDashboardScreenState();
}

class _MessDashboardScreenState extends State<MessDashboardScreen> {
  // In a StatefulWidget, you can hold state like the mess name
  String messName = "Annapurna Mess";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Consistent animated background
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Custom AppBar ---
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                            'https://placehold.co/100x100/EFEFEF/333333?text=Logo'),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back!",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14),
                          ),
                          Text(
                            messName, // Using the state variable
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon:
                            const Icon(Icons.notifications_outlined, size: 28),
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
                      ),
                    ],
                  ),
                ),

                // --- Main Dashboard Content ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    children: [
                      // --- Summary Cards ---
                      const Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: "Subscribers",
                              value: "124",
                              icon: Icons.people_alt_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _SummaryCard(
                              title: "Today's Revenue",
                              value: "₹4,520",
                              icon: Icons.currency_rupee,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: "Daily Payments",
                              value: "98",
                              icon: Icons.receipt_long_outlined,
                              color: Colors.orange,
                            ),
                          ),
                        ],
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
                            label: "Edit Menu",
                            icon: Icons.restaurant_menu,
                            color: Color(0xFF6A1B9A),
                          ),
                          _QuickActionButton(
                            label: "Subscribers",
                            icon: Icons.group,
                            color: Color(0xFF00838F),
                          ),
                          _QuickActionButton(
                            label: "Payments",
                            icon: Icons.payment,
                            color: Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Reusable Internal Widgets ---

// A card for displaying summary information (e.g., Subscribers)
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// A widget for the "Today's Menu" section with tabs
class _TodayMenuSection extends StatelessWidget {
  const _TodayMenuSection();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Breakfast"),
                Tab(text: "Lunch"),
                Tab(text: "Dinner"),
              ],
            ),
          ),
          const SizedBox(
            height: 150, // Fixed height for the TabBarView
            child: TabBarView(
              children: [
                _MenuList(items: ["Poha", "Upma", "Tea/Coffee"]),
                _MenuList(items: ["Roti", "Dal Fry", "Rice", "Aloo Gobi"]),
                _MenuList(items: ["Roti", "Paneer Masala", "Jeera Rice"]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Displays a list of menu items for a specific meal
class _MenuList extends StatelessWidget {
  final List<String> items;

  const _MenuList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              "• ${items[index]}",
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}

// A large, tappable button for quick actions
class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
