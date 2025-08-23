// --- SIGNUP FORM WIDGET ---
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../credentials/api_url.dart';
import '../../encryption/encrypt_text.dart';
import '../../enums/user_types.dart';
import '../../widgets/build_flip_button.dart';
import '../../widgets/build_submit_button.dart';
import '../../widgets/build_text_form_field.dart';
import '../hello.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onFlip;

  const SignupForm({super.key, required this.onFlip});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  // State and controllers from your provided UI
  final _messOwnerFormKey = GlobalKey<FormState>();
  final _customerFormKey = GlobalKey<FormState>();

  // CHANGE: The default user type is changed to "Customer" to prioritize the more common user type.
  UserType _selectedUserType = UserType.Customer;

  // Mess Owner Controllers
  final _messNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  final _ownerConfirmPasswordController = TextEditingController();

  // Customer Controllers
  final _customerFirstNameController = TextEditingController();
  final _customerLastNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerPasswordController = TextEditingController();
  final _customerConfirmPasswordController = TextEditingController();

  // Common Controllers
  final _signupPhoneController = TextEditingController();
  final _signupEmailController = TextEditingController();

  @override
  void dispose() {
    _messNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _signupPhoneController.dispose();
    _signupEmailController.dispose();
    _customerFirstNameController.dispose();
    _customerLastNameController.dispose();
    _customerPhoneController.dispose();
    _ownerPasswordController.dispose();
    _ownerConfirmPasswordController.dispose();
    _customerPasswordController.dispose();
    _customerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('signupForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Create Account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ToggleButtons(
          // CHANGE: The order of the toggle buttons is changed to reflect the new default user type.
          isSelected: [
            _selectedUserType == UserType.Customer,
            _selectedUserType == UserType.MessOwner
          ],
          onPressed: (index) {
            setState(() {
              _selectedUserType =
                  index == 0 ? UserType.Customer : UserType.MessOwner;
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Colors.orange.shade700,
          color: Colors.orange.shade700,
          borderColor: Colors.orange.shade700,
          selectedBorderColor: Colors.orange.shade700,
          children: const [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Customer")),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Mess Owner")),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          // CHANGE: The default form is changed to the customer form.
          child: _selectedUserType == UserType.Customer
              ? _buildCustomerSubForm()
              : _buildMessOwnerSubForm(),
        ),
        const SizedBox(height: 16),
        buildFlipButton(
            label: "Already have an account? Login", onFlip: widget.onFlip),
      ],
    );
  }

  Widget _buildMessOwnerSubForm() {
    return Form(
      key: _messOwnerFormKey,
      child: Column(
        key: const ValueKey('messOwnerForm'),
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextFormField(
              controller: _messNameController,
              label: "Mess Name",
              icon: Icons.storefront,
              validator: (v) => v!.isEmpty ? "Mess Name is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _ownerNameController,
              label: "Owner's Full Name",
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? "Owner's Name is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _addressController,
              label: "Address",
              icon: Icons.location_on_outlined,
              validator: (v) => v!.isEmpty ? "Address is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _cityController,
              label: "City",
              icon: Icons.location_city,
              validator: (v) => v!.isEmpty ? "City is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _signupPhoneController,
              label: "Phone Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v!.length < 10 ? "Enter a valid phone number" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _signupEmailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!)
                  ? "Enter a valid email"
                  : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _ownerPasswordController,
              label: "Password",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v!.length < 6
                  ? "Password must be at least 6 characters"
                  : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _ownerConfirmPasswordController,
              label: "Confirm Password",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v != _ownerPasswordController.text
                  ? "Passwords do not match"
                  : null),
          const SizedBox(height: 20),
          buildSubmitButton(label: "Sign Up as Owner", onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildCustomerSubForm() {
    return Form(
      key: _customerFormKey,
      child: Column(
        key: const ValueKey('customerForm'),
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTextFormField(
              controller: _customerFirstNameController,
              label: "First Name",
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? "First Name is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _customerLastNameController,
              label: "Last Name",
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? "Last Name is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _customerPhoneController,
              label: "Contact no",
              icon: Icons.phone,
              validator: (v) => v!.isEmpty ? "contact no is required" : null,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _signupEmailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!)
                  ? "Enter a valid email"
                  : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _customerPasswordController,
              label: "Password",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v!.length < 6
                  ? "Password must be at least 6 characters"
                  : null),
          const SizedBox(height: 12),
          buildTextFormField(
              controller: _customerConfirmPasswordController,
              label: "Confirm Password",
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v != _customerPasswordController.text
                  ? "password does not matching please check"
                  : null),
          const SizedBox(height: 20),
          buildSubmitButton(
              label: "Sign Up as Customer",
              onPressed: () {
                print("Clicked");
                if (_customerFormKey.currentState!.validate()) {
                  handleCustomerSignUp(
                    _customerFirstNameController.text,
                    _customerLastNameController.text,
                    _signupEmailController.text,
                    _customerPhoneController.text,
                    _customerPasswordController.text,
                    context,
                    null,
                    DateTime.now().toUtc().toIso8601String(),
                  );
                }
              }),
        ],
      ),
    );
  }

  Future<void> handleCustomerSignUp(
      String fname,
      String lname,
      String email,
      String phone,
      String password,
      BuildContext context,
      DateTime? birthDate,
      String date) async {
    String encryptedPassword = await encrypt(password);
    String apiUrl = '${url}auth/register';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        // "Authorization": "Bearer $encryptedPassword"
      },
      body: jsonEncode({
        "createdBy": 0,
        "createdAt": date,
        "modifiedBy": 0,
        "modifiedAt": date,
        "userId": 0,
        "email": email,
        "password": encryptedPassword,
        "firstName": fname,
        "lastName": lname,
        "phoneNo": phone,
        "role": _selectedUserType.name,
        "active": true,
        "customer": {
          "createdBy": 0,
          "createdAt": date,
          "modifiedBy": 0,
          "modifiedAt": date,
          "customerId": 0,
          "status": "ACTIVE",
          "dateOfBirth": birthDate ?? "",
        }
      }),
    );

    if (response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) => Hello(token: response.body),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }
}
