import 'dart:convert';

import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:dailydine/Screens/Auth/registration_successful_screen.dart';
import 'package:dailydine/Screens/Auth/two_factor/setup_two_factor_screen.dart';
import 'package:dailydine/Screens/user/customer/customer_dashboard_screen.dart';
import 'package:dailydine/encryption/encrypt_text.dart';
import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../credentials/api_url.dart';
import '../../widgets/build_flip_button.dart';
import '../../widgets/build_submit_button.dart';
import '../../widgets/build_text_form_field.dart';
import '../user/admin/admin_dashboard_screen.dart';
import '../user/admin/tabs/verify_mess_details_screen.dart';
import '../user/mess_owner/mess_dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onFlip;

  const LoginForm({super.key, required this.onFlip});

  @override
  State<LoginForm> createState() => _LoginformState();
}

class _LoginformState extends State<LoginForm> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      // key: const ValueKey('loginForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // if (isLoading)
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
            label: "VerifyMessDetailsScreen",
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (context) => CustomerDashboardScreen()));
                  builder: (context) => VerifyMessDetailsScreen(),
                ),
              );
            }),
        const SizedBox(height: 15),
        buildSubmitButton(
            label: "Setup Two factor",
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (context) => CustomerDashboardScreen()));
                  builder: (context) => VerifyTwoFactorScreen(),
                ),
              );
            }),
        const SizedBox(height: 15),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF9800), // A nice Google blue
            ),
            child: const Text("Forgot Password?"),
          ),
        ),
        buildFlipButton(
            label: "Don't have an account? Sign Up", onFlip: widget.onFlip),
      ],
    );
  }

  Future<void> handleLogin(
      String email, String password, BuildContext context) async {
    print("Handler called");
    print(url);
    String encryptedPassword = await encrypt(password);
    String apiUrl = '${url}auth/login';
    print(apiUrl);
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer $encryptedPassword"
      },
      body: jsonEncode({
        "email": email,
        "password": encryptedPassword,
      }),
    );

    print(response.body);

    if (response.statusCode == 302) {
      List<String> responseBody = response.body.split(" ");
      String tokenId = responseBody[0];
      String visible = responseBody[2];
      await saveTokenId(tokenId);
      await saveEmail(email);
      await savePassword(password);
      await saveUserRole(responseBody[1]);
      Navigator.pop(context);
      switch (responseBody[1]) {
        case "MessOwner":
          if (visible == "false") {
            Navigator.push(
              context,
              MaterialPageRoute(
                //builder: (builder) => Hello(token: response.body),
                builder: (builder) => RegistrationSuccessfulScreen(),
              ),
            );
          } else if (visible == "true") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builder) => MessDashboardScreen(token: tokenId),
              ),
            );
          }

        case "Customer":
          Navigator.push(
            context,
            MaterialPageRoute(
              //builder: (builder) => Hello(token: response.body),
              builder: (builder) => CustomerDashboardScreen(token: tokenId),
            ),
          );

        case "Admin":
          Navigator.push(
            context,
            MaterialPageRoute(
              //builder: (builder) => Hello(token: response.body),
              builder: (builder) => AdminDashboardScreen(token: tokenId),
            ),
          );

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     //builder: (builder) => Hello(token: response.body),
        //     builder: (builder) => MessDashboardScreen(token: tokenId),
        //   ),
        // );

        default:
          Navigator.push(
            context,
            MaterialPageRoute(
              //builder: (builder) => Hello(token: response.body),
              builder: (builder) =>
                  AuthScreen(screenSize: MediaQuery.of(context).size),
            ),
          );
      }
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
