import 'package:flutter/material.dart';

// The main content for the Admin's Home/Dashboard tab
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

// --- Reusable Admin Widgets for this screen ---

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
