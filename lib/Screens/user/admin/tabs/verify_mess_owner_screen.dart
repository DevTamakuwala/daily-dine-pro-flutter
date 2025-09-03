import 'dart:convert';

import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../credentials/api_url.dart';
import '../verify_mess_details_screen.dart'; // Import the details screen

// CHANGE SUMMARY (from git/user edits):
// - Replaced static mock list with live fetch from the API (getMessDetails).
// - Added http import and token retrieval via save_shared_preference to call protected API.
// - When building list items, the code reads item['createdAt'] and converts it
//   using DateTime.fromMillisecondsSinceEpoch((createdAt as num).toInt()) then formats it
//   with DateFormat('dd-MM-yyyy'). NOTE: this assumes createdAt is a numeric timestamp
//   (milliseconds). If backend sends an ISO string, DateTime.parse should be used instead.
// - Tapping an item now navigates to VerifyMessDetailsScreen and passes userId (item['userId']).
// - Sets a `fetched` flag to avoid repeated fetches; uses setState to store results.

// A screen that displays a list of mess owners pending verification.
class VerifyMessOwnerScreen extends StatefulWidget {
  const VerifyMessOwnerScreen({super.key});

  @override
  State<VerifyMessOwnerScreen> createState() => _VerifyMessOwnerScreenState();
}

class _VerifyMessOwnerScreenState extends State<VerifyMessOwnerScreen> {
  // --- Mock Data (In a real app, you would fetch this from your API) ---
  List<dynamic> _pendingVerifications = [];

  bool fetched = false;

  @override
  Widget build(BuildContext context) {
    if (!fetched) {
      getMessDetails();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _pendingVerifications.length,
        itemBuilder: (context, index) {
          final item = _pendingVerifications[index];
          final createdAtValue = item['createdAt'];
          // Use a robust parser that accepts numeric timestamps (seconds or milliseconds)
          // or ISO date strings. This avoids the 'String.toInt' runtime error.
          DateTime parseCreatedAt(dynamic v) {
            if (v == null) return DateTime.now();
            if (v is num) {
              int millis = v.toInt();
              // If value looks like seconds (10 digits), convert to ms
              if (millis.abs() < 1000000000000) millis = millis * 1000;
              return DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
            }
            final s = v.toString();
            try {
              return DateTime.parse(s).toLocal();
            } catch (_) {
              // Fallback: try parsing a common 'yyyy-MM-dd HH:mm:ss' format
              try {
                return DateTime.parse(s.replaceFirst(' ', 'T')).toLocal();
              } catch (_) {
                return DateTime.now();
              }
            }
          }

          final dateTime = parseCreatedAt(createdAtValue);
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                // When tapped, navigate to the detailed verification screen.
                // In a real app, you would pass the specific item's data to the screen.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyMessDetailsScreen(
                      userId: item['userId'],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.storefront),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['mess']['messName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Owner: ${item['firstName']!}"
                            "${item['lastName']}",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('dd-MM-yyyy').format(dateTime),
                          // item['createdAt'].toString(),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getMessDetails() async {
    String apiUrl = '${url}mess/';
    String? token = await getTokenId();
    while (token == null) {
      token = await getTokenId();
    }
    print(token);
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    print(jsonDecode(response.body));
    setState(() {
      _pendingVerifications = jsonDecode(response.body);
      fetched = true;
    });
  }
}
