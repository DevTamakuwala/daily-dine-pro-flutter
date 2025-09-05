import 'dart:convert';

import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:dailydine/Screens/user/admin/admin_dashboard_screen.dart';
import 'package:dailydine/Screens/user/customer/customer_dashboard_screen.dart';
import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../credentials/api_url.dart';
import '../encryption/encrypt_text.dart';
import '../enums/user_types.dart';
import 'Auth/registration_successful_screen.dart';
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

    if (!mounted) return;

    // Get the screen size reliably here
    final Size screenSize = MediaQuery.of(context).size;
    final String publicKey =
        await rootBundle.loadString('assets/key/public.pem');

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
      nextPage =
          await checkLoginStatus(email, password, token, screenSize, publicKey);
      // Hello(token: token)
    }

    // Use the mounted check for safety before navigating
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) => nextPage,
      ),
    );
    // if (mounted) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => nextPage),
    //   );
    // }
  }

  Future<Widget> checkLoginStatus(String email, String password, String token,
      Size screenSize, String publicKey) async {
    String encryptedPassword = await compute(
        encryptPassword, {'password': password, 'publicKey': publicKey});
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

    // print(response.body);
    print(response.statusCode);

    if (response.statusCode == 302) {
      print("Status code 302");
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String tokenId = responseBody["Token"];
      bool visible = responseBody["Visible"];

      if (tokenId != token) {
        print("Different token");
        await saveTokenId(tokenId);
      }

      if (UserType.MessOwner.name == responseBody["UserRole"]) {
        print("Mess Owner Role");
        if (!visible) {
          print("Not Visible");
          return RegistrationSuccessfulScreen();
        }
        print("Visible");
        return MessDashboardScreen(token: tokenId);
      } else if (UserType.Customer.name == responseBody["UserRole"]) {
        return CustomerDashboardScreen(token: tokenId);
      } else if (UserType.Admin.name == responseBody["UserRole"]) {
        return AdminDashboardScreen(token: tokenId);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        return AuthScreen(screenSize: screenSize);
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return AuthScreen(screenSize: screenSize);
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
