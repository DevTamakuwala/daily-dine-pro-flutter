import 'dart:convert';

import 'package:dailydine/Screens/Hello.dart';
import 'package:dailydine/encryption/encryptText.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'forgot_password_screen.dart';


import '../../credentials/api_url.dart';
import '../../widgets/BuildFlipButton.dart';
import '../../widgets/BuildSubmitButton.dart';
import '../../widgets/BuildTextFormField.dart';

class LoginForm extends StatelessWidget {
  final VoidCallback onFlip;

  LoginForm({super.key, required this.onFlip});

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('loginForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Welcome Back",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Log in to your account",
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        buildTextFormField(
            controller: _loginEmailController,
            label: "Email",
            icon: Icons.email_outlined),
        const SizedBox(height: 16),
        buildTextFormField(
            controller: _loginPasswordController,
            label: "Password",
            icon: Icons.lock_outline,
            obscureText: true),
        const SizedBox(height: 24),
        buildSubmitButton(
            label: "Login",
            onPressed: () async {
              print("Login tapped");
              String email = _loginEmailController.text;
              String password = _loginPasswordController.text;
              await handleLogin(email, password, context);
            }),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // CHANGE: Navigate to the ForgotPasswordScreen when the "Forgot Password?" button is tapped.
              print("Forgot Password tapped!");
              Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF9800), // A nice Google blue
            ),
            child: const Text("Forgot Password?"),
          ),
        ),
        buildFlipButton(
            label: "Don't have an account? Sign Up", onFlip: onFlip),
      ],
    );
  }

  Future<void> handleLogin(String email, String password, BuildContext context) async {
    print("Handler called");
    String encryptedPassword = await encrypt(password);
    String apiUrl = '${url}auth/login';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $encryptedPassword"
      },
      body: jsonEncode({
        "email": email,
        "password": encryptedPassword,
      }),
    );

    if (response.statusCode == 302) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) => Hello(token : response.body),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      // print('Failed: ${response.statusCode} - ${response.body}');
    }
  }
}
