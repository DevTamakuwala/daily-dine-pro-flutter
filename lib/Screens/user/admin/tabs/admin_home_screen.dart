import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../credentials/api_url.dart';
import '../../../../service/save_shared_preference.dart';
import '../../../../widgets/activity_card.dart';
import '../../../../widgets/custom_toast.dart';
import '../../../../widgets/summary_card.dart';

// The main content for the Admin's Home/Dashboard tab
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool isFetched = false;
  Map<String, dynamic> counts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: FutureBuilder(
        future: getDashboardDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  "Overview",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: SummaryCard(
                            title: "Pending Verifications",
                            value: counts["pending-mess-verification"].toString(),
                            icon: Icons.pending_actions,
                            color: Colors.orange)),
                    SizedBox(width: 16),
                    Expanded(
                        child: SummaryCard(
                            title: "Total Messes",
                            value: counts["total-mess"].toString(),
                            icon: Icons.store,
                            color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: SummaryCard(
                            title: "Total Customers",
                            value: counts["total-customers"].toString(),
                            icon: Icons.people,
                            color: Colors.blue)),
                    SizedBox(width: 16),
                    Expanded(
                        child: SummaryCard(
                            title: "Reported Issues",
                            value: "03",
                            icon: Icons.report_problem,
                            color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "Recent Activity",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const ActivityCard(
                  title: "New Mess Registration",
                  subtitle: "'Shree Krishna Mess' is awaiting verification.",
                  icon: Icons.storefront,
                ),
                const ActivityCard(
                  title: "Location Added",
                  subtitle: "New verified location added in Hinjewadi Phase 1.",
                  icon: Icons.location_on,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> getDashboardDetails() async {
    if (isFetched) {
      return;
    }
    String apiUrl = '${url}admin/dashboard/counts';
    String? token = await getTokenId();
    while (token == null) {
      token = await getTokenId();
    }
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    try {
      setState(() {
        counts = jsonDecode(response.body);
        isFetched = true;
      });
    } catch (e) {
      customToast(message: e, context: this);
    }
  }
}
