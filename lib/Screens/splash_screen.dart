import 'dart:convert';

import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:dailydine/Screens/user/admin/admin_dashboard_screen.dart';
import 'package:dailydine/Screens/user/customer/customer_dashboard_screen.dart';
import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../credentials/api_url.dart';
import '../encryption/encrypt_text.dart';
import '../enums/user_types.dart';
import 'user/mess_owner/mess_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for the splash screen duration
    await Future.delayed(const Duration(seconds: 3));

    // Get the screen size reliably here
    final Size screenSize = MediaQuery.of(context).size;

    // Determine the next page
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String token = prefs.getString('token') ?? ''; // Assuming you save the token with this key
    String token = await getTokenId() ?? '';

    Widget nextPage;
    if (token.isEmpty) {
      // Pass the collected screen size to the AuthScreen
      nextPage = AuthScreen(screenSize: screenSize);
    } else {
      String email = await getEmail() ?? '';
      String password = await getPassword() ?? '';
      nextPage = await checkLoginStatus(email, password, token);
      // Hello(token: token)
    }

    // Use the mounted check for safety before navigating
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  Future<Widget> checkLoginStatus(String email, String password, String token) async {
    String encryptedPassword = await encrypt(password);
    String apiUrl = '${url}auth/login';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": encryptedPassword,
      }),
    );

    List<String> responseBody = response.body.split(" ");

    String tokenId = responseBody[0];

    if (tokenId != token) {
      await saveTokenId(tokenId);
    }

    if (UserType.MessOwner.name == responseBody[1]) {
      return MessDashboardScreen(token: tokenId);
    } else if (UserType.Customer.name == responseBody[1]) {
      return CustomerDashboardScreen(token: tokenId);
    } else if (UserType.Admmin.name == responseBody[1]) {
      return AdminDashboardScreen(token: tokenId);
    } else {
      return AuthScreen(screenSize: MediaQuery.of(context).size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/DailyDinePro.png", width: 200, height: 200),
          ],
        ),
      ),
    );
  }
}
