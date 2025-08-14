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
              String email = _loginEmailController.text;
              String password = await encrypt(_loginPasswordController.text);
              String apiUrl = '${url}auth/login';
              print("API getting called $url");
              final response = await http.post(
                Uri.parse(apiUrl),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $password"
                },
                body: jsonEncode({
                  "email": email,
                  "password": password,
                }),
              );

              print("API called");

              if (response.statusCode == 302) {
                print("Login Successful");
                print(response.body);
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
                print('Failed: ${response.statusCode} - ${response.body}');
              }
            }),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // For example, navigate to a ForgotPasswordScreen.
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
}
