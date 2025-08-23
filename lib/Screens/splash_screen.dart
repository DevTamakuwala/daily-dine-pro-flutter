import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:dailydine/Screens/hello.dart';
import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? ''; // Assuming you save the token with this key

    Widget nextPage;
    if (token.isEmpty) {
      // Pass the collected screen size to the AuthScreen
      nextPage = AuthScreen(screenSize: screenSize);
    } else {
      nextPage = Hello(token: token);
    }

    // Use the mounted check for safety before navigating
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
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