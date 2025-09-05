import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../credentials/api_url.dart';
import '../../../Auth/auth_screen.dart';

class MessOwnerHomePage extends StatefulWidget {
  const MessOwnerHomePage({super.key});

  @override
  State<MessOwnerHomePage> createState() => _MessOwnerHomePageState();
}

class _MessOwnerHomePageState extends State<MessOwnerHomePage> {
  // Logout Function (kept here for profile button access)
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
    return FutureBuilder(
      future: getMessOwnerData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F7FC),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF4F7FC),
              elevation: 0,
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back,",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Annapurna Mess",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to Notifications Screen
                  },
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () => _logout(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text("A", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              children: [
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildRevenueChart(),
                const SizedBox(height: 24),
                _buildRecentActivity(),
              ],
            ),
          );
        }
      },
    );
  }

  // A Grid for displaying key statistics
  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "At a Glance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: const [
            _StatCard(
              title: "Subscribers",
              value: "124",
              icon: Icons.people_alt_outlined,
              color: Colors.blue,
            ),
            _StatCard(
              title: "Today's Revenue",
              value: "₹4,520",
              icon: Icons.currency_rupee,
              color: Colors.green,
            ),
            _StatCard(
              title: "Pending Payments",
              value: "12",
              icon: Icons.receipt_long_outlined,
              color: Colors.orange,
            ),
            _StatCard(
              title: "Meals Served Today",
              value: "98",
              icon: Icons.fastfood_outlined,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  // A placeholder for a weekly revenue chart
  Widget _buildRevenueChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weekly Revenue",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              "Chart Placeholder",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  // An actionable list of recent activities
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _ActivityTile(
          icon: Icons.person_add_alt_1_outlined,
          color: Colors.green,
          title: "New Subscriber",
          subtitle: "Rohan Sharma subscribed to Monthly Plan",
          trailing: "Just now",
        ),
        _ActivityTile(
          icon: Icons.payment_outlined,
          color: Colors.blue,
          title: "Payment Received",
          subtitle: "Received ₹1200 from Anjali Mehta",
          trailing: "5m ago",
        ),
        _ActivityTile(
          icon: Icons.pause_circle_outline,
          color: Colors.orange,
          title: "Subscription Paused",
          subtitle: "Vikram Singh paused for 3 days",
          trailing: "1h ago",
        ),
      ],
    );
  }

  Future<void> getMessOwnerData() async {
    int? userId = await getUserId();
    String? token = await getTokenId();
    while (userId == null && token == null) {
      userId = await getUserId();
      token = await getTokenId();
    }
    String apiUrl = '${url}mess/$userId';
    print(apiUrl);
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    print(response.body);
  }
}

// --- Reusable Internal Widgets for the Dashboard Page ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color color;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text(trailing,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
