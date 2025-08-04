// --- SIGNUP FORM WIDGET ---
import 'package:flutter/material.dart';

import 'AuthScreen.dart';
import '../../widgets/BuildFlipButton.dart';
import '../../widgets/BuildSubmitButton.dart';
import '../../widgets/BuildTextFormField.dart';

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
  UserType _selectedUserType = UserType.MessOwner;

  // Mess Owner Controllers
  final _messNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  final _ownerConfirmPasswordController = TextEditingController();

  // Customer Controllers
  final _customerNameController = TextEditingController();
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
    _customerNameController.dispose();
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
        const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ToggleButtons(
          isSelected: [_selectedUserType == UserType.MessOwner, _selectedUserType == UserType.Customer],
          onPressed: (index) {
            setState(() {
              _selectedUserType = index == 0 ? UserType.MessOwner : UserType.Customer;
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Colors.orange.shade700,
          color: Colors.orange.shade700,
          borderColor: Colors.orange.shade700,
          selectedBorderColor: Colors.orange.shade700,
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Mess Owner")),
            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Customer")),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _selectedUserType == UserType.MessOwner
              ? _buildMessOwnerSubForm()
              : _buildCustomerSubForm(),
        ),
        const SizedBox(height: 16),
        buildFlipButton(label: "Already have an account? Login", onFlip: widget.onFlip),
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
          buildTextFormField(controller: _messNameController, label: "Mess Name", icon: Icons.storefront, validator: (v) => v!.isEmpty ? "Mess Name is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _ownerNameController, label: "Owner's Full Name", icon: Icons.person_outline, validator: (v) => v!.isEmpty ? "Owner's Name is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _addressController, label: "Address", icon: Icons.location_on_outlined, validator: (v) => v!.isEmpty ? "Address is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _cityController, label: "City", icon: Icons.location_city, validator: (v) => v!.isEmpty ? "City is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _signupPhoneController, label: "Phone Number", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.length < 10 ? "Enter a valid phone number" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _signupEmailController, label: "Email Address", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!) ? "Enter a valid email" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _ownerPasswordController, label: "Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v!.length < 6 ? "Password must be at least 6 characters" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _ownerConfirmPasswordController, label: "Confirm Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v != _ownerPasswordController.text ? "Passwords do not match" : null),
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
          buildTextFormField(controller: _customerNameController, label: "Full Name", icon: Icons.person_outline, validator: (v) => v!.isEmpty ? "Full Name is required" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _signupEmailController, label: "Email Address", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!) ? "Enter a valid email" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _customerPasswordController, label: "Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v!.length < 6 ? "Password must be at least 6 characters" : null),
          const SizedBox(height: 12),
          buildTextFormField(controller: _customerConfirmPasswordController, label: "Confirm Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v != _customerPasswordController.text ? "Passwords do not match" : null),
          const SizedBox(height: 20),
          buildSubmitButton(label: "Sign Up as Customer", onPressed: () {}),
        ],
      ),
    );
  }
}