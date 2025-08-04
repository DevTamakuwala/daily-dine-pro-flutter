import 'dart:convert';

import 'package:dailydine/Screens/Hello.dart';
import 'package:dailydine/encryption/encryptText.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
              final response = await http.post(
                Uri.parse(apiUrl),
                headers: {
                  "Content-Type": "application/json",
                },
                body: jsonEncode({
                  "email": email,
                  "password": password,
                }),
              );

              if (response.statusCode == 302) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => Hello(),
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
        buildFlipButton(
            label: "Don't have an account? Sign Up", onFlip: onFlip),
      ],
    );
  }
}
