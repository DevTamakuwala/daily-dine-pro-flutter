import 'dart:convert';

import 'package:dailydine/Screens/Auth/auth_screen.dart';
import 'package:dailydine/Screens/Auth/registration_successful_screen.dart';
import 'package:dailydine/Screens/Auth/two_factor/verify_two_factor_screen.dart';
import 'package:dailydine/Screens/user/customer/customer_dashboard_screen.dart';
import 'package:dailydine/Screens/profile_page.dart';
import 'package:dailydine/encryption/encrypt_text.dart';
import 'package:dailydine/service/save_shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../credentials/api_url.dart';
import '../../widgets/build_flip_button.dart';
import '../../widgets/build_submit_button.dart';
import '../../widgets/build_text_form_field.dart';
import '../user/admin/admin_dashboard_screen.dart';
import '../user/customer/CustomerHomeScreen.dart';
import '../user/mess_owner/mess_dashboard_screen.dart';
import '../user/mess_owner/tabs/menu_management_screen.dart';
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
  bool _isPasswordObscured = true;

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
          obscureText: _isPasswordObscured, // Controls visibility
          suffixIcon: _isPasswordObscured
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixIconPressed: () {
            setState(() {
              _isPasswordObscured = !_isPasswordObscured;
            });
          },
        ),
        const SizedBox(height: 24),
        buildSubmitButton(
            label: "MessDashboardScreen",
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (context) => CustomerDashboardScreen()));
                  //builder: (context) => VerifyMessDetailsScreen(),
                  builder: (context) => CustomerDashboardScreen(token: '',
                  ),
                ),
              );
            }),
        const SizedBox(height: 15),
        buildSubmitButton(
            label: "Login",
            onPressed: () async {
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
    String encryptedPassword = await encrypt(password);
    String apiUrl = '${url}auth/login';
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

    if (response.statusCode == 302) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String tokenId = responseBody["Token"];
      bool visible = responseBody["Visible"];
      int userId = responseBody["UserId"];
      await saveTokenId(tokenId);
      await saveEmail(email);
      await saveUserId(userId);
      await savePassword(password);
      await saveUserRole(responseBody["UserRole"]);
      // CHANGE (from git): Previously this code popped the current route here.
      // The pop was commented out to avoid removing the login screen before
      // navigation to role-specific dashboards. Keep this behavior in mind
      // if navigation flow seems off.
      // Navigator.pop(context);
      switch (responseBody["UserRole"]) {
        case "MessOwner":
          // CHANGE (from git): Added a debug print to log the "Visible" flag
          // received from the backend. Useful for debugging visibility flow.
          // CHANGE: Added explicit handling for when a MessOwner is not visible
          // (e.g., registration incomplete). This branch navigates to
          // RegistrationSuccessfulScreen.
          if (!visible) {
            Navigator.push(
              context,
              MaterialPageRoute(
                //builder: (builder) => Hello(token: response.body),
                builder: (builder) => RegistrationSuccessfulScreen(),
              ),
            );
          } else if (visible) {
            if (!responseBody["MfaEnable"]) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => MessDashboardScreen(token: tokenId),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => VerifyTwoFactorScreen(
                      isInitialSetup: false,
                      idToken: tokenId,
                      email: email,
                      responseBody: responseBody,
                      from: "Login"),
                ),
              );
            }
          }

        case "Customer":
          if (visible) {
            if (responseBody["MfaEnable"]) {
              // Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => VerifyTwoFactorScreen(
                      isInitialSetup: false,
                      idToken: tokenId,
                      email: email,
                      from: "Login",
                      responseBody: responseBody),
                ),
              );
            } else {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (builder) => Hello(token: response.body),
                  builder: (builder) => CustomerHomeScreen(token: '',),
                ),
              );
            }
          } else {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                //builder: (builder) => Hello(token: response.body),
                builder: (builder) => AuthScreen(
                  screenSize: MediaQuery.of(context).size,
                ),
              ),
            );
          }

        case "Admin":
          if (visible) {
            if (responseBody["MfaEnable"]) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => VerifyTwoFactorScreen(
                      isInitialSetup: false,
                      idToken: tokenId,
                      email: email,
                      from: "Login",
                      responseBody: responseBody),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (builder) => Hello(token: response.body),
                  builder: (builder) => AdminDashboardScreen(token: tokenId),
                ),
              );
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                //builder: (builder) => Hello(token: response.body),
                builder: (builder) => AuthScreen(
                  screenSize: MediaQuery.of(context).size,
                ),
              ),
            );
          }


        default:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) =>
                  AuthScreen(screenSize: MediaQuery.of(context).size),
            ),
          );
      }
    } else {
      if(mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Login Failed"),
              content: Text(response.body), // Shows the error message from the server
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
