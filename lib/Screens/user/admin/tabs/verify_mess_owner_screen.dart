import 'dart:convert';

import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../credentials/api_url.dart';
import '../../../../widgets/build_mess_list.dart';
import '../../../../widgets/custom_toast.dart';
import '../verify_mess_details_screen.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: FutureBuilder(
        future: getMessDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return messList(_pendingVerifications, (item) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyMessDetailsScreen(
                    userId: item["mess"]["messId"],
                    messOwnerName: "${item['firstName']!} ${item['lastName']}",
                    email: item['email'],
                    phoneNo: item['phoneNo'].toString(),
                  ),
                ),
              );
            });
          }
        },
      ),
    );
  }

  Future<void> getMessDetails() async {
    if (fetched) {
      return;
    }
    String apiUrl = '${url}mess/unverified';
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

    setState(() {
      try {
        _pendingVerifications = jsonDecode(response.body);
        fetched = true;
      } catch (e) {
        customToast(message: e,context: this);
      }
    });
  }
}
