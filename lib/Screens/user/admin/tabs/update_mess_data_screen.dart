import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../credentials/api_url.dart';
import '../../../../service/save_shared_preference.dart';
import '../../../../widgets/build_mess_list.dart';
import '../../../../widgets/custom_toast.dart';

// Placeholder screen for the "Messes" tab
class UpdateMessDataScreen extends StatefulWidget {
  const UpdateMessDataScreen({super.key});

  @override
  State<UpdateMessDataScreen> createState() => _UpdateMessDataScreenState();
}

class _UpdateMessDataScreenState extends State<UpdateMessDataScreen> {
  List<dynamic> _verifiedMess = [];

  bool fetched = false;

  @override
  Widget build(BuildContext context) {
    // In the future, you would fetch and display a list of all messes here.
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
            return messList(_verifiedMess, (item) {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         VerifyMessDetailsScreen(
              //           userId: item["mess"]["messId"],
              //           messOwnerName: "${item['firstName']!} ${item['lastName']}",
              //           email: item['email'],
              //           phoneNo: item['phoneNo'].toString(),
              //         ),
              //   ),
              // );
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
    String apiUrl = '${url}mess/verified';
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
        _verifiedMess = jsonDecode(response.body);
        fetched = true;
      } catch(e) {
        customToast(message: e,context: this);
      }
  }
}
