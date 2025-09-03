// In file: lib/Screens/user/mess_owner/subscribers_page.dart

import 'package:flutter/material.dart';

// A simple data model for a subscriber
class _Subscriber {
  final String name;
  final String plan;
  final String status;

  _Subscriber({required this.name, required this.plan, required this.status});
}

class SubscribersPage extends StatefulWidget {
  const SubscribersPage({super.key});

  @override
  State<SubscribersPage> createState() => _SubscribersPageState();
}

class _SubscribersPageState extends State<SubscribersPage> {
  // Mock data for the list of subscribers
  final List<_Subscriber> _allSubscribers = [
    _Subscriber(name: "Rohan Sharma", plan: "Monthly Plan", status: "Active"),
    _Subscriber(name: "Anjali Mehta", plan: "Monthly Plan", status: "Active"),
    _Subscriber(name: "Vikram Singh", plan: "Weekly Plan", status: "Paused"),
    _Subscriber(name: "Priya Patel", plan: "Monthly Plan", status: "Expired"),
    _Subscriber(name: "Amit Kumar", plan: "Daily Pass", status: "Active"),
    _Subscriber(name: "Sunita Rao", plan: "Monthly Plan", status: "Active"),
  ];

  late List<_Subscriber> _filteredSubscribers;
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = "All";

  @override
  void initState() {
    super.initState();
    _filteredSubscribers = _allSubscribers;
    _searchController.addListener(_filterSubscribers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSubscribers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubscribers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSubscribers = _allSubscribers.where((subscriber) {
        final nameMatch = subscriber.name.toLowerCase().contains(query);
        final statusMatch = _activeFilter == "All" || subscriber.status == _activeFilter;
        return nameMatch && statusMatch;
      }).toList();
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _activeFilter = filter;
      _filterSubscribers(); // Re-run the filter logic with the new status
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Active": return Colors.green;
      case "Paused": return Colors.orange;
      case "Expired": return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Subscribers"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ["All", "Active", "Paused", "Expired"].map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: _activeFilter == status,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        _onFilterSelected(status);
                      }
                    },
                    selectedColor: Colors.orange.shade700,
                    labelStyle: TextStyle(
                      color: _activeFilter == status ? Colors.white : Colors.black,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Subscribers List
          Expanded(
            child: _filteredSubscribers.isEmpty
                ? const Center(child: Text("No subscribers found."))
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Space for the FAB
              itemCount: _filteredSubscribers.length,
              itemBuilder: (context, index) {
                final subscriber = _filteredSubscribers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Text(subscriber.name[0], style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(subscriber.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subscriber.plan),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(subscriber.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subscriber.status,
                        style: TextStyle(color: _getStatusColor(subscriber.status), fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to a detailed subscriber management screen
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show a dialog or navigate to a screen to add a new subscriber
        },
        backgroundColor: Colors.orange.shade700,
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}